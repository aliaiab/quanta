const std = @import("std");

const GlslCompileStep = @This();
const Step = std.Build.Step;

pub const ShaderStage = enum
{
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
    ) *GlslCompileStep 
{
    const self = builder.allocator.create(GlslCompileStep) catch unreachable;

    self.* = GlslCompileStep
    {
        .builder = builder,
        .step = std.Build.Step.init(base_id, name, builder.allocator, make),
        .input_path = input_path,
        .output_path = output_path,
        .shader_stage = shader_stage,
        .optimize_mode = optimize_mode,
        .generated_file = .{ .step = &self.step, .path = null },
    };

    return self;
}

pub fn make(step: *Step) !void
{
    const self = step.cast(GlslCompileStep).?;

    var cache_manifest = self.builder.cache.obtain();
    defer cache_manifest.deinit();

    const shader_target = "vulkan1.2";

    const shader_optimisation = switch (self.optimize_mode)
    {
        .ReleaseFast => "-O0",
        .ReleaseSafe => "-O",
        .ReleaseSmall => "-Os",
        .Debug => "-O0",
    };

    const stage_string = switch (self.shader_stage)
    {
        .vertex => "vert",
        .fragment => "frag",
        .compute => "comp",
    };

    const stage_arg = try std.mem.join(self.builder.allocator, "", (&.{ "-fshader-stage=", stage_string }));

    var args = [_][]const u8 
    { 
        "glslc", 
        "-fauto-map-locations",
        "--target-env=" ++ shader_target, 
        stage_arg, 
        self.input_path, 
        "-Werror", 
        "-c", 
        shader_optimisation, 
        "-g",
        "-o", 
        self.output_path,
    };

    cache_manifest.hash.addListOfBytes(&args);
    const input_file_index = try cache_manifest.addFile(self.input_path, std.math.maxInt(u32));

    const found_existing = try cache_manifest.hit();

    if (found_existing)
    {
        const digest = cache_manifest.final();

        const cached_path = try self.builder.cache_root.join(self.builder.allocator, &.{
            "o/",
            &digest,
            self.output_path
        });  

        self.generated_file.path = cached_path;

        return;
    }

    const input_file: *std.Build.Cache.File = &cache_manifest.files.items[input_file_index];

    if (input_file.contents == null)
    {
        std.debug.print("input_file_index = {}\n", .{ input_file_index });

        const input_file_opened = try std.fs.cwd().openFile(self.input_path, .{});
        defer input_file_opened.close();

        input_file.contents = try input_file_opened.readToEndAlloc(self.builder.allocator, std.math.maxInt(usize));
    } 

    const includes = try getIncludes(self.builder.allocator, input_file.contents.?);

    const source_directory = std.fs.path.dirname(self.input_path).?;

    for (includes) |include|
    {
        const include_path = try std.fs.path.join(self.builder.allocator, &.{ source_directory, include });

        std.debug.print("include path: {s}\n", .{ include_path });

        try cache_manifest.addFilePost(include_path);
    }

    const digest = cache_manifest.final();

    const cached_path = try self.builder.cache_root.join(self.builder.allocator, &.{
        "o/",
        &digest,
        self.output_path
    });  

    std.fs.makeDirAbsolute(std.fs.path.dirname(cached_path).?) catch {};  

    self.generated_file.path = cached_path;

    args[10] = cached_path;

    std.debug.print("compiling {s}\n", .{ cached_path });

    try std.Build.RunStep.runCommand(
        &args,
        self.builder,
        null,
        .ignore,
        .inherit,
        .Ignore,
        self.builder.env_map,
        self.builder.build_root.path,
        true,
    );

    try cache_manifest.writeManifest();
}

pub fn compileModule(
    builder: *std.build.Builder, 
    mode: std.builtin.OptimizeMode, 
    stage: GlslCompileStep.ShaderStage, 
    input: []const u8, 
    output: []const u8,
) *std.build.Module 
{
    const step = GlslCompileStep.create(builder, input, input, output, stage, mode);

    return builder.createModule(.{
        .source_file = std.build.FileSource { .generated = &step.generated_file }
    });
}

pub fn getIncludes(
    allocator: std.mem.Allocator,
    source: []const u8,
) ![][]const u8
{
    var includes: std.ArrayListUnmanaged([]const u8) = .{};

    var state: enum {
        start,
        include_keyword,
        include_path,
    } = .start;

    var current_include_start: usize = 0;

    var i: usize = 0;

    while (i < source.len)
    {
        const char = source[i];

        switch (state)
        {
            .start => {
                switch (char)
                {
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
                switch (char)
                {
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
                switch (char)
                {
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