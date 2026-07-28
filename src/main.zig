const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !u8 {
    run(init.io) catch |err| switch (err) {
        // error.Handled => return 1,
        else => return err,
    };

    return 0;
}

fn run(io: Io) !void {
    var termios = try std.posix.tcgetattr(std.posix.STDIN_FILENO);
    const termios_before = termios;

    termios.lflag.ECHO = false;
    termios.lflag.ICANON = false;
    termios.oflag.OPOST = false;

    try std.posix.tcsetattr(std.posix.STDIN_FILENO, std.posix.TCSA.FLUSH, termios);

    var read_buf: [256]u8 = undefined;
    var reader = Io.File.stdin().reader(io, &read_buf);
    var write_buf: [256]u8 = undefined;
    var writer = Io.File.stdout().writer(io, &write_buf);

    try writer.interface.writeAll("\x1b[2J\x1b[H");
    try writer.flush();

    while (true) {
        const input = try reader.interface.takeByte();
        if (input == 'q') {
            break;
        }
    }

    try std.posix.tcsetattr(std.posix.STDIN_FILENO, std.posix.TCSA.FLUSH, termios_before);
}
