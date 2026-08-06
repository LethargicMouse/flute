const std = @import("std");

const runApp = @import("raw_term").runApp;

const App = @import("App.zig");
const Opener = @import("Opener.zig");
const Writer = @import("Writer.zig");

const Runner = @This();

app: App,
running: bool = true,

pub fn init(io: std.Io, gpa: std.mem.Allocator) !Runner {
    const app = try App.init(io, gpa);
    return .{
        .app = app,
    };
}

pub fn handleInput(runner: *Runner, input: u8) !void {
    switch (input) {
        'q', 27 => runner.running = false,
        'i' => {
            var writer = Writer.init(&runner.app);
            try runApp(&writer);
        },
        'o' => {
            try runner.app.term.hideCursor();
            var opener = try Opener.init(&runner.app);
            defer opener.deinit();
            try runApp(&opener);
            try runner.app.term.showCursor();
        },
        'h' => {
            if (runner.app.cursor != 0) {
                runner.app.cursor -= 1;
            }
        },
        'l' => {
            if (runner.app.cursor != runner.app.buf.items.len) {
                runner.app.cursor += 1;
            }
        },
        else => runner.app.dirty = false,
    }
}

pub fn draw(runner: *Runner) !void {
    try runner.app.drawBuf();
}

pub fn deinit(runner: *Runner) void {
    runner.app.deinit();
    runner.* = undefined;
}
