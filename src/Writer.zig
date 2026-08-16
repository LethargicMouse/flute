const std = @import("std");

const App = @import("App.zig");
const Buffer = @import("Buffer.zig");
const Window = @import("Window.zig");

const Writer = @This();

app: *App,
window: *Window,
running: bool = true,

pub fn init(app: *App, window: *Window) Writer {
    window.status.set(app.gpa, .insert);
    return .{
        .app = app,
        .window = window,
    };
}

pub fn draw(writer: *Writer) !void {
    try writer.window.draw(&writer.app.term, true);
}

pub fn handleInput(writer: *Writer, input: u8) !void {
    switch (input) {
        10 => try writer.window.buffer.newLine(writer.app.gpa),
        27 => writer.running = false,
        127 => try writer.window.buffer.remove(writer.app.gpa),
        else => try writer.window.buffer.add(writer.app.gpa, input),
    }
}

pub fn deinit(writer: *Writer) void {
    writer.window.status.set(writer.app.gpa, .none);
    writer.* = undefined;
}
