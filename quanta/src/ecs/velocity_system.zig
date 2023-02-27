const std = @import("std");
const log = std.log.scoped(.velocity_system);
const components = @import("components.zig");
const ComponentStore = @import("ComponentStore.zig");

const Position = components.Position;
const Velocity = components.Velocity;

pub fn run(
    component_store: *ComponentStore,
    delta_time: f32,
) void 
{
    var query = component_store.query(
        .{ Position, Velocity }, 
        .{}
    );

    while (query.nextBlock()) |block|
    {
        for (
            block.Position, 
            block.Velocity
        ) |*position, velocity|
        {
            position.*.x += velocity.x * delta_time;
            position.*.y += velocity.y * delta_time;
            position.*.z += velocity.z * delta_time;
            
            // log.info("{} = {}, {}", .{ entity, position, velocity });
        }
    }
}