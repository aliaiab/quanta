const std = @import("std");

const GlslCompileStep = @This();
const Step = std.Build.Step;

pub const ShaderStage = enum {
    vertex,
    fragment,
    compute,
};

pub const base_id: Step.Id = .custom;

step: Step,
builder: *std.Build,
input_path: []const u8,
output_path: []const u8,
shader_stage: ShaderStage,
optimize_mode: std.builtin.OptimizeMode,
generated_file: std.Build.GeneratedFile,

pub fn create(
    builder: *std.Build,
    name: []const u8,
    input_path: []const u8,
    output_path: []const u8,
    shader_stage: ShaderStage,
    optimize_mode: std.builtin.OptimizeMode,
) *GlslCompileStep {
    const self = builder.allocator.create(GlslCompileStep) catch unreachable;

    self.* = GlslCompileStep{
        .builder = builder,
        .step = std.Build.Step.init(.{ .id = base_id, .name = name, .owner = builder, .makeFn = &make }),
        .input_path = input_path,
        .output_path = output_path,
        .shader_stage = shader_stage,
        .optimize_mode = optimize_mode,
        .generated_file = .{ .step = &self.step, .path = null },
    };

    return self;
}

pub fn make(step: *Step, _: *std.Progress.Node) !void {
    const self = step.cast(GlslCompileStep).?;

    var cache_manifest = self.builder.cache.obtain();
    defer cache_manifest.deinit();

    const shader_target = "vulkan1.2";

    const shader_optimisation = switch (self.optimize_mode) {
        .ReleaseFast => "-O",
        .ReleaseSafe => "-O",
        .ReleaseSmall => "-Os",
        .Debug => "-O0",
    };

    const stage_string = switch (self.shader_stage) {
        .vertex => "vert",
        .fragment => "frag",
        .compute => "comp",
    };

    const stage_arg = try std.mem.join(self.builder.allocator, "", (&.{ "-fshader-stage=", stage_string }));

    var args_list: std.ArrayListUnmanaged([]const u8) = .{};

    try args_list.append(self.builder.allocator, "glslc");
    try args_list.append(self.builder.allocator, "-fauto-map-locations");
    try args_list.append(self.builder.allocator, "--target-env=" ++ shader_target);
    try args_list.append(self.builder.allocator, stage_arg);
    try args_list.append(self.builder.allocator, self.input_path);
    try args_list.append(self.builder.allocator, "-Werror");
    try args_list.append(self.builder.allocator, "-c");

    try args_list.append(self.builder.allocator, shader_optimisation);

    if (self.optimize_mode == .Debug) {
        try args_list.append(self.builder.allocator, "-g");
    }

    try args_list.append(self.builder.allocator, "-fpreserve-bindings");
    try args_list.append(self.builder.allocator, "-o");
    const output_path_arg_index = args_list.items.len;
    try args_list.append(self.builder.allocator, self.output_path);

    cache_manifest.hash.addListOfBytes(args_list.items);
    const input_file_index = try cache_manifest.addFile(self.input_path, std.math.maxInt(u32));

    const found_existing = try step.cacheHit(&cache_manifest);

    if (found_existing) {
        const digest = cache_manifest.final();

        const cached_path = try self.builder.cache_root.join(self.builder.allocator, &.{ "o/", &digest, self.output_path });

        self.generated_file.path = cached_path;

        return;
    }

    const input_file: *std.Build.Cache.File = &cache_manifest.files.items[input_file_index];

    if (input_file.contents == null) {
        const input_file_opened = try std.fs.cwd().openFile(self.input_path, .{});
        defer input_file_opened.close();

        input_file.contents = try input_file_opened.readToEndAlloc(self.builder.allocator, std.math.maxInt(usize));
    }

    const includes = try getIncludes(self.builder.allocator, input_file.contents.?);

    const source_directory = std.fs.path.dirname(self.input_path).?;

    for (includes) |include| {
        const include_path = try std.fs.path.join(self.builder.allocator, &.{ source_directory, include });

        try cache_manifest.addFilePost(include_path);
    }

    const digest = cache_manifest.final();

    const cached_path = try self.builder.cache_root.join(self.builder.allocator, &.{ "o/", &digest, self.output_path });

    std.fs.makeDirAbsolute(std.fs.path.dirname(cached_path).?) catch {};

    self.generated_file.path = cached_path;

    args_list.items[output_path_arg_index] = cached_path;

    errdefer {
        self.generated_file.path = null;
    }

    const result = try std.process.Child.run(.{
        .allocator = step.owner.allocator,
        .argv = args_list.items,
    });

    switch (result.term) {
        .Exited => |code| {
            if (code != 0) {
                return step.fail("Failed to compile: {s}", .{result.stderr});
            }
        },
        .Signal => {},
        .Stopped => {},
        .Unknown => {},
    }

    try cache_manifest.writeManifest();
}

pub fn compileModule(
    builder: *std.Build,
    mode: std.builtin.OptimizeMode,
    stage: GlslCompileStep.ShaderStage,
    input: []const u8,
    output: []const u8,
) *std.Build.Module {
    const step = GlslCompileStep.create(builder, input, input, output, stage, mode);

    return builder.createModule(.{ .root_source_file = std.Build.LazyPath{ .generated = &step.generated_file } });
}

pub fn getIncludes(
    allocator: std.mem.Allocator,
    source: []const u8,
) ![][]const u8 {
    var includes: std.ArrayListUnmanaged([]const u8) = .{};

    var state: enum {
        start,
        include_keyword,
        include_path,
    } = .start;

    var current_include_start: usize = 0;

    var i: usize = 0;

    while (i < source.len) {
        const char = source[i];

        switch (state) {
            .start => {
                switch (char) {
                    '#' => {
                        state = .include_keyword;

                        i += 1;
                    },
                    else => {
                        i += 1;
                    },
                }
            },
            .include_keyword => {
                switch (char) {
                    '<', '"' => {
                        state = .include_path;

                        i += 1;

                        current_include_start = i;
                    },
                    '\n' => {
                        state = .start;

                        i += 1;
                    },
                    else => {
                        i += 1;
                    },
                }
            },
            .include_path => {
                switch (char) {
                    '>', '"' => {
                        state = .start;

                        try includes.append(allocator, source[current_include_start..i]);

                        i += 1;
                    },
                    else => {
                        i += 1;
                    },
                }
            },
        }
    }

    return includes.items;
}
