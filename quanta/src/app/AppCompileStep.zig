const std = @import("std");

const AppCompileStep = @This();
const Step = std.Build.Step;
const FileSource = std.Build.FileSource;
const CrossTarget = std.zig.CrossTarget;

pub const base_id: Step.Id = .custom;

step: Step,
builder: *std.Build,
name: []const u8,
root_source_file: FileSource,
version: ?std.builtin.Version,
target: CrossTarget,
optimize: std.builtin.Mode,
mode: AppMode,
app_compile_step: *std.Build.CompileStep,
app_runner_compile_step: *std.Build.CompileStep,
cwd: []const u8,

pub const AppMode = enum
{
    ///The app is statically linked with the app runner
    static,
    ///The app is dynamically loaded by the app runner
    dynamic,
};

pub const AppOptions = struct {
    name: []const u8,
    root_source_file: ?FileSource = null,
    version: ?std.builtin.Version = null,
    target: CrossTarget = .{},
    optimize: std.builtin.Mode = .Debug,
    mode: AppMode,
    cwd: []const u8,
    quanta_module: *std.Build.Module,
};

pub fn create(
    builder: *std.Build,
    options: AppOptions,
) *AppCompileStep
{
    const self = builder.allocator.create(AppCompileStep) catch unreachable;

    const app_compile_step = std.Build.CompileStep.create(builder, .{
        .name = options.name,
        .root_source_file = options.root_source_file.?,
        .kind = .lib,
        .linkage = .dynamic,
        .target = options.target,
        .optimize = options.optimize,
        .version = options.version,
    });

    app_compile_step.force_pic = true;
    app_compile_step.bundle_compiler_rt = true;
    app_compile_step.dll_export_fns = true;

    app_compile_step.addModule("quanta", options.quanta_module);
    app_compile_step.install();

    const app_runner_compile_step = std.Build.CompileStep.create(builder, .{
        .name = options.name,
        .root_source_file = std.build.FileSource.relative("quanta/src/app/app_runner.zig"),
        .kind = .exe,
        .target = options.target,
        .optimize = options.optimize,
        .version = options.version,
    });

    app_runner_compile_step.install();
    app_runner_compile_step.linkLibC();

    self.* = .{
        .builder = builder,
        .step = std.Build.Step.init(.{ .id = base_id, .name = options.name, .owner = builder, .makeFn = &make }),
        .name = options.name,
        .root_source_file = options.root_source_file.?,
        .version = options.version,
        .target = options.target,
        .optimize = options.optimize,
        .mode = options.mode,
        .app_compile_step = app_compile_step,
        .app_runner_compile_step = app_runner_compile_step,
        .cwd = options.cwd,
    };

    self.step.dependOn(&self.app_compile_step.step);
    self.step.dependOn(&self.app_runner_compile_step.step);

    return self;
}

pub fn run(self: *AppCompileStep) *std.Build.RunStep
{
    const run_step = self.builder.addRunArtifact(self.app_runner_compile_step);

    run_step.cwd = self.cwd;

    return run_step;
}

fn make(step: *Step, progress_node: *std.Progress.Node) !void
{
    const self = step.cast(@This()).?;

    try self.step.make(progress_node);
}