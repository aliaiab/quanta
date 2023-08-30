connection: *xcb.xcb_connection_t,
screen: *xcb.xcb_screen_t,
window: xcb.xcb_window_t,
keysym_mapping: []keysyms.XKey,
min_keycode: u32,

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
        .min_keycode = 0,
        .keysym_mapping = &.{},
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

    _ = xcb.xcb_map_window(self.connection, self.window);

    self.min_keycode = setup.*.min_keycode;

    const keyboard_mapping = xcb.xcb_get_keyboard_mapping(self.connection, setup.*.min_keycode, setup.*.max_keycode - setup.*.min_keycode + 1);

    const keyboard_mapping_reply = xcb.xcb_get_keyboard_mapping_reply(self.connection, keyboard_mapping, null);

    std.debug.assert(keyboard_mapping_reply != null);

    const mapping_length: usize = @intCast(xcb.xcb_get_keyboard_mapping_keysyms_length(keyboard_mapping_reply));

    self.keysym_mapping = @as([*]keysyms.XKey, @ptrCast(xcb.xcb_get_keyboard_mapping_keysyms(keyboard_mapping_reply)))[0..mapping_length];

    for (self.keysym_mapping, 0..) |key_sym, i| {
        switch (key_sym) {
            .w => {
                std.log.info("[sym = {}] KEY_W keycode = {}", .{ key_sym, setup.*.min_keycode + i });
            },
            .W => {
                std.log.info("[sym = {}] KEY_A keycode = {}", .{ key_sym, setup.*.min_keycode + i });
            },
            else => {
                std.log.info("[sym = {x}] keycode = {x}", .{ key_sym, setup.*.min_keycode + i });
            },
        }
    }

    if (false) std.os.exit(0);

    _ = xcb.xcb_flush(self.connection);

    return self;
}

pub fn deinit(self: *XcbWindow, allocator: std.mem.Allocator) void {
    _ = allocator;
    xcb.xcb_disconnect(self.connection);

    self.* = undefined;
}

pub fn pollEvents(self: XcbWindow) !void {
    //key_actions: *[std.meta.fields(Key).len]Action
    while (@as(?*xcb.xcb_generic_event_t, @ptrCast(xcb.xcb_poll_for_event(self.connection)))) |event| {
        switch (event.response_type & ~@as(u8, 0x80)) {
            xcb.XCB_BUTTON_PRESS => {
                std.log.info("XCB: button pressed", .{});
            },
            xcb.XCB_KEY_PRESS => {
                std.log.info("XCB: key pressed", .{});
                const key_event: *xcb.xcb_key_press_event_t = @ptrCast(event);

                //w = 127

                const key_sym = self.keysym_mapping[self.min_keycode + key_event.detail];

                switch (key_sym) {
                    .w => {
                        std.log.info("pressed w?", .{});
                    },
                    else => {
                        std.log.info("key sym = {}", .{key_sym});
                        std.log.info("key code = {x}", .{self.min_keycode + key_event.detail});
                    },
                }
            },
            else => {},
        }
        std.c.free(event);
    }
}

const XcbWindow = @This();
const xcb = @import("xcb.zig");
const std = @import("std");
const windowing = @import("../../windowing.zig");
const Key = windowing.Key;
const Action = windowing.Action;
const keysyms = @import("keysyms.zig");
const xkb = @import("xkbcommon.zig");
