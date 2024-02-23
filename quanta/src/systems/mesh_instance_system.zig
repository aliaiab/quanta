const std = @import("std");
const components = @import("../components.zig");
const ComponentStore = @import("../ecs/ComponentStore.zig");
const renderer_3d_graph = @import("../renderer_3d.zig").renderer_3d_graph;
const zalgebra = @import("zalgebra");

const Position = components.Position;
const RendererMesh = components.RendererMesh;
const Orientation = components.Orientation;
const NonUniformScale = components.NonUniformScale;

const EntityForEachContext = struct {
    allocator: std.mem.Allocator,
    scene: *renderer_3d_graph.Scene,
};

fn entityForeach(
    context: EntityForEachContext,
    position: Position,
    orientation_optional: ?Orientation,
    scale_optional: ?NonUniformScale,
    mesh_instance: components.RendererMeshInstance,
) void {
    const orientation: Orientation = orientation_optional orelse .{ .x = 0, .y = 0, .z = 0 };
    const scale: NonUniformScale = scale_optional orelse .{ .x = 1, .y = 1, .z = 1 };

    const transform_translate = zalgebra.Mat4.fromTranslate(.{ .data = .{ position.x, position.y, position.z } });
    const transform_rotate = zalgebra.Mat4.fromEulerAngles(.{ .data = .{ orientation.x, orientation.y, orientation.z } });
    const transform_scale = zalgebra.Mat4.fromScale(.{ .data = .{ scale.x, scale.y, scale.z } });

    const transform = transform_translate.mul(transform_rotate.mul(transform_scale));

    context.scene.addInstance(
        context.allocator,
        mesh_instance.mesh,
        transform,
        mesh_instance.material,
    ) catch unreachable;
}

pub fn run(
    component_store: *ComponentStore,
    scene: *renderer_3d_graph.Scene,
    allocator: std.mem.Allocator,
) void {
    const use_foreach = false;

    if (use_foreach) {
        // component_store.foreach(EntityForEachContext{
        //     .allocator = allocator,
        //     .scene = scene,
        // }, entityForeach);
        // return;
    }

    const without = ComponentStore.filterWithout;

    {
        var query = component_store.query(
            .{
                Position,
                components.RendererMeshInstance,
            },
            .{ without(Orientation), without(NonUniformScale) },
        );

        while (query.nextBlock()) |block| {
            for (block.Position, block.RendererMeshInstance) |position, instance| {
                const transform = zalgebra.Mat4.fromTranslate(.{ .data = .{ position.x, position.y, position.z } });

                scene.addInstance(
                    allocator,
                    instance.mesh,
                    transform,
                    instance.material,
                ) catch unreachable;
            }
        }
    }

    {
        var query = component_store.query(
            .{
                Position,
                Orientation,
                RendererMesh,
                components.RendererMeshInstance,
            },
            .{without(NonUniformScale)},
        );

        while (query.nextBlock()) |block| {
            for (block.Position, block.Orientation, block.RendererMeshInstance) |position, rotation, instance| {
                const transform_translate = zalgebra.Mat4.fromTranslate(.{ .data = .{ position.x, position.y, position.z } });
                const transform_rotate = zalgebra.Mat4.fromEulerAngles(.{ .data = .{ rotation.x, rotation.y, rotation.z } });
                const transform = transform_translate.mul(transform_rotate);

                scene.addInstance(
                    allocator,
                    instance.mesh,
                    transform,
                    instance.material,
                ) catch unreachable;
            }
        }
    }

    {
        var query = component_store.query(
            .{
                Position,
                Orientation,
                NonUniformScale,
                components.RendererMeshInstance,
            },
            .{},
        );

        while (query.nextBlock()) |block| {
            for (
                block.Position,
                block.Orientation,
                block.NonUniformScale,
                block.RendererMeshInstance,
            ) |
                position,
                rotation,
                scale,
                mesh_instance,
            | {
                const transform_translate = zalgebra.Mat4.fromTranslate(.{ .data = .{ position.x, position.y, position.z } });
                const transform_rotate = zalgebra.Mat4.fromEulerAngles(.{ .data = .{ rotation.x, rotation.y, rotation.z } });
                const transform_scale = zalgebra.Mat4.fromScale(.{ .data = .{ scale.x, scale.y, scale.z } });
                const transform = transform_translate.mul(transform_rotate.mul(transform_scale));

                scene.addInstance(
                    allocator,
                    mesh_instance.mesh,
                    transform,
                    mesh_instance.material,
                ) catch unreachable;
            }
        }
    }
}
