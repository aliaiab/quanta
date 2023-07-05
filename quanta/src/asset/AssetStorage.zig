const std = @import("std");

const AssetStorage = @This();

pub fn Asset(comptime T: ?type) type {
    return struct {
        handle: u64,

        pub const nil = Asset(T){ .handle = std.math.maxInt(u64) };
    };
}

pub const AssetUntyped = Asset(null);

const Image = struct {};

const ImageHndl = Asset(Image);

pub const Residency = enum {
    resident,
    vacant,
};

pub const AssetArray = struct {
    data: []const u8,
    asset_count: u32,
};

asset_arrays: std.ArrayListUnmanaged(AssetArray),
handles: []AssetUntyped,
handle_residencies: []Residency,

pub fn getResidency(comptime T: type, asset: Asset(T)) Residency {
    _ = asset;
}

pub fn get(comptime T: type, asset: Asset(T)) ?*const T {
    _ = asset;
    return null;
}

pub fn create(self: AssetStorage, comptime T: type) Asset(T) {
    _ = self;
    return Asset(T).nil;
}

pub fn load(self: AssetStorage, comptime T: type, path: []const u8) Asset(T) {
    _ = path;

    const ingot_img = self.load(Image, "minecraft:item/iron_ingot.png");
    _ = ingot_img;
}

pub fn unload(self: AssetStorage, comptime T: type, asset: Asset(T)) void {
    _ = asset;
    _ = self;
}
