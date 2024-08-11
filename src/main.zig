const std = @import("std");
const rand = std.crypto.random;

fn timing(time: f128) void {
    var s: f128 = time / 1_000_000_000.0;
    var m = @divFloor(s, 60);
    const h = @divFloor(s, 3600);

    s = s - (60 * m);
    m = m - (60 * h);

    std.debug.print("{d} h {d} m {d:.9} s\n", .{ h, m, s });
}

fn calc(nRolls: usize) usize {
    var count: usize = 0;
    var max: usize = 0;
    var rolls: usize = 0;

    while (max < 177 and rolls < nRolls) {
        count = 0;

        for (0..231) |_| {
            if (rand.uintLessThan(usize, 4) == 0) {
                count += 1;
            }
        }

        if (count > max) {
            max = count;
        }

        rolls += 1;
        // std.debug.print("Roll: {d}\n", .{rolls});
    }

    return max;
}

pub fn main() !void {
    const nThreads = 1;
    const nRolls = 100_000;

    var count: usize = 0;
    var max: usize = 0;
    var rolls: usize = 0;

    var start: i128 = 0;
    var end: i128 = 0;

    switch (nThreads) {
        0 => std.debug.print("You need to use more than 0 threads.\n", .{}),
        1 => {
            std.debug.print("Running on 1 thread\n", .{});
            // std.debug.print("Start timing\n", .{});
            start = std.time.nanoTimestamp();

            while (max < 177 and rolls < nRolls) {
                count = 0;

                for (0..231) |_| {
                    if (rand.uintLessThan(usize, 4) == 0) {
                        count += 1;
                    }
                }

                if (count > max) {
                    max = count;
                }

                rolls += 1;
                // std.debug.print("Roll: {d}\n", .{rolls});
            }

            end = std.time.nanoTimestamp();
        },
        else => {
            std.debug.print("Running on {d} threads\n", .{nThreads});
            start = std.time.nanoTimestamp();
            max = calc(nRolls);
            end = std.time.nanoTimestamp();
        },
    }

    std.debug.print("End timing\n", .{});
    std.debug.print("Max: {d}\n", .{max});
    std.debug.print("Rolls: {d}\n", .{rolls});
    timing(@floatFromInt(end - start));
}
