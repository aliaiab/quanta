image: []u8,
asset_name_hashes: []u64,
assets: []AssetHeader,
asset_content: []u8,

pub const Header = extern struct {
    asset_count: u32,
};

pub const AssetDescriptor = enum(u32) { _ };

pub const AssetHeader = extern struct {
    source_data_offset: u64,
    source_data_size: u64,
    mapped_data_size: u64,
    mapped_data_alignment: u32,
};

pub const AssetMappedRegion = extern struct {};

pub const AssetDescription = struct {
    name: []const u8,
    source_data: []const u8,
    source_data_alignment: u32,
    mapped_data_size: u64,
};

pub const AssetLocation = struct {
    path: []const u8,
};

pub fn encode(allocator: std.mem.Allocator, assets: []const AssetDescription) ![]const u8 {
    var image_size: usize = @sizeOf(Header);

    image_size = std.mem.alignForward(usize, image_size, @alignOf(AssetHeader));

    const name_hashes_offset = image_size;

    image_size += @sizeOf(u64) * assets.len;

    const asset_headers_offset = image_size;

    image_size += @sizeOf(AssetHeader) * assets.len;

    var source_content_size: usize = 0;

    for (assets) |asset| {
        const aligned_size = std.mem.alignForward(usize, source_content_size, asset.source_data_alignment);

        source_content_size = aligned_size + asset.source_data.len;
    }

    image_size += source_content_size;

    //Seems to be a 4 byte inconsistency somewhere....
    const image = try allocator.alignedAlloc(u8, @alignOf(Header), image_size);
    errdefer allocator.free(image);

    const name_hashes: [*]u64 = @alignCast(@ptrCast(image.ptr + name_hashes_offset));
    const asset_headers: [*]AssetHeader = @alignCast(@ptrCast(image.ptr + asset_headers_offset));

    //In order for builds to be reproducable, images must set padding bytes to a known value
    @memset(image, 0xaa);

    var image_offset: usize = 0;

    const header = @as(*Header, @ptrCast(@alignCast(image.ptr)));
    image_offset += @sizeOf(Header);

    image_offset = std.mem.alignForward(usize, image_offset, @alignOf(AssetHeader));

    image_offset += assets.len * @sizeOf(u64);
    image_offset += assets.len * @sizeOf(AssetHeader);

    header.asset_count = @as(u32, @intCast(assets.len));

    var current_content_offset: usize = image_offset;

    for (assets, 0..) |asset, i| {
        const asset_header = &asset_headers[i];

        current_content_offset = std.mem.alignForward(usize, current_content_offset, asset.source_data_alignment);

        asset_header.source_data_size = @as(u32, @intCast(asset.source_data.len));
        asset_header.source_data_offset = @as(u32, @intCast(current_content_offset));
        asset_header.mapped_data_size = @as(u32, @intCast(asset.mapped_data_size));
        asset_header.mapped_data_alignment = 1;

        name_hashes[i] = hashAssetName(asset.name);

        @memcpy(image[asset_header.source_data_offset .. asset_header.source_data_offset + asset.source_data.len], asset.source_data[0..]);

        current_content_offset += asset_header.source_data_size;
    }

    return image;
}

pub fn decode(allocator: std.mem.Allocator, image: []u8) !Archive {
    _ = allocator;

    var archive = Archive{
        .image = image,
        .assets = &.{},
        .asset_content = &.{},
        .asset_name_hashes = &.{},
    };

    var image_offset: usize = 0;

    const header = @as(*const Header, @ptrCast(@alignCast(image.ptr + image_offset))).*;

    image_offset += @sizeOf(Header);

    image_offset = std.mem.alignForward(usize, image_offset, @alignOf(AssetHeader));

    archive.asset_name_hashes = @as([*]u64, @ptrCast(@alignCast(image.ptr + image_offset)))[0..header.asset_count];

    image_offset += @sizeOf(u64) * header.asset_count;

    archive.assets = @as([*]AssetHeader, @ptrCast(@alignCast(image.ptr + image_offset)))[0..header.asset_count];

    image_offset += @sizeOf(AssetHeader) * header.asset_count;

    archive.asset_content = image[image_offset..];

    return archive;
}

pub fn getAssetData(self: Archive, asset: AssetDescriptor) []u8 {
    const header = self.assets[@intFromEnum(asset)];

    return self.image[header.source_data_offset .. header.source_data_offset + header.source_data_size];
}

pub fn getAssetDataFromName(self: Archive, comptime name: []const u8) error{
    AssetNotFound,
}![]u8 {
    const hash = comptime hashAssetName(name);

    for (self.asset_name_hashes, 0..) |asset_name_hash, index| {
        if (hash == asset_name_hash) {
            return self.getAssetData(@enumFromInt(index));
        }
    }

    return error.AssetNotFound;
}

pub fn hashAssetName(name: []const u8) u64 {
    return std.hash_map.hashString(name);
}

const Archive = @This();
const std = @import("std");
