const std = @import("std");

const App = @import("App.zig");

pub fn main(init: std.process.Init) !u8 {
    run(init.io) catch |err| switch (err) {
        else => return err,
    };
    return 0;
}

fn run(io: std.Io) !void {
    var app = try App.init(io);
    defer app.deinit();
    try app.run();
}
