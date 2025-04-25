const Buffer = @This();

const std = @import("std");
const vk = @import("vulkan");
const Context = @import("Context.zig");
const CommandBuffer = @import("CommandBuffer.zig");

handle: vk.Buffer,
memory: Context.BufferMemory,
size: usize,
alignment: usize,
usage: Usage,
device_address: usize,
///This needs to be sized to fit descriptors from all platforms
descriptor: u128,

pub const Usage = enum {
    vertex,
    index,
    uniform,
    storage,
    indirect,
    staging,
};

pub fn initData(comptime T: type, data: []const T, usage: Usage) !Buffer {
    if (usage == .staging) {
        const use_host_memory = false;

        if (use_host_memory and std.mem.isAligned(@intFromPtr(data.ptr), 0b1000)) {
            const buffer = try initDataHostMemory(.staging, @as([*]const u8, @ptrCast(data.ptr))[0 .. data.len * @sizeOf(T)]);

            return buffer;
        } else {
            var buffer = try init(data.len * @sizeOf(T), .staging);
            errdefer buffer.deinit();

            const mapped = try buffer.map(T);
            defer buffer.unmap();

            @memcpy(mapped, data);

            // @memcpy(@as([*]u8, @ptrCast(mapped.ptr)), @as([*]const u8, @ptrCast(data.ptr)), buffer.size);

            return buffer;
        }
    } else {
        var staging = try initData(T, data, .staging);
        defer staging.deinit();

        var buffer = try init(data.len * @sizeOf(T), usage);
        errdefer buffer.deinit();

        var command_buffer = try CommandBuffer.init(.transfer);
        defer command_buffer.deinit();

        {
            try command_buffer.begin();
            defer command_buffer.end();

            command_buffer.copyBuffer(staging, 0, staging.size, buffer, 0, buffer.size);
        }

        try command_buffer.submitAndWait();

        return buffer;
    }
}

pub fn init(size: usize, usage: Usage) !Buffer {
    var self = Buffer{
        .handle = .null_handle,
        .memory = undefined,
        .size = size,
        .alignment = 0,
        .usage = usage,
        .device_address = undefined,
        .descriptor = 0,
    };

    log.info("Initing buffer!! {}", .{size});

    const create_info = vk.BufferCreateInfo{
        .flags = .{},
        .size = size,
        .usage = switch (usage) {
            .vertex => .{
                .vertex_buffer_bit = true,
                .storage_buffer_bit = true,
                .transfer_dst_bit = true,
                .shader_device_address_bit = true,
            },
            .index => .{
                .index_buffer_bit = true,
                .storage_buffer_bit = true,
                .transfer_dst_bit = true,
                .shader_device_address_bit = true,
            },
            .uniform => .{
                .uniform_buffer_bit = true,
                .transfer_dst_bit = true,
                .shader_device_address_bit = true,
            },
            .storage => .{
                .storage_buffer_bit = true,
                .transfer_dst_bit = true,
                .shader_device_address_bit = true,
            },
            .indirect => .{
                .indirect_buffer_bit = true,
                .storage_buffer_bit = true,
                .transfer_dst_bit = true,
                .shader_device_address_bit = true,
            },
            .staging => .{
                .transfer_src_bit = true,
                .shader_device_address_bit = true,
            },
        },
        .sharing_mode = .exclusive,
        .queue_family_index_count = 0,
        .p_queue_family_indices = undefined,
    };

    self.handle = try Context.self.vkd.createBuffer(Context.self.device, &create_info, Context.self.allocation_callbacks);
    errdefer Context.self.vkd.destroyBuffer(Context.self.device, self.handle, Context.self.allocation_callbacks);

    var memory_requirements: vk.MemoryRequirements2 = .{
        .memory_requirements = undefined,
    };

    Context.self.vkd.getBufferMemoryRequirements2(Context.self.device, &vk.BufferMemoryRequirementsInfo2{
        .buffer = self.handle,
    }, &memory_requirements);

    self.alignment = memory_requirements.memory_requirements.alignment;

    self.memory = try Context.deviceAllocateBuffer(self.handle, switch (usage) {
        .staging => .{
            .host_visible_bit = true,
            .host_coherent_bit = true,
        },
        .vertex,
        .index,
        => .{
            .device_local_bit = true,
        },
        .storage, .uniform => .{
            .host_visible_bit = true,
            .device_local_bit = true,
        },
        .indirect => .{
            .host_visible_bit = true,
            .host_coherent_bit = true,
            .device_local_bit = true,
        },
    });
    errdefer Context.deviceFree(self.memory.memory);

    self.device_address = Context.self.vkd.getBufferDeviceAddress(
        Context.self.device,
        &vk.BufferDeviceAddressInfo{
            .buffer = self.handle,
        },
    );

    if (false)
        Context.self.vkd.getDescriptorEXT(
            Context.self.device,
            &vk.DescriptorGetInfoEXT{
                .type = switch (self.usage) {
                    .vertex, .index, .storage => .storage_buffer,
                    .uniform => .uniform_buffer,
                    else => .storage_buffer,
                },
                .data = .{
                    .p_storage_buffer = &.{
                        .address = self.device_address,
                        .range = self.size,
                        .format = .undefined,
                    },
                },
            },
            @sizeOf(@TypeOf(self.descriptor)),
            &self.descriptor,
        );

    return self;
}

pub fn initUsageFlags(size: usize, usage: vk.BufferUsageFlags) !Buffer {
    var self = Buffer{
        .handle = .null_handle,
        .memory = undefined,
        .size = size,
        .alignment = 0,
        .usage = .storage,
        .device_address = undefined,
        .descriptor = 0,
    };

    const create_info = vk.BufferCreateInfo{
        .flags = .{},
        .size = size,
        .usage = usage,
        .sharing_mode = .exclusive,
        .queue_family_index_count = 0,
        .p_queue_family_indices = undefined,
    };

    self.handle = try Context.self.vkd.createBuffer(
        Context.self.device,
        &create_info,
        Context.self.allocation_callbacks,
    );
    errdefer Context.self.vkd.destroyBuffer(Context.self.device, self.handle, Context.self.allocation_callbacks);

    var memory_requirements: vk.MemoryRequirements2 = .{
        .memory_requirements = undefined,
    };

    Context.self.vkd.getBufferMemoryRequirements2(Context.self.device, &vk.BufferMemoryRequirementsInfo2{
        .buffer = self.handle,
    }, &memory_requirements);

    self.alignment = memory_requirements.memory_requirements.alignment;

    self.memory = try Context.deviceAllocateBuffer(self.handle, .{
        .device_local_bit = true,
    });
    errdefer Context.deviceFree(self.memory);

    if (false) {
        self.device_address = Context.self.vkd.getBufferDeviceAddress(
            Context.self.device,
            &vk.BufferDeviceAddressInfo{
                .buffer = self.handle,
            },
        );
    }

    if (false)
        Context.self.vkd.getDescriptorEXT(
            Context.self.device,
            &vk.DescriptorGetInfoEXT{
                .type = switch (self.usage) {
                    .vertex, .index, .storage => .storage_buffer,
                    .uniform => .uniform_buffer,
                    else => .storage_buffer,
                },
                .data = .{
                    .p_storage_buffer = &.{
                        .address = self.device_address,
                        .range = self.size,
                        .format = .undefined,
                    },
                },
            },
            @sizeOf(@TypeOf(self.descriptor)),
            &self.descriptor,
        );

    return self;
}

fn initDataHostMemory(usage: Usage, host_memory: []const u8) !Buffer {
    std.debug.assert(@intFromPtr(host_memory.ptr) % 0b1000 == 0);

    var self = Buffer{
        .handle = .null_handle,
        .memory = .null_handle,
        .size = host_memory.len,
        .alignment = 0,
        .usage = usage,
    };

    const create_info = vk.BufferCreateInfo{
        .flags = .{},
        .size = host_memory.len,
        .usage = switch (usage) {
            .vertex => .{ .vertex_buffer_bit = true, .storage_buffer_bit = true, .transfer_dst_bit = true },
            .index => .{ .index_buffer_bit = true, .storage_buffer_bit = true, .transfer_dst_bit = true },
            .uniform => .{ .uniform_buffer_bit = true, .transfer_dst_bit = true },
            .storage => .{
                .storage_buffer_bit = true,
                .transfer_dst_bit = true,
            },
            .indirect_draw => .{
                .indirect_buffer_bit = true,
                .storage_buffer_bit = true,
                .transfer_dst_bit = true,
            },
            .staging => .{ .transfer_src_bit = true },
        },
        .sharing_mode = .exclusive,
        .queue_family_index_count = 0,
        .p_queue_family_indices = undefined,
    };

    self.handle = try Context.self.vkd.createBuffer(Context.self.device, &create_info, Context.self.allocation_callbacks);
    errdefer Context.self.vkd.destroyBuffer(Context.self.device, self.handle, Context.self.allocation_callbacks);

    self.alignment = 0;

    self.memory = try Context.deviceAllocateHostMemory(.{ .host_visible_bit = true, .host_coherent_bit = true, .host_cached_bit = true }, //vk.MemoryPropertyFlags
        host_memory);
    errdefer Context.self.vkd.freeMemory(Context.self.device, self.memory, Context.self.allocation_callbacks);

    try Context.self.vkd.bindBufferMemory(Context.self.device, self.handle, self.memory, 0);

    return self;
}

pub fn deinit(self: *Buffer) void {
    defer self.* = undefined;

    defer Context.self.vkd.destroyBuffer(Context.self.device, self.handle, Context.self.allocation_callbacks);
    defer Context.deviceFree(self.memory.memory);
}

pub fn map(self: Buffer, comptime T: type) ![]T {
    return Context.deviceMapBuffer(self.memory, T, self.size / @sizeOf(T));
}

pub fn unmap(self: Buffer) void {
    _ = self; // autofix
}

pub fn update(self: Buffer, comptime T: type, offset: usize, data: []const T) !void {
    var staging = try initData(T, data, .staging);
    defer staging.deinit();

    var command_buffer = try CommandBuffer.init(.graphics);
    defer command_buffer.deinit();

    {
        try command_buffer.begin();
        defer command_buffer.end();

        command_buffer.copyBuffer(staging, 0, staging.size, self, offset, self.size);
    }

    try command_buffer.submitAndWait();
}

///Does nothing in OptimizeMode.Debug
pub fn debugSetName(self: Buffer, name: []const u8) void {
    if (!Context.enable_debug_labels) return;

    var name_buffer: [1024]u8 = undefined;

    const name_z = std.fmt.bufPrintZ(&name_buffer, "{s}", .{name}) catch unreachable;

    Context.self.vkd.setDebugUtilsObjectNameEXT(Context.self.device, &.{
        .object_type = .buffer,
        .object_handle = @intFromEnum(self.handle),
        .p_object_name = name_z,
    }) catch unreachable;
}

test {}

const log = @import("../log.zig").log;
