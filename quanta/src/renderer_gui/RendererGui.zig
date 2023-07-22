const RendererGui = @This();

const std = @import("std");
const graphics = @import("../graphics.zig");
const window = @import("../windowing.zig").window;
const zalgebra = @import("../math.zig").zalgebra;
const imgui = @import("../imgui.zig").cimgui;

var self: @This() = .{};

const RectanglePipelinePushData = extern struct {
    render_target_width: f32,
    render_target_height: f32,
    rectangle: Rectangle,
};

const MeshPipelinePushData = extern struct {
    projection: [4][4]f32,
    texture_index: u32,
};

const Texture = struct {
    image: graphics.Image,
    sampler: graphics.Sampler,
};

allocator: std.mem.Allocator = undefined,
rectangle_pipeline: graphics.GraphicsPipeline = undefined,
mesh_pipeline: graphics.GraphicsPipeline = undefined,
command_buffers: [2]graphics.CommandBuffer = undefined,
color_target_image: *const graphics.Image = undefined,
rectangles: std.ArrayListUnmanaged(Rectangle) = .{},
scissors: std.ArrayListUnmanaged([4]u16) = .{},
rectangles_buffer: graphics.Buffer = undefined,
vertices_buffer: graphics.Buffer = undefined,
vertices_staging_buffers: [2]graphics.Buffer = undefined,
indices_buffer: graphics.Buffer = undefined,
indices_staging_buffers: [2]graphics.Buffer = undefined,
staging_vertices: [2][]imgui.ImDrawVert = undefined,
staging_indices: [2][]u16 = undefined,
textures: std.ArrayListUnmanaged(Texture) = .{},
first_frame: bool = false,

pub const TextureHandle = enum(u32) { null = 0, _ };

pub fn createTexture(data: []const u8, width: u32, height: u32) !TextureHandle {
    const handle = @as(TextureHandle, @enumFromInt(@as(u32, @intCast(self.textures.items.len + 1))));

    var image = try graphics.Image.initData(.@"2d", data, width, height, 1, 1, .r8g8b8a8_srgb, .shader_read_only_optimal, .{
        .transfer_dst_bit = true,
        .sampled_bit = true,
    });
    errdefer image.deinit();

    var sampler = try graphics.Sampler.init(.nearest, .nearest, .repeat, .repeat, .repeat, null);
    errdefer sampler.deinit();

    try self.textures.append(self.allocator, .{
        .image = image,
        .sampler = sampler,
    });

    self.mesh_pipeline.setDescriptorImageSampler(1, @intFromEnum(handle) - 1, image, sampler);

    return handle;
}

pub fn init(allocator: std.mem.Allocator, swapchain: graphics.Swapchain) !void {
    self.allocator = allocator;
    self.first_frame = true;
    // self.rectangle_pipeline = try graphics.GraphicsPipeline.init(
    //     allocator,
    //     .{
    //         .color_attachment_formats = &.{ swapchain.surface_format.format },
    //         .vertex_shader_binary = @alignCast(4, @embedFile("spirv/rectangle.vert.spv")),
    //         .fragment_shader_binary = @alignCast(4, @embedFile("spirv/rectangle.frag.spv")),
    //         .depth_state = .{
    //             .write_enabled = false,
    //             .test_enabled = false,
    //             .compare_op = .greater,
    //         },
    //         .rasterisation_state = .{
    //             .polygon_mode = .fill,
    //         },
    //     },
    //     null,
    //     RectanglePipelinePushData,
    // );
    // errdefer self.rectangle_pipeline.deinit(self.allocator);

    self.mesh_pipeline = try graphics.GraphicsPipeline.init(
        allocator,
        .{
            .color_attachment_formats = &.{swapchain.surface_format.format},
            .vertex_shader_binary = @alignCast(@embedFile("renderer_gui_mesh_vert.spv")),
            .fragment_shader_binary = @alignCast(@embedFile("renderer_gui_mesh_frag.spv")),
            .depth_state = .{
                .write_enabled = false,
                .test_enabled = false,
                .compare_op = .greater,
            },
            .rasterisation_state = .{
                .polygon_mode = .fill,
            },
            .blend_state = .{
                .blend_enabled = true,
            },
        },
        null,
        MeshPipelinePushData,
    );
    errdefer self.mesh_pipeline.deinit(self.allocator);

    for (&self.command_buffers) |*command_buffer| {
        command_buffer.* = try graphics.CommandBuffer.init(.graphics);
    }

    errdefer for (&self.command_buffers) |*command_buffer| {
        command_buffer.deinit();
    };

    self.rectangles_buffer = try graphics.Buffer.init(4096 * @sizeOf(Rectangle), .storage);
    errdefer self.rectangles_buffer.deinit();

    // self.rectangle_pipeline.setDescriptorBuffer(0, 0, self.rectangles_buffer);

    const max_vertices = 50_000;
    const max_indices = 50_000;

    self.vertices_buffer = try graphics.Buffer.init(max_vertices * @sizeOf(Vertex), .storage);
    errdefer self.vertices_buffer.deinit();

    for (&self.vertices_staging_buffers, 0..) |*staging_buffer, i| {
        staging_buffer.* = try graphics.Buffer.init(max_vertices * @sizeOf(Vertex), .staging);
        self.staging_vertices[i] = try staging_buffer.map(imgui.ImDrawVert);
    }

    errdefer for (&self.vertices_staging_buffers) |*staging_buffer| {
        staging_buffer.deinit();
    };

    self.mesh_pipeline.setDescriptorBuffer(0, 0, self.vertices_buffer);

    for (&self.indices_staging_buffers, 0..) |*staging_buffer, i| {
        staging_buffer.* = try graphics.Buffer.init(max_indices * @sizeOf(u16), .staging);
        self.staging_indices[i] = try staging_buffer.map(u16);
    }

    errdefer for (&self.indices_staging_buffers) |*staging_buffer| {
        staging_buffer.deinit();
    };

    self.indices_buffer = try graphics.Buffer.init(max_indices * @sizeOf(u16), .index);
    errdefer self.indices_buffer.deinit();

    try initImGui();
    errdefer deinitImGui();
}

fn initImGui() !void {
    const io: *imgui.ImGuiIO = @as(*imgui.ImGuiIO, @ptrCast(imgui.igGetIO()));

    var pixel_pointer: [*c]u8 = undefined;
    var width: c_int = 0;
    var height: c_int = 0;
    var out_bytes_per_pixel: c_int = 0;

    imgui.ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixel_pointer, &width, &height, &out_bytes_per_pixel);

    const font_texture = try createTexture(pixel_pointer[0 .. @as(u32, @intCast(width)) * @as(u32, @intCast(height)) * @sizeOf(u32)], @as(u32, @intCast(width)), @as(u32, @intCast(height)));

    io.Fonts.*.TexID = @as(*anyopaque, @ptrFromInt(@intFromEnum(font_texture)));
}

fn deinitImGui() void {}

pub fn deinit() void {
    // defer self.rectangle_pipeline.deinit(self.allocator);
    defer self.mesh_pipeline.deinit(self.allocator);
    defer for (&self.command_buffers) |*command_buffer| {
        command_buffer.deinit();
    };
    defer self.rectangles_buffer.deinit();
    defer self.rectangles.deinit(self.allocator);
    defer self.vertices_buffer.deinit();
    defer for (&self.vertices_staging_buffers) |*staging_buffer| {
        staging_buffer.deinit();
    };
    defer self.indices_buffer.deinit();
    defer for (&self.indices_staging_buffers) |*staging_buffer| {
        staging_buffer.deinit();
    };
    defer self.scissors.deinit(self.allocator);
    defer self.textures.deinit(self.allocator);
    defer for (self.textures.items) |*texture| {
        defer texture.image.deinit();
        defer texture.sampler.deinit();
    };
    defer deinitImGui();
}

pub fn begin(color_target_image: *const graphics.Image) void {
    self.color_target_image = color_target_image;
    self.rectangles.clearRetainingCapacity();
    self.scissors.clearRetainingCapacity();
}

pub const Vertex = extern struct {
    position: [2]f32,
    uv: [2]f32,
    color: u32,
};

///All coordinates are 16 bit "pixel" coordinates, which are local or global depending
///on the Pipeline
pub const Rectangle = extern struct {
    x: u16,
    y: u16,
    width: u16,
    height: u16,
    color: u32,
    border_radius: f32 = 0,
};

pub fn drawRectangle(rectangle: Rectangle) void {
    self.rectangles.append(self.allocator, rectangle) catch unreachable;
}

pub fn renderImGuiDrawData(draw_data: *const imgui.ImDrawData) !void {
    if (draw_data.CmdListsCount == 0 or !draw_data.Valid) return;

    const command_buffer = &self.command_buffers[0];

    {
        try command_buffer.begin();
        defer command_buffer.end();

        //Upload
        {
            {
                std.debug.assert(draw_data.CmdListsCount != 0);

                var vertex_offset: usize = 0;
                var index_offset: usize = 0;

                //no need to map every frame
                const staging_vertices = self.staging_vertices[0];
                const staging_indices = self.staging_indices[0];

                for (0..@intCast(draw_data.CmdListsCount)) |command_list_index| {
                    const command_list: *imgui.ImDrawList = draw_data.CmdLists[command_list_index];

                    const vertices: []imgui.ImDrawVert = command_list.VtxBuffer.Data[0..@as(usize, @intCast(command_list.VtxBuffer.Size))];
                    const indices: []u16 = command_list.IdxBuffer.Data[0..@as(usize, @intCast(command_list.IdxBuffer.Size))];

                    @memcpy(staging_vertices[vertex_offset .. vertex_offset + vertices.len], vertices);
                    @memcpy(staging_indices[index_offset .. index_offset + indices.len], indices);

                    vertex_offset += vertices.len;
                    index_offset += indices.len;
                }

                command_buffer.copyBuffer(
                    self.vertices_staging_buffers[0],
                    0,
                    vertex_offset * @sizeOf(imgui.ImDrawVert),
                    self.vertices_buffer,
                    0,
                    vertex_offset * @sizeOf(imgui.ImDrawVert),
                );

                command_buffer.copyBuffer(
                    self.indices_staging_buffers[0],
                    0,
                    index_offset * @sizeOf(u16),
                    self.indices_buffer,
                    0,
                    index_offset * @sizeOf(u16),
                );

                command_buffer.bufferBarrier(self.vertices_buffer, .{
                    .source_stage = .{
                        .copy = true,
                    },
                    .source_access = .{ .transfer_write = true },
                    .destination_stage = .{
                        .vertex_shader = true,
                    },
                    .destination_access = .{ .shader_read = true },
                });

                command_buffer.bufferBarrier(self.indices_buffer, .{
                    .source_stage = .{ .copy = true },
                    .source_access = .{ .transfer_write = true },
                    .destination_stage = .{ .index_input = true },
                    .destination_access = .{ .index_read = true },
                });
            }
        }

        //#Color Pass 1: main
        {
            command_buffer.beginRenderPass(0, 0, window.getWidth(), window.getHeight(), &[_]graphics.CommandBuffer.Attachment{.{
                .image = self.color_target_image,
            }}, null);
            defer command_buffer.endRenderPass();

            command_buffer.setGraphicsPipeline(self.mesh_pipeline);
            command_buffer.setViewport(0, @as(f32, @floatFromInt(window.getHeight())), @as(f32, @floatFromInt(window.getWidth())), -@as(f32, @floatFromInt(window.getHeight())), 0, 1);
            command_buffer.setScissor(0, 0, window.getWidth(), window.getHeight());

            // const projection = zalgebra.orthographic(0, @intToFloat(f32, window.getWidth()), 0, @intToFloat(f32, window.getHeight()), 0, 1);

            var ortho = [4][4]f32{
                .{ 2.0, 0.0, 0.0, 0.0 },
                .{ 0.0, -2.0, 0.0, 0.0 },
                .{ 0.0, 0.0, -1.0, 0.0 },
                .{ -1.0, 1.0, 0.0, 1.0 },
            };
            ortho[0][0] /= @as(f32, @floatFromInt(window.getWidth()));
            ortho[1][1] /= @as(f32, @floatFromInt(window.getHeight()));

            command_buffer.setIndexBuffer(self.indices_buffer, .u16);

            var vertex_offset: usize = 0;
            var index_offset: usize = 0;

            for (0..@intCast(draw_data.CmdListsCount)) |command_list_index| {
                const command_list: *imgui.ImDrawList = draw_data.CmdLists[command_list_index];

                const vertices: []imgui.ImDrawVert = command_list.VtxBuffer.Data[0..@as(usize, @intCast(command_list.VtxBuffer.Size))];
                const indices: []u16 = command_list.IdxBuffer.Data[0..@as(usize, @intCast(command_list.IdxBuffer.Size))];

                for (0..@intCast(command_list.CmdBuffer.Size)) |command_index| {
                    const command: imgui.ImDrawCmd = command_list.CmdBuffer.Data[command_index];

                    command_buffer.setPushData(MeshPipelinePushData, .{
                        .projection = ortho,
                        .texture_index = @as(u32, @intCast(@intFromPtr(command.TextureId))),
                    });

                    command_buffer.setScissor(@as(u32, @intFromFloat(@max(command.ClipRect.x, 0))), @as(u32, @intFromFloat(@max(command.ClipRect.y, 0))), @as(u32, @intFromFloat(@min(command.ClipRect.z, @as(f32, @floatFromInt(window.getWidth()))))) - @as(u32, @intFromFloat(@max(command.ClipRect.x, 0))), @as(u32, @intFromFloat(@min(command.ClipRect.w, @as(f32, @floatFromInt(window.getHeight()))))) - @as(u32, @intFromFloat(@max(command.ClipRect.y, 0))));
                    command_buffer.drawIndexed(command.ElemCount, 1, @as(u32, @intCast(index_offset)) + command.IdxOffset, @as(i32, @intCast(vertex_offset)) + @as(i32, @intCast(command.VtxOffset)), 0);
                }

                vertex_offset += vertices.len;
                index_offset += indices.len;
            }
        }
    }

    if (!self.first_frame) {
        self.command_buffers[1].wait_fence.wait();
        self.command_buffers[1].wait_fence.reset();
    }

    self.first_frame = false;

    //quite slow but will do for now
    try command_buffer.submit(command_buffer.wait_fence);

    std.mem.swap(graphics.CommandBuffer, &self.command_buffers[0], &self.command_buffers[1]);
    std.mem.swap(graphics.Buffer, &self.vertices_staging_buffers[0], &self.vertices_staging_buffers[1]);
    std.mem.swap(graphics.Buffer, &self.indices_staging_buffers[0], &self.indices_staging_buffers[1]);
    std.mem.swap([]imgui.ImDrawVert, &self.staging_vertices[0], &self.staging_vertices[1]);
    std.mem.swap([]u16, &self.staging_indices[0], &self.staging_indices[1]);
}
