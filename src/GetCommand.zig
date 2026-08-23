const std = @import("std");

const App = @import("raw_term").App;
const RawTerm = @import("raw_term").RawTerm;

const Window = @import("Window.zig");

const GetCommand = @This();

window: *Window,
command: std.ArrayList(u8) = .empty,
running: bool = true,

pub fn init(gpa: std.mem.Allocator, window: *Window) GetCommand {
    window.status.set(gpa, .none);
    return .{
        .window = window,
    };
}

pub fn draw(get: GetCommand, term: *RawTerm) !void {
    try get.window.draw(term, false);
    try term.goto(1, 999);
    try term.print(":{s}", .{get.command.items});
}

pub fn handleInput(get: *GetCommand, input: u8, app: *App) !bool {
    switch (input) {
        27 => get.running = false,
        10 => try get.submit(app.io, app.gpa),
        127 => _ = get.command.pop(),
        else => try get.command.append(app.gpa, input),
    }
    return true;
}

fn submit(get: *GetCommand, io: std.Io, gpa: std.mem.Allocator) !void {
    get.running = false;
    const command = std.mem.trim(u8, get.command.items, " ");
    if (command.len == 0) {
        return;
    }
    if (std.mem.eql(u8, command, "w")) {
        get.window.status.set(gpa, .{ .err = .no_path });
        return;
    }
    if (std.mem.startsWith(u8, command, "w ")) {
        const path = command[2..]; // skipping "w "
        try get.window.buffer.save(io, path);
        return;
    }
    const owned = try gpa.dupe(u8, command);
    get.window.status.set(gpa, .{ .err = .{ .invalid_command = owned } });
}

pub fn deinit(get: *GetCommand, gpa: std.mem.Allocator) void {
    get.command.deinit(gpa);
    get.* = undefined;
}
