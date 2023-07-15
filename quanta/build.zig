const std = @import("std");
const GlslCompileStep = @import("src/asset/build_steps/GlslCompileStep.zig");
const glfw = @import("lib/mach-glfw/build.zig");
const zgltf = @import("lib/zgltf/build.zig");

pub fn build(builder: *std.Build) !void {
    _ = builder;
}

pub fn addTest(builder: *std.Build) !*std.Build.CompileStep {
    return builder.addTest(.{
        .name = "test",
        .root_source_file = std.build.FileSource.relative("quanta/src/main.zig"),
        .optimize = .Debug,
    });
}

pub const Context = struct {
    builder: *std.Build,
    module: *std.Build.Module,

    glslc: *std.Build.CompileStep,
    asset_compiler: *std.Build.CompileStep,
    run_asset_compiler: *std.build.Step.Run,

    pub fn init(
        builder: *std.Build,
        target: std.zig.CrossTarget,
        mode: std.builtin.OptimizeMode,
        relative_path: []const u8,
    ) !Context {
        const renderer_tri_vert_spv_module = GlslCompileStep.compileModule(builder, mode, .vertex, builder.pathJoin(&.{ relative_path, "quanta/src/renderer/tri.vert.glsl" }), "tri.vert.spv");
        const renderer_tri_frag_spv_module = GlslCompileStep.compileModule(builder, mode, .fragment, builder.pathJoin(&.{ relative_path, "quanta/src/renderer/tri.frag.glsl" }), "tri.frag.spv");
        const renderer_sky_vert_spv_module = GlslCompileStep.compileModule(builder, mode, .vertex, builder.pathJoin(&.{ relative_path, "quanta/src/renderer/sky.vert.glsl" }), "sky.vert.spv");
        const renderer_sky_frag_spv_module = GlslCompileStep.compileModule(builder, mode, .fragment, builder.pathJoin(&.{ relative_path, "quanta/src/renderer/sky.frag.glsl" }), "sky.frag.spv");
        const renderer_depth_vert_spv_module = GlslCompileStep.compileModule(builder, mode, .vertex, builder.pathJoin(&.{ relative_path, "quanta/src/renderer/depth.vert.glsl" }), "depth.vert.spv");
        const renderer_depth_frag_spv_module = GlslCompileStep.compileModule(builder, mode, .fragment, builder.pathJoin(&.{ relative_path, "quanta/src/renderer/depth.frag.glsl" }), "depth.frag.spv");
        const renderer_pre_depth_cull_comp_module = GlslCompileStep.compileModule(builder, mode, .compute, builder.pathJoin(&.{ relative_path, "quanta/src/renderer/pre_depth_cull.comp.glsl" }), "pre_depth_cull.comp.spv");
        const renderer_post_depth_cull_comp_module = GlslCompileStep.compileModule(builder, mode, .compute, builder.pathJoin(&.{ relative_path, "quanta/src/renderer/post_depth_cull.comp.glsl" }), "post_depth_cull.comp.spv");
        const renderer_depth_reduce_comp_module = GlslCompileStep.compileModule(builder, mode, .compute, builder.pathJoin(&.{ relative_path, "quanta/src/renderer/depth_reduce.comp.glsl" }), "depth_reduce.comp.spv");
        const renderer_color_resolve_comp_module = GlslCompileStep.compileModule(builder, mode, .compute, builder.pathJoin(&.{ relative_path, "quanta/src/renderer/color_resolve.comp.glsl" }), "color_resolve.comp.spv");

        const renderer_gui_rectangle_vert_module = GlslCompileStep.compileModule(builder, mode, .vertex, builder.pathJoin(&.{ relative_path, "quanta/src/renderer_gui/rectangle.vert.glsl" }), "rectangle.vert.spv");
        const renderer_gui_rectangle_frag_module = GlslCompileStep.compileModule(builder, mode, .fragment, builder.pathJoin(&.{ relative_path, "quanta/src/renderer_gui/rectangle.frag.glsl" }), "rectangle.frag.spv");
        const renderer_gui_mesh_vert_module = GlslCompileStep.compileModule(builder, mode, .vertex, builder.pathJoin(&.{ relative_path, "quanta/src/renderer_gui/mesh.vert.glsl" }), "mesh.vert.spv");
        const renderer_gui_mesh_frag_module = GlslCompileStep.compileModule(builder, mode, .fragment, builder.pathJoin(&.{ relative_path, "quanta/src/renderer_gui/mesh.frag.glsl" }), "mesh.frag.spv");

        const options = builder.addOptions();

        var module = builder.createModule(.{
            .source_file = std.build.FileSource.relative(builder.pathJoin(&.{ relative_path, "quanta/src/main.zig" })),
            .dependencies = &.{
                .{ .name = "options", .module = options.createModule() },
                .{ .name = "glfw", .module = glfw.module(builder) },
                .{ .name = "zgltf", .module = builder.createModule(.{ .source_file = std.build.FileSource.relative(builder.pathJoin(&.{ relative_path, "quanta/lib/zgltf/src/main.zig" })) }) },
                .{ .name = "zigimg", .module = builder.createModule(.{ .source_file = std.build.FileSource.relative(builder.pathJoin(&.{ relative_path, "quanta/lib/zigimg/zigimg.zig" })) }) },
                .{ .name = "zalgebra", .module = builder.createModule(.{ .source_file = std.build.FileSource.relative(builder.pathJoin(&.{ relative_path, "quanta/lib/zalgebra/src/main.zig" })) }) },
                .{ .name = "spvine", .module = builder.createModule(.{ .source_file = std.build.FileSource.relative(builder.pathJoin(&.{ relative_path, "quanta/lib/spvine/src/main.zig" })) }) },
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
        });

        const asset_compiler = builder.addExecutable(.{
            .name = "asset_compiler",
            .root_source_file = std.build.FileSource.relative("quanta/src/asset/compiler.zig"),
            .target = std.zig.CrossTarget.fromTarget(builder.host.target),
            .optimize = mode,
        });

        asset_compiler.main_pkg_path = "quanta/src/";

        asset_compiler.addModule("zon", builder.createModule(.{
            .source_file = std.build.FileSource.relative(builder.pathJoin(&.{ relative_path, "quanta/src/zon.zig" })),
        }));

        asset_compiler.addAnonymousModule("zgltf", .{
            .source_file = std.build.FileSource.relative(builder.pathJoin(&.{ relative_path, "quanta/lib/zgltf/src/main.zig" })),
        });

        asset_compiler.addAnonymousModule("zigimg", .{
            .source_file = std.build.FileSource.relative(builder.pathJoin(&.{ relative_path, "quanta/lib/zigimg/zigimg.zig" })),
        });

        try link(builder, asset_compiler, "");

        if (true) return Context{
            .builder = builder,
            .module = module,
            .glslc = undefined,
            .asset_compiler = asset_compiler,
            .run_asset_compiler = builder.addRunArtifact(asset_compiler),
        };

        const glslang = builder.addStaticLibrary(.{
            .name = "glslang",
            .target = target,
            .optimize = mode,
        });

        glslang.addCSourceFiles(&[_][]const u8{
            "quanta/lib/glslang/glslang/MachineIndependent/glslang_tab.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/attribute.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/Constant.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/iomapper.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/InfoSink.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/Initialize.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/IntermTraverse.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/Intermediate.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/ParseContextBase.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/ParseHelper.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/PoolAlloc.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/RemoveTree.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/Scan.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/ShaderLang.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/SpirvIntrinsics.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/SymbolTable.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/Versions.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/intermOut.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/limits.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/linkValidate.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/parseConst.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/reflection.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/preprocessor/Pp.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/preprocessor/PpAtom.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/preprocessor/PpContext.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/preprocessor/PpScanner.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/preprocessor/PpTokens.cpp",
            "quanta/lib/glslang/glslang/MachineIndependent/propagateNoContraction.cpp",
            "quanta/lib/glslang/glslang/HLSL/hlslAttributes.cpp",
            "quanta/lib/glslang/glslang/HLSL/hlslParseHelper.cpp",
            "quanta/lib/glslang/glslang/HLSL/hlslScanContext.cpp",
            "quanta/lib/glslang/glslang/HLSL/hlslOpMap.cpp",
            "quanta/lib/glslang/glslang/HLSL/hlslTokenStream.cpp",
            "quanta/lib/glslang/glslang/HLSL/hlslGrammar.cpp",
            "quanta/lib/glslang/glslang/HLSL/hlslParseables.cpp",
            "quanta/lib/glslang/SPIRV/GlslangToSpv.cpp",
            "quanta/lib/glslang/SPIRV/InReadableOrder.cpp",
            "quanta/lib/glslang/SPIRV/Logger.cpp",
            "quanta/lib/glslang/SPIRV/SpvBuilder.cpp",
            "quanta/lib/glslang/SPIRV/SpvPostProcess.cpp",
            "quanta/lib/glslang/SPIRV/doc.cpp",
            "quanta/lib/glslang/SPIRV/SpvTools.cpp",
            "quanta/lib/glslang/SPIRV/disassemble.cpp",
            "quanta/lib/glslang/SPIRV/CInterface/spirv_c_interface.cpp",
        }, &.{"-DENABLE_HLSL"});

        glslang.addIncludePath("quanta/lib/glslang/");
        glslang.addIncludePath("quanta/lib/glslang/Include/");
        glslang.addIncludePath("quanta/lib/glslang/HLSL/");
        glslang.addIncludePath("quanta/lib/glslang/MachineIndependent/");
        glslang.addIncludePath("quanta/lib/glslang/Public/");
        glslang.linkLibC();
        glslang.linkLibCpp();

        const libshaderc_util = builder.addStaticLibrary(.{
            .name = "libshaderc_util",
            .target = target,
            .optimize = mode,
        });

        libshaderc_util.addIncludePath("quanta/lib/shaderc/libshaderc_util/include/");
        libshaderc_util.addIncludePath("quanta/lib/shaderc/libshaderc_util/include/glslang/Include/");
        libshaderc_util.addIncludePath("quanta/lib/shaderc/libshaderc_util/include/HLSL/");
        libshaderc_util.addIncludePath("quanta/lib/shaderc/glslang/include/HLSL/");
        libshaderc_util.addIncludePath("quanta/lib/glslang/");
        libshaderc_util.addCSourceFiles(&[_][]const u8{
            "quanta/lib/shaderc/libshaderc_util/src/args.cc",
            "quanta/lib/shaderc/libshaderc_util/src/compiler.cc",
            "quanta/lib/shaderc/libshaderc_util/src/file_finder.cc",
            "quanta/lib/shaderc/libshaderc_util/src/io_shaderc.cc",
            "quanta/lib/shaderc/libshaderc_util/src/message.cc",
            "quanta/lib/shaderc/libshaderc_util/src/resources.cc",
            "quanta/lib/shaderc/libshaderc_util/src/shader_stage.cc",
            "quanta/lib/shaderc/libshaderc_util/src/spirv_tools_wrapper.cc",
            "quanta/lib/shaderc/libshaderc_util/src/version_profile.cc",
        }, &.{"-DENABLE_HLSL"});
        libshaderc_util.linkLibC();
        libshaderc_util.linkLibCpp();
        libshaderc_util.linkLibrary(glslang);

        const libshaderc = builder.addStaticLibrary(.{
            .name = "libshaderc",
            .target = target,
            .optimize = mode,
        });

        libshaderc.addIncludePath("quanta/lib/shaderc/libshaderc/include/");
        libshaderc.addIncludePath("quanta/lib/shaderc/libshaderc_util/include/");
        libshaderc.addIncludePath("quanta/lib/shaderc/libshaderc_util/include/");
        libshaderc.addIncludePath("quanta/lib/shaderc/libshaderc_util/include/glslang/Include/");
        libshaderc.addIncludePath("quanta/lib/shaderc/libshaderc_util/include/HLSL/");
        libshaderc.addIncludePath("quanta/lib/shaderc/glslang/include/HLSL/");
        libshaderc.addIncludePath("quanta/lib/glslang/");
        libshaderc.addCSourceFiles(&[_][]const u8{
            "quanta/lib/shaderc/libshaderc/src/shaderc.cc",
        }, &.{"-DENABLE_HLSL"});
        libshaderc.linkLibC();
        libshaderc.linkLibCpp();
        libshaderc.linkLibrary(libshaderc_util);

        //TODO: Port version generation utility from shaderc/utils/update_build_version.py
        const glslc_build_version_inc = builder.addWriteFile("glslc/build-version.inc",
            \\"shaderc v2022.1 v2022.1\n" 
            \\"spirv-tools v2022.2-dev v2022.1-5-gb846f8f1\n"
            \\"glslang 11.1.0-408-gc34bb3b6\n"
        );

        const glslc = builder.addExecutable(.{
            .name = "glslc",
        });

        glslc.step.dependOn(&glslc_build_version_inc.step);

        glslc.addCSourceFiles(&[_][]const u8{
            "quanta/lib/shaderc/glslc/src/main.cc",
            "quanta/lib/shaderc/glslc/src/dependency_info.cc",
            "quanta/lib/shaderc/glslc/src/file_compiler.cc",
            "quanta/lib/shaderc/glslc/src/file_includer.cc",
            "quanta/lib/shaderc/glslc/src/file.cc",
            "quanta/lib/shaderc/glslc/src/resource_parse.cc",
            "quanta/lib/shaderc/glslc/src/shader_stage.cc",
        }, &.{"-DENABLE_HLSL"});
        glslc.addIncludePath("quanta/lib/shaderc/libshaderc/include/");
        glslc.addIncludePath("quanta/lib/shaderc/libshaderc_util/include/");
        glslc.addIncludePath("zig-cache/glslc/");

        builder.installArtifact(glslc);
        glslc.linkLibC();
        glslc.linkLibCpp();
        glslc.linkLibrary(libshaderc);

        return Context{
            .builder = builder,
            .module = module,
            .glslc = glslc,
        };
    }
};

///Links the c depencencies into step
pub fn link(builder: *std.Build, step: *std.Build.CompileStep, package_path: []const u8) !void {
    step.addIncludePath(builder.pathJoin(&.{ package_path, "quanta/lib/cimgui/imgui/" }));
    step.addIncludePath(builder.pathJoin(&.{ package_path, "quanta/lib/ImGuizmo/" }));
    step.addCSourceFiles(&[_][]const u8{
        builder.pathJoin(&.{ package_path, "quanta/lib/cimgui/imgui/imgui.cpp" }),
        builder.pathJoin(&.{ package_path, "quanta/lib/cimgui/imgui/imgui_draw.cpp" }),
        builder.pathJoin(&.{ package_path, "quanta/lib/cimgui/imgui/imgui_tables.cpp" }),
        builder.pathJoin(&.{ package_path, "quanta/lib/cimgui/imgui/imgui_widgets.cpp" }),
        builder.pathJoin(&.{ package_path, "quanta/lib/cimgui/imgui/imgui_demo.cpp" }),
        builder.pathJoin(&.{ package_path, "quanta/lib/cimgui/cimgui.cpp" }),
        builder.pathJoin(&.{ package_path, "quanta/lib/ImGuizmo/ImGuizmo.cpp" }),
        builder.pathJoin(&.{ package_path, "quanta/src/imgui/guizmo.cpp" }),
    }, &[_][]const u8{});
    step.linkLibCpp();

    try glfw.link(builder, step, .{});
}
