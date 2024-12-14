const std = @import("std");
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const info = std.log.info;
const debug = std.log.debug;

pub const std_options = .{ .log_level = .debug };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }

    std.log.info("Sample Answer: {d}", .{try solve("sampleinput.txt", allocator)});
    // std.log.info("Answer: {d}", .{try solve("input.txt", allocator)});
}

fn solve(comptime filename: []const u8, allocator: std.mem.Allocator) !usize {
    const file = @embedFile(filename);
    var lines = tokenizeScalar(u8, file, '\n');
    var output: usize = 0;
    while (lines.next()) |line| {
        var numbers = tokenizeAny(u8, line, ": ");
        const answer = try parseInt(usize, numbers.next().?, 10);
        var array = std.ArrayList(usize).init(allocator);
        defer array.deinit();

        while (numbers.next()) |number| {
            try array.append(try parseInt(usize, number, 10));
        }

        debug("array len: {d}", .{array.items.len});
        for (0..std.math.pow(usize, 2, array.items.len - 1)) |combo| {
            var sumation_array = std.ArrayList(usize).init(allocator);
            defer sumation_array.deinit();
            var last = array.items[0];
            var next_bit: usize = 0b1;
            for (0..array.items.len - 1) |mul_index| {
                const bit = @as(usize, 0b1) << @as(u6, @intCast(mul_index));
                debug("bit {b}, combo {b}, curr_num {d} last {d} bool {}", .{ bit, combo, array.items[mul_index + 1], last, (combo & bit) >> @as(u6, @intCast(mul_index)) == 1 });
                // if (combo & bit == 1 and next_bit == 1) {
                //     last *= array.items[mul_index + 1];
                if ((combo & bit) >> @as(u6, @intCast(mul_index)) == 1) {
                    last *= array.items[mul_index + 1];
                    // try sumation_array.append(last);
                    // last = array.items[mul_index + 1];
                } else {
                    try sumation_array.append(last);
                    last = array.items[mul_index + 1];
                }
                next_bit = bit;
            }
            try sumation_array.append(last);
            debug("sum array: {any}", .{sumation_array.items});
            var total_values: usize = 0;
            for (sumation_array.items) |item| {
                total_values += item;
            }
            debug("TOTAL: {d}", .{total_values});
            if (total_values == answer) {
                output += 1;
                break;
            }
        }

        debug("answer: {d}, items: {any}", .{ answer, array.items });
    }
    return output;
}