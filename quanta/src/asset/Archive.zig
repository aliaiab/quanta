//! An asset archive format that allows for parralel streaming and incremental compilation/caching/hot reload.

image: []u8,
asset_name_hashes: []u64,
asset_content_hashes: []align(1) u256,
assets: []AssetHeader,
asset_content: []u8,

pub const Header = extern struct {
    asset_count: u32,
    ///Can be zero (content hashes are optional)
    asset_content_hashes_count: u32,
};

///Represents an index into the asset header table in the archive
pub const AssetDescriptor = enum(u32) { _ };

pub const AssetHeader = extern struct {
    ///An offset of the source data in the address space of the archive
    source_data_offset: u64,
    ///The size that the source data takes up in the archive from source_data_offset
    source_data_size: u64,
    ///Must be greater than or equal to source_data_size
    mapped_data_size: u64,
    ///Must represent an alignment greater than or equal to the relative alignment of source_data_offset
    mapped_data_alignment: u32,
};

pub const AssetDescription = struct {
    name: []const u8,
    source_data: []const u8,
    source_data_alignment: u32,
    mapped_data_size: u64,
    content_hash: u256,
};

pub const AssetLocation = struct {
    path: []const u8,
};

pub fn encode(
    allocator: std.mem.Allocator,
    assets: []const AssetDescription,
) ![]const u8 {
    var image_size: usize = @sizeOf(Header);

    const name_hashes_offset = image_size;

    image_size += @sizeOf(u64) * assets.len;

    const asset_content_hashes = image_size;

    image_size += @sizeOf(u256) * assets.len;

    image_size = std.mem.alignForward(usize, image_size, @alignOf(AssetHeader));

    const asset_headers_offset = image_size;

    image_size += @sizeOf(AssetHeader) * assets.len;

    var source_content_size: usize = 0;

    for (assets) |asset| {
        const aligned_size = std.mem.alignForward(usize, source_content_size, asset.source_data_alignment);

        source_content_size = aligned_size + asset.source_data.len;
    }

    image_size += source_content_size;

    const image = try allocator.alignedAlloc(u8, @alignOf(Header), image_size);
    errdefer allocator.free(image);

    //In order for builds to be reproducable, images must set padding bytes to a known value
    //Using zero will potentially improve compression ratios and is just better generally
    @memset(image, 0);

    const name_hashes: [*]u64 = @alignCast(@ptrCast(image.ptr + name_hashes_offset));
    const asset_headers: [*]AssetHeader = @alignCast(@ptrCast(image.ptr + asset_headers_offset));
    const content_hashes: [*]align(1) u256 = @alignCast(@ptrCast(image.ptr + asset_content_hashes));

    var image_offset: usize = 0;

    const header = @as(*Header, @ptrCast(@alignCast(image.ptr)));
    image_offset += @sizeOf(Header);

    image_offset += assets.len * @sizeOf(u64);
    image_offset += assets.len * @sizeOf(u256);

    image_offset = std.mem.alignForward(usize, image_offset, @alignOf(AssetHeader));
    image_offset += assets.len * @sizeOf(AssetHeader);

    header.asset_count = @as(u32, @intCast(assets.len));
    //TODO: Allow this to be set to zero for distribution builds
    header.asset_content_hashes_count = @as(u32, @intCast(assets.len));

    var current_content_offset: usize = image_offset;

    for (assets, 0..) |asset, i| {
        const asset_header = &asset_headers[i];

        current_content_offset = std.mem.alignForward(usize, current_content_offset, asset.source_data_alignment);

        asset_header.source_data_size = @intCast(asset.source_data.len);
        asset_header.source_data_offset = @intCast(current_content_offset);
        asset_header.mapped_data_size = @intCast(asset.mapped_data_size);
        asset_header.mapped_data_alignment = 1;

        name_hashes[i] = hashAssetName(asset.name);
        content_hashes[i] = asset.content_hash;

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
        .asset_content_hashes = &.{},
    };

    var image_offset: usize = 0;

    const header = @as(*const Header, @ptrCast(@alignCast(image.ptr + image_offset))).*;

    image_offset += @sizeOf(Header);

    archive.asset_name_hashes = @as([*]u64, @ptrCast(@alignCast(image.ptr + image_offset)))[0..header.asset_count];
    image_offset += @sizeOf(u64) * header.asset_count;

    archive.asset_content_hashes = @as([*]align(1) u256, @ptrCast(@alignCast(image.ptr + image_offset)))[0..header.asset_content_hashes_count];
    image_offset += @sizeOf(u256) * header.asset_content_hashes_count;

    image_offset = std.mem.alignForward(usize, image_offset, @alignOf(AssetHeader));

    archive.assets = @as([*]AssetHeader, @ptrCast(@alignCast(image.ptr + image_offset)))[0..header.asset_count];
    image_offset += @sizeOf(AssetHeader) * header.asset_count;

    archive.asset_content = image[image_offset..];

    return archive;
}

pub fn decodeFree(self: *Archive, allocator: std.mem.Allocator) void {
    allocator.free(self.image);

    self.* = undefined;
}

pub fn decodeHeaderOnlyFromFile(
    allocator: std.mem.Allocator,
    file: std.fs.File,
) !Archive {
    var archive = Archive{
        .image = &.{},
        .assets = &.{},
        .asset_content = &.{},
        .asset_name_hashes = &.{},
        .asset_content_hashes = &.{},
    };

    const header = try file.reader().readStruct(Header);

    std.log.info("Read header: {}", .{header});

    var headers_size: usize = 0;

    headers_size += @sizeOf(Header);

    headers_size += @sizeOf(u64) * header.asset_count;
    headers_size += @sizeOf(u256) * header.asset_content_hashes_count;

    headers_size = std.mem.alignForward(usize, headers_size, @alignOf(AssetHeader));
    headers_size += @sizeOf(AssetHeader) * header.asset_count;

    //load the partial image that contains only heady data (no content)
    const image = try allocator.alignedAlloc(u8, @alignOf(Header), headers_size);
    errdefer allocator.free(image);

    archive.image = image;

    try file.seekTo(0);

    _ = try file.readAll(image);

    var image_offset: usize = 0;

    image_offset += @sizeOf(Header);

    archive.asset_name_hashes = @as([*]u64, @ptrCast(@alignCast(image.ptr + image_offset)))[0..header.asset_count];
    image_offset += @sizeOf(u64) * header.asset_count;

    archive.asset_content_hashes = @as([*]align(1) u256, @ptrCast(@alignCast(image.ptr + image_offset)))[0..header.asset_content_hashes_count];
    image_offset += @sizeOf(u256) * header.asset_content_hashes_count;

    image_offset = std.mem.alignForward(usize, image_offset, @alignOf(AssetHeader));

    archive.assets = @as([*]AssetHeader, @ptrCast(@alignCast(image.ptr + image_offset)))[0..header.asset_count];
    image_offset += @sizeOf(AssetHeader) * header.asset_count;

    std.debug.assert(image_offset == image.len);

    archive.asset_content = &.{};

    for (archive.asset_name_hashes) |name_hash| {
        std.log.info("asset_name_hash: 0x{x}", .{name_hash});
    }

    return archive;
}

///Returns null if the asset doesn't exist in the archive
pub fn getAssetIndexFromName(self: Archive, name: []const u8) ?usize {
    const hash = hashAssetName(name);

    //TODO: use some kind of bucket based table to allow for archives with very large numbers of assets
    return for (self.asset_name_hashes, 0..) |asset_name_hash, index| {
        std.log.info("getAssetIndex: testing hash 0x{x} against name: 0x{x}", .{ asset_name_hash, hash });

        if (hash == asset_name_hash) {
            break index;
        }
    } else null;
}

pub fn getAssetData(self: Archive, asset: AssetDescriptor) []u8 {
    const header = self.assets[@intFromEnum(asset)];

    return self.image[header.source_data_offset .. header.source_data_offset + header.source_data_size];
}

pub fn mapAssetDataFromFile(
    self: Archive,
    gpa: std.mem.Allocator,
    asset: AssetDescriptor,
    file_path: []const u8,
) ![]u8 {
    const asset_header = self.assets[@intFromEnum(asset)];

    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    //TODO: respect mapped_alignment
    const data = try gpa.alloc(u8, asset_header.mapped_data_size);
    errdefer gpa.free(data);

    @memset(data[asset_header.source_data_size..], 0);

    try file.seekTo(asset_header.source_data_offset);

    _ = try file.read(data);

    return data;
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

pub const base_hash = compiler.getBaseHashFromSource(struct {
    pub fn src() std.builtin.SourceLocation {
        return @src();
    }
}.src());

const Archive = @This();
const std = @import("std");
const compiler = @import("compiler.zig");
