const std = @import("std");

const RawTerm = @import("raw_term").RawTerm;

const Buffer = @import("Buffer.zig");

pub const Status = union(enum) {
    pub const Error = union(enum) {
        invalid_command: []const u8,
        no_path,

        fn draw(err: Error, term: *RawTerm) !void {
            try term.setColor(.red, false);
            try term.writeAll("error: ");
            switch (err) {
                .invalid_command => |command| try term.print("invalid command: `{s}`", .{command}),
                .no_path => try term.writeAll("no path given"),
            }
            try term.setColor(.default, false);
        }

        fn deinit(err: *Error, gpa: std.mem.Allocator) void {
            switch (err.*) {
                .invalid_command => |command| gpa.free(command),
                .no_path => {},
            }
            err.* = undefined;
        }
    };

    err: Error,
    none,
    insert,

    fn draw(status: Status, term: *RawTerm) !void {
        if (status == .none) {
            return;
        }
        try term.goto(1, 999);
        switch (status) {
            .none => unreachable,
            .insert => {
                try term.setColor(.yellow, true);
                try term.writeAll("-- INSERT --");
                try term.setColor(.default, false);
            },
            .err => |err| try err.draw(term),
        }
    }

    pub fn set(status: *Status, gpa: std.mem.Allocator, new: Status) void {
        status.deinit(gpa);
        status.* = new;
    }

    fn deinit(status: *Status, gpa: std.mem.Allocator) void {
        switch (status.*) {
            .none => {},
            .insert => {},
            .err => |*err| err.deinit(gpa),
        }
        status.* = undefined;
    }

    fn needFocus(status: Status) bool {
        switch (status) {
            .none, .insert, .invalid_command => return false,
            .get_command => return true,
        }
    }
};

const Window = @This();

buffer: Buffer,
status: Status = .none,

pub fn init(gpa: std.mem.Allocator) !Window {
    const buffer = try Buffer.init(gpa);
    return .{
        .buffer = buffer,
    };
}

pub fn draw(window: Window, term: *RawTerm, focus_buffer: bool) !void {
    try window.status.draw(term);
    try window.buffer.draw(term);
    if (focus_buffer) {
        try window.buffer.focus(term);
    }
}

pub fn deinit(window: *Window, gpa: std.mem.Allocator) void {
    window.buffer.deinit(gpa);
    window.status.deinit(gpa);
    window.* = undefined;
}
