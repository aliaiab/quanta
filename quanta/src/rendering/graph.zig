//!Render Graph implementation built on top of quanta.graphics

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
        buffer: Buffer,
        buffer_offset: usize,
        contents: []const u8,
    },
    update_image: struct {
        image: Image,
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
        buffer: Buffer,
    },
    set_raster_pipeline_image_sampler: struct {
        pipeline: RasterPipeline,
        binding_index: u32,
        array_index: u32,
        image: Image,
        sampler: Sampler,
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
        index_buffer: Buffer,
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

///Graph builder for compiling a graph
///Works like an immediate-mode-gui-type api
pub const Builder = struct {
    allocator: std.mem.Allocator,
    scratch_allocator: std.heap.ArenaAllocator,
    ///List of created resources
    raster_pipelines: std.MultiArrayList(struct {
        handle: RasterPipeline,
        ///Number of times the pipeline was referenced in the graph
        reference_count: u32,

        vertex_module: RasterModule,
        fragment_module: RasterModule,
        push_constant_size: u32,
        attachment_formats: []const ImageFormat,
    }),
    buffers: std.MultiArrayList(struct {
        handle: Buffer,
        reference_count: u32,
        size: usize,
    }),
    images: std.MultiArrayList(struct {
        handle: Image,
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
    ///List of top level passes (not render passes)
    passes: std.MultiArrayList(struct {
        handle: u64,
        reference_count: u32,
        data: PassData,
        command_offset: u32,
        command_count: u32,
        command_data_offset: u32,
        input_offset: u32,
        input_count: u16,
        output_offset: u32,
        output_count: u16,
    }),
    pass_inputs: std.MultiArrayList(struct {
        pass_index: ?u32,
        reference_count: u32,
        resource_type: ResourceType,
        resource_handle: ResourceHandle,
    }) = .{},
    pass_outputs: std.MultiArrayList(struct {
        pass_index: u32,
        reference_count: u32,
        resource_type: ResourceType,
        resource_handle: ResourceHandle,
    }) = .{},
    commands: Commands,

    ///TODO: Handle nested passes?
    ///We could have some kind of context? (IE when we call beginPass*, we context 'switch')
    current_pass_index: u32,

    pub const PassData = union(enum) {
        transfer: void,
        raster: struct {
            render_offset_x: i32,
            render_offset_y: i32,
            render_width: u32,
            render_height: u32,
            attachments: []const RasterAttachment,
        },
        compute: void,
    };

    ///Compile time constant to include debug information into each graph builder
    ///Includes source locations for each
    pub const include_debug_info = false;

    pub fn init(allocator: std.mem.Allocator) @This() {
        return .{
            .allocator = allocator,
            .scratch_allocator = std.heap.ArenaAllocator.init(allocator),
            .raster_pipelines = .{},
            .buffers = .{},
            .passes = .{},
            .commands = .{},
            .current_pass_index = 0,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.raster_pipelines.deinit(self.allocator);
        self.buffers.deinit(self.allocator);
        self.images.deinit(self.allocator);
        self.samplers.deinit(self.allocator);

        self.passes.deinit(self.allocator);
        self.pass_inputs.deinit(self.allocator);
        self.pass_outputs.deinit(self.allocator);

        self.commands.deinit(self.allocator);
        self.scratch_allocator.deinit();

        self.* = undefined;
    }

    ///Clear the graph to its default state. Allows for graph reuse for dynamically building graphs.
    pub fn clear(self: *@This()) void {
        self.raster_pipelines.len = 0;
        self.buffers.len = 0;
        self.images.len = 0;
        self.samplers.len = 0;

        self.passes.len = 0;
        self.pass_inputs.len = 0;
        self.pass_outputs.len = 0;
        self.current_pass_index = 0;

        self.commands.reset();

        _ = self.scratch_allocator.reset(std.heap.ArenaAllocator.ResetMode{ .retain_capacity = {} });
    }

    const CreateRasterPipelineOptions = struct {
        attachment_formats: []const ImageFormat,
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
        }) catch unreachable;

        return handle;
    }

    pub fn createComputePipeline(
        self: *@This(),
        comptime src: SourceLocation,
    ) ComputePipeline {
        _ = self; // autofix
        _ = src; // autofix

        @compileError("Not yet implemented");
    }

    pub fn createBuffer(
        self: *@This(),
        comptime src: SourceLocation,
        size: usize,
    ) Buffer {
        const handle_id = comptime idFromSourceLocation(src);

        const handle: Buffer = .{
            .id = handle_id,
        };

        self.buffers.append(self.allocator, .{
            .handle = handle,
            .size = size,
            .reference_count = 0,
        }) catch unreachable;

        return handle;
    }

    pub fn createImage(
        self: *@This(),
        comptime src: SourceLocation,
        format: ImageFormat,
        width: u32,
        height: u32,
        depth: u32,
    ) Image {
        const handle_id = comptime idFromSourceLocation(src);

        const handle: Image = .{
            .id = handle_id,
        };

        self.images.append(self.allocator, .{
            .handle = .{ .id = handle_id },
            .format = format,
            .reference_count = 0,
            .width = width,
            .height = height,
            .depth = depth,
        }) catch unreachable;

        return handle;
    }

    pub fn imageGetWidth(
        self: *@This(),
        image: anytype,
    ) u32 {
        const index = self.referenceResource(image);

        return self.images.items(.width)[index];
    }

    pub fn imageGetHeight(
        self: *@This(),
        image: anytype,
    ) u32 {
        const index = self.referenceResource(image);

        return self.images.items(.height)[index];
    }

    pub fn imageGetDepth(
        self: *@This(),
        image: anytype,
    ) u32 {
        const index = self.referenceResource(image);

        return self.images.items(.depth)[index];
    }

    pub fn imageGetFormat(
        self: *@This(),
        image: anytype,
    ) ImageFormat {
        const index = self.referenceResource(image);

        return self.images.items(.format)[index];
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

    pub fn InputType(comptime InputTuple: type) type {
        var fields: [std.meta.fields(InputTuple).len]std.builtin.Type.StructField = undefined;

        inline for (std.meta.fields(InputTuple), 0..) |tuple_field, index| {
            var field_type: type = undefined;

            switch (tuple_field.type) {
                Buffer => {
                    field_type = PassInput(Buffer);
                },
                Image => {
                    field_type = PassInput(Image);
                },
                else => {
                    if (@hasDecl(tuple_field.type, "pass_input")) {
                        field_type = tuple_field.type;
                    } else if (@hasDecl(tuple_field.type, "pass_output")) {
                        field_type = PassInput(tuple_field.type.ResourceType);
                    } else {
                        field_type = InputType(tuple_field.type);
                    }
                },
            }

            fields[index] = .{
                .name = tuple_field.name,
                .type = field_type,
                .default_value = null,
                .is_comptime = false,
                .alignment = @alignOf(field_type),
            };
        }

        return @Type(.{
            .Struct = std.builtin.Type.Struct{
                .layout = .Auto,
                .fields = &fields,
                .decls = &.{},
                .is_tuple = false,
            },
        });
    }

    fn parseInputs(self: *@This(), inputs: anytype) InputType(@TypeOf(inputs)) {
        var result: InputType(@TypeOf(inputs)) = undefined;

        inline for (std.meta.fields(@TypeOf(inputs))) |input| {
            const T = input.type;

            const field = @field(inputs, input.name);

            const input_index: u32 = @intCast(self.pass_inputs.len);

            switch (T) {
                Buffer => {
                    self.pass_inputs.append(self.allocator, .{
                        .pass_index = null,
                        .reference_count = 0,
                        .resource_type = .buffer,
                        .resource_handle = .{ .id = field.id },
                    }) catch unreachable;

                    @field(result, input.name) = PassInput(Buffer){
                        .index = input_index,
                        .resource = field,
                    };
                },
                Image => {
                    self.pass_inputs.append(self.allocator, .{
                        .pass_index = null,
                        .reference_count = 0,
                        .resource_type = .image,
                        .resource_handle = .{ .id = field.id },
                    }) catch unreachable;

                    @field(result, input.name) = PassInput(Image){
                        .index = input_index,
                        .resource = field,
                    };
                },
                else => {
                    if (@hasDecl(input.type, "pass_input")) {
                        @field(result, input.name) = @field(inputs, input.name);
                    } else if (@hasDecl(input.type, "pass_output")) {
                        self.referencePassOutput(field);

                        // @compileLog(input.type);

                        self.pass_inputs.append(self.allocator, .{
                            .pass_index = self.pass_outputs.items(.pass_index)[field.index],
                            .reference_count = 0,
                            .resource_type = switch (input.type) {
                                PassOutput(Buffer) => .buffer,
                                PassOutput(Image) => .image,
                                else => @compileError("Resource type not supported"),
                            },
                            .resource_handle = .{ .id = field.resource.id },
                        }) catch unreachable;

                        @field(result, input.name) = PassInput(input.type.ResourceType){
                            .index = input_index,
                            .resource = field.resource,
                        };
                    } else {
                        // @compileError("Input Type not supported");
                        // field_type = InputType(tuple_field.type);

                        @field(result, input.name) = self.parseInputs(field);
                    }
                },
            }
        }

        return result;
    }

    pub fn OutputType(comptime OutputTuple: type) type {
        var fields: [std.meta.fields(OutputTuple).len]std.builtin.Type.StructField = undefined;

        inline for (std.meta.fields(OutputTuple), 0..) |tuple_field, index| {
            var field_type: type = undefined;

            switch (tuple_field.type) {
                else => {
                    if (@hasDecl(tuple_field.type, "pass_output")) {
                        field_type = tuple_field.type;
                    } else if (@hasDecl(tuple_field.type, "pass_input")) {
                        field_type = PassOutput(tuple_field.type.ResourceType);
                    } else {
                        @compileError("Input Type not supported");
                    }
                },
            }

            fields[index] = .{
                .name = tuple_field.name,
                .type = field_type,
                .default_value = null,
                .is_comptime = false,
                .alignment = @alignOf(field_type),
            };
        }

        return @Type(.{
            .Struct = std.builtin.Type.Struct{
                .layout = .Auto,
                .fields = &fields,
                .decls = &.{},
                .is_tuple = false,
            },
        });
    }

    fn parseOutputs(self: *@This(), outputs: anytype) OutputType(@TypeOf(outputs)) {
        var result: OutputType(@TypeOf(outputs)) = undefined;

        inline for (std.meta.fields(@TypeOf(outputs))) |output| {
            const T = output.type;

            const field = @field(outputs, output.name);

            const output_index: u32 = @intCast(self.pass_outputs.len);

            switch (T) {
                else => {
                    if (@hasDecl(output.type, "pass_output")) {
                        //Output passthrough
                        @field(result, output.name) = @field(outputs, output.name);
                    } else if (@hasDecl(output.type, "pass_input")) {
                        self.pass_outputs.append(self.allocator, .{
                            .pass_index = self.current_pass_index,
                            .reference_count = 0,
                            .resource_type = if (output.type.ResourceType == Buffer) .buffer else .image,
                            .resource_handle = .{ .id = field.resource.id },
                        }) catch unreachable;

                        @field(result, output.name) = PassOutput(output.type.ResourceType){
                            .index = output_index,
                            .resource = field.resource,
                        };
                    } else {
                        @compileError("Input Type not supported");
                    }
                },
            }
        }

        return result;
    }

    fn referencePassInput(self: *@This(), pass_input: anytype) void {
        self.pass_inputs.items(.reference_count)[pass_input.index] += 1;

        _ = self.referenceResource(pass_input.resource);
    }

    fn referencePassOutput(self: *@This(), pass_output: anytype) void {
        self.pass_outputs.items(.reference_count)[pass_output.index] += 1;

        _ = self.referenceResource(pass_output.resource);
    }

    ///Begins a pass for transferring, copying and updating resources
    pub fn beginTransferPass(
        self: *@This(),
        ///Uniquely identifies the pass
        comptime src: SourceLocation,
        ///The input dependencies for the pass
        inputs: anytype,
    ) InputType(@TypeOf(inputs)) {
        const pass_id = comptime idFromSourceLocation(src);

        self.beginPassGeneric(pass_id, .transfer, std.meta.fields(@TypeOf(inputs)).len);

        return self.parseInputs(inputs);
    }

    pub fn endTransferPass(
        self: *@This(),
        outputs: anytype,
    ) OutputType(@TypeOf(outputs)) {
        const output_result = self.parseOutputs(outputs);

        self.endPassGeneric();

        return output_result;
    }

    ///Update the buffer with contents.
    ///Must be in a pass.
    ///Returns the modified buffer.
    pub fn updateBuffer(
        self: *@This(),
        buffer: PassInput(Buffer),
        ///The offset into buffer from which contents are written
        buffer_offset: usize,
        comptime T: type,
        contents: []const T,
    ) void {
        self.referencePassInput(buffer);

        self.commands.add(self.allocator, .{
            .update_buffer = .{
                .buffer = buffer.resource,
                .buffer_offset = buffer_offset,
                .contents = std.mem.sliceAsBytes(contents),
            },
        });
    }

    pub fn updateImage(
        self: *@This(),
        image: PassInput(Image),
        offset: usize,
        comptime T: type,
        contents: []const T,
    ) void {
        self.referencePassInput(image);

        self.commands.add(self.allocator, .{
            .update_image = .{
                .image = .{ .id = image.resource.id },
                .image_offset = offset,
                .contents = std.mem.sliceAsBytes(contents),
            },
        });
    }

    pub const RasterAttachment = struct {
        image: Image,
        clear: ?Clear = null,
        ///TODO: determine this at graph compile?
        store: bool = true,

        pub const Clear = union(enum) {
            color: [4]f32,
            depth: f32,
        };
    };

    pub fn beginRasterPass(
        self: *@This(),
        ///Uniquely identifies the pass
        comptime src: SourceLocation,
        attachments: []const RasterAttachment,
        offset_x: i32,
        offset_y: i32,
        width: u32,
        height: u32,
        ///The input dependencies for the pass
        inputs: anytype,
    ) InputType(@TypeOf(inputs)) {
        const pass_id = comptime idFromSourceLocation(src);

        const attachments_allocated = self.scratch_allocator.allocator().dupe(RasterAttachment, attachments) catch unreachable;

        self.beginPassGeneric(pass_id, .{
            .raster = .{
                .render_offset_x = offset_x,
                .render_offset_y = offset_y,
                .render_width = width,
                .render_height = height,
                //TODO: IMPORTANT! add attachments as implicit inputs to the pass
                .attachments = attachments_allocated,
            },
        }, std.meta.fields(@TypeOf(inputs)).len);

        return self.parseInputs(inputs);
    }

    pub fn endRasterPass(
        self: *@This(),
        outputs: anytype,
    ) @TypeOf(outputs) {
        self.endPassGeneric();

        return outputs;
    }

    fn beginPassGeneric(
        self: *@This(),
        id: u64,
        data: PassData,
        input_count: usize,
    ) void {
        self.current_pass_index = @intCast(self.passes.len);

        self.passes.append(self.allocator, .{
            .handle = id,
            .reference_count = 0,
            .command_offset = @intCast(self.commands.tags.items.len),
            .command_count = 0,
            .command_data_offset = @intCast(self.commands.data.items.len),
            .data = data,
            .input_offset = @intCast(self.pass_inputs.len),
            .input_count = @intCast(input_count),
            .output_offset = @intCast(self.pass_outputs.len),
            .output_count = 0,
        }) catch unreachable;
    }

    fn endPassGeneric(
        self: *@This(),
    ) void {
        const command_count = self.commands.tags.items.len - self.passes.items(.command_offset)[self.current_pass_index];
        const input_count = self.pass_inputs.len - self.passes.items(.input_offset)[self.current_pass_index];
        const output_count = self.pass_outputs.len - self.passes.items(.output_offset)[self.current_pass_index];

        self.passes.items(.command_count)[self.current_pass_index] = @intCast(command_count);
        self.passes.items(.output_count)[self.current_pass_index] = @intCast(output_count);
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
        buffer: PassInput(Buffer),
    ) void {
        self.referencePassInput(buffer);

        self.commands.add(self.allocator, .{
            .set_raster_pipeline_resource_buffer = .{
                .pipeline = pipeline,
                .binding_index = binding_index,
                .array_index = array_index,
                .buffer = buffer.resource,
            },
        });
    }

    pub fn setRasterPipelineImageSampler(
        self: *@This(),
        pipeline: RasterPipeline,
        binding_index: u32,
        array_index: u32,
        image: PassInput(Image),
        sampler: Sampler,
    ) void {
        self.referencePassInput(image);
        _ = self.referenceResource(sampler);

        self.commands.add(self.allocator, .{
            .set_raster_pipeline_image_sampler = .{
                .pipeline = pipeline,
                .binding_index = binding_index,
                .array_index = array_index,
                .image = .{ .id = image.resource.id },
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
        buffer: PassInput(Buffer),
        index_type: IndexType,
    ) void {
        self.referencePassInput(buffer);

        self.commands.add(self.allocator, .{
            .set_index_buffer = .{
                .index_buffer = buffer.resource,
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

    ///Incrementes the refence count for buffer and resolves the buffer index
    pub fn referenceBuffer(self: *@This(), buffer: Buffer) usize {
        return self.referenceResource(buffer);
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
    buffers: std.AutoArrayHashMapUnmanaged(u64, graphics.Buffer) = .{},
    images: std.AutoArrayHashMapUnmanaged(u64, struct {
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
        const handle = builder.createImage(
            src,
            @enumFromInt(@intFromEnum(image.format)),
            image.width,
            image.height,
            1,
        );

        const get_or_put_result = self.images.getOrPut(self.allocator, handle.id) catch unreachable;

        get_or_put_result.value_ptr.image = image;
        get_or_put_result.value_ptr.imported = true;

        return handle;
    }

    ///Compiles a built graph to low level api commands
    pub fn compile(
        self: *@This(),
        builder: Builder,
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

        if (builder.passes.len == 0) {
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
            const root_pass_index: u32 = @intCast(builder.passes.len - 1);

            try self.compilePassDependencies(
                builder,
                root_pass_index,
                &dependencies,
            );
        }

        var buffer_usages: std.AutoArrayHashMapUnmanaged(Buffer, struct {
            usage: graphics.vulkan.BufferUsageFlags,
        }) = .{};
        defer buffer_usages.deinit(self.scratch_allocator.allocator());

        var image_usages: std.AutoArrayHashMapUnmanaged(u64, struct {
            usage: graphics.vulkan.ImageUsageFlags,
        }) = .{};
        defer image_usages.deinit(self.scratch_allocator.allocator());

        for (dependencies.items) |*dependency| {
            if (dependency.generated_commands) continue;

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
                            command_data.image.id,
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
                            command_data.image.id,
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
        {
            const raster_pipeline_reference_counts = builder.raster_pipelines.items(.reference_count);

            for (raster_pipeline_reference_counts, 0..) |reference_count, pipeline_index| {
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

                const vertex_module: RasterModule = builder.raster_pipelines.items(.vertex_module)[pipeline_index];
                const fragment_module: RasterModule = builder.raster_pipelines.items(.fragment_module)[pipeline_index];
                const push_constant_size = builder.raster_pipelines.items(.push_constant_size)[pipeline_index];
                const attachment_formats = builder.raster_pipelines.items(.attachment_formats)[pipeline_index];

                //otherwise create the pipeline
                get_or_put_res.value_ptr.* = try graphics.GraphicsPipeline.init(
                    self.allocator,
                    .{
                        .color_attachment_formats = @as([*]const graphics.vulkan.Format, @alignCast(@ptrCast(attachment_formats.ptr)))[0..attachment_formats.len],
                        .vertex_shader_binary = @alignCast(vertex_module.code),
                        .fragment_shader_binary = @alignCast(fragment_module.code),
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
                    //TODO: handle vertex layouts (if anyone's using that in 2024)
                    null,
                    //TODO: runtime push constants
                    push_constant_size,
                );
                errdefer get_or_put_res.value_ptr.deinit(self.allocator);
            }

            for (builder.buffers.items(.reference_count), 0..) |reference_count, buffer_index| {
                if (reference_count == 0) {
                    //TODO: deallocate unreferenced pipelines if they have a backing store
                    continue;
                }

                const handle: Buffer = builder.buffers.items(.handle)[buffer_index];

                const get_or_put_res = try self.buffers.getOrPut(self.allocator, handle.id);

                //cache hit
                if (get_or_put_res.found_existing) {
                    continue;
                }

                const buffer_size = builder.buffers.items(.size)[buffer_index];

                get_or_put_res.value_ptr.* = try graphics.Buffer.initUsageFlags(
                    buffer_size,
                    buffer_usages.get(handle).?.usage,
                );
                errdefer get_or_put_res.value_ptr.deinit();
            }

            for (builder.images.items(.reference_count), 0..) |reference_count, image_index| {
                if (reference_count == 0) {
                    //TODO: deallocate unreferenced pipelines if they have a backing store
                    continue;
                }

                const handle: Image = builder.images.items(.handle)[image_index];

                const get_or_put_res = try self.images.getOrPut(self.allocator, handle.id);

                //cache hit
                if (get_or_put_res.found_existing) {
                    continue;
                }

                const image_width = builder.images.items(.width)[image_index];
                const image_height = builder.images.items(.height)[image_index];
                const image_depth = builder.images.items(.depth)[image_index];
                const image_format = builder.images.items(.format)[image_index];

                get_or_put_res.value_ptr.*.image = try graphics.Image.init(
                    .@"2d",
                    image_width,
                    image_height,
                    image_depth,
                    1,
                    @enumFromInt(@intFromEnum(image_format)),
                    .shader_read_only_optimal,
                    image_usages.get(handle.id).?.usage,
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
                if (dependency.generated_commands) continue;

                var command_iter = builder.passCommandIterator(dependency.pass_index);

                while (command_iter.next()) |command| {
                    switch (command) {
                        .update_buffer => |update_buffer| {
                            self.preAllocateStagingMemory(1, update_buffer.contents.len);
                        },
                        .update_image => |update_image| {
                            //TODO: align based on the format
                            self.preAllocateStagingMemory(4, update_image.contents.len);
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
                if (dependency.generated_commands) continue;
                defer dependency.generated_commands = true;

                const pass_index = dependency.pass_index;
                const pass_data: Builder.PassData = builder.passes.items(.data)[pass_index];

                var current_pipline: ?*graphics.GraphicsPipeline = null;
                var current_index_buffer: ?*graphics.Buffer = null;

                if (pass_data == .raster) {
                    const attachments_input = pass_data.raster.attachments;

                    // attachment barrier prepass
                    for (attachments_input) |
                        input,
                    | {
                        const image = &self.images.getPtr(input.image.id).?.image;

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
                            const buffer = self.buffers.getPtr(update_buffer.buffer.id).?;

                            try barrier_map.writeBuffer(
                                buffer,
                                .{ .copy = true },
                                .{ .transfer_write = true },
                            );
                        },
                        .update_image => |update_image| {
                            const image = &self.images.getPtr(update_image.image.id).?.image;

                            try barrier_map.writeImage(
                                image,
                                .{ .copy = true },
                                .{ .transfer_write = true },
                                .transfer_dst_optimal,
                            );
                        },
                        .set_raster_pipeline_resource_buffer => |command_data| {
                            const buffer = self.buffers.getPtr(command_data.buffer.id).?;

                            barrier_map.readBuffer(
                                buffer,
                                .{ .vertex_shader = true, .fragment_shader = true },
                                .{ .shader_read = true },
                            );
                        },
                        .set_raster_pipeline_image_sampler => |command_data| {
                            const image = &self.images.getPtr(command_data.image.id).?.image;

                            barrier_map.readImage(
                                image,
                                .{ .fragment_shader = true },
                                .{ .shader_read = true },
                                .shader_read_only_optimal,
                            );
                        },
                        .set_index_buffer => |command_data| {
                            current_index_buffer = self.buffers.getPtr(command_data.index_buffer.id).?;
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

                if (pass_data == .raster) {
                    const x = pass_data.raster.render_offset_x;
                    const y = pass_data.raster.render_offset_y;
                    const width = pass_data.raster.render_width;
                    const height = pass_data.raster.render_height;
                    const attachments_input = pass_data.raster.attachments;

                    const attachments = try self.scratch_allocator.allocator().alloc(graphics.CommandBuffer.Attachment, attachments_input.len);
                    defer self.scratch_allocator.allocator().free(attachments);

                    for (attachments_input, attachments) |input, *output| {
                        output.image = &self.images.getPtr(input.image.id).?.image;
                        output.clear = if (input.clear != null) switch (input.clear.?) {
                            .color => |color| .{ .color = color },
                            else => unreachable,
                        } else null;
                        output.store = input.store;
                    }

                    command_buffer.beginRenderPass(
                        x,
                        y,
                        width,
                        height,
                        attachments,
                        null,
                    );
                }
                defer if (pass_data == .raster) command_buffer.endRenderPass();

                current_pipline = null;
                current_index_buffer = null;

                command_iter = builder.passCommandIterator(pass_index);

                //encode final commands
                while (command_iter.next()) |command| {
                    switch (command) {
                        .update_buffer => |update_buffer| {
                            const buffer = self.buffers.getPtr(update_buffer.buffer.id).?;

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
                            const image = self.images.getPtr(update_image.image.id).?.image;

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
                            const buffer = self.buffers.getPtr(command_data.buffer.id).?;

                            current_pipline.?.setDescriptorBuffer(
                                command_data.binding_index,
                                command_data.array_index,
                                buffer.*,
                            );
                        },
                        .set_raster_pipeline_image_sampler => |command_data| {
                            const image = &self.images.getPtr(command_data.image.id).?.image;
                            const sampler = self.samplers.getPtr(command_data.sampler.id).?;

                            current_pipline.?.setDescriptorImageSampler(
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
                            current_index_buffer = self.buffers.getPtr(command_data.index_buffer.id).?;

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
        reference_count: u32 = 0,
        ///Have the commands for this dependency already been compiled
        generated_commands: bool = false,
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
            const pass_if_any = builder.pass_inputs.items(.pass_index)[input_offset + input_index];
            const input_reference_count = builder.pass_inputs.items(.reference_count)[input_offset + input_index];

            if (pass_if_any) |pass_dependency_index| {
                if (input_reference_count != 0) {
                    const existing_index = block: for (pass_dependencies, 0..) |pass_dep, dependency_index| {
                        if (pass_dep.pass_index == pass_dependency_index) break :block dependency_index;
                    } else dependency_count;

                    const found_existing = existing_index != dependency_count;

                    if (found_existing) continue;

                    pass_dependencies[dependency_count] = .{
                        .reference_count = 1,
                        .pass_index = pass_dependency_index,
                    };

                    dependency_count += 1;
                }
            }
        }

        for (pass_dependencies[0..dependency_count]) |dep| {
            try self.compilePassDependencies(
                builder,
                dep.pass_index,
                dependencies,
            );
        } else {
            try dependencies.append(self.scratch_allocator.allocator(), .{
                .reference_count = 1,
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

pub fn PassInput(comptime Resource: type) type {
    return struct {
        ///Input index
        index: u32,
        resource: Resource,

        pub const pass_input = Resource;
        pub const ResourceType = Resource;
    };
}

pub fn PassOutput(comptime Resource: type) type {
    return struct {
        ///Input index
        index: u32,
        resource: Resource,

        pub const pass_output = Resource;
        pub const ResourceType = Resource;
    };
}

pub const ResourceType = enum {
    buffer,
    image,
};

///Generic type erased resource handle
pub const ResourceHandle = packed struct(u64) {
    id: u64,
};

///TODO: provide specialisation constants
pub const RasterModule = struct {
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
    id: u64,

    pub const resource_type = .buffer;
};

pub const Image = struct {
    id: u64,

    pub const resource_type = .image;
};

pub const ImageFormat = enum(u32) {
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
