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
    ///The retained barrier map which tracks barriers across frames and within them
    barrier_map: BarrierMap,

    ///The number of buffered command/staging buffers to keep around for gpu/cpu parralelism
    ///This is completely unrelated and independent from swapchain buffering
    const cpu_buffer_count = 2;

    ///The context now owns the scatch_allocator, and will reset and deinit it
    ///TODO: right now you MUST initialize the barrier map in this struct AFTER calling init
    ///If you don't it's a simple crash
    pub fn init(
        gpa: std.mem.Allocator,
    ) Context {
        var self: Context = .{
            .gpa = gpa,
            .scratch_allocator = std.heap.ArenaAllocator.init(gpa),
            .cpu_buffer = undefined,
            //TODO: I have no idea why I can't make use of the arena for this, it just crashes
            //This is not a lifetime issue, even if I init at the callsite it just breaks
            .barrier_map = .{ .scratch_allocator = gpa },
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
        self.barrier_map.deinit();
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
            compile_buffer.graphics_command_buffer.?.debugSetName("Compiled Render Graph Command Buffer");
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
                    .blit_image => |command_data| {
                        const source_usage = try image_usages.getOrPutValue(self.scratch_allocator.allocator(), command_data.src_image, .{
                            .usage = .{},
                        });
                        const dest_usage = try image_usages.getOrPutValue(self.scratch_allocator.allocator(), command_data.dst_image, .{
                            .usage = .{},
                        });

                        source_usage.value_ptr.usage.transfer_src_bit = true;
                        dest_usage.value_ptr.usage.transfer_dst_bit = true;
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
                _ = reference_count; // autofix
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
                        .input_assembly_state = pipeline.input_assembly_state,
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
                const image_levels = builder.images.items(.levels)[image_index];

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
                    image_levels,
                    @enumFromInt(@intFromEnum(image_format)),
                    image_usage.usage,
                );
                errdefer get_or_put_res.value_ptr.image.deinit();

                const maybe_image_name = builder.debug_info.getImageName(builder.*, handle);

                if (maybe_image_name) |image_name| {
                    get_or_put_res.value_ptr.*.image.debugSetName(image_name);
                }
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

            const barrier_map = &self.barrier_map;

            for (self.images.values()) |*image| {
                if (image.is_presentation_image) {
                    const image_ptr = &image.image;

                    //If the image is a presentation image, we need to synchronise with vkAcquireNextImage, which posts a read on the color attachment output stage
                    //We must only do this once per frame as a presentation image may be used multiple times in a frame (obviously)
                    barrier_map.acquireImage(
                        .{
                            .image = image_ptr,
                            .base_mip_level = 0,
                            .level_count = 1,
                            .stage = .{
                                .color_attachment_output = true,
                            },
                            .access = .{},
                            .expected_layout = .undefined,
                        },
                    );
                    try barrier_map.flushBarriers(command_buffer);
                    barrier_map.releaseImage(.{ .image = image_ptr });
                }
            }

            for (dependencies.items) |*dependency| {
                const pass_index = dependency.pass_index;
                const pass_handle = builder.passes.items(.handle)[pass_index];
                const pass_data: graph.Builder.PassData = builder.passes.items(.data)[pass_index];

                var current_pipline: ?*graphics.GraphicsPipeline = null;

                if (pass_data == .raster) {
                    const attachments_input = pass_data.raster.attachments;

                    // attachment barrier prepass
                    for (attachments_input) |input| {
                        const image = &self.images.getPtr(input.image).?.image;

                        barrier_map.acquireImage(
                            .{
                                .image = image,
                                .stage = .{
                                    .color_attachment_output = true,
                                },
                                .access = .{
                                    .color_attachment_read = false,
                                    .color_attachment_write = input.store,
                                },
                                //If we clear, we don't want to flush the cache because that's a waste
                                .discard_previous_data = input.clear != null,
                                .expected_layout = .color_attachment_optimal,
                            },
                        );
                    }

                    if (pass_data.raster.depth_attachment != null) {
                        const image = &self.images.getPtr(pass_data.raster.depth_attachment.?.image).?.image;

                        barrier_map.acquireImage(
                            .{
                                .image = image,
                                .stage = .{
                                    .early_fragment_tests = true,
                                    .color_attachment_output = true,
                                    //Depth fragments are written in late fragment tests
                                    // .late_fragment_tests = pass_data.raster.depth_attachment.?.store,
                                },
                                .access = .{
                                    .depth_attachment_read = true,
                                    .depth_attachment_write = pass_data.raster.depth_attachment.?.store,
                                    .color_attachment_write = true,
                                },
                                .expected_layout = .depth_attachment_optimal,
                            },
                        );
                    }
                }
                defer if (pass_data == .raster) {
                    const attachments_input = pass_data.raster.attachments;

                    // attachment barrier prepass
                    for (attachments_input) |input| {
                        const image = &self.images.getPtr(input.image).?.image;

                        barrier_map.releaseImage(.{ .image = image });
                    }

                    if (pass_data.raster.depth_attachment != null) {
                        const image = &self.images.getPtr(pass_data.raster.depth_attachment.?.image).?.image;

                        barrier_map.releaseImage(.{ .image = image });
                    }
                };

                var command_iter = builder.passCommandIterator(pass_index);

                //barrier prepass
                //Places barriers before the entire pass
                while (command_iter.next()) |command| {
                    switch (command) {
                        .set_raster_pipeline_resource_buffer => |command_data| {
                            const buffer = self.buffers.getPtr(command_data.buffer).?;

                            barrier_map.acquireBuffer(.{
                                .buffer = buffer,
                                .stage = .{
                                    //TODO: figure out which stages a buffer is used in based on shader reflection data
                                    //that we already have: This could have a huge affect on pipelining and could remove bubbles
                                    .vertex_shader = true,
                                    .fragment_shader = true,
                                },
                                .access = .{
                                    .shader_read = true,
                                },
                            });
                        },
                        .set_raster_pipeline_image_sampler => |command_data| {
                            const image = &self.images.getPtr(command_data.image).?.image;

                            barrier_map.acquireImage(.{
                                .image = image,
                                .base_mip_level = 0,
                                .stage = .{ .fragment_shader = true },
                                .access = .{ .shader_read = true },
                                .expected_layout = .shader_read_only_optimal,
                            });
                        },
                        .set_index_buffer => |command_data| {
                            const buffer = self.buffers.getPtr(command_data.index_buffer).?;

                            barrier_map.acquireBuffer(
                                .{
                                    .buffer = buffer,
                                    .stage = .{ .index_input = true },
                                    .access = .{ .index_read = true },
                                },
                            );
                        },
                        .draw_indexed_indirect_count => |command_data| {
                            const draw_buffer = self.buffers.getPtr(command_data.draw_buffer).?;
                            const count_buffer = self.buffers.getPtr(command_data.count_buffer).?;

                            barrier_map.acquireBuffer(.{
                                .buffer = draw_buffer,
                                .stage = .{
                                    .draw_indirect = true,
                                    //Is this needed?
                                    .pre_rasterization_shaders = true,
                                },
                                .access = .{
                                    .indirect_command_read = true,
                                },
                            });

                            barrier_map.acquireBuffer(.{
                                .buffer = count_buffer,
                                .stage = .{ .draw_indirect = true },
                                .access = .{
                                    .indirect_command_read = true,
                                },
                            });
                        },
                        else => {},
                    }
                }

                command_buffer.debugLabelBegin("(quanta): pre_raster_pass: Flush barriers");

                try barrier_map.flushBarriers(command_buffer);

                command_buffer.debugLabelEnd();

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
                        output.load = input.load;
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

                command_iter = builder.passCommandIterator(pass_index);

                //encode final commands
                while (command_iter.next()) |command| {
                    //Command barrier aqcuire
                    switch (command) {
                        .blit_image => |blit_image| {
                            const source_image = &self.images.getPtr(blit_image.src_image).?.image;
                            const destination_image = &self.images.getPtr(blit_image.dst_image).?.image;

                            barrier_map.acquireImage(
                                .{
                                    .image = source_image,
                                    .base_mip_level = blit_image.region.src_subresource.mip_level,
                                    .level_count = 1,
                                    .stage = .{ .copy = true },
                                    .access = .{ .transfer_read = true },
                                    .expected_layout = .transfer_src_optimal,
                                },
                            );

                            barrier_map.acquireImage(
                                .{
                                    .image = destination_image,
                                    .base_mip_level = blit_image.region.dst_subresource.mip_level,
                                    .level_count = 1,
                                    .stage = .{ .copy = true },
                                    .access = .{ .transfer_write = true },
                                    .expected_layout = .transfer_dst_optimal,
                                },
                            );
                        },
                        //Should only be allowed in transfer and compute
                        .update_buffer => |update_buffer| {
                            const buffer = self.buffers.getPtr(update_buffer.buffer).?;

                            barrier_map.acquireBuffer(.{
                                .buffer = buffer,
                                .stage = .{
                                    .copy = true,
                                },
                                .access = .{
                                    .transfer_write = true,
                                },
                            });
                        },
                        .update_image => |update_image| {
                            barrier_map.acquireImage(.{
                                .image = &self.images.getPtr(update_image.image).?.image,
                                .level_count = 1,
                                .stage = .{
                                    .copy = true,
                                },
                                .access = .{
                                    .transfer_write = true,
                                },
                                .expected_layout = .transfer_dst_optimal,
                            });
                        },
                        else => {},
                    }

                    //Pipeline barriers can't be placed in a render pass instance
                    if (pass_data != .raster) {
                        try barrier_map.flushBarriers(command_buffer);
                    }

                    //Final command buffer encode
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

                            barrier_map.releaseBuffer(buffer);
                        },
                        .update_image => |update_image| {
                            const image = &self.images.getPtr(update_image.image).?.image;

                            const staging_contents = try self.allocateStagingBuffer(4, update_image.contents.len);

                            @memcpy(staging_contents.mapped_region, update_image.contents);

                            command_buffer.copyBufferToImageOffset(
                                staging_contents.buffer.*,
                                staging_contents.offset,
                                staging_contents.mapped_region.len,
                                image.*,
                            );

                            barrier_map.releaseImage(.{ .image = image });
                        },
                        .blit_image => |blit_image| {
                            const source_image = &self.images.getPtr(blit_image.src_image).?.image;
                            const destination_image = &self.images.getPtr(blit_image.dst_image).?.image;

                            //Allow for batched blits with multiple regions
                            const regions = try self.scratch_allocator.allocator().alloc(graphics.vulkan.ImageBlit2, 1);

                            regions[0] = std.mem.zeroInit(graphics.vulkan.ImageBlit2, .{});

                            regions[0].src_offsets[0] = .{
                                .x = blit_image.region.src_offset[0],
                                .y = blit_image.region.src_offset[1],
                                .z = blit_image.region.src_offset[2],
                            };
                            regions[0].src_offsets[1] = .{
                                .x = blit_image.region.src_extent[0],
                                .y = blit_image.region.src_extent[1],
                                .z = blit_image.region.src_extent[2],
                            };

                            regions[0].src_subresource = .{
                                .aspect_mask = .{ .color_bit = true },
                                .mip_level = blit_image.region.src_subresource.mip_level,
                                .base_array_layer = blit_image.region.src_subresource.base_array_layer,
                                .layer_count = blit_image.region.src_subresource.layer_count,
                            };

                            regions[0].dst_subresource = .{
                                .aspect_mask = .{ .color_bit = true },
                                .mip_level = blit_image.region.dst_subresource.mip_level,
                                .base_array_layer = blit_image.region.dst_subresource.base_array_layer,
                                .layer_count = blit_image.region.dst_subresource.layer_count,
                            };

                            regions[0].dst_offsets[0] = .{
                                .x = blit_image.region.dst_offset[0],
                                .y = blit_image.region.dst_offset[1],
                                .z = blit_image.region.dst_offset[2],
                            };
                            regions[0].dst_offsets[1] = .{
                                .x = blit_image.region.dst_extent[0],
                                .y = blit_image.region.dst_extent[1],
                                .z = blit_image.region.dst_extent[2],
                            };

                            command_buffer.imageBlit(
                                source_image,
                                .transfer_src_optimal,
                                destination_image,
                                .transfer_dst_optimal,
                                regions,
                                .linear,
                            );

                            barrier_map.releaseImage(.{
                                .image = source_image,
                                .mip_level = blit_image.region.src_subresource.mip_level,
                            });

                            barrier_map.releaseImage(.{
                                .image = destination_image,
                                .mip_level = blit_image.region.dst_subresource.mip_level,
                            });
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

                            barrier_map.releaseBuffer(buffer);
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
                                .shader_read_only_optimal,
                            );

                            barrier_map.releaseImage(.{ .image = image });
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
                            const index_buffer = self.buffers.getPtr(command_data.index_buffer).?;

                            command_buffer.setIndexBuffer(index_buffer.*, switch (command_data.type) {
                                .u16 => .u16,
                                .u32 => .u32,
                            });

                            barrier_map.releaseBuffer(index_buffer);
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
                            const draw_buffer = self.buffers.getPtr(command_data.draw_buffer).?;
                            const count_buffer = self.buffers.getPtr(command_data.count_buffer).?;

                            command_buffer.drawIndexedIndirectCount(
                                draw_buffer.*,
                                command_data.draw_buffer_offset,
                                command_data.draw_buffer_stride,
                                count_buffer.*,
                                command_data.count_buffer_offset,
                                command_data.max_draw_count,
                            );

                            barrier_map.releaseBuffer(draw_buffer);
                            barrier_map.releaseBuffer(count_buffer);
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

                    barrier_map.acquireImage(.{
                        .image = &image.image,
                        .stage = .{
                            .bottom_of_pipe = true,
                        },
                        .access = .{},
                        .expected_layout = .present_src_khr,
                    });
                }
            }

            command_buffer.debugLabelBegin("(quanta): post_frame: Presentation Image Transitions");

            try barrier_map.flushBarriers(command_buffer);

            command_buffer.debugLabelEnd();

            while (image_iter.next()) |image_entry| {
                if (image_entry.value_ptr.is_presentation_image) {
                    const image = self.images.getPtr(image_entry.key_ptr.*) orelse @panic("Presentation image must have a backing image");

                    barrier_map.releaseImage(.{ .image = &image.image });
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
        scratch_allocator: std.mem.Allocator,
        ///Potential barriers (created on resource write)
        buffer_map: std.AutoArrayHashMapUnmanaged(
            *const graphics.Buffer,
            graphics.CommandBuffer.BufferBarrier,
        ) = .{},
        image_map: std.AutoArrayHashMapUnmanaged(
            ImageSlice,
            graphics.CommandBuffer.ImageBarrier,
        ) = .{},
        ///Completed barriers based on completed read-write pairs
        buffer_barriers: std.MultiArrayList(struct {
            buffer: *const graphics.Buffer,
            barrier: graphics.CommandBuffer.BufferBarrier,
        }) = .{},
        image_barriers: std.MultiArrayList(struct {
            image: *const graphics.Image,
            barrier: graphics.CommandBuffer.ImageBarrier,
        }) = .{},

        pub const BufferSlice = struct {
            buffer: *const graphics.Buffer,
            offset: usize,
            size: usize,
        };

        ///TODO: currently we only support treating seperate mip levels as seperate sync resources
        ///Add support for offsets and sizes, but make sure to share the layout transitions as
        ///it doesn't make sense for different parts of an image to be in different layouts
        pub const ImageSlice = struct {
            image: *const graphics.Image,
            mip_level: u32,
        };

        pub fn deinit(self: *@This()) void {
            self.buffer_map.deinit(self.scratch_allocator);
            self.image_map.deinit(self.scratch_allocator);
            self.buffer_barriers.deinit(self.scratch_allocator);
            self.image_barriers.deinit(self.scratch_allocator);

            self.* = undefined;
        }

        comptime {
            {
                //acqBuffer(buf, .{ .transfer_copy }, .{ .transfer_write });
                //defer relBuffer(buf);
                //
                //flushBarriers();
                //
                //cmdCopyBuffer(buf, ...);
                //...
                //...
            }

            {
                //acqBuffer(buf, .{ .vertex_input }, .{ .index_read });
                //defer releaseBuffer(buf);

                //flushBarriers();

                //cmdBindIndexBuffer(buf, ...);
            }

            {
                //acqImage(img, .{ .transfer_copy }, .{ .transfer_write }, .transfer_dst_optimal);
                //defer relImage(img);

                //flushBarriers();

                //copyBufferToImage(img, staging, ...);
            }
        }

        ///Call this before flushBarriers to ensure that any barriers generated are actually encoded
        ///This will not always encode a barrier, only when a non no-op (when there is actually meaningful sync to be done)
        ///Forms a scope/call pair with releaseBuffer
        pub fn acquireBuffer(
            self: *@This(),
            config: struct {
                buffer: *const graphics.Buffer,
                ///Specifies the destination stages which wait for the buffer to be acquired
                stage: graphics.CommandBuffer.PipelineStage,
                ///Specifies the way the resource will be accessed in the acquire scope
                access: graphics.CommandBuffer.ResourceAccess,
            },
        ) void {
            const barrier_result = self.buffer_map.getOrPutValue(
                self.scratch_allocator,
                config.buffer,
                .{
                    .source_stage = .{},
                    .source_access = .{},
                    .destination_access = .{},
                    .destination_stage = .{},
                },
            ) catch @panic("oom");

            //ors the barrier flags together with the config.stage and access flags
            //We can't just set instead of 'orring' this as acquireBuffer is designed to be able to be called in batches
            //Such as acq, acq, acq ... (work) ... rel
            //This ensures that when the actual barrier is emitted, we wait on all stages that could be writing/reading the buffer
            updateBarrierMask(
                &barrier_result.value_ptr.*.destination_stage,
                &barrier_result.value_ptr.*.destination_access,
                config.stage,
                config.access,
            );

            //We techinically don't need/shouldn't emit the barrier if srcStage is zero, as that is a no-op and
            //is a flat waste of cpu cycles. This doesn't quite apply to image barriers though due to layout transitions
            //For now, this shouldn't cause any false-negatives and will be entirely conservative for correctness
            self.buffer_barriers.append(self.scratch_allocator, .{
                .buffer = config.buffer,
                .barrier = barrier_result.value_ptr.*,
            }) catch @panic("oom");
        }

        //This allows the accesses in the scope to be available to future acquires to do proper sync
        //You must always do things in acquire/release pairs, otherwise auto synchronisation will not work properly
        //Release should only be called once after multiple acquires to a single buffer
        pub fn releaseBuffer(
            self: *@This(),
            buffer: *const graphics.Buffer,
        ) void {
            //Technically release should never be called without acquire, so get should be fine here
            const barrier_result = self.buffer_map.getPtr(
                buffer,
            ) orelse @panic("This should never happen");

            //In release, we swap the current src and dst flags and zero out the dst flags.
            //This is because any accesses done in the scope ended by this release will need to be
            //read as the src and dst flags for the next barrier, as that's when they need to be waited on
            //dst flags are set entirely by the acquire calls, so we technically don't need to store them at all,
            //But I do this mostly because most of this code assumes a full barrier struct

            barrier_result.source_stage = barrier_result.destination_stage;
            barrier_result.source_access = barrier_result.destination_access;

            //This makes repeated calls to release problematic, but a single call to release after multiple acquires should
            //be better anyway, so this is how it should be done

            //^ Now the flags for the buffer have the accesses and stage for the acquire/release
            //scope we just ended, allowing subsequent acquire's to this buffer to encode the correct barriers and wait correctly

            //again, this is technically redundant but let's just do it for consistency
            barrier_result.destination_access = .{};
            barrier_result.destination_stage = .{};
        }

        //Same semantics as acquire/releaseBuffer but with additional layout logic
        pub fn acquireImage(
            self: *@This(),
            config: struct {
                image: *const graphics.Image,
                stage: graphics.CommandBuffer.PipelineStage,
                access: graphics.CommandBuffer.ResourceAccess,
                expected_layout: graphics.vulkan.ImageLayout,
                ///Setting this to true is the same as a pipeline barrier with srclayout = .undefined
                discard_previous_data: bool = false,
                base_mip_level: u32 = 0,
                level_count: u32 = graphics.vulkan.REMAINING_MIP_LEVELS,
            },
        ) void {
            const barrier_result = self.image_map.getOrPutValue(
                self.scratch_allocator,
                .{ .image = config.image, .mip_level = config.base_mip_level },
                .{
                    .source_stage = .{},
                    .source_access = .{},
                    .destination_stage = .{},
                    .destination_access = .{},
                },
            ) catch @panic("oom");

            //ors the barrier flags together with the config.stage and access flags
            //We can't just set instead of 'orring' this as acquireBuffer is designed to be able to be called in batches
            //Such as acq, acq, acq ... (work) ... rel
            //This ensures that when the actual barrier is emitted, we wait on all stages that could be writing/reading the buffer
            updateBarrierMask(
                &barrier_result.value_ptr.*.destination_stage,
                &barrier_result.value_ptr.*.destination_access,
                config.stage,
                config.access,
            );

            barrier_result.value_ptr.base_mip_level = config.base_mip_level;
            barrier_result.value_ptr.level_count = config.level_count;
            //We expect the destination layout to be the expected layout
            //If the previous layout (srcLayout) is different, we have specified a layout transition
            //If the previous layout is the same, we don't need a layout transition
            barrier_result.value_ptr.destination_layout = config.expected_layout;
            //For now we ensure that only 1 mip is transitioned/synced
            //If you want to sync multiple mips together, emit multiple barriers for now
            barrier_result.value_ptr.level_count = 1;

            //Setting source layout to undefined in vulkan is the same as discarding any previous results
            //Which is what you want for fresh images acquired from the WSI for example
            if (config.discard_previous_data or config.expected_layout == .undefined) {
                barrier_result.value_ptr.source_layout = .undefined;
            }

            //We techinically don't need/shouldn't emit the barrier if srcStage is zero, as that is a no-op and
            //is a flat waste of cpu cycles. This doesn't quite apply to image barriers though due to layout transitions
            //For now, this shouldn't cause any false-negatives and will be entirely conservative for correctness
            self.image_barriers.append(self.scratch_allocator, .{
                .image = config.image,
                .barrier = barrier_result.value_ptr.*,
            }) catch @panic("oom");
        }

        pub fn releaseImage(
            self: *@This(),
            config: struct {
                image: *const graphics.Image,
                mip_level: u32 = 0,
            },
        ) void {
            //Technically release should never be called without acquire, so get should be fine here
            //If the barrier doesn't exist it doesn't need to be released
            const barrier_result = self.image_map.getPtr(
                .{ .image = config.image, .mip_level = config.mip_level },
            ) orelse @panic("This should never happen");

            //In release, we swap the current src and dst flags and zero out the dst flags.
            //This is because any accesses done in the scope ended by this release will need to be
            //read as the src and dst flags for the next barrier, as that's when they need to be waited on
            //dst flags are set entirely by the acquire calls, so we technically don't need to store them at all,
            //But I do this mostly because most of this code assumes a full barrier struct

            barrier_result.source_stage = barrier_result.destination_stage;
            barrier_result.source_access = barrier_result.destination_access;
            barrier_result.source_layout = barrier_result.destination_layout;

            //^ Now the flags for the buffer have the accesses and stage for the acquire/release
            //scope we just ended, allowing subsequent acquire's to this buffer to encode the correct barriers and wait correctly

            //again, this is technically redundant but let's just do it for consistency
            barrier_result.destination_stage = .{};
            barrier_result.destination_access = .{};
            barrier_result.destination_layout = .undefined;
        }

        ///Flush pending barriers to the command buffer
        ///Place this before all passes and before every command in non-raster pipelines
        pub fn flushBarriers(
            self: *@This(),
            command_buffer: *graphics.CommandBuffer,
        ) !void {
            command_buffer.bufferBarriers(
                self.buffer_barriers.items(.buffer),
                self.buffer_barriers.items(.barrier),
            );
            self.buffer_barriers.shrinkRetainingCapacity(0);

            command_buffer.imageBarriers(
                self.image_barriers.items(.image),
                self.image_barriers.items(.barrier),
            );
            self.image_barriers.shrinkRetainingCapacity(0);
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
