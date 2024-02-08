const MeshPipelinePushData = extern struct {
    projection: [4][4]f32,
    texture_index: u32,
};

pub fn renderToGraph(
    graph: *quanta.rendering.graph.Builder,
    draw_data: *const imgui.ImDrawData,
    ///The output color attachment to render to
    target: quanta.rendering.graph.Image,
) void {
    const font_atlas = blk: {
        const FontInit = struct {
            var initialized: bool = false;
        };

        const io: *imgui.ImGuiIO = @as(*imgui.ImGuiIO, @ptrCast(imgui.igGetIO()));

        var pixel_pointer: [*c]u8 = undefined;
        var width: c_int = 0;
        var height: c_int = 0;
        var out_bytes_per_pixel: c_int = 0;

        imgui.ImFontAtlas_GetTexDataAsRGBA32(
            io.Fonts,
            &pixel_pointer,
            &width,
            &height,
            &out_bytes_per_pixel,
        );

        const image_contents_size: usize = @as(usize, @intCast(width)) * @as(usize, @intCast(height)) * @sizeOf(u32);

        const font_image = graph.createImage(
            @src(),
            .r8g8b8a8_srgb,
            @intCast(width),
            @intCast(height),
            1,
        );

        io.Fonts.*.TexID = @as(*anyopaque, @ptrFromInt(font_image.id));

        const inputs = graph.beginTransferPass(@src(), .{
            .font_image = font_image,
        });

        //TODO: how do we handle resources who's data does not change
        //We *could* memcmp the inputs if we really want to but that's just silly(?)
        if (!FontInit.initialized) {
            graph.updateImage(
                inputs.font_image,
                0,
                u8,
                pixel_pointer[0..image_contents_size],
            );

            FontInit.initialized = true;
        }

        break :blk graph.endTransferPass(inputs);
    };

    //upload
    //Could be it's own function (but that shouldn't be neccessary)
    const updated_buffers = blk: {
        const max_vertices = 50_000;
        const max_indices = 50_000;

        //Notice how these resources are local to this scope. We pass these resources as inputs to passes, so these variable names needn't be referenced
        const vertex_buffer = graph.createBuffer(@src(), max_vertices * @sizeOf(imgui.ImDrawVert));
        const index_buffer = graph.createBuffer(@src(), max_indices * @sizeOf(u16));

        const inputs = graph.beginTransferPass(@src(), .{
            .vertex_buffer = vertex_buffer,
            .index_buffer = index_buffer,
        });

        var vertex_offset: usize = 0;
        var index_offset: usize = 0;

        for (0..@intCast(draw_data.CmdListsCount)) |command_list_index| {
            const command_list: *imgui.ImDrawList = draw_data.CmdLists[command_list_index];

            const vertices: []const imgui.ImDrawVert = command_list.VtxBuffer.Data[0..@as(usize, @intCast(command_list.VtxBuffer.Size))];
            const indices: []const u16 = command_list.IdxBuffer.Data[0..@as(usize, @intCast(command_list.IdxBuffer.Size))];

            graph.updateBuffer(
                inputs.vertex_buffer,
                vertex_offset * @sizeOf(imgui.ImDrawVert),
                imgui.ImDrawVert,
                vertices,
            );

            graph.updateBuffer(
                inputs.index_buffer,
                index_offset * @sizeOf(u16),
                u16,
                indices,
            );

            vertex_offset += vertices.len;
            index_offset += indices.len;
        }

        //output my inputs
        break :blk graph.endTransferPass(inputs);
    };

    //Drawing
    {
        const pipeline = graph.createRasterPipeline(
            @src(),
            .{ .code = @alignCast(@embedFile("mesh.vert.spv")) },
            .{ .code = @alignCast(@embedFile("mesh.frag.spv")) },
            .{
                .attachment_formats = &.{
                    graph.imageGetFormat(target),
                },
            },
            @sizeOf(MeshPipelinePushData),
        );

        const target_width = graph.imageGetWidth(target);
        const target_height = graph.imageGetHeight(target);

        const inputs = graph.beginRasterPass(
            @src(),
            &.{
                .{
                    .image = target,
                    .clear = .{ .color = .{ 0, 1, 0, 1 } },
                },
            },
            0,
            0,
            target_width,
            target_height,
            .{
                .updated_buffers = updated_buffers,
                .font_atlas = font_atlas,
            },
        );

        graph.setRasterPipeline(pipeline);
        graph.setRasterPipelineResourceBuffer(
            pipeline,
            0,
            0,
            inputs.updated_buffers.vertex_buffer,
        );

        const font_sampler = graph.createSampler(@src(), .{
            .min_filter = .linear,
            .mag_filter = .linear,
        });

        //Do we really need bindless for this?
        graph.setRasterPipelineImageSampler(
            pipeline,
            1,
            0,
            inputs.font_atlas.font_image,
            font_sampler,
        );

        graph.setViewport(
            0,
            @as(f32, @floatFromInt(target_height)),
            @as(f32, @floatFromInt(target_width)),
            -@as(f32, @floatFromInt(target_height)),
            0,
            1,
        );

        graph.setScissor(
            0,
            0,
            target_width,
            target_height,
        );

        graph.setIndexBuffer(inputs.updated_buffers.index_buffer, .u16);

        var ortho = [4][4]f32{
            .{ 2.0, 0.0, 0.0, 0.0 },
            .{ 0.0, -2.0, 0.0, 0.0 },
            .{ 0.0, 0.0, -1.0, 0.0 },
            .{ -1.0, 1.0, 0.0, 1.0 },
        };
        ortho[0][0] /= @as(f32, @floatFromInt(target_width));
        ortho[1][1] /= @as(f32, @floatFromInt(target_height));

        var vertex_offset: usize = 0;
        var index_offset: usize = 0;

        for (0..@intCast(draw_data.CmdListsCount)) |command_list_index| {
            const command_list: *imgui.ImDrawList = draw_data.CmdLists[command_list_index];

            const vertices: []imgui.ImDrawVert = command_list.VtxBuffer.Data[0..@as(usize, @intCast(command_list.VtxBuffer.Size))];
            const indices: []u16 = command_list.IdxBuffer.Data[0..@as(usize, @intCast(command_list.IdxBuffer.Size))];

            for (0..@intCast(command_list.CmdBuffer.Size)) |command_index| {
                const command: imgui.ImDrawCmd = command_list.CmdBuffer.Data[command_index];

                graph.setPushData(MeshPipelinePushData, .{
                    .projection = ortho,
                    .texture_index = 1,
                });

                const window_width = @as(f32, @floatFromInt(target_width));
                const window_height = @as(f32, @floatFromInt(target_height));

                graph.setScissor(
                    @as(u32, @intFromFloat(@max(command.ClipRect.x, 0))),
                    @as(u32, @intFromFloat(@max(command.ClipRect.y, 0))),
                    @as(u32, @intFromFloat(@min(command.ClipRect.z, window_width))) -| @as(u32, @intFromFloat(@max(command.ClipRect.x, 0))),
                    @as(u32, @intFromFloat(@min(command.ClipRect.w, window_height))) -| @as(u32, @intFromFloat(@max(command.ClipRect.y, 0))),
                );

                graph.drawIndexed(
                    command.ElemCount,
                    1,
                    @as(u32, @intCast(index_offset)) + command.IdxOffset,
                    @as(i32, @intCast(vertex_offset)) + @as(i32, @intCast(command.VtxOffset)),
                    0,
                );
            }

            vertex_offset += vertices.len;
            index_offset += indices.len;
        }

        _ = graph.endRasterPass(.{});
    }
}

const RendererGui = @This();
const std = @import("std");
const quanta = @import("quanta");
const zalgebra = quanta.math.zalgebra;
const imgui = @import("../imgui/cimgui.zig");
