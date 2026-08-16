const std = @import("std");

const App = @import("App.zig");
const Buffer = @import("Buffer.zig");

const Opener = @This();

app: *App,
buffer: *Buffer,
dir: std.Io.Dir,
cursor: usize = 0,
entry_count: usize,
running: bool = true,

pub fn init(app: *App, buffer: *Buffer) !Opener {
    const dir = try std.Io.Dir.cwd().openDir(app.io, ".", .{ .iterate = true });
    var entry_count: usize = 0;
    var iter = dir.iterateAssumeFirstIteration();
    while (try iter.next(app.io)) |_| {
        entry_count += 1;
    }
    return .{
        .app = app,
        .buffer = buffer,
        .dir = dir,
        .entry_count = entry_count,
    };
}

pub fn draw(opener: *Opener) !void {
    try opener.app.term.moveTo(1, 1);
    var iter = opener.dir.iterate();
    var i: usize = 0;
    while (try iter.next(opener.app.io)) |entry| : (i += 1) {
        if (opener.cursor == i) {
            try opener.app.term.writeAll(">");
        } else {
            try opener.app.term.writeAll(" ");
        }
        try opener.app.term.print(" {s}\r\n", .{entry.name});
    }
}

pub fn handleInput(opener: *Opener, input: u8) !void {
    switch (input) {
        'q', 27 => opener.running = false,
        'j' => opener.cursor = (opener.cursor + 1) % opener.entry_count,
        'k' => opener.cursor = (opener.cursor + opener.entry_count - 1) % opener.entry_count,
        ' ', 10 => try opener.open(),
        else => opener.app.dirty = false,
    }
}

fn open(opener: *Opener) !void {
    var iter = opener.dir.iterate();
    var i: usize = 0;
    while (try iter.next(opener.app.io)) |entry| : (i += 1) {
        if (i == opener.cursor) {
            try opener.buffer.load(opener.app.io, opener.app.gpa, entry.name);
            break;
        }
    }
    opener.running = false;
}

pub fn deinit(opener: *Opener) void {
    opener.dir.close(opener.app.io);
    opener.* = undefined;
}
