const std = @import("std");

const RawTerm = @import("raw_term").RawTerm;

const Opener = @import("Opener.zig");
const Writer = @import("Writer.zig");

const App = @This();

io: std.Io,
gpa: std.mem.Allocator,
term: RawTerm,
dirty: bool = true,

pub fn init(io: std.Io, gpa: std.mem.Allocator) !App {
    const term = try RawTerm.init(io);

    return .{
        .gpa = gpa,
        .io = io,
        .term = term,
    };
}

pub fn deinit(app: *App) void {
    app.term.deinit();
    app.* = undefined;
}
