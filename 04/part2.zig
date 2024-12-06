const std = @import("std");
const tookenizeScalar = std.mem.tokenizeScalar;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const ArrayList = std.ArrayList;
const info = std.log.info;
const debug = std.log.debug;
const count = std.mem.count;

pub const std_options = .{ .log_level = .info };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }

    info("Sample Answer: {d}", .{try solve("sampleinput.txt", allocator)});
    info("Answer: {d}", .{try solve("input.txt", allocator)});
}

fn solve(comptime filename: []const u8, allocator: std.mem.Allocator) !usize {
    const file = @embedFile(filename);
    var matrix = ArrayList(ArrayList(u8)).init(allocator);
    defer {
        for (matrix.items) |list| {
            list.deinit();
        }
        matrix.deinit();
    }
    var lines = tookenizeScalar(u8, file, '\n');
    while (lines.next()) |line| {
        var new_line = ArrayList(u8).init(allocator);
        try new_line.appendSlice(line);
        try matrix.append(new_line);
    }
    var output: usize = 0;
    const size = matrix.items.len;
    for (0..size - 2) |i| {
        for (0..size - 2) |j| {
            if (matrix.items[i + 1].items[j + 1] == 'A') {
                const tl = matrix.items[i].items[j];
                const tr = matrix.items[i].items[j + 2];
                const bl = matrix.items[i + 2].items[j];
                const br = matrix.items[i + 2].items[j + 2];
                if (tl == 'M' and tr == 'M' and br == 'S' and bl == 'S') {
                    output += 1;
                } else if (tl == 'S' and tr == 'M' and br == 'M' and bl == 'S') {
                    output += 1;
                } else if (tl == 'S' and tr == 'S' and br == 'M' and bl == 'M') {
                    output += 1;
                } else if (tl == 'M' and tr == 'S' and br == 'S' and bl == 'M') {
                    output += 1;
                }
            }
        }
    }
    return output;
}
