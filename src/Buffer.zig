const std = @import("std");

const RawTerm = @import("raw_term").RawTerm;

const Buffer = @This();

vec: std.ArrayList(u8) = .empty,
cursor: usize = 0,

pub fn init() Buffer {
    return .{};
}

pub fn draw(buffer: Buffer, term: *RawTerm) !void {
    try term.moveTo(1, 1);
    try term.writeAll(buffer.vec.items);
    const cursor: u16 = @intCast(buffer.cursor);
    try term.moveTo(cursor + 1, 1);
}

pub fn deinit(buffer: *Buffer, gpa: std.mem.Allocator) void {
    buffer.vec.deinit(gpa);
    buffer.* = undefined;
}
