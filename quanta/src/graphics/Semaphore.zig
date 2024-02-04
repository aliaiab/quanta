handle: vk.Semaphore,

pub fn init() !Semaphore {
    var self = Semaphore{
        .handle = .null_handle,
    };

    var create_semaphore_type: vk.SemaphoreTypeCreateInfo = .{
        .semaphore_type = vk.SemaphoreType.timeline,
        .initial_value = 0,
    };

    self.handle = try Context.self.vkd.createSemaphore(
        Context.self.device,
        &.{
            .p_next = &create_semaphore_type,
            .flags = .{},
        },
        &Context.self.allocation_callbacks,
    );
    errdefer Context.self.vkd.destroySemaphore(Context.self.device, self.handle, &Context.self.allocation_callbacks);

    return self;
}

///Legacy feature for use in wsi
pub fn initBinary() !Semaphore {
    var self = Semaphore{
        .handle = .null_handle,
    };

    const create_semaphore_type: vk.SemaphoreTypeCreateInfo = .{
        .semaphore_type = vk.SemaphoreType.binary,
        .initial_value = 0,
    };
    _ = create_semaphore_type;

    self.handle = try Context.self.vkd.createSemaphore(
        Context.self.device,
        &.{
            // .p_next = &create_semaphore_type,
            .flags = .{},
        },
        Context.self.allocation_callbacks,
    );
    errdefer Context.self.vkd.destroySemaphore(Context.self.device, self.handle, Context.self.allocation_callbacks);

    return self;
}

pub fn deinit(self: *Semaphore) void {
    defer self.* = undefined;

    Context.self.vkd.destroySemaphore(Context.self.device, self.handle, Context.self.allocation_callbacks);
}

pub fn signal(self: Semaphore, value: u64) void {
    Context.self.vkd.signalSemaphore(Context.self.device, &vk.SemaphoreSignalInfo{
        .semaphore = self.handle,
        .value = value,
    }) catch @panic("signalSemaphore failed!");
}

pub fn wait(self: Semaphore, value: u64) void {
    _ = Context.self.vkd.waitSemaphores(Context.self.device, &vk.SemaphoreWaitInfo{
        .p_semaphores = @ptrCast(&self.handle),
        .semaphore_count = 1,
        .p_values = @ptrCast(&value),
    }, std.math.maxInt(u64)) catch unreachable;
}

const std = @import("std");
const vk = @import("vk.zig");
const Context = @import("Context.zig");
const Semaphore = @This();
