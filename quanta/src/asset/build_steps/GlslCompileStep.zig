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
glsl_compiler: *std.Build.Step.Run,
builder: *std.Build,
input_path: []const u8,
output_path: []const u8,
shader_stage: ShaderStage,
optimize_mode: std.builtin.OptimizeMode,
generated_file: std.Build.GeneratedFile,

pub fn create(
    builder: *std.Build,
    quanta_dependency: *std.Build.Dependency,
    name: []const u8,
    input_path: []const u8,
    output_path: []const u8,
    shader_stage: ShaderStage,
    optimize_mode: std.builtin.OptimizeMode,
) *GlslCompileStep {
    const self = builder.allocator.create(GlslCompileStep) catch unreachable;

    const glsl_compiler = quanta_dependency.artifact("glsl_compiler");

    self.* = GlslCompileStep{
        .builder = builder,
        .glsl_compiler = builder.addRunArtifact(glsl_compiler),
        .step = std.Build.Step.init(.{ .id = base_id, .name = name, .owner = builder, .makeFn = &make }),
        .input_path = input_path,
        .output_path = output_path,
        .shader_stage = shader_stage,
        .optimize_mode = optimize_mode,
        .generated_file = .{ .step = &self.step, .path = null },
    };

    self.step.dependOn(&glsl_compiler.step);

    return self;
}

pub fn make(step: *Step, progress_node: *std.Progress.Node) !void {
    const self = step.cast(GlslCompileStep).?;

    var cache_manifest = self.builder.cache.obtain();
    defer cache_manifest.deinit();

    var args_list: std.ArrayListUnmanaged([]const u8) = .{};

    try args_list.append(self.builder.allocator, @tagName(self.optimize_mode));
    try args_list.append(self.builder.allocator, @tagName(self.shader_stage));
    try args_list.append(self.builder.allocator, self.input_path);

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

    for (args_list.items) |arg| {
        self.glsl_compiler.addArg(arg);
    }

    try self.glsl_compiler.step.makeFn(&self.glsl_compiler.step, progress_node);

    try cache_manifest.writeManifest();
}

pub fn compileModule(
    builder: *std.Build,
    quanta_dependency: *std.Build.Dependency,
    mode: std.builtin.OptimizeMode,
    stage: GlslCompileStep.ShaderStage,
    input: []const u8,
    output: []const u8,
) *std.Build.Module {
    const step = GlslCompileStep.create(builder, quanta_dependency, input, input, output, stage, mode);

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
