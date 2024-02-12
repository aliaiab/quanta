//!Render Graph implementation built on top of quanta.graphics
//!TODO: implement unit testing and runtime validation

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
        self.tags.append(allocator, command) catch unreachable;

        switch (command) {
            inline else => |command_data| {
                self.data.appendSlice(
                    allocator,
                    std.mem.asBytes(&command_data),
                ) catch unreachable;
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
    allocator: std.mem.Allocator,
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
        format: ImageFormat,
        width: u32,
        height: u32,
        depth: u32,
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
            },
        },
        compute: void,
    };

    pub fn init(allocator: std.mem.Allocator) @This() {
        return .{
            .allocator = allocator,
            .scratch_allocator = std.heap.ArenaAllocator.init(allocator),
            .current_pass_index = 0,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.raster_pipelines.deinit(self.allocator);
        self.compute_pipelines.deinit(self.allocator);
        self.buffers.deinit(self.allocator);
        self.images.deinit(self.allocator);
        self.samplers.deinit(self.allocator);

        self.passes.deinit(self.allocator);
        self.pass_inputs.deinit(self.allocator);

        self.debug_info.deinit(self.*);

        self.persistant_buffers.deinit(self.allocator);
        self.persistant_images.deinit(self.allocator);

        self.commands.deinit(self.allocator);
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

        _ = self.scratch_allocator.reset(std.heap.ArenaAllocator.ResetMode{ .retain_capacity = {} });
    }

    pub fn scratchAlloc(self: *@This(), comptime T: type, count: usize) []T {
        return self.scratch_allocator.allocator().alloc(T, count) catch unreachable;
    }

    pub fn scratchDupe(self: *@This(), comptime T: type, values: []const T) []T {
        return self.scratch_allocator.allocator().dupe(T, values) catch unreachable;
    }

    const CreateRasterPipelineOptions = struct {
        attachment_formats: []const ImageFormat,
        depth_attachment_format: ImageFormat = .undefined,
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

        self.raster_pipelines.append(self.allocator, .{
            .handle = handle,
            .vertex_module = vertex_module,
            .fragment_module = fragment_module,
            .reference_count = 0,
            .push_constant_size = @intCast(push_constant_size),
            .attachment_formats = self.scratch_allocator.allocator().dupe(ImageFormat, options.attachment_formats) catch unreachable,
            .depth_attachment_format = options.depth_attachment_format,
            .depth_state = options.depth_state,
            .rasterisation_state = options.rasterisation_state,
            .blend_state = options.blend_state,
        }) catch unreachable;

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

        self.compute_pipelines.append(self.allocator, .{
            .handle = handle,
            .module = module,
            .reference_count = 0,
            .push_constant_size = @intCast(push_constant_size),
        }) catch unreachable;

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

        self.buffers.append(self.allocator, .{
            .handle = handle,
            .size = options.size,
            .reference_count = 0,
        }) catch unreachable;

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

    ///Return the persistant handle for image
    ///Can be stored outside of the render graph and then reimported using imageFromHandle in another instance of this graph
    ///Implicitly creates a persistant handle mapping
    pub fn bufferGetPersistantHandle(
        self: *@This(),
        buffer: Buffer,
    ) BufferHandle {
        const handle = self.buffers.items(.handle)[buffer.index];

        const maybe_buffer = self.persistant_buffers.getOrPut(self.allocator, handle) catch unreachable;

        if (!maybe_buffer.found_existing) {
            maybe_buffer.value_ptr.* = .{
                .size = self.buffers.items(.size)[buffer.index],
            };
        }

        return handle;
    }

    ///Create an buffer pointer from a handle
    ///Returns an image that is identical to the image returned from the last createImage called on that handle
    pub fn bufferFromPersistantHandle(
        self: *@This(),
        buffer_handle: BufferHandle,
    ) Image {
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

            self.buffers.append(self.allocator, .{
                .handle = buffer_handle,
                .size = maybe_buffer.?.size,
                .reference_count = 0,
            }) catch unreachable;

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
        const buffer_info = self.persistant_buffers.get(buffer_handle) orelse unreachable;

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
        },
    ) Image {
        //TODO: store a identifier base to allow for looped calls with the same src location to produce different handles
        const handle_id = idFromSourceLocationAndInt(src, options.identifier);

        const handle: ImageHandle = @enumFromInt(handle_id);

        const index: u32 = @intCast(self.images.len);

        self.images.append(self.allocator, .{
            .handle = handle,
            .format = options.format,
            .reference_count = 0,
            .width = options.width,
            .height = options.height,
            .depth = options.depth,
        }) catch unreachable;

        return .{
            .index = index,
            .pass_index = null,
        };
    }

    ///Create an image pointer from a handle
    ///The handle for image must have been created during the graph instance using createImage
    pub fn imageFromHandle(
        self: *@This(),
        image_handle: ImageHandle,
    ) Image {
        for (self.images.items(.handle), 0..) |handle, image_index| {
            if (handle == image_handle) return image_index;
        }

        @panic("Invalid image handle");
    }

    ///Return the persistant handle for image
    ///Can be stored outside of the render graph and then reimported using imageFromHandle in another instance of this graph
    pub fn imageGetHandle(
        self: *@This(),
        image: Image,
    ) ImageHandle {
        return self.images.items(.handle)[image.index];
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

        self.samplers.append(self.allocator, .{
            .handle = .{ .id = handle_id },
            .reference_count = 0,
            .min_filter = options.min_filter,
            .mag_filter = options.mag_filter,
            .address_mode_u = options.address_mode_u,
            .address_mode_v = options.address_mode_v,
            .address_mode_w = options.address_mode_w,
            .reduction_mode = options.reduction_mode,
        }) catch unreachable;

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
        buffer: *Buffer,
        buffer_offset: usize,
        comptime T: type,
        contents: []const T,
    ) void {
        if (contents.len == 0) return;

        _ = self.referenceBufferAsInput(buffer.*);

        self.commands.add(self.allocator, .{
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
        const contents = self.scratch_allocator.allocator().alloc(T, 1) catch unreachable;

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

        self.commands.add(self.allocator, .{
            .update_image = .{
                .image = self.images.items(.handle)[image.index],
                .image_offset = offset,
                .contents = std.mem.sliceAsBytes(contents),
            },
        });

        image.pass_index = @intCast(self.current_pass_index);
    }

    pub const ColorAttachment = struct {
        image: ImageHandle,
        clear: ?[4]f32 = null,
        store: bool = true,
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
            ///TODO: determine this at graph compile?
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

        const attachments_allocated = self.scratch_allocator.allocator().alloc(ColorAttachment, color_attachments.len) catch unreachable;

        for (attachments_allocated, color_attachments) |*attachment_allocated, attachment| {
            attachment_allocated.* = .{
                .image = self.images.items(.handle)[attachment.image.index],
                .clear = attachment.clear,
                .store = attachment.store,
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

        self.passes.append(self.allocator, .{
            .handle = .{ .id = id },
            .reference_count = 0,
            .command_offset = @intCast(self.commands.tags.items.len),
            .command_count = 0,
            .command_data_offset = @intCast(self.commands.data.items.len),
            .data = data,
            .input_offset = @intCast(self.pass_inputs.len),
            .input_count = 0,
        }) catch unreachable;
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

        self.commands.add(self.allocator, .{
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
        self.commands.add(self.allocator, .{
            .set_push_data = .{
                .contents = self.scratch_allocator.allocator().dupe(u8, std.mem.asBytes(&data)) catch unreachable,
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

        self.commands.add(self.allocator, .{
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

        self.commands.add(self.allocator, .{
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
        self.commands.add(self.allocator, .{
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
        self.commands.add(self.allocator, .{
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

        self.commands.add(self.allocator, .{
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
        self.commands.add(self.allocator, .{
            .draw_indexed = .{
                .index_count = index_count,
                .instance_count = instance_count,
                .first_index = first_index,
                .vertex_offset = vertex_offset,
                .first_instance = first_instance,
            },
        });
    }

    pub fn setComputePipeline(
        self: *@This(),
        pipeline: ComputePipeline,
    ) void {
        self.commands.add(self.allocator, .{
            .set_compute_pipeline = .{
                .pipeline = pipeline,
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

        self.pass_inputs.append(self.allocator, .{
            .pass_index = buffer.pass_index.?,
            .resource_type = .buffer,
            .resource_handle = .{ .id = @intFromEnum(self.buffers.items(.handle)[buffer.index]) },
        }) catch unreachable;
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

        self.pass_inputs.append(self.allocator, .{
            .pass_index = image.pass_index.?,
            .resource_type = .image,
            .resource_handle = .{ .id = @intFromEnum(self.images.items(.handle)[image.index]) },
        }) catch unreachable;
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

///Contains all graphics resources (pipelines, buffers, textures ect..)
pub const CompileContext = struct {
    allocator: std.mem.Allocator,
    scratch_allocator: std.heap.ArenaAllocator,
    cpu_buffer: [cpu_buffer_count]struct {
        graphics_command_buffer: ?graphics.CommandBuffer = null,

        staging_buffer: ?graphics.Buffer = null,
        staging_buffer_size: usize = 0,
        staging_buffer_offset: usize = 0,
        staging_buffer_mapping: [*]u8 = undefined,
    },
    buffer_index: u32 = 0,

    //TODO: exploit SourceLocation to make a more efficient mapping
    raster_pipelines: std.AutoArrayHashMapUnmanaged(u64, graphics.GraphicsPipeline) = .{},
    compute_pipelines: std.AutoArrayHashMapUnmanaged(ComputePipeline, graphics.ComputePipeline) = .{},
    buffers: std.AutoArrayHashMapUnmanaged(BufferHandle, graphics.Buffer) = .{},
    images: std.AutoArrayHashMapUnmanaged(ImageHandle, struct {
        imported: bool = false,
        //TODO: use pointer for external image maybe?
        image: graphics.Image,
    }) = .{},
    samplers: std.AutoArrayHashMapUnmanaged(u64, graphics.Sampler) = .{},

    ///The number of bufferred command/staging buffers to keep around for gpu/cpu parralelism
    ///This is completely unrelated and independent from swapchain buffering
    const cpu_buffer_count = 2;

    pub fn init(allocator: std.mem.Allocator) CompileContext {
        var self: CompileContext = .{
            .allocator = allocator,
            .scratch_allocator = std.heap.ArenaAllocator.init(allocator),
            .cpu_buffer = undefined,
        };

        for (0..cpu_buffer_count) |i| {
            self.cpu_buffer[i] = .{};
        }

        return self;
    }

    pub fn deinit(self: *@This()) void {
        for (self.raster_pipelines.values()) |*raster_pipeline| {
            raster_pipeline.deinit(self.allocator);
        }

        for (self.compute_pipelines.values()) |*compute_pipeline| {
            compute_pipeline.deinit(self.allocator);
        }

        for (self.buffers.values()) |*buffer| {
            buffer.deinit();
        }

        for (self.images.values()) |*image| {
            if (!image.imported) {
                image.image.deinit();
            }
        }

        for (self.samplers.values()) |*sampler| {
            sampler.deinit();
        }

        for (&self.cpu_buffer) |*buffer| {
            if (buffer.graphics_command_buffer != null) buffer.graphics_command_buffer.?.deinit();

            if (buffer.staging_buffer != null) {
                buffer.staging_buffer.?.deinit();
            }
        }

        self.raster_pipelines.deinit(self.allocator);
        self.compute_pipelines.deinit(self.allocator);
        self.buffers.deinit(self.allocator);
        self.images.deinit(self.allocator);
        self.samplers.deinit(self.allocator);
        self.scratch_allocator.deinit();

        self.* = undefined;
    }

    ///Imports and underlying gpu api image and provides a handle that is usable from graph building code
    pub fn importExternalImage(
        self: *@This(),
        builder: *Builder,
        comptime src: std.builtin.SourceLocation,
        image: graphics.Image,
    ) Image {
        const image_pointer = builder.createImage(src, .{
            .format = @enumFromInt(@intFromEnum(image.format)),
            .width = image.width,
            .height = image.height,
            .depth = 1,
        });

        const get_or_put_result = self.images.getOrPut(self.allocator, builder.images.items(.handle)[image_pointer.index]) catch unreachable;

        get_or_put_result.value_ptr.image = image;
        get_or_put_result.value_ptr.imported = true;

        return image_pointer;
    }

    ///Compiles a built graph to low level api commands
    pub fn compile(
        self: *@This(),
        builder: *Builder,
    ) !CompileResult {
        defer {
            self.buffer_index += 1;
            self.buffer_index %= cpu_buffer_count;
        }

        defer _ = self.scratch_allocator.reset(.retain_capacity);

        const compile_buffer = &self.cpu_buffer[self.buffer_index];

        compile_buffer.staging_buffer_offset = 0;
        compile_buffer.staging_buffer_size = 0;

        if (compile_buffer.graphics_command_buffer == null) {
            compile_buffer.graphics_command_buffer = try graphics.CommandBuffer.init(.graphics);
        } else {
            compile_buffer.graphics_command_buffer.?.wait_fence.wait();
            compile_buffer.graphics_command_buffer.?.wait_fence.reset();
        }

        if (builder.export_resource == null) {
            //generate empty command buffer
            try compile_buffer.graphics_command_buffer.?.begin();

            return .{
                .graphics_command_buffer = &compile_buffer.graphics_command_buffer.?,
            };
        }

        //ordered list of dependencies for the root pass
        var dependencies: std.ArrayListUnmanaged(Dependency) = .{};
        defer dependencies.deinit(self.scratch_allocator.allocator());

        //Second pass: pass dependency analysis
        {
            //The first pass to evaluate. Evaluation goes bottom up (from last executed to first)
            const root_pass_index: u32 = switch (builder.export_resource.?) {
                .image => |image| image.pass_index.?,
                .buffer => |buffer| buffer.pass_index.?,
            };

            try self.compilePassDependencies(
                builder.*,
                root_pass_index,
                &dependencies,
            );
        }

        var buffer_usages: std.AutoArrayHashMapUnmanaged(BufferHandle, struct {
            usage: graphics.vulkan.BufferUsageFlags,
        }) = .{};
        defer buffer_usages.deinit(self.scratch_allocator.allocator());

        var image_usages: std.AutoArrayHashMapUnmanaged(ImageHandle, struct {
            usage: graphics.vulkan.ImageUsageFlags,
        }) = .{};
        defer image_usages.deinit(self.scratch_allocator.allocator());

        //usage mapping
        for (dependencies.items) |*dependency| {
            const pass_index = dependency.pass_index;
            const pass_data: Builder.PassData = builder.passes.items(.data)[pass_index];

            if (pass_data == .raster) {
                const attachments_input = pass_data.raster.attachments;

                for (attachments_input) |input| {
                    const result = try image_usages.getOrPutValue(
                        self.scratch_allocator.allocator(),
                        input.image,
                        .{
                            .usage = .{},
                        },
                    );

                    result.value_ptr.*.usage.color_attachment_bit = true;
                }

                if (pass_data.raster.depth_attachment != null) {
                    const result = try image_usages.getOrPutValue(
                        self.scratch_allocator.allocator(),
                        pass_data.raster.depth_attachment.?.image,
                        .{
                            .usage = .{},
                        },
                    );

                    result.value_ptr.*.usage.depth_stencil_attachment_bit = true;
                }
            }

            var command_iter = builder.passCommandIterator(dependency.pass_index);

            while (command_iter.next()) |command| {
                switch (command) {
                    .update_buffer => |command_data| {
                        const result = try buffer_usages.getOrPutValue(
                            self.scratch_allocator.allocator(),
                            command_data.buffer,
                            .{
                                .usage = .{},
                            },
                        );

                        result.value_ptr.*.usage.transfer_dst_bit = true;
                    },
                    .update_image => |command_data| {
                        const result = try image_usages.getOrPutValue(
                            self.scratch_allocator.allocator(),
                            command_data.image,
                            .{
                                .usage = .{},
                            },
                        );

                        result.value_ptr.*.usage.transfer_dst_bit = true;
                    },
                    .set_index_buffer => |command_data| {
                        const result = try buffer_usages.getOrPutValue(
                            self.scratch_allocator.allocator(),
                            command_data.index_buffer,
                            .{
                                .usage = .{},
                            },
                        );

                        result.value_ptr.*.usage.index_buffer_bit = true;
                    },
                    .set_raster_pipeline_resource_buffer => |command_data| {
                        const result = try buffer_usages.getOrPutValue(
                            self.scratch_allocator.allocator(),
                            command_data.buffer,
                            .{
                                .usage = .{},
                            },
                        );

                        result.value_ptr.*.usage.storage_buffer_bit = true;
                    },
                    .set_raster_pipeline_image_sampler => |command_data| {
                        const result = try image_usages.getOrPutValue(
                            self.scratch_allocator.allocator(),
                            command_data.image,
                            .{
                                .usage = .{},
                            },
                        );

                        result.value_ptr.usage.sampled_bit = true;
                    },
                    else => {},
                }
            }
        }

        //GPU Resource creation/fetching/allocation/deallocation/destruction pass
        //TODO: resource creation should be driven by the dependency graph, not static reference counts
        {
            for (builder.raster_pipelines.items(.reference_count), 0..) |reference_count, pipeline_index| {
                if (reference_count == 0) {
                    //TODO: deallocate unreferenced pipelines if they have a backing store
                    continue;
                }

                const handle: RasterPipeline = builder.raster_pipelines.items(.handle)[pipeline_index];

                const get_or_put_res = try self.raster_pipelines.getOrPut(self.allocator, handle.id);

                //cache hit
                if (get_or_put_res.found_existing) {
                    continue;
                }

                const pipeline = builder.raster_pipelines.get(pipeline_index);

                const vertex_module: RasterModule = builder.raster_pipelines.items(.vertex_module)[pipeline_index];
                const fragment_module: RasterModule = builder.raster_pipelines.items(.fragment_module)[pipeline_index];
                const push_constant_size = builder.raster_pipelines.items(.push_constant_size)[pipeline_index];
                const attachment_formats = builder.raster_pipelines.items(.attachment_formats)[pipeline_index];
                const depth_attachment_format = builder.raster_pipelines.items(.depth_attachment_format)[pipeline_index];

                get_or_put_res.value_ptr.* = try graphics.GraphicsPipeline.init(
                    self.allocator,
                    .{
                        .color_attachment_formats = @as([*]const graphics.vulkan.Format, @alignCast(@ptrCast(attachment_formats.ptr)))[0..attachment_formats.len],
                        .depth_attachment_format = @enumFromInt(@intFromEnum(depth_attachment_format)),
                        .vertex_shader_binary = @alignCast(vertex_module.code),
                        .fragment_shader_binary = @alignCast(fragment_module.code),
                        .depth_state = pipeline.depth_state,
                        .rasterisation_state = pipeline.rasterisation_state,
                        .blend_state = pipeline.blend_state,
                    },
                    //TODO: handle vertex layouts (if anyone's using that in 2024)
                    null,
                    push_constant_size,
                );
                errdefer get_or_put_res.value_ptr.deinit(self.allocator);
            }

            for (builder.buffers.items(.reference_count), 0..) |reference_count, buffer_index| {
                if (reference_count == 0) {
                    //TODO: deallocate unreferenced pipelines if they have a backing store
                    continue;
                }

                const handle = builder.buffers.items(.handle)[buffer_index];

                const get_or_put_res = try self.buffers.getOrPut(self.allocator, handle);

                const buffer_size = builder.buffers.items(.size)[buffer_index];

                //cache hit
                if (get_or_put_res.found_existing) {
                    //TODO: handle buffer resizing between frames
                    std.debug.assert(get_or_put_res.value_ptr.size == buffer_size);

                    continue;
                }

                get_or_put_res.value_ptr.* = try graphics.Buffer.initUsageFlags(
                    buffer_size,
                    buffer_usages.get(handle).?.usage,
                );
                errdefer get_or_put_res.value_ptr.deinit();

                const maybe_buffer_name = builder.debug_info.getBufferName(builder.*, handle);

                if (maybe_buffer_name) |buffer_name| {
                    get_or_put_res.value_ptr.*.debugSetName(buffer_name);
                }
            }

            for (builder.images.items(.reference_count), 0..) |reference_count, image_index| {
                if (reference_count == 0) {
                    //TODO: deallocate unreferenced pipelines if they have a backing store
                    continue;
                }

                const handle = builder.images.items(.handle)[image_index];

                const image_width = builder.images.items(.width)[image_index];
                const image_height = builder.images.items(.height)[image_index];
                const image_depth = builder.images.items(.depth)[image_index];
                const image_format = builder.images.items(.format)[image_index];

                const get_or_put_res = try self.images.getOrPut(self.allocator, handle);

                //cache hit
                if (get_or_put_res.found_existing) {
                    if (image_width != get_or_put_res.value_ptr.image.width) {
                        std.log.info("image_width: {}, actual_width: {}", .{
                            image_width,
                            get_or_put_res.value_ptr.image.width,
                        });
                    }

                    //TODO: handle image resizing between frames
                    std.debug.assert(image_width == get_or_put_res.value_ptr.image.width);
                    std.debug.assert(image_height == get_or_put_res.value_ptr.image.height);
                    std.debug.assert(image_depth == get_or_put_res.value_ptr.image.depth);

                    continue;
                }

                const image_usage = image_usages.get(handle).?;

                get_or_put_res.value_ptr.*.image = try graphics.Image.init(
                    .@"2d",
                    image_width,
                    image_height,
                    image_depth,
                    1,
                    @enumFromInt(@intFromEnum(image_format)),
                    .shader_read_only_optimal,
                    image_usage.usage,
                );
                errdefer get_or_put_res.value_ptr.image.deinit();
            }

            for (builder.samplers.items(.reference_count), 0..) |reference_count, sampler_index| {
                if (reference_count == 0) {
                    //TODO: deallocate unreferenced pipelines if they have a backing store
                    continue;
                }

                const handle: Sampler = builder.samplers.items(.handle)[sampler_index];

                const get_or_put_res = try self.samplers.getOrPut(self.allocator, handle.id);

                //cache hit
                if (get_or_put_res.found_existing) {
                    continue;
                }

                const min_filter = builder.samplers.items(.min_filter)[sampler_index];
                const mag_filter = builder.samplers.items(.mag_filter)[sampler_index];
                const address_mode_u = builder.samplers.items(.address_mode_u)[sampler_index];
                const address_mode_v = builder.samplers.items(.address_mode_v)[sampler_index];
                const address_mode_w = builder.samplers.items(.address_mode_w)[sampler_index];
                const reduction_mode = builder.samplers.items(.reduction_mode)[sampler_index];

                get_or_put_res.value_ptr.* = try graphics.Sampler.init(
                    @enumFromInt(@intFromEnum(min_filter)),
                    @enumFromInt(@intFromEnum(mag_filter)),
                    @enumFromInt(@intFromEnum(address_mode_u)),
                    @enumFromInt(@intFromEnum(address_mode_v)),
                    @enumFromInt(@intFromEnum(address_mode_w)),
                    if (reduction_mode == null) null else @enumFromInt(@intFromEnum(reduction_mode.?)),
                );
                errdefer get_or_put_res.value_ptr.deinit();
            }
        }

        //Staging memory preallocate pass
        {
            for (dependencies.items) |*dependency| {
                var command_iter = builder.passCommandIterator(dependency.pass_index);

                while (command_iter.next()) |command| {
                    switch (command) {
                        .update_buffer => |update_buffer| {
                            self.preAllocateStagingMemory(1, update_buffer.contents.len);
                        },
                        .update_image => |update_image| {
                            const image = self.images.get(update_image.image).?.image;

                            self.preAllocateStagingMemory(image.alignment, image.size);
                        },
                        else => {},
                    }
                }
            }
        }

        //Final pass: Encode commands
        {
            const command_buffer = &compile_buffer.graphics_command_buffer.?;

            try command_buffer.begin();
            // defer command_buffer.end();

            var barrier_map: BarrierMap = .{
                .context = self,
            };
            defer barrier_map.deinit();

            for (dependencies.items) |*dependency| {
                const pass_index = dependency.pass_index;
                const pass_handle = builder.passes.items(.handle)[pass_index];
                const pass_data: Builder.PassData = builder.passes.items(.data)[pass_index];

                var current_pipline: ?*graphics.GraphicsPipeline = null;
                var current_index_buffer: ?*graphics.Buffer = null;

                if (pass_data == .raster) {
                    const attachments_input = pass_data.raster.attachments;

                    // attachment barrier prepass
                    for (attachments_input) |
                        input,
                    | {
                        const image = &self.images.getPtr(input.image).?.image;

                        if (input.store) {
                            try barrier_map.readWriteImage(
                                image,
                                .{ .color_attachment_output = true },
                                .{ .color_attachment_write = true },
                                .color_attachment_optimal,
                            );
                        }
                    }
                }

                var command_iter = builder.passCommandIterator(pass_index);

                //barrier prepass
                while (command_iter.next()) |command| {
                    switch (command) {
                        .update_buffer => |update_buffer| {
                            const buffer = self.buffers.getPtr(update_buffer.buffer).?;

                            try barrier_map.writeBuffer(
                                buffer,
                                .{ .copy = true },
                                .{ .transfer_write = true },
                            );
                        },
                        .update_image => |update_image| {
                            const image = &self.images.getPtr(update_image.image).?.image;

                            try barrier_map.writeImage(
                                image,
                                .{ .copy = true },
                                .{ .transfer_write = true },
                                .transfer_dst_optimal,
                            );
                        },
                        .set_raster_pipeline_resource_buffer => |command_data| {
                            const buffer = self.buffers.getPtr(command_data.buffer).?;

                            barrier_map.readBuffer(
                                buffer,
                                .{ .vertex_shader = true, .fragment_shader = true },
                                .{ .shader_read = true },
                            );
                        },
                        .set_raster_pipeline_image_sampler => |command_data| {
                            const image = &self.images.getPtr(command_data.image).?.image;

                            barrier_map.readImage(
                                image,
                                .{ .fragment_shader = true },
                                .{ .shader_read = true },
                                .shader_read_only_optimal,
                            );
                        },
                        .set_index_buffer => |command_data| {
                            current_index_buffer = self.buffers.getPtr(command_data.index_buffer).?;
                        },
                        .draw_indexed => {
                            barrier_map.readBuffer(
                                current_index_buffer.?,
                                .{ .index_input = true },
                                .{ .index_read = true },
                            );
                        },
                        else => {},
                    }
                }

                command_buffer.bufferBarriers(
                    barrier_map.buffer_barriers.items(.buffer),
                    barrier_map.buffer_barriers.items(.barrier),
                );
                barrier_map.buffer_barriers.shrinkRetainingCapacity(0);

                command_buffer.imageBarriers(
                    barrier_map.image_barriers.items(.image),
                    barrier_map.image_barriers.items(.barrier),
                );
                barrier_map.image_barriers.shrinkRetainingCapacity(0);

                const maybe_pass_name = builder.debug_info.getPassName(builder.*, pass_handle);

                if (maybe_pass_name) |pass_name| {
                    command_buffer.debugLabelBegin(pass_name);
                }

                if (pass_data == .raster) {
                    const x = pass_data.raster.render_offset_x;
                    const y = pass_data.raster.render_offset_y;
                    const width = pass_data.raster.render_width;
                    const height = pass_data.raster.render_height;
                    const attachments_input = pass_data.raster.attachments;

                    const attachments = try self.scratch_allocator.allocator().alloc(graphics.CommandBuffer.Attachment, attachments_input.len);
                    defer self.scratch_allocator.allocator().free(attachments);

                    for (attachments_input, attachments) |input, *output| {
                        output.image = &self.images.getPtr(input.image).?.image;
                        output.clear = if (input.clear != null) .{ .color = input.clear.? } else null;
                        output.store = input.store;
                    }

                    command_buffer.beginRenderPass(
                        x,
                        y,
                        width,
                        height,
                        attachments,
                        if (pass_data.raster.depth_attachment != null) .{
                            .image = &self.images.getPtr(pass_data.raster.depth_attachment.?.image).?.image,
                            .clear = if (pass_data.raster.depth_attachment.?.clear != null) .{ .depth = pass_data.raster.depth_attachment.?.clear.? } else null,
                            .store = pass_data.raster.depth_attachment.?.store,
                        } else null,
                    );
                }
                defer if (maybe_pass_name) |_| {
                    command_buffer.debugLabelEnd();
                };
                defer if (pass_data == .raster) {
                    command_buffer.endRenderPass();
                };

                current_pipline = null;
                current_index_buffer = null;

                command_iter = builder.passCommandIterator(pass_index);

                //encode final commands
                while (command_iter.next()) |command| {
                    switch (command) {
                        .update_buffer => |update_buffer| {
                            const buffer = self.buffers.getPtr(update_buffer.buffer).?;

                            const staging_contents = try self.allocateStagingBuffer(1, update_buffer.contents.len);

                            @memcpy(staging_contents.mapped_region, update_buffer.contents);

                            command_buffer.copyBuffer(
                                staging_contents.buffer.*,
                                staging_contents.offset,
                                staging_contents.mapped_region.len,
                                buffer.*,
                                update_buffer.buffer_offset,
                                update_buffer.contents.len,
                            );
                        },
                        .update_image => |update_image| {
                            const image = self.images.getPtr(update_image.image).?.image;

                            const staging_contents = try self.allocateStagingBuffer(4, update_image.contents.len);

                            @memcpy(staging_contents.mapped_region, update_image.contents);

                            command_buffer.copyBufferToImageOffset(
                                staging_contents.buffer.*,
                                staging_contents.offset,
                                staging_contents.mapped_region.len,
                                image,
                            );
                        },
                        .set_raster_pipeline => |set_raster_pipeline| {
                            const pipeline = self.raster_pipelines.getPtr(set_raster_pipeline.pipeline.id).?;

                            command_buffer.setGraphicsPipeline(pipeline.*);

                            current_pipline = pipeline;
                        },
                        .set_raster_pipeline_resource_buffer => |command_data| {
                            const pipeline = self.raster_pipelines.getPtr(command_data.pipeline.id).?;
                            const buffer = self.buffers.getPtr(command_data.buffer).?;

                            pipeline.setDescriptorBuffer(
                                command_data.binding_index,
                                command_data.array_index,
                                buffer.*,
                            );
                        },
                        .set_raster_pipeline_image_sampler => |command_data| {
                            const pipeline = self.raster_pipelines.getPtr(command_data.pipeline.id).?;

                            const image = &self.images.getPtr(command_data.image).?.image;
                            const sampler = self.samplers.getPtr(command_data.sampler.id).?;

                            pipeline.setDescriptorImageSampler(
                                command_data.binding_index,
                                command_data.array_index,
                                image.*,
                                sampler.*,
                            );
                        },
                        .set_viewport => |command_data| {
                            command_buffer.setViewport(
                                command_data.x,
                                command_data.y,
                                command_data.width,
                                command_data.height,
                                command_data.min_depth,
                                command_data.max_depth,
                            );
                        },
                        .set_scissor => |command_data| {
                            command_buffer.setScissor(
                                command_data.x,
                                command_data.y,
                                command_data.width,
                                command_data.height,
                            );
                        },
                        .set_index_buffer => |command_data| {
                            current_index_buffer = self.buffers.getPtr(command_data.index_buffer).?;

                            command_buffer.setIndexBuffer(current_index_buffer.?.*, switch (command_data.type) {
                                .u16 => .u16,
                                .u32 => .u32,
                            });
                        },
                        .set_push_data => |command_data| {
                            command_buffer.setPushDataBytes(command_data.contents);
                        },
                        .draw_indexed => |command_data| {
                            command_buffer.drawIndexed(
                                command_data.index_count,
                                command_data.instance_count,
                                command_data.first_index,
                                command_data.vertex_offset,
                                command_data.first_instance,
                            );
                        },
                        .set_compute_pipeline => |command_data| {
                            const pipeline = self.compute_pipelines.getPtr(command_data.pipeline).?;

                            command_buffer.setComputePipeline(pipeline.*);
                        },
                        .compute_dispatch => |command_data| {
                            command_buffer.computeDispatch(
                                command_data.thread_count_x,
                                command_data.thread_count_y,
                                command_data.thread_count_z,
                            );
                        },
                    }
                }
            }
        }

        return .{
            .graphics_command_buffer = &compile_buffer.graphics_command_buffer.?,
        };
    }

    const Dependency = struct {
        pass_index: u32,
    };

    fn compilePassDependencies(
        self: *@This(),
        builder: Builder,
        pass_index: u32,
        dependencies: *std.ArrayListUnmanaged(Dependency),
    ) !void {
        const passes = &builder.passes;

        const input_offset = passes.items(.input_offset)[pass_index];
        const input_count = passes.items(.input_count)[pass_index];

        const pass_dependencies = try self.scratch_allocator.allocator().alloc(Dependency, input_count);
        defer self.scratch_allocator.allocator().free(pass_dependencies);

        var dependency_count: u32 = 0;

        for (0..input_count) |input_index| {
            const pass_dependency_index = builder.pass_inputs.items(.pass_index)[input_offset + input_index];

            const existing_index = block: for (pass_dependencies, 0..) |pass_dep, dependency_index| {
                if (pass_dep.pass_index == pass_dependency_index) break :block dependency_index;
            } else dependency_count;

            const found_existing = existing_index != dependency_count;

            if (found_existing) continue;

            pass_dependencies[dependency_count] = .{
                .pass_index = pass_dependency_index,
            };

            dependency_count += 1;
        }

        for (pass_dependencies[0..dependency_count]) |dep| {
            try self.compilePassDependencies(
                builder,
                dep.pass_index,
                dependencies,
            );
        } else {
            try dependencies.append(self.scratch_allocator.allocator(), .{
                .pass_index = pass_index,
            });
        }
    }

    fn preAllocateStagingMemory(
        self: *@This(),
        alignment: usize,
        size: usize,
    ) void {
        const frame_data = &self.cpu_buffer[self.buffer_index];

        frame_data.staging_buffer_size = std.mem.alignForward(usize, frame_data.staging_buffer_size, alignment);

        frame_data.staging_buffer_size += size;
    }

    const StagingBuffer = struct {
        buffer: *const graphics.Buffer,
        offset: usize,
        mapped_region: []u8,
    };

    ///Allocate staging memory immediately to from a pool
    ///Will get returned to the pool when the command buffer is done
    fn allocateStagingBuffer(
        self: *@This(),
        alignment: usize,
        size: usize,
    ) !StagingBuffer {
        const frame_data = &self.cpu_buffer[self.buffer_index];

        frame_data.staging_buffer_offset = std.mem.alignForward(usize, frame_data.staging_buffer_offset, alignment);

        defer frame_data.staging_buffer_offset += size;

        if (frame_data.staging_buffer != null and frame_data.staging_buffer_size <= frame_data.staging_buffer.?.size) {
            return StagingBuffer{
                .buffer = &frame_data.staging_buffer.?,
                .mapped_region = (frame_data.staging_buffer_mapping + frame_data.staging_buffer_offset)[0..size],
                .offset = frame_data.staging_buffer_offset,
            };
        }

        if (frame_data.staging_buffer != null) {
            frame_data.staging_buffer.?.deinit();
        }

        frame_data.staging_buffer = try graphics.Buffer.init(frame_data.staging_buffer_size, .staging);
        errdefer frame_data.staging_buffer.?.deinit();

        frame_data.staging_buffer.?.debugSetName("staging");

        const mapped_region = try frame_data.staging_buffer.?.map(u8);

        frame_data.staging_buffer_mapping = mapped_region.ptr;

        return StagingBuffer{
            .buffer = &frame_data.staging_buffer.?,
            .mapped_region = (frame_data.staging_buffer_mapping + frame_data.staging_buffer_offset)[0..size],
            .offset = frame_data.staging_buffer_offset,
        };
    }

    const CompilerContext = @This();

    pub const BarrierMap = struct {
        context: *CompilerContext,
        ///Potential barriers (created on resource write)
        buffer_map: std.AutoArrayHashMapUnmanaged(
            *const graphics.Buffer,
            graphics.CommandBuffer.BufferBarrier,
        ) = .{},
        image_map: std.AutoArrayHashMapUnmanaged(
            *const graphics.Image,
            graphics.CommandBuffer.ImageBarrier,
        ) = .{},
        buffer_barriers: std.MultiArrayList(struct {
            buffer: *const graphics.Buffer,
            barrier: graphics.CommandBuffer.BufferBarrier,
        }) = .{},
        image_barriers: std.MultiArrayList(struct {
            image: *const graphics.Image,
            barrier: graphics.CommandBuffer.ImageBarrier,
        }) = .{},

        pub fn deinit(self: *@This()) void {
            self.buffer_map.deinit(self.context.scratch_allocator.allocator());
            self.image_map.deinit(self.context.scratch_allocator.allocator());
            self.buffer_barriers.deinit(self.context.scratch_allocator.allocator());
            self.image_barriers.deinit(self.context.scratch_allocator.allocator());

            self.* = undefined;
        }

        pub fn writeBuffer(
            self: *@This(),
            buffer: *const graphics.Buffer,
            stage: graphics.CommandBuffer.PipelineStage,
            access: graphics.CommandBuffer.ResourceAccess,
        ) !void {
            const barrier_result = try self.buffer_map.getOrPut(
                self.context.scratch_allocator.allocator(),
                buffer,
            );

            if (!barrier_result.found_existing) {
                barrier_result.value_ptr.* = .{
                    .source_stage = stage,
                    .source_access = access,
                    .destination_stage = .{},
                    .destination_access = .{},
                };
            } else {
                updateBarrierMask(
                    &barrier_result.value_ptr.*.source_stage,
                    &barrier_result.value_ptr.*.source_access,
                    stage,
                    access,
                );
            }
        }

        pub fn readBuffer(
            self: *@This(),
            buffer: *const graphics.Buffer,
            stage: graphics.CommandBuffer.PipelineStage,
            access: graphics.CommandBuffer.ResourceAccess,
        ) void {
            const maybe_buffer_barrier = self.buffer_map.getPtr(buffer);

            if (maybe_buffer_barrier) |out_barrier| {
                updateBarrierMask(
                    &out_barrier.*.destination_stage,
                    &out_barrier.*.destination_access,
                    stage,
                    access,
                );

                self.buffer_barriers.append(self.context.scratch_allocator.allocator(), .{
                    .buffer = buffer,
                    .barrier = out_barrier.*,
                }) catch unreachable;
            }
        }

        ///Specifies a dependency that will both read and write an image atomically
        pub fn readWriteImage(
            self: *@This(),
            image: *const graphics.Image,
            stage: graphics.CommandBuffer.PipelineStage,
            access: graphics.CommandBuffer.ResourceAccess,
            expected_layout: graphics.vulkan.ImageLayout,
        ) !void {
            try self.writeImage(
                image,
                stage,
                access,
                expected_layout,
            );
            self.readImage(
                image,
                stage,
                access,
                expected_layout,
            );
        }

        pub fn writeImage(
            self: *@This(),
            image: *const graphics.Image,
            stage: graphics.CommandBuffer.PipelineStage,
            access: graphics.CommandBuffer.ResourceAccess,
            expected_layout: graphics.vulkan.ImageLayout,
        ) !void {
            const barrier_result = try self.image_map.getOrPut(
                self.context.scratch_allocator.allocator(),
                image,
            );

            if (!barrier_result.found_existing) {
                barrier_result.value_ptr.* = .{
                    .source_stage = stage,
                    .source_access = access,
                    .destination_stage = .{},
                    .destination_access = .{},
                    .destination_layout = expected_layout,
                };
            } else {
                updateBarrierMask(
                    &barrier_result.value_ptr.*.source_stage,
                    &barrier_result.value_ptr.*.source_access,
                    stage,
                    access,
                );

                barrier_result.value_ptr.source_layout = expected_layout;
            }
        }

        pub fn readImage(
            self: *@This(),
            image: *const graphics.Image,
            stage: graphics.CommandBuffer.PipelineStage,
            access: graphics.CommandBuffer.ResourceAccess,
            expected_layout: graphics.vulkan.ImageLayout,
        ) void {
            const maybe_barrier = self.image_map.getPtr(image);

            if (maybe_barrier) |out_barrier| {
                updateBarrierMask(
                    &out_barrier.*.destination_stage,
                    &out_barrier.*.destination_access,
                    stage,
                    access,
                );

                out_barrier.destination_layout = expected_layout;

                self.image_barriers.append(self.context.scratch_allocator.allocator(), .{
                    .image = image,
                    .barrier = out_barrier.*,
                }) catch unreachable;
            }
        }

        fn updateBarrierMask(
            dst_stage: *graphics.CommandBuffer.PipelineStage,
            dst_access: *graphics.CommandBuffer.ResourceAccess,
            stage: graphics.CommandBuffer.PipelineStage,
            access: graphics.CommandBuffer.ResourceAccess,
        ) void {
            const incoming_stage: u16 = @bitCast(stage);
            const incoming_access: u16 = @bitCast(access);

            const current_stage: u16 = @bitCast(dst_stage.*);
            const current_access: u16 = @bitCast(dst_access.*);

            //Sets the barrier bits if the incoming ones are true
            //Preserves existing barrier flags
            dst_stage.* = @bitCast(current_stage | incoming_stage);
            dst_access.* = @bitCast(current_access | incoming_access);
        }
    };

    pub const CompileResult = struct {
        ///Command buffer to be submitted to graphics queue
        graphics_command_buffer: *const graphics.CommandBuffer,
    };

    const graphics = @import("../graphics.zig");
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

pub const BufferHandle = enum(u64) { _ };
pub const ImageHandle = enum(u64) { _ };

pub const PassHandle = packed struct(u64) {
    id: u64,
};

///Generic type erased resource handle
pub const ResourceHandle = packed struct(u64) {
    id: u64,
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
