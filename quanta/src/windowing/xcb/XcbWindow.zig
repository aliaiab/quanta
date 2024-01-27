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
mouse_grabbed: bool = false,

//'raw' mouse motion
mouse_motion: @Vector(2, i16) = .{ 0, 0 },

pub fn init(
    allocator: std.mem.Allocator,
    window_system: *XcbWindowSystem,
    width: u16,
    height: u16,
    title: []const u8,
) !XcbWindow {
    _ = allocator;

    var self = XcbWindow{
        .window_system = window_system,
        .connection = window_system.connection,
        .screen = undefined,
        .window = undefined,
        .width = width,
        .height = height,
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

    const values = [_]u32{
        xcb.XCB_EVENT_MASK_EXPOSURE | xcb.XCB_EVENT_MASK_BUTTON_PRESS |
            xcb.XCB_EVENT_MASK_BUTTON_RELEASE | xcb.XCB_EVENT_MASK_POINTER_MOTION |
            xcb.XCB_EVENT_MASK_ENTER_WINDOW | xcb.XCB_EVENT_MASK_LEAVE_WINDOW |
            xcb.XCB_EVENT_MASK_KEY_PRESS | xcb.XCB_EVENT_MASK_KEY_RELEASE | xcb.XCB_EVENT_MASK_PROPERTY_CHANGE |
            xcb.XCB_EVENT_MASK_STRUCTURE_NOTIFY | xcb.XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY | xcb.XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | xcb.XCB_EVENT_MASK_VISIBILITY_CHANGE |
            xcb.XCB_EVENT_MASK_ENTER_WINDOW | xcb.XCB_EVENT_MASK_FOCUS_CHANGE | xcb.XCB_EVENT_MASK_OWNER_GRAB_BUTTON | xcb.XCB_EVENT_MASK_POINTER_MOTION_HINT,
    };

    self.window = self.xcb_library.createWindow(
        self.connection,
        xcb.XCB_COPY_FROM_PARENT,
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

    _ = self.xcb_library.changeProperty(
        self.connection,
        xcb.XCB_PROP_MODE_REPLACE,
        self.window,
        .wm_name,
        .string,
        8,
        @intCast(title.len),
        title.ptr,
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

    {
        const reply = self.xcb_library.queryPointer(self.connection, self.window);
        _ = reply; // autofix

        // self.mouse_position = .{ reply.win_x, reply.win_y };
    }

    {
        // const cookie = xcb.xcb_get_geometry(self.connection, self.window);
        // const reply = xcb.xcb_get_geometry_reply(self.connection, cookie, null);

        // self.width = reply.*.width;
        // self.height = reply.*.height;
    }

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
                    else => {},
                }
            },
            .key_press => |key_press| {
                const keysym = xkb.xkb_state_key_get_one_sym(self.xkb_state, key_press.detail);

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
            .key_release => |key_release| {
                const keysym = xkb.xkb_state_key_get_one_sym(self.xkb_state, key_release.detail);

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
            .motion_notify => |motion_notify| {
                const last_mouse_position = self.mouse_position;
                self.last_mouse_position = last_mouse_position;

                const S = struct {
                    pub var warped: bool = false;
                };

                var warped: bool = false;

                // if (motion_notify.event_x != self.getWidth() / 2 or motion_notify.event_y != self.getHeight() / 2) {
                if (self.mouse_grabbed) {
                    const predicted_position = self.mouse_position + self.mouse_motion;

                    const warped_last = S.warped;
                    _ = warped_last; // autofix

                    if (predicted_position[0] <= 0 or predicted_position[1] <= 0 or
                        predicted_position[0] >= self.getWidth() - 1 or predicted_position[1] >= self.getHeight() - 1)
                    {
                        self.xcb_library.warpPointer(
                            self.connection,
                            self.window,
                            self.window,
                            motion_notify.event_x,
                            motion_notify.event_y,
                            self.getWidth(),
                            self.getHeight(),
                            @intCast(self.getWidth() / 2),
                            @intCast(self.getHeight() / 2),
                            // self.last_mouse_position[0] - self.mouse_motion[0],
                            // self.last_mouse_position[1] - self.mouse_motion[1],
                        );

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
            else => {},
        }
    }

    return false;
}

pub fn shouldClose(self: *XcbWindow) bool {
    return self.pollEvents() catch unreachable;
}

pub fn getWidth(self: XcbWindow) u16 {
    //TODO: store the width properly instead of querying the window system every time these functions are called
    const reply = self.xcb_library.getGeometry(self.connection, @enumFromInt(@intFromEnum(self.window)));

    return reply.width;
}

pub fn getHeight(self: XcbWindow) u16 {
    const reply = self.xcb_library.getGeometry(self.connection, @enumFromInt(@intFromEnum(self.window)));

    return reply.height;
}

pub fn grabCursor(self: *XcbWindow) void {
    _ = self.xcb_library.grabPointer(self.connection, 1, self.screen.root, xcb.XCB_EVENT_MASK_BUTTON_PRESS | xcb.XCB_EVENT_MASK_BUTTON_RELEASE | xcb.XCB_EVENT_MASK_POINTER_MOTION, xcb.XCB_GRAB_MODE_ASYNC, xcb
        .XCB_GRAB_MODE_ASYNC, self.window, @enumFromInt(0), xcb.XCB_CURRENT_TIME);

    self.xcb_library.changeWindowAttributes(self.connection, self.window, xcb.XCB_CW_CURSOR, &self.hidden_cursor);

    self.mouse_grabbed = true;
}

pub fn ungrabCursor(self: *XcbWindow) void {
    self.xcb_library.ungrabPointer(self.connection, xcb.XCB_CURRENT_TIME);

    self.xcb_library.changeWindowAttributes(self.connection, self.window, xcb.XCB_CW_CURSOR, &@as(u32, 0));

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

pub fn getMouseMotion(self: *XcbWindow) @Vector(2, i16) {
    return self.mouse_motion;
}

const XcbWindow = @This();
const XcbWindowSystem = @import("XcbWindowSystem.zig");
const std = @import("std");
const windowing = @import("../../windowing.zig");
const Key = windowing.Key;
const Action = windowing.Action;
const xkb = @import("xkbcommon.zig");
const xcb = @import("xcb.zig");
const xcb_loader = @import("xcb_loader.zig");
