surface: vk.SurfaceKHR,
window: *windowing.Window,

pub fn init(window: *windowing.Window) !WindowSurface {
    var self = WindowSurface{
        .surface = .null_handle,
        .window = window,
    };

    switch (quanta_options.windowing.preferred_backend) {
        .xcb => {
            self.surface = try Context.self.vki.createXcbSurfaceKHR(Context.self.instance, &vk.XcbSurfaceCreateInfoKHR{
                .connection = @ptrCast(window.impl.connection),
                .window = @intFromEnum(window.impl.window),
            }, Context.self.allocation_callbacks);
        },
        else => @compileError("Backend unsupported"),
    }

    return self;
}

pub fn deinit(self: *WindowSurface) void {
    defer self.* = undefined;
    defer Context.self.vki.destroySurfaceKHR(Context.self.instance, self.surface, Context.self.allocation_callbacks);
}

const WindowSurface = @This();
const std = @import("std");
const windowing = @import("../windowing.zig");
const Context = @import("Context.zig");
const vk = @import("vulkan");
const quanta_options = @import("../root.zig").quanta_options;
