const std = @import("std");
const glfw = @import("glfw");

pub var window: glfw.Window = undefined;

var self: @This() = undefined;

width: u32,
height: u32,

pub fn init(width: u32, height: u32, title: [:0]const u8) !void 
{
    if (!glfw.init(.{})) return error.glfwFailure;

    self.width = width;
    self.height = height;

    window = glfw.Window.create(width, height, title.ptr, null, null, .{ 
        .client_api = .no_api,
        .resizable = false,
    }) orelse return error.glfwFailure;
}

pub fn deinit() void 
{
    window.destroy();
    glfw.terminate();
}

pub fn shouldClose() bool 
{
    glfw.pollEvents();

    return window.shouldClose();
}

pub fn getWidth() u32
{
    return self.width;
}

pub fn getHeight() u32
{
    return self.height;
}

pub fn getKeyDown(key: glfw.Key) bool 
{
    return window.getKey(key) == .press;
}

pub fn getMouseDown(button: glfw.MouseButton) bool
{
    return window.getMouseButton(button) == glfw.Action.press;
}

pub fn getMousePos() [2]f32
{
    const pos = window.getCursorPos();

    return .{ @floatCast(f32, pos.xpos), @floatCast(f32, pos.ypos) };
}