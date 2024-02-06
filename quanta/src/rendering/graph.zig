//!Render Graph implementation built on top of quanta.graphics

pub const IndexType = enum {
    u16,
    u32,
};

pub const Command = union(enum) {
    update_buffer: struct {
        buffer: Buffer,
        buffer_offset: usize,
        contents: []const u8,
    },
    update_image: struct {
        image: ImageUntyped,
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
        image: ImageUntyped,
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

        //The static, inital size for this buffer
        //TODO: make this a dynamic size?
        size: usize,
    }),
    images: std.MultiArrayList(struct {
        handle: ImageUntyped,
        reference_count: u32,
        layout: ImageLayout,
        format: ImageFormat,
        width: u32,
        height: u32,
        depth: u32,
    }) = .{},
    samplers: std.MultiArrayList(struct {
        handle: Sampler,
        reference_count: u32,
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
        //What pass is this from, if any
        pass_index: ?u32,
        //The number of times this input was referenced (for culling)
        reference_count: u32,
        resource_type: ResourceType,
        resource_handle: ResourceHandle,
        ///layout if any
        layout: ImageLayout,
        //Represents any transformations that were applied during the pass that this comes from
        transform: InputOutputTransform,
    }) = .{},
    pass_outputs: std.MultiArrayList(struct {
        //What pass is this from. All outputs come from passes
        //TODO: make this a pass id rather than index
        pass_index: u32,
        reference_count: u32,
        resource_type: ResourceType,
        resource_handle: ResourceHandle,
        layout: ImageLayout,
        //Represents any transformations that were applied during the pass
        transform: InputOutputTransform,
    }) = .{},
    commands: Commands,

    ///TODO: Handle nested passes?
    ///We could have some kind of context? (IE when we call beginPass*, we context 'switch')
    current_pass_index: u32,

    ///Represents a transformation (potential mutation) applied to a resource
    ///When all flags are set to zero, it represents a nop (no writes applied)
    pub const InputOutputTransform = packed struct(u16) {
        shader_write: bool,
        transfer_write: bool,
        padding: u14 = 0,

        pub const no_op = InputOutputTransform{
            .shader_write = false,
            .transfer_write = false,
        };
    };

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
        comptime layout: ImageLayout,
        format: ImageFormat,
        width: u32,
        height: u32,
        depth: u32,
    ) Image(layout) {
        const handle_id = comptime idFromSourceLocation(src);

        const handle: Image(layout) = .{
            .id = handle_id,
        };

        self.images.append(self.allocator, .{
            .handle = .{ .id = handle_id },
            .layout = layout,
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
    ) Sampler {
        const handle_id = comptime idFromSourceLocation(src);

        const handle: Sampler = .{
            .id = handle_id,
        };

        self.samplers.append(self.allocator, .{
            .handle = .{ .id = handle_id },
            .reference_count = 0,
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
                Image(.general) => {
                    field_type = PassInput(Image(.general));
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
                        .layout = .general,
                        .transform = InputOutputTransform.no_op,
                    }) catch unreachable;

                    @field(result, input.name) = PassInput(Buffer){
                        .index = input_index,
                        .resource = field,
                    };
                },
                Image(.general) => {
                    self.pass_inputs.append(self.allocator, .{
                        .pass_index = null,
                        .reference_count = 0,
                        .resource_type = .image,
                        .resource_handle = .{ .id = field.id },
                        .layout = .general,
                        .transform = InputOutputTransform.no_op,
                    }) catch unreachable;

                    @field(result, input.name) = PassInput(Image(.general)){
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
                                PassOutput(Image(.general)) => .image,
                                else => @compileError("Resource type not supported"),
                            },
                            .resource_handle = .{ .id = field.resource.id },
                            .layout = .general,
                            .transform = InputOutputTransform.no_op,
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
                            .layout = .general,
                            .transform = InputOutputTransform.no_op,
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
        image: PassInput(Image(.general)),
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
        image: Image(.attachment),
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
        image: PassInput(Image(.general)),
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

    ///Incrementes the refence count for buffer and resolves the resource index
    fn referenceResource(self: *@This(), resource: anytype) usize {
        const resources = switch (@TypeOf(resource)) {
            RasterPipeline => &self.raster_pipelines,
            Buffer => &self.buffers,
            Image(.general), Image(.attachment) => &self.images,
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

        // return hashSourceLocation({}, src);

        return hasher.finalInt();
    }

    pub const SourceLocation = std.builtin.SourceLocation;
};

///Contains all graphics resources (pipelines, buffers, textures ect..)
pub const CompileContext = struct {
    allocator: std.mem.Allocator,
    scratch_allocator: std.heap.ArenaAllocator,
    ///TODO: better way to do this?
    double_buffer: [2]struct {
        graphics_command_buffer: ?graphics.CommandBuffer = null,

        //global staging buffer pool
        staging_buffer: ?graphics.Buffer = null,
        staging_buffer_size: usize = 0,
        staging_buffer_offset: usize = 0,
        staging_buffer_mapping: [*]u8 = undefined,
    } = .{ .{}, .{} },
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

    pub fn init(allocator: std.mem.Allocator) CompileContext {
        return .{
            .allocator = allocator,
            .scratch_allocator = std.heap.ArenaAllocator.init(allocator),
        };
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

        for (&self.double_buffer) |*buffer| {
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
        comptime layout: ImageLayout,
    ) Image(layout) {
        const handle = builder.createImage(
            src,
            layout,
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
            self.buffer_index = if (self.buffer_index != 0) 1 else 0;
        }

        defer _ = self.scratch_allocator.reset(.retain_capacity);

        const compile_buffer = &self.double_buffer[self.buffer_index];

        compile_buffer.staging_buffer_offset = 0;
        compile_buffer.staging_buffer_size = 0;

        if (compile_buffer.graphics_command_buffer == null) {
            compile_buffer.graphics_command_buffer = try graphics.CommandBuffer.init(.graphics);
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

                //TODO: aggregate global usage of each buffer
                get_or_put_res.value_ptr.* = try graphics.Buffer.init(buffer_size, .index);
                errdefer get_or_put_res.value_ptr.deinit();
            }

            for (builder.images.items(.reference_count), 0..) |reference_count, image_index| {
                if (reference_count == 0) {
                    //TODO: deallocate unreferenced pipelines if they have a backing store
                    continue;
                }

                const handle: ImageUntyped = builder.images.items(.handle)[image_index];

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
                    .{
                        .transfer_dst_bit = true,
                        .sampled_bit = true,
                    },
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

                get_or_put_res.value_ptr.* = try graphics.Sampler.init(
                    .nearest,
                    .nearest,
                    .repeat,
                    .repeat,
                    .repeat,
                    null,
                );
                errdefer get_or_put_res.value_ptr.deinit();
            }
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

        //Staging memory preallocate pass
        {
            for (dependencies.items) |*dependency| {
                if (dependency.generated_commands) continue;

                const pass_index = dependency.pass_index;

                const command_offset = builder.passes.items(.command_offset)[pass_index];
                const command_count = builder.passes.items(.command_count)[pass_index];

                var command_iter = builder.commands.iterator(
                    command_offset,
                    command_count,
                    builder.passes.items(.command_data_offset)[pass_index],
                );

                while (command_iter.next()) |command| {
                    switch (command) {
                        .update_buffer => |update_buffer| {
                            self.preAllocateStagingMemory(1, update_buffer.contents.len);
                        },
                        .update_image => |update_image| {
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

                const command_offset = builder.passes.items(.command_offset)[pass_index];
                const command_count = builder.passes.items(.command_count)[pass_index];
                const command_data_offset = builder.passes.items(.command_data_offset)[pass_index];
                const pass_data: Builder.PassData = builder.passes.items(.data)[pass_index];

                var command_iter = builder.commands.iterator(
                    command_offset,
                    command_count,
                    command_data_offset,
                );

                var current_pipline: ?*graphics.GraphicsPipeline = null;
                var current_index_buffer: ?*graphics.Buffer = null;

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
                            );
                        },
                        .set_raster_pipeline_resource_buffer => |command_data| {
                            const buffer = self.buffers.getPtr(command_data.buffer.id).?;

                            barrier_map.readBuffer(
                                buffer,
                                .{ .vertex_shader = true },
                                .{ .shader_read = true },
                            );
                        },
                        .set_raster_pipeline_image_sampler => |command_data| {
                            const image = &self.images.getPtr(command_data.image.id).?.image;

                            barrier_map.readImage(
                                image,
                                .{
                                    .fragment_shader = true,
                                },
                                .{
                                    .shader_read = true,
                                },
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

                for (barrier_map.buffer_map.keys(), barrier_map.buffer_map.values()) |buffer, barrier| {
                    command_buffer.bufferBarrier(buffer.*, barrier);
                }

                for (barrier_map.image_map.keys(), barrier_map.image_map.values()) |image, barrier| {
                    command_buffer.imageBarrier(image.*, barrier);
                }

                if (pass_data == .raster) {
                    const x = pass_data.raster.render_offset_x;
                    const y = pass_data.raster.render_offset_y;
                    const width = pass_data.raster.render_width;
                    const height = pass_data.raster.render_height;
                    const attachments_input = pass_data.raster.attachments;

                    const attachments = try self.allocator.alloc(graphics.CommandBuffer.Attachment, attachments_input.len);
                    defer self.allocator.free(attachments);

                    for (attachments_input, attachments) |input, *output| {
                        output.image = &self.images.getPtr(input.image.id).?.image;
                        output.clear = null;
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

                command_iter = builder.commands.iterator(
                    command_offset,
                    command_count,
                    command_data_offset,
                );

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
        const frame_data = &self.double_buffer[self.buffer_index];

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
        const frame_data = &self.double_buffer[self.buffer_index];

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

        pub fn deinit(self: *@This()) void {
            self.buffer_map.deinit(self.context.scratch_allocator.allocator());
            self.image_map.deinit(self.context.scratch_allocator.allocator());

            self.* = undefined;
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
            }
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

        pub fn readImage(
            self: *@This(),
            image: *const graphics.Image,
            stage: graphics.CommandBuffer.PipelineStage,
            access: graphics.CommandBuffer.ResourceAccess,
        ) void {
            const maybe_barrier = self.image_map.getPtr(image);

            if (maybe_barrier) |out_barrier| {
                updateBarrierMask(
                    &out_barrier.*.destination_stage,
                    &out_barrier.*.destination_access,
                    stage,
                    access,
                );
            }
        }

        pub fn writeImage(
            self: *@This(),
            image: *const graphics.Image,
            stage: graphics.CommandBuffer.PipelineStage,
            access: graphics.CommandBuffer.ResourceAccess,
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

pub const Buffer = struct {
    id: u64,

    pub const resource_type = .buffer;
};

pub const ImageUntyped = struct {
    id: u64,

    pub const resource_type = .image;
};

pub const ImageLayout = enum {
    ///Use for attachment inputs and outputs
    attachment,
    ///Use for buffers and shader accessible things
    general,
};

///Strongly typed representation of an image with layout. Contains read/write semantics and layout semantics
pub fn Image(comptime layout: ImageLayout) type {
    _ = layout; // autofix
    return struct {
        id: u64,

        pub const resource_type = .image;
    };
}

pub const ImageFormat = enum(i32) {
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
};

pub fn imageLayoutCast(comptime layout: ImageLayout, resource: anytype) Image(layout) {
    _ = resource; // autofix
}

pub const Sampler = struct {
    id: u64,
};

test {
    std.testing.refAllDecls(@This());
}

const Graph = @This();
const std = @import("std");
