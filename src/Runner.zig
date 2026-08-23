const std = @import("std");

const App = @import("raw_term").App;
const RawTerm = @import("raw_term").RawTerm;

const Window = @import("Window.zig");
const GetCommand = @import("GetCommand.zig");
const Opener = @import("Opener.zig");
const Writer = @import("Writer.zig");

const Runner = @This();

window: Window,
running: bool = true,

pub fn init(gpa: std.mem.Allocator) !Runner {
    const window = try Window.init(gpa);
    return .{
        .window = window,
    };
}

pub fn handleInput(runner: *Runner, input: u8, app: *App) !bool {
    switch (input) {
        'q', 27 => runner.running = false,
        'i' => {
            var writer = Writer.init(app.gpa, &runner.window);
            defer writer.deinit(app.gpa);
            try app.run(&writer);
        },
        'o' => {
            var opener = try Opener.init(app.io, app.gpa, &runner.window.buffer);
            defer opener.deinit(app.gpa);
            try app.run(&opener);
        },
        'h' => runner.window.buffer.goLeft(),
        'j' => runner.window.buffer.goDown(),
        'k' => runner.window.buffer.goUp(),
        'l' => runner.window.buffer.goRight(),
        ':' => {
            var get_command = GetCommand.init(app.gpa, &runner.window);
            defer get_command.deinit(app.gpa);
            try app.run(&get_command);
        },
        else => return false,
    }
    return true;
}

pub fn draw(runner: Runner, term: *RawTerm) !void {
    try runner.window.draw(term, true);
}

pub fn deinit(runner: *Runner, gpa: std.mem.Allocator) void {
    runner.window.deinit(gpa);
    runner.* = undefined;
}
