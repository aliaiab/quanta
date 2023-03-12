const std = @import("std");
const log = std.log.scoped(.example_app);
const quanta = @import("quanta");
const app = quanta.app;

comptime {
    _ = app;
}

pub fn init() void 
{
    // _ = std.os.write(std.os.STDERR_FILENO, "init!!\n") catch unreachable;
    _ = std.io.getStdErr().write("init!!\n") catch unreachable;
    // log.info("init!!", .{});
}

pub fn deinit() void 
{
    _ = std.io.getStdErr().write("deinit!!\n") catch unreachable;
}

pub fn update(ctx: app.UpdateContext) app.UpdateResult 
{
    _ = std.io.getStdErr().write("update!! FAFAFAF\n") catch unreachable;
    _ = ctx;
    // _ = std.io.getStdErr().writer().print("timestep: {}", .{ ctx.timestep }) catch unreachable;

    return .pass;
}