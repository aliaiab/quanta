const std = @import("std");
const components = @import("components.zig");
const ComponentStore = @import("ComponentStore.zig");

const Position = components.Position;
const Rotation = components.Rotation;
const UniformScale = components.UniformScale;
const NonUniformScale = components.NonUniformScale;

pub fn run(
    component_store: *ComponentStore,
) void 
{
    var query = component_store.query(
        .{ Position, Rotation, UniformScale }, 
        .{}
    );

    while (query.nextBlock()) |block|
    {
        for (block.entities) |entity|
        {
            std.log.info("{}", .{ entity });
        }
    }
}