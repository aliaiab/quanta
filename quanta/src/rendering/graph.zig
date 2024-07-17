//!Render Graph implementation built on top of quanta.graphics
//TODO: implement unit testing and runtime validation

pub const IndexType = enum {
    u16,
    u32,
};

pub const SampleReductionMode = enum {
    min,
    max,
    weighted_average,
};

pub const SampleFilterMode = enum {
    linear,
    nearest,
};

pub const SampleAddressMode = enum {
    repeat,
    mirrored_repeat,
    clamp_to_edge,
    clamp_to_border,
    mirror_clamp_to_edge,
};

///A draw command that can be stored in an draw indirect buffer and used in indirect draw api commands
//Must be kept in sync with the underlying representation of commands for the graphics api
pub const DrawIndexedIndirectCommand = extern struct {
    index_count: u32,
    instance_count: u32,
    first_index: u32,
    vertex_offset: i32,
    first_instance: u32,
};

pub const Command = union(enum) {
    update_buffer: struct {
        buffer: BufferHandle,
        buffer_offset: usize,
        contents: []const u8,
    },
    update_image: struct {
        image: ImageHandle,
        image_offset: usize,
        contents: []const u8,
    },
    blit_image: struct {
        src_image: ImageHandle,
        dst_image: ImageHandle,
        region: BlitRegion,
        filter: SampleFilterMode,
    },
    set_raster_pipeline: struct {
        pipeline: RasterPipeline,
    },
    set_raster_pipeline_resource_buffer: struct {
        pipeline: RasterPipeline,
        binding_index: u32,
        array_index: u32,
        buffer: BufferHandle,
    },
    set_raster_pipeline_image_sampler: struct {
        pipeline: RasterPipeline,
        binding_index: u32,
        array_index: u32,
        image: ImageHandle,
        sampler: Sampler,
    },
    set_compute_pipeline: struct {
        pipeline: ComputePipeline,
    },
    compute_dispatch: struct {
        thread_count_x: u32,
        thread_count_y: u32,
        thread_count_z: u32,
    },
    set_viewport: struct {
        x: f32,
        y: f32,
        width: f32,
        height: f32,
        min_depth: f32,
        max_depth: f32,
    },
    set_scissor: struct {
        x: u32,
        y: u32,
        width: u32,
        height: u32,
    },
    set_index_buffer: struct {
        index_buffer: BufferHandle,
        type: IndexType,
    },
    set_push_data: struct {
        contents: []const u8,
    },
    draw_indexed: struct {
        index_count: u32,
        instance_count: u32,
        first_index: u32,
        vertex_offset: i32,
        first_instance: u32,
    },
    draw: struct {
        vertex_count: u32,
        instance_count: u32,
        first_vertex: u32,
        first_instance: u32,
    },
    draw_indexed_indirect_count: struct {
        draw_buffer: BufferHandle,
        draw_buffer_offset: usize,
        draw_buffer_stride: usize,
        count_buffer: BufferHandle,
        count_buffer_offset: usize,
        max_draw_count: usize,
    },
};

///List of all commands in a graph
///Not ordered globally. Does not have random access
pub const Commands = struct {
    tags: std.ArrayListUnmanaged(std.meta.Tag(Command)) = .{},
    ///List of Command payloads
    data: std.ArrayListUnmanaged(u8) = .{},

    pub fn deinit(self: *@This(), allocator: std.mem.Allocator) void {
        self.tags.deinit(allocator);
        self.data.deinit(allocator);

        self.* = undefined;
    }

    pub fn reset(self: *@This()) void {
        self.tags.items.len = 0;
        self.data.items.len = 0;
    }

    ///Returns the offset where the command was encoded
    pub fn add(
        self: *@This(),
        allocator: std.mem.Allocator,
        command: Command,
    ) void {
        self.tags.append(allocator, command) catch @panic("oom");

        switch (command) {
            inline else => |command_data| {
                self.data.appendSlice(
                    allocator,
                    std.mem.asBytes(&command_data),
                ) catch @panic("oom");
            },
        }
    }

    pub fn iterator(
        self: *const @This(),
        index: usize,
        count: usize,
        data_offset: usize,
    ) Iterator {
        return .{
            .commands = self,
            .start_index = index,
            .end_index = index + count,
            .data_offset = data_offset,
        };
    }

    pub const Tag = std.meta.Tag(Command);

    pub const Iterator = struct {
        commands: *const CommandsType,
        start_index: usize,
        end_index: usize,
        data_offset: usize = 0,

        pub fn next(self: *@This()) ?Command {
            if (self.start_index == self.end_index) return null;
            defer self.start_index += 1;

            const tag = self.commands.tags.items[self.start_index];

            switch (tag) {
                inline else => |tag_comp| {
                    const Payload = std.meta.TagPayload(Command, tag_comp);

                    const payload_offset = self.data_offset;
                    const payload_size = @sizeOf(Payload);

                    const payload_bytes = self.commands.data.items[payload_offset .. payload_offset + payload_size];

                    defer self.data_offset += payload_size;

                    return @unionInit(
                        Command,
                        @tagName(tag_comp),
                        std.mem.bytesAsValue(Payload, payload_bytes).*,
                    );
                },
            }
        }
    };

    test {
        var commands = @This(){};
        defer commands.deinit(std.testing.allocator);

        commands.reset();

        _ = commands.add(
            std.testing.allocator,
            .{ .update_buffer = .{
                .buffer = undefined,
                .buffer_offset = 0,
                .contents = "contents",
            } },
        );

        var iter = commands.iterator(0, commands.tags.items.len, 0);

        while (iter.next()) |command| {
            std.log.warn("command = {}", .{command});
        }
    }

    const CommandsType = @This();
};

///Graph builder for building a graph
///Works like an immediate-mode-gui-type api
pub const Builder = struct {
    gpa: std.mem.Allocator,
    scratch_allocator: std.heap.ArenaAllocator,
    raster_pipelines: std.MultiArrayList(struct {
        handle: RasterPipeline,
        reference_count: u32,
        vertex_module: RasterModule,
        fragment_module: RasterModule,

        push_constant_size: u32,
        attachment_formats: []const ImageFormat,
        depth_attachment_format: ImageFormat,
        depth_state: @import("../graphics.zig").GraphicsPipeline.Options.DepthState,
        rasterisation_state: @import("../graphics.zig").GraphicsPipeline.Options.RasterisationState,
        blend_state: @import("../graphics.zig").GraphicsPipeline.Options.BlendState,
    }) = .{},
    compute_pipelines: std.MultiArrayList(struct {
        handle: ComputePipeline,
        reference_count: u32,
        module: ComputeModule,
        push_constant_size: usize,
    }) = .{},
    buffers: std.MultiArrayList(struct {
        handle: BufferHandle,
        reference_count: u32,
        size: usize,
    }) = .{},
    images: std.MultiArrayList(struct {
        handle: ImageHandle,
        reference_count: u32,
        format: ImageFormat,
        width: u32,
        height: u32,
        depth: u32,
        levels: u32,
    }) = .{},
    samplers: std.MultiArrayList(struct {
        handle: Sampler,
        reference_count: u32,
        min_filter: SampleFilterMode,
        mag_filter: SampleFilterMode,
        address_mode_u: SampleAddressMode,
        address_mode_v: SampleAddressMode,
        address_mode_w: SampleAddressMode,
        reduction_mode: ?SampleReductionMode,
    }) = .{},
    ///List of pass tasks (not render passes)
    passes: std.MultiArrayList(struct {
        handle: PassHandle,
        reference_count: u32,
        data: PassData,
        command_offset: u32,
        command_count: u32,
        command_data_offset: u32,
        input_offset: u32,
        input_count: u16,
    }) = .{},
    pass_inputs: std.MultiArrayList(struct {
        pass_index: u32,
        resource_type: ResourceType,
        resource_handle: ResourceHandle,
    }) = .{},
    commands: Commands = .{},
    ///The exported resource whose data can be observed from outside the graph
    ///Acts as the root edge of the graph
    ///TODO: allow multiple graph exports
    export_resource: ?union(enum) {
        image: Image,
        buffer: Buffer,
    } = null,

    ///TODO: Handle nested passes?
    ///We could have some kind of context? (IE when we call beginPass*, we context 'switch')
    current_pass_index: u32,
    debug_info: DebugInfo = .{},
    ///Persistant buffer handles. Has nothing to do with the persistant of backend allocations or data.
    persistant_buffers: std.AutoArrayHashMapUnmanaged(BufferHandle, struct {
        size: usize,
    }) = .{},
    persistant_images: std.AutoArrayHashMapUnmanaged(ImageHandle, struct {
        ///Store a transient image handle so that pass depedencies can be kept track of
        image: Image,
        ///This is true if the image is actively being used in the current graph instance (if it's stored in the images array)
        is_active: bool,
        format: ImageFormat,
        width: u32,
        height: u32,
        depth: u32,
        levels: u32,
    }) = .{},

    pub const PassData = union(enum) {
        transfer: void,
        raster: struct {
            render_offset_x: i32,
            render_offset_y: i32,
            render_width: u32,
            render_height: u32,
            attachments: []const ColorAttachment,
            depth_attachment: ?struct {
                image: ImageHandle,
                clear: ?f32 = null,
                store: bool = true,
                load: bool = true,
            },
        },
        compute: void,
    };

    pub fn init(gpa: std.mem.Allocator) @This() {
        return .{
            .gpa = gpa,
            .scratch_allocator = std.heap.ArenaAllocator.init(gpa),
            .current_pass_index = 0,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.raster_pipelines.deinit(self.gpa);
        self.compute_pipelines.deinit(self.gpa);
        self.buffers.deinit(self.gpa);
        self.images.deinit(self.gpa);
        self.samplers.deinit(self.gpa);

        self.passes.deinit(self.gpa);
        self.pass_inputs.deinit(self.gpa);

        self.debug_info.deinit(self.*);

        self.persistant_buffers.deinit(self.gpa);
        self.persistant_images.deinit(self.gpa);

        self.commands.deinit(self.gpa);
        self.scratch_allocator.deinit();

        self.* = undefined;
    }

    ///Clear the graph to its default state. Allows for graph reuse for dynamically building graphs.
    pub fn clear(self: *@This()) void {
        self.raster_pipelines.len = 0;
        self.compute_pipelines.len = 0;
        self.buffers.len = 0;
        self.images.len = 0;
        self.samplers.len = 0;

        self.passes.len = 0;
        self.pass_inputs.len = 0;
        self.current_pass_index = 0;

        self.export_resource = null;

        self.commands.reset();
        self.debug_info.reset(self.*);

        for (self.persistant_images.values()) |*persistant_image| {
            persistant_image.is_active = false;
        }

        _ = self.scratch_allocator.reset(std.heap.ArenaAllocator.ResetMode{ .retain_capacity = {} });
    }

    pub fn scratchAlloc(self: *@This(), comptime T: type, count: usize) []T {
        return self.scratch_allocator.allocator().alloc(T, count) catch @panic("oom");
    }

    pub fn scratchDupe(self: *@This(), comptime T: type, values: []const T) []T {
        return self.scratch_allocator.allocator().dupe(T, values) catch @panic("oom");
    }

    const CreateRasterPipelineOptions = struct {
        attachment_formats: []const ImageFormat,
        depth_attachment_format: ImageFormat = .undefined,
        ///TODO: create dedicated pipeline option structs for renderer graph
        depth_state: @import("../graphics.zig").GraphicsPipeline.Options.DepthState = .{},
        rasterisation_state: @import("../graphics.zig").GraphicsPipeline.Options.RasterisationState = .{},
        blend_state: @import("../graphics.zig").GraphicsPipeline.Options.BlendState = .{},
    };

    pub fn createRasterPipeline(
        self: *@This(),
        comptime src: SourceLocation,
        vertex_module: RasterModule,
        fragment_module: RasterModule,
        options: CreateRasterPipelineOptions,
        push_constant_size: usize,
    ) RasterPipeline {
        const handle_id = comptime idFromSourceLocation(src);

        const handle: RasterPipeline = .{
            .id = handle_id,
        };

        self.raster_pipelines.append(self.gpa, .{
            .handle = handle,
            .vertex_module = vertex_module,
            .fragment_module = fragment_module,
            .reference_count = 0,
            .push_constant_size = @intCast(push_constant_size),
            .attachment_formats = self.scratch_allocator.allocator().dupe(ImageFormat, options.attachment_formats) catch @panic("oom"),
            .depth_attachment_format = options.depth_attachment_format,
            .depth_state = options.depth_state,
            .rasterisation_state = options.rasterisation_state,
            .blend_state = options.blend_state,
        }) catch @panic("oom");

        return handle;
    }

    pub fn createComputePipeline(
        self: *@This(),
        comptime src: SourceLocation,
        module: ComputeModule,
        push_constant_size: usize,
    ) ComputePipeline {
        const handle_id = comptime idFromSourceLocation(src);

        const handle: ComputePipeline = .{
            .id = handle_id,
        };

        self.compute_pipelines.append(self.gpa, .{
            .handle = handle,
            .module = module,
            .reference_count = 0,
            .push_constant_size = @intCast(push_constant_size),
        }) catch @panic("oom");

        return handle;
    }

    pub fn createBuffer(
        self: *@This(),
        comptime src: SourceLocation,
        options: struct {
            ///Additional identifier bits. Unique relative to each src.
            identifier: u64 = 0,
            size: usize,
        },
    ) Buffer {
        const handle_id = idFromSourceLocationAndInt(src, options.identifier);

        const handle: BufferHandle = @enumFromInt(handle_id);

        const index: u32 = @intCast(self.buffers.len);

        self.buffers.append(self.gpa, .{
            .handle = handle,
            .size = options.size,
            .reference_count = 0,
        }) catch @panic("oom");

        self.debug_info.addBuffer(
            self.*,
            src,
            handle,
        );

        return .{
            .index = index,
            .pass_index = null,
        };
    }

    ///Return the persistant handle for buffer
    ///Can be stored outside of the render graph and then reimported using imageFromHandle in another instance of this graph
    ///Implicitly creates a persistant handle mapping
    pub fn bufferGetPersistantHandle(
        self: *@This(),
        buffer: Buffer,
    ) BufferHandle {
        const handle = self.buffers.items(.handle)[buffer.index];

        const maybe_buffer = self.persistant_buffers.getOrPut(self.gpa, handle) catch @panic("oom");

        if (!maybe_buffer.found_existing) {
            maybe_buffer.value_ptr.* = .{
                .size = self.buffers.items(.size)[buffer.index],
            };
        }

        return handle;
    }

    ///Create an buffer pointer from a handle
    ///Returns an buffer that is identical to the buffer returned from the last createImage called on that handle
    pub fn bufferFromPersistantHandle(
        self: *@This(),
        buffer_handle: BufferHandle,
    ) Buffer {
        const maybe_buffer = self.persistant_buffers.get(buffer_handle);

        if (maybe_buffer == null) {
            for (self.buffers.items(.handle), 0..) |handle, buffer_index| {
                if (handle == buffer_handle) return .{
                    .index = @intCast(buffer_index),
                    .pass_index = null,
                };
            }

            @panic("Invalid buffer handle");
        } else {
            const index: u32 = @intCast(self.buffers.len);

            self.buffers.append(self.gpa, .{
                .handle = buffer_handle,
                .size = maybe_buffer.?.size,
                .reference_count = 0,
            }) catch @panic("oom");

            return .{
                .index = index,
                .pass_index = null,
            };
        }
    }

    ///Return the size of a persistant buffer handle
    pub fn bufferPersistantGetSize(
        self: @This(),
        buffer_handle: BufferHandle,
    ) usize {
        const buffer_info = self.persistant_buffers.get(buffer_handle) orelse @panic("oom");

        return buffer_info.size;
    }

    pub fn createImage(
        self: *@This(),
        comptime src: SourceLocation,
        options: struct {
            identifier: u64 = 0,
            format: ImageFormat,
            width: u32,
            height: u32,
            depth: u32,
            levels: u32 = 1,
        },
    ) Image {
        const handle_id = idFromSourceLocationAndInt(src, options.identifier);

        const handle: ImageHandle = @enumFromInt(handle_id);

        const index: u32 = @intCast(self.images.len);

        self.images.append(self.gpa, .{
            .handle = handle,
            .format = options.format,
            .width = options.width,
            .height = options.height,
            .depth = options.depth,
            .levels = options.levels,
            .reference_count = 0,
        }) catch @panic("oom");

        self.debug_info.addImage(self.*, src, handle);

        return .{
            .index = index,
            .pass_index = null,
        };
    }

    ///Return the persistant handle for image
    ///Can be stored outside of the render graph and then reimported using imageFromHandle in another instance of this graph
    pub fn imageGetPersistantHandle(
        self: *@This(),
        image: Image,
    ) ImageHandle {
        const handle = self.images.items(.handle)[image.index];

        const maybe_image = self.persistant_images.getOrPut(self.gpa, handle) catch @panic("oom");

        if (!maybe_image.found_existing) {
            maybe_image.value_ptr.* = .{
                .image = .{
                    .index = image.index,
                    .pass_index = image.pass_index,
                },
                .is_active = true,
                .width = self.images.items(.width)[image.index],
                .height = self.images.items(.height)[image.index],
                .depth = self.images.items(.depth)[image.index],
                .levels = self.images.items(.levels)[image.index],
                .format = self.images.items(.format)[image.index],
            };
        }

        return handle;
    }

    ///Create an image pointer from a handle
    pub fn imageFromPersistantHandle(
        self: *@This(),
        image_handle: ImageHandle,
    ) *Image {
        const maybe_image = self.persistant_images.getPtr(image_handle);

        //If the image is not active in the current graph instance, add it to the images list so
        //it can be observed by commands
        if (!maybe_image.?.is_active) {
            //Update the image index with the new one
            maybe_image.?.image.index = @intCast(self.images.len);
            //Make sure the persistant image is marked as active
            maybe_image.?.is_active = true;
            //If the image isn't active, then we must set the pass index to null so that
            //We don't try to depend on a pass index from the last graph instance
            maybe_image.?.image.pass_index = null;

            self.images.append(self.gpa, .{
                .handle = image_handle,
                .format = maybe_image.?.format,
                .width = maybe_image.?.width,
                .height = maybe_image.?.height,
                .depth = maybe_image.?.depth,
                .levels = maybe_image.?.levels,
                .reference_count = 0,
            }) catch @panic("oom");
        }

        return &maybe_image.?.image;
    }

    pub fn imageGetWidth(
        self: *@This(),
        image: Image,
    ) u32 {
        return self.images.items(.width)[image.index];
    }

    pub fn imageGetHeight(
        self: *@This(),
        image: Image,
    ) u32 {
        return self.images.items(.height)[image.index];
    }

    pub fn imageGetDepth(
        self: *@This(),
        image: Image,
    ) u32 {
        return self.images.items(.depth)[image.index];
    }

    pub fn imageGetFormat(
        self: *@This(),
        image: Image,
    ) ImageFormat {
        return self.images.items(.format)[image.index];
    }

    pub fn createSampler(
        self: *@This(),
        comptime src: SourceLocation,
        options: struct {
            min_filter: SampleFilterMode,
            mag_filter: SampleFilterMode,
            address_mode_u: SampleAddressMode = .repeat,
            address_mode_v: SampleAddressMode = .repeat,
            address_mode_w: SampleAddressMode = .repeat,
            reduction_mode: ?SampleReductionMode = null,
        },
    ) Sampler {
        const handle_id = comptime idFromSourceLocation(src);

        const handle: Sampler = .{
            .id = handle_id,
        };

        self.samplers.append(self.gpa, .{
            .handle = .{ .id = handle_id },
            .reference_count = 0,
            .min_filter = options.min_filter,
            .mag_filter = options.mag_filter,
            .address_mode_u = options.address_mode_u,
            .address_mode_v = options.address_mode_v,
            .address_mode_w = options.address_mode_w,
            .reduction_mode = options.reduction_mode,
        }) catch @panic("oom");

        return handle;
    }

    ///Begins a pass for transferring, copying and updating resources
    pub fn beginTransferPass(
        self: *@This(),
        ///Uniquely identifies the pass
        comptime src: SourceLocation,
    ) void {
        const pass_id = comptime idFromSourceLocation(src);

        self.beginPassGeneric(pass_id, .transfer);

        self.debug_info.addPass(self.*, src, .{ .id = pass_id });
    }

    pub fn endTransferPass(
        self: *@This(),
    ) void {
        self.endPassGeneric();
    }

    pub fn updateBuffer(
        self: *@This(),
        ///The destination buffer to be updated
        buffer: *Buffer,
        ///Offset into the destination buffer
        buffer_offset: usize,
        comptime T: type,
        contents: []const T,
    ) void {
        if (contents.len == 0) return;

        _ = self.referenceBufferAsInput(buffer.*);

        self.commands.add(self.gpa, .{
            .update_buffer = .{
                .buffer = self.buffers.items(.handle)[buffer.index],
                .buffer_offset = buffer_offset,
                .contents = std.mem.sliceAsBytes(contents),
            },
        });

        buffer.pass_index = @intCast(self.current_pass_index);
    }

    pub fn updateBufferValue(
        self: *@This(),
        buffer: *Buffer,
        buffer_offset: usize,
        comptime T: type,
        value: T,
    ) void {
        const contents = self.scratch_allocator.allocator().alloc(T, 1) catch @panic("oom");

        contents[0] = value;

        self.updateBuffer(
            buffer,
            buffer_offset,
            T,
            contents,
        );
    }

    pub fn updateImage(
        self: *@This(),
        image: *Image,
        offset: usize,
        comptime T: type,
        contents: []const T,
    ) void {
        self.referenceImageAsInput(image.*);

        self.commands.add(self.gpa, .{
            .update_image = .{
                .image = self.images.items(.handle)[image.index],
                .image_offset = offset,
                .contents = std.mem.sliceAsBytes(contents),
            },
        });

        image.pass_index = @intCast(self.current_pass_index);
    }

    pub fn blitImage(
        self: *@This(),
        src_image: Image,
        dst_image: *Image,
        region: BlitRegion,
        filter: SampleFilterMode,
    ) void {
        self.referenceImageAsInput(src_image);

        self.commands.add(self.gpa, .{
            .blit_image = .{
                .src_image = self.images.items(.handle)[src_image.index],
                .dst_image = self.images.items(.handle)[dst_image.index],
                .region = region,
                .filter = filter,
            },
        });

        dst_image.pass_index = @intCast(self.current_pass_index);
    }

    pub const ColorAttachment = struct {
        image: ImageHandle,
        clear: ?[4]f32 = null,
        store: bool = true,
        load: bool = true,
    };

    pub const RasterRenderArea = union(enum) {
        rectangle: struct {
            offset_x: i32 = 0,
            offset_y: i32 = 0,
            width: u32,
            height: u32,
        },
        ///Renders to the largest possible area for all attachments in a pass
        entirety: void,
    };

    pub fn beginRasterPass(
        self: *@This(),
        comptime src: SourceLocation,
        color_attachments: []const struct {
            image: *Image,
            clear: ?[4]f32 = null,
            load: bool = true,
            store: bool = true,
        },
        depth_attachment: ?union(enum) {
            read_only: struct {
                image: Image,
            },
            read_write: struct {
                image: *Image,
                clear: ?f32 = null,
                store: bool = true,
            },
        },
        render_area: RasterRenderArea,
    ) void {
        const pass_id = comptime idFromSourceLocation(src);

        const attachments_allocated = self.scratch_allocator.allocator().alloc(ColorAttachment, color_attachments.len) catch @panic("oom");

        for (attachments_allocated, color_attachments) |*attachment_allocated, attachment| {
            attachment_allocated.* = .{
                .image = self.images.items(.handle)[attachment.image.index],
                .clear = attachment.clear,
                .store = attachment.store,
                .load = attachment.load,
            };
        }

        var offset_x: i32 = undefined;
        var offset_y: i32 = undefined;
        var width: u32 = undefined;
        var height: u32 = undefined;

        switch (render_area) {
            .entirety => {
                offset_x = 0;
                offset_y = 0;
                width = self.imageGetWidth(color_attachments[0].image.*);
                height = self.imageGetHeight(color_attachments[0].image.*);
            },
            .rectangle => |rectangle| {
                offset_x = rectangle.offset_x;
                offset_y = rectangle.offset_y;
                width = rectangle.width;
                height = rectangle.height;
            },
        }

        self.beginPassGeneric(pass_id, .{
            .raster = .{
                .render_offset_x = offset_x,
                .render_offset_y = offset_y,
                .render_width = width,
                .render_height = height,
                .attachments = attachments_allocated,
                .depth_attachment = if (depth_attachment != null) .{
                    .image = switch (depth_attachment.?) {
                        .read_only => |read_only_depth| self.images.items(.handle)[read_only_depth.image.index],
                        .read_write => |read_write_depth| self.images.items(.handle)[read_write_depth.image.index],
                    },
                    .clear = switch (depth_attachment.?) {
                        .read_only => null,
                        .read_write => |read_write_depth| read_write_depth.clear,
                    },
                    .store = switch (depth_attachment.?) {
                        .read_only => false,
                        .read_write => |read_write_depth| read_write_depth.store,
                    },
                } else null,
            },
        });

        self.debug_info.addPass(self.*, src, .{ .id = pass_id });

        for (color_attachments) |attachment| {
            self.referenceImageAsInput(attachment.image.*);

            attachment.image.pass_index = @intCast(self.current_pass_index);
        }

        if (depth_attachment != null) {
            switch (depth_attachment.?) {
                .read_only => @panic("not yet supported"),
                .read_write => |read_write_depth| {
                    self.referenceImageAsInput(read_write_depth.image.*);

                    read_write_depth.image.pass_index = @intCast(self.current_pass_index);
                },
            }
        }
    }

    pub fn endRasterPass(
        self: *@This(),
    ) void {
        self.endPassGeneric();
    }

    fn beginPassGeneric(
        self: *@This(),
        id: u64,
        data: PassData,
    ) void {
        self.current_pass_index = @intCast(self.passes.len);

        self.passes.append(self.gpa, .{
            .handle = .{ .id = id },
            .reference_count = 0,
            .command_offset = @intCast(self.commands.tags.items.len),
            .command_count = 0,
            .command_data_offset = @intCast(self.commands.data.items.len),
            .data = data,
            .input_offset = @intCast(self.pass_inputs.len),
            .input_count = 0,
        }) catch @panic("oom");
    }

    fn endPassGeneric(
        self: *@This(),
    ) void {
        const command_count = self.commands.tags.items.len - self.passes.items(.command_offset)[self.current_pass_index];
        const input_count = self.pass_inputs.len - self.passes.items(.input_offset)[self.current_pass_index];

        self.passes.items(.command_count)[self.current_pass_index] = @intCast(command_count);
        self.passes.items(.input_count)[self.current_pass_index] = @intCast(input_count);
    }

    pub fn setRasterPipeline(
        self: *@This(),
        pipeline: RasterPipeline,
    ) void {
        const pipeline_index = self.referenceRasterPipeline(pipeline);
        _ = pipeline_index; // autofix

        self.commands.add(self.gpa, .{
            .set_raster_pipeline = .{
                .pipeline = pipeline,
            },
        });
    }

    pub fn setPushData(
        self: *@This(),
        comptime T: type,
        data: T,
    ) void {
        self.commands.add(self.gpa, .{
            .set_push_data = .{
                .contents = self.scratch_allocator.allocator().dupe(u8, std.mem.asBytes(&data)) catch @panic("oom"),
            },
        });
    }

    ///Dynamically set a resource binding in a shader interface
    pub fn setRasterPipelineResourceBuffer(
        self: *@This(),
        pipeline: RasterPipeline,
        binding_index: u32,
        array_index: u32,
        buffer: Buffer,
    ) void {
        self.referenceBufferAsInput(buffer);

        self.commands.add(self.gpa, .{
            .set_raster_pipeline_resource_buffer = .{
                .pipeline = pipeline,
                .binding_index = binding_index,
                .array_index = array_index,
                .buffer = self.buffers.items(.handle)[buffer.index],
            },
        });
    }

    pub fn setRasterPipelineImageSampler(
        self: *@This(),
        pipeline: RasterPipeline,
        binding_index: u32,
        array_index: u32,
        image: Image,
        sampler: Sampler,
    ) void {
        self.referenceImageAsInput(image);
        _ = self.referenceResource(sampler);

        self.commands.add(self.gpa, .{
            .set_raster_pipeline_image_sampler = .{
                .pipeline = pipeline,
                .binding_index = binding_index,
                .array_index = array_index,
                .image = self.images.items(.handle)[image.index],
                .sampler = sampler,
            },
        });
    }

    pub fn setViewport(
        self: *@This(),
        x: f32,
        y: f32,
        width: f32,
        height: f32,
        min_depth: f32,
        max_depth: f32,
    ) void {
        self.commands.add(self.gpa, .{
            .set_viewport = .{
                .x = x,
                .y = y,
                .width = width,
                .height = height,
                .min_depth = min_depth,
                .max_depth = max_depth,
            },
        });
    }

    pub fn setScissor(
        self: *@This(),
        x: u32,
        y: u32,
        width: u32,
        height: u32,
    ) void {
        self.commands.add(self.gpa, .{
            .set_scissor = .{
                .x = x,
                .y = y,
                .width = width,
                .height = height,
            },
        });
    }

    pub fn setIndexBuffer(
        self: *@This(),
        buffer: Buffer,
        index_type: IndexType,
    ) void {
        self.referenceBufferAsInput(buffer);

        self.commands.add(self.gpa, .{
            .set_index_buffer = .{
                .index_buffer = self.buffers.items(.handle)[buffer.index],
                .type = index_type,
            },
        });
    }

    pub fn drawIndexed(
        self: *@This(),
        index_count: u32,
        instance_count: u32,
        first_index: u32,
        vertex_offset: i32,
        first_instance: u32,
    ) void {
        self.commands.add(self.gpa, .{
            .draw_indexed = .{
                .index_count = index_count,
                .instance_count = instance_count,
                .first_index = first_index,
                .vertex_offset = vertex_offset,
                .first_instance = first_instance,
            },
        });
    }

    pub fn drawIndexedIndirectCount(
        self: *@This(),
        draw_buffer: Buffer,
        draw_buffer_offset: usize,
        draw_buffer_stride: usize,
        count_buffer: Buffer,
        count_buffer_offset: usize,
        max_draw_count: usize,
    ) void {
        self.referenceBufferAsInput(draw_buffer);
        self.referenceBufferAsInput(count_buffer);

        self.commands.add(self.gpa, .{
            .draw_indexed_indirect_count = .{
                .draw_buffer = self.buffers.items(.handle)[draw_buffer.index],
                .draw_buffer_offset = draw_buffer_offset,
                .draw_buffer_stride = draw_buffer_stride,
                .count_buffer = self.buffers.items(.handle)[count_buffer.index],
                .count_buffer_offset = count_buffer_offset,
                .max_draw_count = max_draw_count,
            },
        });
    }

    pub fn draw(
        self: *@This(),
        vertex_count: u32,
        instance_count: u32,
        first_vertex: u32,
        first_instance: u32,
    ) void {
        self.commands.add(self.gpa, .{
            .draw = .{
                .vertex_count = vertex_count,
                .instance_count = instance_count,
                .first_vertex = first_vertex,
                .first_instance = first_instance,
            },
        });
    }

    pub fn setComputePipeline(
        self: *@This(),
        pipeline: ComputePipeline,
    ) void {
        self.commands.add(self.gpa, .{
            .set_compute_pipeline = .{
                .pipeline = pipeline,
            },
        });
    }

    pub fn computeDispatch(
        self: *@This(),
        thread_count_x: u32,
        thread_count_y: u32,
        thread_count_z: u32,
    ) void {
        self.commands.add(self.gpa, .{
            .compute_dispatch = .{
                .thread_count_x = thread_count_x,
                .thread_count_y = thread_count_y,
                .thread_count_z = thread_count_z,
            },
        });
    }

    ///References a buffer as an input to a pass
    fn referenceBufferAsInput(self: *@This(), buffer: Buffer) void {
        self.referenceBuffer(buffer);

        if (buffer.pass_index == null) return;

        //TODO: handle intrapass depedencies
        if (buffer.pass_index.? == self.current_pass_index) return;

        for (self.pass_inputs.items(.resource_handle)) |handle| {
            if (handle.id == @intFromEnum(self.buffers.items(.handle)[buffer.index])) return;
        }

        self.pass_inputs.append(self.gpa, .{
            .pass_index = buffer.pass_index.?,
            .resource_type = .buffer,
            .resource_handle = .{ .id = @intFromEnum(self.buffers.items(.handle)[buffer.index]) },
        }) catch @panic("oom");
    }

    ///Incrementes the refence count for buffer and resolves the buffer index
    pub fn referenceBuffer(self: *@This(), buffer: Buffer) void {
        self.buffers.items(.reference_count)[buffer.index] += 1;
    }

    ///References a buffer as an input to a pass
    fn referenceImageAsInput(self: *@This(), image: Image) void {
        self.referenceImage(image);

        if (image.pass_index == null) return;

        //Avoid cyclic depdedency on current pass
        //TODO: handle intrapass depedencies
        if (image.pass_index.? == self.current_pass_index) return;

        for (self.pass_inputs.items(.resource_handle)[self.passes.items(.input_offset)[self.current_pass_index]..]) |handle| {
            if (handle.id == @intFromEnum(self.images.items(.handle)[image.index])) return;
        }

        self.pass_inputs.append(self.gpa, .{
            .pass_index = image.pass_index.?,
            .resource_type = .image,
            .resource_handle = .{ .id = @intFromEnum(self.images.items(.handle)[image.index]) },
        }) catch @panic("oom");
    }

    ///Incrementes the refence count for buffer and resolves the buffer index
    pub fn referenceImage(self: *@This(), image: Image) void {
        self.images.items(.reference_count)[image.index] += 1;
    }

    ///Incrementes the refence count for buffer and resolves the buffer index
    pub fn referenceRasterPipeline(self: *@This(), pipeline: RasterPipeline) usize {
        return self.referenceResource(pipeline);
    }

    pub fn passCommandIterator(self: *const @This(), pass_index: u32) Commands.Iterator {
        const command_offset = self.passes.items(.command_offset)[pass_index];
        const command_count = self.passes.items(.command_count)[pass_index];
        const command_data_offset = self.passes.items(.command_data_offset)[pass_index];

        return self.commands.iterator(
            command_offset,
            command_count,
            command_data_offset,
        );
    }

    ///Incrementes the refence count for buffer and resolves the resource index
    fn referenceResource(self: *@This(), resource: anytype) usize {
        const resources = switch (@TypeOf(resource)) {
            RasterPipeline => &self.raster_pipelines,
            Buffer => &self.buffers,
            Image => &self.images,
            Sampler => &self.samplers,
            else => @compileError("Resource Type not yet supported"),
        };

        const handles = resources.items(.handle);

        //TODO: implement more scalable way to search for buffers (bin into buckets?)
        for (handles, 0..) |handle, buffer_index| {
            if (handle.id == resource.id) {
                resources.items(.reference_count)[buffer_index] += 1;

                return buffer_index;
            }
        }

        @panic("Invalid resource handle");
    }

    ///Returns a unique id (for resources and passes) based on source location
    ///By definition going to be unique for each call to a function assuming correct use of @src()
    fn idFromSourceLocation(src: SourceLocation) u64 {
        @setEvalBranchQuota(10000);

        var hasher = std.hash.SipHash64(2, 4).init("ID" ** 8);

        std.hash.autoHashStrat(&hasher, src, std.hash.Strategy.Deep);

        return hasher.finalInt();
    }

    fn idFromSourceLocationAndInt(comptime src: SourceLocation, identifier: u64) u64 {
        const comptime_id = comptime idFromSourceLocation(src);

        //TODO: Is there a better way to combine hashes for this
        //EG: H(x, y) = AH(x) + H(y), where A is a large odd constant
        return comptime_id +% identifier;
    }

    pub const SourceLocation = std.builtin.SourceLocation;
};

pub const ResourceType = enum {
    buffer,
    image,
};

///TODO: provide specialisation constants
pub const RasterModule = struct {
    ///Graphics API specific code
    code: []align(4) const u8,
};

pub const ComputeModule = struct {
    ///Graphics API specific code
    code: []align(4) const u8,
};

pub const RasterPipeline = struct {
    id: u64,
};

pub const ComputePipeline = struct {
    id: u64,
};

pub const Sampler = struct {
    id: u64,
};

pub const Buffer = struct {
    index: u32,
    pass_index: ?u31,
};

pub const Image = struct {
    index: u32,
    pass_index: ?u31,
};

///A persistant handle to a buffer that can be stored between graph builds
pub const BufferHandle = enum(u64) { _ };
///A persistant handle to a image that can be stored between graph builds
pub const ImageHandle = enum(u64) { _ };

///Generic type erased persistant handle resource
pub const ResourceHandle = packed struct(u64) {
    id: u64,
};

pub const PassHandle = packed struct(u64) {
    id: u64,
};

pub const ImageSubresource = struct {
    mip_level: u32,
    base_array_layer: u32,
    layer_count: u32,
};

pub const BlitRegion = struct {
    src_subresource: ImageSubresource,
    src_offset: @Vector(3, i32) = .{ 0, 0, 0 },
    src_extent: @Vector(3, i32),
    dst_subresource: ImageSubresource,
    dst_offset: @Vector(3, i32) = .{ 0, 0, 0 },
    dst_extent: @Vector(3, i32),
};

pub const ImageFormat = enum(u32) {
    undefined = 0,
    r4g4_unorm_pack8 = 1,
    r4g4b4a4_unorm_pack16 = 2,
    b4g4r4a4_unorm_pack16 = 3,
    r5g6b5_unorm_pack16 = 4,
    b5g6r5_unorm_pack16 = 5,
    r5g5b5a1_unorm_pack16 = 6,
    b5g5r5a1_unorm_pack16 = 7,
    a1r5g5b5_unorm_pack16 = 8,
    r8_unorm = 9,
    r8_snorm = 10,
    r8_uscaled = 11,
    r8_sscaled = 12,
    r8_uint = 13,
    r8_sint = 14,
    r8_srgb = 15,
    r8g8_unorm = 16,
    r8g8_snorm = 17,
    r8g8_uscaled = 18,
    r8g8_sscaled = 19,
    r8g8_uint = 20,
    r8g8_sint = 21,
    r8g8_srgb = 22,
    r8g8b8_unorm = 23,
    r8g8b8_snorm = 24,
    r8g8b8_uscaled = 25,
    r8g8b8_sscaled = 26,
    r8g8b8_uint = 27,
    r8g8b8_sint = 28,
    r8g8b8_srgb = 29,
    b8g8r8_unorm = 30,
    b8g8r8_snorm = 31,
    b8g8r8_uscaled = 32,
    b8g8r8_sscaled = 33,
    b8g8r8_uint = 34,
    b8g8r8_sint = 35,
    b8g8r8_srgb = 36,
    r8g8b8a8_unorm = 37,
    r8g8b8a8_snorm = 38,
    r8g8b8a8_uscaled = 39,
    r8g8b8a8_sscaled = 40,
    r8g8b8a8_uint = 41,
    r8g8b8a8_sint = 42,
    r8g8b8a8_srgb = 43,
    b8g8r8a8_unorm = 44,
    b8g8r8a8_snorm = 45,
    b8g8r8a8_uscaled = 46,
    b8g8r8a8_sscaled = 47,
    b8g8r8a8_uint = 48,
    b8g8r8a8_sint = 49,
    b8g8r8a8_srgb = 50,
    a8b8g8r8_unorm_pack32 = 51,
    a8b8g8r8_snorm_pack32 = 52,
    a8b8g8r8_uscaled_pack32 = 53,
    a8b8g8r8_sscaled_pack32 = 54,
    a8b8g8r8_uint_pack32 = 55,
    a8b8g8r8_sint_pack32 = 56,
    a8b8g8r8_srgb_pack32 = 57,
    a2r10g10b10_unorm_pack32 = 58,
    a2r10g10b10_snorm_pack32 = 59,
    a2r10g10b10_uscaled_pack32 = 60,
    a2r10g10b10_sscaled_pack32 = 61,
    a2r10g10b10_uint_pack32 = 62,
    a2r10g10b10_sint_pack32 = 63,
    a2b10g10r10_unorm_pack32 = 64,
    a2b10g10r10_snorm_pack32 = 65,
    a2b10g10r10_uscaled_pack32 = 66,
    a2b10g10r10_sscaled_pack32 = 67,
    a2b10g10r10_uint_pack32 = 68,
    a2b10g10r10_sint_pack32 = 69,
    r16_unorm = 70,
    r16_snorm = 71,
    r16_uscaled = 72,
    r16_sscaled = 73,
    r16_uint = 74,
    r16_sint = 75,
    r16_sfloat = 76,
    r16g16_unorm = 77,
    r16g16_snorm = 78,
    r16g16_uscaled = 79,
    r16g16_sscaled = 80,
    r16g16_uint = 81,
    r16g16_sint = 82,
    r16g16_sfloat = 83,
    r16g16b16_unorm = 84,
    r16g16b16_snorm = 85,
    r16g16b16_uscaled = 86,
    r16g16b16_sscaled = 87,
    r16g16b16_uint = 88,
    r16g16b16_sint = 89,
    r16g16b16_sfloat = 90,
    r16g16b16a16_unorm = 91,
    r16g16b16a16_snorm = 92,
    r16g16b16a16_uscaled = 93,
    r16g16b16a16_sscaled = 94,
    r16g16b16a16_uint = 95,
    r16g16b16a16_sint = 96,
    r16g16b16a16_sfloat = 97,
    r32_uint = 98,
    r32_sint = 99,
    r32_sfloat = 100,
    r32g32_uint = 101,
    r32g32_sint = 102,
    r32g32_sfloat = 103,
    r32g32b32_uint = 104,
    r32g32b32_sint = 105,
    r32g32b32_sfloat = 106,
    r32g32b32a32_uint = 107,
    r32g32b32a32_sint = 108,
    r32g32b32a32_sfloat = 109,
    r64_uint = 110,
    r64_sint = 111,
    r64_sfloat = 112,
    r64g64_uint = 113,
    r64g64_sint = 114,
    r64g64_sfloat = 115,
    r64g64b64_uint = 116,
    r64g64b64_sint = 117,
    r64g64b64_sfloat = 118,
    r64g64b64a64_uint = 119,
    r64g64b64a64_sint = 120,
    r64g64b64a64_sfloat = 121,
    b10g11r11_ufloat_pack32 = 122,
    e5b9g9r9_ufloat_pack32 = 123,
    d16_unorm = 124,
    x8_d24_unorm_pack32 = 125,
    d32_sfloat = 126,
    s8_uint = 127,
    d16_unorm_s8_uint = 128,
    d24_unorm_s8_uint = 129,
    d32_sfloat_s8_uint = 130,
    bc1_rgb_unorm_block = 131,
    bc1_rgb_srgb_block = 132,
    bc1_rgba_unorm_block = 133,
    bc1_rgba_srgb_block = 134,
    bc2_unorm_block = 135,
    bc2_srgb_block = 136,
    bc3_unorm_block = 137,
    bc3_srgb_block = 138,
    bc4_unorm_block = 139,
    bc4_snorm_block = 140,
    bc5_unorm_block = 141,
    bc5_snorm_block = 142,
    bc6h_ufloat_block = 143,
    bc6h_sfloat_block = 144,
    bc7_unorm_block = 145,
    bc7_srgb_block = 146,
    etc2_r8g8b8_unorm_block = 147,
    etc2_r8g8b8_srgb_block = 148,
    etc2_r8g8b8a1_unorm_block = 149,
    etc2_r8g8b8a1_srgb_block = 150,
    etc2_r8g8b8a8_unorm_block = 151,
    etc2_r8g8b8a8_srgb_block = 152,
    eac_r11_unorm_block = 153,
    eac_r11_snorm_block = 154,
    eac_r11g11_unorm_block = 155,
    eac_r11g11_snorm_block = 156,
    astc_4x_4_unorm_block = 157,
    astc_4x_4_srgb_block = 158,
    astc_5x_4_unorm_block = 159,
    astc_5x_4_srgb_block = 160,
    astc_5x_5_unorm_block = 161,
    astc_5x_5_srgb_block = 162,
    astc_6x_5_unorm_block = 163,
    astc_6x_5_srgb_block = 164,
    astc_6x_6_unorm_block = 165,
    astc_6x_6_srgb_block = 166,
    astc_8x_5_unorm_block = 167,
    astc_8x_5_srgb_block = 168,
    astc_8x_6_unorm_block = 169,
    astc_8x_6_srgb_block = 170,
    astc_8x_8_unorm_block = 171,
    astc_8x_8_srgb_block = 172,
    astc_1_0x_5_unorm_block = 173,
    astc_1_0x_5_srgb_block = 174,
    astc_1_0x_6_unorm_block = 175,
    astc_1_0x_6_srgb_block = 176,
    astc_1_0x_8_unorm_block = 177,
    astc_1_0x_8_srgb_block = 178,
    astc_1_0x_10_unorm_block = 179,
    astc_1_0x_10_srgb_block = 180,
    astc_1_2x_10_unorm_block = 181,
    astc_1_2x_10_srgb_block = 182,
    astc_1_2x_12_unorm_block = 183,
    astc_1_2x_12_srgb_block = 184,
    g8b8g8r8_422_unorm = 1000156000,
    b8g8r8g8_422_unorm = 1000156001,
    g8_b8_r8_3plane_420_unorm = 1000156002,
    g8_b8r8_2plane_420_unorm = 1000156003,
    g8_b8_r8_3plane_422_unorm = 1000156004,
    g8_b8r8_2plane_422_unorm = 1000156005,
    g8_b8_r8_3plane_444_unorm = 1000156006,
    r10x6_unorm_pack16 = 1000156007,
    r10x6g10x6_unorm_2pack16 = 1000156008,
    r10x6g10x6b10x6a10x6_unorm_4pack16 = 1000156009,
    g10x6b10x6g10x6r10x6_422_unorm_4pack16 = 1000156010,
    b10x6g10x6r10x6g10x6_422_unorm_4pack16 = 1000156011,
    g10x6_b10x6_r10x6_3plane_420_unorm_3pack16 = 1000156012,
    g10x6_b10x6r10x6_2plane_420_unorm_3pack16 = 1000156013,
    g10x6_b10x6_r10x6_3plane_422_unorm_3pack16 = 1000156014,
    g10x6_b10x6r10x6_2plane_422_unorm_3pack16 = 1000156015,
    g10x6_b10x6_r10x6_3plane_444_unorm_3pack16 = 1000156016,
    r12x4_unorm_pack16 = 1000156017,
    r12x4g12x4_unorm_2pack16 = 1000156018,
    r12x4g12x4b12x4a12x4_unorm_4pack16 = 1000156019,
    g12x4b12x4g12x4r12x4_422_unorm_4pack16 = 1000156020,
    b12x4g12x4r12x4g12x4_422_unorm_4pack16 = 1000156021,
    g12x4_b12x4_r12x4_3plane_420_unorm_3pack16 = 1000156022,
    g12x4_b12x4r12x4_2plane_420_unorm_3pack16 = 1000156023,
    g12x4_b12x4_r12x4_3plane_422_unorm_3pack16 = 1000156024,
    g12x4_b12x4r12x4_2plane_422_unorm_3pack16 = 1000156025,
    g12x4_b12x4_r12x4_3plane_444_unorm_3pack16 = 1000156026,
    g16b16g16r16_422_unorm = 1000156027,
    b16g16r16g16_422_unorm = 1000156028,
    g16_b16_r16_3plane_420_unorm = 1000156029,
    g16_b16r16_2plane_420_unorm = 1000156030,
    g16_b16_r16_3plane_422_unorm = 1000156031,
    g16_b16r16_2plane_422_unorm = 1000156032,
    g16_b16_r16_3plane_444_unorm = 1000156033,
    g8_b8r8_2plane_444_unorm = 1000330000,
    g10x6_b10x6r10x6_2plane_444_unorm_3pack16 = 1000330001,
    g12x4_b12x4r12x4_2plane_444_unorm_3pack16 = 1000330002,
    g16_b16r16_2plane_444_unorm = 1000330003,
    a4r4g4b4_unorm_pack16 = 1000340000,
    a4b4g4r4_unorm_pack16 = 1000340001,
    astc_4x_4_sfloat_block = 1000066000,
    astc_5x_4_sfloat_block = 1000066001,
    astc_5x_5_sfloat_block = 1000066002,
    astc_6x_5_sfloat_block = 1000066003,
    astc_6x_6_sfloat_block = 1000066004,
    astc_8x_5_sfloat_block = 1000066005,
    astc_8x_6_sfloat_block = 1000066006,
    astc_8x_8_sfloat_block = 1000066007,
    astc_1_0x_5_sfloat_block = 1000066008,
    astc_1_0x_6_sfloat_block = 1000066009,
    astc_1_0x_8_sfloat_block = 1000066010,
    astc_1_0x_10_sfloat_block = 1000066011,
    astc_1_2x_10_sfloat_block = 1000066012,
    astc_1_2x_12_sfloat_block = 1000066013,
    pvrtc1_2bpp_unorm_block_img = 1000054000,
    pvrtc1_4bpp_unorm_block_img = 1000054001,
    pvrtc2_2bpp_unorm_block_img = 1000054002,
    pvrtc2_4bpp_unorm_block_img = 1000054003,
    pvrtc1_2bpp_srgb_block_img = 1000054004,
    pvrtc1_4bpp_srgb_block_img = 1000054005,
    pvrtc2_2bpp_srgb_block_img = 1000054006,
    pvrtc2_4bpp_srgb_block_img = 1000054007,
    r16g16_s10_5_nv = 1000464000,
};

test {
    std.testing.refAllDecls(@This());
}

const Graph = @This();
const std = @import("std");
const DebugInfo = @import("debug.zig").DebugInfo;
