width: u16,
height: u16,
connection: *xcb.xcb_connection_t,
screen: *xcb.xcb_screen_t,
window: xcb.xcb_window_t,
wm_delete_window_cookie: [*c]xcb.xcb_intern_atom_reply_t,
xkb_context: *xkb.xkb_context,
xkb_state: *xkb.xkb_state,
xkb_keymap: *xkb.xkb_keymap,
hidden_cursor: xkb.xcb_cursor_t,

key_map: [std.enums.values(windowing.Key).len]bool,
previous_key_map: [std.enums.values(windowing.Key).len]bool,

mouse_map: [std.enums.values(windowing.MouseButton).len]bool,

mouse_position: @Vector(2, i16) = .{ 0, 0 },
last_mouse_position: @Vector(2, i16) = .{ 0, 0 },
mouse_grabbed: bool = false,

pub fn init(
    allocator: std.mem.Allocator,
    width: u16,
    height: u16,
    title: []const u8,
) !XcbWindow {
    _ = allocator;
    var self = XcbWindow{
        .connection = undefined,
        .screen = undefined,
        .window = 0,
        .width = width,
        .height = height,
        .wm_delete_window_cookie = undefined,
        .xkb_context = undefined,
        .xkb_state = undefined,
        .xkb_keymap = undefined,
        .key_map = std.mem.zeroes([std.enums.values(windowing.Key).len]bool),
        .previous_key_map = std.mem.zeroes([std.enums.values(windowing.Key).len]bool),
        .mouse_map = std.mem.zeroes([std.enums.values(windowing.MouseButton).len]bool),
        .hidden_cursor = undefined,
    };

    self.connection = xcb.xcb_connect(null, null).?;

    const setup = xcb.xcb_get_setup(self.connection);

    const iter = xcb.xcb_setup_roots_iterator(setup);

    self.screen = @ptrCast(iter.data);

    self.window = xcb.xcb_generate_id(self.connection);

    const values = [_]u32{
        xcb.XCB_EVENT_MASK_EXPOSURE | xcb.XCB_EVENT_MASK_BUTTON_PRESS |
            xcb.XCB_EVENT_MASK_BUTTON_RELEASE | xcb.XCB_EVENT_MASK_POINTER_MOTION |
            xcb.XCB_EVENT_MASK_ENTER_WINDOW | xcb.XCB_EVENT_MASK_LEAVE_WINDOW |
            xcb.XCB_EVENT_MASK_KEY_PRESS | xcb.XCB_EVENT_MASK_KEY_RELEASE | xcb.XCB_EVENT_MASK_PROPERTY_CHANGE |
            xcb.XCB_EVENT_MASK_STRUCTURE_NOTIFY | xcb.XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY | xcb.XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | xcb.XCB_EVENT_MASK_VISIBILITY_CHANGE |
            xcb.XCB_EVENT_MASK_ENTER_WINDOW | xcb.XCB_EVENT_MASK_FOCUS_CHANGE | xcb.XCB_EVENT_MASK_OWNER_GRAB_BUTTON | xcb.XCB_EVENT_MASK_POINTER_MOTION_HINT,
    };

    _ = xcb.xcb_create_window(
        self.connection,
        xcb.XCB_COPY_FROM_PARENT,
        self.window,
        self.screen.root,
        0,
        0,
        width,
        height,
        10,
        xcb.XCB_WINDOW_CLASS_INPUT_OUTPUT,
        self.screen.root_visual,
        xcb.XCB_CW_EVENT_MASK,
        &values,
    );

    _ = xcb.xcb_change_property(
        self.connection,
        xcb.XCB_PROP_MODE_REPLACE,
        self.window,
        xcb.XCB_ATOM_WM_NAME,
        xcb.XCB_ATOM_STRING,
        8,
        @intCast(title.len),
        title.ptr,
    );

    const wm_delete_window_cookie_name = "WM_DELETE_WINDOW";

    const cookie0 = xcb.xcb_intern_atom(self.connection, 1, 12, "WM_PROTOCOLS");
    const reply0 = xcb.xcb_intern_atom_reply(self.connection, cookie0, null);

    const cookie = xcb.xcb_intern_atom(self.connection, 0, wm_delete_window_cookie_name.len + 1, wm_delete_window_cookie_name);
    self.wm_delete_window_cookie = xcb.xcb_intern_atom_reply(self.connection, cookie, null);

    _ = xcb.xcb_change_property(self.connection, xcb.XCB_PROP_MODE_REPLACE, self.window, reply0.*.atom, 4, 32, 1, &reply0.*.atom);

    self.xkb_context = xkb.xkb_context_new(xkb.XKB_CONTEXT_NO_FLAGS).?;
    self.xkb_keymap = xkb.xkb_keymap_new_from_names(self.xkb_context, null, xkb.XKB_KEYMAP_COMPILE_NO_FLAGS).?;
    self.xkb_state = xkb.xkb_state_new(self.xkb_keymap).?;

    const hidden_cursor_pixmap = xcb.xcb_generate_id(self.connection);

    _ = xcb.xcb_create_pixmap(self.connection, 1, hidden_cursor_pixmap, self.window, 1, 1);

    self.hidden_cursor = xcb.xcb_generate_id(self.connection);

    _ = xcb.xcb_create_cursor(self.connection, self.hidden_cursor, hidden_cursor_pixmap, hidden_cursor_pixmap, 0, 0, 0, 0, 0, 0, 0, 0);
    _ = xcb.xcb_free_pixmap(self.connection, hidden_cursor_pixmap);

    _ = xcb.xcb_set_close_down_mode(self.connection, xcb.XCB_CLOSE_DOWN_DESTROY_ALL);

    _ = xcb.xcb_map_window(self.connection, self.window);
    _ = xcb.xcb_flush(self.connection);

    return self;
}

pub fn deinit(self: *XcbWindow, allocator: std.mem.Allocator) void {
    _ = allocator;
    xcb.xcb_disconnect(self.connection);
    xkb.xkb_context_unref(self.xkb_context);
    xkb.xkb_state_unref(self.xkb_state);
    xkb.xkb_keymap_unref(self.xkb_keymap);

    self.* = undefined;
}

///return false if we need to close
pub fn pollEvents(self: *XcbWindow) !bool {
    self.previous_key_map = self.key_map;

    {
        const cookie = xcb.xcb_query_pointer(self.connection, self.window);

        const reply = xcb.xcb_query_pointer_reply(self.connection, cookie, null);
        _ = reply;

        // self.mouse_position = .{ @abs(reply.*.win_x), @abs(reply.*.win_y) };
    }

    {
        const cookie = xcb.xcb_get_geometry(self.connection, self.window);
        const reply = xcb.xcb_get_geometry_reply(self.connection, cookie, null);

        self.width = reply.*.width;
        self.height = reply.*.height;
    }

    while (@as(?*xcb.xcb_generic_event_t, @ptrCast(xcb.xcb_poll_for_event(self.connection)))) |event| {
        switch (event.response_type & ~@as(u8, 0x80)) {
            xcb.XCB_BUTTON_PRESS => {
                const button_press_event: *xcb.xcb_button_press_event_t = @ptrCast(event);

                const position: @Vector(2, u16) = .{ @abs(button_press_event.event_x), @abs(button_press_event.event_y) };

                std.log.info("XCB: button pressed at {}", .{position});

                switch (button_press_event.detail) {
                    xcb.XCB_BUTTON_INDEX_1 => self.mouse_map[@intFromEnum(windowing.MouseButton.left)] = true,
                    xcb.XCB_BUTTON_INDEX_2 => self.mouse_map[@intFromEnum(windowing.MouseButton.right)] = true,
                    xcb.XCB_BUTTON_INDEX_3 => self.mouse_map[@intFromEnum(windowing.MouseButton.middle)] = true,
                    else => {},
                }
            },
            xcb.XCB_BUTTON_RELEASE => {
                const button_release_event: *xcb.xcb_button_release_event_t = @ptrCast(event);

                switch (button_release_event.detail) {
                    xcb.XCB_BUTTON_INDEX_1 => self.mouse_map[@intFromEnum(windowing.MouseButton.left)] = false,
                    xcb.XCB_BUTTON_INDEX_2 => self.mouse_map[@intFromEnum(windowing.MouseButton.right)] = false,
                    xcb.XCB_BUTTON_INDEX_3 => self.mouse_map[@intFromEnum(windowing.MouseButton.middle)] = false,
                    else => {},
                }
            },
            xcb.XCB_KEY_PRESS => {
                const key_event: *xcb.xcb_key_press_event_t = @ptrCast(event);

                const keysym = xkb.xkb_state_key_get_one_sym(self.xkb_state, key_event.detail);

                switch (keysym) {
                    xkb.XKB_KEY_space => self.key_map[@intFromEnum(windowing.Key.space)] = true,
                    xkb.XKB_KEY_apostrophe => self.key_map[@intFromEnum(windowing.Key.apostrophe)] = true,
                    xkb.XKB_KEY_comma => self.key_map[@intFromEnum(windowing.Key.comma)] = true,
                    xkb.XKB_KEY_minus => self.key_map[@intFromEnum(windowing.Key.minus)] = true,
                    xkb.XKB_KEY_period => self.key_map[@intFromEnum(windowing.Key.period)] = true,
                    xkb.XKB_KEY_slash => self.key_map[@intFromEnum(windowing.Key.slash)] = true,
                    xkb.XKB_KEY_0 => self.key_map[@intFromEnum(windowing.Key.zero)] = true,
                    xkb.XKB_KEY_1 => self.key_map[@intFromEnum(windowing.Key.one)] = true,
                    xkb.XKB_KEY_2 => self.key_map[@intFromEnum(windowing.Key.two)] = true,
                    xkb.XKB_KEY_3 => self.key_map[@intFromEnum(windowing.Key.three)] = true,
                    xkb.XKB_KEY_4 => self.key_map[@intFromEnum(windowing.Key.four)] = true,
                    xkb.XKB_KEY_5 => self.key_map[@intFromEnum(windowing.Key.five)] = true,
                    xkb.XKB_KEY_6 => self.key_map[@intFromEnum(windowing.Key.six)] = true,
                    xkb.XKB_KEY_7 => self.key_map[@intFromEnum(windowing.Key.seven)] = true,
                    xkb.XKB_KEY_8 => self.key_map[@intFromEnum(windowing.Key.eight)] = true,
                    xkb.XKB_KEY_9 => self.key_map[@intFromEnum(windowing.Key.nine)] = true,
                    xkb.XKB_KEY_semicolon => self.key_map[@intFromEnum(windowing.Key.semicolon)] = true,
                    xkb.XKB_KEY_equal => self.key_map[@intFromEnum(windowing.Key.equal)] = true,
                    xkb.XKB_KEY_a => self.key_map[@intFromEnum(windowing.Key.a)] = true,
                    xkb.XKB_KEY_b => self.key_map[@intFromEnum(windowing.Key.b)] = true,
                    xkb.XKB_KEY_c => self.key_map[@intFromEnum(windowing.Key.c)] = true,
                    xkb.XKB_KEY_d => self.key_map[@intFromEnum(windowing.Key.d)] = true,
                    xkb.XKB_KEY_E, xkb.XKB_KEY_e => self.key_map[@intFromEnum(windowing.Key.e)] = true,
                    xkb.XKB_KEY_f => self.key_map[@intFromEnum(windowing.Key.f)] = true,
                    xkb.XKB_KEY_g => self.key_map[@intFromEnum(windowing.Key.g)] = true,
                    xkb.XKB_KEY_h => self.key_map[@intFromEnum(windowing.Key.h)] = true,
                    xkb.XKB_KEY_i => self.key_map[@intFromEnum(windowing.Key.i)] = true,
                    xkb.XKB_KEY_j => self.key_map[@intFromEnum(windowing.Key.j)] = true,
                    xkb.XKB_KEY_k => self.key_map[@intFromEnum(windowing.Key.k)] = true,
                    xkb.XKB_KEY_l => self.key_map[@intFromEnum(windowing.Key.l)] = true,
                    xkb.XKB_KEY_m => self.key_map[@intFromEnum(windowing.Key.m)] = true,
                    xkb.XKB_KEY_n => self.key_map[@intFromEnum(windowing.Key.n)] = true,
                    xkb.XKB_KEY_o => self.key_map[@intFromEnum(windowing.Key.o)] = true,
                    xkb.XKB_KEY_p => self.key_map[@intFromEnum(windowing.Key.p)] = true,
                    xkb.XKB_KEY_q => self.key_map[@intFromEnum(windowing.Key.q)] = true,
                    xkb.XKB_KEY_r => self.key_map[@intFromEnum(windowing.Key.r)] = true,
                    xkb.XKB_KEY_s => self.key_map[@intFromEnum(windowing.Key.s)] = true,
                    xkb.XKB_KEY_t => self.key_map[@intFromEnum(windowing.Key.t)] = true,
                    xkb.XKB_KEY_u => self.key_map[@intFromEnum(windowing.Key.u)] = true,
                    xkb.XKB_KEY_v => self.key_map[@intFromEnum(windowing.Key.v)] = true,
                    xkb.XKB_KEY_W, xkb.XKB_KEY_w => self.key_map[@intFromEnum(windowing.Key.w)] = true,
                    xkb.XKB_KEY_x => self.key_map[@intFromEnum(windowing.Key.x)] = true,
                    xkb.XKB_KEY_y => self.key_map[@intFromEnum(windowing.Key.y)] = true,
                    xkb.XKB_KEY_z => self.key_map[@intFromEnum(windowing.Key.z)] = true,
                    xkb.XKB_KEY_botleftsqbracket => self.key_map[@intFromEnum(windowing.Key.left_bracket)] = true,
                    xkb.XKB_KEY_backslash => self.key_map[@intFromEnum(windowing.Key.backslash)] = true,
                    xkb.XKB_KEY_botrightsqbracket => self.key_map[@intFromEnum(windowing.Key.right_bracket)] = true,
                    xkb.XKB_KEY_grave => self.key_map[@intFromEnum(windowing.Key.grave_accent)] = true,
                    // world_1,
                    // world_2,
                    xkb.XKB_KEY_Escape => self.key_map[@intFromEnum(windowing.Key.escape)] = true,
                    xkb.XKB_KEY_Return => self.key_map[@intFromEnum(windowing.Key.enter)] = true,
                    xkb.XKB_KEY_Tab => self.key_map[@intFromEnum(windowing.Key.tab)] = true,
                    xkb.XKB_KEY_BackSpace => self.key_map[@intFromEnum(windowing.Key.backspace)] = true,
                    xkb.XKB_KEY_Insert => self.key_map[@intFromEnum(windowing.Key.insert)] = true,
                    xkb.XKB_KEY_Delete => self.key_map[@intFromEnum(windowing.Key.delete)] = true,
                    xkb.XKB_KEY_Right => self.key_map[@intFromEnum(windowing.Key.right)] = true,
                    xkb.XKB_KEY_Left => self.key_map[@intFromEnum(windowing.Key.left)] = true,
                    xkb.XKB_KEY_Down => self.key_map[@intFromEnum(windowing.Key.down)] = true,
                    xkb.XKB_KEY_Up => self.key_map[@intFromEnum(windowing.Key.up)] = true,
                    xkb.XKB_KEY_Page_Up => self.key_map[@intFromEnum(windowing.Key.page_up)] = true,
                    xkb.XKB_KEY_Page_Down => self.key_map[@intFromEnum(windowing.Key.page_down)] = true,
                    xkb.XKB_KEY_Home => self.key_map[@intFromEnum(windowing.Key.home)] = true,
                    xkb.XKB_KEY_End => self.key_map[@intFromEnum(windowing.Key.end)] = true,
                    xkb.XKB_KEY_Caps_Lock => self.key_map[@intFromEnum(windowing.Key.caps_lock)] = true,
                    xkb.XKB_KEY_Scroll_Lock => self.key_map[@intFromEnum(windowing.Key.scroll_lock)] = true,
                    xkb.XKB_KEY_Num_Lock => self.key_map[@intFromEnum(windowing.Key.num_lock)] = true,
                    xkb.XKB_KEY_Print => self.key_map[@intFromEnum(windowing.Key.print_screen)] = true,
                    xkb.XKB_KEY_Pause => self.key_map[@intFromEnum(windowing.Key.pause)] = true,
                    xkb.XKB_KEY_F1 => self.key_map[@intFromEnum(windowing.Key.F1)] = true,
                    xkb.XKB_KEY_F2 => self.key_map[@intFromEnum(windowing.Key.F2)] = true,
                    xkb.XKB_KEY_F3 => self.key_map[@intFromEnum(windowing.Key.F3)] = true,
                    xkb.XKB_KEY_F4 => self.key_map[@intFromEnum(windowing.Key.F4)] = true,
                    xkb.XKB_KEY_F5 => self.key_map[@intFromEnum(windowing.Key.F5)] = true,
                    xkb.XKB_KEY_F6 => self.key_map[@intFromEnum(windowing.Key.F6)] = true,
                    xkb.XKB_KEY_F7 => self.key_map[@intFromEnum(windowing.Key.F7)] = true,
                    xkb.XKB_KEY_F8 => self.key_map[@intFromEnum(windowing.Key.F8)] = true,
                    xkb.XKB_KEY_F9 => self.key_map[@intFromEnum(windowing.Key.F9)] = true,
                    xkb.XKB_KEY_F10 => self.key_map[@intFromEnum(windowing.Key.F10)] = true,
                    xkb.XKB_KEY_F11 => self.key_map[@intFromEnum(windowing.Key.F11)] = true,
                    xkb.XKB_KEY_F12 => self.key_map[@intFromEnum(windowing.Key.F12)] = true,
                    xkb.XKB_KEY_F13 => self.key_map[@intFromEnum(windowing.Key.F13)] = true,
                    xkb.XKB_KEY_F14 => self.key_map[@intFromEnum(windowing.Key.F14)] = true,
                    xkb.XKB_KEY_F15 => self.key_map[@intFromEnum(windowing.Key.F15)] = true,
                    xkb.XKB_KEY_F16 => self.key_map[@intFromEnum(windowing.Key.F16)] = true,
                    xkb.XKB_KEY_F17 => self.key_map[@intFromEnum(windowing.Key.F17)] = true,
                    xkb.XKB_KEY_F18 => self.key_map[@intFromEnum(windowing.Key.F18)] = true,
                    xkb.XKB_KEY_F19 => self.key_map[@intFromEnum(windowing.Key.F19)] = true,
                    xkb.XKB_KEY_F20 => self.key_map[@intFromEnum(windowing.Key.F20)] = true,
                    xkb.XKB_KEY_F21 => self.key_map[@intFromEnum(windowing.Key.F21)] = true,
                    xkb.XKB_KEY_F22 => self.key_map[@intFromEnum(windowing.Key.F22)] = true,
                    xkb.XKB_KEY_F23 => self.key_map[@intFromEnum(windowing.Key.F23)] = true,
                    xkb.XKB_KEY_F24 => self.key_map[@intFromEnum(windowing.Key.F24)] = true,
                    xkb.XKB_KEY_F25 => self.key_map[@intFromEnum(windowing.Key.F25)] = true,
                    xkb.XKB_KEY_KP_0 => self.key_map[@intFromEnum(windowing.Key.kp_0)] = true,
                    xkb.XKB_KEY_KP_1 => self.key_map[@intFromEnum(windowing.Key.kp_1)] = true,
                    xkb.XKB_KEY_KP_2 => self.key_map[@intFromEnum(windowing.Key.kp_2)] = true,
                    xkb.XKB_KEY_KP_3 => self.key_map[@intFromEnum(windowing.Key.kp_3)] = true,
                    xkb.XKB_KEY_KP_4 => self.key_map[@intFromEnum(windowing.Key.kp_4)] = true,
                    xkb.XKB_KEY_KP_5 => self.key_map[@intFromEnum(windowing.Key.kp_5)] = true,
                    xkb.XKB_KEY_KP_6 => self.key_map[@intFromEnum(windowing.Key.kp_6)] = true,
                    xkb.XKB_KEY_KP_7 => self.key_map[@intFromEnum(windowing.Key.kp_7)] = true,
                    xkb.XKB_KEY_KP_8 => self.key_map[@intFromEnum(windowing.Key.kp_8)] = true,
                    xkb.XKB_KEY_KP_9 => self.key_map[@intFromEnum(windowing.Key.kp_9)] = true,
                    xkb.XKB_KEY_KP_Decimal => self.key_map[@intFromEnum(windowing.Key.kp_decimal)] = true,
                    xkb.XKB_KEY_KP_Divide => self.key_map[@intFromEnum(windowing.Key.kp_divide)] = true,
                    xkb.XKB_KEY_KP_Multiply => self.key_map[@intFromEnum(windowing.Key.kp_multiply)] = true,
                    xkb.XKB_KEY_KP_Subtract => self.key_map[@intFromEnum(windowing.Key.kp_subtract)] = true,
                    xkb.XKB_KEY_KP_Add => self.key_map[@intFromEnum(windowing.Key.kp_add)] = true,
                    xkb.XKB_KEY_KP_Enter => self.key_map[@intFromEnum(windowing.Key.kp_enter)] = true,
                    xkb.XKB_KEY_KP_Equal => self.key_map[@intFromEnum(windowing.Key.kp_equal)] = true,
                    xkb.XKB_KEY_Shift_L => self.key_map[@intFromEnum(windowing.Key.left_shift)] = true,
                    xkb.XKB_KEY_Control_L => self.key_map[@intFromEnum(windowing.Key.left_control)] = true,
                    xkb.XKB_KEY_Alt_L => self.key_map[@intFromEnum(windowing.Key.left_alt)] = true,
                    xkb.XKB_KEY_Super_L => self.key_map[@intFromEnum(windowing.Key.left_super)] = true,
                    xkb.XKB_KEY_Shift_R => self.key_map[@intFromEnum(windowing.Key.right_shift)] = true,
                    xkb.XKB_KEY_Control_R => self.key_map[@intFromEnum(windowing.Key.right_control)] = true,
                    xkb.XKB_KEY_Alt_R => self.key_map[@intFromEnum(windowing.Key.right_alt)] = true,
                    xkb.XKB_KEY_Super_R => self.key_map[@intFromEnum(windowing.Key.right_super)] = true,
                    xkb.XKB_KEY_Menu => self.key_map[@intFromEnum(windowing.Key.menu)] = true,
                    else => {},
                }
            },
            xcb.XCB_KEY_RELEASE => {
                const key_event: *xcb.xcb_key_release_event_t = @ptrCast(event);

                const keysym = xkb.xkb_state_key_get_one_sym(self.xkb_state, key_event.detail);

                switch (keysym) {
                    xkb.XKB_KEY_space => self.key_map[@intFromEnum(windowing.Key.space)] = false,
                    xkb.XKB_KEY_apostrophe => self.key_map[@intFromEnum(windowing.Key.apostrophe)] = false,
                    xkb.XKB_KEY_comma => self.key_map[@intFromEnum(windowing.Key.comma)] = false,
                    xkb.XKB_KEY_minus => self.key_map[@intFromEnum(windowing.Key.minus)] = false,
                    xkb.XKB_KEY_period => self.key_map[@intFromEnum(windowing.Key.period)] = false,
                    xkb.XKB_KEY_slash => self.key_map[@intFromEnum(windowing.Key.slash)] = false,
                    xkb.XKB_KEY_0 => self.key_map[@intFromEnum(windowing.Key.zero)] = false,
                    xkb.XKB_KEY_1 => self.key_map[@intFromEnum(windowing.Key.one)] = false,
                    xkb.XKB_KEY_2 => self.key_map[@intFromEnum(windowing.Key.two)] = false,
                    xkb.XKB_KEY_3 => self.key_map[@intFromEnum(windowing.Key.three)] = false,
                    xkb.XKB_KEY_4 => self.key_map[@intFromEnum(windowing.Key.four)] = false,
                    xkb.XKB_KEY_5 => self.key_map[@intFromEnum(windowing.Key.five)] = false,
                    xkb.XKB_KEY_6 => self.key_map[@intFromEnum(windowing.Key.six)] = false,
                    xkb.XKB_KEY_7 => self.key_map[@intFromEnum(windowing.Key.seven)] = false,
                    xkb.XKB_KEY_8 => self.key_map[@intFromEnum(windowing.Key.eight)] = false,
                    xkb.XKB_KEY_9 => self.key_map[@intFromEnum(windowing.Key.nine)] = false,
                    xkb.XKB_KEY_semicolon => self.key_map[@intFromEnum(windowing.Key.semicolon)] = false,
                    xkb.XKB_KEY_equal => self.key_map[@intFromEnum(windowing.Key.equal)] = false,
                    xkb.XKB_KEY_a => self.key_map[@intFromEnum(windowing.Key.a)] = false,
                    xkb.XKB_KEY_b => self.key_map[@intFromEnum(windowing.Key.b)] = false,
                    xkb.XKB_KEY_c => self.key_map[@intFromEnum(windowing.Key.c)] = false,
                    xkb.XKB_KEY_d => self.key_map[@intFromEnum(windowing.Key.d)] = false,
                    xkb.XKB_KEY_E, xkb.XKB_KEY_e => self.key_map[@intFromEnum(windowing.Key.e)] = false,
                    xkb.XKB_KEY_f => self.key_map[@intFromEnum(windowing.Key.f)] = false,
                    xkb.XKB_KEY_g => self.key_map[@intFromEnum(windowing.Key.g)] = false,
                    xkb.XKB_KEY_h => self.key_map[@intFromEnum(windowing.Key.h)] = false,
                    xkb.XKB_KEY_i => self.key_map[@intFromEnum(windowing.Key.i)] = false,
                    xkb.XKB_KEY_j => self.key_map[@intFromEnum(windowing.Key.j)] = false,
                    xkb.XKB_KEY_k => self.key_map[@intFromEnum(windowing.Key.k)] = false,
                    xkb.XKB_KEY_l => self.key_map[@intFromEnum(windowing.Key.l)] = false,
                    xkb.XKB_KEY_m => self.key_map[@intFromEnum(windowing.Key.m)] = false,
                    xkb.XKB_KEY_n => self.key_map[@intFromEnum(windowing.Key.n)] = false,
                    xkb.XKB_KEY_o => self.key_map[@intFromEnum(windowing.Key.o)] = false,
                    xkb.XKB_KEY_p => self.key_map[@intFromEnum(windowing.Key.p)] = false,
                    xkb.XKB_KEY_q => self.key_map[@intFromEnum(windowing.Key.q)] = false,
                    xkb.XKB_KEY_r => self.key_map[@intFromEnum(windowing.Key.r)] = false,
                    xkb.XKB_KEY_s => self.key_map[@intFromEnum(windowing.Key.s)] = false,
                    xkb.XKB_KEY_t => self.key_map[@intFromEnum(windowing.Key.t)] = false,
                    xkb.XKB_KEY_u => self.key_map[@intFromEnum(windowing.Key.u)] = false,
                    xkb.XKB_KEY_v => self.key_map[@intFromEnum(windowing.Key.v)] = false,
                    xkb.XKB_KEY_w => self.key_map[@intFromEnum(windowing.Key.w)] = false,
                    xkb.XKB_KEY_x => self.key_map[@intFromEnum(windowing.Key.x)] = false,
                    xkb.XKB_KEY_y => self.key_map[@intFromEnum(windowing.Key.y)] = false,
                    xkb.XKB_KEY_z => self.key_map[@intFromEnum(windowing.Key.z)] = false,
                    xkb.XKB_KEY_botleftsqbracket => self.key_map[@intFromEnum(windowing.Key.left_bracket)] = false,
                    xkb.XKB_KEY_backslash => self.key_map[@intFromEnum(windowing.Key.backslash)] = false,
                    xkb.XKB_KEY_botrightsqbracket => self.key_map[@intFromEnum(windowing.Key.right_bracket)] = false,
                    xkb.XKB_KEY_grave => self.key_map[@intFromEnum(windowing.Key.grave_accent)] = false,
                    // world_1,
                    // world_2,
                    xkb.XKB_KEY_Escape => self.key_map[@intFromEnum(windowing.Key.escape)] = false,
                    xkb.XKB_KEY_Return => self.key_map[@intFromEnum(windowing.Key.enter)] = false,
                    xkb.XKB_KEY_Tab => self.key_map[@intFromEnum(windowing.Key.tab)] = false,
                    xkb.XKB_KEY_BackSpace => self.key_map[@intFromEnum(windowing.Key.backspace)] = false,
                    xkb.XKB_KEY_Insert => self.key_map[@intFromEnum(windowing.Key.insert)] = false,
                    xkb.XKB_KEY_Delete => self.key_map[@intFromEnum(windowing.Key.delete)] = false,
                    xkb.XKB_KEY_Right => self.key_map[@intFromEnum(windowing.Key.right)] = false,
                    xkb.XKB_KEY_Left => self.key_map[@intFromEnum(windowing.Key.left)] = false,
                    xkb.XKB_KEY_Down => self.key_map[@intFromEnum(windowing.Key.down)] = false,
                    xkb.XKB_KEY_Up => self.key_map[@intFromEnum(windowing.Key.up)] = false,
                    xkb.XKB_KEY_Page_Up => self.key_map[@intFromEnum(windowing.Key.page_up)] = false,
                    xkb.XKB_KEY_Page_Down => self.key_map[@intFromEnum(windowing.Key.page_down)] = false,
                    xkb.XKB_KEY_Home => self.key_map[@intFromEnum(windowing.Key.home)] = false,
                    xkb.XKB_KEY_End => self.key_map[@intFromEnum(windowing.Key.end)] = false,
                    xkb.XKB_KEY_Caps_Lock => self.key_map[@intFromEnum(windowing.Key.caps_lock)] = false,
                    xkb.XKB_KEY_Scroll_Lock => self.key_map[@intFromEnum(windowing.Key.scroll_lock)] = false,
                    xkb.XKB_KEY_Num_Lock => self.key_map[@intFromEnum(windowing.Key.num_lock)] = false,
                    xkb.XKB_KEY_Print => self.key_map[@intFromEnum(windowing.Key.print_screen)] = false,
                    xkb.XKB_KEY_Pause => self.key_map[@intFromEnum(windowing.Key.pause)] = false,
                    xkb.XKB_KEY_F1 => self.key_map[@intFromEnum(windowing.Key.F1)] = false,
                    xkb.XKB_KEY_F2 => self.key_map[@intFromEnum(windowing.Key.F2)] = false,
                    xkb.XKB_KEY_F3 => self.key_map[@intFromEnum(windowing.Key.F3)] = false,
                    xkb.XKB_KEY_F4 => self.key_map[@intFromEnum(windowing.Key.F4)] = false,
                    xkb.XKB_KEY_F5 => self.key_map[@intFromEnum(windowing.Key.F5)] = false,
                    xkb.XKB_KEY_F6 => self.key_map[@intFromEnum(windowing.Key.F6)] = false,
                    xkb.XKB_KEY_F7 => self.key_map[@intFromEnum(windowing.Key.F7)] = false,
                    xkb.XKB_KEY_F8 => self.key_map[@intFromEnum(windowing.Key.F8)] = false,
                    xkb.XKB_KEY_F9 => self.key_map[@intFromEnum(windowing.Key.F9)] = false,
                    xkb.XKB_KEY_F10 => self.key_map[@intFromEnum(windowing.Key.F10)] = false,
                    xkb.XKB_KEY_F11 => self.key_map[@intFromEnum(windowing.Key.F11)] = false,
                    xkb.XKB_KEY_F12 => self.key_map[@intFromEnum(windowing.Key.F12)] = false,
                    xkb.XKB_KEY_F13 => self.key_map[@intFromEnum(windowing.Key.F13)] = false,
                    xkb.XKB_KEY_F14 => self.key_map[@intFromEnum(windowing.Key.F14)] = false,
                    xkb.XKB_KEY_F15 => self.key_map[@intFromEnum(windowing.Key.F15)] = false,
                    xkb.XKB_KEY_F16 => self.key_map[@intFromEnum(windowing.Key.F16)] = false,
                    xkb.XKB_KEY_F17 => self.key_map[@intFromEnum(windowing.Key.F17)] = false,
                    xkb.XKB_KEY_F18 => self.key_map[@intFromEnum(windowing.Key.F18)] = false,
                    xkb.XKB_KEY_F19 => self.key_map[@intFromEnum(windowing.Key.F19)] = false,
                    xkb.XKB_KEY_F20 => self.key_map[@intFromEnum(windowing.Key.F20)] = false,
                    xkb.XKB_KEY_F21 => self.key_map[@intFromEnum(windowing.Key.F21)] = false,
                    xkb.XKB_KEY_F22 => self.key_map[@intFromEnum(windowing.Key.F22)] = false,
                    xkb.XKB_KEY_F23 => self.key_map[@intFromEnum(windowing.Key.F23)] = false,
                    xkb.XKB_KEY_F24 => self.key_map[@intFromEnum(windowing.Key.F24)] = false,
                    xkb.XKB_KEY_F25 => self.key_map[@intFromEnum(windowing.Key.F25)] = false,
                    xkb.XKB_KEY_KP_0 => self.key_map[@intFromEnum(windowing.Key.kp_0)] = false,
                    xkb.XKB_KEY_KP_1 => self.key_map[@intFromEnum(windowing.Key.kp_1)] = false,
                    xkb.XKB_KEY_KP_2 => self.key_map[@intFromEnum(windowing.Key.kp_2)] = false,
                    xkb.XKB_KEY_KP_3 => self.key_map[@intFromEnum(windowing.Key.kp_3)] = false,
                    xkb.XKB_KEY_KP_4 => self.key_map[@intFromEnum(windowing.Key.kp_4)] = false,
                    xkb.XKB_KEY_KP_5 => self.key_map[@intFromEnum(windowing.Key.kp_5)] = false,
                    xkb.XKB_KEY_KP_6 => self.key_map[@intFromEnum(windowing.Key.kp_6)] = false,
                    xkb.XKB_KEY_KP_7 => self.key_map[@intFromEnum(windowing.Key.kp_7)] = false,
                    xkb.XKB_KEY_KP_8 => self.key_map[@intFromEnum(windowing.Key.kp_8)] = false,
                    xkb.XKB_KEY_KP_9 => self.key_map[@intFromEnum(windowing.Key.kp_9)] = false,
                    xkb.XKB_KEY_KP_Decimal => self.key_map[@intFromEnum(windowing.Key.kp_decimal)] = false,
                    xkb.XKB_KEY_KP_Divide => self.key_map[@intFromEnum(windowing.Key.kp_divide)] = false,
                    xkb.XKB_KEY_KP_Multiply => self.key_map[@intFromEnum(windowing.Key.kp_multiply)] = false,
                    xkb.XKB_KEY_KP_Subtract => self.key_map[@intFromEnum(windowing.Key.kp_subtract)] = false,
                    xkb.XKB_KEY_KP_Add => self.key_map[@intFromEnum(windowing.Key.kp_add)] = false,
                    xkb.XKB_KEY_KP_Enter => self.key_map[@intFromEnum(windowing.Key.kp_enter)] = false,
                    xkb.XKB_KEY_KP_Equal => self.key_map[@intFromEnum(windowing.Key.kp_equal)] = false,
                    xkb.XKB_KEY_Shift_L => self.key_map[@intFromEnum(windowing.Key.left_shift)] = false,
                    xkb.XKB_KEY_Control_L => self.key_map[@intFromEnum(windowing.Key.left_control)] = false,
                    xkb.XKB_KEY_Alt_L => self.key_map[@intFromEnum(windowing.Key.left_alt)] = false,
                    xkb.XKB_KEY_Super_L => self.key_map[@intFromEnum(windowing.Key.left_super)] = false,
                    xkb.XKB_KEY_Shift_R => self.key_map[@intFromEnum(windowing.Key.right_shift)] = false,
                    xkb.XKB_KEY_Control_R => self.key_map[@intFromEnum(windowing.Key.right_control)] = false,
                    xkb.XKB_KEY_Alt_R => self.key_map[@intFromEnum(windowing.Key.right_alt)] = false,
                    xkb.XKB_KEY_Super_R => self.key_map[@intFromEnum(windowing.Key.right_super)] = false,
                    xkb.XKB_KEY_Menu => self.key_map[@intFromEnum(windowing.Key.menu)] = false,
                    else => {},
                }
            },
            xcb.XCB_CLIENT_MESSAGE => {
                const client_message_event: *xcb.xcb_client_message_event_t = @ptrCast(event);

                if (client_message_event.data.data32[0] == self.wm_delete_window_cookie.*.atom) {
                    std.log.info("lfklakflakf", .{});
                    return true;
                }
            },
            xcb.XCB_ENTER_NOTIFY => {
                const enter_event: *xcb.xcb_enter_notify_event_t = @ptrCast(event);

                self.last_mouse_position = self.mouse_position;
                self.mouse_position = .{ enter_event.event_x, enter_event.event_y };
            },
            xcb.XCB_MOTION_NOTIFY => {
                const motion_event: *xcb.xcb_motion_notify_event_t = @ptrCast(event);

                std.log.info("event xy = {}, {}", .{ motion_event.event_x, motion_event.event_y });
                std.log.info("root xy = {}, {}", .{ motion_event.event_x, motion_event.root_y });

                self.last_mouse_position = self.mouse_position;

                if (self.mouse_grabbed) {
                    if (motion_event.event_x <= 0) {
                        // _ = xcb.xcb_warp_pointer(self.connection, self.window, self.window, motion_event.event_x, motion_event.event_y, self.getWidth(), self.getHeight(), motion_event.event_x + 100, motion_event.event_y);
                    }

                    // const dxdy = @Vector(2, i16){ motion_event.event_x, motion_event.event_y } - self.last_mouse_position;

                    // self.mouse_position += dxdy;
                    self.mouse_position = .{ motion_event.event_x, motion_event.event_y };
                } else {
                    self.mouse_position = .{ motion_event.event_x, motion_event.event_y };
                }

                // self.last_mouse_position = .{ motion_event.event_x, motion_event.event_y };
            },
            xcb.XCB_MOTION_HINT => {
                std.log.info("motion hint", .{});
            },
            xcb.XCB_DESTROY_NOTIFY => {},
            // xcb.XCB_RESIZE_REQUEST => {
            //     const resize_request_event: *xcb.xcb_resize_request_event_t = @ptrCast(event);

            //     self.width = resize_request_event.width;
            //     self.height = resize_request_event.height;
            // },
            // xcb.XCB_CONFIGURE_NOTIFY => {
            //     const configure_notify_event: *xcb.xcb_configure_notify_event_t = @ptrCast(event);

            //     self.width = configure_notify_event.width;
            //     self.height = configure_notify_event.height;
            // },
            else => {},
        }
        std.c.free(event);
    }

    return false;
}

pub fn shouldClose(self: *XcbWindow) bool {
    return self.pollEvents() catch unreachable;
}

pub fn getWidth(self: XcbWindow) u16 {
    //TODO: store the width properly instead of querying the window system every time these functions are called

    const cookie = xcb.xcb_get_geometry(self.connection, self.window);
    const reply = xcb.xcb_get_geometry_reply(self.connection, cookie, null);

    return reply.*.width;
}

pub fn getHeight(self: XcbWindow) u16 {
    const cookie = xcb.xcb_get_geometry(self.connection, self.window);
    const reply = xcb.xcb_get_geometry_reply(self.connection, cookie, null);

    return reply.*.height;
}

pub fn grabMouse(self: *XcbWindow) void {
    const cookie = xcb.xcb_grab_pointer(self.connection, 1, self.screen.root, xcb.XCB_EVENT_MASK_BUTTON_PRESS | xcb.XCB_EVENT_MASK_BUTTON_RELEASE | xcb.XCB_EVENT_MASK_POINTER_MOTION, xcb.XCB_GRAB_MODE_ASYNC, xcb
        .XCB_GRAB_MODE_ASYNC, self.window, 0, xcb.XCB_CURRENT_TIME);

    _ = xcb.xcb_grab_pointer_reply(self.connection, cookie, null);

    _ = xcb.xcb_change_window_attributes(self.connection, self.window, xcb.XCB_CW_CURSOR, &self.hidden_cursor);

    self.mouse_grabbed = true;
}

pub fn ungrabMouse(self: *XcbWindow) void {
    _ = xcb.xcb_ungrab_pointer(self.connection, xcb.XCB_CURRENT_TIME);
    //setting the cursor id to zero seems to restore the cursor, but this may need to change
    _ = xcb.xcb_change_window_attributes(self.connection, self.window, xcb.XCB_CW_CURSOR, &@as(u32, 0));

    self.mouse_grabbed = false;
}

pub fn getCursorPosition(self: *XcbWindow) @Vector(2, i16) {
    return self.mouse_position;
}

pub fn getKey(self: *XcbWindow, key: windowing.Key) windowing.Action {
    const index = @intFromEnum(key);

    if (!self.key_map[index] and self.previous_key_map[index]) {
        return .press;
    }

    if (self.key_map[index]) {
        return .down;
    }

    return .release;
}

pub fn getMouseButton(self: *XcbWindow, key: windowing.MouseButton) windowing.Action {
    const index = @intFromEnum(key);

    // if (!self.mouse_map[index] and self.previ[index]) {
    // return .press;
    // }

    if (self.mouse_map[index]) {
        return .down;
    }

    return .release;
}

const XcbWindow = @This();
const xcb = @import("xcb.zig");
const std = @import("std");
const windowing = @import("../../windowing.zig");
const Key = windowing.Key;
const Action = windowing.Action;
const xkb = @import("xkbcommon.zig");
