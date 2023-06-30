const std = @import("std");
const Archive = @import("Archive.zig");
const ArchiveLoader = @This();

allocator: std.mem.Allocator,
file_path: []const u8,
file: std.fs.File,

pub fn init(
    allocator: std.mem.Allocator,
    file_path: []const u8,
) !ArchiveLoader {
    var self = ArchiveLoader{
        .allocator = allocator,
        .file_path = file_path,
        .file = try std.fs.cwd().openFile(file_path, .{}),
    };

    var header: Archive.Header = undefined;

    var offset = try self.file.read(std.mem.asBytes(&header));

    offset = std.mem.alignForward(usize, offset, @alignOf(Archive.AssetHeader));

    try self.file.seekTo(offset);

    const asset_headers = try allocator.alloc(Archive.AssetHeader, header.asset_count);
    defer allocator.free(asset_headers);

    _ = try self.file.read(std.mem.sliceAsBytes(asset_headers));

    for (asset_headers, 0..) |asset_header, i| {
        std.log.info("[{}] asset_header = {}", .{ i, asset_header });
    }

    return self;
}

pub fn deinit(self: *ArchiveLoader) void {
    defer self.* = undefined;

    self.file.close();
}

pub const AssetHandle = enum(u64) {
    _,
};

pub fn load(self: *ArchiveLoader, asset: Archive.AssetDescriptor) AssetHandle {
    _ = self;
    _ = asset;
}

pub fn unload(self: *ArchiveLoader, asset: AssetHandle) void {
    _ = self;
    _ = asset;
}
