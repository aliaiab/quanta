const std = @import("std");
const glfw = @import("glfw");
const XcbWindow = @import("xcb/XcbWindow.zig");
const Window = @import("Window.zig");
const windowing = @import("../windowing.zig");

pub var window: glfw.Window = undefined;

pub var self: @This() = undefined;

width: u32,
height: u32,
real_window: Window,

key_actions: [std.meta.fields(windowing.Key).len]windowing.Action,

pub fn init(allocator: std.mem.Allocator, width: u16, height: u16, title: [:0]const u8) !void {
    self.width = width;
    self.height = height;
    self.real_window = try Window.init(allocator, width, height, title);

    std.log.info("window = {}", .{self.real_window});

    window = self.real_window.impl.glfw_window;
}

pub fn deinit(allocator: std.mem.Allocator) void {
    self.real_window.deinit(allocator);
}

pub fn shouldClose() bool {
    self.real_window.pollEvents() catch unreachable;

    return self.real_window.shouldClose();
}

pub fn getWidth() u32 {
    return self.real_window.getWidth();
}

pub fn getHeight() u32 {
    return self.real_window.getHeight();
}

pub fn getKeyDown(key: windowing.Key) bool {
    return self.real_window.getKey(key) == .press;
}

pub fn getMouseDown(button: windowing.MouseButton) bool {
    return self.real_window.getMouseButton(button) == .press;
}

pub fn getMousePos() [2]f32 {
    const pos = self.real_window.getCursorPosition();

    return .{ @as(f32, @floatFromInt(pos[0])), @as(f32, @floatFromInt(pos[1])) };
}
