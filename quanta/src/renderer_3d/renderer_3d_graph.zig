//! Reimplementation of Renderer3D using the quanta.rendering rendering graph api

pub fn buildGraph(
    graph: *rendering.graph.Builder,
    scene: *Scene,
    scene_view: SceneView,
    output_target: *Image,
) void {
    const render_width = 1920;
    const render_height = 1080;

    const radiance_target = graph.createImage(@src(), .{
        .format = .r16g16b16a16_sfloat,
        .width = render_width,
        .height = render_height,
        .depth = 1,
    });
    _ = radiance_target;

    var depth_target = graph.createImage(@src(), .{
        .format = .d32_sfloat,
        .width = render_width,
        .height = render_height,
        .depth = 1,
    });

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
    const fov: f32 = scene_view.camera.fov;

    const projection = perspectiveProjection(fov, aspect_ratio, near_plane);
    const view = zalgebra.lookAt(
        .{ .data = scene_view.camera.translation },
        .{ .data = scene_view.camera.target },
        .{ .data = .{ 0, 1, 0 } },
    );
    const view_projection = projection.mul(view);

    const scene_data_pass = block: {
        //Upload scene data
        graph.beginTransferPass(@src());
        defer graph.endTransferPass();

        var vertex_positions_buffer = graph.createBuffer(@src(), .{
            .size = 10_024 * @sizeOf(legacy.VertexPosition),
        });

        var verticies_buffer = graph.createBuffer(@src(), .{
            .size = 10_024 * @sizeOf(legacy.Vertex),
        });

        var index_buffer = graph.createBuffer(@src(), .{
            .size = 10_024 * @sizeOf(u32),
        });

        for (scene.meshes.items) |*mesh| {
            if (mesh.positions_buffer != null) continue;

            mesh.vertex_offset = scene.mesh_vertex_offset;
            mesh.index_offset = scene.mesh_index_offset;

            graph.updateBuffer(&vertex_positions_buffer, mesh.vertex_offset * @sizeOf(VertexPosition), u8, mesh.positions_data);
            graph.updateBuffer(&verticies_buffer, mesh.vertex_offset * @sizeOf(Vertex), u8, mesh.vertex_data);
            graph.updateBuffer(&index_buffer, mesh.index_offset * @sizeOf(u32), u8, mesh.index_data);

            scene.mesh_vertex_offset += mesh.positions_data.len / @sizeOf(VertexPosition);
            scene.mesh_index_offset += mesh.index_data.len / @sizeOf(u32);

            mesh.positions_buffer = graph.bufferGetPersistantHandle(vertex_positions_buffer);
            mesh.vertex_buffer = graph.bufferGetPersistantHandle(verticies_buffer);
            mesh.index_buffer = graph.bufferGetPersistantHandle(index_buffer);
        }

        var scene_uniforms_buffer = graph.createBuffer(@src(), .{ .size = max_instance_count * @sizeOf(SceneUniforms) });

        graph.updateBufferValue(&scene_uniforms_buffer, 0, SceneUniforms, .{
            .view_position = scene_view.camera.translation,
            .view_projection = view_projection.data,
            .ambient_light = scene.ambient_light,
            .point_light_count = @intCast(scene.point_lights.len),
            .primary_directional_light_index = 0,
        });

        var transform_buffer = graph.createBuffer(@src(), .{ .size = max_instance_count * @sizeOf([4][3]f32) });

        graph.updateBuffer(&transform_buffer, 0, [4][3]f32, scene.mesh_transforms.items);

        var material_indices = graph.createBuffer(@src(), .{ .size = max_instance_count * @sizeOf(u32) });

        graph.updateBuffer(&material_indices, 0, u32, graph.scratchDupe(u32, &.{0}));

        var materials_buffer = graph.createBuffer(@src(), .{ .size = max_instance_count * @sizeOf(Material) });

        graph.updateBuffer(&materials_buffer, 0, Material, scene.materials.items);

        var point_light_buffer = graph.createBuffer(@src(), .{ .size = 1024 * @sizeOf(u32) });

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
        //Color pass
        graph.beginRasterPass(
            @src(),
            &.{.{
                .image = output_target,
                .clear = .{ 0.2, 0.2, 0.2, 1 },
            }},
            .{
                .read_write = .{
                    .image = &depth_target,
                    .clear = 0,
                },
            },
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
                .depth_attachment_format = graph.imageGetFormat(depth_target),
                .depth_state = .{
                    .write_enabled = true,
                    .test_enabled = true,
                    .compare_op = .greater_or_equal,
                },
                .rasterisation_state = .{
                    .polygon_mode = .fill,
                    .cull_mode = .back,
                },
            },
            @sizeOf(u32),
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

        for (scene.mesh_instances.items, 0..) |instance, instance_index| {
            const mesh = scene.meshes.items[instance.mesh_index];

            graph.setPushData(u32, @intCast(instance_index));

            graph.drawIndexed(
                @intCast(mesh.index_data.len / @sizeOf(u32)),
                1,
                @intCast(mesh.index_offset),
                @intCast(mesh.vertex_offset),
                0,
            );
        }

        break :block .{
            .color_target = output_target,
        };
    };

    const resolve_to_output = block: {
        graph.beginTransferPass(
            @src(),
        );
        defer graph.endTransferPass();

        const pipeline = graph.createComputePipeline(@src(), .{
            .code = @alignCast(@embedFile("color_resolve.comp.spv")),
        }, 0);

        graph.setComputePipeline(pipeline);
        graph.computeDispatch(render_width, render_height, 1);

        break :block .{
            .output_target = output_target,
        };
    };

    _ = color_pass;
    _ = resolve_to_output;
}

///Scene description consumed by the render graph builder
pub const Scene = struct {
    ambient_light: AmbientLight,
    point_lights: []PointLight,
    environment_map: struct {} = .{},
    meshes: std.ArrayListUnmanaged(Mesh) = .{},
    mesh_instances: std.ArrayListUnmanaged(MeshInstance) = .{},
    mesh_transforms: std.ArrayListUnmanaged([4][3]f32) = .{},
    material_indices: std.ArrayListUnmanaged(u32) = .{},
    materials: std.ArrayListUnmanaged(Material) = .{},

    mesh_vertex_offset: usize = 0,
    mesh_index_offset: usize = 0,

    pub fn clearInstances(self: *@This()) void {
        self.mesh_instances.items.len = 0;
        self.mesh_transforms.items.len = 0;
        self.material_indices.items.len = 0;
        self.materials.items.len = 0;
    }

    pub fn deinit(self: *@This(), allocator: std.mem.Allocator) void {
        self.meshes.deinit(allocator);
        self.mesh_instances.deinit(allocator);
        self.mesh_transforms.deinit(allocator);
        self.material_indices.deinit(allocator);
        self.materials.deinit(allocator);

        self.* = undefined;
    }

    pub fn addInstance(
        self: *@This(),
        allocator: std.mem.Allocator,
        mesh_index: u32,
        transform: zalgebra.Mat4,
        material: Material,
    ) !void {
        const actual_transform: [4][3]f32 = .{
            transform.data[0][0..3].*,
            transform.data[1][0..3].*,
            transform.data[2][0..3].*,
            transform.data[3][0..3].*,
        };

        try self.mesh_instances.append(allocator, .{
            .mesh_index = mesh_index,
        });

        try self.mesh_transforms.append(allocator, actual_transform);

        try self.materials.append(allocator, material);
    }

    pub const Mesh = struct {
        ///By default these are null
        ///When the meshes are created in buildScene, at render time, these will be initialized
        positions_buffer: ?rendering.graph.BufferHandle = null,
        vertex_buffer: ?rendering.graph.BufferHandle = null,
        index_buffer: ?rendering.graph.BufferHandle = null,

        vertex_offset: usize = 0,
        index_offset: usize = 0,

        positions_data: []const u8,
        vertex_data: []const u8,
        index_data: []const u8,
    };

    pub const MeshInstance = struct {
        mesh_index: u32,
    };

    pub const Texture = struct {
        image_handle: ?rendering.graph.ImageHandle,
        //TODO: sampler
    };
};

///Represents a single view into a scene
pub const SceneView = struct {
    camera: legacy.Camera,
};

pub const AmbientLight = extern struct {
    diffuse: u32,
};

pub const PointLight = extern struct {
    position: [3]f32,
    intensity: f32,
    diffuse: u32,
};

pub const VertexPosition = legacy.VertexPosition;
pub const VertexNormal = legacy.VertexNormal;
pub const VertexUV = legacy.VertexUV;
pub const Vertex = legacy.Vertex;

pub const Material = extern struct {
    albedo_texture_index: u32,
    albedo: u32,
    metalness_texture_index: u32,
    metalness: f32,
    roughness_texture_index: u32,
    roughness: f32,
};

///Reverse-z perspective
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

pub fn quantisePosition(
    pos: @Vector(3, f32),
) VertexPosition {
    const quantised = VertexPosition{
        .x = @floatCast(pos[0]),
        .y = @floatCast(pos[1]),
        .z = @floatCast(pos[2]),
    };

    return quantised;
}

pub fn quantiseNormal(normal: @Vector(3, f32)) VertexNormal {
    const quantised = VertexNormal{
        .x = quantiseFloat(i10, normal[0]),
        .y = quantiseFloat(i10, normal[1]),
        .z = quantiseFloat(i10, normal[2]),
    };

    return quantised;
}

pub fn quantiseUV(uv: @Vector(2, f32)) VertexUV {
    const quantised = VertexUV{
        .u = @floatCast(uv[0]),
        .v = @floatCast(uv[1]),
    };

    return quantised;
}

pub fn quantiseFloat(comptime T: type, float: f32) T {
    if (@typeInfo(T).Int.signedness == .unsigned) {
        const normalized = @abs(std.math.clamp(float, -1, 1));

        return @intFromFloat(normalized * std.math.maxInt(T));
    } else {
        const normalized = std.math.clamp(float, -1, 1);

        return @intFromFloat(normalized * std.math.maxInt(T));
    }
}

pub fn quantiseColor(v: [4]f32) u32 {
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
