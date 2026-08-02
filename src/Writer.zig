const std = @import("std");

const App = @import("App.zig");

const Writer = @This();

app: *App,
running: bool = true,

pub fn init(app: *App) Writer {
    return .{ .app = app };
}

pub fn run(writer: *Writer) !void {
    while (writer.running) {
        try writer.draw();
        try writer.app.term.flush();
        try writer.update();
    }
}

fn draw(writer: *Writer) !void {
    try writer.app.draw();
}

fn update(writer: *Writer) !void {
    const input = try writer.app.term.readByte();
    try writer.handleInput(input);
}

fn handleInput(writer: *Writer, input: u8) !void {
    switch (input) {
        27 => writer.running = false,
        127 => _ = writer.app.buf.pop(),
        else => try writer.app.buf.append(writer.app.gpa, input),
    }
}
