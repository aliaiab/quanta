//! Reimplementation of Renderer3D using the quanta.rendering rendering graph api

pub const Scene = struct {};

pub fn buildGraph(
    graph: *rendering.graph.Builder,
    scene: Scene,
) void {
    _ = graph;
    _ = scene;
}

const rendering = @import("../rendering.zig");
