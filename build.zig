pub fn build(builder: *std.Build) !void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    const renderer_tri_vert_spv_module = GlslCompileStep.compileModule(builder, optimize, .vertex, builder.pathFromRoot("quanta/src/renderer_3d/tri.vert.glsl"), "tri.vert.spv");
    const renderer_tri_frag_spv_module = GlslCompileStep.compileModule(builder, optimize, .fragment, builder.pathFromRoot("quanta/src/renderer_3d/tri.frag.glsl"), "tri.frag.spv");
    const renderer_sky_vert_spv_module = GlslCompileStep.compileModule(builder, optimize, .vertex, builder.pathFromRoot("quanta/src/renderer_3d/sky.vert.glsl"), "sky.vert.spv");
    const renderer_sky_frag_spv_module = GlslCompileStep.compileModule(builder, optimize, .fragment, builder.pathFromRoot("quanta/src/renderer_3d/sky.frag.glsl"), "sky.frag.spv");
    const renderer_depth_vert_spv_module = GlslCompileStep.compileModule(builder, optimize, .vertex, builder.pathFromRoot("quanta/src/renderer_3d/depth.vert.glsl"), "depth.vert.spv");
    const renderer_depth_frag_spv_module = GlslCompileStep.compileModule(builder, optimize, .fragment, builder.pathFromRoot("quanta/src/renderer_3d/depth.frag.glsl"), "depth.frag.spv");
    const renderer_pre_depth_cull_comp_module = GlslCompileStep.compileModule(builder, optimize, .compute, builder.pathFromRoot("quanta/src/renderer_3d/pre_depth_cull.comp.glsl"), "pre_depth_cull.comp.spv");
    const renderer_post_depth_cull_comp_module = GlslCompileStep.compileModule(builder, optimize, .compute, builder.pathFromRoot("quanta/src/renderer_3d/post_depth_cull.comp.glsl"), "post_depth_cull.comp.spv");
    const renderer_depth_reduce_comp_module = GlslCompileStep.compileModule(builder, optimize, .compute, builder.pathFromRoot("quanta/src/renderer_3d/depth_reduce.comp.glsl"), "depth_reduce.comp.spv");
    const renderer_color_resolve_comp_module = GlslCompileStep.compileModule(builder, optimize, .compute, builder.pathFromRoot("quanta/src/renderer_3d/color_resolve.comp.glsl"), "color_resolve.comp.spv");

    const renderer_gui_rectangle_vert_module = GlslCompileStep.compileModule(builder, optimize, .vertex, builder.pathFromRoot("quanta/src/renderer_gui/rectangle.vert.glsl"), "rectangle.vert.spv");
    const renderer_gui_rectangle_frag_module = GlslCompileStep.compileModule(builder, optimize, .fragment, builder.pathFromRoot("quanta/src/renderer_gui/rectangle.frag.glsl"), "rectangle.frag.spv");
    const renderer_gui_mesh_vert_module = GlslCompileStep.compileModule(builder, optimize, .vertex, builder.pathFromRoot("quanta/src/renderer_gui/mesh.vert.glsl"), "mesh.vert.spv");
    const renderer_gui_mesh_frag_module = GlslCompileStep.compileModule(builder, optimize, .fragment, builder.pathFromRoot("quanta/src/renderer_gui/mesh.frag.glsl"), "mesh.frag.spv");

    const options = builder.addOptions();

    const quanta_module = builder.addModule("quanta", .{
        .root_source_file = .{ .path = builder.pathFromRoot("quanta/src/root.zig") },
        .imports = &.{
            .{ .name = "options", .module = options.createModule() },
            .{ .name = "zgltf", .module = builder.createModule(.{ .root_source_file = .{ .path = builder.pathFromRoot("quanta/lib/zgltf/src/main.zig") } }) },
            .{ .name = "zigimg", .module = builder.createModule(.{ .root_source_file = .{ .path = builder.pathFromRoot("quanta/lib/zigimg/zigimg.zig") } }) },
            .{ .name = "zalgebra", .module = builder.createModule(.{ .root_source_file = .{ .path = builder.pathFromRoot("quanta/lib/zalgebra/src/main.zig") } }) },
            .{ .name = "spvine", .module = builder.createModule(.{ .root_source_file = .{ .path = builder.pathFromRoot("quanta/lib/spvine/src/main.zig") } }) },
            .{ .name = "renderer_tri_vert.spv", .module = renderer_tri_vert_spv_module },
            .{ .name = "renderer_tri_frag.spv", .module = renderer_tri_frag_spv_module },
            .{ .name = "renderer_depth_vert.spv", .module = renderer_depth_vert_spv_module },
            .{ .name = "renderer_depth_frag.spv", .module = renderer_depth_frag_spv_module },
            .{ .name = "renderer_sky_vert.spv", .module = renderer_sky_vert_spv_module },
            .{ .name = "renderer_sky_frag.spv", .module = renderer_sky_frag_spv_module },
            .{ .name = "renderer_pre_depth_cull_comp.spv", .module = renderer_pre_depth_cull_comp_module },
            .{ .name = "renderer_post_depth_cull_comp.spv", .module = renderer_post_depth_cull_comp_module },
            .{ .name = "renderer_depth_reduce_comp.spv", .module = renderer_depth_reduce_comp_module },
            .{ .name = "renderer_color_resolve_comp.spv", .module = renderer_color_resolve_comp_module },
            .{ .name = "renderer_gui_rectangle_vert.spv", .module = renderer_gui_rectangle_vert_module },
            .{ .name = "renderer_gui_rectangle_frag.spv", .module = renderer_gui_rectangle_frag_module },
            .{ .name = "renderer_gui_mesh_vert.spv", .module = renderer_gui_mesh_vert_module },
            .{ .name = "renderer_gui_mesh_frag.spv", .module = renderer_gui_mesh_frag_module },
        },
        .link_libcpp = true,
        .link_libc = true,
        .target = target,
    });

    quanta_module.addImport("quanta", quanta_module);

    quanta_module.addIncludePath(.{ .path = builder.pathFromRoot("quanta/lib/cimgui/imgui/") });
    quanta_module.addIncludePath(.{ .path = builder.pathFromRoot("quanta/lib/ImGuizmo/") });
    quanta_module.addCSourceFiles(.{
        .files = &[_][]const u8{
            builder.pathFromRoot("quanta/lib/cimgui/imgui/imgui.cpp"),
            builder.pathFromRoot("quanta/lib/cimgui/imgui/imgui_draw.cpp"),
            builder.pathFromRoot("quanta/lib/cimgui/imgui/imgui_tables.cpp"),
            builder.pathFromRoot("quanta/lib/cimgui/imgui/imgui_widgets.cpp"),
            builder.pathFromRoot("quanta/lib/cimgui/imgui/imgui_demo.cpp"),
            builder.pathFromRoot("quanta/lib/cimgui/cimgui.cpp"),
            builder.pathFromRoot("quanta/lib/ImGuizmo/ImGuizmo.cpp"),
            builder.pathFromRoot("quanta/src/imgui/guizmo.cpp"),
        },
        .flags = &[_][]const u8{},
    });
    //TODO: dynamically load instead of linking
    quanta_module.linkSystemLibrary("xkbcommon", .{});
    quanta_module.linkSystemLibrary("xcb-xinput", .{});

    const include_tracy = builder.option(bool, "include_tracy", "Include and compile the tracy client into the application") orelse false;

    //example
    {
        const example_target = target;

        const exe = builder.addExecutable(.{
            .name = "example",
            .root_source_file = .{ .path = builder.pathFromRoot("example/src/main.zig") },
            .target = example_target,
            .optimize = optimize,
            .strip = optimize == .ReleaseFast or optimize == .ReleaseSmall,
        });

        builder.installArtifact(exe);

        exe.root_module.addImport("quanta", quanta_module);

        const compile_assets = addAssetCompileStepNoDep(
            builder,
            quanta_module,
            .{
                .source_directory = builder.pathFromRoot("example/src/assets/"),
                .install_directory = builder.pathFromRoot("zig-out/bin/"),
                .artifact_name = "example_assets_archive",
                .target = example_target,
                .optimize = optimize,
            },
        );

        if (include_tracy) {
            exe.addCSourceFile(.{
                .file = .{ .path = builder.pathFromRoot("quanta/lib/tracy/public/TracyClient.cpp") },
                .flags = &.{"-DTRACY_ENABLE"},
            });
        }

        const run_cmd = builder.addRunArtifact(exe);

        run_cmd.step.dependOn(builder.getInstallStep());
        run_cmd.step.dependOn(compile_assets.step);

        if (builder.args) |args| {
            run_cmd.addArgs(args);
        }

        run_cmd.cwd = .{ .path = builder.pathFromRoot("zig-out/bin/") };

        const run_step = builder.step("run_example", "Run the example application");
        run_step.dependOn(&run_cmd.step);

        const compile_assets_step = builder.step("compile_assets", "Compile the assets for example");

        compile_assets_step.dependOn(compile_assets.step);
    }

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
    quanta_dependency: std.Build.Dependency,
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

///Custom asset compile step for quanta-example
fn addAssetCompileStepNoDep(
    builder: *std.Build,
    quanta_module: *std.Build.Module,
    config: AssetCompileOptions,
) AssetCompileStep {
    const asset_compiler = builder.addExecutable(.{
        .name = "asset_compiler",
        .root_source_file = std.Build.LazyPath.relative("quanta/src/asset/compiler_main.zig"),
        .target = builder.host,
        .optimize = .Debug,
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
const GlslCompileStep = quanta.asset.build_steps.GlslCompileStep;
