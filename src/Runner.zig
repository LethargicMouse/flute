const std = @import("std");

const runApp = @import("raw_term").runApp;

const App = @import("App.zig");
const Window = @import("Window.zig");
const GetCommand = @import("GetCommand.zig");
const Opener = @import("Opener.zig");
const Writer = @import("Writer.zig");

const Runner = @This();

app: App,
window: Window,
running: bool = true,

pub fn init(io: std.Io, gpa: std.mem.Allocator) !Runner {
    const app = try App.init(io, gpa);
    const window = try Window.init(gpa);
    return .{
        .app = app,
        .window = window,
    };
}

pub fn handleInput(runner: *Runner, input: u8) !void {
    switch (input) {
        'q', 27 => runner.running = false,
        'i' => {
            var writer = Writer.init(&runner.app, &runner.window);
            defer writer.deinit();
            try runApp(&writer);
        },
        'o' => {
            try runner.app.term.hideCursor();
            var opener = try Opener.init(&runner.app, &runner.window.buffer);
            defer opener.deinit();
            try runApp(&opener);
            try runner.app.term.showCursor();
        },
        'h' => runner.window.buffer.goLeft(),
        'j' => runner.window.buffer.goDown(),
        'k' => runner.window.buffer.goUp(),
        'l' => runner.window.buffer.goRight(),
        ':' => {
            var get_command = GetCommand.init(&runner.app, &runner.window);
            defer get_command.deinit();
            try runApp(&get_command);
        },
        else => runner.app.dirty = false,
    }
}

pub fn draw(runner: *Runner) !void {
    try runner.window.draw(&runner.app.term, true);
}

pub fn deinit(runner: *Runner) void {
    runner.window.deinit(runner.app.gpa);
    runner.app.deinit();
    runner.* = undefined;
}
