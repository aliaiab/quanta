const std = @import("std");

const ThreadPool = @This();

threads: []std.Thread,

pub fn init() !ThreadPool 
{
    var self = ThreadPool
    {
        .threads = &.{},
    };

    return self;
}

pub fn deinit(self: *ThreadPool) void 
{
    defer self.* = undefined;
}