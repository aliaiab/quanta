const std = @import("std");
const log = std.log.scoped(.velocity_system);
const components = @import("../components.zig");
const ComponentStore = @import("../ecs/ComponentStore.zig");
const CommandBuffer = @import("../ecs/CommandBuffer.zig");

const Position = components.Position;
const Velocity = components.Velocity;

pub fn run(_: *CommandBuffer, query: *ComponentStore.QueryIterator(.{ Position, Velocity }, .{})) void {
    const delta_time = 0.1 / 1000.0;

    while (query.nextBlock()) |block| {
        for (block.Position, block.Velocity) |*position, velocity| {
            position.x += velocity.x * delta_time;
            position.y += velocity.y * delta_time;
            position.z += velocity.z * delta_time;
        }
    }
}
