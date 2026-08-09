const std = @import("std");

const App = @import("App.zig");

const Writer = @This();

app: *App,
running: bool = true,

pub fn init(app: *App) Writer {
    return .{ .app = app };
}

pub fn draw(writer: *Writer) !void {
    try writer.app.term.moveTo(1, 999);
    try writer.app.term.setColor(.yellow, true);
    try writer.app.term.writeAll("INSERT");
    try writer.app.term.resetColor();
    try writer.app.drawBuf();
}

pub fn handleInput(writer: *Writer, input: u8) !void {
    switch (input) {
        27 => writer.running = false,
        127 => {
            if (writer.app.cursor != 0) {
                _ = writer.app.buf.orderedRemove(writer.app.cursor - 1);
                writer.app.cursor -= 1;
            }
        },
        else => {
            try writer.app.buf.insert(writer.app.gpa, writer.app.cursor, input);
            writer.app.cursor += 1;
        },
    }
}
