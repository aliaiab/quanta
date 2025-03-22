pub fn build(builder: *std.Build) !void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    const vk_gen = builder.dependency("vulkan_zig", .{}).artifact("vulkan-zig-generator");
    const vk_generate_cmd = builder.addRunArtifact(vk_gen);

    const registry = builder.dependency("vulkan_headers", .{}).path("registry/vk.xml");

    vk_generate_cmd.addFileArg(registry);

    const glslang_zig = builder.dependency("glslang_zig", .{});

    const glsl_compiler = builder.addExecutable(.{
        .name = "glsl_compiler",
        .root_source_file = builder.path("quanta/src/asset/build_steps/glsl_compiler.zig"),
        .target = builder.graph.host,
        .optimize = .Debug,
        .sanitize_thread = true,
    });

    glsl_compiler.addIncludePath(builder.path(""));
    glsl_compiler.root_module.addImport("glslang", glslang_zig.module("glslang-zig"));
    glsl_compiler.root_module.addImport("glslang_c", glslang_zig.module("c_interface"));

    const install_glsl_compiler = builder.addInstallArtifact(glsl_compiler, .{});

    builder.install_tls.step.dependOn(&install_glsl_compiler.step);

    var self_dependency: std.Build.Dependency = .{
        .builder = builder,
    };

    const glsl_compile_step = addGlslCompileStep(
        builder,
        &self_dependency,
        .{
            .source_directory = builder.pathFromRoot("quanta/src/renderer_3d/shaders.zon"),
            .optimize = optimize,
        },
    );

    glsl_compile_step.step.dependOn(&install_glsl_compiler.step);

    const options = builder.addOptions();

    const quanta_module = builder.addModule("quanta", .{
        .root_source_file = builder.path("quanta/src/root.zig"),
        .imports = &.{
            .{ .name = "options", .module = options.createModule() },
            .{ .name = "zgltf", .module = builder.dependency("zgltf", .{}).module("zgltf") },
            .{ .name = "spvine", .module = builder.dependency("spvine", .{}).module("spvine") },
            .{ .name = "zigimg", .module = builder.dependency("zigimg", .{}).module("zigimg") },
        },
        .target = target,
        //We currently depend on libc to load vulkan/xcb/xkb and to free various pieces of memory passed from these apis
        .link_libc = true,
    });

    const vk_zig_file = vk_generate_cmd.addOutputFileArg("vk.zig");

    quanta_module.addAnonymousImport("vulkan", .{
        .root_source_file = vk_zig_file,
    });

    quanta_module.addImport("quanta", quanta_module);

    for (glsl_compile_step.embed_modules.?) |spv_module| {
        quanta_module.addImport(spv_module.import_name, spv_module.module);
    }

    switch (target.result.os.tag) {
        .linux,
        .openbsd,
        .freebsd,
        => {},
        .windows => {
            const maybe_zigwin32 = builder.lazyDependency("zigwin32", .{});

            if (maybe_zigwin32) |zigwin32| {
                quanta_module.addAnonymousImport("win32", .{
                    .root_source_file = zigwin32.path("win32.zig"),
                });
            }
        },
        else => {
            return error.OsPlatformNotSupported;
        },
    }

    //TODO: allow user to override asset compiler
    const asset_compiler = builder.addExecutable(.{
        .name = "asset_compiler",
        .root_source_file = builder.path("quanta/src/asset/compiler_main.zig"),
        .target = builder.graph.host,
        .optimize = .Debug,
    });

    asset_compiler.root_module.addImport("quanta", quanta_module);

    builder.install_tls.step.dependOn(&builder.addInstallArtifact(asset_compiler, .{}).step);

    //tests
    {
        const test_step = builder.step("test", "Run the tests");

        const quanta_test = builder.addTest(.{
            .name = "test",
            .root_source_file = builder.path("quanta/src/root.zig"),
            .optimize = .Debug,
            .link_libc = true,
        });

        quanta_test.root_module.addAnonymousImport("vulkan", .{
            .root_source_file = vk_zig_file,
        });

        const run_quanta_tests = builder.addRunArtifact(quanta_test);

        test_step.dependOn(&run_quanta_tests.step);
    }
}

pub const GlslCompileOptions = struct {
    ///The directory containing source glsl files
    source_directory: []const u8,
    ///The directory to install the compiled spirv files
    install_directory: ?[]const u8 = null,
    ///The target platform that the glsl files will be built for
    target: ?std.Build.ResolvedTarget = null,
    ///The optimization level that the glsl files will be built with
    optimize: ?std.builtin.OptimizeMode = null,
};

const GlslCompileStepResult = struct {
    step: *std.Build.Step,
    run_step: *std.Build.Step.Run,
    ///Root module containing embedded compiled files (uses @embedFile)
    ///Import this into your zig module to access compiled glsl files at compile time
    embed_modules: ?[]EmbedModule = null,

    pub const EmbedModule = struct {
        import_name: []const u8,
        module: *std.Build.Module,
    };

    pub fn addImportToModule(self: GlslCompileStepResult, module: *std.Build.Module) void {
        for (self.embed_modules.?) |spv_module| {
            module.addImport(spv_module.import_name, spv_module.module);
        }
    }
};

///TODO: integrate glsl and embedding assets into executables into the asset compiler
pub fn addGlslCompileStep(
    builder: *std.Build,
    quanta_dependency: *std.Build.Dependency,
    options: GlslCompileOptions,
) GlslCompileStepResult {
    const compiler = quanta_dependency.artifact("glsl_compiler");

    const run_step = builder.addRunArtifact(compiler);

    const ShadersRootZon = struct {
        paths: []const []const u8,
    };

    const root_zon_data = std.fs.cwd().readFileAllocOptions(
        builder.allocator,
        options.source_directory,
        std.math.maxInt(usize),
        null,
        1,
        0,
    ) catch @panic("oom");
    defer builder.allocator.free(root_zon_data);

    const root_zon = std.zon.parse.fromSlice(ShadersRootZon, builder.allocator, root_zon_data, null, .{}) catch @panic("");
    defer std.zon.parse.free(builder.allocator, root_zon);

    const source_directory = std.fs.path.dirname(options.source_directory).?;

    var embed_modules: std.ArrayListUnmanaged(GlslCompileStepResult.EmbedModule) = .{};

    for (root_zon.paths) |path| {
        const actual_path = std.fs.path.join(builder.allocator, &.{ source_directory, path }) catch @panic("oom");

        const path_stem = std.fs.path.stem(actual_path);
        //eg: comp
        const stage_path_extension = std.fs.path.extension(path_stem);

        const GlslCompileStep = quanta.asset.build_steps.GlslCompileStep;

        const string_to_stage = std.StaticStringMap(GlslCompileStep.ShaderStage).initComptime(.{
            .{ ".vert", .vertex },
            .{ ".frag", .fragment },
            .{ ".comp", .compute },
        });

        const base_name = std.fs.path.basename(actual_path);

        const spv_name = std.fs.path.stem(base_name);

        const spv_path = std.mem.concat(builder.allocator, u8, &.{ spv_name, ".spv" }) catch @panic("oom");

        const spv_module = GlslCompileStep.compileModule(
            builder,
            quanta_dependency,
            options.optimize orelse .Debug,
            string_to_stage.get(stage_path_extension).?,
            actual_path,
            spv_path,
        );

        embed_modules.append(builder.allocator, .{
            .module = spv_module,
            .import_name = spv_path,
        }) catch @panic("oom");
    }

    return .{
        .step = &run_step.step,
        .run_step = run_step,
        .embed_modules = embed_modules.items,
    };
}

pub const AssetCompileOptions = struct {
    ///The directory containing source assets, cwd relative.
    source_directory: []const u8,
    ///The directory to install the compiled archives
    ///Defaults to the builder.install_path
    install_directory: ?[]const u8 = null,
    ///The sub path within the install directory to put compiled archives
    install_sub_directory: []const u8 = "bin/",
    ///The name of the compiled archive
    artifact_name: []const u8,
    ///The target platform that the assets will be built for
    target: ?std.Build.ResolvedTarget = null,
    ///The optimization level that the assets will be built with
    ///This level can be overiden at the sub directory and asset level in metadata files
    optimize: ?std.builtin.OptimizeMode = null,
    ///The compression level that the assets will be built with
    ///This level can be overiden at the sub directory and asset level in metadata files
    ///Defaults to:
    /// none in OptimizeMode.Debug,
    /// small in OptimizeMode.ReleaseSmall,
    /// fast in OptimizeMode.ReleaseSafe and OptimizeMode.ReleaseFast
    compression: ?quanta.asset.compiler.CompressionMode = null,
    ///Strip debug information and content hashes from the compiled archive
    ///Defaults to true in Optimize.ReleaseFast and Optimize.ReleaseSafe
    strip: ?bool = null,
};

const AssetCompileStep = struct {
    step: *std.Build.Step,
    run_step: *std.Build.Step.Run,
};

///Adds the asset module for compilation
///Use the returned run step to actually run the compiler
pub fn addAssetCompileStep(
    builder: *std.Build,
    quanta_dependency: *std.Build.Dependency,
    config: AssetCompileOptions,
) AssetCompileStep {
    const asset_compiler = quanta_dependency.artifact("asset_compiler");

    const run_asset_compiler = builder.addRunArtifact(asset_compiler);

    const optimize = if (config.optimize) |opt| opt else .Debug;
    const target = if (config.target) |targ| targ else builder.graph.host;
    _ = target; // autofix

    std.log.info("config.source_dir = {s}", .{config.source_directory});

    run_asset_compiler.addArg(@tagName(optimize));
    run_asset_compiler.addDirectoryArg(.{ .cwd_relative = config.source_directory });
    run_asset_compiler.addArg(builder.pathJoin(&.{
        config.install_directory orelse builder.install_path,
        config.install_sub_directory,
    }));
    run_asset_compiler.addArg(config.artifact_name);

    _ = run_asset_compiler.step.addDirectoryWatchInput(.{ .cwd_relative = config.source_directory }) catch @panic("Failed to watch asset source dir");

    var asset_directory = std.fs.cwd().openDir(config.source_directory, .{
        .iterate = true,
    }) catch @panic("Cannot find asset root directory");
    defer asset_directory.close();

    addAssetDirectoryAsInput(
        builder,
        run_asset_compiler,
        asset_directory,
        config.source_directory,
    );

    return .{
        .step = &run_asset_compiler.step,
        .run_step = run_asset_compiler,
    };
}

///Recurses the asset directory to add all directories as watch inputs. This probably innefficient
fn addAssetDirectoryAsInput(
    builder: *std.Build,
    run: *std.Build.Step.Run,
    directory: std.fs.Dir,
    directory_path: []const u8,
) void {
    var iter = directory.iterate();

    while (iter.next() catch @panic("Cannot iterate asset source directory")) |entry| {
        switch (entry.kind) {
            .file => {
                std.log.info("Adding file input '{s}'", .{builder.pathJoin(&.{ directory_path, entry.name })});

                run.addFileInput(.{ .cwd_relative = builder.pathJoin(&.{ directory_path, entry.name }) });
            },
            .directory => {
                var asset_directory = std.fs.cwd().openDir(builder.pathJoin(&.{ directory_path, entry.name }), .{
                    .iterate = true,
                }) catch @panic("Cannot find asset root directory");
                defer asset_directory.close();

                addAssetDirectoryAsInput(
                    builder,
                    run,
                    asset_directory,
                    entry.name,
                );
            },
            else => {},
        }
    }
}

const std = @import("std");
const builtin = @import("builtin");
const quanta = @import("quanta/src/root.zig");
