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

// fn calc(nRolls: usize) void {
fn calc(nRolls: usize) void {
    // For some reason passing the existing randomization from main() was way way way slow, like going from .5s -> 20 or 40
    const seed: u64 = @intCast(std.time.microTimestamp());
    var rand = rng.init(seed);
    var randS = rand.random();

    var count: usize = 0;
    var max: usize = 0;
    var rolls: usize = 0;

    while (max < 177 and rolls < nRolls) {
        count = 0;

        // Roll 231 4 sided dice
        for (0..231) |_| {
            // We dont actually care which number its comparing to, we just need a 25% chance
            // if (rand.uintLessThan(usize, 4) == 0) {
            if (randS.uintLessThan(usize, 4) == 0) {
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

// fn smartCalc(nRolls: usize) void {
fn smartCalc(nRolls: usize) void {
    // For some reason passing the existing randomization from main() was way way way slow, like going from .5s -> 20 or 40
    const seed: u64 = @intCast(std.time.microTimestamp());
    var rand = rng.init(seed);
    var randS = rand.random();

    var count: usize = 0;
    var max: usize = 0;
    var rolls: usize = 0;

    while (max < 177 and rolls < nRolls) {
        count = 0;

        // Roll 231 4 sided dice
        for (0..231) |_| {
            // We dont actually care which number its comparing to, we just need a 25% chance
            // if (rand.uintLessThan(usize, 4) == 0) {
            if (randS.uintLessThan(usize, 4) == 0) {
                count += 1;
            } else {
                // We can also just stop checking when we miss a check, this save so so so so much time its dumb
                break;
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
    const seed: u64 = @intCast(std.time.microTimestamp());
    var rand = rng.init(seed);
    var randS = rand.random();

    // const nThreads: usize = 1;
    const nThreads: usize = 16;
    var nRolls: usize = 1_000_000_000;

    var count: usize = 0;
    var max: usize = 0;
    var rolls: usize = 0;

    const smart: bool = true;

    switch (nThreads) {
        0 => std.debug.print("You need to use more than 0 threads goober\n", .{}), // Dont be a goober
        1 => {
            if (smart) {
                // I dont call calc() here because it ended up adding like 1% overhead to the time, and I dont really want the threads timing themselves anyway
                std.debug.print("Running {d} rolls smartly on 1 thread\n", .{nRolls});

                const start: i128 = std.time.nanoTimestamp(); // Nanoseconds, because why not
                // For some context in --release=fast on my laptop
                // settings the start and end values takes between 50-200 ns
                // subtraction takes between 20-80 ns
                // std.debug.print takes between 16k-21k ns

                while (max < 177 and rolls < nRolls) {
                    count = 0;

                    // Roll 231 4 sided dice
                    for (0..231) |_| {
                        // We dont actually care which number its comparing to, we just need a 25% chance
                        // if (rand.uintLessThan(usize, 4) == 0) {
                        if (randS.uintLessThan(usize, 4) == 0) {
                            count += 1;
                        } else {
                            // We can also just stop checking when we miss a check, this save so so so so much time its dumb
                            break;
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
            } else {
                // I dont call calc() here because it ended up adding like 1% overhead to the time, and I dont really want the threads timing themselves anyway
                std.debug.print("Running {d} rolls on 1 thread\n", .{nRolls});

                const start: i128 = std.time.nanoTimestamp(); // Nanoseconds, because why not
                // For some context in --release=fast on my laptop
                // settings the start and end values takes between 50-200 ns
                // subtraction takes between 20-80 ns
                // std.debug.print takes between 16k-21k ns

                while (max < 177 and rolls < nRolls) {
                    count = 0;

                    // Roll 231 4 sided dice
                    for (0..231) |_| {
                        // We dont actually care which number its comparing to, we just need a 25% chance
                        // if (rand.uintLessThan(usize, 4) == 0) {
                        if (randS.uintLessThan(usize, 4) == 0) {
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
            }
        },
        else => {
            if (smart) {
                std.debug.print("Running {d} rolls smartly on {d} threads\n", .{ nRolls, nThreads });
            } else {
                std.debug.print("Running {d} rolls on {d} threads\n", .{ nRolls, nThreads });
            }

            nRolls = @divTrunc(nRolls, nThreads); // Truncate just in case nRolls is small enough this results in a float

            var threads: [1_024]std.Thread = undefined; // If you have more than 1k threads why are you running this program?

            const start: i128 = std.time.nanoTimestamp();

            if (smart) {
                for (0..nThreads) |i| {
                    threads[i] = try std.Thread.spawn(.{}, smartCalc, .{nRolls}); // Loop to spawn threads
                }
            } else {
                for (0..nThreads) |i| {
                    threads[i] = try std.Thread.spawn(.{}, calc, .{nRolls}); // Loop to spawn threads
                }
            }

            for (0..nThreads) |i| {
                threads[i].join(); // Cleanup threads when they are done
            }

            const end: i128 = std.time.nanoTimestamp();

            timing(@floatFromInt(end - start));
        },
    }
}
