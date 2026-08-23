const std = @import("std");

const RawTerm = @import("raw_term").RawTerm;

const Buffer = @This();

lines: std.ArrayList(std.ArrayList(u8)),
x: usize = 0,
y: usize = 0,

pub fn init(gpa: std.mem.Allocator) !Buffer {
    var lines = std.ArrayList(std.ArrayList(u8)).empty;
    try lines.append(gpa, .empty);

    return .{
        .lines = lines,
    };
}

pub fn draw(buffer: Buffer, term: *RawTerm) !void {
    try term.goto(1, 1);
    for (buffer.lines.items) |line| {
        try term.print("{s}\r\n", .{line.items});
    }
}

pub fn focus(buffer: Buffer, term: *RawTerm) !void {
    const x: u16 = @intCast(buffer.x);
    const y: u16 = @intCast(buffer.y);
    try term.goto(x + 1, y + 1);
}

pub fn deinit(buffer: *Buffer, gpa: std.mem.Allocator) void {
    for (buffer.lines.items) |*line| {
        line.deinit(gpa);
    }
    buffer.lines.deinit(gpa);
    buffer.* = undefined;
}

pub fn remove(buffer: *Buffer, gpa: std.mem.Allocator) !void {
    if (buffer.x == 0 and buffer.y == 0) {
        return;
    }
    if (buffer.x == 0) {
        try buffer.stackLine(gpa);
    }
    buffer.x -= 1;
    _ = buffer.lines.items[buffer.y].orderedRemove(buffer.x);
}

fn stackLine(buffer: *Buffer, gpa: std.mem.Allocator) !void {
    buffer.y -= 1;
    buffer.x = buffer.lines.items[buffer.y].items.len;
    try buffer.lines.items[buffer.y].appendSlice(gpa, buffer.lines.items[buffer.y + 1].items);
    buffer.lines.items[buffer.y + 1].deinit(gpa);
    _ = buffer.lines.orderedRemove(buffer.y + 1);
}

pub fn add(buffer: *Buffer, gpa: std.mem.Allocator, c: u8) !void {
    try buffer.lines.items[buffer.y].insert(gpa, buffer.x, c);
    buffer.x += 1;
}

pub fn load(buffer: *Buffer, io: std.Io, gpa: std.mem.Allocator, path: []const u8) !void {
    for (buffer.lines.items) |*line| {
        line.deinit(gpa);
    }
    buffer.lines.clearRetainingCapacity();
    buffer.x = 0;
    buffer.y = 0;
    const file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io);
    var read_buffer: [2048]u8 = undefined;
    var reader = file.reader(io, &read_buffer);
    while (try reader.interface.takeDelimiter('\n')) |line| {
        var new_line = std.ArrayList(u8).empty;
        try new_line.appendSlice(gpa, line);
        try buffer.lines.append(gpa, new_line);
    }
}

pub fn goLeft(buffer: *Buffer) void {
    if (buffer.x != 0) {
        buffer.x -= 1;
    }
}

pub fn goRight(buffer: *Buffer) void {
    if (buffer.x != buffer.lines.items[buffer.y].items.len) {
        buffer.x += 1;
    }
}

pub fn newLine(buffer: *Buffer, gpa: std.mem.Allocator) !void {
    try buffer.lines.insert(gpa, buffer.y + 1, .empty);
    try buffer.lines.items[buffer.y + 1].appendSlice(gpa, buffer.lines.items[buffer.y].items[buffer.x..]);
    buffer.lines.items[buffer.y].shrinkRetainingCapacity(buffer.x);
    buffer.y += 1;
    buffer.x = 0;
}

pub fn goUp(buffer: *Buffer) void {
    if (buffer.y != 0) {
        buffer.y -= 1;
    }
    const line_len = buffer.getLine().len;
    if (buffer.x > line_len) {
        buffer.x = line_len;
    }
}

pub fn getLine(buffer: Buffer) []u8 {
    return buffer.lines.items[buffer.y].items;
}

pub fn goDown(buffer: *Buffer) void {
    if (buffer.y != buffer.lines.items.len - 1) {
        buffer.y += 1;
    }
    const line_len = buffer.getLine().len;
    if (buffer.x > line_len) {
        buffer.x = line_len;
    }
}

pub fn save(buffer: Buffer, io: std.Io, path: []const u8) !void {
    const file = try std.Io.Dir.cwd().createFile(io, path, .{});
    defer file.close(io);
    var write_buffer: [2048]u8 = undefined;
    var writer = file.writer(io, &write_buffer);
    for (buffer.lines.items) |line| {
        try writer.interface.print("{s}\n", .{line.items});
    }
    try writer.flush();
}
