glfw_window: glfw.Window,

pub fn init(
    allocator: std.mem.Allocator,
    width: u16,
    height: u16,
    title: []const u8,
) !GlfwWindow {
    const title_z = try allocator.dupeZ(u8, title);
    defer allocator.free(title_z);

    if (!glfw.init(.{})) {
        const glfw_error = glfw.getError().?.description;

        std.log.err("glfw error: {s}", .{glfw_error});

        return error.glfwFailure;
    }

    var self = GlfwWindow{
        .glfw_window = glfw.Window.create(
            width,
            height,
            title_z,
            null,
            null,
            .{
                .resizable = false,
                .client_api = .no_api,
            },
        ) orelse return error.CreationFailed,
    };

    return self;
}

pub fn deinit(self: *GlfwWindow, allocator: std.mem.Allocator) void {
    _ = allocator;
    defer self.* = undefined;
    defer self.glfw_window.destroy();
}

pub fn pollEvents(self: *GlfwWindow) !void {
    _ = self;
    glfw.pollEvents();
}

pub fn shouldClose(self: *GlfwWindow) bool {
    return self.glfw_window.shouldClose();
}

pub fn getKey(self: *GlfwWindow, key: windowing.Key) windowing.Action {
    const glfw_action = self.glfw_window.getKey(std.enums.nameCast(glfw.Key, key));

    return switch (glfw_action) {
        .release => .release,
        .press => .press,
        .repeat => .repeat,
    };
}

pub fn getMouseButton(self: *GlfwWindow, button: windowing.MouseButton) windowing.Action {
    const glfw_action = self.glfw_window.getMouseButton(switch (button) {
        .left => .left,
        .right => .right,
        .middle => .middle,
        .four => .four,
        .five => .five,
        .six => .six,
        .seven => .seven,
        .eight => .eight,
    });

    return switch (glfw_action) {
        .release => .release,
        .press => .press,
        .repeat => .repeat,
    };
}

///Get the current width of the window
pub fn getWidth(self: *GlfwWindow) u16 {
    return @intCast(self.glfw_window.getSize().width);
}

///Get the current height of the window
pub fn getHeight(self: *GlfwWindow) u16 {
    return @intCast(self.glfw_window.getSize().height);
}

pub inline fn getCursorPosition(self: *GlfwWindow) @Vector(2, u16) {
    const pos = self.glfw_window.getCursorPos();

    return .{
        @intFromFloat(pos.xpos),
        @intFromFloat(pos.ypos),
    };
}

const GlfwWindow = @This();
const std = @import("std");
const glfw = @import("glfw");
const windowing = @import("../../windowing.zig");
