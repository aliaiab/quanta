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

    const imgui = builder.dependency("imgui", .{});
    const imguizmo = builder.dependency("imguizmo", .{});
    const imgui_node_editor = builder.dependency("imgui_node_editor", .{});

    quanta_imgui_module.addIncludePath(imgui.path(""));
    quanta_imgui_module.addIncludePath(imguizmo.path(""));
    quanta_imgui_module.addIncludePath(imgui_node_editor.path(""));
    quanta_imgui_module.addCSourceFiles(.{
        .dependency = imgui,
        .files = &[_][]const u8{
            "imgui.cpp",
            "imgui_draw.cpp",
            "imgui_tables.cpp",
            "imgui_widgets.cpp",
            "imgui_demo.cpp",
        },
        .flags = &[_][]const u8{},
    });
    quanta_imgui_module.addCSourceFiles(.{
        .files = &[_][]const u8{
            builder.pathFromRoot("src/imgui/cimgui.cpp"),
            builder.pathFromRoot("src/imgui/guizmo.cpp"),
            builder.pathFromRoot("src/imgui/node_editor.cpp"),
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
    quanta_imgui_module.addCSourceFiles(.{
        .dependency = imgui_node_editor,
        .files = &[_][]const u8{
            "crude_json.cpp",
            "imgui_canvas.cpp",
            "imgui_node_editor.cpp",
            "imgui_node_editor_api.cpp",
        },
        .flags = &[_][]const u8{},
    });
}

const std = @import("std");
const Build = std.Build;
const quanta = @import("quanta");
