//!Metadata files are zon files that describe parameters to the asset compiler for a given asset

pub fn load(comptime T: type, allocator: std.mem.Allocator, path: []const u8) !T {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const zon_source = try file.readToEndAllocOptions(allocator, std.math.maxInt(u32), null, @alignOf(u8), 0);
    defer allocator.free(zon_source);

    const data = try std.zon.parse.fromSlice(T, allocator, zon_source, null, .{});

    return data;
}

pub fn loadFree(comptime T: type, allocator: std.mem.Allocator, data: T) void {
    std.zon.parse.free(allocator, data);
}

const std = @import("std");
