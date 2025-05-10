xcb_library: xcb_loader.Library,
xcb_xinput_library: xcb_xinput_loader.Library,
xkbcommon_library: xkbcommon_loader.Library,
connection: *xcb_loader.Connection,

pub fn init(
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
) !WindowSystem {
    _ = gpa; // autofix
    _ = arena; // autofix
    var self = WindowSystem{
        .xcb_library = try xcb_loader.Library.load(),
        .xkbcommon_library = try xkbcommon_loader.load(),
        .xcb_xinput_library = try xcb_xinput_loader.load(),
        .connection = undefined,
    };

    self.connection = self.xcb_library.connect(null, null).?;
    errdefer self.xcb_library.disconnect(self.connection);

    return self;
}

pub fn deinit(
    self: *WindowSystem,
    gpa: std.mem.Allocator,
) void {
    _ = gpa; // autofix
    self.xcb_library.disconnect(self.connection);
    self.xcb_library.unload();
    self.xcb_xinput_library.unload();
    self.xkbcommon_library.unload();
}

pub fn createWindow(
    self: *WindowSystem,
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
    options: windowing.WindowSystem.CreateWindowOptions,
) !struct { Window, windowing.SurfaceRegion } {
    return Window.init(
        arena,
        gpa,
        self,
        options,
    );
}

pub fn destroyWindow(
    self: *WindowSystem,
    window: *Window,
    gpa: std.mem.Allocator,
) void {
    _ = self; // autofix
    return window.deinit(
        gpa,
    );
}

const WindowSystem = @This();
const Window = @import("Window.zig");
const windowing = @import("../../windowing.zig");
const xcb_loader = @import("xcb_loader.zig");
const xcb_xinput_loader = @import("xcb_xinput_loader.zig");
const xkbcommon_loader = @import("../common/xkbcommon_loader.zig");
const std = @import("std");
