pub const image_count = 6;

width: u32,
height: u32,
data: []const u8,

pub fn assetLoad(
    storage: *AssetStorage,
    handle: Asset(CubeMap),
    asset: *CubeMap,
    data: []u8,
) !void {
    _ = storage;
    _ = handle;

    asset.width = 1024;
    asset.height = 1024;
    asset.data = data;
}

pub fn assetUnload(
    storage: *AssetStorage,
    handle: Asset(CubeMap),
    asset: *CubeMap,
) void {
    _ = asset;
    _ = storage;
    _ = handle;
}

pub const Metadata = struct {
    top: []const u8 = "",
    bottom: []const u8 = "",
    left: []const u8 = "",
    right: []const u8 = "",
    front: []const u8 = "",
    back: []const u8 = "",
};

pub fn assetCompile(
    context: *compiler.CompilerContext,
    file_path: []const u8,
    data: []const u8,
    meta_data: ?Metadata,
) ![]const u8 {
    _ = data; // autofix

    const directory_path = std.fs.path.dirname(file_path) orelse unreachable;

    log.info("meta_data = {?}", .{meta_data});
    log.info("path(right) = {s}", .{(try std.fs.path.join(context.allocator, &.{ directory_path, meta_data.?.right }))});

    const imported = try importers.png.importCubeFile(context.allocator, .{
        (try std.fs.path.join(context.allocator, &.{ directory_path, meta_data.?.right })), //x+
        (try std.fs.path.join(context.allocator, &.{ directory_path, meta_data.?.left })), //x+
        (try std.fs.path.join(context.allocator, &.{ directory_path, meta_data.?.top })), //x+
        (try std.fs.path.join(context.allocator, &.{ directory_path, meta_data.?.bottom })), //x+
        (try std.fs.path.join(context.allocator, &.{ directory_path, meta_data.?.back })), //x+
        (try std.fs.path.join(context.allocator, &.{ directory_path, meta_data.?.front })), //x+
    });

    return imported.data;
}

pub const file_extension = ".cubemap.zon";
pub const base_hash = "1";

const compiler = @import("compiler.zig");
const importers = @import("frontends.zig");
const std = @import("std");
const log = @import("../log.zig").log;
const AssetStorage = @import("AssetStorage.zig");
const Asset = AssetStorage.Asset;
const CubeMap = @This();
