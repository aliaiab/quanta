const std = @import("std");
const components = @import("../components.zig");
const ComponentStore = @import("../ecs/ComponentStore.zig");

const Velocity = components.Velocity;
const TerminalVelocity = components.TerminalVelocity;

pub fn run(
    component_store: *ComponentStore,
) void 
{
    var query = component_store.query(
        .{ Velocity, TerminalVelocity }, 
        .{}
    );

    while (query.nextBlock()) |block|
    {
        for (
            block.Velocity,
            block.TerminalVelocity,
        ) |*velocity, terminal_velocity|
        {
            velocity.x = @min(velocity.x, std.math.sign(velocity.x) * terminal_velocity.x);
            velocity.y = @min(velocity.y, std.math.sign(velocity.y) * terminal_velocity.y);
            velocity.z = @min(velocity.z, std.math.sign(velocity.z) * terminal_velocity.z);

            // std.debug.assert(std.math.sign(velocity.x) * velocity.x <= terminal_velocity.x);
        }
    }
}