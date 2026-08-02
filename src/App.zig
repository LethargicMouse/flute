const std = @import("std");

const RawTerm = @import("raw_term").RawTerm;
const Writer = @import("Writer.zig");

const App = @This();

term: RawTerm,
gpa: std.mem.Allocator,
buf: std.ArrayList(u8) = .empty,
running: bool = true,
writing: bool = true,

pub fn init(io: std.Io, gpa: std.mem.Allocator) !App {
    const term = try RawTerm.init(io);

    return .{
        .term = term,
        .gpa = gpa,
    };
}

pub fn run(app: *App) !void {
    try app.term.hideCursor();
    while (app.running) {
        try app.draw();
        try app.term.flush();
        try app.update();
    }
}

pub fn draw(app: *App) !void {
    try app.term.clearScreen();
    try app.term.writeAll(app.buf.items);
}

fn update(app: *App) !void {
    const input = try app.term.readByte();
    try app.handleInput(input);
}

fn handleInput(app: *App, input: u8) !void {
    switch (input) {
        'q', 27 => app.running = false,
        'i' => {
            var writer = Writer.init(app);
            try writer.run();
        },
        else => {},
    }
}

pub fn deinit(app: *App) void {
    app.term.deinit();
    app.buf.deinit(app.gpa);
    app.* = undefined;
}
