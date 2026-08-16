const std = @import("std");

const App = @import("App.zig");
const Buffer = @import("Buffer.zig");

const Writer = @This();

app: *App,
buffer: *Buffer,
running: bool = true,

pub fn init(app: *App, buffer: *Buffer) Writer {
    return .{
        .app = app,
        .buffer = buffer,
    };
}

pub fn draw(writer: *Writer) !void {
    try writer.app.term.moveTo(1, 999);
    try writer.app.term.setColor(.yellow, true);
    try writer.app.term.writeAll("INSERT");
    try writer.app.term.resetColor();
    try writer.buffer.draw(&writer.app.term);
}

pub fn handleInput(writer: *Writer, input: u8) !void {
    switch (input) {
        10 => try writer.buffer.newLine(writer.app.gpa),
        27 => writer.running = false,
        127 => try writer.buffer.remove(writer.app.gpa),
        else => try writer.buffer.add(writer.app.gpa, input),
    }
}
