const std = @import("std");
const log = std.log.scoped(.app_runner);
const app = @import("app.zig");

pub fn main() !void 
{
    log.info("Starting app...", .{});

    var app_lib = try std.DynLib.open("lib/libexample_app.so");
    defer app_lib.close();

    var init = app_lib.lookup(*const fn () callconv(.C) void, "init") orelse return error.FunctionNotFound;
    var deinit = app_lib.lookup(*const fn () callconv(.C) void, "deinit") orelse return error.FunctionNotFound;
    var update = app_lib.lookup(*const fn (ctx: *const app.UpdateContext) callconv(.C) app.UpdateResult, "update") orelse return error.FunctionNotFound;

    init();
    defer deinit();

    var update_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer update_arena.deinit();

    var update_fixed_buffer_data: [16 * 1024]u8 = undefined;
    var update_fixed_buffer = std.heap.FixedBufferAllocator.init(&update_fixed_buffer_data);

    var update_ctx = app.UpdateContext
    {
        .arena_allocator = update_arena.allocator(),
        .fixed_buffer_allocator = update_fixed_buffer.allocator(),
        .time_start = 0,
        .timestep = 0,
    };

    while (true)
    {
        switch (update(&update_ctx))
        {
            .pass => continue,
            .exit => break,
        }
    }
}