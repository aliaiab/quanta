const std = @import("std");
const root = @import("root");

pub const UpdateContext = struct 
{
    ///An arena allocator which is cleared every update
    arena_allocator: std.mem.Allocator,
    ///A fixed buffer allocator which is cleared every update
    fixed_buffer_allocator: std.mem.Allocator,
    ///The time between successive updates
    timestep: f32,
};

pub fn run() !void 
{

}