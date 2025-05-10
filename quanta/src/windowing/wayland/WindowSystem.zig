display: *wl.Display,
registry: *wl.Registry,
compositor: *wl.Compositor,
wm_base: *xdg.WmBase,
seat: *wl.Seat,
pointer: ?*wl.Pointer,
decoration_manager: ?*zxdg.DecorationManagerV1,
listener_state: *ListenerState,

pub fn init(
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
) !WindowSystem {
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

    const listener_state = try arena.create(ListenerState);

    listener_state.* = .{};

    registry_context.seat.?.setListener(*ListenerState, &seatListener, listener_state);

    const pointer = try registry_context.seat.?.getPointer();

    pointer.setListener(*ListenerState, &pointerListener, listener_state);

    return .{
        .display = display,
        .registry = registry,
        .compositor = registry_context.compositor.?,
        .wm_base = registry_context.wm_base.?,
        .seat = registry_context.seat.?,
        .pointer = pointer,
        .decoration_manager = registry_context.decoration_manager,
        .listener_state = listener_state,
    };
}

pub fn deinit(self: *WindowSystem, gpa: std.mem.Allocator) void {
    _ = gpa; // autofix

    _ = self.display.roundtrip();

    if (self.decoration_manager) |decoration_manager| {
        decoration_manager.destroy();
    }

    if (self.pointer) |pointer| {
        pointer.destroy();
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

    try self.listener_state.window_listener_states.put(arena, surface, listener_state);

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
    pointer: ?*wl.Pointer,
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

fn seatListener(seat: *wl.Seat, event: wl.Seat.Event, state: *ListenerState) void {
    _ = state; // autofix
    _ = seat; // autofix
    _ = event; // autofix
}

fn pointerListener(pointer: *wl.Pointer, event: wl.Pointer.Event, state: *ListenerState) void {
    _ = pointer; // autofix
    switch (event) {
        .enter => |enter_event| {
            state.focus_window_state = state.window_listener_states.get(enter_event.surface.?).?;
        },
        .leave => |leave_event| {
            _ = leave_event; // autofix
            state.focus_window_state = null;

            if (state.focus_window_state == null) return;

            if (state.focus_window_state.?.out_input_state == null) return;

            const input_state = state.focus_window_state.?.out_input_state.?;
            _ = input_state; // autofix
            const input_viewport = state.focus_window_state.?.out_viewport_state.?;

            input_viewport.cursor_position = @splat(-1);
            input_viewport.cursor_motion = @splat(0);
        },
        .motion => |motion_event| {
            if (state.focus_window_state == null) return;

            if (state.focus_window_state.?.out_input_state == null) return;

            const input_state = state.focus_window_state.?.out_input_state.?;
            const input_viewport = state.focus_window_state.?.out_viewport_state.?;
            _ = input_state; // autofix

            input_viewport.cursor_position = .{
                @intCast(motion_event.surface_x.toInt()),
                @intCast(motion_event.surface_y.toInt()),
            };
        },
        .button => |button_event| {
            if (state.focus_window_state == null) return;

            if (state.focus_window_state.?.out_input_state == null) return;

            const linux_mouse_input_code_offset = 0x110;

            const input_state = state.focus_window_state.?.out_input_state.?;

            const button_code = button_event.button - linux_mouse_input_code_offset;

            std.log.info("button_code = {}", .{button_code});
            std.log.info("state = {}", .{button_event.state});

            switch (button_event.state) {
                .released => {
                    input_state.buttons_mouse.set(@enumFromInt(button_code), .release);
                },
                .pressed => {
                    input_state.buttons_mouse.set(@enumFromInt(button_code), .down);
                },
                else => {},
            }
        },
        else => {},
    }
}

const ListenerState = struct {
    focus_window_state: ?*Window.ListenerState = null,
    window_listener_states: std.AutoArrayHashMapUnmanaged(*wl.Surface, *Window.ListenerState) = .{},
};

const std = @import("std");
const zxdg = wayland.client.zxdg;
const xdg = wayland.client.xdg;
const wl = wayland.client.wl;
const input = @import("../../input.zig");
const wayland = @import("wayland");
const windowing = @import("../../windowing.zig");
const WindowSystem = @This();
const Window = @import("Window.zig");
const CreateWindowOptions = @import("../../windowing.zig").WindowSystem.CreateWindowOptions;
