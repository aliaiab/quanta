pub fn build(builder: *Build) !void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    const quanta_dependency = builder.dependency("quanta", .{
        .target = target,
        .optimize = optimize,
    });

    const renderer_gui_rectangle_vert_module = GlslCompileStep.compileModule(builder, optimize, .vertex, builder.pathFromRoot("src/renderer_gui/rectangle.vert.glsl"), "rectangle.vert.spv");
    const renderer_gui_rectangle_frag_module = GlslCompileStep.compileModule(builder, optimize, .fragment, builder.pathFromRoot("src/renderer_gui/rectangle.frag.glsl"), "rectangle.frag.spv");
    const renderer_gui_mesh_vert_module = GlslCompileStep.compileModule(builder, optimize, .vertex, builder.pathFromRoot("src/renderer_gui/mesh.vert.glsl"), "mesh.vert.spv");
    const renderer_gui_mesh_frag_module = GlslCompileStep.compileModule(builder, optimize, .fragment, builder.pathFromRoot("src/renderer_gui/mesh.frag.glsl"), "mesh.frag.spv");

    const quanta_imgui_module = builder.addModule("quanta-imgui", .{
        .root_source_file = .{ .path = builder.pathFromRoot("src/root.zig") },
        .imports = &.{
            .{ .name = "renderer_gui_rectangle_vert.spv", .module = renderer_gui_rectangle_vert_module },
            .{ .name = "renderer_gui_rectangle_frag.spv", .module = renderer_gui_rectangle_frag_module },
            .{ .name = "renderer_gui_mesh_vert.spv", .module = renderer_gui_mesh_vert_module },
            .{ .name = "renderer_gui_mesh_frag.spv", .module = renderer_gui_mesh_frag_module },
            .{ .name = "quanta", .module = quanta_dependency.module("quanta") },
        },
        .link_libcpp = true,
        .link_libc = true,
        .target = target,
    });

    quanta_imgui_module.addIncludePath(.{ .path = builder.pathFromRoot("lib/cimgui/imgui/") });
    quanta_imgui_module.addIncludePath(.{ .path = builder.pathFromRoot("lib/ImGuizmo/") });
    quanta_imgui_module.addCSourceFiles(.{
        .files = &[_][]const u8{
            builder.pathFromRoot("lib/cimgui/imgui/imgui.cpp"),
            builder.pathFromRoot("lib/cimgui/imgui/imgui_draw.cpp"),
            builder.pathFromRoot("lib/cimgui/imgui/imgui_tables.cpp"),
            builder.pathFromRoot("lib/cimgui/imgui/imgui_widgets.cpp"),
            builder.pathFromRoot("lib/cimgui/imgui/imgui_demo.cpp"),
            builder.pathFromRoot("lib/cimgui/cimgui.cpp"),
            builder.pathFromRoot("lib/ImGuizmo/ImGuizmo.cpp"),
            builder.pathFromRoot("src/imgui/guizmo.cpp"),
        },
        .flags = &[_][]const u8{},
    });
}

const std = @import("std");
const Build = std.Build;
const quanta = @import("quanta");
const GlslCompileStep = quanta.GlslCompileStep;
