const std = @import("std");
const root = @import("root");

pub const AppCompileStep = @import("AppCompileStep.zig");

pub const UpdateContext = struct 
{
    ///An arena allocator which is cleared every update
    arena_allocator: std.mem.Allocator,
    ///A fixed buffer allocator which is cleared every update
    fixed_buffer_allocator: std.mem.Allocator,
    ///The time in seconds that the app was run
    time_start: u64,
    ///The milliseconds in seconds between successive updates
    timestep: u64,
};

pub const UpdateResult = enum(u8) 
{
    ///Indicates to the app runner the app should exit
    exit,
    ///Indicates to the app runner the app should continue to next update
    pass,
};

pub const InitFn = fn () callconv(.C) void;
pub const DeinitFn = fn () callconv(.C) void;
pub const UpdateFn = fn (ctx: *const UpdateContext) callconv(.C) UpdateResult;

pub const DynamicAppContext = struct 
{
    init: *const InitFn,
    deinit: *const DeinitFn,
    update: *const UpdateFn,
    update_context: UpdateContext,
};

comptime {
    if (
        @hasDecl(root, "init") and 
        @hasDecl(root, "deinit") and 
        @hasDecl(root, "update")
    )
    {
        const S = struct 
        {
            pub fn init() callconv(.C) void
            {
                root.init();
            }  

            pub fn deinit() callconv(.C) void 
            {
                root.deinit();
            }

            pub fn update(ctx: *const UpdateContext) callconv(.C) UpdateResult
            {
                return root.update(ctx.*);
            }
        };

        @export(S.init, .{ .name = "init" });
        @export(S.deinit, .{ .name = "deinit" });
        @export(S.update, .{ .name = "update" });
    }
}