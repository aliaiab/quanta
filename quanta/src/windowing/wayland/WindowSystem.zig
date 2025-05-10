display: *wl.Display,
registry: *wl.Registry,
compositor: *wl.Compositor,
wm_base: *xdg.WmBase,
seat: *wl.Seat,
decoration_manager: ?*zxdg.DecorationManagerV1,

pub fn init(
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
) !WindowSystem {
    _ = arena; // autofix
    _ = gpa; // autofix

    const display = try wl.Display.connect(null);
    const registry = try display.getRegistry();

    var registry_context: RegistryHandlerContext = undefined;

    registry.setListener(*RegistryHandlerContext, &registryListener, &registry_context);

    if (display.roundtrip() != .SUCCESS) return error.RoundtripFailed;

    if (registry_context.compositor == null) {
        return error.CompositorNull;
    }

    if (registry_context.wm_base == null) {
        return error.WmBaseNull;
    }

    registry_context.seat.?.setListener(?*anyopaque, &seatListener, null);

    return .{
        .display = display,
        .registry = registry,
        .compositor = registry_context.compositor.?,
        .wm_base = registry_context.wm_base.?,
        .seat = registry_context.seat.?,
        .decoration_manager = registry_context.decoration_manager,
    };
}

pub fn deinit(self: *WindowSystem, gpa: std.mem.Allocator) void {
    _ = gpa; // autofix

    if (self.decoration_manager) |decoration_manager| {
        decoration_manager.destroy();
    }

    self.seat.destroy();
    self.wm_base.destroy();
    self.compositor.destroy();
    self.registry.destroy();
    self.display.disconnect();

    self.* = undefined;
}

pub fn createWindow(
    self: *WindowSystem,
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
    options: CreateWindowOptions,
) !struct { Window, windowing.SurfaceRegion } {
    _ = gpa; // autofix

    const surface = try self.compositor.createSurface();

    const xdg_surface = try self.wm_base.getXdgSurface(surface);

    const toplevel = try xdg_surface.getToplevel();

    const listener_state = try arena.create(Window.ListenerState);

    listener_state.* = .{
        .running = true,
        .surface = surface,
    };

    xdg_surface.setListener(*Window.ListenerState, Window.xdgSurfaceListener, listener_state);
    toplevel.setListener(*Window.ListenerState, Window.xdgToplevelListener, listener_state);

    var stack_fallback = std.heap.stackFallback(16, arena);

    const title = try stack_fallback.get().dupeZ(u8, options.title);

    toplevel.setTitle(title);
    toplevel.setAppId(title);
    toplevel.setMaximized();

    if (self.decoration_manager) |decoration_manager| {
        const decoration = try decoration_manager.getToplevelDecoration(toplevel);

        decoration.setMode(.server_side);
    }

    surface.commit();
    if (self.display.roundtrip() != .SUCCESS) return error.RoundtripFailed;

    surface.commit();

    return .{
        .{
            .window_system = self,
            .surface = surface,
            .xdg_surface = xdg_surface,
            .toplevel = toplevel,
            .listener_state = listener_state,
        },
        .{ .width = @intCast(listener_state.width), .height = @intCast(listener_state.height) },
    };
}

pub fn destroyWindow(
    self: *WindowSystem,
    window: *Window,
    gpa: std.mem.Allocator,
) void {
    _ = self; // autofix
    _ = gpa; // autofix
    window.toplevel.destroy();
    window.xdg_surface.destroy();
    window.surface.destroy();
}

const RegistryHandlerContext = struct {
    compositor: ?*wl.Compositor,
    wm_base: ?*xdg.WmBase,
    decoration_manager: ?*zxdg.DecorationManagerV1,
    seat: ?*wl.Seat,
};

fn registryListener(registry: *wl.Registry, event: wl.Registry.Event, context: *RegistryHandlerContext) void {
    const mem = std.mem;

    switch (event) {
        .global => |global| {
            if (mem.orderZ(u8, global.interface, wl.Compositor.interface.name) == .eq) {
                context.compositor = registry.bind(global.name, wl.Compositor, 1) catch return;
            } else if (mem.orderZ(u8, global.interface, xdg.WmBase.interface.name) == .eq) {
                context.wm_base = registry.bind(global.name, xdg.WmBase, 1) catch return;
            } else if (mem.orderZ(u8, global.interface, zxdg.DecorationManagerV1.interface.name) == .eq) {
                context.decoration_manager = registry.bind(global.name, zxdg.DecorationManagerV1, 1) catch return;
            } else if (mem.orderZ(u8, global.interface, wl.Seat.interface.name) == .eq) {
                context.seat = registry.bind(global.name, wl.Seat, 1) catch return;
            }
        },
        .global_remove => {},
    }
}

fn seatListener(seat: *wl.Seat, event: wl.Seat.Event, data: ?*anyopaque) void {
    _ = seat; // autofix
    _ = event; // autofix
    _ = data; // autofix
}

const std = @import("std");
const zxdg = wayland.client.zxdg;
const xdg = wayland.client.xdg;
const wl = wayland.client.wl;
const wayland = @import("wayland");
const windowing = @import("../../windowing.zig");
const WindowSystem = @This();
const Window = @import("Window.zig");
const CreateWindowOptions = @import("../../windowing.zig").WindowSystem.CreateWindowOptions;
