const std = @import("std");
const log = std.log.scoped(.force_system);
const components = @import("components.zig");
const ComponentStore = @import("ComponentStore.zig");

const Velocity = components.Velocity;
const Mass = components.Mass;
const Force = components.Force;

pub fn run(
    component_store: *ComponentStore,
    delta_time: f32,
) void 
{
    var query = component_store.query(
        .{ Velocity, Mass, Force }, 
        .{}
    );

    while (query.nextBlock()) |block|
    {
        for (
            block.Velocity, 
            block.Mass, 
            block.Force,
        ) |*velocity, mass, force|
        {
            const acceleration = components.Acceleration
            {
                .x = mass.value * force.x,
                .y = mass.value * force.y,
                .z = mass.value * force.z,
            };

            velocity.*.x += acceleration.x * delta_time;
            velocity.*.y += acceleration.y * delta_time;
            velocity.*.z += acceleration.z * delta_time;

            log.debug("{}", .{ velocity.* });            
        }
    }
}