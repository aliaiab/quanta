pub const Library = struct {
    functions: struct {
        xi_select_events_checked: *const fn (
            connection: *xcb_loader.Connection,
            window: xcb_loader.Window,
            num_mask: u16,
            masks: [*]const EventMask,
        ) xcb_loader.VoidCookie,
    },
    dynamic_library: std.DynLib,

    pub fn unload(self: *Library) void {
        self.dynamic_library.close();

        self.* = undefined;
    }

    pub inline fn xiSelectEventsChecked(
        self: *Library,
        connection: *xcb_loader.Connection,
        window: xcb_loader.Window,
        num_masks: u16,
        masks: [*]const EventMask,
    ) void {
        _ = self.functions.xi_select_events_checked(connection, window, num_masks, masks);
    }
};

pub const EventMask = extern struct {
    deviceid: DeviceId,
    mask_len: u16,
};

pub const EventMaskList = extern struct {
    head: EventMask,
    mask: XiEventMask,
};

pub const XiEventMask = packed struct(u32) {
    padding0: u1 = 0,
    device_changed: bool = false,
    key_press: bool = false,
    key_release: bool = false,
    motion: bool = false,
    enter: bool = false,
    leave: bool = false,
    focus_in: bool = false,
    focus_out: bool = false,
    hierarchy: bool = false,
    property: bool = false,
    raw_key_press: bool = false,
    raw_key_release: bool = false,
    raw_button_press: bool = false,
    raw_button_release: bool = false,
    raw_motion: bool = false,
    touch_begin: bool = false,
    touch_update: bool = false,
    touch_end: bool = false,
    touch_ownership: bool = false,
    raw_touch_begin: bool = false,
    raw_touch_update: bool = false,
    raw_touch_end: bool = false,
    barrier_hit: bool = false,
    barrier_leave: bool = false,
    padding1: u7 = 0,
};

pub const DeviceId = enum(u16) {
    all = 0,
    all_master = 1,
    _,
};

pub fn load() !Library {
    var library: Library = undefined;

    const function_prefix = "xcb_input_";

    library.dynamic_library = try std.DynLib.open("libxcb-xinput.so");
    errdefer library.dynamic_library.close();

    inline for (comptime std.meta.fieldNames(@TypeOf(library.functions))) |field_name| {
        @field(library.functions, field_name) = library.dynamic_library.lookup(@TypeOf(@field(library.functions, field_name)), function_prefix ++ field_name).?;
    }

    return library;
}

const std = @import("std");
const xcb_loader = @import("xcb_loader.zig");
