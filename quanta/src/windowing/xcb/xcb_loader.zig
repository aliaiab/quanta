//Handwritten binding for xcb, with dynamic loading facilities

pub const Library = struct {
    functions: struct {
        connect: *const fn (displayname: ?[*:0]const u8, screenp: ?*i32) callconv(.C) ?*Connection,
        disconnect: *const fn (c: *Connection) callconv(.C) void,
        get_setup: *const fn (c: *Connection) callconv(.C) ?*const Setup,
        setup_roots_iterator: *const fn (R: *const Setup) callconv(.C) ScreenIterator,
        generate_id: *const fn (c: *Connection) callconv(.C) u32,
        create_window: *const fn (
            c: *Connection,
            depth: u8,
            wid: Window,
            parent: Window,
            x: i16,
            y: i16,
            width: u16,
            height: u16,
            border_width: u16,
            _class: u16,
            visual: VisualId,
            value_mask: u32,
            value_list: ?*const anyopaque,
        ) callconv(.C) VoidCookie,
        change_property: *const fn (
            c: *Connection,
            mode: u8,
            window: Window,
            property: Atom,
            @"type": Atom,
            format: u8,
            data_len: u32,
            data: ?*const anyopaque,
        ) callconv(.C) VoidCookie,
        intern_atom: *const fn (
            c: *Connection,
            only_if_exists: bool,
            name_len: u16,
            name: [*]const u8,
        ) callconv(.C) InternAtomCookie,
        intern_atom_reply: *const fn (c: *Connection, cookie: InternAtomCookie, e: ?[*][*]GenericError) callconv(.C) *InternAtomReply,
        create_pixmap: *const fn (c: *Connection, depth: u8, pid: Pixmap, drawable: Drawable, width: u16, height: u16) callconv(.C) VoidCookie,
        free_pixmap: *const fn (c: *Connection, pixmap: Pixmap) callconv(.C) VoidCookie,
        create_cursor: *const fn (
            c: *Connection,
            cid: Cursor,
            source: Pixmap,
            mask: Pixmap,
            fore_red: u16,
            fore_green: u16,
            fore_blue: u16,
            back_red: u16,
            back_green: u16,
            back_blue: u16,
            x: u16,
            y: u16,
        ) callconv(.C) VoidCookie,
        map_window: *const fn (c: *Connection, window: Window) callconv(.C) VoidCookie,
        flush: *const fn (c: *Connection) callconv(.C) i32,
        get_geometry: *const fn (c: *Connection, drawable: Drawable) callconv(.C) GetGeometryCookie,
        get_geometry_reply: *const fn (c: *Connection, cookie: GetGeometryCookie, e: ?[*][*]GenericError) callconv(.C) *GetGeometryReply,
        wait_for_event: *const fn (c: *Connection) callconv(.C) ?*GenericEvent,
        poll_for_event: *const fn (c: *Connection) callconv(.C) ?*GenericEvent,
        grab_pointer: *const fn (
            c: *Connection,
            owner_events: u8,
            grab_window: Window,
            event_mask: u16,
            pointer_mode: u8,
            keyboard_mode: u8,
            confine_to: Window,
            cursor: Cursor,
            time: Timestamp,
        ) callconv(.C) GrabPointerCookie,
        grab_pointer_reply: *const fn (c: *Connection, cookie: GrabPointerCookie, e: ?[*][*]GenericError) callconv(.C) *GrabPointerReply,
        ungrab_pointer: *const fn (c: *Connection, time: Timestamp) callconv(.C) VoidCookie,
        change_window_attributes: *const fn (c: *Connection, window: Window, value_mask: u32, value_list: ?*const anyopaque) callconv(.C) VoidCookie,
        query_pointer: *const fn (c: *Connection, window: Window) callconv(.C) QueryPointerCookie,
        query_pointer_reply: *const fn (c: *Connection, cookie: QueryPointerCookie, e: ?[*][*]GenericError) callconv(.C) *QueryPointerReply,
        warp_pointer: *const fn (c: *Connection, src_window: Window, dst_window: Window, src_x: i16, src_y: i16, src_width: u16, src_height: u16, dst_x: i16, dst_y: i16) callconv(.C) VoidCookie,
        get_input_focus_unchecked: *const fn (c: *Connection) callconv(.C) GetInputFocusCookie,
        get_input_focus_reply: *const fn (c: *Connection, cookie: GetInputFocusCookie, e: ?[*][*]GenericError) callconv(.C) *GetInputFocusReply,
        query_extension: *const fn (c: *Connection, name_len: u16, name: [*]const u8) callconv(.C) QueryExtensionCookie,
        query_extension_reply: *const fn (c: *Connection, cookie: QueryExtensionCookie, e: ?[*][*]GenericError) callconv(.C) *QueryExtensionReply,
    },

    dynamic_library: std.DynLib,

    pub fn load() !Library {
        var library: Library = undefined;

        library.dynamic_library = try std.DynLib.open("libxcb.so");
        errdefer library.dynamic_library.close();

        inline for (comptime std.meta.fieldNames(@TypeOf(library.functions))) |field_name| {
            @field(library.functions, field_name) = library.dynamic_library.lookup(@TypeOf(@field(library.functions, field_name)), "xcb_" ++ field_name).?;
        }

        return library;
    }

    pub fn unload(self: *Library) void {
        self.dynamic_library.close();
        self.* = undefined;
    }

    pub inline fn connect(self: @This(), displayname: ?[*:0]const u8, screenp: ?*i32) ?*Connection {
        return self.functions.connect(displayname, screenp);
    }

    pub inline fn disconnect(self: @This(), connection: *Connection) void {
        return self.functions.disconnect(connection);
    }

    pub inline fn queryExtension(self: @This(), connection: *Connection, name: []const u8) QueryExtensionReply {
        const cookie = self.functions.query_extension(connection, @intCast(name.len), name.ptr);

        return self.functions.query_extension_reply(connection, cookie, null).*;
    }

    pub inline fn getSetup(self: @This(), connection: *Connection) ?*const Setup {
        return self.functions.get_setup(connection);
    }

    pub inline fn setupRootsIterator(self: @This(), setup: *const Setup) ScreenIterator {
        return self.functions.setup_roots_iterator(setup);
    }

    pub inline fn createWindow(
        self: @This(),
        connection: *Connection,
        depth: u8,
        parent: Window,
        x: i16,
        y: i16,
        width: u16,
        height: u16,
        border_width: u16,
        class: u16,
        visual: VisualId,
        value_mask: u32,
        value_list: ?*const anyopaque,
    ) Window {
        const window: Window = @enumFromInt(self.functions.generate_id(connection));

        _ = self.functions.create_window(
            connection,
            depth,
            window,
            parent,
            x,
            y,
            width,
            height,
            border_width,
            class,
            visual,
            value_mask,
            value_list,
        );

        return window;
    }

    pub inline fn changeProperty(
        self: @This(),
        connection: *Connection,
        mode: u8,
        window: Window,
        property: Atom,
        @"type": Atom,
        format: u8,
        data_len: u32,
        data: ?*const anyopaque,
    ) void {
        _ = self.functions.change_property(
            connection,
            mode,
            window,
            property,
            @"type",
            format,
            data_len,
            data,
        );
    }

    pub inline fn internAtom(
        self: @This(),
        connection: *Connection,
        only_if_exists: bool,
        name: []const u8,
    ) *InternAtomReply {
        const cookie = self.functions.intern_atom(
            connection,
            only_if_exists,
            @intCast(name.len),
            name.ptr,
        );

        return self.functions.intern_atom_reply(connection, cookie, null);
    }

    pub inline fn createPixmap(
        self: @This(),
        connection: *Connection,
        depth: u8,
        drawable: Drawable,
        width: u16,
        height: u16,
    ) Pixmap {
        const pixmap: Pixmap = @enumFromInt(self.functions.generate_id(connection));

        _ = self.functions.create_pixmap(connection, depth, pixmap, drawable, width, height);

        return pixmap;
    }

    pub inline fn freePixmap(self: @This(), connection: *Connection, pixmap: Pixmap) void {
        _ = self.functions.free_pixmap(connection, pixmap);
    }

    pub inline fn createCursor(
        self: @This(),
        connection: *Connection,
        source: Pixmap,
        mask: Pixmap,
        fore_red: u16,
        fore_green: u16,
        fore_blue: u16,
        back_red: u16,
        back_green: u16,
        back_blue: u16,
        x: u16,
        y: u16,
    ) Cursor {
        const cursor: Cursor = @enumFromInt(self.functions.generate_id(connection));

        _ = self.functions.create_cursor(
            connection,
            cursor,
            source,
            mask,
            fore_red,
            fore_green,
            fore_blue,
            back_red,
            back_green,
            back_blue,
            x,
            y,
        );

        return cursor;
    }

    pub inline fn freeCursor(self: @This(), connection: *Connection, cursor: Cursor) void {
        _ = self; // autofix
        _ = connection; // autofix
        _ = cursor; // autofix

        @compileError("not implemented");
    }

    pub inline fn mapWindow(self: @This(), connection: *Connection, window: Window) void {
        _ = self.functions.map_window(connection, window);
    }

    pub inline fn flush(self: @This(), connection: *Connection) i32 {
        return self.functions.flush(connection);
    }

    pub inline fn getGeometry(self: @This(), connection: *Connection, drawable: Drawable) GetGeometryReply {
        const cookie = self.functions.get_geometry(connection, drawable);

        return self.functions.get_geometry_reply(connection, cookie, null).*;
    }

    pub inline fn waitForEvent(self: @This(), connection: *Connection) ?*GenericEvent {
        _ = self; // autofix
        _ = connection; // autofix
    }

    pub inline fn pollForEvent(self: @This(), connection: *Connection) ?Event {
        const generic_event = self.functions.poll_for_event(connection);

        if (generic_event == null) return null;

        defer std.c.free(generic_event.?);

        return eventFromGenericEvent(generic_event.?);
    }

    pub inline fn queryPointer(self: @This(), connection: *Connection, window: Window) QueryPointerReply {
        const cookie = self.functions.query_pointer(connection, window);

        return self.functions.query_pointer_reply(connection, cookie, null).*;
    }

    pub inline fn grabPointer(
        self: @This(),
        connection: *Connection,
        owner_events: u8,
        grab_window: Window,
        event_mask: u16,
        pointer_mode: u8,
        keyboard_mode: u8,
        confine_to: Window,
        cursor: Cursor,
        time: Timestamp,
    ) GrabPointerReply {
        const cookie = self.functions.grab_pointer(
            connection,
            owner_events,
            grab_window,
            event_mask,
            pointer_mode,
            keyboard_mode,
            confine_to,
            cursor,
            time,
        );

        return self.functions.grab_pointer_reply(connection, cookie, null).*;
    }

    pub inline fn ungrabPointer(self: @This(), connection: *Connection, time: Timestamp) void {
        _ = self.functions.ungrab_pointer(connection, time);
    }

    pub inline fn changeWindowAttributes(
        self: @This(),
        connection: *Connection,
        window: Window,
        value_mask: u32,
        value_list: ?*const anyopaque,
    ) void {
        _ = self.functions.change_window_attributes(connection, window, value_mask, value_list);
    }

    pub inline fn warpPointer(
        self: @This(),
        connection: *Connection,
        src_window: Window,
        dst_window: Window,
        src_x: i16,
        src_y: i16,
        src_width: u16,
        src_height: u16,
        dst_x: i16,
        dst_y: i16,
    ) void {
        _ = self.functions.warp_pointer(
            connection,
            src_window,
            dst_window,
            src_x,
            src_y,
            src_width,
            src_height,
            dst_x,
            dst_y,
        );
    }

    pub inline fn getInputFocus(
        self: @This(),
        connection: *Connection,
    ) GetInputFocusReply {
        const cookie = self.functions.get_input_focus_unchecked(connection);

        return self.functions.get_input_focus_reply(connection, cookie, null).*;
    }
};

pub const Connection = opaque {};

pub const Setup = extern struct {
    status: u8,
    pad0: u8,
    protocol_major_version: u16,
    protocol_minor_version: u16,
    length: u16,
    release_number: u32,
    resource_id_base: u32,
    resource_id_mask: u32,
    motion_buffer_size: u32,
    vendor_len: u16,
    maximum_request_length: u16,
    roots_len: u8,
    pixmap_formats_len: u8,
    image_byte_order: u8,
    bitmap_format_bit_order: u8,
    bitmap_format_scanline_unit: u8,
    bitmap_format_scanline_pad: u8,
    min_keycode: KeyCode,
    max_keycode: KeyCode,
    pad1: [4]u8,
};

pub const ScreenIterator = extern struct {
    data: [*]Screen,
    rem: i32,
    index: i32,
};

pub const Screen = extern struct {
    root: Window,
    default_colormap: ColorMap,
    white_pixel: u32,
    black_pixel: u32,
    current_input_masks: u32,
    width_in_pixels: u16,
    height_in_pixels: u16,
    width_in_millimeters: u16,
    height_in_millimeters: u16,
    min_installed_maps: u16,
    max_installed_maps: u16,
    root_visual: VisualId,
    backing_stores: u8,
    save_unders: u8,
    root_depth: u8,
    allowed_depths_len: u8,
};

pub const GenericError = extern struct {
    response_type: u8,
    error_code: u8,
    sequence: u16,
    resource_id: u32,
    minor_code: u16,
    major_code: u8,
    pad0: u8,
    pad: [5]u32,
    full_sequence: u32,
};

pub const Window = enum(u32) { _ };
pub const Drawable = enum(u32) { _ };
pub const Pixmap = enum(u32) { _ };
pub const ColorMap = enum(u32) { _ };
pub const VisualId = enum(u32) { _ };

pub const Atom = enum(u32) {
    none = 0,
    primary = 1,
    secondary = 2,
    arc = 3,
    atom = 4,
    bitmap = 5,
    cardinal = 6,
    colormap = 7,
    cursor = 8,
    cut_buffer0 = 9,
    cut_buffer1 = 10,
    cut_buffer2 = 11,
    cut_buffer3 = 12,
    cut_buffer4 = 13,
    cut_buffer5 = 14,
    cut_buffer6 = 15,
    cut_buffer7 = 16,
    drawable = 17,
    font = 18,
    integer = 19,
    pixmap = 20,
    point = 21,
    rectangle = 22,
    resource_manager = 23,
    rgb_color_map = 24,
    rgb_best_map = 25,
    rgb_blue_map = 26,
    rgb_default_map = 27,
    rgb_gray_map = 28,
    rgb_green_map = 29,
    rgb_red_map = 30,
    string = 31,
    visualid = 32,
    window = 33,
    wm_command = 34,
    wm_hints = 35,
    wm_client_machine = 36,
    wm_icon_name = 37,
    wm_icon_size = 38,
    wm_name = 39,
    wm_normal_hints = 40,
    wm_size_hints = 41,
    wm_zoom_hints = 42,
    min_space = 43,
    norm_space = 44,
    max_space = 45,
    end_space = 46,
    SUPERSCRIPT_X = 47,
    SUPERSCRIPT_Y = 48,
    SUBSCRIPT_X = 49,
    SUBSCRIPT_Y = 50,
    UNDERLINE_POSITION = 51,
    UNDERLINE_THICKNESS = 52,
    STRIKEOUT_ASCENT = 53,
    STRIKEOUT_DESCENT = 54,
    ITALIC_ANGLE = 55,
    X_HEIGHT = 56,
    QUAD_WIDTH = 57,
    WEIGHT = 58,
    POINT_SIZE = 59,
    RESOLUTION = 60,
    COPYRIGHT = 61,
    NOTICE = 62,
    FONT_NAME = 63,
    FAMILY_NAME = 64,
    FULL_NAME = 65,
    CAP_HEIGHT = 66,
    WM_CLASS = 67,
    WM_TRANSIENT_FOR = 68,
    _,
};

pub const Cursor = enum(u32) { _ };

pub const KeyCode = u8;

pub const Timestamp = u32;

pub const VoidCookie = extern struct {
    sequence: u32,
};

pub const InternAtomCookie = extern struct {
    sequence: u32,
};

pub const InternAtomReply = extern struct {
    response_type: u8,
    pad0: u8,
    sequence: u16,
    length: u32,
    atom: Atom,
};

pub const GetGeometryCookie = extern struct {
    sequence: u32,
};

pub const GetGeometryReply = extern struct {
    response_type: u8,
    depth: u8,
    sequence: u16,
    length: u32,
    root: Window,
    x: i16,
    y: i16,
    width: u16,
    height: u16,
    border_width: u16,
    pad0: [2]u8,
};

pub const GrabPointerCookie = extern struct {
    sequence: u32,
};

pub const GrabPointerReply = extern struct {
    response_type: u8,
    status: u8,
    sequence: u16,
    length: u32,
};

pub const QueryPointerCookie = extern struct {
    sequence: u32,
};

pub const QueryPointerReply = extern struct {
    response_type: u8,
    same_screen: u8,
    sequence: u16,
    length: u32,
    root: Window,
    child: Window,
    root_x: i16,
    root_y: i16,
    win_x: i16,
    win_y: i16,
    mask: u16,
    pad0: [2]u8,
};

pub const GetInputFocusCookie = extern struct {
    sequence: u32,
};

pub const GetInputFocusReply = extern struct {
    response_type: u8,
    revert_to: u8,
    sequence: u16,
    length: u32,
    focus: Window,
};

pub const QueryExtensionCookie = extern struct {
    sequence: u32,
};

pub const QueryExtensionReply = extern struct {
    response_type: u8,
    pad0: u8,
    sequence: u16,
    length: u32,
    present: u8,
    major_opcode: u8,
    first_event: u8,
    first_error: u8,
};

pub const GenericEvent = extern struct {
    response_type: u8,
    extension: u8,
    sequence: u16,
    length: u32,
    event_type: u16,
    pad0: [22]u8,
    full_sequence: u32,
};

pub const Event = union(enum) {
    none: void,
    button_press: ButtonPress,
    button_release: ButtonRelease,
    key_press: KeyPress,
    key_release: KeyRelease,
    motion_notify: MotionNotify,
    enter_notify: EnterNotify,
    leave_notify: void,
    configure_notify: void,
    client_message: ClientMessage,
    xinput_raw_mouse_motion: XInputRawMouseMotion,

    pub const ButtonPress = extern struct {
        response_type: u8,
        detail: Button,
        sequence: u16,
        time: Timestamp,
        root: Window,
        event: Window,
        child: Window,
        root_x: i16,
        root_y: i16,
        event_x: i16,
        event_y: i16,
        state: u16,
        same_screen: u8,
        pad0: u8,
    };

    pub const ButtonRelease = extern struct {
        response_type: u8,
        detail: Button,
        sequence: u16,
        time: Timestamp,
        root: Window,
        event: Window,
        child: Window,
        root_x: i16,
        root_y: i16,
        event_x: i16,
        event_y: i16,
        state: u16,
        same_screen: u8,
        pad0: u8,
    };

    pub const KeyPress = extern struct {
        response_type: u8,
        detail: KeyCode,
        sequence: u16,
        time: Timestamp,
        root: Window,
        event: Window,
        child: Window,
        root_x: i16,
        root_y: i16,
        event_x: i16,
        event_y: i16,
        state: u16,
        same_screen: u8,
        pad0: u8,
    };

    pub const KeyRelease = extern struct {
        response_type: u8,
        detail: KeyCode,
        sequence: u16,
        time: Timestamp,
        root: Window,
        event: Window,
        child: Window,
        root_x: i16,
        root_y: i16,
        event_x: i16,
        event_y: i16,
        state: u16,
        same_screen: u8,
        pad0: u8,
    };

    pub const MotionNotify = extern struct {
        response_type: u8,
        detail: u8,
        sequence: u16,
        time: Timestamp,
        root: Window,
        event: Window,
        child: Window,
        root_x: i16,
        root_y: i16,
        event_x: i16,
        event_y: i16,
        state: u16,
        same_screen: u8,
        pad0: u8,
    };

    pub const EnterNotify = extern struct {
        response_type: u8,
        detail: u8,
        sequence: u16,
        time: Timestamp,
        root: Window,
        event: Window,
        child: Window,
        root_x: i16,
        root_y: i16,
        event_x: i16,
        event_y: i16,
        state: u16,
        mode: u8,
        same_screen_focus: u8,
    };

    pub const ClientMessage = extern struct {
        response_type: u8,
        format: u8,
        sequence: u16,
        window: Window,
        type: Atom,
        data: extern union {
            data8: [20]u8,
            data16: [10]u16,
            data32: [5]u32,
        },
    };

    pub const XInputRawMouseMotion = extern struct {
        response_type: u8,
        extension: u8,
        sequence: u16,
        length: u32,
        event_type: u16,
        deviceid: XInputDeviceId,
        time: Timestamp,
        detail: u32,
        sourceid: XInputDeviceId,
        valuators_len: u16,
        flags: u32,
        pad0: [4]u8,
        full_sequence: u32,
    };
};

pub const XInputDeviceId = u16;

pub const Button = enum(u8) {
    index_1 = 1,
    index_2 = 2,
    index_3 = 3,
    index_4 = 4,
    index_5 = 5,
};

fn eventFromGenericEvent(generic_event: *GenericEvent) Event {
    switch (generic_event.response_type & ~@as(u8, 0x80)) {
        xcb_c.XCB_BUTTON_PRESS => {
            const event: *Event.ButtonPress = @ptrCast(generic_event);

            return .{
                .button_press = event.*,
            };
        },
        xcb_c.XCB_BUTTON_RELEASE => {
            const event: *Event.ButtonRelease = @ptrCast(generic_event);

            return .{
                .button_release = event.*,
            };
        },
        xcb_c.XCB_KEY_PRESS => {
            const event: *Event.KeyPress = @ptrCast(generic_event);

            return .{
                .key_press = event.*,
            };
        },
        xcb_c.XCB_KEY_RELEASE => {
            const event: *Event.KeyRelease = @ptrCast(generic_event);

            return .{
                .key_release = event.*,
            };
        },
        xcb_c.XCB_MOTION_NOTIFY => {
            const event: *Event.MotionNotify = @ptrCast(generic_event);

            return .{
                .motion_notify = event.*,
            };
        },
        xcb_c.XCB_ENTER_NOTIFY => {
            const event: *Event.EnterNotify = @ptrCast(generic_event);

            return .{
                .enter_notify = event.*,
            };
        },
        xcb_c.XCB_LEAVE_NOTIFY => {},
        xcb_c.XCB_CONFIGURE_NOTIFY => {},
        xcb_c.XCB_CLIENT_MESSAGE => {
            const event: *Event.ClientMessage = @ptrCast(generic_event);

            return .{
                .client_message = event.*,
            };
        },
        xcb_input.XCB_INPUT_RAW_MOTION => {
            const event: *Event.XInputRawMouseMotion = @ptrCast(generic_event);

            return .{
                .xinput_raw_mouse_motion = event.*,
            };
        },
        else => return .none,
    }

    return .none;
}

const std = @import("std");
const xcb_c = @import("xcb.zig");
const xcb_input = @import("xinput.zig");
