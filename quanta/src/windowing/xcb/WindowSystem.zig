xcb_library: xcb_loader.Library,
connection: *xcb_loader.Connection,

pub fn init() !WindowSystem {
    var self = WindowSystem{
        .xcb_library = try xcb_loader.Library.load(),
        .connection = undefined,
    };

    self.connection = self.xcb_library.connect(null, null).?;
    errdefer self.xcb_library.disconnect(self.connection);

    return self;
}

pub fn deinit(self: *WindowSystem) void {
    self.xcb_library.disconnect(self.connection);
    self.xcb_library.unload();
}

pub fn createWindow(
    self: *WindowSystem,
    allocator: std.mem.Allocator,
    options: windowing.WindowSystem.CreateWindowOptions,
) !Window {
    return Window.init(
        allocator,
        self,
        options,
    );
}

test {}

const WindowSystem = @This();
const Window = @import("Window.zig");
const windowing = @import("../../windowing.zig");
const xcb_loader = @import("xcb_loader.zig");
const std = @import("std");
