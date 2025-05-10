window_system: *WindowSystem,
toplevel: *xdg.Toplevel,
surface: *wl.Surface,
xdg_surface: *xdg.Surface,
listener_state: *ListenerState,

pub fn pollEvents(
    self: *Window,
    out_input: *input.State,
    out_viewport: *input.Viewport,
    out_surface_region: *windowing.SurfaceRegion,
) !void {
    _ = out_input; // autofix
    if (self.window_system.display.roundtrip() != .SUCCESS) return error.RoundtripFailed;

    out_viewport.width = @intCast(self.listener_state.width);
    out_viewport.height = @intCast(self.listener_state.height);

    out_surface_region.width = @intCast(self.listener_state.width);
    out_surface_region.height = @intCast(self.listener_state.height);
}

pub fn shouldClose(self: *Window) bool {
    return !self.listener_state.running;
}

pub fn captureCursor(self: *Window) void {
    _ = self; // autofix
}

pub fn uncaptureCursor(self: *Window) void {
    _ = self; // autofix
}

pub fn isCursorCaptured(self: Window) bool {
    _ = self; // autofix
    return false;
}

pub fn hideCursor(self: *Window) void {
    _ = self; // autofix
}

pub fn unhideCursor(self: *Window) void {
    _ = self; // autofix
}

pub fn isCursorHidden(self: Window) bool {
    _ = self; // autofix
    return false;
}

pub fn isFocused(self: Window) bool {
    _ = self; // autofix
    return true;
}

pub fn getUtf8Input(self: Window) []const u8 {
    _ = self; // autofix
    return &.{};
}

pub const ListenerState = struct {
    surface: *wl.Surface,
    running: bool,

    width: i32 = -1,
    height: i32 = -1,
};

pub fn xdgSurfaceListener(xdg_surface: *xdg.Surface, event: xdg.Surface.Event, state: *ListenerState) void {
    switch (event) {
        .configure => |configure| {
            xdg_surface.ackConfigure(configure.serial);
            state.surface.commit();
        },
    }
}

pub fn xdgToplevelListener(_: *xdg.Toplevel, event: xdg.Toplevel.Event, state: *ListenerState) void {
    switch (event) {
        .configure => |configure| {
            state.width = configure.width;
            state.height = configure.height;
        },
        .close => state.running = false,
    }
}

const Window = @This();
const WindowSystem = @import("WindowSystem.zig");
const xdg = wayland.client.xdg;
const wl = wayland.client.wl;
const wayland = @import("wayland");
const input = @import("../../input.zig");
const windowing = @import("../../windowing.zig");
const std = @import("std");
