const std = @import("std");
const log = std.log.scoped(.app_runner);
const app = @import("app.zig");

pub fn main() !void 
{
    log.info("Starting app...", .{});

    const app_lib_file_path = "lib/libexample_app.so";

    var app_lib = try std.DynLib.open(app_lib_file_path);
    defer app_lib.close();

    var init = app_lib.lookup(*const fn () callconv(.C) void, "init") orelse return error.FunctionNotFound;
    var deinit = app_lib.lookup(*const fn () callconv(.C) void, "deinit") orelse return error.FunctionNotFound;
    var update = app_lib.lookup(*const fn (ctx: *const app.UpdateContext) callconv(.C) app.UpdateResult, "update") orelse return error.FunctionNotFound;

    init();
    defer deinit();

    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    defer std.debug.assert(!gpa.deinit());

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

    var file = try std.fs.cwd().openFile(app_lib_file_path, .{}); 
    defer file.close();

    const file_notify_fd = try std.os.inotify_init1(std.os.linux.IN.NONBLOCK | std.os.linux.IN.CLOEXEC);
    defer std.os.close(file_notify_fd);

    _ = try std.os.inotify_add_watch(
        file_notify_fd, 
        std.fs.path.dirname(app_lib_file_path).?, 
        std.os.linux.IN.CLOSE_WRITE | std.os.linux.IN.NONBLOCK | std.os.linux.IN.DELETE | std.os.linux.IN.EXCL_UNLINK | std.os.linux.IN.CREATE
    );

    while (true)
    {
        block: {
            var notify_event_buffer: [1024]u8 = undefined;

            var fds: [1]std.os.pollfd = .{
                .{
                    .fd = file_notify_fd,
                    .events = 0,
                    .revents = undefined,
                }
            };

            _ = try std.os.poll(&fds, 1);

            std.log.info("polled!! = {}", .{ fds[0] });

            const size = std.os.read(file_notify_fd, &notify_event_buffer) catch |e|
            {
                switch (e)
                {
                    error.WouldBlock => break: block,
                    else => return e,
                }
            };

            std.log.info("event_size = {}", .{ size });

            std.log.info("MODIFICATION", .{});

            app_lib.close();
            app_lib = try std.DynLib.open(app_lib_file_path);

            init = app_lib.lookup(*const fn () callconv(.C) void, "init") orelse return error.FunctionNotFound;
            deinit = app_lib.lookup(*const fn () callconv(.C) void, "deinit") orelse return error.FunctionNotFound;
            update = app_lib.lookup(*const fn (ctx: *const app.UpdateContext) callconv(.C) app.UpdateResult, "update") orelse return error.FunctionNotFound;
        }

        switch (update(&update_ctx))
        {
            .pass => continue,
            .exit => break,
        }
    }
}