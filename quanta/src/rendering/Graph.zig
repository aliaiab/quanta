//!Render Graph implementation built on top of quanta.graphics

pub fn init() Graph {
    return undefined;
}

pub fn deinit(self: *Graph) void {
    self.* = undefined;
}

///Graph builder for compiling a graph
///Works like an immediate-mode-gui-type api
pub const Builder = struct {
    allocator: std.mem.Allocator,
    ///List of created resources
    raster_pipelines: std.MultiArrayList(struct {
        handle: RasterPipeline,
        ///Number of times the pipeline was referenced in the graph
        reference_count: u32,

        vertex_module: RasterModule,
        fragment_module: RasterModule,
        push_constant_size: u32,
    }),
    buffers: std.MultiArrayList(struct {
        handle: Buffer,
        reference_count: u32,

        //The static, inital size for this buffer
        size: usize,
    }),
    ///List of top level passes (not render passes)
    passes: std.MultiArrayList(struct {
        handle: u64,
        reference_count: u32,
        //Ordered Command list
        command_offset: u32,
        command_count: u32,
        tag: PassTag,
    }),
    commands: std.MultiArrayList(Command),
    update_buffer_commands: std.ArrayListUnmanaged(Command.UpdateBuffer) = .{},
    set_pipeline_commands: std.ArrayListUnmanaged(Command.SetRasterPipeline) = .{},

    ///TODO: Handle nested passes?
    current_pass_index: u32,

    pub const PassTag = enum {
        transfer,
        raster,
    };

    ///High level command as part of a pass
    pub const Command = struct {
        index: u32,
        tag: Tag,

        pub const Tag = enum {
            update_buffer,
            set_raster_pipeline,
        };

        pub const UpdateBuffer = struct {
            buffer: Buffer,
            buffer_offset: usize,
            contents: []const u8,
        };

        pub const SetRasterPipeline = struct {
            pipeline: RasterPipeline,
        };
    };

    ///Compile time constant to include debug information into each graph builder
    ///Includes source locations for each
    pub const include_debug_info = false;

    pub fn init(allocator: std.mem.Allocator) @This() {
        return .{
            .allocator = allocator,
            .raster_pipelines = .{},
            .buffers = .{},
            .passes = .{},
            .commands = .{},
            .update_buffer_commands = .{},
            .current_pass_index = 0,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.raster_pipelines.deinit(self.allocator);
        self.buffers.deinit(self.allocator);
        self.passes.deinit(self.allocator);
        self.commands.deinit(self.allocator);
        self.update_buffer_commands.deinit(self.allocator);

        self.* = undefined;
    }

    ///Clear the graph to its default state. Allows for graph reuse for dynamically building graphs.
    pub fn clear(self: *@This()) void {
        self.raster_pipelines.len = 0;
        self.buffers.len = 0;
        self.passes.len = 0;
        self.current_pass_index = 0;
    }

    const CreateRasterPipelineOptions = struct {
        attachment_formats: []const ImageFormat,
    };

    ///Resource creation
    ///Can be created outside or inside a pass
    pub fn createRasterPipeline(
        self: *@This(),
        comptime src: SourceLocation,
        vertex_module: RasterModule,
        fragment_module: RasterModule,
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

    ///Create a buffer with a fixed size
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
    ) Image(layout) {
        _ = self; // autofix
        _ = src; // autofix

        @compileError("Unimplemented");
    }

    pub fn createSampler(
        self: *@This(),
        comptime src: SourceLocation,
    ) Sampler {
        _ = self; // autofix
        _ = src; // autofix

        @compileError("Unimplemented");
    }

    //an input type could be like this:
    const ExampleInput = struct {
        color_attachment: Image(.attachment),
        shadow_attachment: Image(.general),
    };

    ///Begins a pass for transferring, copying and updating resources
    pub fn beginTransferPass(
        self: *@This(),
        ///Uniquely identifies the pass
        comptime src: SourceLocation,
        ///The input dependencies for the pass
        inputs: anytype,
    ) @TypeOf(inputs) {
        const pass_id = comptime idFromSourceLocation(src);

        self.current_pass_index = @intCast(self.passes.len);

        self.passes.append(self.allocator, .{
            .handle = pass_id,
            .reference_count = 0,
            .command_offset = @intCast(self.commands.len),
            .command_count = 0,
            .tag = .transfer,
        }) catch unreachable;

        return inputs;
    }

    pub fn endTransferPass(
        self: *@This(),
        outputs: anytype,
    ) @TypeOf(outputs) {
        const command_count = self.commands.len - self.passes.items(.command_offset)[self.current_pass_index];

        self.passes.items(.command_count)[self.current_pass_index] = @intCast(command_count);

        return outputs;
    }

    ///Update the buffer with contents.
    ///Must be in a pass.
    ///Returns the modified buffer.
    pub fn updateBuffer(
        self: *@This(),
        buffer: Buffer,
        ///The offset into buffer from which contents are written
        buffer_offset: usize,
        comptime T: type,
        contents: []const T,
    ) void {
        const buffer_index = self.referenceBuffer(buffer);
        _ = buffer_index; // autofix

        self.commands.append(self.allocator, .{
            .tag = .update_buffer,
            .index = @intCast(self.update_buffer_commands.items.len),
        }) catch unreachable;

        self.update_buffer_commands.append(self.allocator, .{
            .buffer = buffer,
            .buffer_offset = buffer_offset,
            .contents = std.mem.sliceAsBytes(contents),
        }) catch unreachable;
    }

    pub fn beginRasterPass(
        self: *@This(),
        ///Uniquely identifies the pass
        comptime src: SourceLocation,
        ///The input dependencies for the pass
        inputs: anytype,
    ) @TypeOf(inputs) {
        const pass_id = comptime idFromSourceLocation(src);

        self.current_pass_index = @intCast(self.passes.len);

        self.passes.append(self.allocator, .{
            .handle = pass_id,
            .reference_count = 0,
            .command_offset = @intCast(self.commands.len),
            .command_count = 0,
            .tag = .transfer,
        }) catch unreachable;

        return inputs;
    }

    pub fn endRasterPass(
        self: *@This(),
        outputs: anytype,
    ) @TypeOf(outputs) {
        const command_count = self.commands.len - self.passes.items(.command_offset)[self.current_pass_index];

        self.passes.items(.command_count)[self.current_pass_index] = @intCast(command_count);

        return outputs;
    }

    pub fn setRasterPipeline(
        self: *@This(),
        pipeline: RasterPipeline,
    ) void {
        const pipeline_index = self.referenceRasterPipeline(pipeline);
        _ = pipeline_index; // autofix

        self.commands.append(self.allocator, .{
            .tag = .set_raster_pipeline,
            .index = @intCast(self.set_pipeline_commands.items.len),
        }) catch unreachable;

        self.set_pipeline_commands.append(self.allocator, .{
            .pipeline = pipeline,
        }) catch unreachable;
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
    ///TODO: better way to do this?
    double_buffer: [2]struct {
        graphics_command_buffer: ?graphics.CommandBuffer = null,
    } = .{ .{}, .{} },
    buffer_index: u32 = 0,

    //TODO: exploit SourceLocation to make a more efficient mapping
    raster_pipelines: std.AutoArrayHashMapUnmanaged(u64, graphics.GraphicsPipeline) = .{},

    pub fn init() CompileContext {
        return .{};
    }

    pub fn deinit(self: *@This(), allocator: std.mem.Allocator) void {
        for (self.raster_pipelines.values()) |*raster_pipeline| {
            raster_pipeline.deinit(allocator);
        }

        self.* = undefined;
    }

    ///Compiles a built graph to low level api commands
    pub fn compile(
        self: *@This(),
        builder: Builder,
        allocator: std.mem.Allocator,
    ) !CompileResult {
        defer {
            self.buffer_index = if (self.buffer_index != 0) 0 else 1;
        }

        const compile_buffer = &self.double_buffer[self.buffer_index];

        if (compile_buffer.graphics_command_buffer == null) {
            compile_buffer.graphics_command_buffer = try graphics.CommandBuffer.init(.graphics);
        }

        //Resource creation/fetching/destruction pass
        {
            const raster_pipeline_reference_counts = builder.raster_pipelines.items(.reference_count);

            for (raster_pipeline_reference_counts, 0..) |reference_count, pipeline_index| {
                if (reference_count == 0) {
                    //TODO: deallocate unreferenced pipelines if they have a backing store
                    continue;
                }

                const handle: RasterPipeline = builder.raster_pipelines.items(.handle)[pipeline_index];

                const get_or_put_res = try self.raster_pipelines.getOrPut(allocator, handle.id);

                //cache hit
                if (get_or_put_res.found_existing) {
                    std.log.info("raster pipline cache hit", .{});

                    continue;
                }

                const vertex_module: RasterModule = builder.raster_pipelines.items(.vertex_module)[pipeline_index];
                const fragment_module: RasterModule = builder.raster_pipelines.items(.fragment_module)[pipeline_index];
                const push_constant_size = builder.raster_pipelines.items(.push_constant_size)[pipeline_index];

                //otherwise create the pipeline
                get_or_put_res.value_ptr.* = try graphics.GraphicsPipeline.init(
                    allocator,
                    .{
                        .color_attachment_formats = &.{graphics.vulkan.Format.b8g8r8a8_srgb},
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
            }
        }

        //Final pass: Encode commands
        {
            try compile_buffer.graphics_command_buffer.?.begin();
            defer compile_buffer.graphics_command_buffer.?.end();
        }

        //TODO: follow data dependencies to 'find' execution

        return .{
            .graphics_command_buffer = &compile_buffer.graphics_command_buffer.?,
        };
    }

    pub const CompileResult = struct {
        ///Command buffer to be submitted to graphics queue
        graphics_command_buffer: *const graphics.CommandBuffer,
    };

    const graphics = @import("../graphics.zig");
};

///Encode and submit the command buffers
pub fn encodeAndSubmit() void {
    @compileError("Not yet implemented");
}

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
};

pub const ImageUntyped = struct {
    id: u64,
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
    };
}

pub const ImageFormat = enum(u8) {
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
