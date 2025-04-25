pub const File = enum(u64) {
    nil = std.math.maxInt(u64),
    _,
};

pub const ReadResult = struct {};

pub const OpenError = error{
    FileNotFound,
};

pub const VTable = struct {
    openFile: *const fn (path: []const u8) OpenError!File,
    closeFile: *const fn (file: File) void,
    read: *const fn (
        offset: usize,
        size: usize,
    ) void,
};

const std = @import("std");
