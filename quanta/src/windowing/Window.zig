impl: Impl,

pub inline fn init(
    allocator: std.mem.Allocator,
    width: u16,
    height: u16,
    title: []const u8,
) !Window {
    var self = Window{
        .impl = try Impl.init(allocator, width, height, title),
    };

    return self;
}

pub inline fn deinit(self: *Window, allocator: std.mem.Allocator) void {
    defer self.* = undefined;
    defer self.impl.deinit(allocator);
}

pub inline fn pollEvents(self: *Window) !void {
    try self.impl.pollEvents();
}

pub inline fn shouldClose(self: *Window) bool {
    return self.impl.shouldClose();
}

pub inline fn getPosition(self: *Window) @Vector(2, u16) {
    _ = self;
    unreachable;
}

pub inline fn getBounds(self: *Window) @Vector(4, u16) {
    const pos = self.getPosition();
    const width = self.getWidth();
    const height = self.getHeight();

    return .{
        pos[0],
        pos[1],
        width,
        height,
    };
}

///Get the current width of the window
pub inline fn getWidth(self: *Window) u16 {
    return self.impl.getWidth();
}

///Get the current height of the window
pub inline fn getHeight(self: *Window) u16 {
    return self.impl.getHeight();
}

pub inline fn getKey(self: *Window, key: windowing.Key) windowing.Action {
    return self.impl.getKey(key);
}

pub inline fn getMouseButton(self: *Window, key: windowing.MouseButton) windowing.Action {
    return self.impl.getMouseButton(key);
}

pub inline fn getCursorPosition(self: *Window) @Vector(2, u16) {
    return self.impl.getCursorPosition();
}

///Implementation structure
pub const Impl = switch (windowing.backend) {
    .glfw => @import("glfw/GlfwWindow.zig"),
    .wayland => @compileError("Wayland not supported"),
    .xcb => @import("xcb/XcbWindow.zig"),
    .win32 => @compileError("Win32 not supported"),
};

test {
    std.testing.refAllDecls(@This());
}

const Window = @This();
const windowing = @import("../windowing.zig");
const std = @import("std");
