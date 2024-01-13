surface: vk.SurfaceKHR,

pub fn init(window: windowing.Window) !WindowSurface {
    var self = WindowSurface{
        .surface = .null_handle,
    };

    switch (windowing.backend) {
        .glfw => {
            // _ = glfw.createWindowSurface(
            //     self.instance,
            //     window.window,
            //     @as(?*vk.AllocationCallbacks, @ptrCast(&self.allocation_callbacks)),
            //     &self.surface,
            // );
        },
        .xcb => {
            self.surface = try Context.self.vki.createXcbSurfaceKHR(Context.self.instance, &vk.XcbSurfaceCreateInfoKHR{
                .connection = @ptrCast(window.self.real_window.impl.connection),
                .window = window.self.real_window.impl.window,
            }, &Context.self.allocation_callbacks);
        },
        else => @compileError("Backend unsupported"),
    }

    return self;
}

pub fn deinit(self: *WindowSurface) void {
    defer self.* = undefined;
    defer Context.self.vki.destroySurfaceKHR(Context.self.instance, self.surface, &Context.self.allocation_callbacks);
}

const WindowSurface = @This();
const std = @import("std");
const windowing = @import("../windowing.zig");
// const glfw = @import("glfw");
const Context = @import("Context.zig");
const vk = @import("vk.zig");
