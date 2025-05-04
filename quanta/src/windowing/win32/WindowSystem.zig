instance: win32.foundation.HINSTANCE,
///Find a better way using indices? Handles?
window_states: std.AutoArrayHashMapUnmanaged(win32.foundation.HWND, Window.State) = .{},

pub fn init(
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
) !WindowSystem {
    _ = gpa; // autofix
    _ = arena; // autofix
    const self: WindowSystem = .{
        //According to the docs, passing in null returns the instance of the currently loaded exe
        .instance = win32.system.library_loader.GetModuleHandleA(null) orelse return error.FailedToLoadModuleHandle,
    };

    return self;
}

pub fn deinit(
    self: *WindowSystem,
    gpa: std.mem.Allocator,
) void {
    _ = gpa; // autofix
    self.* = undefined;
}

pub fn createWindow(
    self: *WindowSystem,
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
    options: windowing.WindowSystem.CreateWindowOptions,
) !Window {
    var window: Window = undefined;

    try window.init(self, arena, gpa, options);

    return window;
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

test {
    _ = std.testing.refAllDecls(@This());
}

const WindowSystem = @This();
const Window = @import("Window.zig");
const std = @import("std");
const windowing = @import("../../windowing.zig");
const log = @import("../../log.zig").log;
const win32 = @import("win32");
