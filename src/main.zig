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

fn calc(nRolls: usize) void {
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

    std.debug.print("Max: {d}\n", .{max});
    std.debug.print("Rolls: {d}\n", .{rolls});
}

pub fn main() !void {
    const nThreads: usize = 16;
    var nRolls: usize = 1_000_000_000;

    var count: usize = 0;
    var max: usize = 0;
    var rolls: usize = 0;

    switch (nThreads) {
        0 => std.debug.print("You need to use more than 0 threads.\n", .{}),
        1 => {
            std.debug.print("Running on 1 thread\n", .{});

            const start: i128 = std.time.nanoTimestamp();

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

            const end: i128 = std.time.nanoTimestamp();

            std.debug.print("Max: {d}\n", .{max});
            std.debug.print("Rolls: {d}\n", .{rolls});

            timing(@floatFromInt(end - start));
        },
        else => {
            std.debug.print("Running on {d} threads\n", .{nThreads});
            nRolls = @divTrunc(nRolls, nThreads);

            var threads: [nThreads]std.Thread = undefined;

            const start: i128 = std.time.nanoTimestamp();

            for (0..nThreads) |i| {
                threads[i] = try std.Thread.spawn(.{}, calc, .{nRolls});
            }

            for (threads) |thread| {
                thread.join();
            }

            const end: i128 = std.time.nanoTimestamp();

            timing(@floatFromInt(end - start));
        },
    }
}
