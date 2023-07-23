const std = @import("std");
const glfw = @import("glfw");
const XcbWindow = @import("xcb/XcbWindow.zig");

pub var window: glfw.Window = undefined;

var self: @This() = undefined;

width: u32,
height: u32,
xcb_window: XcbWindow,

pub fn init(width: u32, height: u32, title: [:0]const u8) !void {
    if (!glfw.init(.{})) return error.glfwFailure;

    self.width = width;
    self.height = height;
    self.xcb_window = try XcbWindow.init();

    window = glfw.Window.create(width, height, title.ptr, null, null, .{
        .client_api = .no_api,
        .resizable = false,
    }) orelse return error.glfwFailure;
}

pub fn deinit() void {
    window.destroy();
    glfw.terminate();
    self.xcb_window.deinit();
}

pub fn shouldClose() bool {
    self.xcb_window.pollEvents();

    glfw.pollEvents();

    return window.shouldClose();
}

pub fn getWidth() u32 {
    return self.width;
}

pub fn getHeight() u32 {
    return self.height;
}

pub fn getKeyDown(key: glfw.Key) bool {
    return window.getKey(key) == .press;
}

pub fn getMouseDown(button: glfw.MouseButton) bool {
    return window.getMouseButton(button) == glfw.Action.press;
}

pub fn getMousePos() [2]f32 {
    const pos = window.getCursorPos();

    return .{ @as(f32, @floatCast(pos.xpos)), @as(f32, @floatCast(pos.ypos)) };
}
