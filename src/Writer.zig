const std = @import("std");

const App = @import("App.zig");

const Writer = @This();

app: *App,
running: bool = true,

pub fn init(app: *App) Writer {
    return .{ .app = app };
}

pub fn run(writer: *Writer) !void {
    writer.app.dirty = true;
    while (writer.running) {
        if (writer.app.dirty) {
            try writer.draw();
            try writer.app.flush();
        }
        try writer.update();
    }
}

fn draw(writer: *Writer) !void {
    try writer.app.draw();
}

fn update(writer: *Writer) !void {
    const minput = try writer.app.term.readByte();
    if (minput) |input| {
        writer.app.dirty = true;
        try writer.handleInput(input);
    }
}

fn handleInput(writer: *Writer, input: u8) !void {
    switch (input) {
        27 => writer.running = false,
        127 => _ = writer.app.buf.pop(),
        else => try writer.app.buf.append(writer.app.gpa, input),
    }
}
