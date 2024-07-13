//!Compilation of render graphs to command buffers and resources

///Contains all graphics resources (pipelines, buffers, textures ect..)
pub const Context = struct {
    gpa: std.mem.Allocator,
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
    compute_pipelines: std.AutoArrayHashMapUnmanaged(graph.ComputePipeline, graphics.ComputePipeline) = .{},
    buffers: std.AutoArrayHashMapUnmanaged(graph.BufferHandle, graphics.Buffer) = .{},
    images: std.AutoArrayHashMapUnmanaged(graph.ImageHandle, struct {
        imported: bool = false,
        //TODO: use pointer for external image maybe?
        image: graphics.Image,
        is_presentation_image: bool = false,
    }) = .{},
    samplers: std.AutoArrayHashMapUnmanaged(u64, graphics.Sampler) = .{},

    ///The number of buffered command/staging buffers to keep around for gpu/cpu parralelism
    ///This is completely unrelated and independent from swapchain buffering
    const cpu_buffer_count = 2;

    pub fn init(gpa: std.mem.Allocator) Context {
        var self: Context = .{
            .gpa = gpa,
            .scratch_allocator = std.heap.ArenaAllocator.init(gpa),
            .cpu_buffer = undefined,
        };

        for (0..cpu_buffer_count) |i| {
            self.cpu_buffer[i] = .{};
        }

        return self;
    }

    pub fn deinit(self: *@This()) void {
        //Maybe wait for specific resources? This will work for now
        graphics.Context.waitIdle();

        for (self.raster_pipelines.values()) |*raster_pipeline| {
            raster_pipeline.deinit(self.gpa);
        }

        for (self.compute_pipelines.values()) |*compute_pipeline| {
            compute_pipeline.deinit(self.gpa);
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

        self.raster_pipelines.deinit(self.gpa);
        self.compute_pipelines.deinit(self.gpa);
        self.buffers.deinit(self.gpa);
        self.images.deinit(self.gpa);
        self.samplers.deinit(self.gpa);
        self.scratch_allocator.deinit();

        self.* = undefined;
    }

    ///Imports and underlying gpu api image and provides a handle that is usable from graph building code
    pub fn importExternalImage(
        self: *@This(),
        builder: *graph.Builder,
        comptime src: std.builtin.SourceLocation,
        image: graphics.Image,
        ///How is this resource used after being used by the graph
        usage: enum {
            ///Use if the image won't be used for anything particular
            undefined,
            ///This image will be used in presentation
            presentation,
        },
    ) graph.Image {
        const image_pointer = builder.createImage(src, .{
            .format = @enumFromInt(@intFromEnum(image.format)),
            .width = image.width,
            .height = image.height,
            .depth = 1,
        });

        const get_or_put_result = self.images.getOrPut(self.gpa, builder.images.items(.handle)[image_pointer.index]) catch @panic("oom");

        get_or_put_result.value_ptr.image = image;
        get_or_put_result.value_ptr.imported = true;
        get_or_put_result.value_ptr.is_presentation_image = usage == .presentation;

        return image_pointer;
    }

    ///Compiles a built graph to low level api commands
    pub fn compile(
        self: *@This(),
        builder: *graph.Builder,
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
                .image => |image| image.pass_index orelse {
                    return .{
                        .graphics_command_buffer = &compile_buffer.graphics_command_buffer.?,
                    };
                },
                .buffer => |buffer| buffer.pass_index.?,
            };

            try self.compilePassDependencies(
                builder.*,
                root_pass_index,
                &dependencies,
            );
        }

        var buffer_usages: std.AutoArrayHashMapUnmanaged(graph.BufferHandle, struct {
            usage: graphics.vulkan.BufferUsageFlags,
        }) = .{};
        defer buffer_usages.deinit(self.scratch_allocator.allocator());

        var image_usages: std.AutoArrayHashMapUnmanaged(graph.ImageHandle, struct {
            usage: graphics.vulkan.ImageUsageFlags,
        }) = .{};
        defer image_usages.deinit(self.scratch_allocator.allocator());

        //usage mapping
        for (dependencies.items) |*dependency| {
            const pass_index = dependency.pass_index;
            const pass_data: graph.Builder.PassData = builder.passes.items(.data)[pass_index];

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
                        result.value_ptr.*.usage.transfer_dst_bit = true;
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
                        //TODO: This should potentially be set only when the buffer is used for transfer
                        //However, if the buffer is created and then not transferred on first use
                        //It will be created without the flag, so I've just place this here so we can
                        //always transfer to buffers that we use
                        result.value_ptr.*.usage.transfer_dst_bit = true;
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
                    .draw_indexed_indirect_count => |command_data| {
                        const draw_buffer = try buffer_usages.getOrPutValue(
                            self.scratch_allocator.allocator(),
                            command_data.draw_buffer,
                            .{
                                .usage = .{},
                            },
                        );

                        draw_buffer.value_ptr.*.usage.indirect_buffer_bit = true;
                        draw_buffer.value_ptr.*.usage.transfer_dst_bit = true;

                        const count_buffer = try buffer_usages.getOrPutValue(
                            self.scratch_allocator.allocator(),
                            command_data.count_buffer,
                            .{
                                .usage = .{},
                            },
                        );

                        count_buffer.value_ptr.*.usage.indirect_buffer_bit = true;
                        count_buffer.value_ptr.*.usage.transfer_dst_bit = true;
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

                const handle: graph.RasterPipeline = builder.raster_pipelines.items(.handle)[pipeline_index];

                const get_or_put_res = try self.raster_pipelines.getOrPut(self.gpa, handle.id);

                //cache hit
                if (get_or_put_res.found_existing) {
                    continue;
                }

                const pipeline = builder.raster_pipelines.get(pipeline_index);

                const vertex_module: graph.RasterModule = builder.raster_pipelines.items(.vertex_module)[pipeline_index];
                const fragment_module: graph.RasterModule = builder.raster_pipelines.items(.fragment_module)[pipeline_index];
                const push_constant_size = builder.raster_pipelines.items(.push_constant_size)[pipeline_index];
                const attachment_formats = builder.raster_pipelines.items(.attachment_formats)[pipeline_index];
                const depth_attachment_format = builder.raster_pipelines.items(.depth_attachment_format)[pipeline_index];

                get_or_put_res.value_ptr.* = try graphics.GraphicsPipeline.init(
                    self.gpa,
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
                errdefer get_or_put_res.value_ptr.deinit(self.gpa);
            }

            for (builder.buffers.items(.reference_count), 0..) |reference_count, buffer_index| {
                if (reference_count == 0) {
                    //TODO: deallocate unreferenced pipelines if they have a backing store
                    continue;
                }

                const handle = builder.buffers.items(.handle)[buffer_index];

                const get_or_put_res = try self.buffers.getOrPut(self.gpa, handle);

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

                const get_or_put_res = try self.images.getOrPut(self.gpa, handle);

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

                const handle: graph.Sampler = builder.samplers.items(.handle)[sampler_index];

                const get_or_put_res = try self.samplers.getOrPut(self.gpa, handle.id);

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
            defer command_buffer.end();

            var barrier_map: BarrierMap = .{
                .context = self,
            };
            defer barrier_map.deinit();

            for (dependencies.items) |*dependency| {
                const pass_index = dependency.pass_index;
                const pass_handle = builder.passes.items(.handle)[pass_index];
                const pass_data: graph.Builder.PassData = builder.passes.items(.data)[pass_index];

                var current_pipline: ?*graphics.GraphicsPipeline = null;
                var current_index_buffer: ?*graphics.Buffer = null;

                if (pass_data == .raster) {
                    const attachments_input = pass_data.raster.attachments;

                    // attachment barrier prepass
                    for (attachments_input) |input| {
                        const image = &self.images.getPtr(input.image).?.image;

                        try barrier_map.readWriteImage(
                            image,
                            .{ .color_attachment_output = true },
                            .{ .color_attachment_write = true },
                            .color_attachment_optimal,
                        );
                    }

                    if (pass_data.raster.depth_attachment != null) {
                        const image = &self.images.getPtr(pass_data.raster.depth_attachment.?.image).?.image;

                        try barrier_map.readWriteImage(
                            image,
                            .{
                                .early_fragment_tests = true,
                            },
                            .{
                                .depth_attachment_read = true,
                                .depth_attachment_write = pass_data.raster.depth_attachment.?.store,
                            },
                            .depth_attachment_optimal,
                        );
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
                            barrier_map.readBuffer(
                                current_index_buffer.?,
                                .{ .index_input = true },
                                .{ .index_read = true },
                            );
                        },
                        .draw_indexed => {},
                        .draw_indexed_indirect_count => |command_data| {
                            const draw_buffer = self.buffers.getPtr(command_data.draw_buffer).?;
                            const count_buffer = self.buffers.getPtr(command_data.count_buffer).?;

                            barrier_map.readBuffer(
                                draw_buffer,
                                .{ .draw_indirect = true },
                                .{ .indirect_command_read = true },
                            );

                            barrier_map.readBuffer(
                                count_buffer,
                                .{ .draw_indirect = true },
                                .{ .indirect_command_read = true },
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
                        .draw => |command_data| {
                            command_buffer.draw(
                                command_data.vertex_count,
                                command_data.instance_count,
                                command_data.first_vertex,
                                command_data.first_instance,
                            );
                        },
                        .draw_indexed_indirect_count => |command_data| {
                            command_buffer.drawIndexedIndirectCount(
                                self.buffers.getPtr(command_data.draw_buffer).?.*,
                                command_data.draw_buffer_offset,
                                command_data.draw_buffer_stride,
                                self.buffers.getPtr(command_data.count_buffer).?.*,
                                command_data.count_buffer_offset,
                                command_data.max_draw_count,
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

            var image_iter = self.images.iterator();

            //Encode barriers for presentation
            while (image_iter.next()) |image_entry| {
                if (image_entry.value_ptr.is_presentation_image) {
                    const image = self.images.getPtr(image_entry.key_ptr.*) orelse @panic("Presentation image must have a backing image");

                    compile_buffer.graphics_command_buffer.?.imageBarrier(image.*.image, .{
                        .source_stage = .{ .color_attachment_output = true },
                        .source_access = .{ .color_attachment_write = true },
                        .destination_stage = .{},
                        .destination_access = .{},
                        .source_layout = .attachment_optimal,
                        .destination_layout = .present_src_khr,
                    });
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
        builder: graph.Builder,
        pass_index: u32,
        dependencies: *std.ArrayListUnmanaged(Dependency),
    ) !void {
        const passes = &builder.passes;

        const input_offset = passes.items(.input_offset)[pass_index];
        const input_count = passes.items(.input_count)[pass_index];

        const pass_dependencies = try self.scratch_allocator.allocator().alloc(Dependency, input_count);
        defer self.scratch_allocator.allocator().free(pass_dependencies);

        @memset(pass_dependencies, .{ .pass_index = std.math.maxInt(u32) });

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

    ///Allocate staging memory immediately to form a pool
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
                }) catch @panic("oom");
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
                }) catch @panic("oom");
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

    ///Submit the compiled graph to the gpu
    pub fn submit(self: *@This(), compile_result: CompileResult) !void {
        _ = compile_result; // autofix
        _ = self; // autofix

        // try compile_result.graphics_command_buffer.submitSemaphore(
        //     compile_result.graphics_command_buffer.wait_fence,
        //     image.image_acquired,
        //     image.render_finished,
        // );
    }
};

test {
    std.testing.refAllDecls(@This());
}

const std = @import("std");
const graphics = @import("../graphics.zig");
const graph = @import("graph.zig");
