//!Windowing context which contains information about all windows created, monitors, cursors ect..

impl: Impl,

pub inline fn init() !WindowSystem {
    const self = WindowSystem{
        .impl = try Impl.init(),
    };

    return self;
}

pub inline fn deinit(self: *WindowSystem) void {
    self.impl.deinit();

    self.* = undefined;
}

pub inline fn createWindow(
    self: *WindowSystem,
    allocator: std.mem.Allocator,
    width: u16,
    height: u16,
    title: []const u8,
) !Window {
    const window = Window{
        .impl = try self.impl.createWindow(allocator, width, height, title),
    };

    return window;
}

///Implementation structure
const Impl = switch (windowing.backend) {
    .wayland => @compileError("Wayland not yet supported"),
    .xcb => @import("xcb/XcbWindowSystem.zig"),
    .win32 => @compileError("Win32 not yet supported"),
};

test {
    std.testing.refAllDecls(@This());
}

const WindowSystem = @This();
const Window = @import("Window.zig");
const windowing = @import("../windowing.zig");
const std = @import("std");
