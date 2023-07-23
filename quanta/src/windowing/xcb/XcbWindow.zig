connection: *xcb.xcb_connection_t,
screen: *xcb.xcb_screen_t,
window: xcb.xcb_window_t,

pub fn init() !XcbWindow {
    var self = XcbWindow{
        .connection = undefined,
        .screen = undefined,
        .window = 0,
    };

    self.connection = xcb.xcb_connect(null, null).?;

    const setup = xcb.xcb_get_setup(self.connection);
    var iter = xcb.xcb_setup_roots_iterator(setup);
    self.screen = @ptrCast(iter.data);

    self.window = xcb.xcb_generate_id(self.connection);

    const values = [_]u32{
        xcb.XCB_EVENT_MASK_EXPOSURE | xcb.XCB_EVENT_MASK_BUTTON_PRESS |
            xcb.XCB_EVENT_MASK_BUTTON_RELEASE | xcb.XCB_EVENT_MASK_POINTER_MOTION |
            xcb.XCB_EVENT_MASK_ENTER_WINDOW | xcb.XCB_EVENT_MASK_LEAVE_WINDOW |
            xcb.XCB_EVENT_MASK_KEY_PRESS | xcb.XCB_EVENT_MASK_KEY_RELEASE,
    };

    _ = xcb.xcb_create_window(
        self.connection,
        xcb.XCB_COPY_FROM_PARENT,
        self.window,
        self.screen.root,
        0,
        0,
        640,
        480,
        10,
        xcb.XCB_WINDOW_CLASS_INPUT_OUTPUT,
        self.screen.root_visual,
        xcb.XCB_CW_EVENT_MASK,
        &values,
    );

    const title = "XcbWindow";

    _ = xcb.xcb_change_property(
        self.connection,
        xcb.XCB_PROP_MODE_REPLACE,
        self.window,
        xcb.XCB_ATOM_WM_NAME,
        xcb.XCB_ATOM_STRING,
        8,
        @intCast(title.len),
        title,
    );

    _ = xcb.xcb_map_window(self.connection, self.window);

    _ = xcb.xcb_flush(self.connection);

    return self;
}

pub fn deinit(self: *XcbWindow) void {
    self.* = undefined;

    xcb.xcb_disconnect(self.connection);
}

pub fn pollEvents(self: XcbWindow) void {
    while (@as(?*xcb.xcb_generic_event_t, @ptrCast(xcb.xcb_poll_for_event(self.connection)))) |event| {
        switch (event.response_type & ~@as(u8, 0x80)) {
            xcb.XCB_BUTTON_PRESS => {
                std.log.info("XCB: button pressed", .{});
            },
            xcb.XCB_KEY_PRESS => {
                std.log.info("XCB: key pressed", .{});
            },
            else => {},
        }
        std.c.free(event);
    }
}

const XcbWindow = @This();
const xcb = @import("xcb.zig");
const std = @import("std");
