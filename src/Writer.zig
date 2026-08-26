const std = @import("std");

const rt = @import("raw_term");

const Buffer = @import("Buffer.zig");
const Window = @import("Window.zig");

const Writer = @This();

window: *Window,
running: bool = true,

pub fn init(gpa: std.mem.Allocator, window: *Window) Writer {
    window.status.set(gpa, .insert);
    return .{
        .window = window,
    };
}

pub fn start(_: Writer, term: *rt.RawTerm) !void {
    try term.setCursor(.bar);
}

pub fn end(_: Writer, term: *rt.RawTerm) !void {
    try term.setCursor(.default);
}

pub fn draw(writer: Writer, term: *rt.RawTerm) !void {
    try writer.window.draw(term, true);
}

pub fn handleInput(writer: *Writer, input: u8, app: *rt.App) !bool {
    switch (input) {
        10 => try writer.window.buffer.newLine(app.gpa),
        27 => writer.running = false,
        127 => try writer.window.buffer.remove(app.gpa),
        else => try writer.window.buffer.add(app.gpa, input),
    }
    return true;
}

pub fn deinit(writer: *Writer, gpa: std.mem.Allocator) void {
    writer.window.status.set(gpa, .none);
    writer.* = undefined;
}
