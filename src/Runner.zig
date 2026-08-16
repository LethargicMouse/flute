const std = @import("std");

const runApp = @import("raw_term").runApp;

const App = @import("App.zig");
const Buffer = @import("Buffer.zig");
const Opener = @import("Opener.zig");
const Writer = @import("Writer.zig");

const Runner = @This();

app: App,
buffer: Buffer,
running: bool = true,

pub fn init(io: std.Io, gpa: std.mem.Allocator) !Runner {
    const app = try App.init(io, gpa);
    const buffer = try Buffer.init(gpa);
    return .{
        .app = app,
        .buffer = buffer,
    };
}

pub fn handleInput(runner: *Runner, input: u8) !void {
    switch (input) {
        'q', 27 => runner.running = false,
        'i' => {
            var writer = Writer.init(&runner.app, &runner.buffer);
            try runApp(&writer);
        },
        'o' => {
            try runner.app.term.hideCursor();
            var opener = try Opener.init(&runner.app, &runner.buffer);
            defer opener.deinit();
            try runApp(&opener);
            try runner.app.term.showCursor();
        },
        'h' => runner.buffer.goLeft(),
        'j' => runner.buffer.goDown(),
        'k' => runner.buffer.goUp(),
        'l' => runner.buffer.goRight(),
        else => runner.app.dirty = false,
    }
}

pub fn draw(runner: *Runner) !void {
    try runner.buffer.draw(&runner.app.term);
}

pub fn deinit(runner: *Runner) void {
    runner.buffer.deinit(runner.app.gpa);
    runner.app.deinit();
    runner.* = undefined;
}
