///Calculates the appropriate number of mip levels for the given image dimensions
pub fn getMipLevelCount(
    width: u32,
    height: u32,
) u32 {
    const width_f32: f32 = @floatFromInt(width);
    const height_f32: f32 = @floatFromInt(height);

    return @intFromFloat(@floor(@log2(@max(width_f32, height_f32)) + 1));
}

///Generates a mip chain for the given image
///Must be placed in an external transfer pass
pub fn generateMipChain(
    g: *graph.Builder,
    image: *graph.Image,
) void {
    const width = g.imageGetWidth(image.*);
    const height = g.imageGetHeight(image.*);

    const level_count = getMipLevelCount(width, height);

    var mip_width = width;
    var mip_height = height;

    for (1..level_count) |mip_index| {
        // g.beginTransferPass(@src());
        // defer g.endTransferPass();

        g.blitImage(image.*, image, .{
            .src_subresource = .{
                .mip_level = @intCast(mip_index - 1),
                .base_array_layer = 0,
                .layer_count = 1,
            },
            .src_extent = .{
                @intCast(mip_width),
                @intCast(mip_height),
                1,
            },
            .dst_subresource = .{
                .mip_level = @intCast(mip_index),
                .base_array_layer = 0,
                .layer_count = 1,
            },
            .dst_extent = .{
                @intCast(if (mip_width > 1) mip_width / 2 else 1),
                @intCast(if (mip_height > 1) mip_height / 2 else 1),
                1,
            },
        }, .linear);

        if (mip_width > 1) mip_width /= 2;
        if (mip_height > 1) mip_height /= 2;
    }
}

test {
    _ = std.testing.refAllDecls(@This());
}

const graph = @import("../graph.zig");
const std = @import("std");
