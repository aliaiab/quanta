//! Represents a windowing context from which windows can be created.
//! It is a logical connection to the underlying operating system window manager

impl: Impl,

pub fn init(
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
) !WindowSystem {
    const self = WindowSystem{
        .impl = try Impl.init(arena, gpa),
    };

    return self;
}

pub fn deinit(self: *WindowSystem, gpa: std.mem.Allocator) void {
    self.impl.deinit(gpa);

    self.* = undefined;
}

pub const CreateWindowOptions = struct {
    ///A hint to indicate to the window system how wide the window should be
    preferred_width: ?u16 = null,
    ///A hint to indicate to the window system how tall the window should be
    preferred_height: ?u16 = null,
    ///A static title which names this window
    title: []const u8,
};

pub fn createWindow(
    self: *WindowSystem,
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
    options: CreateWindowOptions,
) !Window {
    const window = Window{
        .impl = try self.impl.createWindow(
            arena,
            gpa,
            options,
        ),
    };

    return window;
}

pub fn destroyWindow(
    self: *WindowSystem,
    window: *Window,
    gpa: std.mem.Allocator,
) void {
    return self.impl.destroyWindow(&window.impl, gpa);
}

///Implementation structure
const Impl = switch (quanta_options.windowing.preferred_backend) {
    .wayland => @compileError("Wayland not yet supported"),
    .xcb => @import("xcb/WindowSystem.zig"),
    .win32 => @import("win32/WindowSystem.zig"),
};

test {
    std.testing.refAllDecls(@This());

    _ = Impl;
}

const WindowSystem = @This();
const Window = @import("Window.zig");
const windowing = @import("../windowing.zig");
const std = @import("std");
const quanta_options = @import("../root.zig").quanta_options;
