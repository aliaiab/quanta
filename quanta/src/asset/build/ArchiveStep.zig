const std = @import("std");
const Archive = @import("../Archive.zig");
const Step = std.Build.Step;
const ArchiveStep = @This();

pub const base_id: Step.Id = .custom;

pub const AssetDescription = struct 
{
    pub const Source = union(enum) 
    {
        ///Pointer to a generated file that will be placed as an asset
        generated_file: *const std.Build.GeneratedFile,
    };

    source: Source,
    alignment: u32 = 1,
};

step: Step,
builder: *std.Build,
name: []const u8,
assets: std.ArrayListUnmanaged(AssetDescription),

pub fn init(
    builder: *std.Build,
    name: []const u8,
) !*ArchiveStep 
{
    const self = builder.allocator.create(ArchiveStep) catch unreachable;

    self.* = .{
        .step = Step.init(base_id, name, builder.allocator, &make),
        .builder = builder,
        .name = name,
        .assets = .{},
    };

    return self;
}

pub fn make(step: *Step) !void
{
    const self = @fieldParentPtr(@This(), "step", step);

    std.debug.print("Making asset archive '{s}'\n", .{ self.name });

    const asset_descriptions = try self.builder.allocator.alloc(Archive.AssetDescription, self.assets.items.len);

    for (self.assets.items) |asset, i|
    {
        if (true) continue;
        const path: []const u8 = asset.source.generated_file.path orelse continue;

        const asset_file = try std.fs.cwd().openFile(path, .{});
        defer asset_file.close();

        const asset_data = try asset_file.readToEndAlloc(self.builder.allocator, std.math.maxInt(usize));

        asset_descriptions[i] = .{
            .source_data = asset_data,
            .source_data_alignment = asset.alignment,
            .mapped_data_size = asset_data.len,
        };
    }

    const asset_archive = try Archive.encode(self.builder.allocator, asset_descriptions);

    const asset_archive_path = try std.fs.path.join(self.builder.allocator, &.{ 
        "zig-out/bin/",
        self.name,
    });

    const asset_archive_file = std.fs.cwd().openFile(asset_archive_path, .{ .mode = .write_only }) catch try std.fs.cwd().createFile(asset_archive_path, .{});
    defer asset_archive_file.close();

    try asset_archive_file.writeAll(asset_archive);
}

pub fn addAsset(self: *ArchiveStep, name: []const u8, asset: AssetDescription) !void 
{
    _ = name;

    try self.assets.append(self.builder.allocator, asset);
}

pub fn addAnonymousAsset(self: ArchiveStep, asset: Archive.AssetDescription) void 
{
    _ = self;
    _ = asset;
}