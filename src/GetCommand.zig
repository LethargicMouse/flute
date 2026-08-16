const std = @import("std");

const App = @import("App.zig");
const Window = @import("Window.zig");

const GetCommand = @This();

app: *App,
window: *Window,
command: std.ArrayList(u8) = .empty,
running: bool = true,

pub fn init(app: *App, window: *Window) GetCommand {
    window.status.set(app.gpa, .none);
    return .{
        .app = app,
        .window = window,
    };
}

pub fn draw(get: GetCommand) !void {
    try get.window.draw(&get.app.term, false);
    try get.app.term.moveTo(1, 999);
    try get.app.term.print(":{s}", .{get.command.items});
}

pub fn handleInput(get: *GetCommand, input: u8) !void {
    switch (input) {
        27 => get.running = false,
        10 => try get.submit(),
        127 => _ = get.command.pop(),
        else => try get.command.append(get.app.gpa, input),
    }
}

fn submit(get: *GetCommand) !void {
    get.running = false;
    const command = std.mem.trim(u8, get.command.items, " ");
    if (command.len == 0) {
        return;
    }
    if (std.mem.eql(u8, command, "w")) {
        get.window.status.set(get.app.gpa, .{ .err = .no_path });
        return;
    }
    if (std.mem.startsWith(u8, command, "w ")) {
        const path = command[2..]; // skipping "w "
        try get.window.buffer.save(get.app.io, path);
        return;
    }
    const owned = try get.app.gpa.dupe(u8, command);
    get.window.status.set(get.app.gpa, .{ .err = .{ .invalid_command = owned } });
}

pub fn deinit(get: *GetCommand) void {
    get.command.deinit(get.app.gpa);
    get.* = undefined;
}
