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

///Creates and configures a new window, returning the window and its initial surface region
pub fn createWindow(
    self: *WindowSystem,
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
    options: CreateWindowOptions,
) !struct { Window, windowing.SurfaceRegion } {
    const backend_window, const surface_region = try self.impl.createWindow(
        arena,
        gpa,
        options,
    );

    return .{ .{ .impl = backend_window }, surface_region };
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
    .branch_wayland_xcb => @import("branch_wayland_xcb.zig").WindowSystem,
    .wayland => @import("wayland/WindowSystem.zig"),
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
const branch_backend = @import("branch_backend.zig");
const std = @import("std");
const quanta_options = @import("../root.zig").quanta_options;
