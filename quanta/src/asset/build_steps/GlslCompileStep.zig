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
        .step = std.Build.Step.init(.{
            .id = base_id,
            .name = std.mem.concat(
                builder.allocator,
                u8,
                &.{ "glsl compile ", name },
            ) catch @panic("oom"),
            .owner = builder,
            .makeFn = &make,
        }),
        .input_path = input_path,
        .output_path = output_path,
        .shader_stage = shader_stage,
        .optimize_mode = optimize_mode,
        .generated_file = .{ .step = &self.step, .path = null },
    };

    self.step.dependOn(&glsl_compiler.step);

    return self;
}

pub fn make(step: *Step, make_options: std.Build.Step.MakeOptions) anyerror!void {
    const self = step.cast(GlslCompileStep).?;

    var cache_manifest = self.builder.graph.cache.obtain();
    defer cache_manifest.deinit();

    var args_list: std.ArrayListUnmanaged([]const u8) = .{};

    try args_list.append(self.builder.allocator, @tagName(self.optimize_mode));
    try args_list.append(self.builder.allocator, @tagName(self.shader_stage));
    try args_list.append(self.builder.allocator, self.input_path);

    const output_path_arg_index = args_list.items.len;

    try args_list.append(self.builder.allocator, self.output_path);

    cache_manifest.hash.addListOfBytes(args_list.items);

    const input_file_index = try cache_manifest.addFile(self.input_path, std.math.maxInt(u32));
    _ = input_file_index; // autofix

    const found_existing = try step.cacheHit(&cache_manifest);

    if (found_existing) {
        const digest = cache_manifest.final();

        const cached_path = try self.builder.cache_root.join(self.builder.allocator, &.{ "o/", &digest, self.output_path });

        self.generated_file.path = cached_path;

        return;
    }

    const contents = try std.fs.cwd().readFileAlloc(self.builder.allocator, self.input_path, std.math.maxInt(usize));

    // const input_file: *std.Build.Cache.File = &cache_manifest;

    // if (input_file.contents == null) {
    // input_file.contents = try std.fs.cwd().readFileAlloc(self.builder.allocator, self.input_path, std.math.maxInt(usize));
    // }

    const source_directory = std.fs.path.dirname(self.input_path).?;

    const includes = try getIncludesRecursive(self.builder.allocator, source_directory, contents);

    for (includes) |include| {
        // const include_path = try std.fs.path.join(self.builder.allocator, &.{ source_directory, include });
        const include_path = include;

        cache_manifest.addFilePost(include_path) catch |e| {
            switch (e) {
                error.FileNotFound => {
                    const error_message = try std.fmt.allocPrint(
                        self.builder.allocator,
                        "Could not find include file \"{s}\"",
                        .{include_path},
                    );

                    self.step.result_error_msgs.append(self.builder.allocator, error_message) catch {};

                    return e;
                },
                else => return e,
            }
        };
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

    self.glsl_compiler.addCheck(.{ .expect_stderr_exact = "" });

    errdefer {
        //The build runner will assert fail if the length of this string is zero
        self.step.result_stderr = " ";

        const error_message = self.glsl_compiler.step.result_error_msgs.items[0];

        var info_log_lines = std.mem.tokenizeSequence(u8, error_message, &.{'\n'});

        while (info_log_lines.next()) |info_log_line| {
            const error_token: []const u8 = "error: ";

            if (std.mem.startsWith(u8, info_log_line, error_token)) {
                self.step.result_error_msgs.append(self.builder.allocator, info_log_line[error_token.len..]) catch {};
            }
        }
    }

    try self.glsl_compiler.step.makeFn(&self.glsl_compiler.step, make_options);

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
    _ = step; // autofix

    const glsl_compiler = quanta_dependency.artifact("glsl_compiler");

    const run_glsl_compiler = builder.addRunArtifact(glsl_compiler);

    run_glsl_compiler.addFileInput(.{ .cwd_relative = input });

    run_glsl_compiler.addArg(@tagName(mode));
    run_glsl_compiler.addArg(@tagName(stage));
    run_glsl_compiler.addArg(input);
    const output_path = run_glsl_compiler.addOutputFileArg(output);

    const resulting_step = &run_glsl_compiler.step;

    resulting_step.addWatchInput(.{ .cwd_relative = input }) catch @panic("oom");

    return builder.createModule(.{
        // .root_source_file = std.Build.LazyPath{ .generated = .{ .file = &resulting_step.generated_file } },
        .root_source_file = output_path,
    });
}

///Returns a linear list of all includes, including transitive ones
pub fn getIncludesRecursive(
    allocator: std.mem.Allocator,
    source_directory: []const u8,
    source: []const u8,
) ![][]const u8 {
    const includes_inital = try getIncludes(allocator, source);

    var includes: std.ArrayListUnmanaged([]const u8) = .{};

    for (includes_inital) |include| {
        const include_path = try std.fs.path.join(allocator, &.{ source_directory, include });

        try includes.append(allocator, include_path);
    }

    for (includes_inital) |include| {
        const directory = try std.fs.path.join(allocator, &.{
            source_directory,
            std.fs.path.dirname(include) orelse "",
        });
        defer allocator.free(directory);

        const include_path = try std.fs.path.join(allocator, &.{ source_directory, include });
        defer allocator.free(include_path);

        const include_contents = std.fs.cwd().readFileAlloc(allocator, include_path, std.math.maxInt(usize)) catch |e| {
            switch (e) {
                error.FileNotFound => {
                    std.log.info("include_path = {s}", .{include_path});

                    return e;
                },
                else => return e,
            }
        };

        const sub_includes = try getIncludesRecursive(allocator, directory, include_contents);

        try includes.appendSlice(allocator, sub_includes);
    }

    return includes.items;
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

const std = @import("std");
const log = std.log.scoped(.quanta_build);
const GlslCompileStep = @This();
const Step = std.Build.Step;
