const std = @import("std");

const RawTerm = @import("raw_term").RawTerm;

const Opener = @import("Opener.zig");
const Writer = @import("Writer.zig");

const App = @This();

io: std.Io,
gpa: std.mem.Allocator,
term: RawTerm,
buf: std.ArrayList(u8) = .empty,
dirty: bool = true,

pub fn init(io: std.Io, gpa: std.mem.Allocator) !App {
    const term = try RawTerm.init(io);

    return .{
        .gpa = gpa,
        .io = io,
        .term = term,
    };
}

pub fn drawBuf(app: *App) !void {
    try app.term.moveTo(1, 1);
    try app.term.writeAll(app.buf.items);
}

pub fn deinit(app: *App) void {
    app.term.deinit();
    app.buf.deinit(app.gpa);
    app.* = undefined;
}
