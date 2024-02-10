//! Reimplementation of Renderer3D using the quanta.rendering rendering graph api

pub fn buildGraph(
    graph: *rendering.graph.Builder,
    scene: Scene,
    output_target: *Image,
) void {
    const render_width = 1920;
    const render_height = 1080;

    const radiance_target = graph.createImage(
        @src(),
        .r16g16b16a16_sfloat,
        render_width,
        render_height,
        1,
    );
    _ = radiance_target;

    const depth_target = graph.createImage(
        @src(),
        .d32_sfloat,
        render_width,
        render_height,
        1,
    );

    const max_instance_count = 1024;

    const SceneUniforms = extern struct {
        view_projection: [4][4]f32 align(1),
        view_position: [3]f32 align(1),
        point_light_count: u32 align(1),
        ambient_light: AmbientLight align(1),
        primary_directional_light_index: u32 align(1),
    };

    const target_width = graph.imageGetWidth(output_target.*);
    const target_height = graph.imageGetHeight(output_target.*);

    const aspect_ratio: f32 = @as(f32, @floatFromInt(target_width)) / @as(f32, @floatFromInt(target_height));
    const near_plane: f32 = 0.01;
    const fov: f32 = scene.camera.fov;

    const projection = perspectiveProjection(fov, aspect_ratio, near_plane);
    const view = zalgebra.lookAt(
        .{ .data = scene.camera.translation },
        .{ .data = scene.camera.target },
        .{ .data = .{ 0, 1, 0 } },
    );
    const view_projection = projection.mul(view);

    const scene_data_pass = block: {
        graph.beginTransferPass(@src());
        defer graph.endTransferPass();

        const test_vertex_positions = [_]VertexPosition{
            quantisePosition(.{ 0, 0, 0 }),
            quantisePosition(.{ 0.5, 1, 0 }),
            quantisePosition(.{ 1, 0, 0 }),
        };

        const test_vertices = [_]Vertex{
            .{
                .uv = quantiseUV(.{ 0, 0 }),
                .normal = quantiseNormal(.{ 0, 0, 1 }),
                .color = quantiseColor(.{ 1, 0, 0, 1 }),
            },
            .{
                .uv = quantiseUV(.{ 0, 0 }),
                .normal = quantiseNormal(.{ 0, 0, 1 }),
                .color = quantiseColor(.{ 1, 0, 0, 1 }),
            },
            .{
                .uv = quantiseUV(.{ 0, 0 }),
                .normal = quantiseNormal(.{ 0, 0, 1 }),
                .color = quantiseColor(.{ 1, 0, 0, 1 }),
            },
        };

        const test_indices = [_]u32{
            0, 1, 2,
        };

        const test_transform_actual = zalgebra.Mat4.identity();

        const test_transform: [4][3]f32 = .{
            test_transform_actual.data[0][0..3].*,
            test_transform_actual.data[1][0..3].*,
            test_transform_actual.data[2][0..3].*,
            test_transform_actual.data[3][0..3].*,
        };

        var vertex_positions_buffer = graph.createBuffer(@src(), 10_024 * @sizeOf(legacy.VertexPosition));

        graph.updateBuffer(
            &vertex_positions_buffer,
            0,
            VertexPosition,
            graph.scratchDupe(VertexPosition, &test_vertex_positions),
        );

        var verticies_buffer = graph.createBuffer(@src(), 10_024 * @sizeOf(legacy.Vertex));

        graph.updateBuffer(
            &verticies_buffer,
            0,
            Vertex,
            graph.scratchDupe(Vertex, &test_vertices),
        );

        var index_buffer = graph.createBuffer(@src(), 10_024 * @sizeOf(u32));

        graph.updateBuffer(
            &index_buffer,
            0,
            u32,
            graph.scratchDupe(u32, &test_indices),
        );

        var scene_uniforms_buffer = graph.createBuffer(@src(), max_instance_count * @sizeOf(SceneUniforms));

        graph.updateBufferValue(&scene_uniforms_buffer, 0, SceneUniforms, .{
            .view_position = scene.camera.translation,
            .view_projection = view_projection.data,
            .ambient_light = scene.ambient_light,
            .point_light_count = @intCast(scene.point_lights.len),
            .primary_directional_light_index = 0,
        });

        var transform_buffer = graph.createBuffer(@src(), max_instance_count * @sizeOf([4][3]f32));

        graph.updateBuffer(&transform_buffer, 0, [4][3]f32, graph.scratchDupe([4][3]f32, &.{test_transform}));

        var material_indices = graph.createBuffer(@src(), max_instance_count * @sizeOf(u32));

        graph.updateBuffer(&material_indices, 0, u32, graph.scratchDupe(u32, &.{0}));

        var materials_buffer = graph.createBuffer(@src(), max_instance_count * @sizeOf(Material));

        graph.updateBuffer(&materials_buffer, 0, Material, graph.scratchDupe(Material, &.{
            .{
                .albedo_texture_index = 0,
                .albedo = quantiseColor(.{ 1, 1, 1, 1 }),
                .metalness_texture_index = 0,
                .metalness = 0,
                .roughness_texture_index = 0,
                .roughness = 1,
            },
        }));

        var point_light_buffer = graph.createBuffer(@src(), 1024 * @sizeOf(u32));

        graph.updateBuffer(&point_light_buffer, 0, PointLight, scene.point_lights);

        break :block .{
            .vertex_positions_buffer = vertex_positions_buffer,
            .verticies_buffer = verticies_buffer,
            .index_buffer = index_buffer,
            .scene_uniforms_buffer = scene_uniforms_buffer,
            .transform_buffer = transform_buffer,
            .material_indices = material_indices,
            .materials_buffer = materials_buffer,
            .point_light_buffer = point_light_buffer,
        };
    };

    const color_pass = block: {
        graph.beginRasterPass(
            @src(),
            &.{.{
                .image = output_target,
                .clear = .{ 0.2, 0.2, 0.2, 1 },
            }},
            .entirety,
        );
        defer graph.endRasterPass();

        graph.setViewport(
            0,
            @as(f32, @floatFromInt(graph.imageGetHeight(output_target.*))),
            @as(f32, @floatFromInt(graph.imageGetWidth(output_target.*))),
            -@as(f32, @floatFromInt(graph.imageGetHeight(output_target.*))),
            0,
            1,
        );

        graph.setScissor(
            0,
            0,
            graph.imageGetWidth(output_target.*),
            graph.imageGetHeight(output_target.*),
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
                    graph.imageGetFormat(output_target.*),
                },
            },
            0,
        );

        graph.setRasterPipelineResourceBuffer(color_pipeline, 0, 0, scene_data_pass.vertex_positions_buffer);
        graph.setRasterPipelineResourceBuffer(color_pipeline, 1, 0, scene_data_pass.verticies_buffer);
        graph.setRasterPipelineResourceBuffer(color_pipeline, 2, 0, scene_data_pass.transform_buffer);
        graph.setRasterPipelineResourceBuffer(color_pipeline, 3, 0, scene_data_pass.material_indices);
        graph.setRasterPipelineResourceBuffer(color_pipeline, 10, 0, scene_data_pass.scene_uniforms_buffer);
        graph.setRasterPipelineResourceBuffer(color_pipeline, 5, 0, scene_data_pass.materials_buffer);
        graph.setRasterPipelineResourceBuffer(color_pipeline, 7, 0, scene_data_pass.point_light_buffer);

        graph.setRasterPipeline(color_pipeline);

        graph.setIndexBuffer(scene_data_pass.index_buffer, .u32);

        graph.drawIndexed(
            3,
            1,
            0,
            0,
            0,
        );

        break :block .{
            .color_target = output_target,
        };
    };

    const resolve_to_output = block: {
        graph.beginTransferPass(
            @src(),
        );
        defer graph.endRasterPass();

        const pipeline = graph.createComputePipeline(@src(), .{
            .code = @alignCast(@embedFile("color_resolve.comp.spv")),
        }, 0);

        graph.setComputePipeline(pipeline);

        break :block .{
            .output_target = output_target,
        };
    };

    _ = depth_target;
    _ = color_pass;
    _ = resolve_to_output;
}

pub const Scene = struct {
    camera: legacy.Camera,
    ambient_light: AmbientLight,
    point_lights: []PointLight,
    environment_map: struct {} = .{},
};

pub const AmbientLight = extern struct {
    diffuse: u32,
};

pub const PointLight = extern struct {
    position: [3]f32,
    intensity: f32,
    diffuse: u32,
};

const VertexPosition = legacy.VertexPosition;
const VertexNormal = legacy.VertexNormal;
const VertexUV = legacy.VertexUV;
const Vertex = legacy.Vertex;

const Material = extern struct {
    albedo_texture_index: u32,
    albedo: u32,
    metalness_texture_index: u32,
    metalness: f32,
    roughness_texture_index: u32,
    roughness: f32,
};

//Reverse-z perspective
fn perspectiveProjection(fovy_degrees: f32, aspect_ratio: f32, znear: f32) zalgebra.Mat4 {
    const f = 1 / std.math.tan(std.math.degreesToRadians(f32, fovy_degrees) / 2);

    return .{
        .data = .{
            .{ f / aspect_ratio, 0, 0, 0 },
            .{ 0, f, 0, 0 },
            .{ 0, 0, 0, -1 },
            .{ 0, 0, znear, 0 },
        },
    };
}

fn quantisePosition(
    pos: @Vector(3, f32),
) VertexPosition {
    const quantised = VertexPosition{
        .x = @floatCast(pos[0]),
        .y = @floatCast(pos[1]),
        .z = @floatCast(pos[2]),
    };

    return quantised;
}

fn quantiseNormal(normal: @Vector(3, f32)) VertexNormal {
    const quantised = VertexNormal{
        .x = quantiseFloat(i10, normal[0]),
        .y = quantiseFloat(i10, normal[1]),
        .z = quantiseFloat(i10, normal[2]),
    };

    return quantised;
}

fn quantiseUV(uv: @Vector(2, f32)) VertexUV {
    const quantised = VertexUV{
        .u = @floatCast(uv[0]),
        .v = @floatCast(uv[1]),
    };

    return quantised;
}

fn quantiseFloat(comptime T: type, float: f32) T {
    if (@typeInfo(T).Int.signedness == .unsigned) {
        const normalized = @abs(std.math.clamp(float, -1, 1));

        return @intFromFloat(normalized * std.math.maxInt(T));
    } else {
        const normalized = std.math.clamp(float, -1, 1);

        return @intFromFloat(normalized * std.math.maxInt(T));
    }
}

fn quantiseColor(v: [4]f32) u32 {
    const Unorm4x8 = packed struct(u32) {
        x: u8,
        y: u8,
        z: u8,
        w: u8,
    };

    const x = @as(u8, @intFromFloat(v[0] * @as(f32, @floatFromInt(std.math.maxInt(u8)))));
    const y = @as(u8, @intFromFloat(v[1] * @as(f32, @floatFromInt(std.math.maxInt(u8)))));
    const z = @as(u8, @intFromFloat(v[2] * @as(f32, @floatFromInt(std.math.maxInt(u8)))));
    const w = @as(u8, @intFromFloat(v[3] * @as(f32, @floatFromInt(std.math.maxInt(u8)))));

    return @as(u32, @bitCast(Unorm4x8{
        .x = x,
        .y = y,
        .z = z,
        .w = w,
    }));
}

const Image = rendering.graph.Image;
const rendering = @import("../rendering.zig");
const legacy = @import("Renderer3D.zig");
const std = @import("std");
const zalgebra = @import("zalgebra");
