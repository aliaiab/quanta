const std = @import("std");
const Step = std.Build.Step;
const GltfCompileStep = @This();
const ArchiveStep = @import("ArchiveStep.zig");
const gltf = @import("../importers/gltf.zig");
const build = @import("../../../build.zig");

pub const base_id: Step.Id = .custom;

var gltf_import_cmd: ?*std.Build.CompileStep = null;

step: Step,
builder: *std.Build,
source_path: []const u8,
generated_file: std.Build.GeneratedFile,

pub fn init(
    context: build.Context,
    source_path: []const u8,
) *GltfCompileStep {
    const builder = context.builder;

    const self = builder.allocator.create(GltfCompileStep) catch unreachable;

    self.* = .{ .step = Step.init(base_id, source_path, builder.allocator, &make), .builder = builder, .source_path = source_path, .generated_file = .{
        .step = &self.step,
        .path = null,
    } };

    if (gltf_import_cmd == null) {
        gltf_import_cmd = self.builder.addExecutable(.{
            .name = "gltf_import_cmd",
            .root_source_file = std.build.FileSource.relative("quanta/src/asset/build/gltf_import_cmd.zig"),
            .optimize = .Debug,
        });

        gltf_import_cmd.?.addModule("quanta", context.module);
        build.link(gltf_import_cmd.?) catch unreachable;

        self.step.dependOn(&gltf_import_cmd.?.step);
    }

    return self;
}

pub fn make(step: *Step) !void {
    const self = step.cast(GltfCompileStep).?;

    var cache_manifest = self.builder.cache.obtain();
    defer cache_manifest.deinit();

    _ = try cache_manifest.addFile(self.source_path, std.math.maxInt(usize));

    const cache_hit = try cache_manifest.hit();

    const cache_digest = cache_manifest.final();

    const cache_path = try self.builder.cache_root.join(self.builder.allocator, &.{
        "o/",
        &cache_digest,
        self.source_path,
    });

    std.fs.makeDirAbsolute(std.fs.path.dirname(cache_path).?) catch {};

    self.generated_file.path = cache_path;

    if (cache_hit) {
        // return;
    }

    const gltf_import_run = gltf_import_cmd.?.run();

    try gltf_import_run.step.make();

    // try std.fs.cwd().writeFile(cache_path, import_encoded);

    try cache_manifest.writeManifest();
}

pub fn addToArchiveStep(self: GltfCompileStep, step: *ArchiveStep) !void {
    if (true) return;

    try step.addAsset(self.source_path, .{
        .source = .{ .generated_file = &self.generated_file },
        .alignment = @alignOf(gltf.ImportBinHeader),
    });
}
