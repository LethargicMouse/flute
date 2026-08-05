const std = @import("std");

const App = @import("App.zig");

const Writer = @This();

app: *App,
running: bool = true,

pub fn init(app: *App) Writer {
    return .{ .app = app };
}

pub fn draw(writer: *Writer) !void {
    try writer.app.drawBuf();
}

pub fn handleInput(writer: *Writer, input: u8) !void {
    switch (input) {
        27 => writer.running = false,
        127 => _ = writer.app.buf.pop(),
        else => try writer.app.buf.append(writer.app.gpa, input),
    }
}
