const std = @import("std");

const App = @import("raw_term").App;

const Runner = @import("Runner.zig");

pub fn main(init: std.process.Init) !u8 {
    run(init) catch |err| switch (err) {
        else => return err,
    };
    return 0;
}

fn run(init: std.process.Init) !void {
    var app = try App.init(init.io, init.gpa);
    defer app.deinit();

    var runner = try Runner.init(init.gpa);
    defer runner.deinit(init.gpa);

    try app.run(&runner);
}
