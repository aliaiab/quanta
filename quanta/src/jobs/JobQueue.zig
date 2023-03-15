const std = @import("std");

const JobQueue = @This();

pub const JobCommand = struct 
{
    memory_offset: u32,
    memory_size: u32,
    procedure: *const fn(self: *JobCommand) anyerror!void,
};

allocator: std.mem.Allocator,
commands: std.ArrayListUnmanaged(JobCommand),

pub fn init() !JobQueue
{
    var self = JobQueue 
    {
        .commands = .{},
    };

    return self;
}

pub fn deinit(self: *JobQueue) void 
{
    defer self.* = undefined;
}

pub fn enqueue(self: *JobQueue, command: JobCommand) void 
{
    self.commands.append(self.allocator, command) catch unreachable;
}

pub fn dequeue(self: *JobQueue) ?JobCommand
{
    self.commands.popOrNull();
} 