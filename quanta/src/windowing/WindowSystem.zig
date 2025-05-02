//!Windowing context which contains information about all windows created, monitors, cursors ect..

impl: Impl,

pub fn init() !WindowSystem {
    const self = WindowSystem{
        .impl = try Impl.init(),
    };

    return self;
}

pub fn deinit(self: *WindowSystem) void {
    self.impl.deinit();

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
    gpa: std.mem.Allocator,
    options: CreateWindowOptions,
) !Window {
    const window = Window{
        .impl = try self.impl.createWindow(
            gpa,
            options,
        ),
    };

    return window;
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
