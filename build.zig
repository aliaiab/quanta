pub fn build(builder: *std.Build) !void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    const glslang_module = builder.createModule(.{
        .link_libcpp = true,
    });

    glslang_module.addIncludePath(.{ .path = builder.pathFromRoot("quanta/lib/glslang/") });
    glslang_module.addCSourceFiles(.{
        .files = &[_][]const u8{
            //cinterface
            builder.pathFromRoot("quanta/lib/glslang/glslang/CInterface/glslang_c_interface.cpp"),

            //Codegen
            builder.pathFromRoot("quanta/lib/glslang/glslang/GenericCodeGen/Link.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/GenericCodeGen/CodeGen.cpp"),

            //Preprocessor
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/preprocessor/Pp.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/preprocessor/PpAtom.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/preprocessor/PpContext.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/preprocessor/PpScanner.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/preprocessor/PpTokens.cpp"),

            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/limits.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/linkValidate.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/parseConst.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/ParseContextBase.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/ParseHelper.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/PoolAlloc.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/reflection.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/RemoveTree.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/Scan.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/ShaderLang.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/SpirvIntrinsics.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/SymbolTable.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/Versions.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/Intermediate.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/Constant.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/attribute.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/glslang_tab.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/InfoSink.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/Initialize.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/intermOut.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/IntermTraverse.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/propagateNoContraction.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/MachineIndependent/iomapper.cpp"),

            //OsDependent
            builder.pathFromRoot("quanta/lib/glslang/glslang/OSDependent/Unix/ossource.cpp"),

            //I'm not sure what this does or why it's needed
            builder.pathFromRoot("quanta/lib/glslang/OGLCompilersDLL/InitializeDll.cpp"),

            builder.pathFromRoot("quanta/lib/glslang/glslang/ResourceLimits/resource_limits_c.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/glslang/ResourceLimits/ResourceLimits.cpp"),

            //SPIRV backend
            builder.pathFromRoot("quanta/lib/glslang/SPIRV/CInterface/spirv_c_interface.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/SPIRV/GlslangToSpv.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/SPIRV/SpvPostProcess.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/SPIRV/SPVRemapper.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/SPIRV/SpvTools.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/SPIRV/SpvBuilder.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/SPIRV/Logger.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/SPIRV/InReadableOrder.cpp"),
            builder.pathFromRoot("quanta/lib/glslang/SPIRV/doc.cpp"),
        },
        .flags = &[_][]const u8{},
    });

    const glsl_compiler = builder.addExecutable(.{
        .name = "glsl_compiler",
        .root_source_file = std.Build.LazyPath.relative("quanta/src/asset/build_steps/glsl_compiler.zig"),
        .target = builder.host,
        .optimize = .Debug,
    });

    glsl_compiler.addIncludePath(.{ .path = builder.pathFromRoot("quanta/lib/glslang/") });
    glsl_compiler.root_module.addImport("glslang", glslang_module);

    builder.install_tls.step.dependOn(&builder.addInstallArtifact(glsl_compiler, .{}).step);

    const glsl_compiler_step = builder.step("glsl_compiler", "Run the glsl_compiler standalone (temporary option for testing)");

    const run_glsl_compiler = builder.addRunArtifact(glsl_compiler);

    glsl_compiler_step.dependOn(&run_glsl_compiler.step);

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

    const options = builder.addOptions();

    const quanta_module = builder.addModule("quanta", .{
        .root_source_file = .{ .path = builder.pathFromRoot("quanta/src/root.zig") },
        .imports = &.{
            .{ .name = "options", .module = options.createModule() },
            .{ .name = "zgltf", .module = builder.createModule(.{ .root_source_file = .{ .path = builder.pathFromRoot("quanta/lib/zgltf/src/main.zig") } }) },
            .{ .name = "zigimg", .module = builder.createModule(.{ .root_source_file = .{ .path = builder.pathFromRoot("quanta/lib/zigimg/zigimg.zig") } }) },
            .{ .name = "zalgebra", .module = builder.createModule(.{ .root_source_file = .{ .path = builder.pathFromRoot("quanta/lib/zalgebra/src/main.zig") } }) },
            .{ .name = "spvine", .module = builder.createModule(.{ .root_source_file = .{ .path = builder.pathFromRoot("quanta/lib/spvine/src/main.zig") } }) },
        },
        .link_libc = true,
        .target = target,
    });

    quanta_module.addImport("quanta", quanta_module);

    for (glsl_compile_step.embed_modules.?) |spv_module| {
        quanta_module.addImport(spv_module.import_name, spv_module.module);
    }

    //TODO: dynamically load instead of linking
    quanta_module.linkSystemLibrary("xkbcommon", .{});
    quanta_module.linkSystemLibrary("xcb-xinput", .{});

    //tests
    {
        const test_step = builder.step("test", "Run the tests");

        const quanta_test = builder.addTest(.{
            .name = "test",
            .root_source_file = std.Build.LazyPath.relative("quanta/src/root.zig"),
            .optimize = .Debug,
        });

        const run_quanta_tests = builder.addRunArtifact(quanta_test);

        test_step.dependOn(&run_quanta_tests.step);
    }
}

pub const GlslCompileStep = quanta.asset.build_steps.GlslCompileStep;

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

    const root_zon = zon.parse.parse(ShadersRootZon, builder.allocator, root_zon_data) catch @panic("");
    defer zon.parse.parseFree(ShadersRootZon, builder.allocator, root_zon);

    const source_directory = std.fs.path.dirname(options.source_directory).?;

    var embed_modules: std.ArrayListUnmanaged(GlslCompileStepResult.EmbedModule) = .{};

    for (root_zon.paths) |path| {
        const actual_path = std.fs.path.join(builder.allocator, &.{ source_directory, path }) catch @panic("oom");

        const path_stem = std.fs.path.stem(actual_path);
        //eg: comp
        const stage_path_extension = std.fs.path.extension(path_stem);

        const string_to_stage = std.ComptimeStringMap(GlslCompileStep.ShaderStage, .{
            .{ ".vert", .vertex },
            .{ ".frag", .fragment },
            .{ ".comp", .compute },
        });

        const base_name = std.fs.path.basename(actual_path);

        const spv_name = std.fs.path.stem(base_name);

        const spv_path = std.mem.concat(builder.allocator, u8, &.{ spv_name, ".spv" }) catch @panic("oom");

        const spv_module = GlslCompileStep.compileModule(
            builder,
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
    ///The directory containing source assets
    source_directory: []const u8,
    ///The directory to install the compiled archives
    install_directory: []const u8,
    ///The name of the compiled archive
    artifact_name: []const u8,
    ///The target platform that the assets will be built for
    target: ?std.Build.ResolvedTarget = null,
    ///The optimization level that the assets will be built with
    optimize: ?std.builtin.OptimizeMode = null,
};

const AssetCompileStep = struct {
    step: *std.Build.Step,
    run_step: *std.Build.Step.Run,
};

pub fn addAssetCompileStep(
    builder: *std.Build,
    quanta_dependency: *std.Build.Dependency,
    config: AssetCompileOptions,
) AssetCompileStep {
    const quanta_module = quanta_dependency.module("quanta");

    //TODO: allow user to override asset compiler
    const asset_compiler = builder.addExecutable(.{
        .name = "asset_compiler",
        .root_source_file = quanta_dependency.path("quanta/src/asset/compiler_main.zig"),
        .target = builder.host,
        .optimize = .ReleaseSafe,
    });

    asset_compiler.root_module.addImport("quanta", quanta_module);

    const run_asset_compiler = builder.addRunArtifact(asset_compiler);

    const optimize = if (config.optimize) |opt| opt else .Debug;
    const target = if (config.target) |targ| targ else builder.host;
    _ = target; // autofix

    run_asset_compiler.addArg(@tagName(optimize));

    run_asset_compiler.addArg(config.source_directory);
    run_asset_compiler.addArg(config.install_directory);
    run_asset_compiler.addArg(config.artifact_name);

    return .{
        .step = &run_asset_compiler.step,
        .run_step = run_asset_compiler,
    };
}

const std = @import("std");
const builtin = @import("builtin");
const quanta = @import("quanta/src/root.zig");
const zon = quanta.zon;
