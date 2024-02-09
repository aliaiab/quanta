//! Reimplementation of Renderer3D using the quanta.rendering rendering graph api

pub const Scene = struct {};

const Image = rendering.graph.Image;

pub fn buildGraph(
    graph: *rendering.graph.Builder,
    scene: Scene,
    output_target: Image,
) struct {
    color_target: Image,
} {
    _ = scene;

    const render_width = 1920;
    const render_height = 1080;

    // const radiance_target = graph.createImage(
    //     @src(),
    //     .r16g16b16a16_sfloat,
    //     render_width,
    //     render_height,
    //     1,
    // );

    const depth_target = graph.createImage(
        @src(),
        .d32_sfloat,
        render_width,
        render_height,
        1,
    );

    const vertex_buffer = graph.createBuffer(@src(), 1024 * @sizeOf(legacy.Vertex));
    const index_buffer = graph.createBuffer(@src(), 1024 * @sizeOf(u32));

    const color_pass = block: {
        graph.beginRasterPass(
            @src(),
            &.{.{
                .image = output_target,
                .clear = .{ .color = .{ 0.2, 0.2, 0.2, 1 } },
            }},
            0,
            0,
            graph.imageGetWidth(output_target),
            graph.imageGetHeight(output_target),
        );

        graph.setViewport(
            0,
            @as(f32, @floatFromInt(render_height)),
            @as(f32, @floatFromInt(render_width)),
            -@as(f32, @floatFromInt(render_height)),
            0,
            1,
        );

        graph.setScissor(
            0,
            0,
            render_width,
            render_height,
        );

        const color_pipeline = graph.createRasterPipeline(
            @src(),
            .{
                .code = @alignCast(@embedFile("tri.vert.spv")),
            },
            .{
                .code = @alignCast(@embedFile("tri.frag.spv")),
            },
            .{
                .attachment_formats = &.{
                    graph.imageGetFormat(output_target),
                },
            },
            0,
        );

        _ = color_pipeline;

        break :block graph.endRasterPass(.{
            .color_target = output_target,
        });
    };

    _ = index_buffer;
    _ = vertex_buffer;
    _ = depth_target;

    return .{ .color_target = color_pass.color_target };
}

const rendering = @import("../rendering.zig");
const legacy = @import("Renderer3D.zig");
