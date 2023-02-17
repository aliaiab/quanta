const std = @import("std");

const glfw = @import("quanta/lib/mach-glfw/build.zig");

const quanta = @import("quanta/src/main.zig");
const quanta_build = @import("quanta/build.zig");

const asset_build = quanta.asset.build;

pub fn build(builder: *std.build.Builder) !void 
{
    const target = builder.standardTargetOptions(.{});
    const mode = builder.standardOptimizeOption(.{});

    const quanta_build_context = try quanta_build.Context.init(builder, mode);

    const quanta_module = quanta_build_context.module;

    //example asset build
    {
        const exe = builder.addExecutable(.{
            .name = "example_assets",
            .root_source_file = std.build.FileSource.relative("example/src/asset_build.zig"),
            .target = std.zig.CrossTarget.fromTarget(builder.host.target),
            .optimize = mode,
        });

        exe.install();

        exe.addModule("quanta", quanta_module);
        try quanta_build.link(exe);

        const run_cmd = builder.addRunArtifact(exe);

        run_cmd.step.dependOn(builder.getInstallStep());
        run_cmd.condition = .always;

        const run_step = builder.step("build_assets", "Build example assets");
        run_step.dependOn(&run_cmd.step);
    }

    //example
    {
        // const assets_step = try asset_build.ArchiveStep.init(builder, "test_assets");

        // try asset_build.GltfCompileStep.init(
        //     quanta_build_context, 
        //     "example/src/assets/test_scene/test_scene.gltf"
        // ).addToArchiveStep(assets_step);

        const exe = builder.addExecutable(.{
            .name = "example",
            .root_source_file = std.build.FileSource.relative("example/src/main.zig"),
            .target = target,
            .optimize = mode,
        });

        exe.install();

        exe.addModule("quanta", quanta_module);
        try quanta_build.link(exe);
        
        // exe.step.dependOn(&assets_step.step);

        if (mode == .ReleaseFast or mode == .ReleaseSmall)
        {
            exe.strip = true;
        }

        const run_cmd = builder.addRunArtifact(exe);

        run_cmd.step.dependOn(builder.getInstallStep());
        run_cmd.condition = .always;

        if (builder.args) |args| 
        {
            run_cmd.addArgs(args);
        }

        const run_step = builder.step("run_example", "Run the example application");
        run_step.dependOn(&run_cmd.step);
    }
}
