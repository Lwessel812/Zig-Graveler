const std = @import("std");
const rng = std.rand.DefaultPrng;

fn timing(time: f128) void {
    var s: f128 = time / 1_000_000_000.0; // Convert to seconds
    var m = @divFloor(s, 60); // Convert to minutes
    const h = @divFloor(s, 3600); // Convert to hours

    s = s - (60 * m); // Remove converted minutes
    m = m - (60 * h); // Remove converted hours

    std.debug.print("{d} h {d} m {d:.9} s\n", .{ h, m, s });
}

fn calc(nRounds: usize) void {
    const seed: u64 = @intCast(std.time.microTimestamp());
    var rand = rng.init(seed);
    var randS = rand.random();

    var hits: usize = 0;
    var max: usize = 0; // Paralysis turns
    var rounds: usize = 0;

    while (max < 177 and rounds < nRounds) {
        hits = 0;

        // Roll 231 4 sided dice
        for (0..231) |_| {
            // We dont actually care which number its comparing to, we just need a 25% chance
            if (randS.uintLessThan(usize, 4) == 0) {
                hits += 1;
            }
        }

        // Update the maximum amount of paralysis hits
        if (hits > max) {
            max = hits;
        }

        rounds += 1;
    }

    std.debug.print("max: {d}\n", .{max});
    std.debug.print("rounds: {d}\n", .{rounds});
}

fn multi(nRounds: usize, nThreads: usize) !i128 {
    var threads: [1_024]std.Thread = undefined; // If you have more than 1k threads why are you running this program?

    const start: i128 = std.time.nanoTimestamp();

    for (0..nThreads) |i| {
        threads[i] = try std.Thread.spawn(.{}, calc, .{nRounds}); // Loop to spawn threads
    }

    for (0..nThreads) |i| {
        threads[i].join(); // Cleanup threads when they are done
    }

    const end: i128 = std.time.nanoTimestamp();

    return end - start;
}

pub fn main() !void {
    // const nThreads: usize = 1;
    // var nRounds: usize = 1_000;

    const nThreads: usize = 6;
    const nRounds: usize = 1_000;

    const nTrials: usize = 10;
    var times = [_]i128{0} ** nTrials;

    var avg: i128 = 0;

    std.debug.print("Running {d} trials with {d} rounds on {d} threads\n\n", .{ nTrials, nRounds, nThreads });

    for (0..nTrials) |i| {
        times[i] = try multi(@divTrunc(nRounds, nThreads), nThreads);
    }

    var best: i128 = times[0];

    for (1..times.len) |i| {
        if (times[i] < best) {
            best = times[i];
        }
    }

    std.debug.print("Best runtime ", .{});
    timing(@floatFromInt(best));

    for (0..times.len) |i| {
        avg += times[i];
    }

    avg = @divExact(avg, @as(i128, nTrials));

    std.debug.print("Average runtime ", .{});
    timing(@floatFromInt(avg));
}
