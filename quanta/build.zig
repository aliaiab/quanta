const std = @import("std");
const GlslCompileStep = @import("src/asset/build/GlslCompileStep.zig");
const glfw = @import("lib/mach-glfw/build.zig");
const zgltf = @import("lib/zgltf/build.zig");

pub fn build(builder: *std.Build) !void
{
    _ = builder;
}

pub fn addTest(builder: *std.Build) !*std.Build.CompileStep
{
    return builder.addTest(.{
        .name = "test",
        .root_source_file = std.build.FileSource.relative("quanta/src/main.zig"),
        .optimize = .Debug,
    });
}

pub const Context = struct 
{
    builder: *std.Build,
    module: *std.Build.Module,

    pub fn init(
        builder: *std.Build,
        mode: std.builtin.OptimizeMode,
    ) !Context
    {
        const renderer_tri_vert_spv_module = GlslCompileStep.compileModule(builder, mode, .vertex, "quanta/src/renderer/tri.vert.glsl", "tri.vert.spv");
        const renderer_tri_frag_spv_module = GlslCompileStep.compileModule(builder, mode, .fragment, "quanta/src/renderer/tri.frag.glsl", "tri.frag.spv");
        const renderer_sky_vert_spv_module = GlslCompileStep.compileModule(builder, mode, .vertex, "quanta/src/renderer/sky.vert.glsl", "sky.vert.spv");
        const renderer_sky_frag_spv_module = GlslCompileStep.compileModule(builder, mode, .fragment, "quanta/src/renderer/sky.frag.glsl", "sky.frag.spv");
        const renderer_depth_vert_spv_module = GlslCompileStep.compileModule(builder, mode, .vertex, "quanta/src/renderer/depth.vert.glsl", "depth.vert.spv");
        const renderer_depth_frag_spv_module = GlslCompileStep.compileModule(builder, mode, .fragment, "quanta/src/renderer/depth.frag.glsl", "depth.frag.spv");
        const renderer_pre_depth_cull_comp_module = GlslCompileStep.compileModule(builder, mode, .compute, "quanta/src/renderer/pre_depth_cull.comp.glsl", "pre_depth_cull.comp.spv");
        const renderer_post_depth_cull_comp_module = GlslCompileStep.compileModule(builder, mode, .compute, "quanta/src/renderer/post_depth_cull.comp.glsl", "post_depth_cull.comp.spv");
        const renderer_depth_reduce_comp_module = GlslCompileStep.compileModule(builder, mode, .compute, "quanta/src/renderer/depth_reduce.comp.glsl", "depth_reduce.comp.spv");
        const renderer_color_resolve_comp_module = GlslCompileStep.compileModule(builder, mode, .compute, "quanta/src/renderer/color_resolve.comp.glsl", "color_resolve.comp.spv");

        const renderer_gui_rectangle_vert_module = GlslCompileStep.compileModule(builder, mode, .vertex, "quanta/src/renderer_gui/rectangle.vert.glsl", "rectangle.vert.spv");
        const renderer_gui_rectangle_frag_module = GlslCompileStep.compileModule(builder, mode, .fragment, "quanta/src/renderer_gui/rectangle.frag.glsl", "rectangle.frag.spv");
        const renderer_gui_mesh_vert_module = GlslCompileStep.compileModule(builder, mode, .vertex, "quanta/src/renderer_gui/mesh.vert.glsl", "mesh.vert.spv");
        const renderer_gui_mesh_frag_module = GlslCompileStep.compileModule(builder, mode, .fragment, "quanta/src/renderer_gui/mesh.frag.glsl", "mesh.frag.spv");

        const options = builder.addOptions();

        var module = builder.createModule(
            .{
                .source_file = std.build.FileSource.relative("quanta/src/main.zig"),
                .dependencies = &.{
                    .{ .name = "options", .module = options.createModule() },
                    .{ .name = "glfw", .module = glfw.module(builder) },
                    .{ .name = "zgltf", .module = builder.createModule(.{ .source_file = std.build.FileSource.relative("quanta/lib/zgltf/src/main.zig") }) },
                    .{ .name = "zigimg", .module = builder.createModule(.{ .source_file = std.build.FileSource.relative("quanta/lib/zigimg/zigimg.zig") }) },
                    .{ .name = "zalgebra", .module = builder.createModule(.{ .source_file = std.build.FileSource.relative("quanta/lib/zalgebra/src/main.zig") }) },
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
            }
        );

        return Context 
        {
            .builder = builder,
            .module = module,
        };
    }
};

///Links the c depencencies into step
pub fn link(step: *std.build.CompileStep) !void 
{
    step.addCSourceFile("quanta/src/asset/importers/cgltf.c", &[_][]const u8 {});
    step.addIncludePath("quanta/lib/Nuklear/");
    step.addCSourceFile("quanta/src/nuklear/nuklear.c", &[_][]const u8 {});
    step.addIncludePath("lib/cimgui/imgui/");
    step.addCSourceFiles(&[_][]const u8 {
        "quanta/lib/cimgui/imgui/imgui.cpp",
        "quanta/lib/cimgui/imgui/imgui_draw.cpp",
        "quanta/lib/cimgui/imgui/imgui_tables.cpp",
        "quanta/lib/cimgui/imgui/imgui_widgets.cpp",
        "quanta/lib/cimgui/imgui/imgui_demo.cpp",
        "quanta/lib/cimgui/cimgui.cpp",
    }, &[_][]const u8 {});
    step.linkLibCpp();

    try glfw.link(step.builder, step, .{});
}