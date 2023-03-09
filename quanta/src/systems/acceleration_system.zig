const std = @import("std");
const log = std.log.scoped(.acceleration_system);
const components = @import("../components.zig");
const ComponentStore = @import("../ecs/ComponentStore.zig");

const Acceleration = components.Acceleration;
const Velocity = components.Velocity;

pub fn run(
    component_store: *ComponentStore,
    delta_time: f32,
) void 
{
    var query = component_store.query(
        .{ Velocity, Acceleration }, 
        .{}
    );

    while (query.nextBlock()) |block|
    {
        for (
            block.Velocity, 
            block.Acceleration
        ) |*velocity, acceleration|
        {
            velocity.*.x += acceleration.x * delta_time;
            velocity.*.y += acceleration.y * delta_time;
            velocity.*.z += acceleration.z * delta_time;            
        }
    }
}