const std = @import("std");
const builtin = @import("builtin");

const glfw = @import("quanta/lib/mach-glfw/build.zig");

const quanta = @import("quanta/src/main.zig");
const quanta_build = @import("quanta/build.zig");

const asset_build = quanta.asset.build;

pub fn build(builder: *std.build.Builder) !void 
{
    comptime 
    {
        const current_zig_version = builtin.zig_version;

        const min_zig_version = std.SemanticVersion.parse("0.11.0-dev.1862+e7f128c20") catch unreachable;

        if (current_zig_version.order(min_zig_version) == .lt) 
        {
            @compileError(std.fmt.comptimePrint("Your Zig version v{} does not meet the minimum build requirement of v{}", .{ current_zig_version, min_zig_version }));
        }
    }

    const target = builder.standardTargetOptions(.{});
    const mode = builder.standardOptimizeOption(.{});

    const quanta_build_context = try quanta_build.Context.init(builder, mode);

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

        exe.install();

        exe.addModule("quanta", quanta_module);
        try quanta_build.link(exe);

        const run_cmd = builder.addRunArtifact(exe);

        run_cmd.step.dependOn(builder.getInstallStep());

        const run_step = builder.step("build_assets", "Build example assets");
        run_step.dependOn(&run_cmd.step);
    }

    //example
    {
        var example_target = target;

        if (mode == .ReleaseFast or mode == .ReleaseSmall or mode == .ReleaseSafe)
        {
            //TODO: Would use musl, but there seems to be an issue with mach-glfw/glfw
            example_target.abi = std.Target.Abi.gnu;
        }

        const exe = builder.addExecutable(.{
            .name = "example",
            .root_source_file = std.build.FileSource.relative("example/src/main.zig"),
            .target = example_target,
            .optimize = mode,
        });

        exe.install();

        exe.addModule("quanta", quanta_module);
        try quanta_build.link(exe);
        
        if (mode == .ReleaseFast or mode == .ReleaseSmall)
        {
            exe.strip = true;
        }

        const run_cmd = builder.addRunArtifact(exe);

        run_cmd.step.dependOn(builder.getInstallStep());

        if (builder.args) |args| 
        {
            run_cmd.addArgs(args);
        }

        run_cmd.cwd = "zig-out/bin/";

        const run_step = builder.step("run_example", "Run the example application");
        run_step.dependOn(&run_cmd.step);
    }

    {
        const test_step = builder.step("test", "Run the tests");

        test_step.dependOn(&quanta_test.step);
    }
}
