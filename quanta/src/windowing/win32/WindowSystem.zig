instance: win32.foundation.HINSTANCE,
///Find a better way using indices? Handles?
window_states: std.AutoArrayHashMapUnmanaged(win32.foundation.HWND, Window.State) = .{},

pub fn init() !WindowSystem {
    const self: WindowSystem = .{
        //According to the docs, passing in null returns the instance of the currently loaded exe
        .instance = win32.system.library_loader.GetModuleHandleA(null) orelse return error.FailedToLoadModuleHandle,
    };

    return self;
}

pub fn deinit(self: *WindowSystem) void {
    self.* = undefined;
}

pub fn createWindow(
    self: *WindowSystem,
    gpa: std.mem.Allocator,
    options: windowing.WindowSystem.CreateWindowOptions,
) !Window {
    log.info("Creating win32 window! {}", .{options});

    var window: Window = undefined;

    try window.init(self, gpa, options);

    return window;
}

const WindowSystem = @This();
const Window = @import("Window.zig");
const std = @import("std");
const windowing = @import("../../windowing.zig");
const log = @import("../../log.zig").log;
const win32 = @import("win32");

test {
    _ = std.testing.refAllDecls(@This());
}
