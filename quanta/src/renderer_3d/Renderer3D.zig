const depth_reduce_comp_spv: []align(4) const u8 = @alignCast(@embedFile("depth_reduce.comp.spv"));
const depth_vert_spv: []align(4) const u8 = @alignCast(@embedFile("depth.vert.spv"));
const depth_frag_spv: []align(4) const u8 = @alignCast(@embedFile("depth.frag.spv"));

const SkyPipelinePushConstants = extern struct {
    view_projection: [4][4]f32,
};

const DepthPassPushConstants = extern struct {
    view_projection: [4][4]f32,
};

const ColorPassUniforms = extern struct {
    view_projection: [4][4]f32 align(1),
    view_position: [3]f32 align(1),
    point_light_count: u32 align(1),
    ambient_light: AmbientLight align(1),
    primary_directional_light_index: u32 align(1),
};

const ColorResolvePushData = extern struct {
    exposure: f32,
};

const DepthReducePushData = extern struct {
    image_size: [2]f32,
    image_index: u32,
};

const DrawCullPushConstants = extern struct {
    draw_count: u32,
    near_face: [4]f32,
    far_face: [4]f32,
    right_face: [4]f32,
    left_face: [4]f32,
    top_face: [4]f32,
    bottom_face: [4]f32,
    post_depth_local_size_x: u32,
};

const PostDepthCullPushConstants = extern struct {
    post_depth_draw_command_offset: u32,
};

const InputDraw = extern struct {
    mesh_index: u32,
};

const DrawCommand = extern struct {
    indirect_command: graphics.CommandBuffer.DrawIndexedIndirectCommand,
    instance_index: u32,
};

pub var self: Renderer3D = undefined;

allocator: std.mem.Allocator,
radiance_color_image: graphics.Image,
depth_image: graphics.Image,
depth_pyramid: graphics.Image,
depth_pyramid_levels: []Image.View,
depth_pyramid_level_count: u32,
shadow_image: graphics.Image,
shadow_sampler: graphics.Sampler,
command_buffers: []graphics.CommandBuffer,
frame_fence: graphics.Fence,
first_frame: bool = true,

transfer_command_buffer: graphics.CommandBuffer,
image_transfer_events: std.ArrayListUnmanaged(graphics.Event),

image_staging_buffers: std.ArrayListUnmanaged(graphics.Buffer),
image_staging_fence: graphics.Fence,

vertex_position_staging_buffers: std.ArrayListUnmanaged(graphics.Buffer),
vertex_staging_buffers: std.ArrayListUnmanaged(graphics.Buffer),
index_staging_buffers: std.ArrayListUnmanaged(graphics.Buffer),
mesh_staging_fence: graphics.Fence,

vertex_position_buffer: graphics.Buffer,
vertex_position_offset: usize,
vertex_buffer: graphics.Buffer,
vertex_offset: usize,
index_buffer: graphics.Buffer,
index_offset: usize,

depth_reduce_sampler: graphics.Sampler,

depth_reduce_pipeline: graphics.ComputePipeline,
cull_pipeline: graphics.ComputePipeline,
post_depth_cull_pipeline: graphics.ComputePipeline,
depth_pipeline: graphics.GraphicsPipeline,
shadow_pipeline: graphics.GraphicsPipeline,
color_pipeline: graphics.GraphicsPipeline,
sky_pipeline: graphics.GraphicsPipeline,
color_resolve_pipeline: graphics.ComputePipeline,

meshes: std.ArrayListUnmanaged(Mesh),
///This is probably an unecessary hack, we don't need to store bounding boxes twice?
mesh_bounding_boxes: std.ArrayListUnmanaged(struct { min: @Vector(3, f32), max: @Vector(3, f32) }),
mesh_buffer: graphics.Buffer,

mesh_lods: std.ArrayListUnmanaged(MeshLod),
mesh_lod_buffer: graphics.Buffer,

materials: std.ArrayListUnmanaged(Material),
materials_buffer: graphics.Buffer,

scenes: std.ArrayListUnmanaged(Scene),

texture_images: std.ArrayListUnmanaged(Image),
texture_samplers: std.ArrayListUnmanaged(Sampler),

camera: Camera,

mesh_data_changed: bool,
material_data_changed: bool,

statistics: Statistics,
timeline_query_pool: vk.QueryPool,

fn previousPow2(v: u32) u32 {
    var r: u32 = 1;

    while (r * 2 < v)
        r *= 2;

    return r;
}

fn getImageMipLevels(width: u32, height: u32) u32 {
    var current_width = width;
    var current_height = height;

    var result: u32 = 1;

    while (current_width > 1 or current_height > 1) {
        result += 1;
        current_width /= 2;
        current_height /= 2;
    }

    return result;
}

fn initFrameImages(render_width: u32, render_height: u32) !void {
    self.radiance_color_image = try Image.init(
        .@"2d",
        render_width,
        render_height,
        1,
        1,
        .r16g16b16a16_sfloat,
        vk.ImageLayout.attachment_optimal,
        .{
            .color_attachment_bit = true,
            .storage_bit = true,
            .sampled_bit = true,
        },
    );
    errdefer self.radiance_color_image.deinit();

    self.depth_image = try Image.init(
        .@"2d",
        render_width,
        render_height,
        1,
        1,
        .d32_sfloat,
        vk.ImageLayout.attachment_optimal,
        .{
            .depth_stencil_attachment_bit = true,
            .sampled_bit = true,
        },
    );
    errdefer self.depth_image.deinit();

    const depth_pyramid_width = previousPow2(render_width);
    const depth_pyramid_height = previousPow2(render_height);

    self.depth_pyramid_level_count = getImageMipLevels(depth_pyramid_width, depth_pyramid_height);

    self.depth_pyramid = try Image.init(
        .@"2d",
        depth_pyramid_width,
        depth_pyramid_height,
        1,
        self.depth_pyramid_level_count,
        .r32_sfloat,
        .general,
        .{
            .transfer_src_bit = true,
            .storage_bit = true,
            .sampled_bit = true,
        },
    );
    errdefer self.depth_pyramid.deinit();

    self.depth_pyramid_levels = try self.allocator.alloc(graphics.Image.View, self.depth_pyramid.levels);
    errdefer self.allocator.free(self.depth_pyramid_levels);

    for (self.depth_pyramid_levels, 0..) |*pyramid_level, i| {
        pyramid_level.* = try self.depth_pyramid.createView(@as(u32, @intCast(i)), 1);

        if (i == 0) {
            self.depth_reduce_pipeline.setDescriptorImageSampler(1, 0, self.depth_image, self.depth_reduce_sampler);
        } else {
            self.depth_reduce_pipeline.setDescriptorImageViewSampler(1, @as(u32, @intCast(i)), self.depth_pyramid_levels[i - 1], self.depth_reduce_sampler);
        }

        self.depth_reduce_pipeline.setDescriptorImageView(0, @as(u32, @intCast(i)), self.depth_pyramid_levels[i]);
    }

    errdefer for (self.depth_pyramid_levels) |*pyramid_level| {
        self.depth_pyramid.destroyView(pyramid_level.*);
    };

    self.shadow_image = try Image.init(
        .@"2d",
        4096,
        4096,
        1,
        1,
        .d32_sfloat,
        vk.ImageLayout.attachment_optimal,
        .{
            .depth_stencil_attachment_bit = true,
            .sampled_bit = true,
        },
    );
    errdefer self.shadow_image.deinit();
}

fn deinitFrameImages() void {
    defer self.radiance_color_image.deinit();
    defer self.depth_image.deinit();
    defer self.depth_pyramid.deinit();
    defer self.allocator.free(self.depth_pyramid_levels);
    defer for (self.depth_pyramid_levels) |pyramid_level| {
        self.depth_pyramid.destroyView(pyramid_level);
    };
    defer self.shadow_image.deinit();
}

pub fn init(allocator: std.mem.Allocator) !void {
    self.allocator = allocator;
    self.vertex_offset = 0;
    self.index_offset = 0;
    self.vertex_position_offset = 0;
    self.mesh_data_changed = false;
    self.material_data_changed = false;
    self.image_transfer_events = .{};
    self.vertex_position_staging_buffers = .{};
    self.vertex_staging_buffers = .{};
    self.index_staging_buffers = .{};
    self.first_frame = true;

    self.depth_reduce_pipeline = try graphics.ComputePipeline.init(
        self.allocator,
        depth_reduce_comp_spv,
        .@"2d",
        null,
        DepthReducePushData,
    );
    errdefer self.depth_reduce_pipeline.deinit(self.allocator);

    self.depth_reduce_sampler = try graphics.Sampler.init(
        .nearest,
        .nearest,
        .repeat,
        .repeat,
        .repeat,
        .min,
    );
    errdefer self.depth_reduce_sampler.deinit();

    try initFrameImages(1920, 1080);
    errdefer deinitFrameImages();

    self.command_buffers = try allocator.alloc(graphics.CommandBuffer, 2);
    errdefer allocator.free(self.command_buffers);

    self.materials = .{};
    self.texture_images = .{};
    self.texture_samplers = .{};

    for (self.command_buffers) |*command_buffer| {
        command_buffer.* = try graphics.CommandBuffer.init(.graphics);
    }

    errdefer for (self.command_buffers) |*command_buffer| {
        command_buffer.deinit();
    };

    self.transfer_command_buffer = try graphics.CommandBuffer.init(.transfer);
    errdefer self.transfer_command_buffer.deinit();

    self.image_staging_buffers = .{};
    self.image_staging_fence = try graphics.Fence.init();
    errdefer self.image_staging_fence.deinit();

    self.frame_fence = try graphics.Fence.init();
    errdefer self.frame_fence.deinit();

    self.mesh_buffer = try graphics.Buffer.init(4096, .storage);
    errdefer self.mesh_buffer.deinit();

    self.mesh_lod_buffer = try graphics.Buffer.init(4096 * 4, .storage);
    errdefer self.mesh_lod_buffer.deinit();

    const vertex_buffer_size = 32 * 1024 * 1024;

    self.vertex_position_buffer = try graphics.Buffer.init(vertex_buffer_size, .vertex);
    errdefer self.vertex_position_buffer.deinit();

    self.vertex_buffer = try graphics.Buffer.init(vertex_buffer_size, .vertex);
    errdefer self.vertex_buffer.deinit();

    self.index_buffer = try graphics.Buffer.init(vertex_buffer_size, .index);
    errdefer self.index_buffer.deinit();

    self.cull_pipeline = try graphics.ComputePipeline.init(
        self.allocator,
        @alignCast(@embedFile("pre_depth_cull.comp.spv")),
        .@"1d",
        null,
        DrawCullPushConstants,
    );
    errdefer self.cull_pipeline.deinit(self.allocator);

    self.post_depth_cull_pipeline = try graphics.ComputePipeline.init(
        self.allocator,
        @alignCast(@embedFile("post_depth_cull.comp.spv")),
        .@"1d",
        null,
        PostDepthCullPushConstants,
    );
    errdefer self.post_depth_cull_pipeline.deinit(self.allocator);

    self.post_depth_cull_pipeline.setDescriptorBuffer(1, 0, self.mesh_buffer);
    self.post_depth_cull_pipeline.setDescriptorImageSampler(2, 0, self.depth_pyramid, self.depth_reduce_sampler);

    self.color_pipeline = try graphics.GraphicsPipeline.init(
        self.allocator,
        .{
            .color_attachment_formats = &[_]vk.Format{
            //use when drawing directly to swapchain image
            // swapchain.surface_format.format,
            self.radiance_color_image.format},
            .depth_attachment_format = self.depth_image.format,
            .vertex_shader_binary = @alignCast(@embedFile("tri.vert.spv")),
            .fragment_shader_binary = @alignCast(@embedFile("tri.frag.spv")),
            .depth_state = .{
                .write_enabled = false,
                .test_enabled = true,
                .compare_op = .greater_or_equal,
            },
            .rasterisation_state = .{
                .polygon_mode = .fill,
                .cull_mode = .back,
            },
        },
        null,
        0,
    );
    errdefer self.color_pipeline.deinit(allocator);

    self.sky_pipeline = try graphics.GraphicsPipeline.init(
        self.allocator,
        .{
            .color_attachment_formats = &[_]vk.Format{
                self.radiance_color_image.format,
            },
            .depth_attachment_format = self.depth_image.format,
            .vertex_shader_binary = @alignCast(@embedFile("sky.vert.spv")),
            .fragment_shader_binary = @alignCast(@embedFile("sky.frag.spv")),
            .depth_state = .{
                .write_enabled = false,
                .test_enabled = true,
                .compare_op = .greater_or_equal,
            },
            .rasterisation_state = .{
                .polygon_mode = .fill,
                .cull_mode = .back,
            },
        },
        null,
        @sizeOf(SkyPipelinePushConstants),
    );
    errdefer self.sky_pipeline.deinit(allocator);

    self.depth_pipeline = try graphics.GraphicsPipeline.init(
        self.allocator,
        .{
            .color_attachment_formats = &.{},
            .depth_attachment_format = self.depth_image.format,
            .vertex_shader_binary = depth_vert_spv,
            .fragment_shader_binary = depth_frag_spv,
            .depth_state = .{
                .write_enabled = true,
                .test_enabled = true,
                .compare_op = .greater,
            },
            .rasterisation_state = .{
                .polygon_mode = .fill,
                .cull_mode = .back,
            },
        },
        null,
        @sizeOf(DepthPassPushConstants),
    );
    errdefer self.depth_pipeline.deinit(allocator);

    self.shadow_pipeline = try graphics.GraphicsPipeline.init(
        self.allocator,
        .{
            .color_attachment_formats = &.{},
            .depth_attachment_format = self.shadow_image.format,
            .vertex_shader_binary = depth_vert_spv,
            .fragment_shader_binary = depth_frag_spv,
            .depth_state = .{
                .write_enabled = true,
                .test_enabled = true,
                .compare_op = .greater,
            },
            .rasterisation_state = .{
                .polygon_mode = .fill,
                .cull_mode = .none,
            },
        },
        null,
        @sizeOf(DepthPassPushConstants),
    );
    errdefer self.shadow_pipeline.deinit(allocator);

    self.color_resolve_pipeline = try graphics.ComputePipeline.init(
        allocator,
        @alignCast(@embedFile("color_resolve.comp.spv")),
        .@"2d",
        null,
        ColorResolvePushData,
    );
    errdefer self.color_resolve_pipeline.deinit(self.allocator);

    self.materials_buffer = try graphics.Buffer.init(1024 * @sizeOf(Material), .storage);
    errdefer self.materials_buffer.deinit();

    self.shadow_sampler = try graphics.Sampler.init(
        .linear,
        .linear,
        .clamp_to_border,
        .clamp_to_border,
        .clamp_to_border,
        null,
    );
    errdefer self.shadow_sampler.deinit();

    self.color_pipeline.setDescriptorBuffer(0, 0, self.vertex_position_buffer);
    self.color_pipeline.setDescriptorBuffer(1, 0, self.vertex_buffer);
    self.color_pipeline.setDescriptorBuffer(5, 0, self.materials_buffer);
    self.color_pipeline.setDescriptorImageSamplerWithLayout(9, 0, self.shadow_image, .general, self.shadow_sampler);

    self.depth_pipeline.setDescriptorBuffer(0, 0, self.vertex_position_buffer);

    self.shadow_pipeline.setDescriptorBuffer(0, 0, self.vertex_position_buffer);

    self.cull_pipeline.setDescriptorBuffer(1, 0, self.mesh_buffer);
    self.cull_pipeline.setDescriptorBuffer(2, 0, self.mesh_lod_buffer);

    self.timeline_query_pool = try GraphicsContext.self.vkd.createQueryPool(GraphicsContext.self.device, &vk.QueryPoolCreateInfo{
        .flags = vk.QueryPoolCreateFlags{},
        .query_type = vk.QueryType.timestamp,
        .query_count = 4,
        .pipeline_statistics = vk.QueryPipelineStatisticFlags{},
    }, GraphicsContext.self.allocation_callbacks);
    errdefer GraphicsContext.self.vkd.destroyQueryPool(GraphicsContext.self.device, self.timeline_query_pool, GraphicsContext.self.allocation_callbacks);
}

pub fn deinit() void {
    defer self = undefined;
    defer self.allocator.free(self.command_buffers);
    defer deinitFrameImages();
    defer for (self.command_buffers) |*command_buffer| {
        command_buffer.deinit();
    };

    for (self.image_staging_buffers.items) |*staging_buffer| {
        staging_buffer.deinit();
    }

    for (self.image_transfer_events.items) |*event| {
        event.deinit();
    }

    for (self.vertex_position_staging_buffers.items) |*staging| {
        staging.deinit();
    }

    for (self.vertex_staging_buffers.items) |*staging| {
        staging.deinit();
    }

    for (self.index_staging_buffers.items) |*staging| {
        staging.deinit();
    }

    defer self.image_staging_buffers.deinit(self.allocator);
    defer self.transfer_command_buffer.deinit();
    defer self.image_staging_fence.deinit();
    defer self.frame_fence.deinit();
    defer self.image_transfer_events.deinit(self.allocator);
    defer self.vertex_position_staging_buffers.deinit(self.allocator);
    defer self.vertex_staging_buffers.deinit(self.allocator);
    defer self.index_staging_buffers.deinit(self.allocator);
    defer self.mesh_buffer.deinit();
    defer self.mesh_lod_buffer.deinit();
    defer self.vertex_position_buffer.deinit();
    defer self.vertex_buffer.deinit();
    defer self.index_buffer.deinit();
    defer self.depth_reduce_sampler.deinit();
    defer self.depth_reduce_pipeline.deinit(self.allocator);
    defer self.cull_pipeline.deinit(self.allocator);
    defer self.post_depth_cull_pipeline.deinit(self.allocator);
    defer self.depth_pipeline.deinit(self.allocator);
    defer self.shadow_pipeline.deinit(self.allocator);
    defer self.shadow_sampler.deinit();
    defer self.color_pipeline.deinit(self.allocator);
    defer self.sky_pipeline.deinit(self.allocator);
    defer self.color_resolve_pipeline.deinit(self.allocator);
    defer self.meshes.deinit(self.allocator);
    defer self.mesh_bounding_boxes.deinit(self.allocator);
    defer self.mesh_lods.deinit(self.allocator);
    defer self.materials.deinit(self.allocator);
    defer self.materials_buffer.deinit();
    defer self.texture_images.deinit(self.allocator);
    defer for (self.texture_images.items) |*image| {
        image.deinit();
    };
    defer self.texture_samplers.deinit(self.allocator);
    defer for (self.texture_samplers.items) |*sampler| {
        sampler.deinit();
    };
    defer GraphicsContext.self.vkd.destroyQueryPool(GraphicsContext.self.device, self.timeline_query_pool, GraphicsContext.self.allocation_callbacks);
    defer self.scenes.deinit(self.allocator);
}

pub const Camera = struct {
    translation: [3]f32,
    target: [3]f32,
    fov: f32,
    exposure: f32,

    const Window = @import("../windowing/Window.zig");

    ///Returns a non-inverse z projection matrix
    pub fn getProjectionNonInverse(camera: Camera, window: *Window) [4][4]f32 {
        const aspect_ratio: f32 = @as(f32, @floatFromInt(window.getWidth())) / @as(f32, @floatFromInt(window.getHeight()));
        const near_plane: f32 = 0.01;
        const fov: f32 = camera.fov;

        const projection_non_inverse = zalgebra.perspective(fov, aspect_ratio, near_plane, 500);

        return projection_non_inverse.data;
    }

    pub fn getView(camera: Camera) [4][4]f32 {
        const view = zalgebra.lookAt(
            .{ .data = camera.translation },
            .{ .data = camera.target },
            .{ .data = .{ 0, 1, 0 } },
        );

        return view.data;
    }
};

pub fn beginSceneRender(
    scene: SceneHandle,
    active_views: []const View,
    ambient_light: AmbientLight,
    primary_directional_light_index: u32,
) !void {
    const scene_data: *Scene = &self.scenes.items[@intFromEnum(scene)];

    std.debug.assert(active_views.len == 1);

    scene_data.ambient_light = ambient_light;

    scene_data.dynamic_draw_count = 0;
    scene_data.directional_light_count = 0;
    scene_data.point_light_count = 0;
    scene_data.primary_directional_light_index = primary_directional_light_index;

    self.camera = active_views[0].camera;

    if (self.material_data_changed or self.mesh_data_changed) {
        {
            try self.transfer_command_buffer.begin();
            defer self.transfer_command_buffer.end();

            if (self.mesh_data_changed) {
                try self.mesh_buffer.update(Mesh, 0, self.meshes.items);
                try self.mesh_lod_buffer.update(MeshLod, 0, self.mesh_lods.items);

                {
                    var offset: usize = 0;

                    for (self.vertex_position_staging_buffers.items) |staging_buffer| {
                        self.transfer_command_buffer.copyBuffer(staging_buffer, 0, staging_buffer.size, self.vertex_position_buffer, offset, self.vertex_position_buffer.size);

                        offset += staging_buffer.size;
                    }
                }

                {
                    var offset: usize = 0;

                    for (self.vertex_staging_buffers.items) |staging_buffer| {
                        self.transfer_command_buffer.copyBuffer(staging_buffer, 0, staging_buffer.size, self.vertex_buffer, offset, self.vertex_buffer.size);

                        offset += staging_buffer.size;
                    }
                }

                {
                    var offset: usize = 0;

                    for (self.index_staging_buffers.items) |staging_buffer| {
                        self.transfer_command_buffer.copyBuffer(staging_buffer, 0, staging_buffer.size, self.index_buffer, offset, self.index_buffer.size);

                        offset += staging_buffer.size;
                    }
                }

                self.mesh_data_changed = false;
            }

            if (self.material_data_changed) {
                try self.materials_buffer.update(Material, 0, self.materials.items);

                for (self.image_staging_buffers.items, 0..) |staging_buffer, i| {
                    self.transfer_command_buffer.copyBufferToImage(staging_buffer, self.texture_images.items[i]);

                    GraphicsContext.self.vkd.cmdSetEvent2(self.transfer_command_buffer.handle, self.image_transfer_events.items[i].handle, &.{
                        .dependency_flags = .{},
                        .memory_barrier_count = 0,
                        .p_memory_barriers = undefined,
                        .buffer_memory_barrier_count = 0,
                        .p_buffer_memory_barriers = undefined,
                        .image_memory_barrier_count = 1,
                        .p_image_memory_barriers = &[_]vk.ImageMemoryBarrier2{.{
                            .src_stage_mask = .{
                                .copy_bit = true,
                            },
                            .src_access_mask = .{
                                .transfer_write_bit = true,
                            },
                            .dst_access_mask = .{},
                            .dst_stage_mask = .{},
                            .old_layout = .transfer_dst_optimal,
                            .new_layout = self.texture_images.items[i].layout,
                            .src_queue_family_index = GraphicsContext.self.transfer_family_index.?,
                            .dst_queue_family_index = GraphicsContext.self.graphics_family_index.?,
                            .image = self.texture_images.items[i].handle,
                            .subresource_range = .{
                                .aspect_mask = self.texture_images.items[i].aspect_mask,
                                .base_mip_level = 0,
                                .level_count = vk.REMAINING_MIP_LEVELS,
                                .base_array_layer = 0,
                                .layer_count = vk.REMAINING_ARRAY_LAYERS,
                            },
                        }},
                    });
                }

                self.material_data_changed = false;
            }
        }

        self.image_staging_fence.reset();
        try self.transfer_command_buffer.submit(self.image_staging_fence);
    }
}

//Reverse-z ortho (I think)
fn orthographicProjection(left: f32, right: f32, bottom: f32, top: f32, z_near: f32, z_far: f32) zalgebra.Mat4 {
    return zalgebra.orthographic(left, right, bottom, top, z_far, z_near);
}

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

fn vectorLength(p: @Vector(4, f32)) f32 {
    return @sqrt(@reduce(.Add, p * p));
}

fn vectorCross(a: @Vector(3, f32), b: @Vector(3, f32)) @Vector(3, f32) {
    const x1 = a[0];
    const y1 = a[1];
    const z1 = a[2];

    const x2 = b[0];
    const y2 = b[1];
    const z2 = b[2];

    const result_x = (y1 * z2) - (z1 * y2);
    const result_y = (z1 * x2) - (x1 * z2);
    const result_z = (x1 * y2) - (y1 * x2);

    return @Vector(3, f32){ result_x, result_y, result_z };
}

fn normalizePlane(p: @Vector(4, f32)) @Vector(4, f32) {
    return p / @as(@Vector(4, f32), @splat(vectorLength(.{ p[0], p[1], p[2], 0 })));
}

fn extractPlanesFromProjmat(proj: [4][4]f32, view: [4][4]f32, left: *[4]f32, right: *[4]f32, bottom: *[4]f32, top: *[4]f32, near: *[4]f32, far: *[4]f32) void {
    const mat = zalgebra.Mat4.mul(zalgebra.Mat4{ .data = proj }, zalgebra.Mat4.transpose(.{ .data = view })).data;

    var i: usize = 0;

    i = 3;
    while (i > 0) : (i -= 1) left[i] = mat[i][3] + mat[i][0];
    i = 3;
    while (i > 0) : (i -= 1) right[i] = mat[i][3] - mat[i][0];
    i = 3;
    while (i > 0) : (i -= 1) bottom[i] = mat[i][3] + mat[i][1];
    i = 3;
    while (i > 0) : (i -= 1) top[i] = mat[i][3] - mat[i][1];
    i = 3;
    while (i > 0) : (i -= 1) near[i] = mat[i][3] + mat[i][2];
    i = 3;
    while (i > 0) : (i -= 1) far[i] = mat[i][3] - mat[i][2];
}

fn createPlane(p1: @Vector(3, f32), normal: @Vector(3, f32)) [4]f32 {
    const normalized_normal = zalgebra.Vec3.norm(.{ .data = normal }).data;
    const distance = zalgebra.Vec3.dot(.{ .data = normalized_normal }, .{ .data = p1 });

    return .{ normalized_normal[0], normalized_normal[1], normalized_normal[2], distance };
}

fn getFrustumCorners(view_projection: zalgebra.Mat4) [8][3]f32 {
    var points: [8][3]f32 = undefined;

    const inverse = zalgebra.Mat4.inv(view_projection);

    var x: u32 = 0;
    var i: u32 = 0;

    while (x < 2) : (x += 1) {
        var y: u32 = 0;

        while (y < 2) : (y += 1) {
            var z: u32 = 0;

            while (z < 2) : (z += 1) {
                const point = inverse.mulByVec4(.{ .data = .{ 2 * @as(f32, @floatFromInt(x)) - 1, 2 * @as(f32, @floatFromInt(y)) - 1, 2 * @as(f32, @floatFromInt(z)) - 1, 1 } });

                points[i] = .{ point.data[0], point.data[1], point.data[2] };
                points[i][0] /= point.data[3];
                points[i][1] /= point.data[3];
                points[i][2] /= point.data[3];

                i += 1;
            }
        }
    }

    return points;
}

pub fn endSceneRender(
    scene: SceneHandle,
    target: graphics.Image,
    target_aqcuired: graphics.Semaphore,
    target_render_finished: graphics.Semaphore,
) !void {
    const scene_data: *Scene = &self.scenes.items[@intFromEnum(scene)];

    if (self.image_staging_fence.getStatus() == true) {
        self.material_data_changed = false;
        self.mesh_data_changed = false;

        for (self.image_staging_buffers.items) |*staging_buffer| {
            staging_buffer.deinit();
        }
        self.image_staging_buffers.clearRetainingCapacity();

        for (self.image_transfer_events.items) |*event| {
            event.deinit();
        }
        self.image_transfer_events.clearRetainingCapacity();

        for (self.vertex_position_staging_buffers.items) |*staging| {
            staging.deinit();
        }
        self.vertex_position_staging_buffers.clearRetainingCapacity();

        for (self.vertex_staging_buffers.items) |*staging| {
            staging.deinit();
        }
        self.vertex_staging_buffers.clearRetainingCapacity();

        for (self.index_staging_buffers.items) |*staging| {
            staging.deinit();
        }
        self.index_staging_buffers.clearRetainingCapacity();
    }

    const command_buffer = &self.command_buffers[0];

    const aspect_ratio: f32 = @as(f32, @floatFromInt(target.width)) / @as(f32, @floatFromInt(target.height));
    const near_plane: f32 = 0.01;
    const fov: f32 = self.camera.fov;

    const projection = perspectiveProjection(fov, aspect_ratio, near_plane);
    const projection_non_inverse = zalgebra.perspective(fov, aspect_ratio, near_plane, 500);
    const view = zalgebra.lookAt(
        .{ .data = self.camera.translation },
        .{ .data = self.camera.target },
        .{ .data = .{ 0, 1, 0 } },
    );
    const view_projection = projection.mul(view);
    // const view_frustum_corners = getFrustumCorners(view_projection);
    const view_frustum_corners = getFrustumCorners(projection_non_inverse.mul(view));

    var shadow_view_frustrum_center: [3]f32 = .{ 0, 0, 0 };

    for (view_frustum_corners) |corner| {
        shadow_view_frustrum_center[0] += corner[0];
        shadow_view_frustrum_center[1] += corner[1];
        shadow_view_frustrum_center[2] += corner[2];
    }

    shadow_view_frustrum_center[0] /= @as(f32, @floatFromInt(view_frustum_corners.len));
    shadow_view_frustrum_center[1] /= @as(f32, @floatFromInt(view_frustum_corners.len));
    shadow_view_frustrum_center[2] /= @as(f32, @floatFromInt(view_frustum_corners.len));

    const primary_directional_light = &scene_data.directional_lights[0][scene_data.primary_directional_light_index];

    const shadow_view_position = [3]f32{ shadow_view_frustrum_center[0] + primary_directional_light.direction[0], shadow_view_frustrum_center[1] + primary_directional_light.direction[1], shadow_view_frustrum_center[2] + primary_directional_light.direction[2] };

    const shadow_view = zalgebra.lookAt(.{ .data = shadow_view_position }, .{ .data = shadow_view_frustrum_center }, .{ .data = .{ 0, 1, 0 } });

    var shadow_projection: zalgebra.Mat4 = undefined;

    {
        var min_x: f32 = std.math.floatMax(f32);
        var min_y: f32 = std.math.floatMax(f32);
        var min_z: f32 = std.math.floatMax(f32);

        var max_x: f32 = std.math.floatMin(f32);
        var max_y: f32 = std.math.floatMin(f32);
        var max_z: f32 = std.math.floatMin(f32);

        for (view_frustum_corners) |corner| {
            const corner_in_light_space = zalgebra.Mat4.mulByVec4(shadow_view, .{ .data = .{ corner[0], corner[1], corner[2], 1 } });

            min_x = @min(min_x, corner_in_light_space.data[0]);
            min_y = @min(min_y, corner_in_light_space.data[1]);
            min_z = @min(min_z, corner_in_light_space.data[2]);

            max_x = @max(max_x, corner_in_light_space.data[0]);
            max_y = @max(max_y, corner_in_light_space.data[1]);
            max_z = @max(max_z, corner_in_light_space.data[2]);
        }

        //compute from scene bounds
        const z_factor = 1000;

        if (min_z < 0) {
            min_z *= z_factor;
        } else {
            min_z /= z_factor;
        }

        if (max_z < 0) {
            max_z /= z_factor;
        } else {
            max_z *= z_factor;
        }

        shadow_projection = orthographicProjection(min_x, max_x, min_y, max_y, min_z, max_z);
    }

    //view_projection for directional light view
    const shadow_view_projection = shadow_projection.mul(shadow_view);

    scene_data.uniforms[0].* = ColorPassUniforms{
        .view_projection = view_projection.data,
        .view_position = self.camera.translation,
        .point_light_count = scene_data.point_light_count,
        .ambient_light = scene_data.ambient_light,
        .primary_directional_light_index = scene_data.primary_directional_light_index,
    };

    primary_directional_light.view_projection = shadow_view_projection.data;

    if (!self.first_frame) {
        self.command_buffers[1].wait_fence.wait();
        self.command_buffers[1].wait_fence.reset();

        var times = [_]u64{ 0, 0, 0, 0 };

        _ = try GraphicsContext.self.vkd.getQueryPoolResults(
            GraphicsContext.self.device,
            self.timeline_query_pool,
            0,
            4,
            @sizeOf(@TypeOf(times)),
            &times,
            @sizeOf(u64),
            vk.QueryResultFlags{ .wait_bit = false, .@"64_bit" = true },
        );

        self.statistics.depth_prepass_time = times[1] - times[0];
        self.statistics.geometry_pass_time = times[3] - times[2];
    }

    self.first_frame = false;

    //Render passes
    {
        command_buffer.begin() catch unreachable;
        defer command_buffer.end();

        command_buffer.copyEntireBuffer(scene_data.uniforms_staging_buffers[0], scene_data.uniforms_buffer);
        command_buffer.copyEntireBuffer(scene_data.input_draw_staging_buffers[0], scene_data.input_draw_buffer);
        command_buffer.copyEntireBuffer(scene_data.transforms_staging_buffers[0], scene_data.transforms_buffer);
        command_buffer.copyEntireBuffer(scene_data.material_indices_staging_buffers[0], scene_data.material_indices_buffer);
        command_buffer.copyEntireBuffer(scene_data.point_light_staging_buffers[0], scene_data.point_light_buffer);
        command_buffer.copyEntireBuffer(scene_data.directional_light_staging_buffers[0], scene_data.directional_light_buffer);

        command_buffer.memoryBarrier(.{
            .source_stage = .{ .copy = true },
            .source_access = .{ .transfer_write = true },
            .destination_stage = .{ .all_commands = true },
            .destination_access = .{ .shader_storage_read = true, .shader_read = true, .transfer_read = true },
        });

        GraphicsContext.self.vkd.cmdResetQueryPool(command_buffer.handle, self.timeline_query_pool, 0, 4);

        //compute pass #1 pre depth per instance cull
        {
            command_buffer.setComputePipeline(self.cull_pipeline);

            command_buffer.fillBuffer(scene_data.draw_indirect_count_buffer, 0, @sizeOf(u32) * 2, 0);

            command_buffer.bufferBarrier(scene_data.draw_indirect_count_buffer, .{
                .source_stage = .{ .copy = true },
                .source_access = .{ .transfer_write = true },
                .destination_stage = .{ .compute_shader = true },
                .destination_access = .{ .shader_read = true, .shader_write = true },
            });

            var near_face: [4]f32 = .{ 0, 0, 0, 0 };
            const far_face: [4]f32 = .{ 0, 0, 0, 0 };
            const right_face: [4]f32 = .{ 0, 0, 0, 0 };
            const left_face: [4]f32 = .{ 0, 0, 0, 0 };
            const top_face: [4]f32 = .{ 0, 0, 0, 0 };
            const bottom_face: [4]f32 = .{ 0, 0, 0, 0 };

            // extractPlanesFromProjmat(view_projection.data, view_projection.data, &left_face, &right_face, &bottom_face, &top_face, &near_face, &far_face);

            const front = @as(@Vector(3, f32), self.camera.target) - @as(@Vector(3, f32), self.camera.translation);

            near_face = createPlane(self.camera.translation + (@as(@Vector(3, f32), @splat(near_plane)) * front), front);

            command_buffer.setPushData(DrawCullPushConstants, .{
                .draw_count = scene_data.static_draw_count + scene_data.dynamic_draw_count,
                .near_face = near_face,
                .far_face = far_face,
                .right_face = right_face,
                .left_face = left_face,
                .top_face = top_face,
                .bottom_face = bottom_face,
                .post_depth_local_size_x = self.post_depth_cull_pipeline.local_size_x,
            });
            command_buffer.computeDispatch(scene_data.static_draw_count + scene_data.dynamic_draw_count, 1, 1);

            command_buffer.bufferBarrier(scene_data.draw_indirect_buffer, .{
                .source_stage = .{ .compute_shader = true },
                .source_access = .{ .shader_write = true },
                .destination_stage = .{ .draw_indirect = true, .vertex_shader = true },
                .destination_access = .{ .indirect_command_read = true, .shader_read = true },
            });
            command_buffer.bufferBarrier(scene_data.draw_indirect_count_buffer, .{
                .source_stage = .{ .compute_shader = true },
                .source_access = .{ .shader_write = true },
                .destination_stage = .{ .draw_indirect = true },
                .destination_access = .{ .indirect_command_read = true },
            });
        }

        //Directional Light Shadow pass #1
        {
            //This should use a non-culled draw command buffer, but currently culling is not enabled so this
            //should work for now

            command_buffer.imageBarrier(self.shadow_image, .{
                .source_stage = .{ .all_commands = true },
                .source_access = .{},
                .destination_stage = .{ .color_attachment_output = true },
                .destination_access = .{ .color_attachment_write = true },
                .destination_layout = .attachment_optimal,
            });

            command_buffer.beginRenderPass(
                0,
                0,
                self.shadow_image.width,
                self.shadow_image.height,
                &.{},
                .{
                    .image = &self.shadow_image,
                    .clear = .{ .depth = 0 },
                },
            );
            defer command_buffer.endRenderPass();

            command_buffer.setViewport(
                0,
                @as(f32, @floatFromInt(self.shadow_image.height)),
                @as(f32, @floatFromInt(self.shadow_image.width)),
                -@as(f32, @floatFromInt(self.shadow_image.height)),
                0,
                1,
            );
            command_buffer.setScissor(
                0,
                0,
                self.shadow_image.width,
                self.shadow_image.height,
            );
            command_buffer.setGraphicsPipeline(self.shadow_pipeline);
            command_buffer.setIndexBuffer(self.index_buffer, .u32);
            command_buffer.setPushData(DepthPassPushConstants, .{
                .view_projection = shadow_view_projection.data,
            });

            command_buffer.drawIndexedIndirectCount(
                scene_data.draw_indirect_buffer,
                0,
                @sizeOf(DrawCommand),
                scene_data.draw_indirect_count_buffer,
                0,
                scene_data.static_draw_count + scene_data.dynamic_draw_count,
            );
        }

        //Depth pass #1
        {
            command_buffer.imageBarrier(self.depth_image, .{
                .source_stage = .{ .all_commands = true },
                .source_access = .{},
                .destination_stage = .{ .color_attachment_output = true },
                .destination_access = .{ .color_attachment_write = true },
                .destination_layout = .attachment_optimal,
            });

            command_buffer.beginRenderPass(
                0,
                0,
                self.depth_image.width,
                self.depth_image.height,
                &.{},
                .{
                    .image = &self.depth_image,
                    .clear = .{ .depth = 0 },
                },
            );
            defer command_buffer.endRenderPass();

            command_buffer.setViewport(
                0,
                @as(f32, @floatFromInt(self.depth_image.height)),
                @as(f32, @floatFromInt(self.depth_image.width)),
                -@as(f32, @floatFromInt(self.depth_image.height)),
                0,
                1,
            );
            command_buffer.setScissor(0, 0, self.depth_image.width, self.depth_image.height);
            command_buffer.setGraphicsPipeline(self.depth_pipeline);
            command_buffer.setIndexBuffer(self.index_buffer, .u32);
            command_buffer.setPushData(DepthPassPushConstants, .{
                .view_projection = view_projection.data,
            });

            GraphicsContext.self.vkd.cmdWriteTimestamp2(command_buffer.handle, vk.PipelineStageFlags2{
                .top_of_pipe_bit = true,
            }, self.timeline_query_pool, 0);

            command_buffer.drawIndexedIndirectCount(
                scene_data.draw_indirect_buffer,
                0,
                @sizeOf(DrawCommand),
                scene_data.draw_indirect_count_buffer,
                0,
                scene_data.static_draw_count + scene_data.dynamic_draw_count,
            );

            GraphicsContext.self.vkd.cmdWriteTimestamp2(command_buffer.handle, vk.PipelineStageFlags2{
                .bottom_of_pipe_bit = true,
            }, self.timeline_query_pool, 1);
        }

        //Depth reduce
        {
            command_buffer.imageBarrier(self.depth_image, .{
                .source_stage = .{ .late_fragment_tests = true },
                .source_access = .{ .depth_attachment_write = true },
                .destination_stage = .{ .compute_shader = true },
                .destination_access = .{ .shader_read = true },
                .source_layout = .attachment_optimal,
                .destination_layout = .shader_read_only_optimal,
            });

            command_buffer.imageBarrier(self.depth_pyramid, .{
                .source_stage = .{ .compute_shader = true },
                .source_access = .{ .shader_read = true },
                .destination_stage = .{ .compute_shader = true },
                .destination_access = .{ .shader_write = true },
                .source_layout = .general,
                .destination_layout = .general,
            });

            command_buffer.setComputePipeline(self.depth_reduce_pipeline);

            for (self.depth_pyramid_levels, 0..) |_, i| {
                const pyramid_level_width: u32 = @max(1, self.depth_pyramid.width >> @as(u5, @intCast(i)));
                const pyramid_level_height: u32 = @max(1, self.depth_pyramid.height >> @as(u5, @intCast(i)));

                command_buffer.setPushData(DepthReducePushData, .{
                    .image_size = .{
                        @as(f32, @floatFromInt(pyramid_level_width)),
                        @as(f32, @floatFromInt(pyramid_level_height)),
                    },
                    .image_index = @as(u32, @intCast(i)),
                });
                command_buffer.computeDispatch(pyramid_level_width, pyramid_level_height, 1);

                command_buffer.imageBarrier(self.depth_pyramid, .{
                    .layer = 0,
                    .source_stage = .{ .compute_shader = true },
                    .source_access = .{ .shader_write = true },
                    .destination_stage = .{ .compute_shader = true },
                    .destination_access = .{ .shader_read = true },
                    .source_layout = .general,
                    .destination_layout = .general,
                });
            }
        }

        //Post depth per instance cull #1
        {
            command_buffer.bufferBarrier(scene_data.draw_indirect_buffer, .{
                .source_stage = .{ .draw_indirect = true, .vertex_shader = true },
                .source_access = .{ .indirect_command_read = true, .shader_read = true },
                .destination_stage = .{ .compute_shader = true },
                .destination_access = .{ .shader_write = true, .shader_read = true },
            });

            command_buffer.bufferBarrier(scene_data.post_depth_cull_dispatch_buffer, .{
                .source_stage = .{ .compute_shader = true },
                .source_access = .{ .shader_write = true },
                .destination_stage = .{ .compute_shader = true },
                .destination_access = .{ .shader_read = true },
            });

            command_buffer.setComputePipeline(self.post_depth_cull_pipeline);
            command_buffer.setPushData(PostDepthCullPushConstants, .{ .post_depth_draw_command_offset = scene_data.post_depth_draw_command_offset });
            //Use dispatch indirect to set count in pre-depth cull instead of conservatively
            command_buffer.computeDispatch(scene_data.static_draw_count + scene_data.dynamic_draw_count, 1, 1);

            // command_buffer.computeDispatchIndirect(scene_data.post_depth_cull_dispatch_buffer, 0);

            command_buffer.bufferBarrier(scene_data.draw_indirect_buffer, .{
                .source_stage = .{ .compute_shader = true },
                .source_access = .{ .shader_write = true },
                .destination_stage = .{ .draw_indirect = true, .vertex_shader = true },
                .destination_access = .{ .indirect_command_read = true, .shader_read = true },
            });

            command_buffer.bufferBarrier(scene_data.draw_indirect_count_buffer, .{
                .source_stage = .{ .compute_shader = true },
                .source_access = .{ .shader_write = true },
                .destination_stage = .{ .draw_indirect = true },
                .destination_access = .{ .indirect_command_read = true },
            });
        }

        //Deferred Color Pass
        {}

        //Forward Color Pass
        {
            //TODO: is this neccesary: I think it is *IF* we intend to observe any writes to target (such as some renderered result that runs before render3d)
            // command_buffer.imageBarrier(target, .{
            //     .source_stage = .{ .all_commands = true },
            //     .source_access = .{},
            //     .destination_stage = .{ .color_attachment_output = true },
            //     .destination_access = .{ .color_attachment_write = true },
            //     .destination_layout = .attachment_optimal,
            // });

            command_buffer.imageBarrier(self.radiance_color_image, .{
                .source_stage = .{ .compute_shader = true },
                .source_access = .{ .shader_read = true },
                .destination_stage = .{
                    .color_attachment_output = true,
                },
                .destination_access = .{
                    .color_attachment_write = true,
                },
                .destination_layout = .attachment_optimal,
            });

            command_buffer.imageBarrier(self.shadow_image, .{
                .source_stage = .{ .late_fragment_tests = true },
                .source_access = .{ .depth_attachment_write = true },
                .source_layout = vk.ImageLayout.depth_attachment_optimal,
                .destination_stage = .{ .fragment_shader = true },
                .destination_access = .{ .shader_read = true },
                .destination_layout = vk.ImageLayout.general,
            });

            command_buffer.beginRenderPass(
                0,
                0,
                self.radiance_color_image.width,
                self.radiance_color_image.height,
                &[_]graphics.CommandBuffer.Attachment{.{
                    .image = &self.radiance_color_image,
                    .clear = if (!scene_data.environment_enabled) .{ .color = .{ 0, 0, 0, 1 } } else null,
                }},
                .{
                    .image = &self.depth_image,
                    .clear = null,
                    .store = false,
                },
            );
            defer command_buffer.endRenderPass();

            command_buffer.setViewport(
                0,
                @as(f32, @floatFromInt(self.radiance_color_image.height)),
                @as(f32, @floatFromInt(self.radiance_color_image.width)),
                -@as(f32, @floatFromInt(self.radiance_color_image.height)),
                0,
                1,
            );

            command_buffer.setScissor(
                0,
                0,
                self.radiance_color_image.width,
                self.radiance_color_image.height,
            );

            command_buffer.setGraphicsPipeline(self.color_pipeline);
            command_buffer.setIndexBuffer(self.index_buffer, .u32);

            GraphicsContext.self.vkd.cmdWriteTimestamp2(command_buffer.handle, vk.PipelineStageFlags2{
                .top_of_pipe_bit = true,
            }, self.timeline_query_pool, 2);

            const use_occlusion_culling = false;

            if (use_occlusion_culling) {
                command_buffer.drawIndexedIndirectCount(
                    scene_data.draw_indirect_buffer,
                    scene_data.post_depth_draw_command_offset * @sizeOf(DrawCommand),
                    @sizeOf(DrawCommand),
                    scene_data.draw_indirect_count_buffer,
                    @sizeOf(u32),
                    scene_data.static_draw_count + scene_data.dynamic_draw_count,
                );
            } else {
                command_buffer.drawIndexedIndirectCount(
                    scene_data.draw_indirect_buffer,
                    0,
                    @sizeOf(DrawCommand),
                    scene_data.draw_indirect_count_buffer,
                    0,
                    scene_data.static_draw_count + scene_data.dynamic_draw_count,
                );
            }

            if (scene_data.environment_enabled) {
                command_buffer.setGraphicsPipeline(self.sky_pipeline);
                command_buffer.setPushData(
                    SkyPipelinePushConstants,
                    .{
                        .view_projection = projection.mul(.{ .data = .{ .{ view.data[0][0], view.data[0][1], view.data[0][2], 0 }, .{ view.data[1][0], view.data[1][1], view.data[1][2], 0 }, .{ view.data[2][0], view.data[2][1], view.data[2][2], 0 }, .{ 0, 0, 0, 1 } } }).data,
                    },
                );
                command_buffer.draw(36, 1, 0, 0);
            }

            GraphicsContext.self.vkd.cmdWriteTimestamp2(command_buffer.handle, vk.PipelineStageFlags2{
                .bottom_of_pipe_bit = true,
            }, self.timeline_query_pool, 3);
        }

        command_buffer.imageBarrier(self.radiance_color_image, .{
            .source_stage = .{
                .color_attachment_output = true,
            },
            .source_access = .{
                .color_attachment_write = true,
            },
            .source_layout = .attachment_optimal,
            .destination_stage = .{ .compute_shader = true },
            .destination_access = .{ .shader_read = true },
            .destination_layout = vk.ImageLayout.shader_read_only_optimal,
        });

        //Color resolve
        {
            //input
            command_buffer.imageBarrier(target, .{
                .source_stage = .{},
                .source_access = .{},
                .destination_stage = .{ .compute_shader = true },
                .destination_access = .{ .shader_write = true },
                .source_layout = .undefined,
                .destination_layout = .general,
            });

            self.color_resolve_pipeline.setDescriptorImageWithLayout(0, 0, self.radiance_color_image, .general);
            self.color_resolve_pipeline.setDescriptorImageWithLayout(1, 0, target, .general);

            command_buffer.setComputePipeline(self.color_resolve_pipeline);
            command_buffer.setPushData(ColorResolvePushData, .{ .exposure = self.camera.exposure });
            command_buffer.computeDispatch(target.width, target.height, 1);

            //output
            command_buffer.imageBarrier(target, .{
                .source_stage = .{ .compute_shader = true },
                .source_access = .{ .shader_write = true },
                .destination_stage = .{},
                .destination_access = .{},
                .source_layout = .general,
                .destination_layout = .attachment_optimal,
            });
        }
    }

    try GraphicsContext.self.vkd.queueSubmit2(GraphicsContext.self.graphics_queue, 1, &[_]vk.SubmitInfo2{.{
        .flags = .{},
        .wait_semaphore_info_count = 1,
        .p_wait_semaphore_infos = &[_]vk.SemaphoreSubmitInfo{.{
            .semaphore = target_aqcuired.handle,
            .value = 1,
            .stage_mask = .{
                .color_attachment_output_bit = true,
            },
            .device_index = 0,
        }},
        .command_buffer_info_count = 1,
        .p_command_buffer_infos = &[_]vk.CommandBufferSubmitInfo{.{
            .command_buffer = command_buffer.handle,
            .device_mask = 0,
        }},
        .signal_semaphore_info_count = 1,
        .p_signal_semaphore_infos = &[_]vk.SemaphoreSubmitInfo{.{
            .semaphore = target_render_finished.handle,
            .value = 1,
            .stage_mask = .{
                .color_attachment_output_bit = true,
            },
            .device_index = 0,
        }},
    }}, command_buffer.wait_fence.handle);

    //Command buffer 0 is the command buffer being encoded
    //and command buffer 1 is the command buffer being executed
    std.mem.swap(graphics.CommandBuffer, &self.command_buffers[0], &self.command_buffers[1]);
    std.mem.swap(graphics.Buffer, &scene_data.uniforms_staging_buffers[0], &scene_data.uniforms_staging_buffers[1]);
    std.mem.swap(graphics.Buffer, &scene_data.input_draw_staging_buffers[0], &scene_data.input_draw_staging_buffers[1]);
    std.mem.swap(graphics.Buffer, &scene_data.transforms_staging_buffers[0], &scene_data.transforms_staging_buffers[1]);
    std.mem.swap(graphics.Buffer, &scene_data.point_light_staging_buffers[0], &scene_data.point_light_staging_buffers[1]);
    std.mem.swap(graphics.Buffer, &scene_data.material_indices_staging_buffers[0], &scene_data.material_indices_staging_buffers[1]);
    std.mem.swap(graphics.Buffer, &scene_data.directional_light_staging_buffers[0], &scene_data.directional_light_staging_buffers[1]);

    std.mem.swap(@TypeOf(scene_data.uniforms[0]), &scene_data.uniforms[0], &scene_data.uniforms[1]);
    std.mem.swap(@TypeOf(scene_data.input_draws[0]), &scene_data.input_draws[0], &scene_data.input_draws[1]);
    std.mem.swap(@TypeOf(scene_data.transforms[0]), &scene_data.transforms[0], &scene_data.transforms[1]);
    std.mem.swap(@TypeOf(scene_data.point_lights[0]), &scene_data.point_lights[0], &scene_data.point_lights[1]);
    std.mem.swap(@TypeOf(scene_data.material_indices[0]), &scene_data.material_indices[0], &scene_data.material_indices[1]);
    std.mem.swap(@TypeOf(scene_data.directional_lights[0]), &scene_data.directional_lights[0], &scene_data.directional_lights[1]);
}

///Specifies a view into a scene
pub const View = struct {
    camera: Camera,
};

pub const AmbientLight = extern struct {
    diffuse: u32,
};

pub const DirectionalLight = extern struct {
    direction: [3]f32,
    intensity: f32,
    diffuse: u32,
    view_projection: [4][4]f32,
};

pub const PointLight = extern struct {
    position: [3]f32,
    intensity: f32,
    diffuse: u32,
};

const Scene = struct {
    ambient_light: AmbientLight,
    views: []View,

    //TODO: double buffer
    transforms_buffer: graphics.Buffer,
    transforms_staging_buffers: [2]graphics.Buffer,
    transforms: [2][][4][3]f32,

    //TODO: double buffer
    material_indices_buffer: graphics.Buffer,
    material_indices_staging_buffers: [2]graphics.Buffer,
    material_indices: [2][]u32,

    //TODO: double buffer
    input_draw_buffer: graphics.Buffer,
    input_draw_staging_buffers: [2]graphics.Buffer,
    input_draws: [2][]InputDraw,

    //The conservative volume containing all meshes
    mesh_draw_volume_min: [3]f32,
    mesh_draw_volume_max: [3]f32,

    uniforms_buffer: graphics.Buffer,
    uniforms_staging_buffers: [2]graphics.Buffer,
    //TODO: double buffer
    uniforms: [2]*ColorPassUniforms,

    draw_indirect_buffer: graphics.Buffer,
    draw_indirect_count_buffer: graphics.Buffer,
    post_depth_cull_dispatch_buffer: graphics.Buffer,

    post_depth_draw_command_offset: u32,

    //TODO: double buffer
    directional_light_buffer: graphics.Buffer,
    directional_light_staging_buffers: [2]graphics.Buffer,
    directional_lights: [2][]DirectionalLight,
    directional_light_count: u32,
    primary_directional_light_index: u32,

    //TODO: double buffer
    point_light_buffer: graphics.Buffer,
    point_light_staging_buffers: [2]graphics.Buffer,
    point_lights: [2][]PointLight,
    point_light_count: u32,

    environment_image: graphics.Image,
    environment_sampler: graphics.Sampler,
    environment_enabled: bool,

    max_draw_count: u32 = 0,

    static_draw_offset: u32 = 0,
    dynamic_draw_offset: u32 = 0,

    static_draw_count: u32 = 0,
    dynamic_draw_count: u32 = 0,
};

pub const SceneHandle = enum(u32) { _ };

///Creates a scene, statically allocating using the max parameters
///Will eventually support dynamic reallocation
pub fn createScene(
    max_view_count: u32,
    max_mesh_draw_count: u32,
    max_directional_light_count: u32,
    max_point_light_count: u32,
    environment_data: ?[]const u8,
    environment_width: ?u32,
    environment_height: ?u32,
) !SceneHandle {
    std.debug.assert(max_view_count == 1);

    const handle = @as(SceneHandle, @enumFromInt(@as(u32, @intCast(self.scenes.items.len))));

    var scene: Scene = undefined;

    const command_count = max_mesh_draw_count;

    scene.draw_indirect_buffer = try graphics.Buffer.init(command_count * @sizeOf(DrawCommand), .indirect);
    errdefer scene.draw_indirect_buffer.deinit();

    scene.draw_indirect_count_buffer = try graphics.Buffer.init(@sizeOf(u32) * 2, .indirect);
    errdefer scene.draw_indirect_count_buffer.deinit();

    scene.post_depth_cull_dispatch_buffer = try graphics.Buffer.init(@sizeOf(graphics.CommandBuffer.DispatchIndirectCommand), .indirect);
    errdefer scene.post_depth_cull_dispatch_buffer.deinit();

    try scene.post_depth_cull_dispatch_buffer.update(graphics.CommandBuffer.DispatchIndirectCommand, 0, &.{.{
        .group_count_x = 0,
        .group_count_y = 1,
        .group_count_z = 1,
    }});

    scene.post_depth_draw_command_offset = command_count / 2;

    for (&scene.uniforms_staging_buffers, 0..) |*staging_buffer, i| {
        staging_buffer.* = try graphics.Buffer.init(@sizeOf(ColorPassUniforms), .staging);

        scene.uniforms[i] = &(try staging_buffer.map(ColorPassUniforms))[0];
    }

    scene.uniforms_buffer = try graphics.Buffer.init(@sizeOf(ColorPassUniforms), .storage);
    errdefer scene.uniforms_buffer.deinit();

    scene.input_draw_buffer = try graphics.Buffer.init(command_count * @sizeOf(InputDraw), .storage);
    errdefer scene.input_draw_buffer.deinit();

    for (&scene.input_draw_staging_buffers, 0..) |*staging_buffer, i| {
        staging_buffer.* = try graphics.Buffer.init(command_count * @sizeOf(InputDraw), .staging);
        scene.input_draws[i] = try staging_buffer.map(InputDraw);
    }

    scene.transforms_buffer = try graphics.Buffer.init(command_count * @sizeOf([4][3]f32), .storage);
    errdefer scene.transforms_buffer.deinit();

    for (&scene.transforms_staging_buffers, 0..) |*staging_buffer, i| {
        staging_buffer.* = try graphics.Buffer.init(command_count * @sizeOf([4][3]f32), .staging);
        scene.transforms[i] = try staging_buffer.map([4][3]f32);
    }

    scene.material_indices_buffer = try graphics.Buffer.init(command_count * @sizeOf(u32), .storage);
    errdefer scene.material_indices_buffer.deinit();

    for (&scene.material_indices_staging_buffers, 0..) |*staging_buffer, i| {
        staging_buffer.* = try graphics.Buffer.init(command_count * @sizeOf(u32), .staging);
        scene.material_indices[i] = try staging_buffer.map(u32);
    }

    scene.mesh_draw_volume_min = .{ std.math.floatMax(f32), std.math.floatMax(f32), std.math.floatMax(f32) };
    scene.mesh_draw_volume_max = .{ std.math.floatMin(f32), std.math.floatMin(f32), std.math.floatMin(f32) };

    scene.environment_enabled = environment_data != null and environment_width != null and environment_width != null;
    scene.environment_image = if (scene.environment_enabled) try graphics.Image.initData(
        .cube,
        environment_data.?,
        environment_width.?,
        environment_height.?,
        6,
        1,
        .r8g8b8a8_srgb,
        .shader_read_only_optimal,
        .{
            .transfer_dst_bit = true,
            .sampled_bit = true,
        },
    ) else undefined;
    errdefer if (scene.environment_enabled) scene.environment_image.deinit();

    scene.environment_sampler = if (scene.environment_enabled) try graphics.Sampler.init(
        .linear,
        .linear,
        .repeat,
        .repeat,
        .repeat,
        null,
    ) else undefined;
    errdefer if (scene.environment_enabled) scene.environment_sampler.deinit();

    if (scene.environment_enabled) {
        self.sky_pipeline.setDescriptorImageSampler(0, 0, scene.environment_image, scene.environment_sampler);
    }

    scene.directional_light_buffer = try graphics.Buffer.init(max_directional_light_count * @sizeOf(DirectionalLight), .storage);
    errdefer scene.directional_light_buffer.deinit();

    for (&scene.directional_light_staging_buffers, 0..) |*staging_buffer, i| {
        staging_buffer.* = try graphics.Buffer.init(max_directional_light_count * @sizeOf(DirectionalLight), .staging);
        scene.directional_lights[i] = try staging_buffer.map(DirectionalLight);
    }

    scene.directional_light_count = 0;

    scene.point_light_buffer = try graphics.Buffer.init(max_point_light_count * @sizeOf(PointLight), .storage);
    errdefer scene.point_light_buffer.deinit();

    for (&scene.point_light_staging_buffers, 0..) |*staging_buffer, i| {
        staging_buffer.* = try graphics.Buffer.init(max_point_light_count * @sizeOf(PointLight), .staging);
        scene.point_lights[i] = try staging_buffer.map(PointLight);
    }

    scene.point_light_count = 0;

    self.color_pipeline.setDescriptorBuffer(2, 0, scene.transforms_buffer);
    self.color_pipeline.setDescriptorBuffer(3, 0, scene.material_indices_buffer);
    self.color_pipeline.setDescriptorBuffer(4, 0, scene.draw_indirect_buffer);
    self.color_pipeline.setDescriptorBuffer(7, 0, scene.point_light_buffer);
    self.color_pipeline.setDescriptorImageSampler(8, 0, scene.environment_image, scene.environment_sampler);
    self.color_pipeline.setDescriptorBuffer(10, 0, scene.uniforms_buffer);
    self.color_pipeline.setDescriptorBuffer(11, 0, scene.directional_light_buffer);

    self.depth_pipeline.setDescriptorBuffer(1, 0, scene.transforms_buffer);
    self.depth_pipeline.setDescriptorBuffer(2, 0, scene.draw_indirect_buffer);

    self.shadow_pipeline.setDescriptorBuffer(1, 0, scene.transforms_buffer);
    self.shadow_pipeline.setDescriptorBuffer(2, 0, scene.draw_indirect_buffer);

    self.cull_pipeline.setDescriptorBuffer(0, 0, scene.transforms_buffer);
    self.cull_pipeline.setDescriptorBuffer(3, 0, scene.draw_indirect_buffer);
    self.cull_pipeline.setDescriptorBuffer(4, 0, scene.draw_indirect_count_buffer);
    self.cull_pipeline.setDescriptorBuffer(5, 0, scene.input_draw_buffer);
    self.cull_pipeline.setDescriptorBuffer(6, 0, scene.post_depth_cull_dispatch_buffer);

    self.post_depth_cull_pipeline.setDescriptorBuffer(0, 0, scene.transforms_buffer);
    self.post_depth_cull_pipeline.setDescriptorBuffer(3, 0, scene.draw_indirect_buffer);
    self.post_depth_cull_pipeline.setDescriptorBuffer(4, 0, scene.draw_indirect_count_buffer);

    scene.max_draw_count = max_mesh_draw_count;
    scene.static_draw_count = 0;
    scene.dynamic_draw_count = 0;
    scene.static_draw_offset = 0;
    scene.dynamic_draw_offset = 0;

    try self.scenes.append(self.allocator, scene);

    return handle;
}

pub fn destroyScene(scene: SceneHandle) void {
    var scene_data = &self.scenes.items[@intFromEnum(scene)];

    defer scene_data.uniforms_buffer.deinit();
    defer scene_data.draw_indirect_buffer.deinit();
    defer scene_data.draw_indirect_count_buffer.deinit();
    defer scene_data.post_depth_cull_dispatch_buffer.deinit();
    defer scene_data.input_draw_buffer.deinit();
    defer scene_data.transforms_buffer.deinit();
    defer scene_data.material_indices_buffer.deinit();
    defer scene_data.point_light_buffer.deinit();
    defer scene_data.directional_light_buffer.deinit();
    defer for (&scene_data.uniforms_staging_buffers) |*staging_buffer| {
        staging_buffer.deinit();
    };
    defer for (&scene_data.input_draw_staging_buffers) |*staging_buffer| {
        staging_buffer.deinit();
    };
    defer for (&scene_data.transforms_staging_buffers) |*staging_buffer| {
        staging_buffer.deinit();
    };
    defer for (&scene_data.material_indices_staging_buffers) |*staging_buffer| {
        staging_buffer.deinit();
    };
    defer for (&scene_data.point_light_staging_buffers) |*staging_buffer| {
        staging_buffer.deinit();
    };
    defer for (&scene_data.directional_light_staging_buffers) |*staging_buffer| {
        staging_buffer.deinit();
    };
    defer if (scene_data.environment_enabled) scene_data.environment_image.deinit();
    defer if (scene_data.environment_enabled) scene_data.environment_sampler.deinit();
}

pub const SceneMeshInstance = enum(u32) { _ };

///Add a retained mesh to the scene
pub fn sceneAddMesh(
    scene: SceneHandle,
    mesh: MeshHandle,
    material: MaterialHandle,
    transform: zalgebra.Mat4x4(f32),
) !void {
    const scene_data: *Scene = &self.scenes.items[@intFromEnum(scene)];

    const draw_offset = scene_data.static_draw_offset + scene_data.static_draw_count;

    scene_data.input_draws[0][draw_offset] = .{
        .mesh_index = @intFromEnum(mesh),
    };

    scene_data.transforms[0][draw_offset] = .{
        transform.data[0][0..3].*,
        transform.data[1][0..3].*,
        transform.data[2][0..3].*,
        transform.data[3][0..3].*,
    };

    scene_data.material_indices[0][draw_offset] = @intFromEnum(material);

    const mesh_data: Mesh = self.meshes.items[@intFromEnum(mesh)];

    const bounding_min = [3]f32{
        mesh_data.bounding_box_center[0] - mesh_data.bounding_box_extents[0],
        mesh_data.bounding_box_center[1] - mesh_data.bounding_box_extents[1],
        mesh_data.bounding_box_center[2] - mesh_data.bounding_box_extents[2],
    };

    const bounding_max = [3]f32{
        mesh_data.bounding_box_center[0] + mesh_data.bounding_box_extents[0],
        mesh_data.bounding_box_center[1] + mesh_data.bounding_box_extents[1],
        mesh_data.bounding_box_center[2] + mesh_data.bounding_box_extents[2],
    };

    scene_data.static_draw_count += 1;

    scene_data.mesh_draw_volume_min[0] = @min(scene_data.mesh_draw_volume_min[0], bounding_min[0]);
    scene_data.mesh_draw_volume_min[1] = @min(scene_data.mesh_draw_volume_min[1], bounding_min[1]);
    scene_data.mesh_draw_volume_min[2] = @min(scene_data.mesh_draw_volume_min[2], bounding_min[2]);

    scene_data.mesh_draw_volume_max[0] = @max(scene_data.mesh_draw_volume_max[0], bounding_max[0]);
    scene_data.mesh_draw_volume_max[1] = @max(scene_data.mesh_draw_volume_max[1], bounding_max[1]);
    scene_data.mesh_draw_volume_max[2] = @max(scene_data.mesh_draw_volume_max[2], bounding_max[2]);

    std.log.info("scene mesh bounding volume_min = {d}, {d}, {d}", .{ scene_data.mesh_draw_volume_min[0], scene_data.mesh_draw_volume_min[1], scene_data.mesh_draw_volume_min[2] });
    std.log.info("scene mesh bounding volume_max = {d}, {d}, {d}", .{
        scene_data.mesh_draw_volume_max[0],
        scene_data.mesh_draw_volume_max[1],
        scene_data.mesh_draw_volume_max[2],
    });
}

///Push a dynamic mesh into the scene
pub fn scenePushMesh(
    scene: SceneHandle,
    mesh: MeshHandle,
    material: MaterialHandle,
    transform: zalgebra.Mat4x4(f32),
) void {
    const scene_data: *Scene = &self.scenes.items[@intFromEnum(scene)];

    scene_data.input_draws[0][scene_data.static_draw_count + scene_data.dynamic_draw_count] = .{
        .mesh_index = @intFromEnum(mesh),
    };

    scene_data.transforms[0][scene_data.static_draw_count + scene_data.dynamic_draw_count] = .{
        transform.data[0][0..3].*,
        transform.data[1][0..3].*,
        transform.data[2][0..3].*,
        transform.data[3][0..3].*,
    };

    scene_data.material_indices[0][scene_data.static_draw_count + scene_data.dynamic_draw_count] = @intFromEnum(material);

    scene_data.dynamic_draw_count += 1;
}

///Pushes a dynamic point light into the scene
pub fn scenePushPointLight(scene: SceneHandle, point_light: PointLight) void {
    const scene_data: *Scene = &self.scenes.items[@intFromEnum(scene)];

    const index = scene_data.point_light_count;

    scene_data.point_lights[0][index] = point_light;

    scene_data.point_light_count += 1;
}

///Pushes a dynamic directional light into the scene
pub fn scenePushDirectionalLight(scene: SceneHandle, directional_light: DirectionalLight) void {
    const scene_data: *Scene = &self.scenes.items[@intFromEnum(scene)];

    const index = scene_data.directional_light_count;

    scene_data.directional_lights[0][index] = directional_light;

    scene_data.directional_light_count += 1;
}

const Mesh = extern struct {
    vertex_offset: u32,
    vertex_count: u32,
    lod_offset: u32,
    lod_count: u32,
    bounding_box_center: [3]f32,
    bounding_box_extents: [3]f32,
};

const MeshLod = extern struct {
    index_offset: u32,
    index_count: u32,
};

pub const MeshHandle = enum(u32) { _ };

pub fn createMesh(
    vertex_positions: []const VertexPosition,
    vertices: []const Vertex,
    indices: []const u32,
    bounding_box_min: @Vector(3, f32),
    bounding_box_max: @Vector(3, f32),
) !MeshHandle {
    const mesh_handle = @as(u32, @intCast(self.meshes.items.len));

    const lod_offset = @as(u32, @intCast(self.mesh_lods.items.len));
    const lod_count = 1;

    try self.mesh_lods.append(self.allocator, .{
        .index_offset = @as(u32, @intCast(self.index_offset)),
        .index_count = @as(u32, @intCast(indices.len)),
    });

    try self.mesh_bounding_boxes.append(self.allocator, .{ .min = bounding_box_min, .max = bounding_box_max });

    const bounding_box_center = (bounding_box_max + bounding_box_min) / @as(@Vector(3, f32), @splat(2));
    const bounding_box_extents = @Vector(3, f32){
        bounding_box_max[0] - bounding_box_center[0],
        bounding_box_max[1] - bounding_box_center[1],
        bounding_box_max[2] - bounding_box_center[2],
    };

    try self.meshes.append(self.allocator, .{
        .vertex_offset = @as(u32, @intCast(self.vertex_position_offset)),
        .vertex_count = @as(u32, @intCast(vertices.len)),
        .lod_offset = lod_offset,
        .lod_count = lod_count,
        .bounding_box_center = bounding_box_center,
        .bounding_box_extents = bounding_box_extents,
    });

    var vertex_positions_staging_buffer = try graphics.Buffer.initData(VertexPosition, vertex_positions, .staging);
    errdefer vertex_positions_staging_buffer.deinit();

    try self.vertex_position_staging_buffers.append(self.allocator, vertex_positions_staging_buffer);

    self.vertex_position_offset += vertex_positions.len;

    var vertex_staging_buffer = try graphics.Buffer.initData(Vertex, vertices, .staging);
    errdefer vertex_staging_buffer.deinit();

    try self.vertex_staging_buffers.append(self.allocator, vertex_staging_buffer);
    self.vertex_offset += vertices.len;

    var index_staging_buffer = try graphics.Buffer.initData(u32, indices, .staging);
    errdefer index_staging_buffer.deinit();

    try self.index_staging_buffers.append(self.allocator, index_staging_buffer);
    self.index_offset += indices.len;

    self.mesh_data_changed = true;

    return @as(MeshHandle, @enumFromInt(mesh_handle));
}

pub fn getMeshBox(mesh_handle: MeshHandle) struct { min: @Vector(3, f32), max: @Vector(3, f32) } {
    const bounding_box = self.mesh_bounding_boxes.items[@intFromEnum(mesh_handle)];

    return .{ .min = bounding_box.min, .max = bounding_box.max };
}

const Material = extern struct {
    albedo_texture_index: u32,
    albedo: u32,
    metalness_texture_index: u32,
    metalness: f32,
    roughness_texture_index: u32,
    roughness: f32,
};

pub const MaterialHandle = enum(u32) { _ };

fn packUnorm4x8(v: [4]f32) u32 {
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

pub const TextureHandle = enum(u32) { _ };

pub fn createTexture(
    data: []const u8,
    width: u32,
    height: u32,
) !TextureHandle {
    const texture_handle = @as(u32, @intCast(self.texture_images.items.len)) + 1;

    var image = try Image.init(.@"2d", width, height, 1, 1, .r8g8b8a8_srgb, .shader_read_only_optimal, .{
        .transfer_dst_bit = true,
        .sampled_bit = true,
    });
    errdefer image.deinit();

    try self.texture_images.append(self.allocator, image);

    var staging_buffer = try graphics.Buffer.initData(u8, data, .staging);
    errdefer staging_buffer.deinit();

    var transfer_event = try graphics.Event.init();
    errdefer transfer_event.deinit();

    try self.image_transfer_events.append(self.allocator, transfer_event);
    try self.image_staging_buffers.append(self.allocator, staging_buffer);

    var sampler = try Sampler.init(.nearest, .nearest, .repeat, .repeat, .repeat, null);
    errdefer sampler.deinit();

    try self.texture_samplers.append(self.allocator, sampler);

    self.color_pipeline.setDescriptorImageSampler(6, texture_handle, image, sampler);

    return @as(TextureHandle, @enumFromInt(texture_handle));
}

pub fn createMaterial(
    albedo_texture: ?TextureHandle,
    albedo_color: [4]f32,
    metalness_texture: ?TextureHandle,
    metalness: f32,
    roughness_texture: ?TextureHandle,
    roughness: f32,
) !MaterialHandle {
    const material_handle = @as(u32, @intCast(self.materials.items.len));
    const albedo_handle = if (albedo_texture != null) @intFromEnum(albedo_texture.?) else 0;
    const metalness_handle = if (metalness_texture != null) @intFromEnum(metalness_texture.?) else 0;
    const roughness_handle = if (roughness_texture != null) @intFromEnum(roughness_texture.?) else 0;

    std.log.debug("Created material {}", .{material_handle});

    try self.materials.append(self.allocator, .{
        .albedo_texture_index = albedo_handle,
        .albedo = packUnorm4x8(albedo_color),
        .metalness_texture_index = metalness_handle,
        .metalness = metalness,
        .roughness_texture_index = roughness_handle,
        .roughness = roughness,
    });

    self.material_data_changed = true;

    return @as(MaterialHandle, @enumFromInt(material_handle));
}

const VertexPositionAABB = packed struct(u64) {
    ///We store 0-1 normalised floats using all 21 bits of precision
    ///0(u21) = 0.0(f32), max(u21) = 1.0(f32)
    x: u21,
    y: u21,
    z: u21,
    padding: u1 = 0,

    ///For best use of the precision, the mesh should be centered on (0, 0, 0)
    pub fn encode(pos: @Vector(3, f32), scale: f32) VertexPositionAABB {
        return .{
            //   (0.0, 1.0)       * (2^21)
            .x = @intFromFloat((pos[0] / scale) * (std.math.maxInt(u21) + 1)),
            .y = @intFromFloat((pos[1] / scale) * (std.math.maxInt(u21) + 1)),
            .z = @intFromFloat((pos[2] / scale) * (std.math.maxInt(u21) + 1)),
        };
    }
};

pub const Triangle = extern struct {
    a: VertexPosition,
    //If we can compress b and c in terms of a,
    //then we can take a trianglet that takes up 192 bits
    //and compress it to one that takes 128 bits
    b: PositionRelative,
    c: PositionRelative,

    pub const PositionRelative = packed struct(u32) {
        x: u10,
        y: u10,
        z: u10,
        padding: u2 = 0,
    };
};

pub const VertexPosition = packed struct(u64) {
    x: f16,
    y: f16,
    z: f16,
    padding: u16 = 0,
};

pub const VertexNormal = packed struct(u32) {
    x: i10,
    y: i10,
    z: i10,
    padding: u2 = 0,
};

pub const VertexNormalSpherical = packed struct(u32) {
    //theta radians = (theta/2^16)tau
    //phi radians = (phi/2^16)tau

    theta: u16,
    phi: u16,

    pub fn fromCartesian(normal: @Vector(3, f32)) VertexNormalSpherical {
        const theta = std.math.fabs(std.math.acos(normal[2]));
        const phi = std.math.fabs(std.math.atan2(f32, normal[1], normal[0]));

        const scale = @as(f32, @floatFromInt(std.math.maxInt(u16)));

        return .{
            .theta = @intFromFloat((theta / std.math.tau) * scale),
            .phi = @intFromFloat((phi / std.math.tau) * scale),
        };
    }

    pub fn toCartesian(normal: VertexNormalSpherical) @Vector(3, f32) {
        const scale = 1 / @as(f32, @floatFromInt(std.math.maxInt(u16)));

        const theta: f32 = @as(f32, @floatFromInt(normal.theta)) * scale;
        const phi: f32 = @as(f32, @floatFromInt(normal.phi)) * scale;

        const sin_theta = @sin(theta * std.math.tau);
        const cos_theta = @cos(theta * std.math.tau);
        const cos_phi = @cos(phi * std.math.tau);

        const x = sin_theta * cos_phi;
        const y = sin_theta * sin_theta;
        const z = cos_theta;

        return .{ x, y, z };
    }
};

pub const VertexUV = packed struct(u32) {
    u: f16,
    v: f16,
};

pub const VertexColor = u32;

pub const Vertex = extern struct {
    normal: VertexNormal,
    color: VertexColor,
    uv: VertexUV,
};

pub const Statistics = struct {
    vertex_shader_invocations: u32,
    fragment_shader_invocations: u32,
    depth_prepass_time: u64,
    geometry_pass_time: u64,
};

pub fn getStatistics() Statistics {
    return self.statistics;
}

const Renderer3D = @This();
const std = @import("std");
const graphics = @import("../graphics.zig");
const GraphicsContext = graphics.Context;
const Image = graphics.Image;
const Sampler = graphics.Sampler;
const vk = graphics.vulkan;
const zalgebra = @import("zalgebra");
const options = @import("options");
