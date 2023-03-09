const std = @import("std");
const components = @import("../components.zig");
const ComponentStore = @import("../ecs/ComponentStore.zig");
const Renderer3D = @import("../renderer.zig").Renderer3D;
const zalgebra = @import("zalgebra");

const Position = components.Position;
const PointLight = components.PointLight;
const Visibility = components.Visibility;

pub fn run(
    component_store: *ComponentStore,
    scene: Renderer3D.SceneHandle,
) void 
{
    const without = ComponentStore.filterWithout;
    
    var query = component_store.query(
        .{ Position, PointLight, }, 
        .{ without(Visibility), }
    );

    while (query.nextBlock()) |block|
    {
        for (
            block.Position, 
            block.PointLight
        ) |position, point_light|
        {   
            Renderer3D.scenePushPointLight(scene, .{
                .position = .{ position.x, position.y, position.z },
                .intensity = point_light.intensity,
                .diffuse = packUnorm4x8(.{ point_light.diffuse[0], point_light.diffuse[1], point_light.diffuse[2], 1 }),
            });
        }
    }

    var visibility_query = component_store.query(
        .{ Position, PointLight, Visibility }, 
        .{}
    );

    while (visibility_query.nextBlock()) |block|
    {
        for (
            block.Position, 
            block.PointLight,
            block.Visibility,
        ) |position, point_light, visibility|
        {   
            if (!visibility.is_visible) continue;

            Renderer3D.scenePushPointLight(scene, .{
                .position = .{ position.x, position.y, position.z },
                .intensity = point_light.intensity,
                .diffuse = packUnorm4x8(.{ point_light.diffuse[0], point_light.diffuse[1], point_light.diffuse[2], 1 }),
            });
        }
    }
}

fn packUnorm4x8(v: [4]f32) u32
{
    const Unorm4x8 = packed struct(u32)
    {
        x: u8,
        y: u8,
        z: u8,
        w: u8,
    };

    const x = @floatToInt(u8, v[0] * @intToFloat(f32, std.math.maxInt(u8)));
    const y = @floatToInt(u8, v[1] * @intToFloat(f32, std.math.maxInt(u8)));
    const z = @floatToInt(u8, v[2] * @intToFloat(f32, std.math.maxInt(u8)));
    const w = @floatToInt(u8, v[3] * @intToFloat(f32, std.math.maxInt(u8)));

    return @bitCast(u32, Unorm4x8 {
        .x = x,
        .y = y,
        .z = z, 
        .w = w,
    });
}