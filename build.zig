const std = @import("std");
const builtin = @import("builtin");

const glfw = @import("quanta/lib/mach-glfw/build.zig");

const quanta = @import("quanta/src/main.zig");
const quanta_build = @import("quanta/build.zig");

const asset_build = quanta.asset.build;

pub fn build(builder: *std.build.Builder) !void {
    comptime {
        const current_zig_version = builtin.zig_version;

        const min_zig_version = std.SemanticVersion.parse("0.12.0-dev.176+c429bb5d2") catch unreachable;
        const order = current_zig_version.order(min_zig_version);

        if (!(order == .eq or order == .gt)) {
            @compileError(std.fmt.comptimePrint("Your Zig version v{} does not meet the minimum build requirement of v{}", .{ current_zig_version, min_zig_version }));
        }
    }

    var target = builder.standardTargetOptions(.{});

    const mode = builder.standardOptimizeOption(.{});

    const quanta_build_context = try quanta_build.Context.init(builder, target, mode, "");

    const quanta_module = quanta_build_context.module;

    const quanta_test = try quanta_build.addTest(builder);

    //example asset build
    {
        const exe = builder.addExecutable(.{
            .name = "example_assets",
            .root_source_file = std.build.FileSource.relative("example/src/asset_build.zig"),
            .target = std.zig.CrossTarget.fromTarget(builder.host.target),
            .optimize = mode,
        });

        builder.installArtifact(exe);

        exe.addModule("quanta", quanta_module);
        try quanta_build.link(builder, exe, "");

        const run_cmd = builder.addRunArtifact(exe);

        run_cmd.step.dependOn(builder.getInstallStep());

        const run_step = builder.step("build_assets", "Build example assets");
        run_step.dependOn(&run_cmd.step);
    }

    //example
    {
        var example_target = target;

        if (mode == .ReleaseFast or mode == .ReleaseSmall or mode == .ReleaseSafe) {
            //TODO: Would use musl, but there seems to be an issue with mach-glfw/glfw
            example_target.abi = std.Target.Abi.gnu;
        }

        const exe = builder.addExecutable(.{
            .name = "example",
            .root_source_file = std.build.FileSource.relative("example/src/main.zig"),
            .target = example_target,
            .optimize = mode,
        });

        builder.installArtifact(exe);

        exe.addModule("quanta", quanta_module);
        try quanta_build.link(builder, exe, "");

        if (mode == .ReleaseFast or mode == .ReleaseSmall) {
            exe.strip = true;
        }

        const run_cmd = builder.addRunArtifact(exe);

        run_cmd.step.dependOn(builder.getInstallStep());
        run_cmd.step.dependOn(&quanta_build_context.run_asset_compiler.step);

        if (builder.args) |args| {
            run_cmd.addArgs(args);
        }

        run_cmd.cwd = "zig-out/bin/";

        const run_step = builder.step("run_example", "Run the example application");
        run_step.dependOn(&run_cmd.step);
    }

    //example app
    {
        const app = quanta.app.AppCompileStep.create(builder, .{
            .name = "example_app",
            .root_source_file = std.build.FileSource.relative("example/src/main.zig"),
            .target = target,
            .optimize = mode,
            .mode = .dynamic,
            .cwd = "zig-out/",
            .quanta_module = quanta_module,
        });

        try quanta_build.link(builder, app.app_compile_step, "");

        const run_step = app.run();

        run_step.step.dependOn(builder.getInstallStep());

        const run_cmd = builder.step("run_example_app", "Run the example application (quanta.app)");

        run_cmd.dependOn(&run_step.step);
    }

    {
        const test_step = builder.step("test", "Run the tests");

        const run_quanta_tests = builder.addRunArtifact(quanta_test);

        test_step.dependOn(&run_quanta_tests.step);
    }
}
