display: *wl.Display,
registry: *wl.Registry,
compositor: *wl.Compositor,
wm_base: *xdg.WmBase,
seat: *wl.Seat,
keyboard: ?*wl.Keyboard,
pointer: ?*wl.Pointer,
relative_pointer_manager: ?*wayland.client.zwp.RelativePointerManagerV1,
relative_pointer: ?*wayland.client.zwp.RelativePointerV1,
decoration_manager: ?*zxdg.DecorationManagerV1,
listener_state: *ListenerState,
xkb_library: xkb_common_loader.Library,
xkb_context: *xkb_common_loader.Context,

pub fn init(
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
) !WindowSystem {
    _ = gpa; // autofix

    const xkb_library = try xkb_common_loader.load();

    const xkb_context = xkb_library.contextNew(.{});

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

    listener_state.* = .{
        .xkb_library = xkb_library,
        .xkb_context = xkb_context,
    };

    registry_context.seat.?.setListener(*ListenerState, &seatListener, listener_state);

    const pointer = try registry_context.seat.?.getPointer();

    pointer.setListener(*ListenerState, &pointerListener, listener_state);

    const keyboard = try registry_context.seat.?.getKeyboard();

    keyboard.setListener(*ListenerState, &keyboardListener, listener_state);

    const relative_pointer = try registry_context.relative_pointer_manager.?.getRelativePointer(pointer);

    relative_pointer.setListener(*ListenerState, &relativePointerListener, listener_state);

    return .{
        .display = display,
        .registry = registry,
        .compositor = registry_context.compositor.?,
        .wm_base = registry_context.wm_base.?,
        .seat = registry_context.seat.?,
        .pointer = pointer,
        .keyboard = keyboard,
        .relative_pointer_manager = registry_context.relative_pointer_manager,
        .relative_pointer = relative_pointer,
        .decoration_manager = registry_context.decoration_manager,
        .listener_state = listener_state,
        .xkb_library = xkb_library,
        .xkb_context = xkb_context,
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

    if (self.keyboard) |keyboard| {
        keyboard.destroy();
    }

    if (self.relative_pointer_manager) |relative_pointer_manager| {
        relative_pointer_manager.destroy();
    }

    if (self.relative_pointer) |relative_pointer| {
        relative_pointer.destroy();
    }

    self.seat.destroy();
    self.wm_base.destroy();
    self.compositor.destroy();
    self.registry.destroy();
    self.display.disconnect();

    self.xkb_library.contextUnref(self.xkb_context);
    self.xkb_library.dynamic_library.close();

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
    relative_pointer_manager: ?*wayland.client.zwp.RelativePointerManagerV1,
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
            } else if (mem.orderZ(u8, global.interface, wayland.client.zwp.RelativePointerManagerV1.interface.name) == .eq) {
                context.relative_pointer_manager = registry.bind(global.name, wayland.client.zwp.RelativePointerManagerV1, 1) catch return;
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
            if (enter_event.surface == null) return;

            state.focus_window_state = state.window_listener_states.get(enter_event.surface.?) orelse return;
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

fn relativePointerListener(
    relative_pointer: *wayland.client.zwp.RelativePointerV1,
    event: wayland.client.zwp.RelativePointerV1.Event,
    listener_state: *ListenerState,
) void {
    _ = relative_pointer; // autofix

    if (listener_state.focus_window_state == null) return;

    const focus_window_state = listener_state.focus_window_state.?;

    focus_window_state.out_viewport_state.?.cursor_motion[0] = @intCast(event.relative_motion.dx.toInt());
    focus_window_state.out_viewport_state.?.cursor_motion[1] = @intCast(event.relative_motion.dy.toInt());

    focus_window_state.out_input_state.?.mouse_motion = focus_window_state.out_viewport_state.?.cursor_motion;
}

fn keyboardListener(
    keyboard: *wl.Keyboard,
    event: wl.Keyboard.Event,
    listener_state: *ListenerState,
) void {
    _ = keyboard; // autofix

    switch (event) {
        .keymap => |keymap_event| {
            defer std.posix.close(keymap_event.fd);

            const buffer = std.posix.mmap(null, keymap_event.size, std.posix.PROT.READ, .{
                .TYPE = .PRIVATE,
            }, keymap_event.fd, 0) catch @panic("oom");
            defer std.posix.munmap(buffer);

            std.debug.assert(keymap_event.format == .xkb_v1);

            listener_state.xkb_keymap = listener_state.xkb_library.keymapNewFromBuffer(
                listener_state.xkb_context,
                buffer.ptr,
                buffer.len,
                .text_v1,
                .{},
            );

            listener_state.xkb_state = listener_state.xkb_library.stateNew(listener_state.xkb_keymap.?);
        },
        .key => |key_event| {
            if (listener_state.focus_window_state == null) return;

            const focus_window_state = listener_state.focus_window_state.?;

            if (listener_state.xkb_state == null) return;

            const xkb_state = listener_state.xkb_state.?;

            const scancode = key_event.key + 8;

            const keysym = listener_state.xkb_library.stateKeyGetOneSym(xkb_state, @enumFromInt(scancode));

            if (xkb_keys.xkbKeyToQuantaKey(keysym)) |key| {
                if (key_event.state == .pressed) {
                    _ = listener_state.xkb_library.stateUpdateKey(xkb_state, @enumFromInt(scancode), .down);

                    focus_window_state.out_input_state.?.buttons_keyboard.set(key, .press);
                } else {
                    _ = listener_state.xkb_library.stateUpdateKey(xkb_state, @enumFromInt(scancode), .up);

                    focus_window_state.out_input_state.?.buttons_keyboard.set(key, .release);
                }
            }
        },
        else => {},
    }
}

const ListenerState = struct {
    focus_window_state: ?*Window.ListenerState = null,
    window_listener_states: std.AutoArrayHashMapUnmanaged(*wl.Surface, *Window.ListenerState) = .{},

    xkb_library: xkb_common_loader.Library,
    xkb_context: *xkb_common_loader.Context,
    xkb_keymap: ?*xkb_common_loader.Keymap = null,
    xkb_state: ?*xkb_common_loader.State = null,
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
const xkb_common_loader = @import("../common/xkbcommon_loader.zig");
const xkb_keys = @import("../common/xkb_keys.zig");
