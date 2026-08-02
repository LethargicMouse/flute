const std = @import("std");

const RawTerm = @import("raw_term").RawTerm;

const App = @This();

term: RawTerm,
is_running: bool = true,

pub fn init(io: std.Io) !App {
    const term = try RawTerm.init(io);

    return .{
        .term = term,
    };
}

pub fn run(app: *App) !void {
    try app.term.hideCursor();
    while (app.is_running) {
        try app.draw();
        try app.update();
    }
}

fn draw(app: *App) !void {
    try app.term.clearScreen();
    try app.term.flush();
}

fn update(app: *App) !void {
    const input = try app.term.readByte();
    switch (input) {
        'q', 27 => app.is_running = false,
        else => {},
    }
}

pub fn deinit(app: *App) void {
    app.term.deinit();
    app.* = undefined;
}
