const std = @import("std");

const App = @import("raw_term").App;
const RawTerm = @import("raw_term").RawTerm;

const Buffer = @import("Buffer.zig");

const Entry = struct {
    name: []const u8,
};

const Opener = @This();

buffer: *Buffer,
entries: []const Entry,
arena: std.heap.ArenaAllocator,
cursor: usize = 0,
running: bool = true,

pub fn init(io: std.Io, gpa: std.mem.Allocator, buffer: *Buffer) !Opener {
    var arena = std.heap.ArenaAllocator.init(gpa);
    const dir = try std.Io.Dir.cwd().openDir(io, ".", .{ .iterate = true });
    var vec = std.ArrayList(Entry).empty;
    var iter = dir.iterateAssumeFirstIteration();
    while (try iter.next(io)) |entry| {
        const name = try arena.allocator().dupe(u8, entry.name);
        try vec.append(gpa, .{
            .name = name,
        });
    }
    const entries = try vec.toOwnedSlice(gpa);
    return .{
        .arena = arena,
        .buffer = buffer,
        .entries = entries,
    };
}

pub fn start(_: Opener, term: *RawTerm) !void {
    try term.hideCursor();
}

pub fn end(_: Opener, term: *RawTerm) !void {
    try term.showCursor();
}

pub fn draw(opener: Opener, term: *RawTerm) !void {
    try term.goto(1, 1);
    for (opener.entries, 0..) |entry, i| {
        if (opener.cursor == i) {
            try term.writeAll(">");
        } else {
            try term.writeAll(" ");
        }
        try term.print(" {s}\r\n", .{entry.name});
    }
}

pub fn handleInput(opener: *Opener, input: u8, app: *App) !bool {
    switch (input) {
        'q', 27 => opener.running = false,
        'j' => opener.cursor = (opener.cursor + 1) % opener.entries.len,
        'k' => opener.cursor = (opener.cursor + opener.entries.len - 1) % opener.entries.len,
        ' ', 10 => try opener.open(app.io, app.gpa),
        else => return false,
    }
    return true;
}

fn open(opener: *Opener, io: std.Io, gpa: std.mem.Allocator) !void {
    for (opener.entries, 0..) |entry, i| {
        if (i == opener.cursor) {
            try opener.buffer.load(io, gpa, entry.name);
            break;
        }
    }
    opener.running = false;
}

pub fn deinit(opener: *Opener, gpa: std.mem.Allocator) void {
    gpa.free(opener.entries);
    opener.arena.deinit();
    opener.* = undefined;
}
