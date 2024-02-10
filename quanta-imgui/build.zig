pub fn build(builder: *Build) !void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    const quanta_dependency = builder.dependency("quanta", .{
        .target = target,
        .optimize = optimize,
    });

    const glsl_compile_step = quanta.addGlslCompileStep(builder, quanta_dependency, .{
        .optimize = optimize,
        .source_directory = builder.pathFromRoot("src/renderer_gui/shaders.zon"),
    });

    const quanta_imgui_module = builder.addModule("quanta_imgui", .{
        .root_source_file = .{ .path = builder.pathFromRoot("src/root.zig") },
        .imports = &.{
            .{ .name = "quanta", .module = quanta_dependency.module("quanta") },
        },
        .link_libcpp = true,
        .link_libc = true,
        .target = target,
    });

    glsl_compile_step.addImportToModule(quanta_imgui_module);

    const imguizmo = builder.dependency("imguizmo", .{});

    quanta_imgui_module.addIncludePath(.{ .path = builder.pathFromRoot("lib/cimgui/imgui/") });
    quanta_imgui_module.addIncludePath(imguizmo.path(""));
    quanta_imgui_module.addCSourceFiles(.{
        .files = &[_][]const u8{
            builder.pathFromRoot("lib/cimgui/imgui/imgui.cpp"),
            builder.pathFromRoot("lib/cimgui/imgui/imgui_draw.cpp"),
            builder.pathFromRoot("lib/cimgui/imgui/imgui_tables.cpp"),
            builder.pathFromRoot("lib/cimgui/imgui/imgui_widgets.cpp"),
            builder.pathFromRoot("lib/cimgui/imgui/imgui_demo.cpp"),
            builder.pathFromRoot("lib/cimgui/cimgui.cpp"),
            builder.pathFromRoot("src/imgui/guizmo.cpp"),
        },
        .flags = &[_][]const u8{},
    });
    quanta_imgui_module.addCSourceFiles(.{
        .dependency = imguizmo,
        .files = &[_][]const u8{
            "ImGuizmo.cpp",
        },
        .flags = &[_][]const u8{},
    });
}

const std = @import("std");
const Build = std.Build;
const quanta = @import("quanta");
