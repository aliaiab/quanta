const Archive = @This();

const std = @import("std");

image: []u8,
assets: []AssetHeader,
name_buffer: []u8,
asset_content: []u8,

pub const Header = extern struct {
    asset_count: u32,
    name_buffer_size: u32,
};

pub const AssetDescriptor = enum(u32) { _ };

pub const AssetHeader = extern struct {
    source_data_offset: u32,
    source_data_size: u32,
    mapped_data_size: u32,
    mapped_data_alignment: u32,
    name_offset: u32,
};

pub const AssetMappedRegion = extern struct {};

pub const AssetDescription = struct {
    name: []const u8,
    source_data: []const u8,
    source_data_alignment: u32,
    mapped_data_size: usize,
};

pub const AssetLocation = struct {
    path: []const u8,
};

pub fn encode(allocator: std.mem.Allocator, assets: []const AssetDescription) ![]const u8 {
    var image_size: usize = @sizeOf(Header);

    image_size = std.mem.alignForward(usize, image_size, @alignOf(AssetHeader));
    image_size += @sizeOf(AssetHeader) * assets.len;

    var source_content_size: usize = 0;
    var name_buffer_size: usize = 0;

    for (assets) |asset| {
        const aligned_size = std.mem.alignForward(usize, source_content_size, asset.source_data_alignment);

        source_content_size = aligned_size + asset.source_data.len;

        name_buffer_size += asset.name.len + 1;
    }

    image_size += name_buffer_size + source_content_size;

    //Seems to be a 4 byte inconsistency somewhere....
    const image = try allocator.alignedAlloc(u8, @alignOf(Header), image_size + 4);
    errdefer allocator.free(image);

    //In order for builds to be reproducable, images must set padding bytes to a known value
    @memset(image, 0xaa);

    var image_offset: usize = 0;

    const header = @as(*Header, @ptrCast(@alignCast(image.ptr)));
    image_offset += @sizeOf(Header);

    image_offset = std.mem.alignForward(usize, image_offset, @alignOf(AssetHeader));

    const asset_header_offset = image_offset;

    image_offset += assets.len * @sizeOf(AssetHeader);

    var name_buffer_offset = image_offset;

    const name_buffer_start = name_buffer_offset;

    image_offset += name_buffer_size;

    header.asset_count = @as(u32, @intCast(assets.len));

    var current_content_offset: usize = image_offset;

    for (assets, 0..) |asset, i| {
        const asset_header = @as(*AssetHeader, @ptrCast(@alignCast(image.ptr + asset_header_offset + i * @sizeOf(AssetHeader))));

        current_content_offset = std.mem.alignForward(usize, current_content_offset, asset.source_data_alignment);

        asset_header.source_data_size = @as(u32, @intCast(asset.source_data.len));
        asset_header.source_data_offset = @as(u32, @intCast(current_content_offset));
        asset_header.mapped_data_size = @as(u32, @intCast(asset.mapped_data_size));
        asset_header.mapped_data_alignment = 1;
        asset_header.name_offset = @intCast(name_buffer_offset - name_buffer_start);

        @memcpy(image[name_buffer_offset .. name_buffer_offset + asset.name.len], asset.name);

        image[name_buffer_offset + asset.name.len] = 0;

        @memcpy(image[asset_header.source_data_offset .. asset_header.source_data_offset + asset.source_data.len], asset.source_data[0..]);

        current_content_offset += asset_header.source_data_size;

        name_buffer_offset += asset.name.len + 1;
    }

    header.name_buffer_size = @intCast(name_buffer_size);

    return image;
}

pub fn decode(allocator: std.mem.Allocator, image: []u8) !Archive {
    _ = allocator;

    var archive = Archive{
        .image = image,
        .assets = &.{},
        .name_buffer = &.{},
        .asset_content = &.{},
    };

    var image_offset: usize = 0;

    const header = @as(*const Header, @ptrCast(@alignCast(image.ptr + image_offset))).*;

    image_offset += @sizeOf(Header);

    image_offset = std.mem.alignForward(usize, image_offset, @alignOf(AssetHeader));

    archive.assets = @as([*]AssetHeader, @ptrCast(@alignCast(image.ptr + image_offset)))[0..header.asset_count];

    image_offset += @sizeOf(AssetHeader) * header.asset_count;

    archive.name_buffer = image[image_offset .. image_offset + header.name_buffer_size];

    image_offset += header.name_buffer_size;

    archive.asset_content = image[image_offset..];

    return archive;
}

pub fn getAssetData(self: Archive, asset: AssetDescriptor) []u8 {
    const header = self.assets[@intFromEnum(asset)];

    return self.image[header.source_data_offset .. header.source_data_offset + header.source_data_size - @sizeOf(u32)];
}

pub fn getAssetDataFromName(self: Archive, name: []const u8) []u8 {
    for (self.assets, 0..) |header, index| {
        const asset_name = std.mem.span(@as([*:0]u8, @ptrCast(self.name_buffer[header.name_offset..].ptr)));

        if (std.mem.eql(u8, asset_name, name)) {
            return self.getAssetData(@enumFromInt(index));
        }
    }

    unreachable;
}
