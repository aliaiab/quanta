const std = @import("std");
const components = @import("components.zig");
const ComponentStore = @import("ComponentStore.zig");
const Renderer3D = @import("../renderer.zig").Renderer3D;
const zalgebra = @import("zalgebra");

const Position = components.Position;
const RendererMesh = components.RendererMesh;

pub fn run(
    component_store: *ComponentStore,
    scene: Renderer3D.SceneHandle,
) void 
{
    var query = component_store.query(
        .{ Position, RendererMesh }, 
        .{}
    );

    while (query.nextBlock()) |block|
    {
        for (
            block.Position, 
            block.RendererMesh
        ) |position, mesh|
        {   
            const transform = zalgebra.Mat4.fromTranslate(.{ .data = .{ position.x, position.y, position.z } });

            Renderer3D.scenePushMesh(scene, mesh.mesh, mesh.material, transform);
        }
    }
}