const std = @import("std");
const components = @import("../components.zig");
const ComponentStore = @import("../ecs/ComponentStore.zig");
const Renderer3D = @import("../renderer_3d.zig").Renderer3D;
const zalgebra = @import("zalgebra");

const Position = components.Position;
const RendererMesh = components.RendererMesh;
const Orientation = components.Orientation;
const NonUniformScale = components.NonUniformScale;

pub fn run(
    component_store: *ComponentStore,
    scene: Renderer3D.SceneHandle,
) void {
    const without = ComponentStore.filterWithout;

    {
        var query = component_store.query(
            .{
                Position,
                RendererMesh,
            },
            .{ without(Orientation), without(NonUniformScale) },
        );

        while (query.nextBlock()) |block| {
            for (block.Position, block.RendererMesh) |position, mesh| {
                const transform = zalgebra.Mat4.fromTranslate(.{ .data = .{ position.x, position.y, position.z } });

                Renderer3D.scenePushMesh(scene, mesh.mesh, mesh.material, transform);
            }
        }
    }

    {
        var query = component_store.query(
            .{
                Position,
                Orientation,
                RendererMesh,
            },
            .{without(NonUniformScale)},
        );

        while (query.nextBlock()) |block| {
            for (block.Position, block.Orientation, block.RendererMesh) |position, rotation, mesh| {
                const transform_translate = zalgebra.Mat4.fromTranslate(.{ .data = .{ position.x, position.y, position.z } });
                const transform_rotate = zalgebra.Mat4.fromEulerAngles(.{ .data = .{ rotation.x, rotation.y, rotation.z } });
                const transform = transform_translate.mul(transform_rotate);

                Renderer3D.scenePushMesh(scene, mesh.mesh, mesh.material, transform);
            }
        }
    }

    {
        var query = component_store.query(
            .{
                Position,
                Orientation,
                NonUniformScale,
                RendererMesh,
            },
            .{},
        );

        while (query.nextBlock()) |block| {
            for (block.Position, block.Orientation, block.NonUniformScale, block.RendererMesh) |position, rotation, scale, mesh| {
                const transform_translate = zalgebra.Mat4.fromTranslate(.{ .data = .{ position.x, position.y, position.z } });
                const transform_rotate = zalgebra.Mat4.fromEulerAngles(.{ .data = .{ rotation.x, rotation.y, rotation.z } });
                const transform_scale = zalgebra.Mat4.fromScale(.{ .data = .{ scale.x, scale.y, scale.z } });
                const transform = transform_translate.mul(transform_rotate.mul(transform_scale));

                Renderer3D.scenePushMesh(scene, mesh.mesh, mesh.material, transform);
            }
        }
    }
}
