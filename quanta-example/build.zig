pub fn build(builder: *std.Build) !void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    const quanta_dependency = builder.dependency("quanta", .{
        .target = target,
        .optimize = optimize,
    });

    const quanta_imgui_dependency = builder.dependency("quanta_imgui", .{
        .target = target,
        .optimize = optimize,
    });

    const quanta_module = quanta_dependency.module("quanta");

    const exe = builder.addExecutable(.{
        .name = "example",
        .root_source_file = .{ .path = builder.pathFromRoot("src/main.zig") },
        .target = target,
        .optimize = optimize,
        .strip = optimize == .ReleaseFast or optimize == .ReleaseSmall,
    });

    builder.installArtifact(exe);

    exe.root_module.addImport("quanta", quanta_module);
    exe.root_module.addImport("quanta-imgui", quanta_imgui_dependency.module("quanta-imgui"));

    const compile_assets = quanta.addAssetCompileStep(
        builder,
        quanta_dependency,
        .{
            .source_directory = builder.pathFromRoot("src/assets/"),
            .install_directory = builder.pathFromRoot("zig-out/bin/"),
            .artifact_name = "example_assets_archive",
            .target = target,
            .optimize = optimize,
        },
    );

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

const std = @import("std");
const builtin = @import("builtin");
const quanta = @import("quanta");
