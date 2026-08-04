const std = @import("std");

const RawTerm = @import("raw_term").RawTerm;

const Opener = @import("Opener.zig");
const Writer = @import("Writer.zig");

const App = @This();

term: RawTerm,
io: std.Io,
gpa: std.mem.Allocator,
buf: std.ArrayList(u8) = .empty,
running: bool = true,
dirty: bool = true,

pub fn init(io: std.Io, gpa: std.mem.Allocator) !App {
    const term = try RawTerm.init(io);

    return .{
        .gpa = gpa,
        .io = io,
        .term = term,
    };
}

pub fn run(app: *App) !void {
    try app.term.hideCursor();
    while (app.running) {
        if (app.dirty) {
            try app.draw();
            try app.flush();
        }
        try app.update();
    }
}

pub fn draw(app: *App) !void {
    try app.term.clearScreen();
    try app.term.moveTo(1, 1);
    try app.term.writeAll(app.buf.items);
}

fn update(app: *App) !void {
    const minput = try app.term.readByte();
    if (minput) |input| {
        app.dirty = true;
        try app.handleInput(input);
    }
}

fn handleInput(app: *App, input: u8) !void {
    switch (input) {
        'q', 27 => app.running = false,
        'i' => {
            var writer = Writer.init(app);
            try writer.run();
        },
        'o' => {
            var opener = try Opener.init(app);
            defer opener.deinit();
            try opener.run();
        },
        else => app.dirty = false,
    }
}

pub fn deinit(app: *App) void {
    app.term.deinit();
    app.buf.deinit(app.gpa);
    app.* = undefined;
}

pub fn flush(app: *App) !void {
    try app.term.flush();
    app.dirty = false;
}
