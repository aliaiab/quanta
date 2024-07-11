const CommandBuffer = @This();

const std = @import("std");
const vk = @import("vulkan");
const Context = @import("Context.zig");
const ComputePipeline = @import("ComputePipeline.zig");
const GraphicsPipeline = @import("GraphicsPipeline.zig");
const Semaphore = @import("Semaphore.zig");
const Buffer = @import("Buffer.zig");
const Image = @import("Image.zig");
const Fence = @import("Fence.zig");
const Event = @import("Event.zig");

pub const Queue = enum {
    graphics,
    compute,
    transfer,
};

handle: vk.CommandBuffer,
queue: Queue,
pipeline_layout: vk.PipelineLayout,
wait_fence: Fence,
local_size_x: u32,
local_size_y: u32,
local_size_z: u32,
is_graphics_pipeline: bool,
is_render_pass_instance: bool,

pub fn init(queue: Queue) !CommandBuffer {
    var self: CommandBuffer = .{
        .handle = .null_handle,
        .queue = queue,
        .pipeline_layout = .null_handle,
        .wait_fence = .{
            .handle = .null_handle,
        },
        .local_size_x = 0,
        .local_size_y = 0,
        .local_size_z = 0,
        .is_graphics_pipeline = false,
        .is_render_pass_instance = false,
    };

    self.wait_fence = try Fence.init();
    errdefer self.wait_fence.deinit();

    const pool = switch (self.queue) {
        .graphics => Context.self.graphics_command_pool,
        .compute => Context.self.compute_command_pool,
        .transfer => Context.self.transfer_command_pool,
    };

    try Context.self.vkd.allocateCommandBuffers(Context.self.device, &.{
        .command_pool = pool,
        .level = .primary,
        .command_buffer_count = 1,
    }, @as([*]vk.CommandBuffer, @ptrCast(&self.handle)));

    return self;
}

pub fn deinit(self: *CommandBuffer) void {
    defer self.* = undefined;

    const pool = switch (self.queue) {
        .graphics => Context.self.graphics_command_pool,
        .compute => Context.self.compute_command_pool,
        .transfer => Context.self.transfer_command_pool,
    };

    defer self.wait_fence.deinit();
    defer Context.self.vkd.freeCommandBuffers(Context.self.device, pool, 1, @as([*]vk.CommandBuffer, @ptrCast(&self.handle)));
}

pub fn begin(self: CommandBuffer) !void {
    try Context.self.vkd.resetCommandBuffer(self.handle, .{});
    try Context.self.vkd.beginCommandBuffer(self.handle, &.{
        .flags = .{
            .one_time_submit_bit = true,
        },
        .p_inheritance_info = null,
    });
}

pub fn end(self: CommandBuffer) void {
    Context.self.vkd.endCommandBuffer(self.handle) catch unreachable;
}

//Mabye not good idea to do all this work automatically, but ehh it's convenient and may improve driver/gpu
//performance enough that it's well worth it
fn placePendingBarriers(self: CommandBuffer) void {
    if (self.consecutive_memory_barrier_count == 0 or
        self.consecutive_image_barrier_count == 0)
    {
        return;
    }

    //the whole point of this function is to eventually batch all calls to vkImage/Buffer/Memory barrier to
    //reduce dispatch overhead and allow the driver to optimise the barrier itself
    for (self.consecutive_memory_barriers[0..self.consecutive_memory_barrier_count]) |memory_barrier| {
        self.memoryBarrier(memory_barrier);
    }

    for (self.consecutive_image_barrier_images[0..self.consecutive_image_barrier_count], 0..) |image_barrier, i| {
        self.imageBarrier(self.consecutive_image_barrier_images[i].*, image_barrier);
    }

    defer self.consecutive_memory_barrier_count = 0;
    defer self.consecutive_image_barrier_count = 0;
}

pub const PipelineStage = packed struct(u16) {
    all_commands: bool = false,
    all_graphics: bool = false,
    color_attachment_output: bool = false,
    early_fragment_tests: bool = false,
    late_fragment_tests: bool = false,
    draw_indirect: bool = false,
    index_input: bool = false,
    vertex_shader: bool = false,
    fragment_shader: bool = false,
    compute_shader: bool = false,
    copy: bool = false,
    top_of_pipe: bool = false,
    bottom_of_pipe: bool = false,
    padding: u3 = 0,
};

inline fn getVkPipelineStage(pipeline_stage: PipelineStage) vk.PipelineStageFlags2 {
    return vk.PipelineStageFlags2{
        .all_commands_bit = pipeline_stage.all_commands,
        .color_attachment_output_bit = pipeline_stage.color_attachment_output,
        .early_fragment_tests_bit = pipeline_stage.early_fragment_tests,
        .late_fragment_tests_bit = pipeline_stage.late_fragment_tests,
        .draw_indirect_bit = pipeline_stage.draw_indirect,
        .vertex_shader_bit = pipeline_stage.vertex_shader,
        .index_input_bit = pipeline_stage.index_input,
        .fragment_shader_bit = pipeline_stage.fragment_shader,
        .compute_shader_bit = pipeline_stage.compute_shader,
        .copy_bit = pipeline_stage.copy,
        .top_of_pipe_bit = pipeline_stage.top_of_pipe,
        .bottom_of_pipe_bit = pipeline_stage.bottom_of_pipe,
    };
}

pub const ResourceAccess = packed struct(u16) {
    color_attachment_read: bool = false,
    color_attachment_write: bool = false,
    depth_attachment_read: bool = false,
    depth_attachment_write: bool = false,
    shader_read: bool = false,
    shader_write: bool = false,
    shader_storage_read: bool = false,
    shader_storage_write: bool = false,
    indirect_command_read: bool = false,
    transfer_read: bool = false,
    transfer_write: bool = false,
    index_read: bool = false,
    padding: u4 = 0,
};

inline fn getVkResourceAccess(resource_access: ResourceAccess) vk.AccessFlags2 {
    return vk.AccessFlags2{
        .vertex_attribute_read_bit = false,
        .uniform_read_bit = false,
        .input_attachment_read_bit = false,
        .shader_read_bit = resource_access.shader_read,
        .shader_write_bit = resource_access.shader_write,
        .color_attachment_read_bit = resource_access.color_attachment_read,
        .color_attachment_write_bit = resource_access.color_attachment_write,
        .depth_stencil_attachment_read_bit = resource_access.depth_attachment_read,
        .depth_stencil_attachment_write_bit = resource_access.depth_attachment_write,
        .transfer_read_bit = resource_access.transfer_read,
        .transfer_write_bit = resource_access.transfer_write,
        .host_read_bit = false,
        .host_write_bit = false,
        .memory_read_bit = false,
        .memory_write_bit = false,
        .index_read_bit = resource_access.index_read,
        .shader_storage_read_bit = resource_access.shader_storage_read,
        .shader_storage_write_bit = resource_access.shader_storage_write,
        .indirect_command_read_bit = resource_access.indirect_command_read,
    };
}

pub const MemoryBarrier = packed struct {
    source_stage: PipelineStage,
    source_access: ResourceAccess,
    destination_stage: PipelineStage,
    destination_access: ResourceAccess,
};

pub fn memoryBarrier(self: CommandBuffer, barrier: MemoryBarrier) void {
    Context.self.vkd.cmdPipelineBarrier2(self.handle, &.{
        .dependency_flags = .{
            .by_region_bit = true,
        },
        .memory_barrier_count = 1,
        .p_memory_barriers = &[_]vk.MemoryBarrier2{.{
            .src_stage_mask = getVkPipelineStage(barrier.source_stage),
            .src_access_mask = getVkResourceAccess(barrier.source_access),
            .dst_stage_mask = getVkPipelineStage(barrier.destination_stage),
            .dst_access_mask = getVkResourceAccess(barrier.destination_access),
        }},
        .buffer_memory_barrier_count = 0,
        .p_buffer_memory_barriers = undefined,
        .image_memory_barrier_count = 0,
        .p_image_memory_barriers = undefined,
    });
}

pub const ImageBarrier = struct {
    layer: u32 = 0,
    source_stage: PipelineStage,
    source_access: ResourceAccess,
    source_layout: vk.ImageLayout = .undefined,
    destination_stage: PipelineStage,
    destination_access: ResourceAccess,
    destination_layout: vk.ImageLayout = .undefined,
};

pub fn imageBarrier(
    self: CommandBuffer,
    image: Image,
    barrier: ImageBarrier,
) void {
    Context.self.vkd.cmdPipelineBarrier2(self.handle, &.{
        .dependency_flags = .{
            .by_region_bit = true,
        },
        .memory_barrier_count = 0,
        .p_memory_barriers = undefined,
        .buffer_memory_barrier_count = 0,
        .p_buffer_memory_barriers = undefined,
        .image_memory_barrier_count = 1,
        .p_image_memory_barriers = @as([*]const vk.ImageMemoryBarrier2, @ptrCast(&vk.ImageMemoryBarrier2{
            .src_stage_mask = getVkPipelineStage(barrier.source_stage),
            .src_access_mask = getVkResourceAccess(barrier.source_access),
            .dst_stage_mask = getVkPipelineStage(barrier.destination_stage),
            .dst_access_mask = getVkResourceAccess(barrier.destination_access),
            .old_layout = barrier.source_layout,
            .new_layout = barrier.destination_layout,
            .src_queue_family_index = vk.QUEUE_FAMILY_IGNORED,
            .dst_queue_family_index = vk.QUEUE_FAMILY_IGNORED,
            .image = image.handle,
            .subresource_range = .{
                .aspect_mask = image.aspect_mask,
                .base_mip_level = barrier.layer,
                .level_count = vk.REMAINING_MIP_LEVELS,
                .base_array_layer = 0,
                .layer_count = vk.REMAINING_ARRAY_LAYERS,
            },
        })),
    });
}

pub fn imageBarriers(
    self: CommandBuffer,
    images: []const *const Image,
    barriers: []const ImageBarrier,
) void {
    std.debug.assert(images.len == barriers.len);

    var image_barriers: [64]vk.ImageMemoryBarrier2 = undefined;

    std.debug.assert(barriers.len <= image_barriers.len);

    for (images, barriers, image_barriers[0..barriers.len]) |image, barrier, *image_barrier| {
        image_barrier.* = .{
            .src_stage_mask = getVkPipelineStage(barrier.source_stage),
            .src_access_mask = getVkResourceAccess(barrier.source_access),
            .dst_stage_mask = getVkPipelineStage(barrier.destination_stage),
            .dst_access_mask = getVkResourceAccess(barrier.destination_access),
            .old_layout = barrier.source_layout,
            .new_layout = barrier.destination_layout,
            .src_queue_family_index = vk.QUEUE_FAMILY_IGNORED,
            .dst_queue_family_index = vk.QUEUE_FAMILY_IGNORED,
            .image = image.handle,
            .subresource_range = .{
                .aspect_mask = image.aspect_mask,
                .base_mip_level = barrier.layer,
                .level_count = vk.REMAINING_MIP_LEVELS,
                .base_array_layer = 0,
                .layer_count = vk.REMAINING_ARRAY_LAYERS,
            },
        };
    }

    Context.self.vkd.cmdPipelineBarrier2(self.handle, &.{
        .dependency_flags = .{
            .by_region_bit = true,
        },
        .memory_barrier_count = 0,
        .p_memory_barriers = undefined,
        .buffer_memory_barrier_count = 0,
        .p_buffer_memory_barriers = undefined,
        .image_memory_barrier_count = @intCast(barriers.len),
        .p_image_memory_barriers = &image_barriers,
    });
}

pub const BufferBarrier = struct {
    source_stage: PipelineStage = .{},
    source_access: ResourceAccess = .{},
    destination_stage: PipelineStage = .{},
    destination_access: ResourceAccess = .{},
};

pub fn bufferBarrier(self: CommandBuffer, buffer: Buffer, barrier: BufferBarrier) void {
    Context.self.vkd.cmdPipelineBarrier2(self.handle, &.{
        .dependency_flags = .{
            .by_region_bit = true,
            .view_local_bit = self.is_render_pass_instance,
        },
        .memory_barrier_count = 0,
        .p_memory_barriers = undefined,
        .buffer_memory_barrier_count = 1,
        .p_buffer_memory_barriers = &[_]vk.BufferMemoryBarrier2{
            .{
                .src_stage_mask = getVkPipelineStage(barrier.source_stage),
                .src_access_mask = getVkResourceAccess(barrier.source_access),
                .dst_stage_mask = getVkPipelineStage(barrier.destination_stage),
                .dst_access_mask = getVkResourceAccess(barrier.destination_access),
                .src_queue_family_index = vk.QUEUE_FAMILY_IGNORED,
                .dst_queue_family_index = vk.QUEUE_FAMILY_IGNORED,
                .buffer = buffer.handle,
                .offset = 0,
                .size = buffer.size,
            },
        },
        .image_memory_barrier_count = 0,
        .p_image_memory_barriers = undefined,
    });
}

pub fn bufferBarriers(
    self: CommandBuffer,
    buffers: []const *const Buffer,
    barriers: []const BufferBarrier,
) void {
    std.debug.assert(buffers.len == barriers.len);

    if (barriers.len == 0) return;

    //TODO: better allocation strategy for batched barrier calls
    var memory_barriers: [512]vk.BufferMemoryBarrier2 = undefined;

    for (buffers, barriers, 0..) |buffer, barrier, i| {
        memory_barriers[i] = .{
            .src_stage_mask = getVkPipelineStage(barrier.source_stage),
            .src_access_mask = getVkResourceAccess(barrier.source_access),
            .dst_stage_mask = getVkPipelineStage(barrier.destination_stage),
            .dst_access_mask = getVkResourceAccess(barrier.destination_access),
            .src_queue_family_index = vk.QUEUE_FAMILY_IGNORED,
            .dst_queue_family_index = vk.QUEUE_FAMILY_IGNORED,
            .buffer = buffer.handle,
            .offset = 0,
            .size = buffer.size,
        };
    }

    Context.self.vkd.cmdPipelineBarrier2(self.handle, &.{
        .dependency_flags = .{
            .by_region_bit = true,
            .view_local_bit = self.is_render_pass_instance,
        },
        .memory_barrier_count = 0,
        .p_memory_barriers = undefined,
        .buffer_memory_barrier_count = @intCast(barriers.len),
        .p_buffer_memory_barriers = &memory_barriers,
        .image_memory_barrier_count = 0,
        .p_image_memory_barriers = undefined,
    });
}

///Places an event which signals when the previous commands are finished executing
pub fn setEvent(self: CommandBuffer, event: Event) void {
    Context.self.vkd.cmdSetEvent(self.handle, event.handle, .{ .top_of_pipe_bit = true });
}

pub fn submitAndWait(self: CommandBuffer) !void {
    try self.submit(self.wait_fence);
    self.wait_fence.wait();
    self.wait_fence.reset();
}

pub fn submitAndWaitSemaphore(self: CommandBuffer, semaphore: Semaphore) !void {
    try self.submitSemaphore(self.wait_fence, semaphore);
    self.wait_fence.wait();
    self.wait_fence.reset();
}

pub fn submit(self: CommandBuffer, fence: Fence) !void {
    const queue = switch (self.queue) {
        .graphics => Context.self.graphics_queue,
        .compute => Context.self.compute_queue,
        .transfer => Context.self.transfer_queue,
    };

    try Context.self.vkd.queueSubmit2(queue, 1, &[_]vk.SubmitInfo2{.{
        .flags = .{},
        .wait_semaphore_info_count = 0,
        .p_wait_semaphore_infos = undefined,
        .command_buffer_info_count = 1,
        .p_command_buffer_infos = &[_]vk.CommandBufferSubmitInfo{.{
            .command_buffer = self.handle,
            .device_mask = 0,
        }},
        .signal_semaphore_info_count = 0,
        .p_signal_semaphore_infos = undefined,
    }}, fence.handle);
}

pub fn submitSemaphore(self: CommandBuffer, fence: Fence, wait_semaphore: Semaphore, signal_semaphore: Semaphore) !void {
    const queue = switch (self.queue) {
        .graphics => Context.self.graphics_queue,
        .compute => Context.self.compute_queue,
        .transfer => Context.self.transfer_queue,
    };

    try Context.self.vkd.queueSubmit2(queue, 1, &[_]vk.SubmitInfo2{.{
        .flags = .{},
        .wait_semaphore_info_count = 1,
        .p_wait_semaphore_infos = &[_]vk.SemaphoreSubmitInfo{.{
            .semaphore = wait_semaphore.handle,
            .value = 1,
            .stage_mask = .{
                .color_attachment_output_bit = true,
            },
            .device_index = 0,
        }},
        .command_buffer_info_count = 1,
        .p_command_buffer_infos = &[_]vk.CommandBufferSubmitInfo{.{
            .command_buffer = self.handle,
            .device_mask = 0,
        }},
        .signal_semaphore_info_count = 1,
        .p_signal_semaphore_infos = &[_]vk.SemaphoreSubmitInfo{.{
            .semaphore = signal_semaphore.handle,
            .value = 1,
            .stage_mask = .{
                .color_attachment_output_bit = true,
            },
            .device_index = 0,
        }},
    }}, fence.handle);
}

pub const Attachment = struct {
    image: *const Image,
    clear: ?Clear = null,
    store: bool = true,

    pub const Clear = union(enum) {
        color: [4]f32,
        depth: f32,
    };
};

pub fn beginRenderPass(
    self: *CommandBuffer,
    offset_x: i32,
    offset_y: i32,
    width: u32,
    height: u32,
    color_attachments: []const Attachment,
    depth_attachment: ?Attachment,
) void {
    var color_attachment_infos: [8]vk.RenderingAttachmentInfo = undefined;

    var max_width: u32 = std.math.maxInt(u32);
    var max_height: u32 = std.math.maxInt(u32);

    for (color_attachments, 0..) |color_attachment, i| {
        color_attachment_infos[i] = .{
            .image_view = color_attachment.image.view,
            .image_layout = .attachment_optimal,
            .resolve_mode = .{},
            .resolve_image_view = .null_handle,
            .resolve_image_layout = .undefined,
            .load_op = if (color_attachment.clear != null) .clear else .load,
            .store_op = if (color_attachment.store) .store else .dont_care,
            .clear_value = if (color_attachment.clear != null) switch (color_attachment.clear.?) {
                .color => .{ .color = .{ .float_32 = color_attachment.clear.?.color } },
                .depth => .{ .depth_stencil = .{
                    .depth = color_attachment.clear.?.depth,
                    .stencil = 1,
                } },
            } else .{ .color = .{ .float_32 = .{ 0, 0, 0, 0 } } },
        };

        max_width = @min(max_width, color_attachment.image.width);
        max_height = @min(max_height, color_attachment.image.height);
    }

    var depth_attachment_info: vk.RenderingAttachmentInfo = undefined;

    if (depth_attachment != null) {
        depth_attachment_info = .{
            .image_view = depth_attachment.?.image.view,
            .image_layout = .attachment_optimal,
            .resolve_mode = .{},
            .resolve_image_view = .null_handle,
            .resolve_image_layout = .undefined,
            .load_op = if (depth_attachment.?.clear != null) .clear else .load,
            .store_op = if (depth_attachment.?.store) .store else .dont_care,
            .clear_value = if (depth_attachment.?.clear != null) switch (depth_attachment.?.clear.?) {
                .color => .{ .color = .{ .float_32 = depth_attachment.?.clear.?.color } },
                .depth => .{ .depth_stencil = .{
                    .depth = depth_attachment.?.clear.?.depth,
                    .stencil = 1,
                } },
            } else .{ .color = .{ .float_32 = .{ 0, 0, 0, 0 } } },
        };

        max_width = @min(max_width, depth_attachment.?.image.width);
        max_height = @min(max_height, depth_attachment.?.image.height);
    }

    Context.self.vkd.cmdBeginRendering(self.handle, &.{
        .flags = .{},
        .render_area = .{ .offset = .{ .x = offset_x, .y = offset_y }, .extent = .{
            .width = @min(width, max_width),
            .height = @min(height, max_height),
        } },
        .layer_count = 1,
        .view_mask = 0,
        .color_attachment_count = @as(u32, @intCast(color_attachments.len)),
        .p_color_attachments = &color_attachment_infos,
        .p_depth_attachment = if (depth_attachment != null) &depth_attachment_info else null,
        .p_stencil_attachment = null,
    });

    self.is_render_pass_instance = true;
}

pub fn endRenderPass(self: *CommandBuffer) void {
    Context.self.vkd.cmdEndRendering(self.handle);

    self.is_render_pass_instance = false;
}

pub fn setGraphicsPipeline(self: *CommandBuffer, pipeline: GraphicsPipeline) void {
    Context.self.vkd.cmdBindPipeline(self.handle, .graphics, pipeline.handle);

    self.pipeline_layout = pipeline.layout;

    if (pipeline.descriptor_pool != .null_handle) {
        Context.self.vkd.cmdBindDescriptorSets(self.handle, .graphics, pipeline.layout, 0, @as(u32, @intCast(pipeline.descriptor_sets.len)), pipeline.descriptor_sets.ptr, 0, undefined);
    }

    self.is_graphics_pipeline = true;
}

pub fn setDescriptorBuffer(self: *CommandBuffer, buffer: Buffer) void {
    Context.self.vkd.cmdBindDescriptorBuffersEXT(
        self.handle,
        1,
        &[_]vk.DescriptorBufferBindingInfoEXT{.{
            .address = buffer.device_address,
            .usage = switch (buffer.usage) {
                .vertex => .{ .vertex_buffer_bit = true, .storage_buffer_bit = true, .transfer_dst_bit = true },
                .index => .{ .index_buffer_bit = true, .storage_buffer_bit = true, .transfer_dst_bit = true },
                .uniform => .{ .uniform_buffer_bit = true, .transfer_dst_bit = true },
                .storage => .{
                    .storage_buffer_bit = true,
                    .transfer_dst_bit = true,
                },
                .indirect => .{
                    .indirect_buffer_bit = true,
                    .storage_buffer_bit = true,
                    .transfer_dst_bit = true,
                },
                .staging => .{ .transfer_src_bit = true },
            },
        }},
    );
}

pub fn setVertexBuffer(self: CommandBuffer, buffer: Buffer) void {
    Context.self.vkd.cmdBindVertexBuffers(self.handle, 0, 1, @as([*]const vk.Buffer, @ptrCast(&buffer.handle)), @as([*]const u64, @ptrCast(&@as(u64, 0))));
}

pub fn setPushData(self: CommandBuffer, comptime T: type, data: T) void {
    self.setPushDataBytes(std.mem.asBytes(&data));
}

pub fn setPushDataBytes(self: CommandBuffer, data: []const u8) void {
    const shader_stages: vk.ShaderStageFlags = if (self.is_graphics_pipeline) .{ .vertex_bit = true, .fragment_bit = true } else .{ .compute_bit = true };

    Context.self.vkd.cmdPushConstants(self.handle, self.pipeline_layout, shader_stages, 0, @intCast(data.len), data.ptr);
}

pub fn setViewport(self: CommandBuffer, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
    Context.self.vkd.cmdSetViewport(self.handle, 0, 1, @as([*]const vk.Viewport, @ptrCast(&.{
        .x = x,
        .y = y,
        .width = width,
        .height = height,
        .min_depth = min_depth,
        .max_depth = max_depth,
    })));
}

pub fn setScissor(self: CommandBuffer, x: u32, y: u32, width: u32, height: u32) void {
    Context.self.vkd.cmdSetScissor(self.handle, 0, 1, @as([*]const vk.Rect2D, @ptrCast(&.{ .offset = .{ .x = x, .y = y }, .extent = .{ .width = width, .height = height } })));
}

pub const IndexType = enum {
    u16,
    u32,
};

pub fn setIndexBuffer(self: CommandBuffer, buffer: Buffer, index_type: IndexType) void {
    Context.self.vkd.cmdBindIndexBuffer(self.handle, buffer.handle, 0, switch (index_type) {
        .u16 => .uint16,
        .u32 => .uint32,
    });
}

pub fn copyBuffer(
    self: CommandBuffer,
    source: Buffer,
    source_offset: usize,
    source_size: usize,
    destination: Buffer,
    destination_offset: usize,
    destination_size: usize,
) void {
    const copy_region = vk.BufferCopy{
        .src_offset = source_offset,
        .dst_offset = destination_offset,
        .size = @min(source_size, destination_size),
    };

    Context.self.vkd.cmdCopyBuffer(
        self.handle,
        source.handle,
        destination.handle,
        1,
        @as([*]const vk.BufferCopy, @ptrCast(&copy_region)),
    );
}

pub fn copyEntireBuffer(
    self: CommandBuffer,
    source: Buffer,
    destination: Buffer,
) void {
    self.copyBuffer(
        source,
        0,
        source.size,
        destination,
        0,
        destination.size,
    );
}

pub fn updateBuffer(self: CommandBuffer, destination: Buffer, offset: usize, comptime T: type, data: []const T) void {
    std.debug.assert((data.len * @sizeOf(T)) <= 65536);

    Context.self.vkd.cmdUpdateBuffer(
        self.handle,
        destination.handle,
        std.mem.alignForward(usize, offset, 4),
        std.mem.alignBackward(usize, data.len * @sizeOf(T), 4),
        data.ptr,
    );

    @compileError("Unsupported");
}

pub fn fillBuffer(self: CommandBuffer, source: Buffer, offset: usize, size: usize, value: u32) void {
    Context.self.vkd.cmdFillBuffer(self.handle, source.handle, offset, size, value);
}

pub fn copyBufferToImage(self: CommandBuffer, source: Buffer, destination: Image) void {
    Context.self.vkd.cmdCopyBufferToImage2(self.handle, &.{
        .src_buffer = source.handle,
        .dst_image = destination.handle,
        .dst_image_layout = .transfer_dst_optimal,
        .region_count = 1,
        .p_regions = &[_]vk.BufferImageCopy2{.{
            .buffer_offset = 0,
            .buffer_row_length = destination.width,
            .buffer_image_height = destination.height,
            .image_subresource = .{
                .aspect_mask = .{
                    .color_bit = true,
                },
                .mip_level = 0,
                .base_array_layer = 0,
                .layer_count = if (destination.type == .cube) 6 else 1,
            },
            .image_offset = .{
                .x = 0,
                .y = 0,
                .z = 0,
            },
            .image_extent = .{ .width = destination.width, .height = destination.height, .depth = if (destination.type == .cube) 1 else destination.depth },
        }},
    });
}

pub fn copyBufferToImageOffset(
    self: CommandBuffer,
    source: Buffer,
    source_offset: usize,
    source_size: usize,
    destination: Image,
) void {
    _ = source_size; // autofix
    Context.self.vkd.cmdCopyBufferToImage2(self.handle, &.{
        .src_buffer = source.handle,
        .dst_image = destination.handle,
        .dst_image_layout = .transfer_dst_optimal,
        .region_count = 1,
        .p_regions = &[_]vk.BufferImageCopy2{.{
            .buffer_offset = source_offset,
            .buffer_row_length = destination.width,
            .buffer_image_height = destination.height,
            .image_subresource = .{
                .aspect_mask = .{
                    .color_bit = true,
                },
                .mip_level = 0,
                .base_array_layer = 0,
                .layer_count = if (destination.type == .cube) 6 else 1,
            },
            .image_offset = .{
                .x = 0,
                .y = 0,
                .z = 0,
            },
            .image_extent = .{
                .width = destination.width,
                .height = destination.height,
                .depth = if (destination.type == .cube) 1 else destination.depth,
            },
        }},
    });
}

pub fn draw(
    self: CommandBuffer,
    vertex_count: u32,
    instance_count: u32,
    first_vertex: u32,
    first_instance: u32,
) void {
    Context.self.vkd.cmdDraw(self.handle, vertex_count, instance_count, first_vertex, first_instance);
}

pub fn drawIndexed(
    self: CommandBuffer,
    index_count: u32,
    instance_count: u32,
    first_index: u32,
    vertex_offset: i32,
    first_instance: u32,
) void {
    Context.self.vkd.cmdDrawIndexed(
        self.handle,
        index_count,
        instance_count,
        first_index,
        vertex_offset,
        first_instance,
    );
}

pub const DrawIndirectCommand = extern struct {
    vertex_count: u32,
    instance_count: u32,
    first_vertex: u32,
    first_instance: u32,
};

pub fn drawIndirect(
    self: CommandBuffer,
    draw_buffer: Buffer,
    draw_buffer_offset: usize,
    draw_count: usize,
) void {
    Context.self.vkd.cmdDrawIndirect(
        self.handle,
        draw_buffer.handle,
        draw_buffer_offset,
        @as(u32, @truncate(draw_count)),
        @sizeOf(DrawIndirectCommand),
    );
}

pub const DrawIndexedIndirectCommand = extern struct {
    index_count: u32,
    instance_count: u32,
    first_index: u32,
    vertex_offset: i32,
    first_instance: u32,
};

pub fn drawIndexedIndirect(
    self: CommandBuffer,
    draw_buffer: Buffer,
    draw_buffer_offset: usize,
    draw_count: usize,
) void {
    Context.self.vkd.cmdDrawIndexedIndirect(
        self.handle,
        draw_buffer.handle,
        draw_buffer_offset,
        @as(u32, @truncate(draw_count)),
        @sizeOf(DrawIndexedIndirectCommand),
    );
}

pub fn drawIndexedIndirectCount(
    self: CommandBuffer,
    draw_buffer: Buffer,
    draw_buffer_offset: usize,
    draw_buffer_stride: usize,
    count_buffer: Buffer,
    count_buffer_offset: usize,
    max_draw_count: usize,
) void {
    Context.self.vkd.cmdDrawIndexedIndirectCount(
        self.handle,
        draw_buffer.handle,
        draw_buffer_offset,
        count_buffer.handle,
        count_buffer_offset,
        @as(u32, @truncate(max_draw_count)),
        @as(u32, @intCast(draw_buffer_stride)),
    );
}

pub fn setComputePipeline(self: *CommandBuffer, pipeline: ComputePipeline) void {
    Context.self.vkd.cmdBindPipeline(self.handle, .compute, pipeline.handle);

    self.pipeline_layout = pipeline.layout;
    self.local_size_x = pipeline.local_size_x;
    self.local_size_y = pipeline.local_size_y;
    self.local_size_z = pipeline.local_size_z;

    Context.self.vkd.cmdBindDescriptorSets(self.handle, .compute, pipeline.layout, 0, @as(u32, @intCast(pipeline.descriptor_sets.len)), pipeline.descriptor_sets.ptr, 0, undefined);

    self.is_graphics_pipeline = false;
}

pub fn computeDispatch(self: CommandBuffer, thread_count_x: u32, thread_count_y: u32, thread_count_z: u32) void {
    const group_count_x = (thread_count_x + self.local_size_x - 1) / self.local_size_x;
    const group_count_y = (thread_count_y + self.local_size_y - 1) / self.local_size_y;
    const group_count_z = (thread_count_z + self.local_size_z - 1) / self.local_size_z;

    Context.self.vkd.cmdDispatch(self.handle, group_count_x, group_count_y, group_count_z);
}

pub const DispatchIndirectCommand = extern struct {
    group_count_x: u32,
    group_count_y: u32,
    group_count_z: u32,
};

pub fn computeDispatchIndirect(self: CommandBuffer, buffer: Buffer, offset: usize) void {
    Context.self.vkd.cmdDispatchIndirect(self.handle, buffer.handle, offset);
}

///Only does something in OptimizeMode.Debug
pub fn debugLabelBegin(self: CommandBuffer, name: []const u8) void {
    if (@import("builtin").mode != .Debug) return;

    var name_buffer: [1024]u8 = undefined;

    const name_z = std.fmt.bufPrintZ(&name_buffer, "{s}", .{name}) catch unreachable;

    Context.self.vkd.cmdBeginDebugUtilsLabelEXT(self.handle, &.{
        .p_label_name = name_z.ptr,
        .color = .{ 0, 0, 0, 0 },
    });
}

///Only does something in OptimizeMode.Debug
pub fn debugLabelEnd(self: CommandBuffer) void {
    if (@import("builtin").mode != .Debug) return;

    Context.self.vkd.cmdEndDebugUtilsLabelEXT(self.handle);
}
