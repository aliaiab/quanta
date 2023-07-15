const std = @import("std");
const reflect = @import("../reflect/reflect.zig");
const Archive = @import("Archive.zig");

const AssetStorage = @This();

pub fn AssetPath(comptime T: ?type) type {
    _ = T;
    return struct {
        path: []const u8,
    };
}

pub fn Asset(comptime T: ?type) type {
    return packed struct(u64) {
        ///Index into the array of asset arrays
        type_index: u32 = std.math.maxInt(u32),
        ///Index into the asset array for this type
        index: u32 = std.math.maxInt(u32),

        pub const nil = Asset(T){};

        pub fn cast(self: @This(), comptime U: ?type) Asset(U) {
            return @as(Asset(U), @bitCast(self));
        }

        pub fn toUntyped(self: @This()) AssetUntyped {
            return self.cast(null);
        }
    };
}

pub const AssetUntyped = Asset(null);

pub const AssetArray = struct {
    ///Data is only allocated and populated when loaded
    data: std.ArrayListUnmanaged(u8) = .{},
    asset_count: u32 = 0,
    asset_size: u32,
    asset_alignment: u32,
};

pub const AssetLoadFn = fn (
    storage: *AssetStorage,
    handle: AssetUntyped,
    asset: *anyopaque,
    data: []u8,
) anyerror!void;

pub const AssetUnloadFn = fn (
    storage: *AssetStorage,
    handle: AssetUntyped,
    asset: *anyopaque,
) void;

pub fn assetLoadFn(comptime T: type) AssetLoadFn {
    const loadFn = T.assetLoad;

    const static = struct {
        fn function(storage: *AssetStorage, handle: AssetUntyped, asset: *anyopaque, data: []u8) anyerror!void {
            return @call(.always_inline, loadFn, .{
                storage,
                handle.cast(T),
                @as(*T, @ptrCast(@alignCast(asset))),
                data,
            });
        }
    };

    return static.function;
}

pub fn assetUnloadFn(comptime T: type) AssetUnloadFn {
    const unloadFn = T.assetUnload;

    const static = struct {
        fn function(storage: *AssetStorage, handle: AssetUntyped, asset: *anyopaque) void {
            return @call(.always_inline, unloadFn, .{
                storage,
                handle.cast(T),
                @as(*T, @ptrCast(@alignCast(asset))),
            });
        }
    };

    return static.function;
}

allocator: std.mem.Allocator,
archive: Archive,
asset_load_fns: std.ArrayListUnmanaged(*const AssetLoadFn) = .{},
asset_unload_fns: std.ArrayListUnmanaged(*const AssetUnloadFn) = .{},
asset_types: std.AutoHashMapUnmanaged(reflect.Type.Id, u32) = .{},
asset_arrays: std.ArrayListUnmanaged(AssetArray) = .{},
handle_count: u32 = 0,

pub fn init(allocator: std.mem.Allocator, archive: Archive) AssetStorage {
    return .{
        .allocator = allocator,
        .archive = archive,
    };
}

pub fn deinit(self: *AssetStorage) void {
    //Whether it's necessary to 'unload' assets is debatable
    //For debug purposes, we will do it, but we could also use an allocator that frees automatically like
    //an arena (or just let the os deal with it and not free at all, idk)
    for (self.asset_arrays.items, 0..) |*asset_array, type_index| {
        for (0..asset_array.asset_count) |asset_index| {
            const asset_pointer = asset_array.data.items.ptr + asset_index * asset_array.asset_size;

            self.asset_unload_fns.items[type_index](
                self,
                .{ .type_index = @truncate(type_index), .index = @truncate(asset_index) },
                asset_pointer,
            );
        }

        asset_array.data.deinit(self.allocator);
    }

    self.asset_load_fns.deinit(self.allocator);
    self.asset_unload_fns.deinit(self.allocator);
    self.asset_types.deinit(self.allocator);
    self.asset_arrays.deinit(self.allocator);

    self.* = undefined;
}

pub fn get(self: *AssetStorage, comptime T: type, asset: Asset(T)) ?*const T {
    const asset_array: *AssetArray = &self.asset_arrays.items[asset.type_index];

    const pointer = asset_array.data.items.ptr + asset.index * @sizeOf(T);

    return @as(*T, @ptrCast(@alignCast(pointer)));
}

pub fn create(self: *AssetStorage, comptime T: type) Asset(T) {
    const handle = self.nextHandle(T);

    const asset_type = handle.type_index;

    const asset_array: *AssetArray = &self.asset_arrays.items[asset_type];

    var asset: T = undefined;

    asset_array.data.appendSlice(self.allocator, std.mem.asBytes(&asset)) catch unreachable;

    self.handle_count += 1;

    return handle.cast(T);
}

pub fn load(self: *AssetStorage, comptime T: type, name: []const u8) Asset(T) {
    const handle = self.create(T);

    const data = @constCast(self.get(T, handle).?);

    //problem: getting asset descriptors from paths
    //solution: some kind of asset descriptor path table

    const asset_data = self.archive.getAssetDataFromName(name);

    //Ideally we would schedule this load function and the io loading itself to
    //another thread, but that requires a robust way to schedule jobs

    self.asset_load_fns.items[handle.type_index](self, handle.toUntyped(), data, asset_data) catch {
        //If the load function fails, then invalidate the handle somehow?
    };

    return handle;
}

pub fn unload(self: *AssetStorage, comptime T: type, asset: Asset(T)) void {
    const data = @constCast(self.get(T, asset).?);

    self.asset_unload_fns.items[asset.type_index](self, asset.toUntyped(), data);
}

fn nextHandle(self: *AssetStorage, comptime T: type) AssetUntyped {
    const asset_type = self.assetTypeIndex(T);

    const index = self.asset_arrays.items[asset_type].asset_count;

    defer self.asset_arrays.items[asset_type].asset_count += 1;

    return .{ .type_index = asset_type, .index = index };
}

fn assetTypeIndex(self: *AssetStorage, comptime T: type) u32 {
    const result = self.asset_types.getOrPut(self.allocator, reflect.Type.id(T)) catch unreachable;

    if (!result.found_existing) {
        const index = self.asset_arrays.items.len;

        self.asset_arrays.append(self.allocator, .{
            .asset_size = @sizeOf(T),
            .asset_alignment = @alignOf(T),
        }) catch unreachable;
        self.asset_load_fns.append(self.allocator, assetLoadFn(T)) catch unreachable;
        self.asset_unload_fns.append(self.allocator, assetUnloadFn(T)) catch unreachable;

        result.value_ptr.* = @intCast(index);
    }

    return result.value_ptr.*;
}
