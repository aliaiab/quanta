const AssetStorage = @import("AssetStorage.zig");
const Asset = AssetStorage.Asset;

const CubeMap = @This();

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
