window_system: *XcbWindowSystem,
xcb_library: *xcb_loader.Library,
xcb_xinput_library: *xcb_xinput_loader.Library,
xkbcommon_library: *xkbcommon_loader.Library,
width: u16,
height: u16,
connection: *xcb_loader.Connection,
screen: *xcb_loader.Screen,
window: xcb_loader.Window,
wm_delete_window_atom: xcb_loader.Atom,
xkb_context: *xkbcommon_loader.Context,
xkb_state: *xkbcommon_loader.State,
xkb_keymap: *xkbcommon_loader.Keymap,
hidden_cursor: xcb_loader.Cursor,
key_map: [std.enums.values(input.KeyboardKey).len]bool,
key_press_timestamps: [std.enums.values(input.KeyboardKey).len]u32,
previous_key_map: [std.enums.values(input.KeyboardKey).len]bool,
mouse_map: [std.enums.values(input.MouseButton).len]bool,
previous_mouse_map: [std.enums.values(input.MouseButton).len]bool,
cursor_position: @Vector(2, i16) = .{ 0, 0 },
last_cursor_position: @Vector(2, i16) = .{ 0, 0 },
cursor_grabbed: bool = false,
cursor_hidden: bool = false,
//'raw' mouse motion
mouse_motion: @Vector(2, i16) = .{ 0, 0 },
text_buffer: [256]u8 = undefined,
text_len: usize = 0,
mouse_scroll: i32 = 0,
should_close: bool = false,

pub fn init(
    gpa: std.mem.Allocator,
    window_system: *XcbWindowSystem,
    options: windowing.WindowSystem.CreateWindowOptions,
) !XcbWindow {
    _ = gpa;

    var self = XcbWindow{
        .window_system = window_system,
        .connection = window_system.connection,
        .screen = undefined,
        .window = undefined,
        .width = undefined,
        .height = undefined,
        .wm_delete_window_atom = undefined,
        .xkb_context = undefined,
        .xkb_state = undefined,
        .xkb_keymap = undefined,
        .key_map = std.mem.zeroes([std.enums.values(input.KeyboardKey).len]bool),
        .key_press_timestamps = std.mem.zeroes([std.enums.values(input.KeyboardKey).len]u32),
        .previous_key_map = std.mem.zeroes([std.enums.values(input.KeyboardKey).len]bool),
        .mouse_map = std.mem.zeroes([std.enums.values(input.MouseButton).len]bool),
        .previous_mouse_map = std.mem.zeroes([std.enums.values(input.MouseButton).len]bool),
        .hidden_cursor = undefined,
        .xcb_library = &window_system.xcb_library,
        .xkbcommon_library = &window_system.xkbcommon_library,
        .xcb_xinput_library = &window_system.xcb_xinput_library,
    };

    const setup = self.xcb_library.getSetup(self.connection).?;

    const iter = self.xcb_library.setupRootsIterator(setup);

    self.screen = &iter.data[0];

    const xinput_extension_info = self.xcb_library.queryExtension(self.connection, "XInputExtension");

    if (xinput_extension_info.present == 0) {
        @panic("XInputExtension not present. The compositor must have support for the XInputExtension and provide libxcb-input");
    }

    const values = [_]u32{
        xcb.XCB_EVENT_MASK_EXPOSURE | xcb.XCB_EVENT_MASK_BUTTON_PRESS |
            xcb.XCB_EVENT_MASK_BUTTON_RELEASE | xcb.XCB_EVENT_MASK_POINTER_MOTION |
            xcb.XCB_EVENT_MASK_ENTER_WINDOW | xcb.XCB_EVENT_MASK_LEAVE_WINDOW |
            xcb.XCB_EVENT_MASK_KEY_PRESS | xcb.XCB_EVENT_MASK_KEY_RELEASE | xcb.XCB_EVENT_MASK_PROPERTY_CHANGE |
            xcb.XCB_EVENT_MASK_STRUCTURE_NOTIFY | xcb.XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY | xcb.XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | xcb.XCB_EVENT_MASK_VISIBILITY_CHANGE |
            xcb_input.XCB_INPUT_XI_EVENT_MASK_RAW_MOTION | xcb_input.XCB_INPUT_XI_EVENT_MASK_MOTION | xcb_input.XCB_INPUT_XI_EVENT_MASK_RAW_KEY_PRESS |
            xcb.XCB_EVENT_MASK_ENTER_WINDOW | xcb.XCB_EVENT_MASK_FOCUS_CHANGE | xcb.XCB_EVENT_MASK_OWNER_GRAB_BUTTON | xcb.XCB_EVENT_MASK_POINTER_MOTION_HINT,
    };

    self.window = self.xcb_library.createWindow(
        self.connection,
        xcb.XCB_COPY_FROM_PARENT,
        self.screen.root,
        xcb.XCB_COPY_FROM_PARENT,
        xcb.XCB_COPY_FROM_PARENT,
        options.preferred_width orelse self.screen.width_in_pixels * 2 / 3,
        options.preferred_height orelse self.screen.height_in_pixels * 2 / 3,
        xcb.XCB_COPY_FROM_PARENT,
        xcb.XCB_WINDOW_CLASS_INPUT_OUTPUT,
        self.screen.root_visual,
        xcb.XCB_CW_EVENT_MASK,
        &values,
    );

    const input_mask: xcb_xinput_loader.EventMaskList = .{
        .head = .{
            .deviceid = .all_master,
            .mask_len = 1,
        },
        .mask = .{
            .motion = true,
            .raw_motion = true,
        },
    };

    //TODO: FIXME: This is currently crashing in release fast and I don't know why
    if (@import("builtin").mode != .ReleaseFast) {
        self.xcb_xinput_library.xiSelectEventsChecked(
            self.connection,
            self.window,
            1,
            @ptrCast(&input_mask.head),
        );
    }

    _ = self.xcb_library.changeProperty(
        self.connection,
        xcb.XCB_PROP_MODE_REPLACE,
        self.window,
        .wm_name,
        .string,
        8,
        @intCast(options.title.len),
        options.title.ptr,
    );

    const protocols_atom = self.xcb_library.internAtom(self.connection, false, "WM_PROTOCOLS");
    const delete_window_atom = self.xcb_library.internAtom(self.connection, false, "WM_DELETE_WINDOW");

    self.wm_delete_window_atom = delete_window_atom.atom;

    self.xcb_library.changeProperty(
        self.connection,
        xcb.XCB_PROP_MODE_REPLACE,
        self.window,
        protocols_atom.atom,
        .atom,
        32,
        1,
        &delete_window_atom.atom,
    );

    self.xkb_context = self.xkbcommon_library.contextNew(.{});
    errdefer self.xkbcommon_library.contextUnref(self.xkb_context);

    self.xkb_keymap = self.xkbcommon_library.keymapNewFromNames(self.xkb_context, null, .{});
    errdefer self.xkbcommon_library.keymapUnref(self.xkb_keymap);

    self.xkb_state = self.xkbcommon_library.stateNew(self.xkb_keymap);
    errdefer self.xkbcommon_library.stateUnref(self.xkb_state);

    const hidden_cursor_pixmap = self.xcb_library.createPixmap(
        self.connection,
        1,
        @enumFromInt(@intFromEnum(self.window)),
        1,
        1,
    );

    self.hidden_cursor = self.xcb_library.createCursor(
        self.connection,
        hidden_cursor_pixmap,
        hidden_cursor_pixmap,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
    );

    self.xcb_library.freePixmap(self.connection, hidden_cursor_pixmap);

    self.xcb_library.mapWindow(self.connection, self.window);

    _ = self.xcb_library.flush(self.connection);

    return self;
}

pub fn deinit(self: *XcbWindow, allocator: std.mem.Allocator) void {
    _ = allocator;
    self.xkbcommon_library.contextUnref(self.xkb_context);
    self.xkbcommon_library.stateUnref(self.xkb_state);
    self.xkbcommon_library.keymapUnref(self.xkb_keymap);

    self.* = undefined;
}

///return false if we need to close
pub fn pollEvents(self: *XcbWindow, out_input: *input.State) !void {
    self.previous_key_map = self.key_map;
    self.previous_mouse_map = self.mouse_map;
    // self.last_cursor_position = self.cursor_position;

    const query_pointer = self.xcb_library.queryPointer(self.connection, self.window);

    self.cursor_position[0] = query_pointer.win_x;
    self.cursor_position[1] = query_pointer.win_y;

    @memset(&self.text_buffer, 0);

    self.text_len = 0;

    self.mouse_scroll = 0;

    if (!self.isFocused()) {
        @memset(&self.key_map, false);
        @memset(&self.mouse_map, false);
    }

    out_input.buttons_mouse = .initFill(.release);

    while (self.xcb_library.pollForEvent(self.connection)) |event| {
        switch (event) {
            .button_press => |button_press| {
                if (!self.isFocused()) continue;

                switch (button_press.detail) {
                    .index_1 => {
                        switch (out_input.buttons_mouse.get(.left)) {
                            .release, .down, .press => {
                                out_input.buttons_mouse.set(.left, .down);
                            },
                        }

                        self.mouse_map[@intFromEnum(input.MouseButton.left)] = true;
                    },
                    .index_2 => self.mouse_map[@intFromEnum(input.MouseButton.middle)] = true,
                    .index_3 => self.mouse_map[@intFromEnum(input.MouseButton.right)] = true,
                    else => {},
                }
            },
            .button_release => |button_release| {
                if (!self.isFocused()) continue;

                switch (button_release.detail) {
                    .index_1 => {
                        switch (out_input.buttons_mouse.get(.left)) {
                            .release => {},
                            .press => {
                                out_input.buttons_mouse.set(.left, .release);
                            },
                            .down => {
                                out_input.buttons_mouse.set(.left, .press);
                            },
                        }

                        self.mouse_map[@intFromEnum(input.MouseButton.left)] = false;
                    },
                    .index_2 => self.mouse_map[@intFromEnum(input.MouseButton.middle)] = false,
                    .index_3 => self.mouse_map[@intFromEnum(input.MouseButton.right)] = false,
                    .index_4 => {
                        self.mouse_scroll += 1;
                    },
                    .index_5 => {
                        self.mouse_scroll -= 1;
                    },
                }
            },
            .key_press => |key_press| {
                if (!self.isFocused()) continue;

                const keysym = self.xkbcommon_library.stateKeyGetOneSym(self.xkb_state, @enumFromInt(key_press.detail));

                _ = self.xkbcommon_library.stateUpdateKey(self.xkb_state, @enumFromInt(key_press.detail), .down);

                const text_len = self.xkbcommon_library.stateKeyGetUtf8(
                    self.xkb_state,
                    @enumFromInt(key_press.detail),
                    &self.text_buffer,
                    self.text_buffer.len,
                );

                self.text_len += text_len;

                if (xkbKeyToQuantaKey(keysym)) |key| {
                    const time_difference = key_press.time - self.key_press_timestamps[@intFromEnum(key)];

                    if (time_difference == key_press.time or
                        (time_difference > 0 and time_difference < (1 << 31)))
                    {
                        self.key_map[@intFromEnum(key)] = true;
                        self.key_press_timestamps[@intFromEnum(key)] = key_press.time;
                    }
                }
            },
            .key_release => |key_release| {
                if (!self.isFocused()) continue;

                const keysym = self.xkbcommon_library.stateKeyGetOneSym(self.xkb_state, @enumFromInt(key_release.detail));

                _ = self.xkbcommon_library.stateUpdateKey(self.xkb_state, @enumFromInt(key_release.detail), .up);

                if (xkbKeyToQuantaKey(keysym)) |key| {
                    self.key_map[@intFromEnum(key)] = false;
                }
            },
            .motion_notify => |motion_notify| {
                // const last_mouse_position = self.mouse_position;
                // self.last_mouse_position = last_mouse_position;
                std.log.info("{} motion_notify = {}, {}, rt: {}, {}", .{
                    std.time.timestamp(),
                    motion_notify.event_x,
                    motion_notify.event_y,
                    motion_notify.root_x,
                    motion_notify.root_y,
                });

                const new_cursor_pos: @Vector(2, i16) = .{ motion_notify.event_x, motion_notify.event_y };

                const raw_cursor_delta = new_cursor_pos - self.last_cursor_position;

                std.log.info("last_pos = {}", .{self.last_cursor_position});
                std.log.info("new_pos = {}", .{new_cursor_pos});
                std.log.info("raw_cursor_delta = {}", .{raw_cursor_delta});

                if (self.cursor_grabbed) {
                    if (motion_notify.event_x == 0) {
                        self.xcb_library.warpPointer(
                            self.connection,
                            self.window,
                            self.window,
                            motion_notify.event_x,
                            motion_notify.event_y,
                            self.getWidth(),
                            self.getHeight(),
                            @intCast(self.getWidth() - 1),
                            motion_notify.event_y,
                        );

                        out_input.cursor_motion = .{ -1, raw_cursor_delta[1] };
                    } else {
                        out_input.cursor_motion = raw_cursor_delta;
                    }
                }

                std.log.info("out_motion = {}, {}", .{ out_input.cursor_motion[0], out_input.cursor_motion[1] });

                self.last_cursor_position = new_cursor_pos;
            },
            .focus_in => |focus_in| {
                if (focus_in.mode == xcb.XCB_NOTIFY_MODE_GRAB or focus_in.mode == xcb.XCB_NOTIFY_MODE_UNGRAB) {
                    continue;
                }

                if (self.cursor_grabbed) {
                    self.captureCursor();
                } else {
                    self.uncaptureCursor();
                }
            },
            .focus_out => |focus_out| {
                if (focus_out.mode == xcb.XCB_NOTIFY_MODE_GRAB or focus_out.mode == xcb.XCB_NOTIFY_MODE_UNGRAB) {
                    continue;
                }

                if (self.cursor_grabbed) {
                    self.captureCursor();
                } else {
                    self.uncaptureCursor();
                }

                self.eventFocusOut();
            },
            .enter_notify => |enter_notify| {
                const x: i16 = enter_notify.event_x;
                const y: i16 = enter_notify.event_y;

                self.last_cursor_position = .{ x, y };
            },
            .leave_notify => {},
            .configure_notify => |configure_notify| {
                _ = configure_notify; // autofix
            },
            .client_message => |client_message| {
                if (client_message.data.data32[0] == @intFromEnum(self.wm_delete_window_atom)) {
                    self.should_close = true;

                    return;
                }
            },
            .xinput_motion_event => |motion| {
                _ = motion; // autofix
            },
            .xinput_raw_mouse_motion => |raw_mouse_motion| {
                _ = raw_mouse_motion; // autofix
            },
            else => {},
        }
    }

    if (!self.cursor_grabbed) {
        out_input.cursor_motion = self.cursor_position -% self.last_cursor_position;
    }

    out_input.cursor_position = self.cursor_position;
    out_input.mouse_scroll = self.mouse_scroll;

    for (std.enums.values(input.MouseButton)) |button| {
        out_input.buttons_mouse.set(button, self.getMouseButton(button));
    }

    for (std.enums.values(input.KeyboardKey)) |button| {
        out_input.buttons_keyboard.set(button, self.getKey(button));
    }
}

pub fn shouldClose(self: *XcbWindow) bool {
    return self.should_close;
}

pub fn getWidth(self: XcbWindow) u16 {
    const reply = self.xcb_library.getGeometry(self.connection, @enumFromInt(@intFromEnum(self.window)));

    return reply.width;
}

pub fn getHeight(self: XcbWindow) u16 {
    const reply = self.xcb_library.getGeometry(self.connection, @enumFromInt(@intFromEnum(self.window)));

    return reply.height;
}

pub fn captureCursor(self: *XcbWindow) void {
    if (self.cursor_grabbed) return;

    self.key_map = std.mem.zeroes(@TypeOf(self.key_map));
    self.mouse_map = std.mem.zeroes(@TypeOf(self.mouse_map));

    @memset(&self.previous_key_map, false);
    @memset(&self.previous_mouse_map, false);

    self.hideCursor();

    _ = self.xcb_library.grabPointer(
        self.connection,
        1,
        self.screen.root,
        xcb.XCB_EVENT_MASK_BUTTON_PRESS | xcb.XCB_EVENT_MASK_BUTTON_RELEASE | xcb.XCB_EVENT_MASK_POINTER_MOTION,
        xcb.XCB_GRAB_MODE_ASYNC,
        xcb.XCB_GRAB_MODE_ASYNC,
        self.window,
        @enumFromInt(0),
        xcb.XCB_CURRENT_TIME,
    );

    self.cursor_grabbed = true;
}

pub fn uncaptureCursor(self: *XcbWindow) void {
    if (!self.cursor_grabbed) return;

    self.xcb_library.ungrabPointer(self.connection, xcb.XCB_CURRENT_TIME);

    self.unhideCursor();

    self.cursor_grabbed = false;
}

pub fn isCursorCaptured(self: XcbWindow) bool {
    return self.cursor_grabbed;
}

pub fn hideCursor(self: *XcbWindow) void {
    if (self.cursor_hidden) return;

    self.xcb_library.changeWindowAttributes(self.connection, self.window, xcb.XCB_CW_CURSOR, &self.hidden_cursor);

    self.cursor_hidden = true;
}

pub fn unhideCursor(self: *XcbWindow) void {
    if (!self.cursor_hidden) return;

    self.xcb_library.changeWindowAttributes(self.connection, self.window, xcb.XCB_CW_CURSOR, &@as(u32, 0));

    self.cursor_hidden = false;
}

pub fn isCursorHidden(self: XcbWindow) bool {
    return self.cursor_hidden;
}

pub fn isFocused(self: XcbWindow) bool {
    const focus = self.xcb_library.getInputFocus(self.connection);

    return self.window == focus.focus;
}

pub fn getUtf8Input(self: *const XcbWindow) []const u8 {
    return self.text_buffer[0..self.text_len];
}

fn eventFocusOut(self: *XcbWindow) void {
    @memset(&self.key_map, false);
    @memset(&self.mouse_map, false);
}

fn getKey(self: XcbWindow, key: input.KeyboardKey) input.ButtonAction {
    const index = @intFromEnum(key);

    if (!self.key_map[index] and self.previous_key_map[index]) {
        return .press;
    }

    if (self.key_map[index]) {
        return .down;
    }

    return .release;
}

fn getMouseButton(self: XcbWindow, key: input.MouseButton) input.ButtonAction {
    const index = @intFromEnum(key);

    if (!self.mouse_map[index] and self.previous_mouse_map[index]) {
        return .press;
    }

    if (self.mouse_map[index]) {
        return .down;
    }

    return .release;
}

fn getMouseMotion(self: XcbWindow) @Vector(2, i16) {
    //TODO: use raw motion
    return self.mouse_motion;
}

fn getCursorMotion(self: XcbWindow) @Vector(2, i16) {
    return self.mouse_motion;
}

///Convert xkb key symbol to windowing.Key
fn xkbKeyToQuantaKey(keysym: xkbcommon_loader.KeySym) ?input.KeyboardKey {
    return switch (keysym) {
        .space => .space,
        .apostrophe => .apostrophe,
        .comma => .comma,
        .minus => .minus,
        .period => .period,
        .slash => .slash,
        .@"0" => .zero,
        .@"1" => .one,
        .@"2" => .two,
        .@"3" => .three,
        .@"4" => .four,
        .@"5" => .five,
        .@"6" => .six,
        .@"7" => .seven,
        .@"8" => .eight,
        .@"9" => .nine,
        .semicolon => .semicolon,
        .equal => .equal,
        .A, .a => .a,
        .B, .b => .b,
        .C, .c => .c,
        .D, .d => .d,
        .E, .e => .e,
        .F, .f => .f,
        .G, .g => .g,
        .H, .h => .h,
        .I, .i => .i,
        .J, .j => .j,
        .K, .k => .k,
        .L, .l => .l,
        .M, .m => .m,
        .N, .n => .n,
        .O, .o => .o,
        .P, .p => .p,
        .Q, .q => .q,
        .R, .r => .r,
        .S, .s => .s,
        .T, .t => .t,
        .U, .u => .u,
        .V, .v => .v,
        .W, .w => .w,
        .X, .x => .x,
        .Y, .y => .y,
        .Z, .z => .z,
        .botleftsqbracket => .left_bracket,
        .backslash => .backslash,
        .botrightsqbracket => .right_bracket,
        .grave => .grave_accent,
        .Escape => .escape,
        .Return => .enter,
        .Tab => .tab,
        .BackSpace => .backspace,
        .Insert => .insert,
        .Delete => .delete,
        .Right => .right,
        .Left => .left,
        .Down => .down,
        .Up => .up,
        .Page_Up => .page_up,
        .Page_Down => .page_down,
        .Home => .home,
        .End => .end,
        .Caps_Lock => .caps_lock,
        .Scroll_Lock => .scroll_lock,
        .Num_Lock => .num_lock,
        .Print => .print_screen,
        .Pause => .pause,
        .F1 => .F1,
        .F2 => .F2,
        .F3 => .F3,
        .F4 => .F4,
        .F5 => .F5,
        .F6 => .F6,
        .F7 => .F7,
        .F8 => .F8,
        .F9 => .F9,
        .F10 => .F10,
        .F11 => .F11,
        .F12 => .F12,
        .F13 => .F13,
        .F14 => .F14,
        .F15 => .F15,
        .F16 => .F16,
        .F17 => .F17,
        .F18 => .F18,
        .F19 => .F19,
        .F20 => .F20,
        .F21 => .F21,
        .F22 => .F22,
        .F23 => .F23,
        .F24 => .F24,
        .F25 => .F25,
        .KP_0 => .kp_0,
        .KP_1 => .kp_1,
        .KP_2 => .kp_2,
        .KP_3 => .kp_3,
        .KP_4 => .kp_4,
        .KP_5 => .kp_5,
        .KP_6 => .kp_6,
        .KP_7 => .kp_7,
        .KP_8 => .kp_8,
        .KP_9 => .kp_9,
        .KP_Decimal => .kp_decimal,
        .KP_Divide => .kp_divide,
        .KP_Multiply => .kp_multiply,
        .KP_Subtract => .kp_subtract,
        .KP_Add => .kp_add,
        .KP_Enter => .kp_enter,
        .KP_Equal => .kp_equal,
        .Shift_L => .left_shift,
        .Control_L => .left_control,
        .Alt_L => .left_alt,
        .Super_L => .left_super,
        .Shift_R => .right_shift,
        .Control_R => .right_control,
        .Alt_R => .right_alt,
        .Super_R => .right_super,
        .Menu => .menu,
        else => null,
    };
}

test {}

const XcbWindow = @This();
const XcbWindowSystem = @import("WindowSystem.zig");
const std = @import("std");
const windowing = @import("../../windowing.zig");
const input = @import("../../input.zig");
const Key = input.KeyboardKey;
const Action = input.ButtonAction;
const xcb = @import("xcb.zig");
const xcb_input = @import("xinput.zig");
const xcb_loader = @import("xcb_loader.zig");
const xkbcommon_loader = @import("xkbcommon_loader.zig");
const xcb_xinput_loader = @import("xcb_xinput_loader.zig");
