window_system: *XcbWindowSystem,
xcb_library: *xcb_loader.Library,
width: u16,
height: u16,
connection: *xcb_loader.Connection,
screen: *xcb_loader.Screen,
window: xcb_loader.Window,
wm_delete_window_atom: xcb_loader.Atom,
xkb_context: *xkb.xkb_context,
xkb_state: *xkb.xkb_state,
xkb_keymap: *xkb.xkb_keymap,
hidden_cursor: xcb_loader.Cursor,
key_map: [std.enums.values(windowing.Key).len]bool,
previous_key_map: [std.enums.values(windowing.Key).len]bool,
mouse_map: [std.enums.values(windowing.MouseButton).len]bool,
mouse_position: @Vector(2, i16) = .{ 0, 0 },
last_mouse_position: @Vector(2, i16) = .{ 0, 0 },
cursor_grabbed: bool = false,
cursor_hidden: bool = false,
//'raw' mouse motion
mouse_motion: @Vector(2, i16) = .{ 0, 0 },
text_buffer: [256]u8 = undefined,
text_len: usize = 0,
mouse_scroll: i32 = 0,

pub fn init(
    allocator: std.mem.Allocator,
    window_system: *XcbWindowSystem,
    options: windowing.WindowSystem.CreateWindowOptions,
) !XcbWindow {
    _ = allocator;

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
        .key_map = std.mem.zeroes([std.enums.values(windowing.Key).len]bool),
        .previous_key_map = std.mem.zeroes([std.enums.values(windowing.Key).len]bool),
        .mouse_map = std.mem.zeroes([std.enums.values(windowing.MouseButton).len]bool),
        .hidden_cursor = undefined,
        .xcb_library = &window_system.xcb_library,
    };

    const setup = self.xcb_library.getSetup(self.connection).?;

    const iter = self.xcb_library.setupRootsIterator(setup);

    self.screen = &iter.data[0];

    const xinput_extension_info = self.xcb_library.queryExtension(self.connection, "XInputExtension");
    _ = xinput_extension_info; // autofix

    const values = [_]u32{xcb.XCB_EVENT_MASK_EXPOSURE | xcb.XCB_EVENT_MASK_BUTTON_PRESS |
        xcb.XCB_EVENT_MASK_BUTTON_RELEASE | xcb.XCB_EVENT_MASK_POINTER_MOTION |
        xcb.XCB_EVENT_MASK_ENTER_WINDOW | xcb.XCB_EVENT_MASK_LEAVE_WINDOW |
        xcb.XCB_EVENT_MASK_KEY_PRESS | xcb.XCB_EVENT_MASK_KEY_RELEASE | xcb.XCB_EVENT_MASK_PROPERTY_CHANGE |
        xcb.XCB_EVENT_MASK_STRUCTURE_NOTIFY | xcb.XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY | xcb.XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | xcb.XCB_EVENT_MASK_VISIBILITY_CHANGE |
        xcb_input.XCB_INPUT_XI_EVENT_MASK_RAW_MOTION | xcb_input.XCB_INPUT_XI_EVENT_MASK_MOTION | xcb_input.XCB_INPUT_XI_EVENT_MASK_RAW_KEY_PRESS |
        xcb.XCB_EVENT_MASK_ENTER_WINDOW | xcb.XCB_EVENT_MASK_FOCUS_CHANGE | xcb.XCB_EVENT_MASK_OWNER_GRAB_BUTTON | xcb.XCB_EVENT_MASK_POINTER_MOTION_HINT};

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

    const input_mask: extern struct {
        head: xcb_input.xcb_input_event_mask_t,
        mask: xcb_input.xcb_input_xi_event_mask_t,
    } = .{
        .head = .{
            .deviceid = xcb_input.XCB_INPUT_DEVICE_ALL_MASTER,
            .mask_len = 1,
        },
        .mask = xcb_input.XCB_INPUT_XI_EVENT_MASK_MOTION | xcb_input.XCB_INPUT_XI_EVENT_MASK_RAW_MOTION,
    };

    _ = xcb_input.xcb_input_xi_select_events_checked(
        @ptrCast(self.connection),
        @intFromEnum(self.window),
        1,
        &input_mask.head,
    );

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

    self.xkb_context = xkb.xkb_context_new(xkb.XKB_CONTEXT_NO_FLAGS).?;
    self.xkb_keymap = xkb.xkb_keymap_new_from_names(self.xkb_context, null, xkb.XKB_KEYMAP_COMPILE_NO_FLAGS).?;
    self.xkb_state = xkb.xkb_state_new(self.xkb_keymap).?;

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
    xkb.xkb_context_unref(self.xkb_context);
    xkb.xkb_state_unref(self.xkb_state);
    xkb.xkb_keymap_unref(self.xkb_keymap);

    self.* = undefined;
}

///return false if we need to close
pub fn pollEvents(self: *XcbWindow) !bool {
    self.previous_key_map = self.key_map;

    const query_pointer = self.xcb_library.queryPointer(self.connection, self.window);

    self.mouse_position[0] = query_pointer.win_x;
    self.mouse_position[1] = query_pointer.win_y;

    self.text_len = 0;

    self.mouse_scroll = 0;

    while (self.xcb_library.pollForEvent(self.connection)) |event| {
        switch (event) {
            .button_press => |button_press| {
                switch (button_press.detail) {
                    .index_1 => self.mouse_map[@intFromEnum(windowing.MouseButton.left)] = true,
                    .index_2 => self.mouse_map[@intFromEnum(windowing.MouseButton.right)] = true,
                    .index_3 => self.mouse_map[@intFromEnum(windowing.MouseButton.middle)] = true,
                    else => {},
                }
            },
            .button_release => |button_release| {
                switch (button_release.detail) {
                    .index_1 => self.mouse_map[@intFromEnum(windowing.MouseButton.left)] = false,
                    .index_2 => self.mouse_map[@intFromEnum(windowing.MouseButton.right)] = false,
                    .index_3 => self.mouse_map[@intFromEnum(windowing.MouseButton.middle)] = false,
                    .index_4 => {
                        self.mouse_scroll += 1;
                    },
                    .index_5 => {
                        self.mouse_scroll -= 1;
                    },
                }
            },
            .key_press => |key_press| {
                const keysym = xkb.xkb_state_key_get_one_sym(self.xkb_state, key_press.detail);

                _ = xkb.xkb_state_update_key(self.xkb_state, key_press.detail, xkb.XKB_KEY_DOWN);

                const text_len = xkb.xkb_state_key_get_utf8(self.xkb_state, key_press.detail, &self.text_buffer[self.text_len], self.text_buffer.len);

                self.text_len += @intCast(text_len);

                if (xkbKeyToQuantaKey(keysym)) |key| {
                    self.key_map[@intFromEnum(key)] = true;
                }
            },
            .key_release => |key_release| {
                const keysym = xkb.xkb_state_key_get_one_sym(self.xkb_state, key_release.detail);

                _ = xkb.xkb_state_update_key(self.xkb_state, key_release.detail, xkb.XKB_KEY_UP);

                if (xkbKeyToQuantaKey(keysym)) |key| {
                    self.key_map[@intFromEnum(key)] = false;
                }
            },
            .motion_notify => |motion_notify| {
                const last_mouse_position = self.mouse_position;
                self.last_mouse_position = last_mouse_position;

                const S = struct {
                    pub var warped: bool = false;
                };

                var warped: bool = false;

                // if (motion_notify.event_x != self.getWidth() / 2 or motion_notify.event_y != self.getHeight() / 2) {
                if (self.cursor_grabbed) {
                    const predicted_position = self.mouse_position + self.mouse_motion;

                    const warped_last = S.warped;
                    _ = warped_last; // autofix

                    if (predicted_position[0] <= 0 or predicted_position[1] <= 0 or
                        predicted_position[0] >= self.getWidth() - 1 or predicted_position[1] >= self.getHeight() - 1)
                    {
                        // self.xcb_library.warpPointer(
                        //     self.connection,
                        //     self.window,
                        //     self.window,
                        //     motion_notify.event_x,
                        //     motion_notify.event_y,
                        //     self.getWidth(),
                        //     self.getHeight(),
                        //     @intCast(self.getWidth() / 2),
                        //     @intCast(self.getHeight() / 2),
                        //     // self.last_mouse_position[0] - self.mouse_motion[0],
                        //     // self.last_mouse_position[1] - self.mouse_motion[1],
                        // );

                        warped = true;
                    }

                    self.mouse_position = .{ motion_notify.event_x, motion_notify.event_y };
                    // self.mouse_motion = self.mouse_position - self.last_mouse_position;

                    // self.mouse_position += .{ motion_notify.event_x - self.last_mouse_position[0], motion_notify.event_y - self.last_mouse_position[1] };
                } else {
                    self.mouse_position = .{ motion_notify.event_x, motion_notify.event_y };
                }

                if (!S.warped) {
                    self.mouse_motion = self.mouse_position - self.last_mouse_position;
                } else {
                    // self.mouse_motion = .{ 0, 0 };
                }

                S.warped = warped;
            },
            .enter_notify => {},
            .leave_notify => {},
            .configure_notify => {},
            .client_message => |client_message| {
                if (client_message.data.data32[0] == @intFromEnum(self.wm_delete_window_atom)) {
                    return true;
                }
            },
            .xinput_raw_mouse_motion => |raw_mouse_motion| {
                _ = raw_mouse_motion; // autofix
            },
            else => {},
        }
    }

    return false;
}

pub fn shouldClose(self: *XcbWindow) bool {
    return self.pollEvents() catch unreachable;
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

pub fn getCursorPosition(self: XcbWindow) @Vector(2, i16) {
    return self.mouse_position;
}

pub fn getKey(self: XcbWindow, key: windowing.Key) windowing.Action {
    const index = @intFromEnum(key);

    if (!self.key_map[index] and self.previous_key_map[index]) {
        return .press;
    }

    if (self.key_map[index]) {
        return .down;
    }

    return .release;
}

pub fn getMouseButton(self: XcbWindow, key: windowing.MouseButton) windowing.Action {
    const index = @intFromEnum(key);

    if (self.mouse_map[index]) {
        return .down;
    }

    return .release;
}

pub fn getMouseMotion(self: XcbWindow) @Vector(2, i16) {
    return self.mouse_motion;
}

pub fn isFocused(self: XcbWindow) bool {
    const focus = self.xcb_library.getInputFocus(self.connection);

    return self.window == focus.focus;
}

pub fn getUtf8Input(self: XcbWindow) []const u8 {
    return self.text_buffer[0..self.text_len];
}

pub fn getMouseScroll(self: XcbWindow) i32 {
    return self.mouse_scroll;
}

///Convert xkb key symbol to windowing.Key
fn xkbKeyToQuantaKey(keysym: u32) ?windowing.Key {
    return switch (keysym) {
        xkb.XKB_KEY_space => .space,
        xkb.XKB_KEY_apostrophe => .apostrophe,
        xkb.XKB_KEY_comma => .comma,
        xkb.XKB_KEY_minus => .minus,
        xkb.XKB_KEY_period => .period,
        xkb.XKB_KEY_slash => .slash,
        xkb.XKB_KEY_0 => .zero,
        xkb.XKB_KEY_1 => .one,
        xkb.XKB_KEY_2 => .two,
        xkb.XKB_KEY_3 => .three,
        xkb.XKB_KEY_4 => .four,
        xkb.XKB_KEY_5 => .five,
        xkb.XKB_KEY_6 => .six,
        xkb.XKB_KEY_7 => .seven,
        xkb.XKB_KEY_8 => .eight,
        xkb.XKB_KEY_9 => .nine,
        xkb.XKB_KEY_semicolon => .semicolon,
        xkb.XKB_KEY_equal => .equal,
        xkb.XKB_KEY_a => .a,
        xkb.XKB_KEY_b => .b,
        xkb.XKB_KEY_c => .c,
        xkb.XKB_KEY_d => .d,
        xkb.XKB_KEY_E, xkb.XKB_KEY_e => .e,
        xkb.XKB_KEY_f => .f,
        xkb.XKB_KEY_g => .g,
        xkb.XKB_KEY_h => .h,
        xkb.XKB_KEY_i => .i,
        xkb.XKB_KEY_j => .j,
        xkb.XKB_KEY_k => .k,
        xkb.XKB_KEY_l => .l,
        xkb.XKB_KEY_m => .m,
        xkb.XKB_KEY_n => .n,
        xkb.XKB_KEY_o => .o,
        xkb.XKB_KEY_p => .p,
        xkb.XKB_KEY_q => .q,
        xkb.XKB_KEY_r => .r,
        xkb.XKB_KEY_s => .s,
        xkb.XKB_KEY_t => .t,
        xkb.XKB_KEY_u => .u,
        xkb.XKB_KEY_v => .v,
        xkb.XKB_KEY_W, xkb.XKB_KEY_w => .w,
        xkb.XKB_KEY_x => .x,
        xkb.XKB_KEY_y => .y,
        xkb.XKB_KEY_z => .z,
        xkb.XKB_KEY_botleftsqbracket => .left_bracket,
        xkb.XKB_KEY_backslash => .backslash,
        xkb.XKB_KEY_botrightsqbracket => .right_bracket,
        xkb.XKB_KEY_grave => .grave_accent,
        xkb.XKB_KEY_Escape => .escape,
        xkb.XKB_KEY_Return => .enter,
        xkb.XKB_KEY_Tab => .tab,
        xkb.XKB_KEY_BackSpace => .backspace,
        xkb.XKB_KEY_Insert => .insert,
        xkb.XKB_KEY_Delete => .delete,
        xkb.XKB_KEY_Right => .right,
        xkb.XKB_KEY_Left => .left,
        xkb.XKB_KEY_Down => .down,
        xkb.XKB_KEY_Up => .up,
        xkb.XKB_KEY_Page_Up => .page_up,
        xkb.XKB_KEY_Page_Down => .page_down,
        xkb.XKB_KEY_Home => .home,
        xkb.XKB_KEY_End => .end,
        xkb.XKB_KEY_Caps_Lock => .caps_lock,
        xkb.XKB_KEY_Scroll_Lock => .scroll_lock,
        xkb.XKB_KEY_Num_Lock => .num_lock,
        xkb.XKB_KEY_Print => .print_screen,
        xkb.XKB_KEY_Pause => .pause,
        xkb.XKB_KEY_F1 => .F1,
        xkb.XKB_KEY_F2 => .F2,
        xkb.XKB_KEY_F3 => .F3,
        xkb.XKB_KEY_F4 => .F4,
        xkb.XKB_KEY_F5 => .F5,
        xkb.XKB_KEY_F6 => .F6,
        xkb.XKB_KEY_F7 => .F7,
        xkb.XKB_KEY_F8 => .F8,
        xkb.XKB_KEY_F9 => .F9,
        xkb.XKB_KEY_F10 => .F10,
        xkb.XKB_KEY_F11 => .F11,
        xkb.XKB_KEY_F12 => .F12,
        xkb.XKB_KEY_F13 => .F13,
        xkb.XKB_KEY_F14 => .F14,
        xkb.XKB_KEY_F15 => .F15,
        xkb.XKB_KEY_F16 => .F16,
        xkb.XKB_KEY_F17 => .F17,
        xkb.XKB_KEY_F18 => .F18,
        xkb.XKB_KEY_F19 => .F19,
        xkb.XKB_KEY_F20 => .F20,
        xkb.XKB_KEY_F21 => .F21,
        xkb.XKB_KEY_F22 => .F22,
        xkb.XKB_KEY_F23 => .F23,
        xkb.XKB_KEY_F24 => .F24,
        xkb.XKB_KEY_F25 => .F25,
        xkb.XKB_KEY_KP_0 => .kp_0,
        xkb.XKB_KEY_KP_1 => .kp_1,
        xkb.XKB_KEY_KP_2 => .kp_2,
        xkb.XKB_KEY_KP_3 => .kp_3,
        xkb.XKB_KEY_KP_4 => .kp_4,
        xkb.XKB_KEY_KP_5 => .kp_5,
        xkb.XKB_KEY_KP_6 => .kp_6,
        xkb.XKB_KEY_KP_7 => .kp_7,
        xkb.XKB_KEY_KP_8 => .kp_8,
        xkb.XKB_KEY_KP_9 => .kp_9,
        xkb.XKB_KEY_KP_Decimal => .kp_decimal,
        xkb.XKB_KEY_KP_Divide => .kp_divide,
        xkb.XKB_KEY_KP_Multiply => .kp_multiply,
        xkb.XKB_KEY_KP_Subtract => .kp_subtract,
        xkb.XKB_KEY_KP_Add => .kp_add,
        xkb.XKB_KEY_KP_Enter => .kp_enter,
        xkb.XKB_KEY_KP_Equal => .kp_equal,
        xkb.XKB_KEY_Shift_L => .left_shift,
        xkb.XKB_KEY_Control_L => .left_control,
        xkb.XKB_KEY_Alt_L => .left_alt,
        xkb.XKB_KEY_Super_L => .left_super,
        xkb.XKB_KEY_Shift_R => .right_shift,
        xkb.XKB_KEY_Control_R => .right_control,
        xkb.XKB_KEY_Alt_R => .right_alt,
        xkb.XKB_KEY_Super_R => .right_super,
        xkb.XKB_KEY_Menu => .menu,
        else => null,
    };
}

const XcbWindow = @This();
const XcbWindowSystem = @import("XcbWindowSystem.zig");
const std = @import("std");
const windowing = @import("../../windowing.zig");
const Key = windowing.Key;
const Action = windowing.Action;
const xcb = @import("xcb.zig");
const xkb = @import("xkbcommon.zig");
const xcb_input = @import("xinput.zig");
const xcb_loader = @import("xcb_loader.zig");
