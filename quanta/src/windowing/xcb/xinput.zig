pub const struct_xcb_connection_t = opaque {};
pub const xcb_connection_t = struct_xcb_connection_t;
pub const xcb_generic_iterator_t = extern struct {
    data: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_generic_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_generic_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    pad: [7]u32 = @import("std").mem.zeroes([7]u32),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_raw_generic_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    pad: [7]u32 = @import("std").mem.zeroes([7]u32),
};
pub const xcb_ge_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    pad1: u16 = @import("std").mem.zeroes(u16),
    pad: [5]u32 = @import("std").mem.zeroes([5]u32),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_generic_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    resource_id: u32 = @import("std").mem.zeroes(u32),
    minor_code: u16 = @import("std").mem.zeroes(u16),
    major_code: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    pad: [5]u32 = @import("std").mem.zeroes([5]u32),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_void_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const struct_xcb_char2b_t = extern struct {
    byte1: u8 = @import("std").mem.zeroes(u8),
    byte2: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_char2b_t = struct_xcb_char2b_t;
pub const struct_xcb_char2b_iterator_t = extern struct {
    data: [*c]xcb_char2b_t = @import("std").mem.zeroes([*c]xcb_char2b_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_char2b_iterator_t = struct_xcb_char2b_iterator_t;
pub const xcb_window_t = u32;
pub const struct_xcb_window_iterator_t = extern struct {
    data: [*c]xcb_window_t = @import("std").mem.zeroes([*c]xcb_window_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_window_iterator_t = struct_xcb_window_iterator_t;
pub const xcb_pixmap_t = u32;
pub const struct_xcb_pixmap_iterator_t = extern struct {
    data: [*c]xcb_pixmap_t = @import("std").mem.zeroes([*c]xcb_pixmap_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_pixmap_iterator_t = struct_xcb_pixmap_iterator_t;
pub const xcb_cursor_t = u32;
pub const struct_xcb_cursor_iterator_t = extern struct {
    data: [*c]xcb_cursor_t = @import("std").mem.zeroes([*c]xcb_cursor_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_cursor_iterator_t = struct_xcb_cursor_iterator_t;
pub const xcb_font_t = u32;
pub const struct_xcb_font_iterator_t = extern struct {
    data: [*c]xcb_font_t = @import("std").mem.zeroes([*c]xcb_font_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_font_iterator_t = struct_xcb_font_iterator_t;
pub const xcb_gcontext_t = u32;
pub const struct_xcb_gcontext_iterator_t = extern struct {
    data: [*c]xcb_gcontext_t = @import("std").mem.zeroes([*c]xcb_gcontext_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_gcontext_iterator_t = struct_xcb_gcontext_iterator_t;
pub const xcb_colormap_t = u32;
pub const struct_xcb_colormap_iterator_t = extern struct {
    data: [*c]xcb_colormap_t = @import("std").mem.zeroes([*c]xcb_colormap_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_colormap_iterator_t = struct_xcb_colormap_iterator_t;
pub const xcb_atom_t = u32;
pub const struct_xcb_atom_iterator_t = extern struct {
    data: [*c]xcb_atom_t = @import("std").mem.zeroes([*c]xcb_atom_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_atom_iterator_t = struct_xcb_atom_iterator_t;
pub const xcb_drawable_t = u32;
pub const struct_xcb_drawable_iterator_t = extern struct {
    data: [*c]xcb_drawable_t = @import("std").mem.zeroes([*c]xcb_drawable_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_drawable_iterator_t = struct_xcb_drawable_iterator_t;
pub const xcb_fontable_t = u32;
pub const struct_xcb_fontable_iterator_t = extern struct {
    data: [*c]xcb_fontable_t = @import("std").mem.zeroes([*c]xcb_fontable_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_fontable_iterator_t = struct_xcb_fontable_iterator_t;
pub const xcb_bool32_t = u32;
pub const struct_xcb_bool32_iterator_t = extern struct {
    data: [*c]xcb_bool32_t = @import("std").mem.zeroes([*c]xcb_bool32_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_bool32_iterator_t = struct_xcb_bool32_iterator_t;
pub const xcb_visualid_t = u32;
pub const struct_xcb_visualid_iterator_t = extern struct {
    data: [*c]xcb_visualid_t = @import("std").mem.zeroes([*c]xcb_visualid_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_visualid_iterator_t = struct_xcb_visualid_iterator_t;
pub const xcb_timestamp_t = u32;
pub const struct_xcb_timestamp_iterator_t = extern struct {
    data: [*c]xcb_timestamp_t = @import("std").mem.zeroes([*c]xcb_timestamp_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_timestamp_iterator_t = struct_xcb_timestamp_iterator_t;
pub const xcb_keysym_t = u32;
pub const struct_xcb_keysym_iterator_t = extern struct {
    data: [*c]xcb_keysym_t = @import("std").mem.zeroes([*c]xcb_keysym_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_keysym_iterator_t = struct_xcb_keysym_iterator_t;
pub const xcb_keycode_t = u8;
pub const struct_xcb_keycode_iterator_t = extern struct {
    data: [*c]xcb_keycode_t = @import("std").mem.zeroes([*c]xcb_keycode_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_keycode_iterator_t = struct_xcb_keycode_iterator_t;
pub const xcb_keycode32_t = u32;
pub const struct_xcb_keycode32_iterator_t = extern struct {
    data: [*c]xcb_keycode32_t = @import("std").mem.zeroes([*c]xcb_keycode32_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_keycode32_iterator_t = struct_xcb_keycode32_iterator_t;
pub const xcb_button_t = u8;
pub const struct_xcb_button_iterator_t = extern struct {
    data: [*c]xcb_button_t = @import("std").mem.zeroes([*c]xcb_button_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_button_iterator_t = struct_xcb_button_iterator_t;
pub const struct_xcb_point_t = extern struct {
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_point_t = struct_xcb_point_t;
pub const struct_xcb_point_iterator_t = extern struct {
    data: [*c]xcb_point_t = @import("std").mem.zeroes([*c]xcb_point_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_point_iterator_t = struct_xcb_point_iterator_t;
pub const struct_xcb_rectangle_t = extern struct {
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_rectangle_t = struct_xcb_rectangle_t;
pub const struct_xcb_rectangle_iterator_t = extern struct {
    data: [*c]xcb_rectangle_t = @import("std").mem.zeroes([*c]xcb_rectangle_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_rectangle_iterator_t = struct_xcb_rectangle_iterator_t;
pub const struct_xcb_arc_t = extern struct {
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    angle1: i16 = @import("std").mem.zeroes(i16),
    angle2: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_arc_t = struct_xcb_arc_t;
pub const struct_xcb_arc_iterator_t = extern struct {
    data: [*c]xcb_arc_t = @import("std").mem.zeroes([*c]xcb_arc_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_arc_iterator_t = struct_xcb_arc_iterator_t;
pub const struct_xcb_format_t = extern struct {
    depth: u8 = @import("std").mem.zeroes(u8),
    bits_per_pixel: u8 = @import("std").mem.zeroes(u8),
    scanline_pad: u8 = @import("std").mem.zeroes(u8),
    pad0: [5]u8 = @import("std").mem.zeroes([5]u8),
};
pub const xcb_format_t = struct_xcb_format_t;
pub const struct_xcb_format_iterator_t = extern struct {
    data: [*c]xcb_format_t = @import("std").mem.zeroes([*c]xcb_format_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_format_iterator_t = struct_xcb_format_iterator_t;
pub const XCB_VISUAL_CLASS_STATIC_GRAY: c_int = 0;
pub const XCB_VISUAL_CLASS_GRAY_SCALE: c_int = 1;
pub const XCB_VISUAL_CLASS_STATIC_COLOR: c_int = 2;
pub const XCB_VISUAL_CLASS_PSEUDO_COLOR: c_int = 3;
pub const XCB_VISUAL_CLASS_TRUE_COLOR: c_int = 4;
pub const XCB_VISUAL_CLASS_DIRECT_COLOR: c_int = 5;
pub const enum_xcb_visual_class_t = c_uint;
pub const xcb_visual_class_t = enum_xcb_visual_class_t;
pub const struct_xcb_visualtype_t = extern struct {
    visual_id: xcb_visualid_t = @import("std").mem.zeroes(xcb_visualid_t),
    _class: u8 = @import("std").mem.zeroes(u8),
    bits_per_rgb_value: u8 = @import("std").mem.zeroes(u8),
    colormap_entries: u16 = @import("std").mem.zeroes(u16),
    red_mask: u32 = @import("std").mem.zeroes(u32),
    green_mask: u32 = @import("std").mem.zeroes(u32),
    blue_mask: u32 = @import("std").mem.zeroes(u32),
    pad0: [4]u8 = @import("std").mem.zeroes([4]u8),
};
pub const xcb_visualtype_t = struct_xcb_visualtype_t;
pub const struct_xcb_visualtype_iterator_t = extern struct {
    data: [*c]xcb_visualtype_t = @import("std").mem.zeroes([*c]xcb_visualtype_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_visualtype_iterator_t = struct_xcb_visualtype_iterator_t;
pub const struct_xcb_depth_t = extern struct {
    depth: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    visuals_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [4]u8 = @import("std").mem.zeroes([4]u8),
};
pub const xcb_depth_t = struct_xcb_depth_t;
pub const struct_xcb_depth_iterator_t = extern struct {
    data: [*c]xcb_depth_t = @import("std").mem.zeroes([*c]xcb_depth_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_depth_iterator_t = struct_xcb_depth_iterator_t;
pub const XCB_EVENT_MASK_NO_EVENT: c_int = 0;
pub const XCB_EVENT_MASK_KEY_PRESS: c_int = 1;
pub const XCB_EVENT_MASK_KEY_RELEASE: c_int = 2;
pub const XCB_EVENT_MASK_BUTTON_PRESS: c_int = 4;
pub const XCB_EVENT_MASK_BUTTON_RELEASE: c_int = 8;
pub const XCB_EVENT_MASK_ENTER_WINDOW: c_int = 16;
pub const XCB_EVENT_MASK_LEAVE_WINDOW: c_int = 32;
pub const XCB_EVENT_MASK_POINTER_MOTION: c_int = 64;
pub const XCB_EVENT_MASK_POINTER_MOTION_HINT: c_int = 128;
pub const XCB_EVENT_MASK_BUTTON_1_MOTION: c_int = 256;
pub const XCB_EVENT_MASK_BUTTON_2_MOTION: c_int = 512;
pub const XCB_EVENT_MASK_BUTTON_3_MOTION: c_int = 1024;
pub const XCB_EVENT_MASK_BUTTON_4_MOTION: c_int = 2048;
pub const XCB_EVENT_MASK_BUTTON_5_MOTION: c_int = 4096;
pub const XCB_EVENT_MASK_BUTTON_MOTION: c_int = 8192;
pub const XCB_EVENT_MASK_KEYMAP_STATE: c_int = 16384;
pub const XCB_EVENT_MASK_EXPOSURE: c_int = 32768;
pub const XCB_EVENT_MASK_VISIBILITY_CHANGE: c_int = 65536;
pub const XCB_EVENT_MASK_STRUCTURE_NOTIFY: c_int = 131072;
pub const XCB_EVENT_MASK_RESIZE_REDIRECT: c_int = 262144;
pub const XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY: c_int = 524288;
pub const XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT: c_int = 1048576;
pub const XCB_EVENT_MASK_FOCUS_CHANGE: c_int = 2097152;
pub const XCB_EVENT_MASK_PROPERTY_CHANGE: c_int = 4194304;
pub const XCB_EVENT_MASK_COLOR_MAP_CHANGE: c_int = 8388608;
pub const XCB_EVENT_MASK_OWNER_GRAB_BUTTON: c_int = 16777216;
pub const enum_xcb_event_mask_t = c_uint;
pub const xcb_event_mask_t = enum_xcb_event_mask_t;
pub const XCB_BACKING_STORE_NOT_USEFUL: c_int = 0;
pub const XCB_BACKING_STORE_WHEN_MAPPED: c_int = 1;
pub const XCB_BACKING_STORE_ALWAYS: c_int = 2;
pub const enum_xcb_backing_store_t = c_uint;
pub const xcb_backing_store_t = enum_xcb_backing_store_t;
pub const struct_xcb_screen_t = extern struct {
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    default_colormap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    white_pixel: u32 = @import("std").mem.zeroes(u32),
    black_pixel: u32 = @import("std").mem.zeroes(u32),
    current_input_masks: u32 = @import("std").mem.zeroes(u32),
    width_in_pixels: u16 = @import("std").mem.zeroes(u16),
    height_in_pixels: u16 = @import("std").mem.zeroes(u16),
    width_in_millimeters: u16 = @import("std").mem.zeroes(u16),
    height_in_millimeters: u16 = @import("std").mem.zeroes(u16),
    min_installed_maps: u16 = @import("std").mem.zeroes(u16),
    max_installed_maps: u16 = @import("std").mem.zeroes(u16),
    root_visual: xcb_visualid_t = @import("std").mem.zeroes(xcb_visualid_t),
    backing_stores: u8 = @import("std").mem.zeroes(u8),
    save_unders: u8 = @import("std").mem.zeroes(u8),
    root_depth: u8 = @import("std").mem.zeroes(u8),
    allowed_depths_len: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_screen_t = struct_xcb_screen_t;
pub const struct_xcb_screen_iterator_t = extern struct {
    data: [*c]xcb_screen_t = @import("std").mem.zeroes([*c]xcb_screen_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_screen_iterator_t = struct_xcb_screen_iterator_t;
pub const struct_xcb_setup_request_t = extern struct {
    byte_order: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    protocol_major_version: u16 = @import("std").mem.zeroes(u16),
    protocol_minor_version: u16 = @import("std").mem.zeroes(u16),
    authorization_protocol_name_len: u16 = @import("std").mem.zeroes(u16),
    authorization_protocol_data_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_setup_request_t = struct_xcb_setup_request_t;
pub const struct_xcb_setup_request_iterator_t = extern struct {
    data: [*c]xcb_setup_request_t = @import("std").mem.zeroes([*c]xcb_setup_request_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_setup_request_iterator_t = struct_xcb_setup_request_iterator_t;
pub const struct_xcb_setup_failed_t = extern struct {
    status: u8 = @import("std").mem.zeroes(u8),
    reason_len: u8 = @import("std").mem.zeroes(u8),
    protocol_major_version: u16 = @import("std").mem.zeroes(u16),
    protocol_minor_version: u16 = @import("std").mem.zeroes(u16),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_setup_failed_t = struct_xcb_setup_failed_t;
pub const struct_xcb_setup_failed_iterator_t = extern struct {
    data: [*c]xcb_setup_failed_t = @import("std").mem.zeroes([*c]xcb_setup_failed_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_setup_failed_iterator_t = struct_xcb_setup_failed_iterator_t;
pub const struct_xcb_setup_authenticate_t = extern struct {
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [5]u8 = @import("std").mem.zeroes([5]u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_setup_authenticate_t = struct_xcb_setup_authenticate_t;
pub const struct_xcb_setup_authenticate_iterator_t = extern struct {
    data: [*c]xcb_setup_authenticate_t = @import("std").mem.zeroes([*c]xcb_setup_authenticate_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_setup_authenticate_iterator_t = struct_xcb_setup_authenticate_iterator_t;
pub const XCB_IMAGE_ORDER_LSB_FIRST: c_int = 0;
pub const XCB_IMAGE_ORDER_MSB_FIRST: c_int = 1;
pub const enum_xcb_image_order_t = c_uint;
pub const xcb_image_order_t = enum_xcb_image_order_t;
pub const struct_xcb_setup_t = extern struct {
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    protocol_major_version: u16 = @import("std").mem.zeroes(u16),
    protocol_minor_version: u16 = @import("std").mem.zeroes(u16),
    length: u16 = @import("std").mem.zeroes(u16),
    release_number: u32 = @import("std").mem.zeroes(u32),
    resource_id_base: u32 = @import("std").mem.zeroes(u32),
    resource_id_mask: u32 = @import("std").mem.zeroes(u32),
    motion_buffer_size: u32 = @import("std").mem.zeroes(u32),
    vendor_len: u16 = @import("std").mem.zeroes(u16),
    maximum_request_length: u16 = @import("std").mem.zeroes(u16),
    roots_len: u8 = @import("std").mem.zeroes(u8),
    pixmap_formats_len: u8 = @import("std").mem.zeroes(u8),
    image_byte_order: u8 = @import("std").mem.zeroes(u8),
    bitmap_format_bit_order: u8 = @import("std").mem.zeroes(u8),
    bitmap_format_scanline_unit: u8 = @import("std").mem.zeroes(u8),
    bitmap_format_scanline_pad: u8 = @import("std").mem.zeroes(u8),
    min_keycode: xcb_keycode_t = @import("std").mem.zeroes(xcb_keycode_t),
    max_keycode: xcb_keycode_t = @import("std").mem.zeroes(xcb_keycode_t),
    pad1: [4]u8 = @import("std").mem.zeroes([4]u8),
};
pub const xcb_setup_t = struct_xcb_setup_t;
pub const struct_xcb_setup_iterator_t = extern struct {
    data: [*c]xcb_setup_t = @import("std").mem.zeroes([*c]xcb_setup_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_setup_iterator_t = struct_xcb_setup_iterator_t;
pub const XCB_MOD_MASK_SHIFT: c_int = 1;
pub const XCB_MOD_MASK_LOCK: c_int = 2;
pub const XCB_MOD_MASK_CONTROL: c_int = 4;
pub const XCB_MOD_MASK_1: c_int = 8;
pub const XCB_MOD_MASK_2: c_int = 16;
pub const XCB_MOD_MASK_3: c_int = 32;
pub const XCB_MOD_MASK_4: c_int = 64;
pub const XCB_MOD_MASK_5: c_int = 128;
pub const XCB_MOD_MASK_ANY: c_int = 32768;
pub const enum_xcb_mod_mask_t = c_uint;
pub const xcb_mod_mask_t = enum_xcb_mod_mask_t;
pub const XCB_KEY_BUT_MASK_SHIFT: c_int = 1;
pub const XCB_KEY_BUT_MASK_LOCK: c_int = 2;
pub const XCB_KEY_BUT_MASK_CONTROL: c_int = 4;
pub const XCB_KEY_BUT_MASK_MOD_1: c_int = 8;
pub const XCB_KEY_BUT_MASK_MOD_2: c_int = 16;
pub const XCB_KEY_BUT_MASK_MOD_3: c_int = 32;
pub const XCB_KEY_BUT_MASK_MOD_4: c_int = 64;
pub const XCB_KEY_BUT_MASK_MOD_5: c_int = 128;
pub const XCB_KEY_BUT_MASK_BUTTON_1: c_int = 256;
pub const XCB_KEY_BUT_MASK_BUTTON_2: c_int = 512;
pub const XCB_KEY_BUT_MASK_BUTTON_3: c_int = 1024;
pub const XCB_KEY_BUT_MASK_BUTTON_4: c_int = 2048;
pub const XCB_KEY_BUT_MASK_BUTTON_5: c_int = 4096;
pub const enum_xcb_key_but_mask_t = c_uint;
pub const xcb_key_but_mask_t = enum_xcb_key_but_mask_t;
pub const XCB_WINDOW_NONE: c_int = 0;
pub const enum_xcb_window_enum_t = c_uint;
pub const xcb_window_enum_t = enum_xcb_window_enum_t;
pub const struct_xcb_key_press_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    detail: xcb_keycode_t = @import("std").mem.zeroes(xcb_keycode_t),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    root_x: i16 = @import("std").mem.zeroes(i16),
    root_y: i16 = @import("std").mem.zeroes(i16),
    event_x: i16 = @import("std").mem.zeroes(i16),
    event_y: i16 = @import("std").mem.zeroes(i16),
    state: u16 = @import("std").mem.zeroes(u16),
    same_screen: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_key_press_event_t = struct_xcb_key_press_event_t;
pub const xcb_key_release_event_t = xcb_key_press_event_t;
pub const XCB_BUTTON_MASK_1: c_int = 256;
pub const XCB_BUTTON_MASK_2: c_int = 512;
pub const XCB_BUTTON_MASK_3: c_int = 1024;
pub const XCB_BUTTON_MASK_4: c_int = 2048;
pub const XCB_BUTTON_MASK_5: c_int = 4096;
pub const XCB_BUTTON_MASK_ANY: c_int = 32768;
pub const enum_xcb_button_mask_t = c_uint;
pub const xcb_button_mask_t = enum_xcb_button_mask_t;
pub const struct_xcb_button_press_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    detail: xcb_button_t = @import("std").mem.zeroes(xcb_button_t),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    root_x: i16 = @import("std").mem.zeroes(i16),
    root_y: i16 = @import("std").mem.zeroes(i16),
    event_x: i16 = @import("std").mem.zeroes(i16),
    event_y: i16 = @import("std").mem.zeroes(i16),
    state: u16 = @import("std").mem.zeroes(u16),
    same_screen: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_button_press_event_t = struct_xcb_button_press_event_t;
pub const xcb_button_release_event_t = xcb_button_press_event_t;
pub const XCB_MOTION_NORMAL: c_int = 0;
pub const XCB_MOTION_HINT: c_int = 1;
pub const enum_xcb_motion_t = c_uint;
pub const xcb_motion_t = enum_xcb_motion_t;
pub const struct_xcb_motion_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    detail: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    root_x: i16 = @import("std").mem.zeroes(i16),
    root_y: i16 = @import("std").mem.zeroes(i16),
    event_x: i16 = @import("std").mem.zeroes(i16),
    event_y: i16 = @import("std").mem.zeroes(i16),
    state: u16 = @import("std").mem.zeroes(u16),
    same_screen: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_motion_notify_event_t = struct_xcb_motion_notify_event_t;
pub const XCB_NOTIFY_DETAIL_ANCESTOR: c_int = 0;
pub const XCB_NOTIFY_DETAIL_VIRTUAL: c_int = 1;
pub const XCB_NOTIFY_DETAIL_INFERIOR: c_int = 2;
pub const XCB_NOTIFY_DETAIL_NONLINEAR: c_int = 3;
pub const XCB_NOTIFY_DETAIL_NONLINEAR_VIRTUAL: c_int = 4;
pub const XCB_NOTIFY_DETAIL_POINTER: c_int = 5;
pub const XCB_NOTIFY_DETAIL_POINTER_ROOT: c_int = 6;
pub const XCB_NOTIFY_DETAIL_NONE: c_int = 7;
pub const enum_xcb_notify_detail_t = c_uint;
pub const xcb_notify_detail_t = enum_xcb_notify_detail_t;
pub const XCB_NOTIFY_MODE_NORMAL: c_int = 0;
pub const XCB_NOTIFY_MODE_GRAB: c_int = 1;
pub const XCB_NOTIFY_MODE_UNGRAB: c_int = 2;
pub const XCB_NOTIFY_MODE_WHILE_GRABBED: c_int = 3;
pub const enum_xcb_notify_mode_t = c_uint;
pub const xcb_notify_mode_t = enum_xcb_notify_mode_t;
pub const struct_xcb_enter_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    detail: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    root_x: i16 = @import("std").mem.zeroes(i16),
    root_y: i16 = @import("std").mem.zeroes(i16),
    event_x: i16 = @import("std").mem.zeroes(i16),
    event_y: i16 = @import("std").mem.zeroes(i16),
    state: u16 = @import("std").mem.zeroes(u16),
    mode: u8 = @import("std").mem.zeroes(u8),
    same_screen_focus: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_enter_notify_event_t = struct_xcb_enter_notify_event_t;
pub const xcb_leave_notify_event_t = xcb_enter_notify_event_t;
pub const struct_xcb_focus_in_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    detail: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    mode: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_focus_in_event_t = struct_xcb_focus_in_event_t;
pub const xcb_focus_out_event_t = xcb_focus_in_event_t;
pub const struct_xcb_keymap_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    keys: [31]u8 = @import("std").mem.zeroes([31]u8),
};
pub const xcb_keymap_notify_event_t = struct_xcb_keymap_notify_event_t;
pub const struct_xcb_expose_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x: u16 = @import("std").mem.zeroes(u16),
    y: u16 = @import("std").mem.zeroes(u16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    count: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_expose_event_t = struct_xcb_expose_event_t;
pub const struct_xcb_graphics_exposure_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    x: u16 = @import("std").mem.zeroes(u16),
    y: u16 = @import("std").mem.zeroes(u16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    minor_opcode: u16 = @import("std").mem.zeroes(u16),
    count: u16 = @import("std").mem.zeroes(u16),
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad1: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_graphics_exposure_event_t = struct_xcb_graphics_exposure_event_t;
pub const struct_xcb_no_exposure_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    minor_opcode: u16 = @import("std").mem.zeroes(u16),
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad1: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_no_exposure_event_t = struct_xcb_no_exposure_event_t;
pub const XCB_VISIBILITY_UNOBSCURED: c_int = 0;
pub const XCB_VISIBILITY_PARTIALLY_OBSCURED: c_int = 1;
pub const XCB_VISIBILITY_FULLY_OBSCURED: c_int = 2;
pub const enum_xcb_visibility_t = c_uint;
pub const xcb_visibility_t = enum_xcb_visibility_t;
pub const struct_xcb_visibility_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    state: u8 = @import("std").mem.zeroes(u8),
    pad1: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_visibility_notify_event_t = struct_xcb_visibility_notify_event_t;
pub const struct_xcb_create_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    parent: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    border_width: u16 = @import("std").mem.zeroes(u16),
    override_redirect: u8 = @import("std").mem.zeroes(u8),
    pad1: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_create_notify_event_t = struct_xcb_create_notify_event_t;
pub const struct_xcb_destroy_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_destroy_notify_event_t = struct_xcb_destroy_notify_event_t;
pub const struct_xcb_unmap_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    from_configure: u8 = @import("std").mem.zeroes(u8),
    pad1: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_unmap_notify_event_t = struct_xcb_unmap_notify_event_t;
pub const struct_xcb_map_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    override_redirect: u8 = @import("std").mem.zeroes(u8),
    pad1: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_map_notify_event_t = struct_xcb_map_notify_event_t;
pub const struct_xcb_map_request_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    parent: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_map_request_event_t = struct_xcb_map_request_event_t;
pub const struct_xcb_reparent_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    parent: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    override_redirect: u8 = @import("std").mem.zeroes(u8),
    pad1: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_reparent_notify_event_t = struct_xcb_reparent_notify_event_t;
pub const struct_xcb_configure_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    above_sibling: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    border_width: u16 = @import("std").mem.zeroes(u16),
    override_redirect: u8 = @import("std").mem.zeroes(u8),
    pad1: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_configure_notify_event_t = struct_xcb_configure_notify_event_t;
pub const struct_xcb_configure_request_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    stack_mode: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    parent: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    sibling: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    border_width: u16 = @import("std").mem.zeroes(u16),
    value_mask: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_configure_request_event_t = struct_xcb_configure_request_event_t;
pub const struct_xcb_gravity_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_gravity_notify_event_t = struct_xcb_gravity_notify_event_t;
pub const struct_xcb_resize_request_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_resize_request_event_t = struct_xcb_resize_request_event_t;
pub const XCB_PLACE_ON_TOP: c_int = 0;
pub const XCB_PLACE_ON_BOTTOM: c_int = 1;
pub const enum_xcb_place_t = c_uint;
pub const xcb_place_t = enum_xcb_place_t;
pub const struct_xcb_circulate_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    pad1: [4]u8 = @import("std").mem.zeroes([4]u8),
    place: u8 = @import("std").mem.zeroes(u8),
    pad2: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_circulate_notify_event_t = struct_xcb_circulate_notify_event_t;
pub const xcb_circulate_request_event_t = xcb_circulate_notify_event_t;
pub const XCB_PROPERTY_NEW_VALUE: c_int = 0;
pub const XCB_PROPERTY_DELETE: c_int = 1;
pub const enum_xcb_property_t = c_uint;
pub const xcb_property_t = enum_xcb_property_t;
pub const struct_xcb_property_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    atom: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    state: u8 = @import("std").mem.zeroes(u8),
    pad1: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_property_notify_event_t = struct_xcb_property_notify_event_t;
pub const struct_xcb_selection_clear_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    owner: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    selection: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
};
pub const xcb_selection_clear_event_t = struct_xcb_selection_clear_event_t;
pub const XCB_TIME_CURRENT_TIME: c_int = 0;
pub const enum_xcb_time_t = c_uint;
pub const xcb_time_t = enum_xcb_time_t;
pub const XCB_ATOM_NONE: c_int = 0;
pub const XCB_ATOM_ANY: c_int = 0;
pub const XCB_ATOM_PRIMARY: c_int = 1;
pub const XCB_ATOM_SECONDARY: c_int = 2;
pub const XCB_ATOM_ARC: c_int = 3;
pub const XCB_ATOM_ATOM: c_int = 4;
pub const XCB_ATOM_BITMAP: c_int = 5;
pub const XCB_ATOM_CARDINAL: c_int = 6;
pub const XCB_ATOM_COLORMAP: c_int = 7;
pub const XCB_ATOM_CURSOR: c_int = 8;
pub const XCB_ATOM_CUT_BUFFER0: c_int = 9;
pub const XCB_ATOM_CUT_BUFFER1: c_int = 10;
pub const XCB_ATOM_CUT_BUFFER2: c_int = 11;
pub const XCB_ATOM_CUT_BUFFER3: c_int = 12;
pub const XCB_ATOM_CUT_BUFFER4: c_int = 13;
pub const XCB_ATOM_CUT_BUFFER5: c_int = 14;
pub const XCB_ATOM_CUT_BUFFER6: c_int = 15;
pub const XCB_ATOM_CUT_BUFFER7: c_int = 16;
pub const XCB_ATOM_DRAWABLE: c_int = 17;
pub const XCB_ATOM_FONT: c_int = 18;
pub const XCB_ATOM_INTEGER: c_int = 19;
pub const XCB_ATOM_PIXMAP: c_int = 20;
pub const XCB_ATOM_POINT: c_int = 21;
pub const XCB_ATOM_RECTANGLE: c_int = 22;
pub const XCB_ATOM_RESOURCE_MANAGER: c_int = 23;
pub const XCB_ATOM_RGB_COLOR_MAP: c_int = 24;
pub const XCB_ATOM_RGB_BEST_MAP: c_int = 25;
pub const XCB_ATOM_RGB_BLUE_MAP: c_int = 26;
pub const XCB_ATOM_RGB_DEFAULT_MAP: c_int = 27;
pub const XCB_ATOM_RGB_GRAY_MAP: c_int = 28;
pub const XCB_ATOM_RGB_GREEN_MAP: c_int = 29;
pub const XCB_ATOM_RGB_RED_MAP: c_int = 30;
pub const XCB_ATOM_STRING: c_int = 31;
pub const XCB_ATOM_VISUALID: c_int = 32;
pub const XCB_ATOM_WINDOW: c_int = 33;
pub const XCB_ATOM_WM_COMMAND: c_int = 34;
pub const XCB_ATOM_WM_HINTS: c_int = 35;
pub const XCB_ATOM_WM_CLIENT_MACHINE: c_int = 36;
pub const XCB_ATOM_WM_ICON_NAME: c_int = 37;
pub const XCB_ATOM_WM_ICON_SIZE: c_int = 38;
pub const XCB_ATOM_WM_NAME: c_int = 39;
pub const XCB_ATOM_WM_NORMAL_HINTS: c_int = 40;
pub const XCB_ATOM_WM_SIZE_HINTS: c_int = 41;
pub const XCB_ATOM_WM_ZOOM_HINTS: c_int = 42;
pub const XCB_ATOM_MIN_SPACE: c_int = 43;
pub const XCB_ATOM_NORM_SPACE: c_int = 44;
pub const XCB_ATOM_MAX_SPACE: c_int = 45;
pub const XCB_ATOM_END_SPACE: c_int = 46;
pub const XCB_ATOM_SUPERSCRIPT_X: c_int = 47;
pub const XCB_ATOM_SUPERSCRIPT_Y: c_int = 48;
pub const XCB_ATOM_SUBSCRIPT_X: c_int = 49;
pub const XCB_ATOM_SUBSCRIPT_Y: c_int = 50;
pub const XCB_ATOM_UNDERLINE_POSITION: c_int = 51;
pub const XCB_ATOM_UNDERLINE_THICKNESS: c_int = 52;
pub const XCB_ATOM_STRIKEOUT_ASCENT: c_int = 53;
pub const XCB_ATOM_STRIKEOUT_DESCENT: c_int = 54;
pub const XCB_ATOM_ITALIC_ANGLE: c_int = 55;
pub const XCB_ATOM_X_HEIGHT: c_int = 56;
pub const XCB_ATOM_QUAD_WIDTH: c_int = 57;
pub const XCB_ATOM_WEIGHT: c_int = 58;
pub const XCB_ATOM_POINT_SIZE: c_int = 59;
pub const XCB_ATOM_RESOLUTION: c_int = 60;
pub const XCB_ATOM_COPYRIGHT: c_int = 61;
pub const XCB_ATOM_NOTICE: c_int = 62;
pub const XCB_ATOM_FONT_NAME: c_int = 63;
pub const XCB_ATOM_FAMILY_NAME: c_int = 64;
pub const XCB_ATOM_FULL_NAME: c_int = 65;
pub const XCB_ATOM_CAP_HEIGHT: c_int = 66;
pub const XCB_ATOM_WM_CLASS: c_int = 67;
pub const XCB_ATOM_WM_TRANSIENT_FOR: c_int = 68;
pub const enum_xcb_atom_enum_t = c_uint;
pub const xcb_atom_enum_t = enum_xcb_atom_enum_t;
pub const struct_xcb_selection_request_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    owner: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    requestor: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    selection: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    target: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
};
pub const xcb_selection_request_event_t = struct_xcb_selection_request_event_t;
pub const struct_xcb_selection_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    requestor: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    selection: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    target: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
};
pub const xcb_selection_notify_event_t = struct_xcb_selection_notify_event_t;
pub const XCB_COLORMAP_STATE_UNINSTALLED: c_int = 0;
pub const XCB_COLORMAP_STATE_INSTALLED: c_int = 1;
pub const enum_xcb_colormap_state_t = c_uint;
pub const xcb_colormap_state_t = enum_xcb_colormap_state_t;
pub const XCB_COLORMAP_NONE: c_int = 0;
pub const enum_xcb_colormap_enum_t = c_uint;
pub const xcb_colormap_enum_t = enum_xcb_colormap_enum_t;
pub const struct_xcb_colormap_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    colormap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    _new: u8 = @import("std").mem.zeroes(u8),
    state: u8 = @import("std").mem.zeroes(u8),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_colormap_notify_event_t = struct_xcb_colormap_notify_event_t;
pub const union_xcb_client_message_data_t = extern union {
    data8: [20]u8,
    data16: [10]u16,
    data32: [5]u32,
};
pub const xcb_client_message_data_t = union_xcb_client_message_data_t;
pub const struct_xcb_client_message_data_iterator_t = extern struct {
    data: [*c]xcb_client_message_data_t = @import("std").mem.zeroes([*c]xcb_client_message_data_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_client_message_data_iterator_t = struct_xcb_client_message_data_iterator_t;
pub const struct_xcb_client_message_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    format: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    type: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    data: xcb_client_message_data_t = @import("std").mem.zeroes(xcb_client_message_data_t),
};
pub const xcb_client_message_event_t = struct_xcb_client_message_event_t;
pub const XCB_MAPPING_MODIFIER: c_int = 0;
pub const XCB_MAPPING_KEYBOARD: c_int = 1;
pub const XCB_MAPPING_POINTER: c_int = 2;
pub const enum_xcb_mapping_t = c_uint;
pub const xcb_mapping_t = enum_xcb_mapping_t;
pub const struct_xcb_mapping_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    request: u8 = @import("std").mem.zeroes(u8),
    first_keycode: xcb_keycode_t = @import("std").mem.zeroes(xcb_keycode_t),
    count: u8 = @import("std").mem.zeroes(u8),
    pad1: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_mapping_notify_event_t = struct_xcb_mapping_notify_event_t;
pub const struct_xcb_ge_generic_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    pad0: [22]u8 = @import("std").mem.zeroes([22]u8),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_ge_generic_event_t = struct_xcb_ge_generic_event_t;
pub const struct_xcb_request_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    bad_value: u32 = @import("std").mem.zeroes(u32),
    minor_opcode: u16 = @import("std").mem.zeroes(u16),
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_request_error_t = struct_xcb_request_error_t;
pub const struct_xcb_value_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    bad_value: u32 = @import("std").mem.zeroes(u32),
    minor_opcode: u16 = @import("std").mem.zeroes(u16),
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_value_error_t = struct_xcb_value_error_t;
pub const xcb_window_error_t = xcb_value_error_t;
pub const xcb_pixmap_error_t = xcb_value_error_t;
pub const xcb_atom_error_t = xcb_value_error_t;
pub const xcb_cursor_error_t = xcb_value_error_t;
pub const xcb_font_error_t = xcb_value_error_t;
pub const xcb_match_error_t = xcb_request_error_t;
pub const xcb_drawable_error_t = xcb_value_error_t;
pub const xcb_access_error_t = xcb_request_error_t;
pub const xcb_alloc_error_t = xcb_request_error_t;
pub const xcb_colormap_error_t = xcb_value_error_t;
pub const xcb_g_context_error_t = xcb_value_error_t;
pub const xcb_id_choice_error_t = xcb_value_error_t;
pub const xcb_name_error_t = xcb_request_error_t;
pub const xcb_length_error_t = xcb_request_error_t;
pub const xcb_implementation_error_t = xcb_request_error_t;
pub const XCB_WINDOW_CLASS_COPY_FROM_PARENT: c_int = 0;
pub const XCB_WINDOW_CLASS_INPUT_OUTPUT: c_int = 1;
pub const XCB_WINDOW_CLASS_INPUT_ONLY: c_int = 2;
pub const enum_xcb_window_class_t = c_uint;
pub const xcb_window_class_t = enum_xcb_window_class_t;
pub const XCB_CW_BACK_PIXMAP: c_int = 1;
pub const XCB_CW_BACK_PIXEL: c_int = 2;
pub const XCB_CW_BORDER_PIXMAP: c_int = 4;
pub const XCB_CW_BORDER_PIXEL: c_int = 8;
pub const XCB_CW_BIT_GRAVITY: c_int = 16;
pub const XCB_CW_WIN_GRAVITY: c_int = 32;
pub const XCB_CW_BACKING_STORE: c_int = 64;
pub const XCB_CW_BACKING_PLANES: c_int = 128;
pub const XCB_CW_BACKING_PIXEL: c_int = 256;
pub const XCB_CW_OVERRIDE_REDIRECT: c_int = 512;
pub const XCB_CW_SAVE_UNDER: c_int = 1024;
pub const XCB_CW_EVENT_MASK: c_int = 2048;
pub const XCB_CW_DONT_PROPAGATE: c_int = 4096;
pub const XCB_CW_COLORMAP: c_int = 8192;
pub const XCB_CW_CURSOR: c_int = 16384;
pub const enum_xcb_cw_t = c_uint;
pub const xcb_cw_t = enum_xcb_cw_t;
pub const XCB_BACK_PIXMAP_NONE: c_int = 0;
pub const XCB_BACK_PIXMAP_PARENT_RELATIVE: c_int = 1;
pub const enum_xcb_back_pixmap_t = c_uint;
pub const xcb_back_pixmap_t = enum_xcb_back_pixmap_t;
pub const XCB_GRAVITY_BIT_FORGET: c_int = 0;
pub const XCB_GRAVITY_WIN_UNMAP: c_int = 0;
pub const XCB_GRAVITY_NORTH_WEST: c_int = 1;
pub const XCB_GRAVITY_NORTH: c_int = 2;
pub const XCB_GRAVITY_NORTH_EAST: c_int = 3;
pub const XCB_GRAVITY_WEST: c_int = 4;
pub const XCB_GRAVITY_CENTER: c_int = 5;
pub const XCB_GRAVITY_EAST: c_int = 6;
pub const XCB_GRAVITY_SOUTH_WEST: c_int = 7;
pub const XCB_GRAVITY_SOUTH: c_int = 8;
pub const XCB_GRAVITY_SOUTH_EAST: c_int = 9;
pub const XCB_GRAVITY_STATIC: c_int = 10;
pub const enum_xcb_gravity_t = c_uint;
pub const xcb_gravity_t = enum_xcb_gravity_t;
pub const struct_xcb_create_window_value_list_t = extern struct {
    background_pixmap: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    background_pixel: u32 = @import("std").mem.zeroes(u32),
    border_pixmap: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    border_pixel: u32 = @import("std").mem.zeroes(u32),
    bit_gravity: u32 = @import("std").mem.zeroes(u32),
    win_gravity: u32 = @import("std").mem.zeroes(u32),
    backing_store: u32 = @import("std").mem.zeroes(u32),
    backing_planes: u32 = @import("std").mem.zeroes(u32),
    backing_pixel: u32 = @import("std").mem.zeroes(u32),
    override_redirect: xcb_bool32_t = @import("std").mem.zeroes(xcb_bool32_t),
    save_under: xcb_bool32_t = @import("std").mem.zeroes(xcb_bool32_t),
    event_mask: u32 = @import("std").mem.zeroes(u32),
    do_not_propogate_mask: u32 = @import("std").mem.zeroes(u32),
    colormap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
};
pub const xcb_create_window_value_list_t = struct_xcb_create_window_value_list_t;
pub const struct_xcb_create_window_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    depth: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    wid: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    parent: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    border_width: u16 = @import("std").mem.zeroes(u16),
    _class: u16 = @import("std").mem.zeroes(u16),
    visual: xcb_visualid_t = @import("std").mem.zeroes(xcb_visualid_t),
    value_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_create_window_request_t = struct_xcb_create_window_request_t;
pub const struct_xcb_change_window_attributes_value_list_t = extern struct {
    background_pixmap: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    background_pixel: u32 = @import("std").mem.zeroes(u32),
    border_pixmap: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    border_pixel: u32 = @import("std").mem.zeroes(u32),
    bit_gravity: u32 = @import("std").mem.zeroes(u32),
    win_gravity: u32 = @import("std").mem.zeroes(u32),
    backing_store: u32 = @import("std").mem.zeroes(u32),
    backing_planes: u32 = @import("std").mem.zeroes(u32),
    backing_pixel: u32 = @import("std").mem.zeroes(u32),
    override_redirect: xcb_bool32_t = @import("std").mem.zeroes(xcb_bool32_t),
    save_under: xcb_bool32_t = @import("std").mem.zeroes(xcb_bool32_t),
    event_mask: u32 = @import("std").mem.zeroes(u32),
    do_not_propogate_mask: u32 = @import("std").mem.zeroes(u32),
    colormap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
};
pub const xcb_change_window_attributes_value_list_t = struct_xcb_change_window_attributes_value_list_t;
pub const struct_xcb_change_window_attributes_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    value_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_change_window_attributes_request_t = struct_xcb_change_window_attributes_request_t;
pub const XCB_MAP_STATE_UNMAPPED: c_int = 0;
pub const XCB_MAP_STATE_UNVIEWABLE: c_int = 1;
pub const XCB_MAP_STATE_VIEWABLE: c_int = 2;
pub const enum_xcb_map_state_t = c_uint;
pub const xcb_map_state_t = enum_xcb_map_state_t;
pub const struct_xcb_get_window_attributes_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_window_attributes_cookie_t = struct_xcb_get_window_attributes_cookie_t;
pub const struct_xcb_get_window_attributes_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_get_window_attributes_request_t = struct_xcb_get_window_attributes_request_t;
pub const struct_xcb_get_window_attributes_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    backing_store: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    visual: xcb_visualid_t = @import("std").mem.zeroes(xcb_visualid_t),
    _class: u16 = @import("std").mem.zeroes(u16),
    bit_gravity: u8 = @import("std").mem.zeroes(u8),
    win_gravity: u8 = @import("std").mem.zeroes(u8),
    backing_planes: u32 = @import("std").mem.zeroes(u32),
    backing_pixel: u32 = @import("std").mem.zeroes(u32),
    save_under: u8 = @import("std").mem.zeroes(u8),
    map_is_installed: u8 = @import("std").mem.zeroes(u8),
    map_state: u8 = @import("std").mem.zeroes(u8),
    override_redirect: u8 = @import("std").mem.zeroes(u8),
    colormap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    all_event_masks: u32 = @import("std").mem.zeroes(u32),
    your_event_mask: u32 = @import("std").mem.zeroes(u32),
    do_not_propagate_mask: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_get_window_attributes_reply_t = struct_xcb_get_window_attributes_reply_t;
pub const struct_xcb_destroy_window_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_destroy_window_request_t = struct_xcb_destroy_window_request_t;
pub const struct_xcb_destroy_subwindows_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_destroy_subwindows_request_t = struct_xcb_destroy_subwindows_request_t;
pub const XCB_SET_MODE_INSERT: c_int = 0;
pub const XCB_SET_MODE_DELETE: c_int = 1;
pub const enum_xcb_set_mode_t = c_uint;
pub const xcb_set_mode_t = enum_xcb_set_mode_t;
pub const struct_xcb_change_save_set_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_change_save_set_request_t = struct_xcb_change_save_set_request_t;
pub const struct_xcb_reparent_window_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    parent: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_reparent_window_request_t = struct_xcb_reparent_window_request_t;
pub const struct_xcb_map_window_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_map_window_request_t = struct_xcb_map_window_request_t;
pub const struct_xcb_map_subwindows_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_map_subwindows_request_t = struct_xcb_map_subwindows_request_t;
pub const struct_xcb_unmap_window_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_unmap_window_request_t = struct_xcb_unmap_window_request_t;
pub const struct_xcb_unmap_subwindows_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_unmap_subwindows_request_t = struct_xcb_unmap_subwindows_request_t;
pub const XCB_CONFIG_WINDOW_X: c_int = 1;
pub const XCB_CONFIG_WINDOW_Y: c_int = 2;
pub const XCB_CONFIG_WINDOW_WIDTH: c_int = 4;
pub const XCB_CONFIG_WINDOW_HEIGHT: c_int = 8;
pub const XCB_CONFIG_WINDOW_BORDER_WIDTH: c_int = 16;
pub const XCB_CONFIG_WINDOW_SIBLING: c_int = 32;
pub const XCB_CONFIG_WINDOW_STACK_MODE: c_int = 64;
pub const enum_xcb_config_window_t = c_uint;
pub const xcb_config_window_t = enum_xcb_config_window_t;
pub const XCB_STACK_MODE_ABOVE: c_int = 0;
pub const XCB_STACK_MODE_BELOW: c_int = 1;
pub const XCB_STACK_MODE_TOP_IF: c_int = 2;
pub const XCB_STACK_MODE_BOTTOM_IF: c_int = 3;
pub const XCB_STACK_MODE_OPPOSITE: c_int = 4;
pub const enum_xcb_stack_mode_t = c_uint;
pub const xcb_stack_mode_t = enum_xcb_stack_mode_t;
pub const struct_xcb_configure_window_value_list_t = extern struct {
    x: i32 = @import("std").mem.zeroes(i32),
    y: i32 = @import("std").mem.zeroes(i32),
    width: u32 = @import("std").mem.zeroes(u32),
    height: u32 = @import("std").mem.zeroes(u32),
    border_width: u32 = @import("std").mem.zeroes(u32),
    sibling: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    stack_mode: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_configure_window_value_list_t = struct_xcb_configure_window_value_list_t;
pub const struct_xcb_configure_window_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    value_mask: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_configure_window_request_t = struct_xcb_configure_window_request_t;
pub const XCB_CIRCULATE_RAISE_LOWEST: c_int = 0;
pub const XCB_CIRCULATE_LOWER_HIGHEST: c_int = 1;
pub const enum_xcb_circulate_t = c_uint;
pub const xcb_circulate_t = enum_xcb_circulate_t;
pub const struct_xcb_circulate_window_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    direction: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_circulate_window_request_t = struct_xcb_circulate_window_request_t;
pub const struct_xcb_get_geometry_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_geometry_cookie_t = struct_xcb_get_geometry_cookie_t;
pub const struct_xcb_get_geometry_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
};
pub const xcb_get_geometry_request_t = struct_xcb_get_geometry_request_t;
pub const struct_xcb_get_geometry_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    depth: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    border_width: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_get_geometry_reply_t = struct_xcb_get_geometry_reply_t;
pub const struct_xcb_query_tree_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_query_tree_cookie_t = struct_xcb_query_tree_cookie_t;
pub const struct_xcb_query_tree_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_query_tree_request_t = struct_xcb_query_tree_request_t;
pub const struct_xcb_query_tree_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    parent: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    children_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [14]u8 = @import("std").mem.zeroes([14]u8),
};
pub const xcb_query_tree_reply_t = struct_xcb_query_tree_reply_t;
pub const struct_xcb_intern_atom_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_intern_atom_cookie_t = struct_xcb_intern_atom_cookie_t;
pub const struct_xcb_intern_atom_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    only_if_exists: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    name_len: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_intern_atom_request_t = struct_xcb_intern_atom_request_t;
pub const struct_xcb_intern_atom_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    atom: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
};
pub const xcb_intern_atom_reply_t = struct_xcb_intern_atom_reply_t;
pub const struct_xcb_get_atom_name_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_atom_name_cookie_t = struct_xcb_get_atom_name_cookie_t;
pub const struct_xcb_get_atom_name_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    atom: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
};
pub const xcb_get_atom_name_request_t = struct_xcb_get_atom_name_request_t;
pub const struct_xcb_get_atom_name_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    name_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_get_atom_name_reply_t = struct_xcb_get_atom_name_reply_t;
pub const XCB_PROP_MODE_REPLACE: c_int = 0;
pub const XCB_PROP_MODE_PREPEND: c_int = 1;
pub const XCB_PROP_MODE_APPEND: c_int = 2;
pub const enum_xcb_prop_mode_t = c_uint;
pub const xcb_prop_mode_t = enum_xcb_prop_mode_t;
pub const struct_xcb_change_property_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    type: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    format: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    data_len: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_change_property_request_t = struct_xcb_change_property_request_t;
pub const struct_xcb_delete_property_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
};
pub const xcb_delete_property_request_t = struct_xcb_delete_property_request_t;
pub const XCB_GET_PROPERTY_TYPE_ANY: c_int = 0;
pub const enum_xcb_get_property_type_t = c_uint;
pub const xcb_get_property_type_t = enum_xcb_get_property_type_t;
pub const struct_xcb_get_property_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_property_cookie_t = struct_xcb_get_property_cookie_t;
pub const struct_xcb_get_property_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    _delete: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    type: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    long_offset: u32 = @import("std").mem.zeroes(u32),
    long_length: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_get_property_request_t = struct_xcb_get_property_request_t;
pub const struct_xcb_get_property_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    format: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    type: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    bytes_after: u32 = @import("std").mem.zeroes(u32),
    value_len: u32 = @import("std").mem.zeroes(u32),
    pad0: [12]u8 = @import("std").mem.zeroes([12]u8),
};
pub const xcb_get_property_reply_t = struct_xcb_get_property_reply_t;
pub const struct_xcb_list_properties_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_list_properties_cookie_t = struct_xcb_list_properties_cookie_t;
pub const struct_xcb_list_properties_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_list_properties_request_t = struct_xcb_list_properties_request_t;
pub const struct_xcb_list_properties_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    atoms_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_list_properties_reply_t = struct_xcb_list_properties_reply_t;
pub const struct_xcb_set_selection_owner_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    owner: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    selection: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
};
pub const xcb_set_selection_owner_request_t = struct_xcb_set_selection_owner_request_t;
pub const struct_xcb_get_selection_owner_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_selection_owner_cookie_t = struct_xcb_get_selection_owner_cookie_t;
pub const struct_xcb_get_selection_owner_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    selection: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
};
pub const xcb_get_selection_owner_request_t = struct_xcb_get_selection_owner_request_t;
pub const struct_xcb_get_selection_owner_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    owner: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_get_selection_owner_reply_t = struct_xcb_get_selection_owner_reply_t;
pub const struct_xcb_convert_selection_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    requestor: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    selection: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    target: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
};
pub const xcb_convert_selection_request_t = struct_xcb_convert_selection_request_t;
pub const XCB_SEND_EVENT_DEST_POINTER_WINDOW: c_int = 0;
pub const XCB_SEND_EVENT_DEST_ITEM_FOCUS: c_int = 1;
pub const enum_xcb_send_event_dest_t = c_uint;
pub const xcb_send_event_dest_t = enum_xcb_send_event_dest_t;
pub const struct_xcb_send_event_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    propagate: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    destination: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event_mask: u32 = @import("std").mem.zeroes(u32),
    event: [32]u8 = @import("std").mem.zeroes([32]u8),
};
pub const xcb_send_event_request_t = struct_xcb_send_event_request_t;
pub const XCB_GRAB_MODE_SYNC: c_int = 0;
pub const XCB_GRAB_MODE_ASYNC: c_int = 1;
pub const enum_xcb_grab_mode_t = c_uint;
pub const xcb_grab_mode_t = enum_xcb_grab_mode_t;
pub const XCB_GRAB_STATUS_SUCCESS: c_int = 0;
pub const XCB_GRAB_STATUS_ALREADY_GRABBED: c_int = 1;
pub const XCB_GRAB_STATUS_INVALID_TIME: c_int = 2;
pub const XCB_GRAB_STATUS_NOT_VIEWABLE: c_int = 3;
pub const XCB_GRAB_STATUS_FROZEN: c_int = 4;
pub const enum_xcb_grab_status_t = c_uint;
pub const xcb_grab_status_t = enum_xcb_grab_status_t;
pub const XCB_CURSOR_NONE: c_int = 0;
pub const enum_xcb_cursor_enum_t = c_uint;
pub const xcb_cursor_enum_t = enum_xcb_cursor_enum_t;
pub const struct_xcb_grab_pointer_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_grab_pointer_cookie_t = struct_xcb_grab_pointer_cookie_t;
pub const struct_xcb_grab_pointer_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    owner_events: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event_mask: u16 = @import("std").mem.zeroes(u16),
    pointer_mode: u8 = @import("std").mem.zeroes(u8),
    keyboard_mode: u8 = @import("std").mem.zeroes(u8),
    confine_to: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
};
pub const xcb_grab_pointer_request_t = struct_xcb_grab_pointer_request_t;
pub const struct_xcb_grab_pointer_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    status: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_grab_pointer_reply_t = struct_xcb_grab_pointer_reply_t;
pub const struct_xcb_ungrab_pointer_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
};
pub const xcb_ungrab_pointer_request_t = struct_xcb_ungrab_pointer_request_t;
pub const XCB_BUTTON_INDEX_ANY: c_int = 0;
pub const XCB_BUTTON_INDEX_1: c_int = 1;
pub const XCB_BUTTON_INDEX_2: c_int = 2;
pub const XCB_BUTTON_INDEX_3: c_int = 3;
pub const XCB_BUTTON_INDEX_4: c_int = 4;
pub const XCB_BUTTON_INDEX_5: c_int = 5;
pub const enum_xcb_button_index_t = c_uint;
pub const xcb_button_index_t = enum_xcb_button_index_t;
pub const struct_xcb_grab_button_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    owner_events: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event_mask: u16 = @import("std").mem.zeroes(u16),
    pointer_mode: u8 = @import("std").mem.zeroes(u8),
    keyboard_mode: u8 = @import("std").mem.zeroes(u8),
    confine_to: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    button: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    modifiers: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_grab_button_request_t = struct_xcb_grab_button_request_t;
pub const struct_xcb_ungrab_button_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    button: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    modifiers: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_ungrab_button_request_t = struct_xcb_ungrab_button_request_t;
pub const struct_xcb_change_active_pointer_grab_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    event_mask: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_change_active_pointer_grab_request_t = struct_xcb_change_active_pointer_grab_request_t;
pub const struct_xcb_grab_keyboard_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_grab_keyboard_cookie_t = struct_xcb_grab_keyboard_cookie_t;
pub const struct_xcb_grab_keyboard_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    owner_events: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    pointer_mode: u8 = @import("std").mem.zeroes(u8),
    keyboard_mode: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_grab_keyboard_request_t = struct_xcb_grab_keyboard_request_t;
pub const struct_xcb_grab_keyboard_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    status: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_grab_keyboard_reply_t = struct_xcb_grab_keyboard_reply_t;
pub const struct_xcb_ungrab_keyboard_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
};
pub const xcb_ungrab_keyboard_request_t = struct_xcb_ungrab_keyboard_request_t;
pub const XCB_GRAB_ANY: c_int = 0;
pub const enum_xcb_grab_t = c_uint;
pub const xcb_grab_t = enum_xcb_grab_t;
pub const struct_xcb_grab_key_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    owner_events: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    modifiers: u16 = @import("std").mem.zeroes(u16),
    key: xcb_keycode_t = @import("std").mem.zeroes(xcb_keycode_t),
    pointer_mode: u8 = @import("std").mem.zeroes(u8),
    keyboard_mode: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_grab_key_request_t = struct_xcb_grab_key_request_t;
pub const struct_xcb_ungrab_key_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    key: xcb_keycode_t = @import("std").mem.zeroes(xcb_keycode_t),
    length: u16 = @import("std").mem.zeroes(u16),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    modifiers: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_ungrab_key_request_t = struct_xcb_ungrab_key_request_t;
pub const XCB_ALLOW_ASYNC_POINTER: c_int = 0;
pub const XCB_ALLOW_SYNC_POINTER: c_int = 1;
pub const XCB_ALLOW_REPLAY_POINTER: c_int = 2;
pub const XCB_ALLOW_ASYNC_KEYBOARD: c_int = 3;
pub const XCB_ALLOW_SYNC_KEYBOARD: c_int = 4;
pub const XCB_ALLOW_REPLAY_KEYBOARD: c_int = 5;
pub const XCB_ALLOW_ASYNC_BOTH: c_int = 6;
pub const XCB_ALLOW_SYNC_BOTH: c_int = 7;
pub const enum_xcb_allow_t = c_uint;
pub const xcb_allow_t = enum_xcb_allow_t;
pub const struct_xcb_allow_events_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
};
pub const xcb_allow_events_request_t = struct_xcb_allow_events_request_t;
pub const struct_xcb_grab_server_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_grab_server_request_t = struct_xcb_grab_server_request_t;
pub const struct_xcb_ungrab_server_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_ungrab_server_request_t = struct_xcb_ungrab_server_request_t;
pub const struct_xcb_query_pointer_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_query_pointer_cookie_t = struct_xcb_query_pointer_cookie_t;
pub const struct_xcb_query_pointer_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_query_pointer_request_t = struct_xcb_query_pointer_request_t;
pub const struct_xcb_query_pointer_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    same_screen: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    root_x: i16 = @import("std").mem.zeroes(i16),
    root_y: i16 = @import("std").mem.zeroes(i16),
    win_x: i16 = @import("std").mem.zeroes(i16),
    win_y: i16 = @import("std").mem.zeroes(i16),
    mask: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_query_pointer_reply_t = struct_xcb_query_pointer_reply_t;
pub const struct_xcb_timecoord_t = extern struct {
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_timecoord_t = struct_xcb_timecoord_t;
pub const struct_xcb_timecoord_iterator_t = extern struct {
    data: [*c]xcb_timecoord_t = @import("std").mem.zeroes([*c]xcb_timecoord_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_timecoord_iterator_t = struct_xcb_timecoord_iterator_t;
pub const struct_xcb_get_motion_events_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_motion_events_cookie_t = struct_xcb_get_motion_events_cookie_t;
pub const struct_xcb_get_motion_events_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    start: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    stop: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
};
pub const xcb_get_motion_events_request_t = struct_xcb_get_motion_events_request_t;
pub const struct_xcb_get_motion_events_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    events_len: u32 = @import("std").mem.zeroes(u32),
    pad1: [20]u8 = @import("std").mem.zeroes([20]u8),
};
pub const xcb_get_motion_events_reply_t = struct_xcb_get_motion_events_reply_t;
pub const struct_xcb_translate_coordinates_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_translate_coordinates_cookie_t = struct_xcb_translate_coordinates_cookie_t;
pub const struct_xcb_translate_coordinates_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    src_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    dst_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_translate_coordinates_request_t = struct_xcb_translate_coordinates_request_t;
pub const struct_xcb_translate_coordinates_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    same_screen: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    dst_x: i16 = @import("std").mem.zeroes(i16),
    dst_y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_translate_coordinates_reply_t = struct_xcb_translate_coordinates_reply_t;
pub const struct_xcb_warp_pointer_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    src_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    dst_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
    src_width: u16 = @import("std").mem.zeroes(u16),
    src_height: u16 = @import("std").mem.zeroes(u16),
    dst_x: i16 = @import("std").mem.zeroes(i16),
    dst_y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_warp_pointer_request_t = struct_xcb_warp_pointer_request_t;
pub const XCB_INPUT_FOCUS_NONE: c_int = 0;
pub const XCB_INPUT_FOCUS_POINTER_ROOT: c_int = 1;
pub const XCB_INPUT_FOCUS_PARENT: c_int = 2;
pub const XCB_INPUT_FOCUS_FOLLOW_KEYBOARD: c_int = 3;
pub const enum_xcb_input_focus_t = c_uint;
pub const xcb_input_focus_t = enum_xcb_input_focus_t;
pub const struct_xcb_set_input_focus_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    revert_to: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    focus: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
};
pub const xcb_set_input_focus_request_t = struct_xcb_set_input_focus_request_t;
pub const struct_xcb_get_input_focus_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_input_focus_cookie_t = struct_xcb_get_input_focus_cookie_t;
pub const struct_xcb_get_input_focus_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_get_input_focus_request_t = struct_xcb_get_input_focus_request_t;
pub const struct_xcb_get_input_focus_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    revert_to: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    focus: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_get_input_focus_reply_t = struct_xcb_get_input_focus_reply_t;
pub const struct_xcb_query_keymap_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_query_keymap_cookie_t = struct_xcb_query_keymap_cookie_t;
pub const struct_xcb_query_keymap_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_query_keymap_request_t = struct_xcb_query_keymap_request_t;
pub const struct_xcb_query_keymap_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    keys: [32]u8 = @import("std").mem.zeroes([32]u8),
};
pub const xcb_query_keymap_reply_t = struct_xcb_query_keymap_reply_t;
pub const struct_xcb_open_font_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    fid: xcb_font_t = @import("std").mem.zeroes(xcb_font_t),
    name_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_open_font_request_t = struct_xcb_open_font_request_t;
pub const struct_xcb_close_font_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    font: xcb_font_t = @import("std").mem.zeroes(xcb_font_t),
};
pub const xcb_close_font_request_t = struct_xcb_close_font_request_t;
pub const XCB_FONT_DRAW_LEFT_TO_RIGHT: c_int = 0;
pub const XCB_FONT_DRAW_RIGHT_TO_LEFT: c_int = 1;
pub const enum_xcb_font_draw_t = c_uint;
pub const xcb_font_draw_t = enum_xcb_font_draw_t;
pub const struct_xcb_fontprop_t = extern struct {
    name: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    value: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_fontprop_t = struct_xcb_fontprop_t;
pub const struct_xcb_fontprop_iterator_t = extern struct {
    data: [*c]xcb_fontprop_t = @import("std").mem.zeroes([*c]xcb_fontprop_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_fontprop_iterator_t = struct_xcb_fontprop_iterator_t;
pub const struct_xcb_charinfo_t = extern struct {
    left_side_bearing: i16 = @import("std").mem.zeroes(i16),
    right_side_bearing: i16 = @import("std").mem.zeroes(i16),
    character_width: i16 = @import("std").mem.zeroes(i16),
    ascent: i16 = @import("std").mem.zeroes(i16),
    descent: i16 = @import("std").mem.zeroes(i16),
    attributes: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_charinfo_t = struct_xcb_charinfo_t;
pub const struct_xcb_charinfo_iterator_t = extern struct {
    data: [*c]xcb_charinfo_t = @import("std").mem.zeroes([*c]xcb_charinfo_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_charinfo_iterator_t = struct_xcb_charinfo_iterator_t;
pub const struct_xcb_query_font_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_query_font_cookie_t = struct_xcb_query_font_cookie_t;
pub const struct_xcb_query_font_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    font: xcb_fontable_t = @import("std").mem.zeroes(xcb_fontable_t),
};
pub const xcb_query_font_request_t = struct_xcb_query_font_request_t;
pub const struct_xcb_query_font_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    min_bounds: xcb_charinfo_t = @import("std").mem.zeroes(xcb_charinfo_t),
    pad1: [4]u8 = @import("std").mem.zeroes([4]u8),
    max_bounds: xcb_charinfo_t = @import("std").mem.zeroes(xcb_charinfo_t),
    pad2: [4]u8 = @import("std").mem.zeroes([4]u8),
    min_char_or_byte2: u16 = @import("std").mem.zeroes(u16),
    max_char_or_byte2: u16 = @import("std").mem.zeroes(u16),
    default_char: u16 = @import("std").mem.zeroes(u16),
    properties_len: u16 = @import("std").mem.zeroes(u16),
    draw_direction: u8 = @import("std").mem.zeroes(u8),
    min_byte1: u8 = @import("std").mem.zeroes(u8),
    max_byte1: u8 = @import("std").mem.zeroes(u8),
    all_chars_exist: u8 = @import("std").mem.zeroes(u8),
    font_ascent: i16 = @import("std").mem.zeroes(i16),
    font_descent: i16 = @import("std").mem.zeroes(i16),
    char_infos_len: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_query_font_reply_t = struct_xcb_query_font_reply_t;
pub const struct_xcb_query_text_extents_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_query_text_extents_cookie_t = struct_xcb_query_text_extents_cookie_t;
pub const struct_xcb_query_text_extents_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    odd_length: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    font: xcb_fontable_t = @import("std").mem.zeroes(xcb_fontable_t),
};
pub const xcb_query_text_extents_request_t = struct_xcb_query_text_extents_request_t;
pub const struct_xcb_query_text_extents_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    draw_direction: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    font_ascent: i16 = @import("std").mem.zeroes(i16),
    font_descent: i16 = @import("std").mem.zeroes(i16),
    overall_ascent: i16 = @import("std").mem.zeroes(i16),
    overall_descent: i16 = @import("std").mem.zeroes(i16),
    overall_width: i32 = @import("std").mem.zeroes(i32),
    overall_left: i32 = @import("std").mem.zeroes(i32),
    overall_right: i32 = @import("std").mem.zeroes(i32),
};
pub const xcb_query_text_extents_reply_t = struct_xcb_query_text_extents_reply_t;
pub const struct_xcb_str_t = extern struct {
    name_len: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_str_t = struct_xcb_str_t;
pub const struct_xcb_str_iterator_t = extern struct {
    data: [*c]xcb_str_t = @import("std").mem.zeroes([*c]xcb_str_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_str_iterator_t = struct_xcb_str_iterator_t;
pub const struct_xcb_list_fonts_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_list_fonts_cookie_t = struct_xcb_list_fonts_cookie_t;
pub const struct_xcb_list_fonts_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    max_names: u16 = @import("std").mem.zeroes(u16),
    pattern_len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_list_fonts_request_t = struct_xcb_list_fonts_request_t;
pub const struct_xcb_list_fonts_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    names_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_list_fonts_reply_t = struct_xcb_list_fonts_reply_t;
pub const struct_xcb_list_fonts_with_info_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_list_fonts_with_info_cookie_t = struct_xcb_list_fonts_with_info_cookie_t;
pub const struct_xcb_list_fonts_with_info_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    max_names: u16 = @import("std").mem.zeroes(u16),
    pattern_len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_list_fonts_with_info_request_t = struct_xcb_list_fonts_with_info_request_t;
pub const struct_xcb_list_fonts_with_info_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    name_len: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    min_bounds: xcb_charinfo_t = @import("std").mem.zeroes(xcb_charinfo_t),
    pad0: [4]u8 = @import("std").mem.zeroes([4]u8),
    max_bounds: xcb_charinfo_t = @import("std").mem.zeroes(xcb_charinfo_t),
    pad1: [4]u8 = @import("std").mem.zeroes([4]u8),
    min_char_or_byte2: u16 = @import("std").mem.zeroes(u16),
    max_char_or_byte2: u16 = @import("std").mem.zeroes(u16),
    default_char: u16 = @import("std").mem.zeroes(u16),
    properties_len: u16 = @import("std").mem.zeroes(u16),
    draw_direction: u8 = @import("std").mem.zeroes(u8),
    min_byte1: u8 = @import("std").mem.zeroes(u8),
    max_byte1: u8 = @import("std").mem.zeroes(u8),
    all_chars_exist: u8 = @import("std").mem.zeroes(u8),
    font_ascent: i16 = @import("std").mem.zeroes(i16),
    font_descent: i16 = @import("std").mem.zeroes(i16),
    replies_hint: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_list_fonts_with_info_reply_t = struct_xcb_list_fonts_with_info_reply_t;
pub const struct_xcb_set_font_path_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    font_qty: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_set_font_path_request_t = struct_xcb_set_font_path_request_t;
pub const struct_xcb_get_font_path_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_font_path_cookie_t = struct_xcb_get_font_path_cookie_t;
pub const struct_xcb_get_font_path_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_get_font_path_request_t = struct_xcb_get_font_path_request_t;
pub const struct_xcb_get_font_path_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    path_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_get_font_path_reply_t = struct_xcb_get_font_path_reply_t;
pub const struct_xcb_create_pixmap_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    depth: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    pid: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_create_pixmap_request_t = struct_xcb_create_pixmap_request_t;
pub const struct_xcb_free_pixmap_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    pixmap: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
};
pub const xcb_free_pixmap_request_t = struct_xcb_free_pixmap_request_t;
pub const XCB_GC_FUNCTION: c_int = 1;
pub const XCB_GC_PLANE_MASK: c_int = 2;
pub const XCB_GC_FOREGROUND: c_int = 4;
pub const XCB_GC_BACKGROUND: c_int = 8;
pub const XCB_GC_LINE_WIDTH: c_int = 16;
pub const XCB_GC_LINE_STYLE: c_int = 32;
pub const XCB_GC_CAP_STYLE: c_int = 64;
pub const XCB_GC_JOIN_STYLE: c_int = 128;
pub const XCB_GC_FILL_STYLE: c_int = 256;
pub const XCB_GC_FILL_RULE: c_int = 512;
pub const XCB_GC_TILE: c_int = 1024;
pub const XCB_GC_STIPPLE: c_int = 2048;
pub const XCB_GC_TILE_STIPPLE_ORIGIN_X: c_int = 4096;
pub const XCB_GC_TILE_STIPPLE_ORIGIN_Y: c_int = 8192;
pub const XCB_GC_FONT: c_int = 16384;
pub const XCB_GC_SUBWINDOW_MODE: c_int = 32768;
pub const XCB_GC_GRAPHICS_EXPOSURES: c_int = 65536;
pub const XCB_GC_CLIP_ORIGIN_X: c_int = 131072;
pub const XCB_GC_CLIP_ORIGIN_Y: c_int = 262144;
pub const XCB_GC_CLIP_MASK: c_int = 524288;
pub const XCB_GC_DASH_OFFSET: c_int = 1048576;
pub const XCB_GC_DASH_LIST: c_int = 2097152;
pub const XCB_GC_ARC_MODE: c_int = 4194304;
pub const enum_xcb_gc_t = c_uint;
pub const xcb_gc_t = enum_xcb_gc_t;
pub const XCB_GX_CLEAR: c_int = 0;
pub const XCB_GX_AND: c_int = 1;
pub const XCB_GX_AND_REVERSE: c_int = 2;
pub const XCB_GX_COPY: c_int = 3;
pub const XCB_GX_AND_INVERTED: c_int = 4;
pub const XCB_GX_NOOP: c_int = 5;
pub const XCB_GX_XOR: c_int = 6;
pub const XCB_GX_OR: c_int = 7;
pub const XCB_GX_NOR: c_int = 8;
pub const XCB_GX_EQUIV: c_int = 9;
pub const XCB_GX_INVERT: c_int = 10;
pub const XCB_GX_OR_REVERSE: c_int = 11;
pub const XCB_GX_COPY_INVERTED: c_int = 12;
pub const XCB_GX_OR_INVERTED: c_int = 13;
pub const XCB_GX_NAND: c_int = 14;
pub const XCB_GX_SET: c_int = 15;
pub const enum_xcb_gx_t = c_uint;
pub const xcb_gx_t = enum_xcb_gx_t;
pub const XCB_LINE_STYLE_SOLID: c_int = 0;
pub const XCB_LINE_STYLE_ON_OFF_DASH: c_int = 1;
pub const XCB_LINE_STYLE_DOUBLE_DASH: c_int = 2;
pub const enum_xcb_line_style_t = c_uint;
pub const xcb_line_style_t = enum_xcb_line_style_t;
pub const XCB_CAP_STYLE_NOT_LAST: c_int = 0;
pub const XCB_CAP_STYLE_BUTT: c_int = 1;
pub const XCB_CAP_STYLE_ROUND: c_int = 2;
pub const XCB_CAP_STYLE_PROJECTING: c_int = 3;
pub const enum_xcb_cap_style_t = c_uint;
pub const xcb_cap_style_t = enum_xcb_cap_style_t;
pub const XCB_JOIN_STYLE_MITER: c_int = 0;
pub const XCB_JOIN_STYLE_ROUND: c_int = 1;
pub const XCB_JOIN_STYLE_BEVEL: c_int = 2;
pub const enum_xcb_join_style_t = c_uint;
pub const xcb_join_style_t = enum_xcb_join_style_t;
pub const XCB_FILL_STYLE_SOLID: c_int = 0;
pub const XCB_FILL_STYLE_TILED: c_int = 1;
pub const XCB_FILL_STYLE_STIPPLED: c_int = 2;
pub const XCB_FILL_STYLE_OPAQUE_STIPPLED: c_int = 3;
pub const enum_xcb_fill_style_t = c_uint;
pub const xcb_fill_style_t = enum_xcb_fill_style_t;
pub const XCB_FILL_RULE_EVEN_ODD: c_int = 0;
pub const XCB_FILL_RULE_WINDING: c_int = 1;
pub const enum_xcb_fill_rule_t = c_uint;
pub const xcb_fill_rule_t = enum_xcb_fill_rule_t;
pub const XCB_SUBWINDOW_MODE_CLIP_BY_CHILDREN: c_int = 0;
pub const XCB_SUBWINDOW_MODE_INCLUDE_INFERIORS: c_int = 1;
pub const enum_xcb_subwindow_mode_t = c_uint;
pub const xcb_subwindow_mode_t = enum_xcb_subwindow_mode_t;
pub const XCB_ARC_MODE_CHORD: c_int = 0;
pub const XCB_ARC_MODE_PIE_SLICE: c_int = 1;
pub const enum_xcb_arc_mode_t = c_uint;
pub const xcb_arc_mode_t = enum_xcb_arc_mode_t;
pub const struct_xcb_create_gc_value_list_t = extern struct {
    function: u32 = @import("std").mem.zeroes(u32),
    plane_mask: u32 = @import("std").mem.zeroes(u32),
    foreground: u32 = @import("std").mem.zeroes(u32),
    background: u32 = @import("std").mem.zeroes(u32),
    line_width: u32 = @import("std").mem.zeroes(u32),
    line_style: u32 = @import("std").mem.zeroes(u32),
    cap_style: u32 = @import("std").mem.zeroes(u32),
    join_style: u32 = @import("std").mem.zeroes(u32),
    fill_style: u32 = @import("std").mem.zeroes(u32),
    fill_rule: u32 = @import("std").mem.zeroes(u32),
    tile: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    stipple: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    tile_stipple_x_origin: i32 = @import("std").mem.zeroes(i32),
    tile_stipple_y_origin: i32 = @import("std").mem.zeroes(i32),
    font: xcb_font_t = @import("std").mem.zeroes(xcb_font_t),
    subwindow_mode: u32 = @import("std").mem.zeroes(u32),
    graphics_exposures: xcb_bool32_t = @import("std").mem.zeroes(xcb_bool32_t),
    clip_x_origin: i32 = @import("std").mem.zeroes(i32),
    clip_y_origin: i32 = @import("std").mem.zeroes(i32),
    clip_mask: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    dash_offset: u32 = @import("std").mem.zeroes(u32),
    dashes: u32 = @import("std").mem.zeroes(u32),
    arc_mode: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_create_gc_value_list_t = struct_xcb_create_gc_value_list_t;
pub const struct_xcb_create_gc_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cid: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    value_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_create_gc_request_t = struct_xcb_create_gc_request_t;
pub const struct_xcb_change_gc_value_list_t = extern struct {
    function: u32 = @import("std").mem.zeroes(u32),
    plane_mask: u32 = @import("std").mem.zeroes(u32),
    foreground: u32 = @import("std").mem.zeroes(u32),
    background: u32 = @import("std").mem.zeroes(u32),
    line_width: u32 = @import("std").mem.zeroes(u32),
    line_style: u32 = @import("std").mem.zeroes(u32),
    cap_style: u32 = @import("std").mem.zeroes(u32),
    join_style: u32 = @import("std").mem.zeroes(u32),
    fill_style: u32 = @import("std").mem.zeroes(u32),
    fill_rule: u32 = @import("std").mem.zeroes(u32),
    tile: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    stipple: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    tile_stipple_x_origin: i32 = @import("std").mem.zeroes(i32),
    tile_stipple_y_origin: i32 = @import("std").mem.zeroes(i32),
    font: xcb_font_t = @import("std").mem.zeroes(xcb_font_t),
    subwindow_mode: u32 = @import("std").mem.zeroes(u32),
    graphics_exposures: xcb_bool32_t = @import("std").mem.zeroes(xcb_bool32_t),
    clip_x_origin: i32 = @import("std").mem.zeroes(i32),
    clip_y_origin: i32 = @import("std").mem.zeroes(i32),
    clip_mask: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    dash_offset: u32 = @import("std").mem.zeroes(u32),
    dashes: u32 = @import("std").mem.zeroes(u32),
    arc_mode: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_change_gc_value_list_t = struct_xcb_change_gc_value_list_t;
pub const struct_xcb_change_gc_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    value_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_change_gc_request_t = struct_xcb_change_gc_request_t;
pub const struct_xcb_copy_gc_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    src_gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    dst_gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    value_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_copy_gc_request_t = struct_xcb_copy_gc_request_t;
pub const struct_xcb_set_dashes_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    dash_offset: u16 = @import("std").mem.zeroes(u16),
    dashes_len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_set_dashes_request_t = struct_xcb_set_dashes_request_t;
pub const XCB_CLIP_ORDERING_UNSORTED: c_int = 0;
pub const XCB_CLIP_ORDERING_Y_SORTED: c_int = 1;
pub const XCB_CLIP_ORDERING_YX_SORTED: c_int = 2;
pub const XCB_CLIP_ORDERING_YX_BANDED: c_int = 3;
pub const enum_xcb_clip_ordering_t = c_uint;
pub const xcb_clip_ordering_t = enum_xcb_clip_ordering_t;
pub const struct_xcb_set_clip_rectangles_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    ordering: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    clip_x_origin: i16 = @import("std").mem.zeroes(i16),
    clip_y_origin: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_set_clip_rectangles_request_t = struct_xcb_set_clip_rectangles_request_t;
pub const struct_xcb_free_gc_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
};
pub const xcb_free_gc_request_t = struct_xcb_free_gc_request_t;
pub const struct_xcb_clear_area_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    exposures: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_clear_area_request_t = struct_xcb_clear_area_request_t;
pub const struct_xcb_copy_area_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    src_drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    dst_drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
    dst_x: i16 = @import("std").mem.zeroes(i16),
    dst_y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_copy_area_request_t = struct_xcb_copy_area_request_t;
pub const struct_xcb_copy_plane_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    src_drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    dst_drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
    dst_x: i16 = @import("std").mem.zeroes(i16),
    dst_y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    bit_plane: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_copy_plane_request_t = struct_xcb_copy_plane_request_t;
pub const XCB_COORD_MODE_ORIGIN: c_int = 0;
pub const XCB_COORD_MODE_PREVIOUS: c_int = 1;
pub const enum_xcb_coord_mode_t = c_uint;
pub const xcb_coord_mode_t = enum_xcb_coord_mode_t;
pub const struct_xcb_poly_point_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    coordinate_mode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
};
pub const xcb_poly_point_request_t = struct_xcb_poly_point_request_t;
pub const struct_xcb_poly_line_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    coordinate_mode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
};
pub const xcb_poly_line_request_t = struct_xcb_poly_line_request_t;
pub const struct_xcb_segment_t = extern struct {
    x1: i16 = @import("std").mem.zeroes(i16),
    y1: i16 = @import("std").mem.zeroes(i16),
    x2: i16 = @import("std").mem.zeroes(i16),
    y2: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_segment_t = struct_xcb_segment_t;
pub const struct_xcb_segment_iterator_t = extern struct {
    data: [*c]xcb_segment_t = @import("std").mem.zeroes([*c]xcb_segment_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_segment_iterator_t = struct_xcb_segment_iterator_t;
pub const struct_xcb_poly_segment_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
};
pub const xcb_poly_segment_request_t = struct_xcb_poly_segment_request_t;
pub const struct_xcb_poly_rectangle_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
};
pub const xcb_poly_rectangle_request_t = struct_xcb_poly_rectangle_request_t;
pub const struct_xcb_poly_arc_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
};
pub const xcb_poly_arc_request_t = struct_xcb_poly_arc_request_t;
pub const XCB_POLY_SHAPE_COMPLEX: c_int = 0;
pub const XCB_POLY_SHAPE_NONCONVEX: c_int = 1;
pub const XCB_POLY_SHAPE_CONVEX: c_int = 2;
pub const enum_xcb_poly_shape_t = c_uint;
pub const xcb_poly_shape_t = enum_xcb_poly_shape_t;
pub const struct_xcb_fill_poly_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    shape: u8 = @import("std").mem.zeroes(u8),
    coordinate_mode: u8 = @import("std").mem.zeroes(u8),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_fill_poly_request_t = struct_xcb_fill_poly_request_t;
pub const struct_xcb_poly_fill_rectangle_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
};
pub const xcb_poly_fill_rectangle_request_t = struct_xcb_poly_fill_rectangle_request_t;
pub const struct_xcb_poly_fill_arc_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
};
pub const xcb_poly_fill_arc_request_t = struct_xcb_poly_fill_arc_request_t;
pub const XCB_IMAGE_FORMAT_XY_BITMAP: c_int = 0;
pub const XCB_IMAGE_FORMAT_XY_PIXMAP: c_int = 1;
pub const XCB_IMAGE_FORMAT_Z_PIXMAP: c_int = 2;
pub const enum_xcb_image_format_t = c_uint;
pub const xcb_image_format_t = enum_xcb_image_format_t;
pub const struct_xcb_put_image_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    format: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    dst_x: i16 = @import("std").mem.zeroes(i16),
    dst_y: i16 = @import("std").mem.zeroes(i16),
    left_pad: u8 = @import("std").mem.zeroes(u8),
    depth: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_put_image_request_t = struct_xcb_put_image_request_t;
pub const struct_xcb_get_image_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_image_cookie_t = struct_xcb_get_image_cookie_t;
pub const struct_xcb_get_image_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    format: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    plane_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_get_image_request_t = struct_xcb_get_image_request_t;
pub const struct_xcb_get_image_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    depth: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    visual: xcb_visualid_t = @import("std").mem.zeroes(xcb_visualid_t),
    pad0: [20]u8 = @import("std").mem.zeroes([20]u8),
};
pub const xcb_get_image_reply_t = struct_xcb_get_image_reply_t;
pub const struct_xcb_poly_text_8_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_poly_text_8_request_t = struct_xcb_poly_text_8_request_t;
pub const struct_xcb_poly_text_16_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_poly_text_16_request_t = struct_xcb_poly_text_16_request_t;
pub const struct_xcb_image_text_8_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    string_len: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_image_text_8_request_t = struct_xcb_image_text_8_request_t;
pub const struct_xcb_image_text_16_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    string_len: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_image_text_16_request_t = struct_xcb_image_text_16_request_t;
pub const XCB_COLORMAP_ALLOC_NONE: c_int = 0;
pub const XCB_COLORMAP_ALLOC_ALL: c_int = 1;
pub const enum_xcb_colormap_alloc_t = c_uint;
pub const xcb_colormap_alloc_t = enum_xcb_colormap_alloc_t;
pub const struct_xcb_create_colormap_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    alloc: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    mid: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    visual: xcb_visualid_t = @import("std").mem.zeroes(xcb_visualid_t),
};
pub const xcb_create_colormap_request_t = struct_xcb_create_colormap_request_t;
pub const struct_xcb_free_colormap_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
};
pub const xcb_free_colormap_request_t = struct_xcb_free_colormap_request_t;
pub const struct_xcb_copy_colormap_and_free_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    mid: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    src_cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
};
pub const xcb_copy_colormap_and_free_request_t = struct_xcb_copy_colormap_and_free_request_t;
pub const struct_xcb_install_colormap_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
};
pub const xcb_install_colormap_request_t = struct_xcb_install_colormap_request_t;
pub const struct_xcb_uninstall_colormap_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
};
pub const xcb_uninstall_colormap_request_t = struct_xcb_uninstall_colormap_request_t;
pub const struct_xcb_list_installed_colormaps_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_list_installed_colormaps_cookie_t = struct_xcb_list_installed_colormaps_cookie_t;
pub const struct_xcb_list_installed_colormaps_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_list_installed_colormaps_request_t = struct_xcb_list_installed_colormaps_request_t;
pub const struct_xcb_list_installed_colormaps_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    cmaps_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_list_installed_colormaps_reply_t = struct_xcb_list_installed_colormaps_reply_t;
pub const struct_xcb_alloc_color_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_alloc_color_cookie_t = struct_xcb_alloc_color_cookie_t;
pub const struct_xcb_alloc_color_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    red: u16 = @import("std").mem.zeroes(u16),
    green: u16 = @import("std").mem.zeroes(u16),
    blue: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_alloc_color_request_t = struct_xcb_alloc_color_request_t;
pub const struct_xcb_alloc_color_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    red: u16 = @import("std").mem.zeroes(u16),
    green: u16 = @import("std").mem.zeroes(u16),
    blue: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
    pixel: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_alloc_color_reply_t = struct_xcb_alloc_color_reply_t;
pub const struct_xcb_alloc_named_color_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_alloc_named_color_cookie_t = struct_xcb_alloc_named_color_cookie_t;
pub const struct_xcb_alloc_named_color_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    name_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_alloc_named_color_request_t = struct_xcb_alloc_named_color_request_t;
pub const struct_xcb_alloc_named_color_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    pixel: u32 = @import("std").mem.zeroes(u32),
    exact_red: u16 = @import("std").mem.zeroes(u16),
    exact_green: u16 = @import("std").mem.zeroes(u16),
    exact_blue: u16 = @import("std").mem.zeroes(u16),
    visual_red: u16 = @import("std").mem.zeroes(u16),
    visual_green: u16 = @import("std").mem.zeroes(u16),
    visual_blue: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_alloc_named_color_reply_t = struct_xcb_alloc_named_color_reply_t;
pub const struct_xcb_alloc_color_cells_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_alloc_color_cells_cookie_t = struct_xcb_alloc_color_cells_cookie_t;
pub const struct_xcb_alloc_color_cells_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    contiguous: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    colors: u16 = @import("std").mem.zeroes(u16),
    planes: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_alloc_color_cells_request_t = struct_xcb_alloc_color_cells_request_t;
pub const struct_xcb_alloc_color_cells_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    pixels_len: u16 = @import("std").mem.zeroes(u16),
    masks_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [20]u8 = @import("std").mem.zeroes([20]u8),
};
pub const xcb_alloc_color_cells_reply_t = struct_xcb_alloc_color_cells_reply_t;
pub const struct_xcb_alloc_color_planes_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_alloc_color_planes_cookie_t = struct_xcb_alloc_color_planes_cookie_t;
pub const struct_xcb_alloc_color_planes_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    contiguous: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    colors: u16 = @import("std").mem.zeroes(u16),
    reds: u16 = @import("std").mem.zeroes(u16),
    greens: u16 = @import("std").mem.zeroes(u16),
    blues: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_alloc_color_planes_request_t = struct_xcb_alloc_color_planes_request_t;
pub const struct_xcb_alloc_color_planes_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    pixels_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
    red_mask: u32 = @import("std").mem.zeroes(u32),
    green_mask: u32 = @import("std").mem.zeroes(u32),
    blue_mask: u32 = @import("std").mem.zeroes(u32),
    pad2: [8]u8 = @import("std").mem.zeroes([8]u8),
};
pub const xcb_alloc_color_planes_reply_t = struct_xcb_alloc_color_planes_reply_t;
pub const struct_xcb_free_colors_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    plane_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_free_colors_request_t = struct_xcb_free_colors_request_t;
pub const XCB_COLOR_FLAG_RED: c_int = 1;
pub const XCB_COLOR_FLAG_GREEN: c_int = 2;
pub const XCB_COLOR_FLAG_BLUE: c_int = 4;
pub const enum_xcb_color_flag_t = c_uint;
pub const xcb_color_flag_t = enum_xcb_color_flag_t;
pub const struct_xcb_coloritem_t = extern struct {
    pixel: u32 = @import("std").mem.zeroes(u32),
    red: u16 = @import("std").mem.zeroes(u16),
    green: u16 = @import("std").mem.zeroes(u16),
    blue: u16 = @import("std").mem.zeroes(u16),
    flags: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_coloritem_t = struct_xcb_coloritem_t;
pub const struct_xcb_coloritem_iterator_t = extern struct {
    data: [*c]xcb_coloritem_t = @import("std").mem.zeroes([*c]xcb_coloritem_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_coloritem_iterator_t = struct_xcb_coloritem_iterator_t;
pub const struct_xcb_store_colors_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
};
pub const xcb_store_colors_request_t = struct_xcb_store_colors_request_t;
pub const struct_xcb_store_named_color_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    flags: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    pixel: u32 = @import("std").mem.zeroes(u32),
    name_len: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_store_named_color_request_t = struct_xcb_store_named_color_request_t;
pub const struct_xcb_rgb_t = extern struct {
    red: u16 = @import("std").mem.zeroes(u16),
    green: u16 = @import("std").mem.zeroes(u16),
    blue: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_rgb_t = struct_xcb_rgb_t;
pub const struct_xcb_rgb_iterator_t = extern struct {
    data: [*c]xcb_rgb_t = @import("std").mem.zeroes([*c]xcb_rgb_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_rgb_iterator_t = struct_xcb_rgb_iterator_t;
pub const struct_xcb_query_colors_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_query_colors_cookie_t = struct_xcb_query_colors_cookie_t;
pub const struct_xcb_query_colors_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
};
pub const xcb_query_colors_request_t = struct_xcb_query_colors_request_t;
pub const struct_xcb_query_colors_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    colors_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_query_colors_reply_t = struct_xcb_query_colors_reply_t;
pub const struct_xcb_lookup_color_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_lookup_color_cookie_t = struct_xcb_lookup_color_cookie_t;
pub const struct_xcb_lookup_color_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cmap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
    name_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_lookup_color_request_t = struct_xcb_lookup_color_request_t;
pub const struct_xcb_lookup_color_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    exact_red: u16 = @import("std").mem.zeroes(u16),
    exact_green: u16 = @import("std").mem.zeroes(u16),
    exact_blue: u16 = @import("std").mem.zeroes(u16),
    visual_red: u16 = @import("std").mem.zeroes(u16),
    visual_green: u16 = @import("std").mem.zeroes(u16),
    visual_blue: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_lookup_color_reply_t = struct_xcb_lookup_color_reply_t;
pub const XCB_PIXMAP_NONE: c_int = 0;
pub const enum_xcb_pixmap_enum_t = c_uint;
pub const xcb_pixmap_enum_t = enum_xcb_pixmap_enum_t;
pub const struct_xcb_create_cursor_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cid: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    source: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    mask: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    fore_red: u16 = @import("std").mem.zeroes(u16),
    fore_green: u16 = @import("std").mem.zeroes(u16),
    fore_blue: u16 = @import("std").mem.zeroes(u16),
    back_red: u16 = @import("std").mem.zeroes(u16),
    back_green: u16 = @import("std").mem.zeroes(u16),
    back_blue: u16 = @import("std").mem.zeroes(u16),
    x: u16 = @import("std").mem.zeroes(u16),
    y: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_create_cursor_request_t = struct_xcb_create_cursor_request_t;
pub const XCB_FONT_NONE: c_int = 0;
pub const enum_xcb_font_enum_t = c_uint;
pub const xcb_font_enum_t = enum_xcb_font_enum_t;
pub const struct_xcb_create_glyph_cursor_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cid: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    source_font: xcb_font_t = @import("std").mem.zeroes(xcb_font_t),
    mask_font: xcb_font_t = @import("std").mem.zeroes(xcb_font_t),
    source_char: u16 = @import("std").mem.zeroes(u16),
    mask_char: u16 = @import("std").mem.zeroes(u16),
    fore_red: u16 = @import("std").mem.zeroes(u16),
    fore_green: u16 = @import("std").mem.zeroes(u16),
    fore_blue: u16 = @import("std").mem.zeroes(u16),
    back_red: u16 = @import("std").mem.zeroes(u16),
    back_green: u16 = @import("std").mem.zeroes(u16),
    back_blue: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_create_glyph_cursor_request_t = struct_xcb_create_glyph_cursor_request_t;
pub const struct_xcb_free_cursor_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
};
pub const xcb_free_cursor_request_t = struct_xcb_free_cursor_request_t;
pub const struct_xcb_recolor_cursor_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    fore_red: u16 = @import("std").mem.zeroes(u16),
    fore_green: u16 = @import("std").mem.zeroes(u16),
    fore_blue: u16 = @import("std").mem.zeroes(u16),
    back_red: u16 = @import("std").mem.zeroes(u16),
    back_green: u16 = @import("std").mem.zeroes(u16),
    back_blue: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_recolor_cursor_request_t = struct_xcb_recolor_cursor_request_t;
pub const XCB_QUERY_SHAPE_OF_LARGEST_CURSOR: c_int = 0;
pub const XCB_QUERY_SHAPE_OF_FASTEST_TILE: c_int = 1;
pub const XCB_QUERY_SHAPE_OF_FASTEST_STIPPLE: c_int = 2;
pub const enum_xcb_query_shape_of_t = c_uint;
pub const xcb_query_shape_of_t = enum_xcb_query_shape_of_t;
pub const struct_xcb_query_best_size_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_query_best_size_cookie_t = struct_xcb_query_best_size_cookie_t;
pub const struct_xcb_query_best_size_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    _class: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_query_best_size_request_t = struct_xcb_query_best_size_request_t;
pub const struct_xcb_query_best_size_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_query_best_size_reply_t = struct_xcb_query_best_size_reply_t;
pub const struct_xcb_query_extension_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_query_extension_cookie_t = struct_xcb_query_extension_cookie_t;
pub const struct_xcb_query_extension_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    name_len: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_query_extension_request_t = struct_xcb_query_extension_request_t;
pub const struct_xcb_query_extension_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    present: u8 = @import("std").mem.zeroes(u8),
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    first_event: u8 = @import("std").mem.zeroes(u8),
    first_error: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_query_extension_reply_t = struct_xcb_query_extension_reply_t;
pub const struct_xcb_list_extensions_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_list_extensions_cookie_t = struct_xcb_list_extensions_cookie_t;
pub const struct_xcb_list_extensions_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_list_extensions_request_t = struct_xcb_list_extensions_request_t;
pub const struct_xcb_list_extensions_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    names_len: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    pad0: [24]u8 = @import("std").mem.zeroes([24]u8),
};
pub const xcb_list_extensions_reply_t = struct_xcb_list_extensions_reply_t;
pub const struct_xcb_change_keyboard_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    keycode_count: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    first_keycode: xcb_keycode_t = @import("std").mem.zeroes(xcb_keycode_t),
    keysyms_per_keycode: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_change_keyboard_mapping_request_t = struct_xcb_change_keyboard_mapping_request_t;
pub const struct_xcb_get_keyboard_mapping_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_keyboard_mapping_cookie_t = struct_xcb_get_keyboard_mapping_cookie_t;
pub const struct_xcb_get_keyboard_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    first_keycode: xcb_keycode_t = @import("std").mem.zeroes(xcb_keycode_t),
    count: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_get_keyboard_mapping_request_t = struct_xcb_get_keyboard_mapping_request_t;
pub const struct_xcb_get_keyboard_mapping_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    keysyms_per_keycode: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    pad0: [24]u8 = @import("std").mem.zeroes([24]u8),
};
pub const xcb_get_keyboard_mapping_reply_t = struct_xcb_get_keyboard_mapping_reply_t;
pub const XCB_KB_KEY_CLICK_PERCENT: c_int = 1;
pub const XCB_KB_BELL_PERCENT: c_int = 2;
pub const XCB_KB_BELL_PITCH: c_int = 4;
pub const XCB_KB_BELL_DURATION: c_int = 8;
pub const XCB_KB_LED: c_int = 16;
pub const XCB_KB_LED_MODE: c_int = 32;
pub const XCB_KB_KEY: c_int = 64;
pub const XCB_KB_AUTO_REPEAT_MODE: c_int = 128;
pub const enum_xcb_kb_t = c_uint;
pub const xcb_kb_t = enum_xcb_kb_t;
pub const XCB_LED_MODE_OFF: c_int = 0;
pub const XCB_LED_MODE_ON: c_int = 1;
pub const enum_xcb_led_mode_t = c_uint;
pub const xcb_led_mode_t = enum_xcb_led_mode_t;
pub const XCB_AUTO_REPEAT_MODE_OFF: c_int = 0;
pub const XCB_AUTO_REPEAT_MODE_ON: c_int = 1;
pub const XCB_AUTO_REPEAT_MODE_DEFAULT: c_int = 2;
pub const enum_xcb_auto_repeat_mode_t = c_uint;
pub const xcb_auto_repeat_mode_t = enum_xcb_auto_repeat_mode_t;
pub const struct_xcb_change_keyboard_control_value_list_t = extern struct {
    key_click_percent: i32 = @import("std").mem.zeroes(i32),
    bell_percent: i32 = @import("std").mem.zeroes(i32),
    bell_pitch: i32 = @import("std").mem.zeroes(i32),
    bell_duration: i32 = @import("std").mem.zeroes(i32),
    led: u32 = @import("std").mem.zeroes(u32),
    led_mode: u32 = @import("std").mem.zeroes(u32),
    key: xcb_keycode32_t = @import("std").mem.zeroes(xcb_keycode32_t),
    auto_repeat_mode: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_change_keyboard_control_value_list_t = struct_xcb_change_keyboard_control_value_list_t;
pub const struct_xcb_change_keyboard_control_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    value_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_change_keyboard_control_request_t = struct_xcb_change_keyboard_control_request_t;
pub const struct_xcb_get_keyboard_control_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_keyboard_control_cookie_t = struct_xcb_get_keyboard_control_cookie_t;
pub const struct_xcb_get_keyboard_control_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_get_keyboard_control_request_t = struct_xcb_get_keyboard_control_request_t;
pub const struct_xcb_get_keyboard_control_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    global_auto_repeat: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    led_mask: u32 = @import("std").mem.zeroes(u32),
    key_click_percent: u8 = @import("std").mem.zeroes(u8),
    bell_percent: u8 = @import("std").mem.zeroes(u8),
    bell_pitch: u16 = @import("std").mem.zeroes(u16),
    bell_duration: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    auto_repeats: [32]u8 = @import("std").mem.zeroes([32]u8),
};
pub const xcb_get_keyboard_control_reply_t = struct_xcb_get_keyboard_control_reply_t;
pub const struct_xcb_bell_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    percent: i8 = @import("std").mem.zeroes(i8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_bell_request_t = struct_xcb_bell_request_t;
pub const struct_xcb_change_pointer_control_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    acceleration_numerator: i16 = @import("std").mem.zeroes(i16),
    acceleration_denominator: i16 = @import("std").mem.zeroes(i16),
    threshold: i16 = @import("std").mem.zeroes(i16),
    do_acceleration: u8 = @import("std").mem.zeroes(u8),
    do_threshold: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_change_pointer_control_request_t = struct_xcb_change_pointer_control_request_t;
pub const struct_xcb_get_pointer_control_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_pointer_control_cookie_t = struct_xcb_get_pointer_control_cookie_t;
pub const struct_xcb_get_pointer_control_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_get_pointer_control_request_t = struct_xcb_get_pointer_control_request_t;
pub const struct_xcb_get_pointer_control_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    acceleration_numerator: u16 = @import("std").mem.zeroes(u16),
    acceleration_denominator: u16 = @import("std").mem.zeroes(u16),
    threshold: u16 = @import("std").mem.zeroes(u16),
    pad1: [18]u8 = @import("std").mem.zeroes([18]u8),
};
pub const xcb_get_pointer_control_reply_t = struct_xcb_get_pointer_control_reply_t;
pub const XCB_BLANKING_NOT_PREFERRED: c_int = 0;
pub const XCB_BLANKING_PREFERRED: c_int = 1;
pub const XCB_BLANKING_DEFAULT: c_int = 2;
pub const enum_xcb_blanking_t = c_uint;
pub const xcb_blanking_t = enum_xcb_blanking_t;
pub const XCB_EXPOSURES_NOT_ALLOWED: c_int = 0;
pub const XCB_EXPOSURES_ALLOWED: c_int = 1;
pub const XCB_EXPOSURES_DEFAULT: c_int = 2;
pub const enum_xcb_exposures_t = c_uint;
pub const xcb_exposures_t = enum_xcb_exposures_t;
pub const struct_xcb_set_screen_saver_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    timeout: i16 = @import("std").mem.zeroes(i16),
    interval: i16 = @import("std").mem.zeroes(i16),
    prefer_blanking: u8 = @import("std").mem.zeroes(u8),
    allow_exposures: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_set_screen_saver_request_t = struct_xcb_set_screen_saver_request_t;
pub const struct_xcb_get_screen_saver_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_screen_saver_cookie_t = struct_xcb_get_screen_saver_cookie_t;
pub const struct_xcb_get_screen_saver_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_get_screen_saver_request_t = struct_xcb_get_screen_saver_request_t;
pub const struct_xcb_get_screen_saver_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    timeout: u16 = @import("std").mem.zeroes(u16),
    interval: u16 = @import("std").mem.zeroes(u16),
    prefer_blanking: u8 = @import("std").mem.zeroes(u8),
    allow_exposures: u8 = @import("std").mem.zeroes(u8),
    pad1: [18]u8 = @import("std").mem.zeroes([18]u8),
};
pub const xcb_get_screen_saver_reply_t = struct_xcb_get_screen_saver_reply_t;
pub const XCB_HOST_MODE_INSERT: c_int = 0;
pub const XCB_HOST_MODE_DELETE: c_int = 1;
pub const enum_xcb_host_mode_t = c_uint;
pub const xcb_host_mode_t = enum_xcb_host_mode_t;
pub const XCB_FAMILY_INTERNET: c_int = 0;
pub const XCB_FAMILY_DECNET: c_int = 1;
pub const XCB_FAMILY_CHAOS: c_int = 2;
pub const XCB_FAMILY_SERVER_INTERPRETED: c_int = 5;
pub const XCB_FAMILY_INTERNET_6: c_int = 6;
pub const enum_xcb_family_t = c_uint;
pub const xcb_family_t = enum_xcb_family_t;
pub const struct_xcb_change_hosts_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    family: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    address_len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_change_hosts_request_t = struct_xcb_change_hosts_request_t;
pub const struct_xcb_host_t = extern struct {
    family: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    address_len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_host_t = struct_xcb_host_t;
pub const struct_xcb_host_iterator_t = extern struct {
    data: [*c]xcb_host_t = @import("std").mem.zeroes([*c]xcb_host_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_host_iterator_t = struct_xcb_host_iterator_t;
pub const struct_xcb_list_hosts_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_list_hosts_cookie_t = struct_xcb_list_hosts_cookie_t;
pub const struct_xcb_list_hosts_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_list_hosts_request_t = struct_xcb_list_hosts_request_t;
pub const struct_xcb_list_hosts_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    hosts_len: u16 = @import("std").mem.zeroes(u16),
    pad0: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_list_hosts_reply_t = struct_xcb_list_hosts_reply_t;
pub const XCB_ACCESS_CONTROL_DISABLE: c_int = 0;
pub const XCB_ACCESS_CONTROL_ENABLE: c_int = 1;
pub const enum_xcb_access_control_t = c_uint;
pub const xcb_access_control_t = enum_xcb_access_control_t;
pub const struct_xcb_set_access_control_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_set_access_control_request_t = struct_xcb_set_access_control_request_t;
pub const XCB_CLOSE_DOWN_DESTROY_ALL: c_int = 0;
pub const XCB_CLOSE_DOWN_RETAIN_PERMANENT: c_int = 1;
pub const XCB_CLOSE_DOWN_RETAIN_TEMPORARY: c_int = 2;
pub const enum_xcb_close_down_t = c_uint;
pub const xcb_close_down_t = enum_xcb_close_down_t;
pub const struct_xcb_set_close_down_mode_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_set_close_down_mode_request_t = struct_xcb_set_close_down_mode_request_t;
pub const XCB_KILL_ALL_TEMPORARY: c_int = 0;
pub const enum_xcb_kill_t = c_uint;
pub const xcb_kill_t = enum_xcb_kill_t;
pub const struct_xcb_kill_client_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    resource: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_kill_client_request_t = struct_xcb_kill_client_request_t;
pub const struct_xcb_rotate_properties_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    atoms_len: u16 = @import("std").mem.zeroes(u16),
    delta: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_rotate_properties_request_t = struct_xcb_rotate_properties_request_t;
pub const XCB_SCREEN_SAVER_RESET: c_int = 0;
pub const XCB_SCREEN_SAVER_ACTIVE: c_int = 1;
pub const enum_xcb_screen_saver_t = c_uint;
pub const xcb_screen_saver_t = enum_xcb_screen_saver_t;
pub const struct_xcb_force_screen_saver_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_force_screen_saver_request_t = struct_xcb_force_screen_saver_request_t;
pub const XCB_MAPPING_STATUS_SUCCESS: c_int = 0;
pub const XCB_MAPPING_STATUS_BUSY: c_int = 1;
pub const XCB_MAPPING_STATUS_FAILURE: c_int = 2;
pub const enum_xcb_mapping_status_t = c_uint;
pub const xcb_mapping_status_t = enum_xcb_mapping_status_t;
pub const struct_xcb_set_pointer_mapping_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_set_pointer_mapping_cookie_t = struct_xcb_set_pointer_mapping_cookie_t;
pub const struct_xcb_set_pointer_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    map_len: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_set_pointer_mapping_request_t = struct_xcb_set_pointer_mapping_request_t;
pub const struct_xcb_set_pointer_mapping_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    status: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_set_pointer_mapping_reply_t = struct_xcb_set_pointer_mapping_reply_t;
pub const struct_xcb_get_pointer_mapping_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_pointer_mapping_cookie_t = struct_xcb_get_pointer_mapping_cookie_t;
pub const struct_xcb_get_pointer_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_get_pointer_mapping_request_t = struct_xcb_get_pointer_mapping_request_t;
pub const struct_xcb_get_pointer_mapping_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    map_len: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    pad0: [24]u8 = @import("std").mem.zeroes([24]u8),
};
pub const xcb_get_pointer_mapping_reply_t = struct_xcb_get_pointer_mapping_reply_t;
pub const XCB_MAP_INDEX_SHIFT: c_int = 0;
pub const XCB_MAP_INDEX_LOCK: c_int = 1;
pub const XCB_MAP_INDEX_CONTROL: c_int = 2;
pub const XCB_MAP_INDEX_1: c_int = 3;
pub const XCB_MAP_INDEX_2: c_int = 4;
pub const XCB_MAP_INDEX_3: c_int = 5;
pub const XCB_MAP_INDEX_4: c_int = 6;
pub const XCB_MAP_INDEX_5: c_int = 7;
pub const enum_xcb_map_index_t = c_uint;
pub const xcb_map_index_t = enum_xcb_map_index_t;
pub const struct_xcb_set_modifier_mapping_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_set_modifier_mapping_cookie_t = struct_xcb_set_modifier_mapping_cookie_t;
pub const struct_xcb_set_modifier_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    keycodes_per_modifier: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_set_modifier_mapping_request_t = struct_xcb_set_modifier_mapping_request_t;
pub const struct_xcb_set_modifier_mapping_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    status: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_set_modifier_mapping_reply_t = struct_xcb_set_modifier_mapping_reply_t;
pub const struct_xcb_get_modifier_mapping_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_get_modifier_mapping_cookie_t = struct_xcb_get_modifier_mapping_cookie_t;
pub const struct_xcb_get_modifier_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_get_modifier_mapping_request_t = struct_xcb_get_modifier_mapping_request_t;
pub const struct_xcb_get_modifier_mapping_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    keycodes_per_modifier: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    pad0: [24]u8 = @import("std").mem.zeroes([24]u8),
};
pub const xcb_get_modifier_mapping_reply_t = struct_xcb_get_modifier_mapping_reply_t;
pub const struct_xcb_no_operation_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_no_operation_request_t = struct_xcb_no_operation_request_t;
pub extern fn xcb_char2b_next(i: [*c]xcb_char2b_iterator_t) void;
pub extern fn xcb_char2b_end(i: xcb_char2b_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_window_next(i: [*c]xcb_window_iterator_t) void;
pub extern fn xcb_window_end(i: xcb_window_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_pixmap_next(i: [*c]xcb_pixmap_iterator_t) void;
pub extern fn xcb_pixmap_end(i: xcb_pixmap_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_cursor_next(i: [*c]xcb_cursor_iterator_t) void;
pub extern fn xcb_cursor_end(i: xcb_cursor_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_font_next(i: [*c]xcb_font_iterator_t) void;
pub extern fn xcb_font_end(i: xcb_font_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_gcontext_next(i: [*c]xcb_gcontext_iterator_t) void;
pub extern fn xcb_gcontext_end(i: xcb_gcontext_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_colormap_next(i: [*c]xcb_colormap_iterator_t) void;
pub extern fn xcb_colormap_end(i: xcb_colormap_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_atom_next(i: [*c]xcb_atom_iterator_t) void;
pub extern fn xcb_atom_end(i: xcb_atom_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_drawable_next(i: [*c]xcb_drawable_iterator_t) void;
pub extern fn xcb_drawable_end(i: xcb_drawable_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_fontable_next(i: [*c]xcb_fontable_iterator_t) void;
pub extern fn xcb_fontable_end(i: xcb_fontable_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_bool32_next(i: [*c]xcb_bool32_iterator_t) void;
pub extern fn xcb_bool32_end(i: xcb_bool32_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_visualid_next(i: [*c]xcb_visualid_iterator_t) void;
pub extern fn xcb_visualid_end(i: xcb_visualid_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_timestamp_next(i: [*c]xcb_timestamp_iterator_t) void;
pub extern fn xcb_timestamp_end(i: xcb_timestamp_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_keysym_next(i: [*c]xcb_keysym_iterator_t) void;
pub extern fn xcb_keysym_end(i: xcb_keysym_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_keycode_next(i: [*c]xcb_keycode_iterator_t) void;
pub extern fn xcb_keycode_end(i: xcb_keycode_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_keycode32_next(i: [*c]xcb_keycode32_iterator_t) void;
pub extern fn xcb_keycode32_end(i: xcb_keycode32_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_button_next(i: [*c]xcb_button_iterator_t) void;
pub extern fn xcb_button_end(i: xcb_button_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_point_next(i: [*c]xcb_point_iterator_t) void;
pub extern fn xcb_point_end(i: xcb_point_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_rectangle_next(i: [*c]xcb_rectangle_iterator_t) void;
pub extern fn xcb_rectangle_end(i: xcb_rectangle_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_arc_next(i: [*c]xcb_arc_iterator_t) void;
pub extern fn xcb_arc_end(i: xcb_arc_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_format_next(i: [*c]xcb_format_iterator_t) void;
pub extern fn xcb_format_end(i: xcb_format_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_visualtype_next(i: [*c]xcb_visualtype_iterator_t) void;
pub extern fn xcb_visualtype_end(i: xcb_visualtype_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_depth_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_depth_visuals(R: [*c]const xcb_depth_t) [*c]xcb_visualtype_t;
pub extern fn xcb_depth_visuals_length(R: [*c]const xcb_depth_t) c_int;
pub extern fn xcb_depth_visuals_iterator(R: [*c]const xcb_depth_t) xcb_visualtype_iterator_t;
pub extern fn xcb_depth_next(i: [*c]xcb_depth_iterator_t) void;
pub extern fn xcb_depth_end(i: xcb_depth_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_screen_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_screen_allowed_depths_length(R: [*c]const xcb_screen_t) c_int;
pub extern fn xcb_screen_allowed_depths_iterator(R: [*c]const xcb_screen_t) xcb_depth_iterator_t;
pub extern fn xcb_screen_next(i: [*c]xcb_screen_iterator_t) void;
pub extern fn xcb_screen_end(i: xcb_screen_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_setup_request_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_setup_request_authorization_protocol_name(R: [*c]const xcb_setup_request_t) [*c]u8;
pub extern fn xcb_setup_request_authorization_protocol_name_length(R: [*c]const xcb_setup_request_t) c_int;
pub extern fn xcb_setup_request_authorization_protocol_name_end(R: [*c]const xcb_setup_request_t) xcb_generic_iterator_t;
pub extern fn xcb_setup_request_authorization_protocol_data(R: [*c]const xcb_setup_request_t) [*c]u8;
pub extern fn xcb_setup_request_authorization_protocol_data_length(R: [*c]const xcb_setup_request_t) c_int;
pub extern fn xcb_setup_request_authorization_protocol_data_end(R: [*c]const xcb_setup_request_t) xcb_generic_iterator_t;
pub extern fn xcb_setup_request_next(i: [*c]xcb_setup_request_iterator_t) void;
pub extern fn xcb_setup_request_end(i: xcb_setup_request_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_setup_failed_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_setup_failed_reason(R: [*c]const xcb_setup_failed_t) [*c]u8;
pub extern fn xcb_setup_failed_reason_length(R: [*c]const xcb_setup_failed_t) c_int;
pub extern fn xcb_setup_failed_reason_end(R: [*c]const xcb_setup_failed_t) xcb_generic_iterator_t;
pub extern fn xcb_setup_failed_next(i: [*c]xcb_setup_failed_iterator_t) void;
pub extern fn xcb_setup_failed_end(i: xcb_setup_failed_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_setup_authenticate_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_setup_authenticate_reason(R: [*c]const xcb_setup_authenticate_t) [*c]u8;
pub extern fn xcb_setup_authenticate_reason_length(R: [*c]const xcb_setup_authenticate_t) c_int;
pub extern fn xcb_setup_authenticate_reason_end(R: [*c]const xcb_setup_authenticate_t) xcb_generic_iterator_t;
pub extern fn xcb_setup_authenticate_next(i: [*c]xcb_setup_authenticate_iterator_t) void;
pub extern fn xcb_setup_authenticate_end(i: xcb_setup_authenticate_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_setup_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_setup_vendor(R: [*c]const xcb_setup_t) [*c]u8;
pub extern fn xcb_setup_vendor_length(R: [*c]const xcb_setup_t) c_int;
pub extern fn xcb_setup_vendor_end(R: [*c]const xcb_setup_t) xcb_generic_iterator_t;
pub extern fn xcb_setup_pixmap_formats(R: [*c]const xcb_setup_t) [*c]xcb_format_t;
pub extern fn xcb_setup_pixmap_formats_length(R: [*c]const xcb_setup_t) c_int;
pub extern fn xcb_setup_pixmap_formats_iterator(R: [*c]const xcb_setup_t) xcb_format_iterator_t;
pub extern fn xcb_setup_roots_length(R: [*c]const xcb_setup_t) c_int;
pub extern fn xcb_setup_roots_iterator(R: [*c]const xcb_setup_t) xcb_screen_iterator_t;
pub extern fn xcb_setup_next(i: [*c]xcb_setup_iterator_t) void;
pub extern fn xcb_setup_end(i: xcb_setup_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_client_message_data_next(i: [*c]xcb_client_message_data_iterator_t) void;
pub extern fn xcb_client_message_data_end(i: xcb_client_message_data_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_create_window_value_list_serialize(_buffer: [*c]?*anyopaque, value_mask: u32, _aux: [*c]const xcb_create_window_value_list_t) c_int;
pub extern fn xcb_create_window_value_list_unpack(_buffer: ?*const anyopaque, value_mask: u32, _aux: [*c]xcb_create_window_value_list_t) c_int;
pub extern fn xcb_create_window_value_list_sizeof(_buffer: ?*const anyopaque, value_mask: u32) c_int;
pub extern fn xcb_create_window_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_create_window_checked(c: ?*xcb_connection_t, depth: u8, wid: xcb_window_t, parent: xcb_window_t, x: i16, y: i16, width: u16, height: u16, border_width: u16, _class: u16, visual: xcb_visualid_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_create_window(c: ?*xcb_connection_t, depth: u8, wid: xcb_window_t, parent: xcb_window_t, x: i16, y: i16, width: u16, height: u16, border_width: u16, _class: u16, visual: xcb_visualid_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_create_window_aux_checked(c: ?*xcb_connection_t, depth: u8, wid: xcb_window_t, parent: xcb_window_t, x: i16, y: i16, width: u16, height: u16, border_width: u16, _class: u16, visual: xcb_visualid_t, value_mask: u32, value_list: [*c]const xcb_create_window_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_create_window_aux(c: ?*xcb_connection_t, depth: u8, wid: xcb_window_t, parent: xcb_window_t, x: i16, y: i16, width: u16, height: u16, border_width: u16, _class: u16, visual: xcb_visualid_t, value_mask: u32, value_list: [*c]const xcb_create_window_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_create_window_value_list(R: [*c]const xcb_create_window_request_t) ?*anyopaque;
pub extern fn xcb_change_window_attributes_value_list_serialize(_buffer: [*c]?*anyopaque, value_mask: u32, _aux: [*c]const xcb_change_window_attributes_value_list_t) c_int;
pub extern fn xcb_change_window_attributes_value_list_unpack(_buffer: ?*const anyopaque, value_mask: u32, _aux: [*c]xcb_change_window_attributes_value_list_t) c_int;
pub extern fn xcb_change_window_attributes_value_list_sizeof(_buffer: ?*const anyopaque, value_mask: u32) c_int;
pub extern fn xcb_change_window_attributes_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_change_window_attributes_checked(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_change_window_attributes(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_change_window_attributes_aux_checked(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u32, value_list: [*c]const xcb_change_window_attributes_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_change_window_attributes_aux(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u32, value_list: [*c]const xcb_change_window_attributes_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_change_window_attributes_value_list(R: [*c]const xcb_change_window_attributes_request_t) ?*anyopaque;
pub extern fn xcb_get_window_attributes(c: ?*xcb_connection_t, window: xcb_window_t) xcb_get_window_attributes_cookie_t;
pub extern fn xcb_get_window_attributes_unchecked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_get_window_attributes_cookie_t;
pub extern fn xcb_get_window_attributes_reply(c: ?*xcb_connection_t, cookie: xcb_get_window_attributes_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_window_attributes_reply_t;
pub extern fn xcb_destroy_window_checked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_destroy_window(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_destroy_subwindows_checked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_destroy_subwindows(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_change_save_set_checked(c: ?*xcb_connection_t, mode: u8, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_change_save_set(c: ?*xcb_connection_t, mode: u8, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_reparent_window_checked(c: ?*xcb_connection_t, window: xcb_window_t, parent: xcb_window_t, x: i16, y: i16) xcb_void_cookie_t;
pub extern fn xcb_reparent_window(c: ?*xcb_connection_t, window: xcb_window_t, parent: xcb_window_t, x: i16, y: i16) xcb_void_cookie_t;
pub extern fn xcb_map_window_checked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_map_window(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_map_subwindows_checked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_map_subwindows(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_unmap_window_checked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_unmap_window(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_unmap_subwindows_checked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_unmap_subwindows(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_configure_window_value_list_serialize(_buffer: [*c]?*anyopaque, value_mask: u16, _aux: [*c]const xcb_configure_window_value_list_t) c_int;
pub extern fn xcb_configure_window_value_list_unpack(_buffer: ?*const anyopaque, value_mask: u16, _aux: [*c]xcb_configure_window_value_list_t) c_int;
pub extern fn xcb_configure_window_value_list_sizeof(_buffer: ?*const anyopaque, value_mask: u16) c_int;
pub extern fn xcb_configure_window_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_configure_window_checked(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u16, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_configure_window(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u16, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_configure_window_aux_checked(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u16, value_list: [*c]const xcb_configure_window_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_configure_window_aux(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u16, value_list: [*c]const xcb_configure_window_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_configure_window_value_list(R: [*c]const xcb_configure_window_request_t) ?*anyopaque;
pub extern fn xcb_circulate_window_checked(c: ?*xcb_connection_t, direction: u8, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_circulate_window(c: ?*xcb_connection_t, direction: u8, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_get_geometry(c: ?*xcb_connection_t, drawable: xcb_drawable_t) xcb_get_geometry_cookie_t;
pub extern fn xcb_get_geometry_unchecked(c: ?*xcb_connection_t, drawable: xcb_drawable_t) xcb_get_geometry_cookie_t;
pub extern fn xcb_get_geometry_reply(c: ?*xcb_connection_t, cookie: xcb_get_geometry_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_geometry_reply_t;
pub extern fn xcb_query_tree_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_query_tree(c: ?*xcb_connection_t, window: xcb_window_t) xcb_query_tree_cookie_t;
pub extern fn xcb_query_tree_unchecked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_query_tree_cookie_t;
pub extern fn xcb_query_tree_children(R: [*c]const xcb_query_tree_reply_t) [*c]xcb_window_t;
pub extern fn xcb_query_tree_children_length(R: [*c]const xcb_query_tree_reply_t) c_int;
pub extern fn xcb_query_tree_children_end(R: [*c]const xcb_query_tree_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_query_tree_reply(c: ?*xcb_connection_t, cookie: xcb_query_tree_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_query_tree_reply_t;
pub extern fn xcb_intern_atom_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_intern_atom(c: ?*xcb_connection_t, only_if_exists: u8, name_len: u16, name: [*c]const u8) xcb_intern_atom_cookie_t;
pub extern fn xcb_intern_atom_unchecked(c: ?*xcb_connection_t, only_if_exists: u8, name_len: u16, name: [*c]const u8) xcb_intern_atom_cookie_t;
pub extern fn xcb_intern_atom_reply(c: ?*xcb_connection_t, cookie: xcb_intern_atom_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_intern_atom_reply_t;
pub extern fn xcb_get_atom_name_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_get_atom_name(c: ?*xcb_connection_t, atom: xcb_atom_t) xcb_get_atom_name_cookie_t;
pub extern fn xcb_get_atom_name_unchecked(c: ?*xcb_connection_t, atom: xcb_atom_t) xcb_get_atom_name_cookie_t;
pub extern fn xcb_get_atom_name_name(R: [*c]const xcb_get_atom_name_reply_t) [*c]u8;
pub extern fn xcb_get_atom_name_name_length(R: [*c]const xcb_get_atom_name_reply_t) c_int;
pub extern fn xcb_get_atom_name_name_end(R: [*c]const xcb_get_atom_name_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_get_atom_name_reply(c: ?*xcb_connection_t, cookie: xcb_get_atom_name_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_atom_name_reply_t;
pub extern fn xcb_change_property_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_change_property_checked(c: ?*xcb_connection_t, mode: u8, window: xcb_window_t, property: xcb_atom_t, @"type": xcb_atom_t, format: u8, data_len: u32, data: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_change_property(c: ?*xcb_connection_t, mode: u8, window: xcb_window_t, property: xcb_atom_t, @"type": xcb_atom_t, format: u8, data_len: u32, data: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_change_property_data(R: [*c]const xcb_change_property_request_t) ?*anyopaque;
pub extern fn xcb_change_property_data_length(R: [*c]const xcb_change_property_request_t) c_int;
pub extern fn xcb_change_property_data_end(R: [*c]const xcb_change_property_request_t) xcb_generic_iterator_t;
pub extern fn xcb_delete_property_checked(c: ?*xcb_connection_t, window: xcb_window_t, property: xcb_atom_t) xcb_void_cookie_t;
pub extern fn xcb_delete_property(c: ?*xcb_connection_t, window: xcb_window_t, property: xcb_atom_t) xcb_void_cookie_t;
pub extern fn xcb_get_property_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_get_property(c: ?*xcb_connection_t, _delete: u8, window: xcb_window_t, property: xcb_atom_t, @"type": xcb_atom_t, long_offset: u32, long_length: u32) xcb_get_property_cookie_t;
pub extern fn xcb_get_property_unchecked(c: ?*xcb_connection_t, _delete: u8, window: xcb_window_t, property: xcb_atom_t, @"type": xcb_atom_t, long_offset: u32, long_length: u32) xcb_get_property_cookie_t;
pub extern fn xcb_get_property_value(R: [*c]const xcb_get_property_reply_t) ?*anyopaque;
pub extern fn xcb_get_property_value_length(R: [*c]const xcb_get_property_reply_t) c_int;
pub extern fn xcb_get_property_value_end(R: [*c]const xcb_get_property_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_get_property_reply(c: ?*xcb_connection_t, cookie: xcb_get_property_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_property_reply_t;
pub extern fn xcb_list_properties_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_list_properties(c: ?*xcb_connection_t, window: xcb_window_t) xcb_list_properties_cookie_t;
pub extern fn xcb_list_properties_unchecked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_list_properties_cookie_t;
pub extern fn xcb_list_properties_atoms(R: [*c]const xcb_list_properties_reply_t) [*c]xcb_atom_t;
pub extern fn xcb_list_properties_atoms_length(R: [*c]const xcb_list_properties_reply_t) c_int;
pub extern fn xcb_list_properties_atoms_end(R: [*c]const xcb_list_properties_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_list_properties_reply(c: ?*xcb_connection_t, cookie: xcb_list_properties_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_list_properties_reply_t;
pub extern fn xcb_set_selection_owner_checked(c: ?*xcb_connection_t, owner: xcb_window_t, selection: xcb_atom_t, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_set_selection_owner(c: ?*xcb_connection_t, owner: xcb_window_t, selection: xcb_atom_t, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_get_selection_owner(c: ?*xcb_connection_t, selection: xcb_atom_t) xcb_get_selection_owner_cookie_t;
pub extern fn xcb_get_selection_owner_unchecked(c: ?*xcb_connection_t, selection: xcb_atom_t) xcb_get_selection_owner_cookie_t;
pub extern fn xcb_get_selection_owner_reply(c: ?*xcb_connection_t, cookie: xcb_get_selection_owner_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_selection_owner_reply_t;
pub extern fn xcb_convert_selection_checked(c: ?*xcb_connection_t, requestor: xcb_window_t, selection: xcb_atom_t, target: xcb_atom_t, property: xcb_atom_t, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_convert_selection(c: ?*xcb_connection_t, requestor: xcb_window_t, selection: xcb_atom_t, target: xcb_atom_t, property: xcb_atom_t, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_send_event_checked(c: ?*xcb_connection_t, propagate: u8, destination: xcb_window_t, event_mask: u32, event: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_send_event(c: ?*xcb_connection_t, propagate: u8, destination: xcb_window_t, event_mask: u32, event: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_grab_pointer(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, event_mask: u16, pointer_mode: u8, keyboard_mode: u8, confine_to: xcb_window_t, cursor: xcb_cursor_t, time: xcb_timestamp_t) xcb_grab_pointer_cookie_t;
pub extern fn xcb_grab_pointer_unchecked(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, event_mask: u16, pointer_mode: u8, keyboard_mode: u8, confine_to: xcb_window_t, cursor: xcb_cursor_t, time: xcb_timestamp_t) xcb_grab_pointer_cookie_t;
pub extern fn xcb_grab_pointer_reply(c: ?*xcb_connection_t, cookie: xcb_grab_pointer_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_grab_pointer_reply_t;
pub extern fn xcb_ungrab_pointer_checked(c: ?*xcb_connection_t, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_ungrab_pointer(c: ?*xcb_connection_t, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_grab_button_checked(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, event_mask: u16, pointer_mode: u8, keyboard_mode: u8, confine_to: xcb_window_t, cursor: xcb_cursor_t, button: u8, modifiers: u16) xcb_void_cookie_t;
pub extern fn xcb_grab_button(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, event_mask: u16, pointer_mode: u8, keyboard_mode: u8, confine_to: xcb_window_t, cursor: xcb_cursor_t, button: u8, modifiers: u16) xcb_void_cookie_t;
pub extern fn xcb_ungrab_button_checked(c: ?*xcb_connection_t, button: u8, grab_window: xcb_window_t, modifiers: u16) xcb_void_cookie_t;
pub extern fn xcb_ungrab_button(c: ?*xcb_connection_t, button: u8, grab_window: xcb_window_t, modifiers: u16) xcb_void_cookie_t;
pub extern fn xcb_change_active_pointer_grab_checked(c: ?*xcb_connection_t, cursor: xcb_cursor_t, time: xcb_timestamp_t, event_mask: u16) xcb_void_cookie_t;
pub extern fn xcb_change_active_pointer_grab(c: ?*xcb_connection_t, cursor: xcb_cursor_t, time: xcb_timestamp_t, event_mask: u16) xcb_void_cookie_t;
pub extern fn xcb_grab_keyboard(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, time: xcb_timestamp_t, pointer_mode: u8, keyboard_mode: u8) xcb_grab_keyboard_cookie_t;
pub extern fn xcb_grab_keyboard_unchecked(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, time: xcb_timestamp_t, pointer_mode: u8, keyboard_mode: u8) xcb_grab_keyboard_cookie_t;
pub extern fn xcb_grab_keyboard_reply(c: ?*xcb_connection_t, cookie: xcb_grab_keyboard_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_grab_keyboard_reply_t;
pub extern fn xcb_ungrab_keyboard_checked(c: ?*xcb_connection_t, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_ungrab_keyboard(c: ?*xcb_connection_t, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_grab_key_checked(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, modifiers: u16, key: xcb_keycode_t, pointer_mode: u8, keyboard_mode: u8) xcb_void_cookie_t;
pub extern fn xcb_grab_key(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, modifiers: u16, key: xcb_keycode_t, pointer_mode: u8, keyboard_mode: u8) xcb_void_cookie_t;
pub extern fn xcb_ungrab_key_checked(c: ?*xcb_connection_t, key: xcb_keycode_t, grab_window: xcb_window_t, modifiers: u16) xcb_void_cookie_t;
pub extern fn xcb_ungrab_key(c: ?*xcb_connection_t, key: xcb_keycode_t, grab_window: xcb_window_t, modifiers: u16) xcb_void_cookie_t;
pub extern fn xcb_allow_events_checked(c: ?*xcb_connection_t, mode: u8, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_allow_events(c: ?*xcb_connection_t, mode: u8, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_grab_server_checked(c: ?*xcb_connection_t) xcb_void_cookie_t;
pub extern fn xcb_grab_server(c: ?*xcb_connection_t) xcb_void_cookie_t;
pub extern fn xcb_ungrab_server_checked(c: ?*xcb_connection_t) xcb_void_cookie_t;
pub extern fn xcb_ungrab_server(c: ?*xcb_connection_t) xcb_void_cookie_t;
pub extern fn xcb_query_pointer(c: ?*xcb_connection_t, window: xcb_window_t) xcb_query_pointer_cookie_t;
pub extern fn xcb_query_pointer_unchecked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_query_pointer_cookie_t;
pub extern fn xcb_query_pointer_reply(c: ?*xcb_connection_t, cookie: xcb_query_pointer_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_query_pointer_reply_t;
pub extern fn xcb_timecoord_next(i: [*c]xcb_timecoord_iterator_t) void;
pub extern fn xcb_timecoord_end(i: xcb_timecoord_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_get_motion_events_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_get_motion_events(c: ?*xcb_connection_t, window: xcb_window_t, start: xcb_timestamp_t, stop: xcb_timestamp_t) xcb_get_motion_events_cookie_t;
pub extern fn xcb_get_motion_events_unchecked(c: ?*xcb_connection_t, window: xcb_window_t, start: xcb_timestamp_t, stop: xcb_timestamp_t) xcb_get_motion_events_cookie_t;
pub extern fn xcb_get_motion_events_events(R: [*c]const xcb_get_motion_events_reply_t) [*c]xcb_timecoord_t;
pub extern fn xcb_get_motion_events_events_length(R: [*c]const xcb_get_motion_events_reply_t) c_int;
pub extern fn xcb_get_motion_events_events_iterator(R: [*c]const xcb_get_motion_events_reply_t) xcb_timecoord_iterator_t;
pub extern fn xcb_get_motion_events_reply(c: ?*xcb_connection_t, cookie: xcb_get_motion_events_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_motion_events_reply_t;
pub extern fn xcb_translate_coordinates(c: ?*xcb_connection_t, src_window: xcb_window_t, dst_window: xcb_window_t, src_x: i16, src_y: i16) xcb_translate_coordinates_cookie_t;
pub extern fn xcb_translate_coordinates_unchecked(c: ?*xcb_connection_t, src_window: xcb_window_t, dst_window: xcb_window_t, src_x: i16, src_y: i16) xcb_translate_coordinates_cookie_t;
pub extern fn xcb_translate_coordinates_reply(c: ?*xcb_connection_t, cookie: xcb_translate_coordinates_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_translate_coordinates_reply_t;
pub extern fn xcb_warp_pointer_checked(c: ?*xcb_connection_t, src_window: xcb_window_t, dst_window: xcb_window_t, src_x: i16, src_y: i16, src_width: u16, src_height: u16, dst_x: i16, dst_y: i16) xcb_void_cookie_t;
pub extern fn xcb_warp_pointer(c: ?*xcb_connection_t, src_window: xcb_window_t, dst_window: xcb_window_t, src_x: i16, src_y: i16, src_width: u16, src_height: u16, dst_x: i16, dst_y: i16) xcb_void_cookie_t;
pub extern fn xcb_set_input_focus_checked(c: ?*xcb_connection_t, revert_to: u8, focus: xcb_window_t, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_set_input_focus(c: ?*xcb_connection_t, revert_to: u8, focus: xcb_window_t, time: xcb_timestamp_t) xcb_void_cookie_t;
pub extern fn xcb_get_input_focus(c: ?*xcb_connection_t) xcb_get_input_focus_cookie_t;
pub extern fn xcb_get_input_focus_unchecked(c: ?*xcb_connection_t) xcb_get_input_focus_cookie_t;
pub extern fn xcb_get_input_focus_reply(c: ?*xcb_connection_t, cookie: xcb_get_input_focus_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_input_focus_reply_t;
pub extern fn xcb_query_keymap(c: ?*xcb_connection_t) xcb_query_keymap_cookie_t;
pub extern fn xcb_query_keymap_unchecked(c: ?*xcb_connection_t) xcb_query_keymap_cookie_t;
pub extern fn xcb_query_keymap_reply(c: ?*xcb_connection_t, cookie: xcb_query_keymap_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_query_keymap_reply_t;
pub extern fn xcb_open_font_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_open_font_checked(c: ?*xcb_connection_t, fid: xcb_font_t, name_len: u16, name: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_open_font(c: ?*xcb_connection_t, fid: xcb_font_t, name_len: u16, name: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_open_font_name(R: [*c]const xcb_open_font_request_t) [*c]u8;
pub extern fn xcb_open_font_name_length(R: [*c]const xcb_open_font_request_t) c_int;
pub extern fn xcb_open_font_name_end(R: [*c]const xcb_open_font_request_t) xcb_generic_iterator_t;
pub extern fn xcb_close_font_checked(c: ?*xcb_connection_t, font: xcb_font_t) xcb_void_cookie_t;
pub extern fn xcb_close_font(c: ?*xcb_connection_t, font: xcb_font_t) xcb_void_cookie_t;
pub extern fn xcb_fontprop_next(i: [*c]xcb_fontprop_iterator_t) void;
pub extern fn xcb_fontprop_end(i: xcb_fontprop_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_charinfo_next(i: [*c]xcb_charinfo_iterator_t) void;
pub extern fn xcb_charinfo_end(i: xcb_charinfo_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_query_font_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_query_font(c: ?*xcb_connection_t, font: xcb_fontable_t) xcb_query_font_cookie_t;
pub extern fn xcb_query_font_unchecked(c: ?*xcb_connection_t, font: xcb_fontable_t) xcb_query_font_cookie_t;
pub extern fn xcb_query_font_properties(R: [*c]const xcb_query_font_reply_t) [*c]xcb_fontprop_t;
pub extern fn xcb_query_font_properties_length(R: [*c]const xcb_query_font_reply_t) c_int;
pub extern fn xcb_query_font_properties_iterator(R: [*c]const xcb_query_font_reply_t) xcb_fontprop_iterator_t;
pub extern fn xcb_query_font_char_infos(R: [*c]const xcb_query_font_reply_t) [*c]xcb_charinfo_t;
pub extern fn xcb_query_font_char_infos_length(R: [*c]const xcb_query_font_reply_t) c_int;
pub extern fn xcb_query_font_char_infos_iterator(R: [*c]const xcb_query_font_reply_t) xcb_charinfo_iterator_t;
pub extern fn xcb_query_font_reply(c: ?*xcb_connection_t, cookie: xcb_query_font_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_query_font_reply_t;
pub extern fn xcb_query_text_extents_sizeof(_buffer: ?*const anyopaque, string_len: u32) c_int;
pub extern fn xcb_query_text_extents(c: ?*xcb_connection_t, font: xcb_fontable_t, string_len: u32, string: [*c]const xcb_char2b_t) xcb_query_text_extents_cookie_t;
pub extern fn xcb_query_text_extents_unchecked(c: ?*xcb_connection_t, font: xcb_fontable_t, string_len: u32, string: [*c]const xcb_char2b_t) xcb_query_text_extents_cookie_t;
pub extern fn xcb_query_text_extents_reply(c: ?*xcb_connection_t, cookie: xcb_query_text_extents_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_query_text_extents_reply_t;
pub extern fn xcb_str_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_str_name(R: [*c]const xcb_str_t) [*c]u8;
pub extern fn xcb_str_name_length(R: [*c]const xcb_str_t) c_int;
pub extern fn xcb_str_name_end(R: [*c]const xcb_str_t) xcb_generic_iterator_t;
pub extern fn xcb_str_next(i: [*c]xcb_str_iterator_t) void;
pub extern fn xcb_str_end(i: xcb_str_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_list_fonts_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_list_fonts(c: ?*xcb_connection_t, max_names: u16, pattern_len: u16, pattern: [*c]const u8) xcb_list_fonts_cookie_t;
pub extern fn xcb_list_fonts_unchecked(c: ?*xcb_connection_t, max_names: u16, pattern_len: u16, pattern: [*c]const u8) xcb_list_fonts_cookie_t;
pub extern fn xcb_list_fonts_names_length(R: [*c]const xcb_list_fonts_reply_t) c_int;
pub extern fn xcb_list_fonts_names_iterator(R: [*c]const xcb_list_fonts_reply_t) xcb_str_iterator_t;
pub extern fn xcb_list_fonts_reply(c: ?*xcb_connection_t, cookie: xcb_list_fonts_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_list_fonts_reply_t;
pub extern fn xcb_list_fonts_with_info_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_list_fonts_with_info(c: ?*xcb_connection_t, max_names: u16, pattern_len: u16, pattern: [*c]const u8) xcb_list_fonts_with_info_cookie_t;
pub extern fn xcb_list_fonts_with_info_unchecked(c: ?*xcb_connection_t, max_names: u16, pattern_len: u16, pattern: [*c]const u8) xcb_list_fonts_with_info_cookie_t;
pub extern fn xcb_list_fonts_with_info_properties(R: [*c]const xcb_list_fonts_with_info_reply_t) [*c]xcb_fontprop_t;
pub extern fn xcb_list_fonts_with_info_properties_length(R: [*c]const xcb_list_fonts_with_info_reply_t) c_int;
pub extern fn xcb_list_fonts_with_info_properties_iterator(R: [*c]const xcb_list_fonts_with_info_reply_t) xcb_fontprop_iterator_t;
pub extern fn xcb_list_fonts_with_info_name(R: [*c]const xcb_list_fonts_with_info_reply_t) [*c]u8;
pub extern fn xcb_list_fonts_with_info_name_length(R: [*c]const xcb_list_fonts_with_info_reply_t) c_int;
pub extern fn xcb_list_fonts_with_info_name_end(R: [*c]const xcb_list_fonts_with_info_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_list_fonts_with_info_reply(c: ?*xcb_connection_t, cookie: xcb_list_fonts_with_info_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_list_fonts_with_info_reply_t;
pub extern fn xcb_set_font_path_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_set_font_path_checked(c: ?*xcb_connection_t, font_qty: u16, font: [*c]const xcb_str_t) xcb_void_cookie_t;
pub extern fn xcb_set_font_path(c: ?*xcb_connection_t, font_qty: u16, font: [*c]const xcb_str_t) xcb_void_cookie_t;
pub extern fn xcb_set_font_path_font_length(R: [*c]const xcb_set_font_path_request_t) c_int;
pub extern fn xcb_set_font_path_font_iterator(R: [*c]const xcb_set_font_path_request_t) xcb_str_iterator_t;
pub extern fn xcb_get_font_path_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_get_font_path(c: ?*xcb_connection_t) xcb_get_font_path_cookie_t;
pub extern fn xcb_get_font_path_unchecked(c: ?*xcb_connection_t) xcb_get_font_path_cookie_t;
pub extern fn xcb_get_font_path_path_length(R: [*c]const xcb_get_font_path_reply_t) c_int;
pub extern fn xcb_get_font_path_path_iterator(R: [*c]const xcb_get_font_path_reply_t) xcb_str_iterator_t;
pub extern fn xcb_get_font_path_reply(c: ?*xcb_connection_t, cookie: xcb_get_font_path_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_font_path_reply_t;
pub extern fn xcb_create_pixmap_checked(c: ?*xcb_connection_t, depth: u8, pid: xcb_pixmap_t, drawable: xcb_drawable_t, width: u16, height: u16) xcb_void_cookie_t;
pub extern fn xcb_create_pixmap(c: ?*xcb_connection_t, depth: u8, pid: xcb_pixmap_t, drawable: xcb_drawable_t, width: u16, height: u16) xcb_void_cookie_t;
pub extern fn xcb_free_pixmap_checked(c: ?*xcb_connection_t, pixmap: xcb_pixmap_t) xcb_void_cookie_t;
pub extern fn xcb_free_pixmap(c: ?*xcb_connection_t, pixmap: xcb_pixmap_t) xcb_void_cookie_t;
pub extern fn xcb_create_gc_value_list_serialize(_buffer: [*c]?*anyopaque, value_mask: u32, _aux: [*c]const xcb_create_gc_value_list_t) c_int;
pub extern fn xcb_create_gc_value_list_unpack(_buffer: ?*const anyopaque, value_mask: u32, _aux: [*c]xcb_create_gc_value_list_t) c_int;
pub extern fn xcb_create_gc_value_list_sizeof(_buffer: ?*const anyopaque, value_mask: u32) c_int;
pub extern fn xcb_create_gc_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_create_gc_checked(c: ?*xcb_connection_t, cid: xcb_gcontext_t, drawable: xcb_drawable_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_create_gc(c: ?*xcb_connection_t, cid: xcb_gcontext_t, drawable: xcb_drawable_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_create_gc_aux_checked(c: ?*xcb_connection_t, cid: xcb_gcontext_t, drawable: xcb_drawable_t, value_mask: u32, value_list: [*c]const xcb_create_gc_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_create_gc_aux(c: ?*xcb_connection_t, cid: xcb_gcontext_t, drawable: xcb_drawable_t, value_mask: u32, value_list: [*c]const xcb_create_gc_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_create_gc_value_list(R: [*c]const xcb_create_gc_request_t) ?*anyopaque;
pub extern fn xcb_change_gc_value_list_serialize(_buffer: [*c]?*anyopaque, value_mask: u32, _aux: [*c]const xcb_change_gc_value_list_t) c_int;
pub extern fn xcb_change_gc_value_list_unpack(_buffer: ?*const anyopaque, value_mask: u32, _aux: [*c]xcb_change_gc_value_list_t) c_int;
pub extern fn xcb_change_gc_value_list_sizeof(_buffer: ?*const anyopaque, value_mask: u32) c_int;
pub extern fn xcb_change_gc_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_change_gc_checked(c: ?*xcb_connection_t, gc: xcb_gcontext_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_change_gc(c: ?*xcb_connection_t, gc: xcb_gcontext_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_change_gc_aux_checked(c: ?*xcb_connection_t, gc: xcb_gcontext_t, value_mask: u32, value_list: [*c]const xcb_change_gc_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_change_gc_aux(c: ?*xcb_connection_t, gc: xcb_gcontext_t, value_mask: u32, value_list: [*c]const xcb_change_gc_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_change_gc_value_list(R: [*c]const xcb_change_gc_request_t) ?*anyopaque;
pub extern fn xcb_copy_gc_checked(c: ?*xcb_connection_t, src_gc: xcb_gcontext_t, dst_gc: xcb_gcontext_t, value_mask: u32) xcb_void_cookie_t;
pub extern fn xcb_copy_gc(c: ?*xcb_connection_t, src_gc: xcb_gcontext_t, dst_gc: xcb_gcontext_t, value_mask: u32) xcb_void_cookie_t;
pub extern fn xcb_set_dashes_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_set_dashes_checked(c: ?*xcb_connection_t, gc: xcb_gcontext_t, dash_offset: u16, dashes_len: u16, dashes: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_set_dashes(c: ?*xcb_connection_t, gc: xcb_gcontext_t, dash_offset: u16, dashes_len: u16, dashes: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_set_dashes_dashes(R: [*c]const xcb_set_dashes_request_t) [*c]u8;
pub extern fn xcb_set_dashes_dashes_length(R: [*c]const xcb_set_dashes_request_t) c_int;
pub extern fn xcb_set_dashes_dashes_end(R: [*c]const xcb_set_dashes_request_t) xcb_generic_iterator_t;
pub extern fn xcb_set_clip_rectangles_sizeof(_buffer: ?*const anyopaque, rectangles_len: u32) c_int;
pub extern fn xcb_set_clip_rectangles_checked(c: ?*xcb_connection_t, ordering: u8, gc: xcb_gcontext_t, clip_x_origin: i16, clip_y_origin: i16, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_set_clip_rectangles(c: ?*xcb_connection_t, ordering: u8, gc: xcb_gcontext_t, clip_x_origin: i16, clip_y_origin: i16, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_set_clip_rectangles_rectangles(R: [*c]const xcb_set_clip_rectangles_request_t) [*c]xcb_rectangle_t;
pub extern fn xcb_set_clip_rectangles_rectangles_length(R: [*c]const xcb_set_clip_rectangles_request_t) c_int;
pub extern fn xcb_set_clip_rectangles_rectangles_iterator(R: [*c]const xcb_set_clip_rectangles_request_t) xcb_rectangle_iterator_t;
pub extern fn xcb_free_gc_checked(c: ?*xcb_connection_t, gc: xcb_gcontext_t) xcb_void_cookie_t;
pub extern fn xcb_free_gc(c: ?*xcb_connection_t, gc: xcb_gcontext_t) xcb_void_cookie_t;
pub extern fn xcb_clear_area_checked(c: ?*xcb_connection_t, exposures: u8, window: xcb_window_t, x: i16, y: i16, width: u16, height: u16) xcb_void_cookie_t;
pub extern fn xcb_clear_area(c: ?*xcb_connection_t, exposures: u8, window: xcb_window_t, x: i16, y: i16, width: u16, height: u16) xcb_void_cookie_t;
pub extern fn xcb_copy_area_checked(c: ?*xcb_connection_t, src_drawable: xcb_drawable_t, dst_drawable: xcb_drawable_t, gc: xcb_gcontext_t, src_x: i16, src_y: i16, dst_x: i16, dst_y: i16, width: u16, height: u16) xcb_void_cookie_t;
pub extern fn xcb_copy_area(c: ?*xcb_connection_t, src_drawable: xcb_drawable_t, dst_drawable: xcb_drawable_t, gc: xcb_gcontext_t, src_x: i16, src_y: i16, dst_x: i16, dst_y: i16, width: u16, height: u16) xcb_void_cookie_t;
pub extern fn xcb_copy_plane_checked(c: ?*xcb_connection_t, src_drawable: xcb_drawable_t, dst_drawable: xcb_drawable_t, gc: xcb_gcontext_t, src_x: i16, src_y: i16, dst_x: i16, dst_y: i16, width: u16, height: u16, bit_plane: u32) xcb_void_cookie_t;
pub extern fn xcb_copy_plane(c: ?*xcb_connection_t, src_drawable: xcb_drawable_t, dst_drawable: xcb_drawable_t, gc: xcb_gcontext_t, src_x: i16, src_y: i16, dst_x: i16, dst_y: i16, width: u16, height: u16, bit_plane: u32) xcb_void_cookie_t;
pub extern fn xcb_poly_point_sizeof(_buffer: ?*const anyopaque, points_len: u32) c_int;
pub extern fn xcb_poly_point_checked(c: ?*xcb_connection_t, coordinate_mode: u8, drawable: xcb_drawable_t, gc: xcb_gcontext_t, points_len: u32, points: [*c]const xcb_point_t) xcb_void_cookie_t;
pub extern fn xcb_poly_point(c: ?*xcb_connection_t, coordinate_mode: u8, drawable: xcb_drawable_t, gc: xcb_gcontext_t, points_len: u32, points: [*c]const xcb_point_t) xcb_void_cookie_t;
pub extern fn xcb_poly_point_points(R: [*c]const xcb_poly_point_request_t) [*c]xcb_point_t;
pub extern fn xcb_poly_point_points_length(R: [*c]const xcb_poly_point_request_t) c_int;
pub extern fn xcb_poly_point_points_iterator(R: [*c]const xcb_poly_point_request_t) xcb_point_iterator_t;
pub extern fn xcb_poly_line_sizeof(_buffer: ?*const anyopaque, points_len: u32) c_int;
pub extern fn xcb_poly_line_checked(c: ?*xcb_connection_t, coordinate_mode: u8, drawable: xcb_drawable_t, gc: xcb_gcontext_t, points_len: u32, points: [*c]const xcb_point_t) xcb_void_cookie_t;
pub extern fn xcb_poly_line(c: ?*xcb_connection_t, coordinate_mode: u8, drawable: xcb_drawable_t, gc: xcb_gcontext_t, points_len: u32, points: [*c]const xcb_point_t) xcb_void_cookie_t;
pub extern fn xcb_poly_line_points(R: [*c]const xcb_poly_line_request_t) [*c]xcb_point_t;
pub extern fn xcb_poly_line_points_length(R: [*c]const xcb_poly_line_request_t) c_int;
pub extern fn xcb_poly_line_points_iterator(R: [*c]const xcb_poly_line_request_t) xcb_point_iterator_t;
pub extern fn xcb_segment_next(i: [*c]xcb_segment_iterator_t) void;
pub extern fn xcb_segment_end(i: xcb_segment_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_poly_segment_sizeof(_buffer: ?*const anyopaque, segments_len: u32) c_int;
pub extern fn xcb_poly_segment_checked(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, segments_len: u32, segments: [*c]const xcb_segment_t) xcb_void_cookie_t;
pub extern fn xcb_poly_segment(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, segments_len: u32, segments: [*c]const xcb_segment_t) xcb_void_cookie_t;
pub extern fn xcb_poly_segment_segments(R: [*c]const xcb_poly_segment_request_t) [*c]xcb_segment_t;
pub extern fn xcb_poly_segment_segments_length(R: [*c]const xcb_poly_segment_request_t) c_int;
pub extern fn xcb_poly_segment_segments_iterator(R: [*c]const xcb_poly_segment_request_t) xcb_segment_iterator_t;
pub extern fn xcb_poly_rectangle_sizeof(_buffer: ?*const anyopaque, rectangles_len: u32) c_int;
pub extern fn xcb_poly_rectangle_checked(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_poly_rectangle(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_poly_rectangle_rectangles(R: [*c]const xcb_poly_rectangle_request_t) [*c]xcb_rectangle_t;
pub extern fn xcb_poly_rectangle_rectangles_length(R: [*c]const xcb_poly_rectangle_request_t) c_int;
pub extern fn xcb_poly_rectangle_rectangles_iterator(R: [*c]const xcb_poly_rectangle_request_t) xcb_rectangle_iterator_t;
pub extern fn xcb_poly_arc_sizeof(_buffer: ?*const anyopaque, arcs_len: u32) c_int;
pub extern fn xcb_poly_arc_checked(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, arcs_len: u32, arcs: [*c]const xcb_arc_t) xcb_void_cookie_t;
pub extern fn xcb_poly_arc(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, arcs_len: u32, arcs: [*c]const xcb_arc_t) xcb_void_cookie_t;
pub extern fn xcb_poly_arc_arcs(R: [*c]const xcb_poly_arc_request_t) [*c]xcb_arc_t;
pub extern fn xcb_poly_arc_arcs_length(R: [*c]const xcb_poly_arc_request_t) c_int;
pub extern fn xcb_poly_arc_arcs_iterator(R: [*c]const xcb_poly_arc_request_t) xcb_arc_iterator_t;
pub extern fn xcb_fill_poly_sizeof(_buffer: ?*const anyopaque, points_len: u32) c_int;
pub extern fn xcb_fill_poly_checked(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, shape: u8, coordinate_mode: u8, points_len: u32, points: [*c]const xcb_point_t) xcb_void_cookie_t;
pub extern fn xcb_fill_poly(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, shape: u8, coordinate_mode: u8, points_len: u32, points: [*c]const xcb_point_t) xcb_void_cookie_t;
pub extern fn xcb_fill_poly_points(R: [*c]const xcb_fill_poly_request_t) [*c]xcb_point_t;
pub extern fn xcb_fill_poly_points_length(R: [*c]const xcb_fill_poly_request_t) c_int;
pub extern fn xcb_fill_poly_points_iterator(R: [*c]const xcb_fill_poly_request_t) xcb_point_iterator_t;
pub extern fn xcb_poly_fill_rectangle_sizeof(_buffer: ?*const anyopaque, rectangles_len: u32) c_int;
pub extern fn xcb_poly_fill_rectangle_checked(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_poly_fill_rectangle(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_poly_fill_rectangle_rectangles(R: [*c]const xcb_poly_fill_rectangle_request_t) [*c]xcb_rectangle_t;
pub extern fn xcb_poly_fill_rectangle_rectangles_length(R: [*c]const xcb_poly_fill_rectangle_request_t) c_int;
pub extern fn xcb_poly_fill_rectangle_rectangles_iterator(R: [*c]const xcb_poly_fill_rectangle_request_t) xcb_rectangle_iterator_t;
pub extern fn xcb_poly_fill_arc_sizeof(_buffer: ?*const anyopaque, arcs_len: u32) c_int;
pub extern fn xcb_poly_fill_arc_checked(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, arcs_len: u32, arcs: [*c]const xcb_arc_t) xcb_void_cookie_t;
pub extern fn xcb_poly_fill_arc(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, arcs_len: u32, arcs: [*c]const xcb_arc_t) xcb_void_cookie_t;
pub extern fn xcb_poly_fill_arc_arcs(R: [*c]const xcb_poly_fill_arc_request_t) [*c]xcb_arc_t;
pub extern fn xcb_poly_fill_arc_arcs_length(R: [*c]const xcb_poly_fill_arc_request_t) c_int;
pub extern fn xcb_poly_fill_arc_arcs_iterator(R: [*c]const xcb_poly_fill_arc_request_t) xcb_arc_iterator_t;
pub extern fn xcb_put_image_sizeof(_buffer: ?*const anyopaque, data_len: u32) c_int;
pub extern fn xcb_put_image_checked(c: ?*xcb_connection_t, format: u8, drawable: xcb_drawable_t, gc: xcb_gcontext_t, width: u16, height: u16, dst_x: i16, dst_y: i16, left_pad: u8, depth: u8, data_len: u32, data: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_put_image(c: ?*xcb_connection_t, format: u8, drawable: xcb_drawable_t, gc: xcb_gcontext_t, width: u16, height: u16, dst_x: i16, dst_y: i16, left_pad: u8, depth: u8, data_len: u32, data: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_put_image_data(R: [*c]const xcb_put_image_request_t) [*c]u8;
pub extern fn xcb_put_image_data_length(R: [*c]const xcb_put_image_request_t) c_int;
pub extern fn xcb_put_image_data_end(R: [*c]const xcb_put_image_request_t) xcb_generic_iterator_t;
pub extern fn xcb_get_image_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_get_image(c: ?*xcb_connection_t, format: u8, drawable: xcb_drawable_t, x: i16, y: i16, width: u16, height: u16, plane_mask: u32) xcb_get_image_cookie_t;
pub extern fn xcb_get_image_unchecked(c: ?*xcb_connection_t, format: u8, drawable: xcb_drawable_t, x: i16, y: i16, width: u16, height: u16, plane_mask: u32) xcb_get_image_cookie_t;
pub extern fn xcb_get_image_data(R: [*c]const xcb_get_image_reply_t) [*c]u8;
pub extern fn xcb_get_image_data_length(R: [*c]const xcb_get_image_reply_t) c_int;
pub extern fn xcb_get_image_data_end(R: [*c]const xcb_get_image_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_get_image_reply(c: ?*xcb_connection_t, cookie: xcb_get_image_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_image_reply_t;
pub extern fn xcb_poly_text_8_sizeof(_buffer: ?*const anyopaque, items_len: u32) c_int;
pub extern fn xcb_poly_text_8_checked(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, x: i16, y: i16, items_len: u32, items: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_poly_text_8(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, x: i16, y: i16, items_len: u32, items: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_poly_text_8_items(R: [*c]const xcb_poly_text_8_request_t) [*c]u8;
pub extern fn xcb_poly_text_8_items_length(R: [*c]const xcb_poly_text_8_request_t) c_int;
pub extern fn xcb_poly_text_8_items_end(R: [*c]const xcb_poly_text_8_request_t) xcb_generic_iterator_t;
pub extern fn xcb_poly_text_16_sizeof(_buffer: ?*const anyopaque, items_len: u32) c_int;
pub extern fn xcb_poly_text_16_checked(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, x: i16, y: i16, items_len: u32, items: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_poly_text_16(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, x: i16, y: i16, items_len: u32, items: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_poly_text_16_items(R: [*c]const xcb_poly_text_16_request_t) [*c]u8;
pub extern fn xcb_poly_text_16_items_length(R: [*c]const xcb_poly_text_16_request_t) c_int;
pub extern fn xcb_poly_text_16_items_end(R: [*c]const xcb_poly_text_16_request_t) xcb_generic_iterator_t;
pub extern fn xcb_image_text_8_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_image_text_8_checked(c: ?*xcb_connection_t, string_len: u8, drawable: xcb_drawable_t, gc: xcb_gcontext_t, x: i16, y: i16, string: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_image_text_8(c: ?*xcb_connection_t, string_len: u8, drawable: xcb_drawable_t, gc: xcb_gcontext_t, x: i16, y: i16, string: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_image_text_8_string(R: [*c]const xcb_image_text_8_request_t) [*c]u8;
pub extern fn xcb_image_text_8_string_length(R: [*c]const xcb_image_text_8_request_t) c_int;
pub extern fn xcb_image_text_8_string_end(R: [*c]const xcb_image_text_8_request_t) xcb_generic_iterator_t;
pub extern fn xcb_image_text_16_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_image_text_16_checked(c: ?*xcb_connection_t, string_len: u8, drawable: xcb_drawable_t, gc: xcb_gcontext_t, x: i16, y: i16, string: [*c]const xcb_char2b_t) xcb_void_cookie_t;
pub extern fn xcb_image_text_16(c: ?*xcb_connection_t, string_len: u8, drawable: xcb_drawable_t, gc: xcb_gcontext_t, x: i16, y: i16, string: [*c]const xcb_char2b_t) xcb_void_cookie_t;
pub extern fn xcb_image_text_16_string(R: [*c]const xcb_image_text_16_request_t) [*c]xcb_char2b_t;
pub extern fn xcb_image_text_16_string_length(R: [*c]const xcb_image_text_16_request_t) c_int;
pub extern fn xcb_image_text_16_string_iterator(R: [*c]const xcb_image_text_16_request_t) xcb_char2b_iterator_t;
pub extern fn xcb_create_colormap_checked(c: ?*xcb_connection_t, alloc: u8, mid: xcb_colormap_t, window: xcb_window_t, visual: xcb_visualid_t) xcb_void_cookie_t;
pub extern fn xcb_create_colormap(c: ?*xcb_connection_t, alloc: u8, mid: xcb_colormap_t, window: xcb_window_t, visual: xcb_visualid_t) xcb_void_cookie_t;
pub extern fn xcb_free_colormap_checked(c: ?*xcb_connection_t, cmap: xcb_colormap_t) xcb_void_cookie_t;
pub extern fn xcb_free_colormap(c: ?*xcb_connection_t, cmap: xcb_colormap_t) xcb_void_cookie_t;
pub extern fn xcb_copy_colormap_and_free_checked(c: ?*xcb_connection_t, mid: xcb_colormap_t, src_cmap: xcb_colormap_t) xcb_void_cookie_t;
pub extern fn xcb_copy_colormap_and_free(c: ?*xcb_connection_t, mid: xcb_colormap_t, src_cmap: xcb_colormap_t) xcb_void_cookie_t;
pub extern fn xcb_install_colormap_checked(c: ?*xcb_connection_t, cmap: xcb_colormap_t) xcb_void_cookie_t;
pub extern fn xcb_install_colormap(c: ?*xcb_connection_t, cmap: xcb_colormap_t) xcb_void_cookie_t;
pub extern fn xcb_uninstall_colormap_checked(c: ?*xcb_connection_t, cmap: xcb_colormap_t) xcb_void_cookie_t;
pub extern fn xcb_uninstall_colormap(c: ?*xcb_connection_t, cmap: xcb_colormap_t) xcb_void_cookie_t;
pub extern fn xcb_list_installed_colormaps_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_list_installed_colormaps(c: ?*xcb_connection_t, window: xcb_window_t) xcb_list_installed_colormaps_cookie_t;
pub extern fn xcb_list_installed_colormaps_unchecked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_list_installed_colormaps_cookie_t;
pub extern fn xcb_list_installed_colormaps_cmaps(R: [*c]const xcb_list_installed_colormaps_reply_t) [*c]xcb_colormap_t;
pub extern fn xcb_list_installed_colormaps_cmaps_length(R: [*c]const xcb_list_installed_colormaps_reply_t) c_int;
pub extern fn xcb_list_installed_colormaps_cmaps_end(R: [*c]const xcb_list_installed_colormaps_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_list_installed_colormaps_reply(c: ?*xcb_connection_t, cookie: xcb_list_installed_colormaps_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_list_installed_colormaps_reply_t;
pub extern fn xcb_alloc_color(c: ?*xcb_connection_t, cmap: xcb_colormap_t, red: u16, green: u16, blue: u16) xcb_alloc_color_cookie_t;
pub extern fn xcb_alloc_color_unchecked(c: ?*xcb_connection_t, cmap: xcb_colormap_t, red: u16, green: u16, blue: u16) xcb_alloc_color_cookie_t;
pub extern fn xcb_alloc_color_reply(c: ?*xcb_connection_t, cookie: xcb_alloc_color_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_alloc_color_reply_t;
pub extern fn xcb_alloc_named_color_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_alloc_named_color(c: ?*xcb_connection_t, cmap: xcb_colormap_t, name_len: u16, name: [*c]const u8) xcb_alloc_named_color_cookie_t;
pub extern fn xcb_alloc_named_color_unchecked(c: ?*xcb_connection_t, cmap: xcb_colormap_t, name_len: u16, name: [*c]const u8) xcb_alloc_named_color_cookie_t;
pub extern fn xcb_alloc_named_color_reply(c: ?*xcb_connection_t, cookie: xcb_alloc_named_color_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_alloc_named_color_reply_t;
pub extern fn xcb_alloc_color_cells_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_alloc_color_cells(c: ?*xcb_connection_t, contiguous: u8, cmap: xcb_colormap_t, colors: u16, planes: u16) xcb_alloc_color_cells_cookie_t;
pub extern fn xcb_alloc_color_cells_unchecked(c: ?*xcb_connection_t, contiguous: u8, cmap: xcb_colormap_t, colors: u16, planes: u16) xcb_alloc_color_cells_cookie_t;
pub extern fn xcb_alloc_color_cells_pixels(R: [*c]const xcb_alloc_color_cells_reply_t) [*c]u32;
pub extern fn xcb_alloc_color_cells_pixels_length(R: [*c]const xcb_alloc_color_cells_reply_t) c_int;
pub extern fn xcb_alloc_color_cells_pixels_end(R: [*c]const xcb_alloc_color_cells_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_alloc_color_cells_masks(R: [*c]const xcb_alloc_color_cells_reply_t) [*c]u32;
pub extern fn xcb_alloc_color_cells_masks_length(R: [*c]const xcb_alloc_color_cells_reply_t) c_int;
pub extern fn xcb_alloc_color_cells_masks_end(R: [*c]const xcb_alloc_color_cells_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_alloc_color_cells_reply(c: ?*xcb_connection_t, cookie: xcb_alloc_color_cells_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_alloc_color_cells_reply_t;
pub extern fn xcb_alloc_color_planes_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_alloc_color_planes(c: ?*xcb_connection_t, contiguous: u8, cmap: xcb_colormap_t, colors: u16, reds: u16, greens: u16, blues: u16) xcb_alloc_color_planes_cookie_t;
pub extern fn xcb_alloc_color_planes_unchecked(c: ?*xcb_connection_t, contiguous: u8, cmap: xcb_colormap_t, colors: u16, reds: u16, greens: u16, blues: u16) xcb_alloc_color_planes_cookie_t;
pub extern fn xcb_alloc_color_planes_pixels(R: [*c]const xcb_alloc_color_planes_reply_t) [*c]u32;
pub extern fn xcb_alloc_color_planes_pixels_length(R: [*c]const xcb_alloc_color_planes_reply_t) c_int;
pub extern fn xcb_alloc_color_planes_pixels_end(R: [*c]const xcb_alloc_color_planes_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_alloc_color_planes_reply(c: ?*xcb_connection_t, cookie: xcb_alloc_color_planes_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_alloc_color_planes_reply_t;
pub extern fn xcb_free_colors_sizeof(_buffer: ?*const anyopaque, pixels_len: u32) c_int;
pub extern fn xcb_free_colors_checked(c: ?*xcb_connection_t, cmap: xcb_colormap_t, plane_mask: u32, pixels_len: u32, pixels: [*c]const u32) xcb_void_cookie_t;
pub extern fn xcb_free_colors(c: ?*xcb_connection_t, cmap: xcb_colormap_t, plane_mask: u32, pixels_len: u32, pixels: [*c]const u32) xcb_void_cookie_t;
pub extern fn xcb_free_colors_pixels(R: [*c]const xcb_free_colors_request_t) [*c]u32;
pub extern fn xcb_free_colors_pixels_length(R: [*c]const xcb_free_colors_request_t) c_int;
pub extern fn xcb_free_colors_pixels_end(R: [*c]const xcb_free_colors_request_t) xcb_generic_iterator_t;
pub extern fn xcb_coloritem_next(i: [*c]xcb_coloritem_iterator_t) void;
pub extern fn xcb_coloritem_end(i: xcb_coloritem_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_store_colors_sizeof(_buffer: ?*const anyopaque, items_len: u32) c_int;
pub extern fn xcb_store_colors_checked(c: ?*xcb_connection_t, cmap: xcb_colormap_t, items_len: u32, items: [*c]const xcb_coloritem_t) xcb_void_cookie_t;
pub extern fn xcb_store_colors(c: ?*xcb_connection_t, cmap: xcb_colormap_t, items_len: u32, items: [*c]const xcb_coloritem_t) xcb_void_cookie_t;
pub extern fn xcb_store_colors_items(R: [*c]const xcb_store_colors_request_t) [*c]xcb_coloritem_t;
pub extern fn xcb_store_colors_items_length(R: [*c]const xcb_store_colors_request_t) c_int;
pub extern fn xcb_store_colors_items_iterator(R: [*c]const xcb_store_colors_request_t) xcb_coloritem_iterator_t;
pub extern fn xcb_store_named_color_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_store_named_color_checked(c: ?*xcb_connection_t, flags: u8, cmap: xcb_colormap_t, pixel: u32, name_len: u16, name: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_store_named_color(c: ?*xcb_connection_t, flags: u8, cmap: xcb_colormap_t, pixel: u32, name_len: u16, name: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_store_named_color_name(R: [*c]const xcb_store_named_color_request_t) [*c]u8;
pub extern fn xcb_store_named_color_name_length(R: [*c]const xcb_store_named_color_request_t) c_int;
pub extern fn xcb_store_named_color_name_end(R: [*c]const xcb_store_named_color_request_t) xcb_generic_iterator_t;
pub extern fn xcb_rgb_next(i: [*c]xcb_rgb_iterator_t) void;
pub extern fn xcb_rgb_end(i: xcb_rgb_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_query_colors_sizeof(_buffer: ?*const anyopaque, pixels_len: u32) c_int;
pub extern fn xcb_query_colors(c: ?*xcb_connection_t, cmap: xcb_colormap_t, pixels_len: u32, pixels: [*c]const u32) xcb_query_colors_cookie_t;
pub extern fn xcb_query_colors_unchecked(c: ?*xcb_connection_t, cmap: xcb_colormap_t, pixels_len: u32, pixels: [*c]const u32) xcb_query_colors_cookie_t;
pub extern fn xcb_query_colors_colors(R: [*c]const xcb_query_colors_reply_t) [*c]xcb_rgb_t;
pub extern fn xcb_query_colors_colors_length(R: [*c]const xcb_query_colors_reply_t) c_int;
pub extern fn xcb_query_colors_colors_iterator(R: [*c]const xcb_query_colors_reply_t) xcb_rgb_iterator_t;
pub extern fn xcb_query_colors_reply(c: ?*xcb_connection_t, cookie: xcb_query_colors_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_query_colors_reply_t;
pub extern fn xcb_lookup_color_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_lookup_color(c: ?*xcb_connection_t, cmap: xcb_colormap_t, name_len: u16, name: [*c]const u8) xcb_lookup_color_cookie_t;
pub extern fn xcb_lookup_color_unchecked(c: ?*xcb_connection_t, cmap: xcb_colormap_t, name_len: u16, name: [*c]const u8) xcb_lookup_color_cookie_t;
pub extern fn xcb_lookup_color_reply(c: ?*xcb_connection_t, cookie: xcb_lookup_color_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_lookup_color_reply_t;
pub extern fn xcb_create_cursor_checked(c: ?*xcb_connection_t, cid: xcb_cursor_t, source: xcb_pixmap_t, mask: xcb_pixmap_t, fore_red: u16, fore_green: u16, fore_blue: u16, back_red: u16, back_green: u16, back_blue: u16, x: u16, y: u16) xcb_void_cookie_t;
pub extern fn xcb_create_cursor(c: ?*xcb_connection_t, cid: xcb_cursor_t, source: xcb_pixmap_t, mask: xcb_pixmap_t, fore_red: u16, fore_green: u16, fore_blue: u16, back_red: u16, back_green: u16, back_blue: u16, x: u16, y: u16) xcb_void_cookie_t;
pub extern fn xcb_create_glyph_cursor_checked(c: ?*xcb_connection_t, cid: xcb_cursor_t, source_font: xcb_font_t, mask_font: xcb_font_t, source_char: u16, mask_char: u16, fore_red: u16, fore_green: u16, fore_blue: u16, back_red: u16, back_green: u16, back_blue: u16) xcb_void_cookie_t;
pub extern fn xcb_create_glyph_cursor(c: ?*xcb_connection_t, cid: xcb_cursor_t, source_font: xcb_font_t, mask_font: xcb_font_t, source_char: u16, mask_char: u16, fore_red: u16, fore_green: u16, fore_blue: u16, back_red: u16, back_green: u16, back_blue: u16) xcb_void_cookie_t;
pub extern fn xcb_free_cursor_checked(c: ?*xcb_connection_t, cursor: xcb_cursor_t) xcb_void_cookie_t;
pub extern fn xcb_free_cursor(c: ?*xcb_connection_t, cursor: xcb_cursor_t) xcb_void_cookie_t;
pub extern fn xcb_recolor_cursor_checked(c: ?*xcb_connection_t, cursor: xcb_cursor_t, fore_red: u16, fore_green: u16, fore_blue: u16, back_red: u16, back_green: u16, back_blue: u16) xcb_void_cookie_t;
pub extern fn xcb_recolor_cursor(c: ?*xcb_connection_t, cursor: xcb_cursor_t, fore_red: u16, fore_green: u16, fore_blue: u16, back_red: u16, back_green: u16, back_blue: u16) xcb_void_cookie_t;
pub extern fn xcb_query_best_size(c: ?*xcb_connection_t, _class: u8, drawable: xcb_drawable_t, width: u16, height: u16) xcb_query_best_size_cookie_t;
pub extern fn xcb_query_best_size_unchecked(c: ?*xcb_connection_t, _class: u8, drawable: xcb_drawable_t, width: u16, height: u16) xcb_query_best_size_cookie_t;
pub extern fn xcb_query_best_size_reply(c: ?*xcb_connection_t, cookie: xcb_query_best_size_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_query_best_size_reply_t;
pub extern fn xcb_query_extension_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_query_extension(c: ?*xcb_connection_t, name_len: u16, name: [*c]const u8) xcb_query_extension_cookie_t;
pub extern fn xcb_query_extension_unchecked(c: ?*xcb_connection_t, name_len: u16, name: [*c]const u8) xcb_query_extension_cookie_t;
pub extern fn xcb_query_extension_reply(c: ?*xcb_connection_t, cookie: xcb_query_extension_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_query_extension_reply_t;
pub extern fn xcb_list_extensions_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_list_extensions(c: ?*xcb_connection_t) xcb_list_extensions_cookie_t;
pub extern fn xcb_list_extensions_unchecked(c: ?*xcb_connection_t) xcb_list_extensions_cookie_t;
pub extern fn xcb_list_extensions_names_length(R: [*c]const xcb_list_extensions_reply_t) c_int;
pub extern fn xcb_list_extensions_names_iterator(R: [*c]const xcb_list_extensions_reply_t) xcb_str_iterator_t;
pub extern fn xcb_list_extensions_reply(c: ?*xcb_connection_t, cookie: xcb_list_extensions_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_list_extensions_reply_t;
pub extern fn xcb_change_keyboard_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_change_keyboard_mapping_checked(c: ?*xcb_connection_t, keycode_count: u8, first_keycode: xcb_keycode_t, keysyms_per_keycode: u8, keysyms: [*c]const xcb_keysym_t) xcb_void_cookie_t;
pub extern fn xcb_change_keyboard_mapping(c: ?*xcb_connection_t, keycode_count: u8, first_keycode: xcb_keycode_t, keysyms_per_keycode: u8, keysyms: [*c]const xcb_keysym_t) xcb_void_cookie_t;
pub extern fn xcb_change_keyboard_mapping_keysyms(R: [*c]const xcb_change_keyboard_mapping_request_t) [*c]xcb_keysym_t;
pub extern fn xcb_change_keyboard_mapping_keysyms_length(R: [*c]const xcb_change_keyboard_mapping_request_t) c_int;
pub extern fn xcb_change_keyboard_mapping_keysyms_end(R: [*c]const xcb_change_keyboard_mapping_request_t) xcb_generic_iterator_t;
pub extern fn xcb_get_keyboard_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_get_keyboard_mapping(c: ?*xcb_connection_t, first_keycode: xcb_keycode_t, count: u8) xcb_get_keyboard_mapping_cookie_t;
pub extern fn xcb_get_keyboard_mapping_unchecked(c: ?*xcb_connection_t, first_keycode: xcb_keycode_t, count: u8) xcb_get_keyboard_mapping_cookie_t;
pub extern fn xcb_get_keyboard_mapping_keysyms(R: [*c]const xcb_get_keyboard_mapping_reply_t) [*c]xcb_keysym_t;
pub extern fn xcb_get_keyboard_mapping_keysyms_length(R: [*c]const xcb_get_keyboard_mapping_reply_t) c_int;
pub extern fn xcb_get_keyboard_mapping_keysyms_end(R: [*c]const xcb_get_keyboard_mapping_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_get_keyboard_mapping_reply(c: ?*xcb_connection_t, cookie: xcb_get_keyboard_mapping_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_keyboard_mapping_reply_t;
pub extern fn xcb_change_keyboard_control_value_list_serialize(_buffer: [*c]?*anyopaque, value_mask: u32, _aux: [*c]const xcb_change_keyboard_control_value_list_t) c_int;
pub extern fn xcb_change_keyboard_control_value_list_unpack(_buffer: ?*const anyopaque, value_mask: u32, _aux: [*c]xcb_change_keyboard_control_value_list_t) c_int;
pub extern fn xcb_change_keyboard_control_value_list_sizeof(_buffer: ?*const anyopaque, value_mask: u32) c_int;
pub extern fn xcb_change_keyboard_control_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_change_keyboard_control_checked(c: ?*xcb_connection_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_change_keyboard_control(c: ?*xcb_connection_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_change_keyboard_control_aux_checked(c: ?*xcb_connection_t, value_mask: u32, value_list: [*c]const xcb_change_keyboard_control_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_change_keyboard_control_aux(c: ?*xcb_connection_t, value_mask: u32, value_list: [*c]const xcb_change_keyboard_control_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_change_keyboard_control_value_list(R: [*c]const xcb_change_keyboard_control_request_t) ?*anyopaque;
pub extern fn xcb_get_keyboard_control(c: ?*xcb_connection_t) xcb_get_keyboard_control_cookie_t;
pub extern fn xcb_get_keyboard_control_unchecked(c: ?*xcb_connection_t) xcb_get_keyboard_control_cookie_t;
pub extern fn xcb_get_keyboard_control_reply(c: ?*xcb_connection_t, cookie: xcb_get_keyboard_control_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_keyboard_control_reply_t;
pub extern fn xcb_bell_checked(c: ?*xcb_connection_t, percent: i8) xcb_void_cookie_t;
pub extern fn xcb_bell(c: ?*xcb_connection_t, percent: i8) xcb_void_cookie_t;
pub extern fn xcb_change_pointer_control_checked(c: ?*xcb_connection_t, acceleration_numerator: i16, acceleration_denominator: i16, threshold: i16, do_acceleration: u8, do_threshold: u8) xcb_void_cookie_t;
pub extern fn xcb_change_pointer_control(c: ?*xcb_connection_t, acceleration_numerator: i16, acceleration_denominator: i16, threshold: i16, do_acceleration: u8, do_threshold: u8) xcb_void_cookie_t;
pub extern fn xcb_get_pointer_control(c: ?*xcb_connection_t) xcb_get_pointer_control_cookie_t;
pub extern fn xcb_get_pointer_control_unchecked(c: ?*xcb_connection_t) xcb_get_pointer_control_cookie_t;
pub extern fn xcb_get_pointer_control_reply(c: ?*xcb_connection_t, cookie: xcb_get_pointer_control_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_pointer_control_reply_t;
pub extern fn xcb_set_screen_saver_checked(c: ?*xcb_connection_t, timeout: i16, interval: i16, prefer_blanking: u8, allow_exposures: u8) xcb_void_cookie_t;
pub extern fn xcb_set_screen_saver(c: ?*xcb_connection_t, timeout: i16, interval: i16, prefer_blanking: u8, allow_exposures: u8) xcb_void_cookie_t;
pub extern fn xcb_get_screen_saver(c: ?*xcb_connection_t) xcb_get_screen_saver_cookie_t;
pub extern fn xcb_get_screen_saver_unchecked(c: ?*xcb_connection_t) xcb_get_screen_saver_cookie_t;
pub extern fn xcb_get_screen_saver_reply(c: ?*xcb_connection_t, cookie: xcb_get_screen_saver_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_screen_saver_reply_t;
pub extern fn xcb_change_hosts_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_change_hosts_checked(c: ?*xcb_connection_t, mode: u8, family: u8, address_len: u16, address: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_change_hosts(c: ?*xcb_connection_t, mode: u8, family: u8, address_len: u16, address: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_change_hosts_address(R: [*c]const xcb_change_hosts_request_t) [*c]u8;
pub extern fn xcb_change_hosts_address_length(R: [*c]const xcb_change_hosts_request_t) c_int;
pub extern fn xcb_change_hosts_address_end(R: [*c]const xcb_change_hosts_request_t) xcb_generic_iterator_t;
pub extern fn xcb_host_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_host_address(R: [*c]const xcb_host_t) [*c]u8;
pub extern fn xcb_host_address_length(R: [*c]const xcb_host_t) c_int;
pub extern fn xcb_host_address_end(R: [*c]const xcb_host_t) xcb_generic_iterator_t;
pub extern fn xcb_host_next(i: [*c]xcb_host_iterator_t) void;
pub extern fn xcb_host_end(i: xcb_host_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_list_hosts_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_list_hosts(c: ?*xcb_connection_t) xcb_list_hosts_cookie_t;
pub extern fn xcb_list_hosts_unchecked(c: ?*xcb_connection_t) xcb_list_hosts_cookie_t;
pub extern fn xcb_list_hosts_hosts_length(R: [*c]const xcb_list_hosts_reply_t) c_int;
pub extern fn xcb_list_hosts_hosts_iterator(R: [*c]const xcb_list_hosts_reply_t) xcb_host_iterator_t;
pub extern fn xcb_list_hosts_reply(c: ?*xcb_connection_t, cookie: xcb_list_hosts_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_list_hosts_reply_t;
pub extern fn xcb_set_access_control_checked(c: ?*xcb_connection_t, mode: u8) xcb_void_cookie_t;
pub extern fn xcb_set_access_control(c: ?*xcb_connection_t, mode: u8) xcb_void_cookie_t;
pub extern fn xcb_set_close_down_mode_checked(c: ?*xcb_connection_t, mode: u8) xcb_void_cookie_t;
pub extern fn xcb_set_close_down_mode(c: ?*xcb_connection_t, mode: u8) xcb_void_cookie_t;
pub extern fn xcb_kill_client_checked(c: ?*xcb_connection_t, resource: u32) xcb_void_cookie_t;
pub extern fn xcb_kill_client(c: ?*xcb_connection_t, resource: u32) xcb_void_cookie_t;
pub extern fn xcb_rotate_properties_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_rotate_properties_checked(c: ?*xcb_connection_t, window: xcb_window_t, atoms_len: u16, delta: i16, atoms: [*c]const xcb_atom_t) xcb_void_cookie_t;
pub extern fn xcb_rotate_properties(c: ?*xcb_connection_t, window: xcb_window_t, atoms_len: u16, delta: i16, atoms: [*c]const xcb_atom_t) xcb_void_cookie_t;
pub extern fn xcb_rotate_properties_atoms(R: [*c]const xcb_rotate_properties_request_t) [*c]xcb_atom_t;
pub extern fn xcb_rotate_properties_atoms_length(R: [*c]const xcb_rotate_properties_request_t) c_int;
pub extern fn xcb_rotate_properties_atoms_end(R: [*c]const xcb_rotate_properties_request_t) xcb_generic_iterator_t;
pub extern fn xcb_force_screen_saver_checked(c: ?*xcb_connection_t, mode: u8) xcb_void_cookie_t;
pub extern fn xcb_force_screen_saver(c: ?*xcb_connection_t, mode: u8) xcb_void_cookie_t;
pub extern fn xcb_set_pointer_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_set_pointer_mapping(c: ?*xcb_connection_t, map_len: u8, map: [*c]const u8) xcb_set_pointer_mapping_cookie_t;
pub extern fn xcb_set_pointer_mapping_unchecked(c: ?*xcb_connection_t, map_len: u8, map: [*c]const u8) xcb_set_pointer_mapping_cookie_t;
pub extern fn xcb_set_pointer_mapping_reply(c: ?*xcb_connection_t, cookie: xcb_set_pointer_mapping_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_set_pointer_mapping_reply_t;
pub extern fn xcb_get_pointer_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_get_pointer_mapping(c: ?*xcb_connection_t) xcb_get_pointer_mapping_cookie_t;
pub extern fn xcb_get_pointer_mapping_unchecked(c: ?*xcb_connection_t) xcb_get_pointer_mapping_cookie_t;
pub extern fn xcb_get_pointer_mapping_map(R: [*c]const xcb_get_pointer_mapping_reply_t) [*c]u8;
pub extern fn xcb_get_pointer_mapping_map_length(R: [*c]const xcb_get_pointer_mapping_reply_t) c_int;
pub extern fn xcb_get_pointer_mapping_map_end(R: [*c]const xcb_get_pointer_mapping_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_get_pointer_mapping_reply(c: ?*xcb_connection_t, cookie: xcb_get_pointer_mapping_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_pointer_mapping_reply_t;
pub extern fn xcb_set_modifier_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_set_modifier_mapping(c: ?*xcb_connection_t, keycodes_per_modifier: u8, keycodes: [*c]const xcb_keycode_t) xcb_set_modifier_mapping_cookie_t;
pub extern fn xcb_set_modifier_mapping_unchecked(c: ?*xcb_connection_t, keycodes_per_modifier: u8, keycodes: [*c]const xcb_keycode_t) xcb_set_modifier_mapping_cookie_t;
pub extern fn xcb_set_modifier_mapping_reply(c: ?*xcb_connection_t, cookie: xcb_set_modifier_mapping_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_set_modifier_mapping_reply_t;
pub extern fn xcb_get_modifier_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_get_modifier_mapping(c: ?*xcb_connection_t) xcb_get_modifier_mapping_cookie_t;
pub extern fn xcb_get_modifier_mapping_unchecked(c: ?*xcb_connection_t) xcb_get_modifier_mapping_cookie_t;
pub extern fn xcb_get_modifier_mapping_keycodes(R: [*c]const xcb_get_modifier_mapping_reply_t) [*c]xcb_keycode_t;
pub extern fn xcb_get_modifier_mapping_keycodes_length(R: [*c]const xcb_get_modifier_mapping_reply_t) c_int;
pub extern fn xcb_get_modifier_mapping_keycodes_end(R: [*c]const xcb_get_modifier_mapping_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_get_modifier_mapping_reply(c: ?*xcb_connection_t, cookie: xcb_get_modifier_mapping_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_get_modifier_mapping_reply_t;
pub extern fn xcb_no_operation_checked(c: ?*xcb_connection_t) xcb_void_cookie_t;
pub extern fn xcb_no_operation(c: ?*xcb_connection_t) xcb_void_cookie_t;
pub const struct_xcb_auth_info_t = extern struct {
    namelen: c_int = @import("std").mem.zeroes(c_int),
    name: [*c]u8 = @import("std").mem.zeroes([*c]u8),
    datalen: c_int = @import("std").mem.zeroes(c_int),
    data: [*c]u8 = @import("std").mem.zeroes([*c]u8),
};
pub const xcb_auth_info_t = struct_xcb_auth_info_t;
pub extern fn xcb_flush(c: ?*xcb_connection_t) c_int;
pub extern fn xcb_get_maximum_request_length(c: ?*xcb_connection_t) u32;
pub extern fn xcb_prefetch_maximum_request_length(c: ?*xcb_connection_t) void;
pub extern fn xcb_wait_for_event(c: ?*xcb_connection_t) [*c]xcb_generic_event_t;
pub extern fn xcb_poll_for_event(c: ?*xcb_connection_t) [*c]xcb_generic_event_t;
pub extern fn xcb_poll_for_queued_event(c: ?*xcb_connection_t) [*c]xcb_generic_event_t;
pub const struct_xcb_special_event = opaque {};
pub const xcb_special_event_t = struct_xcb_special_event;
pub extern fn xcb_poll_for_special_event(c: ?*xcb_connection_t, se: ?*xcb_special_event_t) [*c]xcb_generic_event_t;
pub extern fn xcb_wait_for_special_event(c: ?*xcb_connection_t, se: ?*xcb_special_event_t) [*c]xcb_generic_event_t;
pub const struct_xcb_extension_t = opaque {};
pub const xcb_extension_t = struct_xcb_extension_t;
pub extern fn xcb_register_for_special_xge(c: ?*xcb_connection_t, ext: ?*xcb_extension_t, eid: u32, stamp: [*c]u32) ?*xcb_special_event_t;
pub extern fn xcb_unregister_for_special_event(c: ?*xcb_connection_t, se: ?*xcb_special_event_t) void;
pub extern fn xcb_request_check(c: ?*xcb_connection_t, cookie: xcb_void_cookie_t) [*c]xcb_generic_error_t;
pub extern fn xcb_discard_reply(c: ?*xcb_connection_t, sequence: c_uint) void;
pub extern fn xcb_discard_reply64(c: ?*xcb_connection_t, sequence: u64) void;
pub extern fn xcb_get_extension_data(c: ?*xcb_connection_t, ext: ?*xcb_extension_t) [*c]const struct_xcb_query_extension_reply_t;
pub extern fn xcb_prefetch_extension_data(c: ?*xcb_connection_t, ext: ?*xcb_extension_t) void;
pub extern fn xcb_get_setup(c: ?*xcb_connection_t) [*c]const struct_xcb_setup_t;
pub extern fn xcb_get_file_descriptor(c: ?*xcb_connection_t) c_int;
pub extern fn xcb_connection_has_error(c: ?*xcb_connection_t) c_int;
pub extern fn xcb_connect_to_fd(fd: c_int, auth_info: [*c]xcb_auth_info_t) ?*xcb_connection_t;
pub extern fn xcb_disconnect(c: ?*xcb_connection_t) void;
pub extern fn xcb_parse_display(name: [*c]const u8, host: [*c][*c]u8, display: [*c]c_int, screen: [*c]c_int) c_int;
pub extern fn xcb_connect(displayname: [*c]const u8, screenp: [*c]c_int) ?*xcb_connection_t;
pub extern fn xcb_connect_to_display_with_auth_info(display: [*c]const u8, auth: [*c]xcb_auth_info_t, screen: [*c]c_int) ?*xcb_connection_t;
pub extern fn xcb_generate_id(c: ?*xcb_connection_t) u32;
pub extern fn xcb_total_read(c: ?*xcb_connection_t) u64;
pub extern fn xcb_total_written(c: ?*xcb_connection_t) u64;
pub extern var xcb_render_id: xcb_extension_t;
pub const XCB_RENDER_PICT_TYPE_INDEXED: c_int = 0;
pub const XCB_RENDER_PICT_TYPE_DIRECT: c_int = 1;
pub const enum_xcb_render_pict_type_t = c_uint;
pub const xcb_render_pict_type_t = enum_xcb_render_pict_type_t;
pub const XCB_RENDER_PICTURE_NONE: c_int = 0;
pub const enum_xcb_render_picture_enum_t = c_uint;
pub const xcb_render_picture_enum_t = enum_xcb_render_picture_enum_t;
pub const XCB_RENDER_PICT_OP_CLEAR: c_int = 0;
pub const XCB_RENDER_PICT_OP_SRC: c_int = 1;
pub const XCB_RENDER_PICT_OP_DST: c_int = 2;
pub const XCB_RENDER_PICT_OP_OVER: c_int = 3;
pub const XCB_RENDER_PICT_OP_OVER_REVERSE: c_int = 4;
pub const XCB_RENDER_PICT_OP_IN: c_int = 5;
pub const XCB_RENDER_PICT_OP_IN_REVERSE: c_int = 6;
pub const XCB_RENDER_PICT_OP_OUT: c_int = 7;
pub const XCB_RENDER_PICT_OP_OUT_REVERSE: c_int = 8;
pub const XCB_RENDER_PICT_OP_ATOP: c_int = 9;
pub const XCB_RENDER_PICT_OP_ATOP_REVERSE: c_int = 10;
pub const XCB_RENDER_PICT_OP_XOR: c_int = 11;
pub const XCB_RENDER_PICT_OP_ADD: c_int = 12;
pub const XCB_RENDER_PICT_OP_SATURATE: c_int = 13;
pub const XCB_RENDER_PICT_OP_DISJOINT_CLEAR: c_int = 16;
pub const XCB_RENDER_PICT_OP_DISJOINT_SRC: c_int = 17;
pub const XCB_RENDER_PICT_OP_DISJOINT_DST: c_int = 18;
pub const XCB_RENDER_PICT_OP_DISJOINT_OVER: c_int = 19;
pub const XCB_RENDER_PICT_OP_DISJOINT_OVER_REVERSE: c_int = 20;
pub const XCB_RENDER_PICT_OP_DISJOINT_IN: c_int = 21;
pub const XCB_RENDER_PICT_OP_DISJOINT_IN_REVERSE: c_int = 22;
pub const XCB_RENDER_PICT_OP_DISJOINT_OUT: c_int = 23;
pub const XCB_RENDER_PICT_OP_DISJOINT_OUT_REVERSE: c_int = 24;
pub const XCB_RENDER_PICT_OP_DISJOINT_ATOP: c_int = 25;
pub const XCB_RENDER_PICT_OP_DISJOINT_ATOP_REVERSE: c_int = 26;
pub const XCB_RENDER_PICT_OP_DISJOINT_XOR: c_int = 27;
pub const XCB_RENDER_PICT_OP_CONJOINT_CLEAR: c_int = 32;
pub const XCB_RENDER_PICT_OP_CONJOINT_SRC: c_int = 33;
pub const XCB_RENDER_PICT_OP_CONJOINT_DST: c_int = 34;
pub const XCB_RENDER_PICT_OP_CONJOINT_OVER: c_int = 35;
pub const XCB_RENDER_PICT_OP_CONJOINT_OVER_REVERSE: c_int = 36;
pub const XCB_RENDER_PICT_OP_CONJOINT_IN: c_int = 37;
pub const XCB_RENDER_PICT_OP_CONJOINT_IN_REVERSE: c_int = 38;
pub const XCB_RENDER_PICT_OP_CONJOINT_OUT: c_int = 39;
pub const XCB_RENDER_PICT_OP_CONJOINT_OUT_REVERSE: c_int = 40;
pub const XCB_RENDER_PICT_OP_CONJOINT_ATOP: c_int = 41;
pub const XCB_RENDER_PICT_OP_CONJOINT_ATOP_REVERSE: c_int = 42;
pub const XCB_RENDER_PICT_OP_CONJOINT_XOR: c_int = 43;
pub const XCB_RENDER_PICT_OP_MULTIPLY: c_int = 48;
pub const XCB_RENDER_PICT_OP_SCREEN: c_int = 49;
pub const XCB_RENDER_PICT_OP_OVERLAY: c_int = 50;
pub const XCB_RENDER_PICT_OP_DARKEN: c_int = 51;
pub const XCB_RENDER_PICT_OP_LIGHTEN: c_int = 52;
pub const XCB_RENDER_PICT_OP_COLOR_DODGE: c_int = 53;
pub const XCB_RENDER_PICT_OP_COLOR_BURN: c_int = 54;
pub const XCB_RENDER_PICT_OP_HARD_LIGHT: c_int = 55;
pub const XCB_RENDER_PICT_OP_SOFT_LIGHT: c_int = 56;
pub const XCB_RENDER_PICT_OP_DIFFERENCE: c_int = 57;
pub const XCB_RENDER_PICT_OP_EXCLUSION: c_int = 58;
pub const XCB_RENDER_PICT_OP_HSL_HUE: c_int = 59;
pub const XCB_RENDER_PICT_OP_HSL_SATURATION: c_int = 60;
pub const XCB_RENDER_PICT_OP_HSL_COLOR: c_int = 61;
pub const XCB_RENDER_PICT_OP_HSL_LUMINOSITY: c_int = 62;
pub const enum_xcb_render_pict_op_t = c_uint;
pub const xcb_render_pict_op_t = enum_xcb_render_pict_op_t;
pub const XCB_RENDER_POLY_EDGE_SHARP: c_int = 0;
pub const XCB_RENDER_POLY_EDGE_SMOOTH: c_int = 1;
pub const enum_xcb_render_poly_edge_t = c_uint;
pub const xcb_render_poly_edge_t = enum_xcb_render_poly_edge_t;
pub const XCB_RENDER_POLY_MODE_PRECISE: c_int = 0;
pub const XCB_RENDER_POLY_MODE_IMPRECISE: c_int = 1;
pub const enum_xcb_render_poly_mode_t = c_uint;
pub const xcb_render_poly_mode_t = enum_xcb_render_poly_mode_t;
pub const XCB_RENDER_CP_REPEAT: c_int = 1;
pub const XCB_RENDER_CP_ALPHA_MAP: c_int = 2;
pub const XCB_RENDER_CP_ALPHA_X_ORIGIN: c_int = 4;
pub const XCB_RENDER_CP_ALPHA_Y_ORIGIN: c_int = 8;
pub const XCB_RENDER_CP_CLIP_X_ORIGIN: c_int = 16;
pub const XCB_RENDER_CP_CLIP_Y_ORIGIN: c_int = 32;
pub const XCB_RENDER_CP_CLIP_MASK: c_int = 64;
pub const XCB_RENDER_CP_GRAPHICS_EXPOSURE: c_int = 128;
pub const XCB_RENDER_CP_SUBWINDOW_MODE: c_int = 256;
pub const XCB_RENDER_CP_POLY_EDGE: c_int = 512;
pub const XCB_RENDER_CP_POLY_MODE: c_int = 1024;
pub const XCB_RENDER_CP_DITHER: c_int = 2048;
pub const XCB_RENDER_CP_COMPONENT_ALPHA: c_int = 4096;
pub const enum_xcb_render_cp_t = c_uint;
pub const xcb_render_cp_t = enum_xcb_render_cp_t;
pub const XCB_RENDER_SUB_PIXEL_UNKNOWN: c_int = 0;
pub const XCB_RENDER_SUB_PIXEL_HORIZONTAL_RGB: c_int = 1;
pub const XCB_RENDER_SUB_PIXEL_HORIZONTAL_BGR: c_int = 2;
pub const XCB_RENDER_SUB_PIXEL_VERTICAL_RGB: c_int = 3;
pub const XCB_RENDER_SUB_PIXEL_VERTICAL_BGR: c_int = 4;
pub const XCB_RENDER_SUB_PIXEL_NONE: c_int = 5;
pub const enum_xcb_render_sub_pixel_t = c_uint;
pub const xcb_render_sub_pixel_t = enum_xcb_render_sub_pixel_t;
pub const XCB_RENDER_REPEAT_NONE: c_int = 0;
pub const XCB_RENDER_REPEAT_NORMAL: c_int = 1;
pub const XCB_RENDER_REPEAT_PAD: c_int = 2;
pub const XCB_RENDER_REPEAT_REFLECT: c_int = 3;
pub const enum_xcb_render_repeat_t = c_uint;
pub const xcb_render_repeat_t = enum_xcb_render_repeat_t;
pub const xcb_render_glyph_t = u32;
pub const struct_xcb_render_glyph_iterator_t = extern struct {
    data: [*c]xcb_render_glyph_t = @import("std").mem.zeroes([*c]xcb_render_glyph_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_glyph_iterator_t = struct_xcb_render_glyph_iterator_t;
pub const xcb_render_glyphset_t = u32;
pub const struct_xcb_render_glyphset_iterator_t = extern struct {
    data: [*c]xcb_render_glyphset_t = @import("std").mem.zeroes([*c]xcb_render_glyphset_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_glyphset_iterator_t = struct_xcb_render_glyphset_iterator_t;
pub const xcb_render_picture_t = u32;
pub const struct_xcb_render_picture_iterator_t = extern struct {
    data: [*c]xcb_render_picture_t = @import("std").mem.zeroes([*c]xcb_render_picture_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_picture_iterator_t = struct_xcb_render_picture_iterator_t;
pub const xcb_render_pictformat_t = u32;
pub const struct_xcb_render_pictformat_iterator_t = extern struct {
    data: [*c]xcb_render_pictformat_t = @import("std").mem.zeroes([*c]xcb_render_pictformat_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_pictformat_iterator_t = struct_xcb_render_pictformat_iterator_t;
pub const xcb_render_fixed_t = i32;
pub const struct_xcb_render_fixed_iterator_t = extern struct {
    data: [*c]xcb_render_fixed_t = @import("std").mem.zeroes([*c]xcb_render_fixed_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_fixed_iterator_t = struct_xcb_render_fixed_iterator_t;
pub const struct_xcb_render_pict_format_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_render_pict_format_error_t = struct_xcb_render_pict_format_error_t;
pub const struct_xcb_render_picture_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_render_picture_error_t = struct_xcb_render_picture_error_t;
pub const struct_xcb_render_pict_op_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_render_pict_op_error_t = struct_xcb_render_pict_op_error_t;
pub const struct_xcb_render_glyph_set_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_render_glyph_set_error_t = struct_xcb_render_glyph_set_error_t;
pub const struct_xcb_render_glyph_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_render_glyph_error_t = struct_xcb_render_glyph_error_t;
pub const struct_xcb_render_directformat_t = extern struct {
    red_shift: u16 = @import("std").mem.zeroes(u16),
    red_mask: u16 = @import("std").mem.zeroes(u16),
    green_shift: u16 = @import("std").mem.zeroes(u16),
    green_mask: u16 = @import("std").mem.zeroes(u16),
    blue_shift: u16 = @import("std").mem.zeroes(u16),
    blue_mask: u16 = @import("std").mem.zeroes(u16),
    alpha_shift: u16 = @import("std").mem.zeroes(u16),
    alpha_mask: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_render_directformat_t = struct_xcb_render_directformat_t;
pub const struct_xcb_render_directformat_iterator_t = extern struct {
    data: [*c]xcb_render_directformat_t = @import("std").mem.zeroes([*c]xcb_render_directformat_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_directformat_iterator_t = struct_xcb_render_directformat_iterator_t;
pub const struct_xcb_render_pictforminfo_t = extern struct {
    id: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
    type: u8 = @import("std").mem.zeroes(u8),
    depth: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    direct: xcb_render_directformat_t = @import("std").mem.zeroes(xcb_render_directformat_t),
    colormap: xcb_colormap_t = @import("std").mem.zeroes(xcb_colormap_t),
};
pub const xcb_render_pictforminfo_t = struct_xcb_render_pictforminfo_t;
pub const struct_xcb_render_pictforminfo_iterator_t = extern struct {
    data: [*c]xcb_render_pictforminfo_t = @import("std").mem.zeroes([*c]xcb_render_pictforminfo_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_pictforminfo_iterator_t = struct_xcb_render_pictforminfo_iterator_t;
pub const struct_xcb_render_pictvisual_t = extern struct {
    visual: xcb_visualid_t = @import("std").mem.zeroes(xcb_visualid_t),
    format: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
};
pub const xcb_render_pictvisual_t = struct_xcb_render_pictvisual_t;
pub const struct_xcb_render_pictvisual_iterator_t = extern struct {
    data: [*c]xcb_render_pictvisual_t = @import("std").mem.zeroes([*c]xcb_render_pictvisual_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_pictvisual_iterator_t = struct_xcb_render_pictvisual_iterator_t;
pub const struct_xcb_render_pictdepth_t = extern struct {
    depth: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    num_visuals: u16 = @import("std").mem.zeroes(u16),
    pad1: [4]u8 = @import("std").mem.zeroes([4]u8),
};
pub const xcb_render_pictdepth_t = struct_xcb_render_pictdepth_t;
pub const struct_xcb_render_pictdepth_iterator_t = extern struct {
    data: [*c]xcb_render_pictdepth_t = @import("std").mem.zeroes([*c]xcb_render_pictdepth_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_pictdepth_iterator_t = struct_xcb_render_pictdepth_iterator_t;
pub const struct_xcb_render_pictscreen_t = extern struct {
    num_depths: u32 = @import("std").mem.zeroes(u32),
    fallback: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
};
pub const xcb_render_pictscreen_t = struct_xcb_render_pictscreen_t;
pub const struct_xcb_render_pictscreen_iterator_t = extern struct {
    data: [*c]xcb_render_pictscreen_t = @import("std").mem.zeroes([*c]xcb_render_pictscreen_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_pictscreen_iterator_t = struct_xcb_render_pictscreen_iterator_t;
pub const struct_xcb_render_indexvalue_t = extern struct {
    pixel: u32 = @import("std").mem.zeroes(u32),
    red: u16 = @import("std").mem.zeroes(u16),
    green: u16 = @import("std").mem.zeroes(u16),
    blue: u16 = @import("std").mem.zeroes(u16),
    alpha: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_render_indexvalue_t = struct_xcb_render_indexvalue_t;
pub const struct_xcb_render_indexvalue_iterator_t = extern struct {
    data: [*c]xcb_render_indexvalue_t = @import("std").mem.zeroes([*c]xcb_render_indexvalue_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_indexvalue_iterator_t = struct_xcb_render_indexvalue_iterator_t;
pub const struct_xcb_render_color_t = extern struct {
    red: u16 = @import("std").mem.zeroes(u16),
    green: u16 = @import("std").mem.zeroes(u16),
    blue: u16 = @import("std").mem.zeroes(u16),
    alpha: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_render_color_t = struct_xcb_render_color_t;
pub const struct_xcb_render_color_iterator_t = extern struct {
    data: [*c]xcb_render_color_t = @import("std").mem.zeroes([*c]xcb_render_color_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_color_iterator_t = struct_xcb_render_color_iterator_t;
pub const struct_xcb_render_pointfix_t = extern struct {
    x: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    y: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
};
pub const xcb_render_pointfix_t = struct_xcb_render_pointfix_t;
pub const struct_xcb_render_pointfix_iterator_t = extern struct {
    data: [*c]xcb_render_pointfix_t = @import("std").mem.zeroes([*c]xcb_render_pointfix_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_pointfix_iterator_t = struct_xcb_render_pointfix_iterator_t;
pub const struct_xcb_render_linefix_t = extern struct {
    p1: xcb_render_pointfix_t = @import("std").mem.zeroes(xcb_render_pointfix_t),
    p2: xcb_render_pointfix_t = @import("std").mem.zeroes(xcb_render_pointfix_t),
};
pub const xcb_render_linefix_t = struct_xcb_render_linefix_t;
pub const struct_xcb_render_linefix_iterator_t = extern struct {
    data: [*c]xcb_render_linefix_t = @import("std").mem.zeroes([*c]xcb_render_linefix_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_linefix_iterator_t = struct_xcb_render_linefix_iterator_t;
pub const struct_xcb_render_triangle_t = extern struct {
    p1: xcb_render_pointfix_t = @import("std").mem.zeroes(xcb_render_pointfix_t),
    p2: xcb_render_pointfix_t = @import("std").mem.zeroes(xcb_render_pointfix_t),
    p3: xcb_render_pointfix_t = @import("std").mem.zeroes(xcb_render_pointfix_t),
};
pub const xcb_render_triangle_t = struct_xcb_render_triangle_t;
pub const struct_xcb_render_triangle_iterator_t = extern struct {
    data: [*c]xcb_render_triangle_t = @import("std").mem.zeroes([*c]xcb_render_triangle_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_triangle_iterator_t = struct_xcb_render_triangle_iterator_t;
pub const struct_xcb_render_trapezoid_t = extern struct {
    top: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    bottom: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    left: xcb_render_linefix_t = @import("std").mem.zeroes(xcb_render_linefix_t),
    right: xcb_render_linefix_t = @import("std").mem.zeroes(xcb_render_linefix_t),
};
pub const xcb_render_trapezoid_t = struct_xcb_render_trapezoid_t;
pub const struct_xcb_render_trapezoid_iterator_t = extern struct {
    data: [*c]xcb_render_trapezoid_t = @import("std").mem.zeroes([*c]xcb_render_trapezoid_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_trapezoid_iterator_t = struct_xcb_render_trapezoid_iterator_t;
pub const struct_xcb_render_glyphinfo_t = extern struct {
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    x_off: i16 = @import("std").mem.zeroes(i16),
    y_off: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_render_glyphinfo_t = struct_xcb_render_glyphinfo_t;
pub const struct_xcb_render_glyphinfo_iterator_t = extern struct {
    data: [*c]xcb_render_glyphinfo_t = @import("std").mem.zeroes([*c]xcb_render_glyphinfo_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_glyphinfo_iterator_t = struct_xcb_render_glyphinfo_iterator_t;
pub const struct_xcb_render_query_version_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_render_query_version_cookie_t = struct_xcb_render_query_version_cookie_t;
pub const struct_xcb_render_query_version_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    client_major_version: u32 = @import("std").mem.zeroes(u32),
    client_minor_version: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_render_query_version_request_t = struct_xcb_render_query_version_request_t;
pub const struct_xcb_render_query_version_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    major_version: u32 = @import("std").mem.zeroes(u32),
    minor_version: u32 = @import("std").mem.zeroes(u32),
    pad1: [16]u8 = @import("std").mem.zeroes([16]u8),
};
pub const xcb_render_query_version_reply_t = struct_xcb_render_query_version_reply_t;
pub const struct_xcb_render_query_pict_formats_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_render_query_pict_formats_cookie_t = struct_xcb_render_query_pict_formats_cookie_t;
pub const struct_xcb_render_query_pict_formats_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_render_query_pict_formats_request_t = struct_xcb_render_query_pict_formats_request_t;
pub const struct_xcb_render_query_pict_formats_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_formats: u32 = @import("std").mem.zeroes(u32),
    num_screens: u32 = @import("std").mem.zeroes(u32),
    num_depths: u32 = @import("std").mem.zeroes(u32),
    num_visuals: u32 = @import("std").mem.zeroes(u32),
    num_subpixel: u32 = @import("std").mem.zeroes(u32),
    pad1: [4]u8 = @import("std").mem.zeroes([4]u8),
};
pub const xcb_render_query_pict_formats_reply_t = struct_xcb_render_query_pict_formats_reply_t;
pub const struct_xcb_render_query_pict_index_values_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_render_query_pict_index_values_cookie_t = struct_xcb_render_query_pict_index_values_cookie_t;
pub const struct_xcb_render_query_pict_index_values_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    format: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
};
pub const xcb_render_query_pict_index_values_request_t = struct_xcb_render_query_pict_index_values_request_t;
pub const struct_xcb_render_query_pict_index_values_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_values: u32 = @import("std").mem.zeroes(u32),
    pad1: [20]u8 = @import("std").mem.zeroes([20]u8),
};
pub const xcb_render_query_pict_index_values_reply_t = struct_xcb_render_query_pict_index_values_reply_t;
pub const struct_xcb_render_create_picture_value_list_t = extern struct {
    repeat: u32 = @import("std").mem.zeroes(u32),
    alphamap: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    alphaxorigin: i32 = @import("std").mem.zeroes(i32),
    alphayorigin: i32 = @import("std").mem.zeroes(i32),
    clipxorigin: i32 = @import("std").mem.zeroes(i32),
    clipyorigin: i32 = @import("std").mem.zeroes(i32),
    clipmask: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    graphicsexposure: u32 = @import("std").mem.zeroes(u32),
    subwindowmode: u32 = @import("std").mem.zeroes(u32),
    polyedge: u32 = @import("std").mem.zeroes(u32),
    polymode: u32 = @import("std").mem.zeroes(u32),
    dither: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    componentalpha: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_render_create_picture_value_list_t = struct_xcb_render_create_picture_value_list_t;
pub const struct_xcb_render_create_picture_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    pid: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
    format: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
    value_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_render_create_picture_request_t = struct_xcb_render_create_picture_request_t;
pub const struct_xcb_render_change_picture_value_list_t = extern struct {
    repeat: u32 = @import("std").mem.zeroes(u32),
    alphamap: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    alphaxorigin: i32 = @import("std").mem.zeroes(i32),
    alphayorigin: i32 = @import("std").mem.zeroes(i32),
    clipxorigin: i32 = @import("std").mem.zeroes(i32),
    clipyorigin: i32 = @import("std").mem.zeroes(i32),
    clipmask: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
    graphicsexposure: u32 = @import("std").mem.zeroes(u32),
    subwindowmode: u32 = @import("std").mem.zeroes(u32),
    polyedge: u32 = @import("std").mem.zeroes(u32),
    polymode: u32 = @import("std").mem.zeroes(u32),
    dither: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    componentalpha: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_render_change_picture_value_list_t = struct_xcb_render_change_picture_value_list_t;
pub const struct_xcb_render_change_picture_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    value_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_render_change_picture_request_t = struct_xcb_render_change_picture_request_t;
pub const struct_xcb_render_set_picture_clip_rectangles_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    clip_x_origin: i16 = @import("std").mem.zeroes(i16),
    clip_y_origin: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_render_set_picture_clip_rectangles_request_t = struct_xcb_render_set_picture_clip_rectangles_request_t;
pub const struct_xcb_render_free_picture_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
};
pub const xcb_render_free_picture_request_t = struct_xcb_render_free_picture_request_t;
pub const struct_xcb_render_composite_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    op: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    src: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    mask: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    dst: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
    mask_x: i16 = @import("std").mem.zeroes(i16),
    mask_y: i16 = @import("std").mem.zeroes(i16),
    dst_x: i16 = @import("std").mem.zeroes(i16),
    dst_y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_render_composite_request_t = struct_xcb_render_composite_request_t;
pub const struct_xcb_render_trapezoids_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    op: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    src: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    dst: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    mask_format: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_render_trapezoids_request_t = struct_xcb_render_trapezoids_request_t;
pub const struct_xcb_render_triangles_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    op: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    src: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    dst: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    mask_format: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_render_triangles_request_t = struct_xcb_render_triangles_request_t;
pub const struct_xcb_render_tri_strip_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    op: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    src: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    dst: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    mask_format: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_render_tri_strip_request_t = struct_xcb_render_tri_strip_request_t;
pub const struct_xcb_render_tri_fan_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    op: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    src: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    dst: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    mask_format: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_render_tri_fan_request_t = struct_xcb_render_tri_fan_request_t;
pub const struct_xcb_render_create_glyph_set_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    gsid: xcb_render_glyphset_t = @import("std").mem.zeroes(xcb_render_glyphset_t),
    format: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
};
pub const xcb_render_create_glyph_set_request_t = struct_xcb_render_create_glyph_set_request_t;
pub const struct_xcb_render_reference_glyph_set_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    gsid: xcb_render_glyphset_t = @import("std").mem.zeroes(xcb_render_glyphset_t),
    existing: xcb_render_glyphset_t = @import("std").mem.zeroes(xcb_render_glyphset_t),
};
pub const xcb_render_reference_glyph_set_request_t = struct_xcb_render_reference_glyph_set_request_t;
pub const struct_xcb_render_free_glyph_set_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    glyphset: xcb_render_glyphset_t = @import("std").mem.zeroes(xcb_render_glyphset_t),
};
pub const xcb_render_free_glyph_set_request_t = struct_xcb_render_free_glyph_set_request_t;
pub const struct_xcb_render_add_glyphs_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    glyphset: xcb_render_glyphset_t = @import("std").mem.zeroes(xcb_render_glyphset_t),
    glyphs_len: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_render_add_glyphs_request_t = struct_xcb_render_add_glyphs_request_t;
pub const struct_xcb_render_free_glyphs_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    glyphset: xcb_render_glyphset_t = @import("std").mem.zeroes(xcb_render_glyphset_t),
};
pub const xcb_render_free_glyphs_request_t = struct_xcb_render_free_glyphs_request_t;
pub const struct_xcb_render_composite_glyphs_8_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    op: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    src: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    dst: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    mask_format: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
    glyphset: xcb_render_glyphset_t = @import("std").mem.zeroes(xcb_render_glyphset_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_render_composite_glyphs_8_request_t = struct_xcb_render_composite_glyphs_8_request_t;
pub const struct_xcb_render_composite_glyphs_16_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    op: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    src: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    dst: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    mask_format: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
    glyphset: xcb_render_glyphset_t = @import("std").mem.zeroes(xcb_render_glyphset_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_render_composite_glyphs_16_request_t = struct_xcb_render_composite_glyphs_16_request_t;
pub const struct_xcb_render_composite_glyphs_32_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    op: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    src: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    dst: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    mask_format: xcb_render_pictformat_t = @import("std").mem.zeroes(xcb_render_pictformat_t),
    glyphset: xcb_render_glyphset_t = @import("std").mem.zeroes(xcb_render_glyphset_t),
    src_x: i16 = @import("std").mem.zeroes(i16),
    src_y: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_render_composite_glyphs_32_request_t = struct_xcb_render_composite_glyphs_32_request_t;
pub const struct_xcb_render_fill_rectangles_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    op: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    dst: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    color: xcb_render_color_t = @import("std").mem.zeroes(xcb_render_color_t),
};
pub const xcb_render_fill_rectangles_request_t = struct_xcb_render_fill_rectangles_request_t;
pub const struct_xcb_render_create_cursor_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cid: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    source: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    x: u16 = @import("std").mem.zeroes(u16),
    y: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_render_create_cursor_request_t = struct_xcb_render_create_cursor_request_t;
pub const struct_xcb_render_transform_t = extern struct {
    matrix11: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    matrix12: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    matrix13: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    matrix21: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    matrix22: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    matrix23: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    matrix31: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    matrix32: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    matrix33: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
};
pub const xcb_render_transform_t = struct_xcb_render_transform_t;
pub const struct_xcb_render_transform_iterator_t = extern struct {
    data: [*c]xcb_render_transform_t = @import("std").mem.zeroes([*c]xcb_render_transform_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_transform_iterator_t = struct_xcb_render_transform_iterator_t;
pub const struct_xcb_render_set_picture_transform_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    transform: xcb_render_transform_t = @import("std").mem.zeroes(xcb_render_transform_t),
};
pub const xcb_render_set_picture_transform_request_t = struct_xcb_render_set_picture_transform_request_t;
pub const struct_xcb_render_query_filters_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_render_query_filters_cookie_t = struct_xcb_render_query_filters_cookie_t;
pub const struct_xcb_render_query_filters_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    drawable: xcb_drawable_t = @import("std").mem.zeroes(xcb_drawable_t),
};
pub const xcb_render_query_filters_request_t = struct_xcb_render_query_filters_request_t;
pub const struct_xcb_render_query_filters_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_aliases: u32 = @import("std").mem.zeroes(u32),
    num_filters: u32 = @import("std").mem.zeroes(u32),
    pad1: [16]u8 = @import("std").mem.zeroes([16]u8),
};
pub const xcb_render_query_filters_reply_t = struct_xcb_render_query_filters_reply_t;
pub const struct_xcb_render_set_picture_filter_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    filter_len: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_render_set_picture_filter_request_t = struct_xcb_render_set_picture_filter_request_t;
pub const struct_xcb_render_animcursorelt_t = extern struct {
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    delay: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_render_animcursorelt_t = struct_xcb_render_animcursorelt_t;
pub const struct_xcb_render_animcursorelt_iterator_t = extern struct {
    data: [*c]xcb_render_animcursorelt_t = @import("std").mem.zeroes([*c]xcb_render_animcursorelt_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_animcursorelt_iterator_t = struct_xcb_render_animcursorelt_iterator_t;
pub const struct_xcb_render_create_anim_cursor_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cid: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
};
pub const xcb_render_create_anim_cursor_request_t = struct_xcb_render_create_anim_cursor_request_t;
pub const struct_xcb_render_spanfix_t = extern struct {
    l: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    r: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    y: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
};
pub const xcb_render_spanfix_t = struct_xcb_render_spanfix_t;
pub const struct_xcb_render_spanfix_iterator_t = extern struct {
    data: [*c]xcb_render_spanfix_t = @import("std").mem.zeroes([*c]xcb_render_spanfix_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_spanfix_iterator_t = struct_xcb_render_spanfix_iterator_t;
pub const struct_xcb_render_trap_t = extern struct {
    top: xcb_render_spanfix_t = @import("std").mem.zeroes(xcb_render_spanfix_t),
    bot: xcb_render_spanfix_t = @import("std").mem.zeroes(xcb_render_spanfix_t),
};
pub const xcb_render_trap_t = struct_xcb_render_trap_t;
pub const struct_xcb_render_trap_iterator_t = extern struct {
    data: [*c]xcb_render_trap_t = @import("std").mem.zeroes([*c]xcb_render_trap_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_render_trap_iterator_t = struct_xcb_render_trap_iterator_t;
pub const struct_xcb_render_add_traps_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    x_off: i16 = @import("std").mem.zeroes(i16),
    y_off: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_render_add_traps_request_t = struct_xcb_render_add_traps_request_t;
pub const struct_xcb_render_create_solid_fill_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    color: xcb_render_color_t = @import("std").mem.zeroes(xcb_render_color_t),
};
pub const xcb_render_create_solid_fill_request_t = struct_xcb_render_create_solid_fill_request_t;
pub const struct_xcb_render_create_linear_gradient_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    p1: xcb_render_pointfix_t = @import("std").mem.zeroes(xcb_render_pointfix_t),
    p2: xcb_render_pointfix_t = @import("std").mem.zeroes(xcb_render_pointfix_t),
    num_stops: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_render_create_linear_gradient_request_t = struct_xcb_render_create_linear_gradient_request_t;
pub const struct_xcb_render_create_radial_gradient_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    inner: xcb_render_pointfix_t = @import("std").mem.zeroes(xcb_render_pointfix_t),
    outer: xcb_render_pointfix_t = @import("std").mem.zeroes(xcb_render_pointfix_t),
    inner_radius: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    outer_radius: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    num_stops: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_render_create_radial_gradient_request_t = struct_xcb_render_create_radial_gradient_request_t;
pub const struct_xcb_render_create_conical_gradient_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    center: xcb_render_pointfix_t = @import("std").mem.zeroes(xcb_render_pointfix_t),
    angle: xcb_render_fixed_t = @import("std").mem.zeroes(xcb_render_fixed_t),
    num_stops: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_render_create_conical_gradient_request_t = struct_xcb_render_create_conical_gradient_request_t;
pub extern fn xcb_render_glyph_next(i: [*c]xcb_render_glyph_iterator_t) void;
pub extern fn xcb_render_glyph_end(i: xcb_render_glyph_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_glyphset_next(i: [*c]xcb_render_glyphset_iterator_t) void;
pub extern fn xcb_render_glyphset_end(i: xcb_render_glyphset_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_picture_next(i: [*c]xcb_render_picture_iterator_t) void;
pub extern fn xcb_render_picture_end(i: xcb_render_picture_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_pictformat_next(i: [*c]xcb_render_pictformat_iterator_t) void;
pub extern fn xcb_render_pictformat_end(i: xcb_render_pictformat_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_fixed_next(i: [*c]xcb_render_fixed_iterator_t) void;
pub extern fn xcb_render_fixed_end(i: xcb_render_fixed_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_directformat_next(i: [*c]xcb_render_directformat_iterator_t) void;
pub extern fn xcb_render_directformat_end(i: xcb_render_directformat_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_pictforminfo_next(i: [*c]xcb_render_pictforminfo_iterator_t) void;
pub extern fn xcb_render_pictforminfo_end(i: xcb_render_pictforminfo_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_pictvisual_next(i: [*c]xcb_render_pictvisual_iterator_t) void;
pub extern fn xcb_render_pictvisual_end(i: xcb_render_pictvisual_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_pictdepth_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_render_pictdepth_visuals(R: [*c]const xcb_render_pictdepth_t) [*c]xcb_render_pictvisual_t;
pub extern fn xcb_render_pictdepth_visuals_length(R: [*c]const xcb_render_pictdepth_t) c_int;
pub extern fn xcb_render_pictdepth_visuals_iterator(R: [*c]const xcb_render_pictdepth_t) xcb_render_pictvisual_iterator_t;
pub extern fn xcb_render_pictdepth_next(i: [*c]xcb_render_pictdepth_iterator_t) void;
pub extern fn xcb_render_pictdepth_end(i: xcb_render_pictdepth_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_pictscreen_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_render_pictscreen_depths_length(R: [*c]const xcb_render_pictscreen_t) c_int;
pub extern fn xcb_render_pictscreen_depths_iterator(R: [*c]const xcb_render_pictscreen_t) xcb_render_pictdepth_iterator_t;
pub extern fn xcb_render_pictscreen_next(i: [*c]xcb_render_pictscreen_iterator_t) void;
pub extern fn xcb_render_pictscreen_end(i: xcb_render_pictscreen_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_indexvalue_next(i: [*c]xcb_render_indexvalue_iterator_t) void;
pub extern fn xcb_render_indexvalue_end(i: xcb_render_indexvalue_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_color_next(i: [*c]xcb_render_color_iterator_t) void;
pub extern fn xcb_render_color_end(i: xcb_render_color_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_pointfix_next(i: [*c]xcb_render_pointfix_iterator_t) void;
pub extern fn xcb_render_pointfix_end(i: xcb_render_pointfix_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_linefix_next(i: [*c]xcb_render_linefix_iterator_t) void;
pub extern fn xcb_render_linefix_end(i: xcb_render_linefix_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_triangle_next(i: [*c]xcb_render_triangle_iterator_t) void;
pub extern fn xcb_render_triangle_end(i: xcb_render_triangle_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_trapezoid_next(i: [*c]xcb_render_trapezoid_iterator_t) void;
pub extern fn xcb_render_trapezoid_end(i: xcb_render_trapezoid_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_glyphinfo_next(i: [*c]xcb_render_glyphinfo_iterator_t) void;
pub extern fn xcb_render_glyphinfo_end(i: xcb_render_glyphinfo_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_query_version(c: ?*xcb_connection_t, client_major_version: u32, client_minor_version: u32) xcb_render_query_version_cookie_t;
pub extern fn xcb_render_query_version_unchecked(c: ?*xcb_connection_t, client_major_version: u32, client_minor_version: u32) xcb_render_query_version_cookie_t;
pub extern fn xcb_render_query_version_reply(c: ?*xcb_connection_t, cookie: xcb_render_query_version_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_render_query_version_reply_t;
pub extern fn xcb_render_query_pict_formats_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_render_query_pict_formats(c: ?*xcb_connection_t) xcb_render_query_pict_formats_cookie_t;
pub extern fn xcb_render_query_pict_formats_unchecked(c: ?*xcb_connection_t) xcb_render_query_pict_formats_cookie_t;
pub extern fn xcb_render_query_pict_formats_formats(R: [*c]const xcb_render_query_pict_formats_reply_t) [*c]xcb_render_pictforminfo_t;
pub extern fn xcb_render_query_pict_formats_formats_length(R: [*c]const xcb_render_query_pict_formats_reply_t) c_int;
pub extern fn xcb_render_query_pict_formats_formats_iterator(R: [*c]const xcb_render_query_pict_formats_reply_t) xcb_render_pictforminfo_iterator_t;
pub extern fn xcb_render_query_pict_formats_screens_length(R: [*c]const xcb_render_query_pict_formats_reply_t) c_int;
pub extern fn xcb_render_query_pict_formats_screens_iterator(R: [*c]const xcb_render_query_pict_formats_reply_t) xcb_render_pictscreen_iterator_t;
pub extern fn xcb_render_query_pict_formats_subpixels(R: [*c]const xcb_render_query_pict_formats_reply_t) [*c]u32;
pub extern fn xcb_render_query_pict_formats_subpixels_length(R: [*c]const xcb_render_query_pict_formats_reply_t) c_int;
pub extern fn xcb_render_query_pict_formats_subpixels_end(R: [*c]const xcb_render_query_pict_formats_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_render_query_pict_formats_reply(c: ?*xcb_connection_t, cookie: xcb_render_query_pict_formats_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_render_query_pict_formats_reply_t;
pub extern fn xcb_render_query_pict_index_values_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_render_query_pict_index_values(c: ?*xcb_connection_t, format: xcb_render_pictformat_t) xcb_render_query_pict_index_values_cookie_t;
pub extern fn xcb_render_query_pict_index_values_unchecked(c: ?*xcb_connection_t, format: xcb_render_pictformat_t) xcb_render_query_pict_index_values_cookie_t;
pub extern fn xcb_render_query_pict_index_values_values(R: [*c]const xcb_render_query_pict_index_values_reply_t) [*c]xcb_render_indexvalue_t;
pub extern fn xcb_render_query_pict_index_values_values_length(R: [*c]const xcb_render_query_pict_index_values_reply_t) c_int;
pub extern fn xcb_render_query_pict_index_values_values_iterator(R: [*c]const xcb_render_query_pict_index_values_reply_t) xcb_render_indexvalue_iterator_t;
pub extern fn xcb_render_query_pict_index_values_reply(c: ?*xcb_connection_t, cookie: xcb_render_query_pict_index_values_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_render_query_pict_index_values_reply_t;
pub extern fn xcb_render_create_picture_value_list_serialize(_buffer: [*c]?*anyopaque, value_mask: u32, _aux: [*c]const xcb_render_create_picture_value_list_t) c_int;
pub extern fn xcb_render_create_picture_value_list_unpack(_buffer: ?*const anyopaque, value_mask: u32, _aux: [*c]xcb_render_create_picture_value_list_t) c_int;
pub extern fn xcb_render_create_picture_value_list_sizeof(_buffer: ?*const anyopaque, value_mask: u32) c_int;
pub extern fn xcb_render_create_picture_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_render_create_picture_checked(c: ?*xcb_connection_t, pid: xcb_render_picture_t, drawable: xcb_drawable_t, format: xcb_render_pictformat_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_render_create_picture(c: ?*xcb_connection_t, pid: xcb_render_picture_t, drawable: xcb_drawable_t, format: xcb_render_pictformat_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_render_create_picture_aux_checked(c: ?*xcb_connection_t, pid: xcb_render_picture_t, drawable: xcb_drawable_t, format: xcb_render_pictformat_t, value_mask: u32, value_list: [*c]const xcb_render_create_picture_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_picture_aux(c: ?*xcb_connection_t, pid: xcb_render_picture_t, drawable: xcb_drawable_t, format: xcb_render_pictformat_t, value_mask: u32, value_list: [*c]const xcb_render_create_picture_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_picture_value_list(R: [*c]const xcb_render_create_picture_request_t) ?*anyopaque;
pub extern fn xcb_render_change_picture_value_list_serialize(_buffer: [*c]?*anyopaque, value_mask: u32, _aux: [*c]const xcb_render_change_picture_value_list_t) c_int;
pub extern fn xcb_render_change_picture_value_list_unpack(_buffer: ?*const anyopaque, value_mask: u32, _aux: [*c]xcb_render_change_picture_value_list_t) c_int;
pub extern fn xcb_render_change_picture_value_list_sizeof(_buffer: ?*const anyopaque, value_mask: u32) c_int;
pub extern fn xcb_render_change_picture_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_render_change_picture_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_render_change_picture(c: ?*xcb_connection_t, picture: xcb_render_picture_t, value_mask: u32, value_list: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_render_change_picture_aux_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t, value_mask: u32, value_list: [*c]const xcb_render_change_picture_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_render_change_picture_aux(c: ?*xcb_connection_t, picture: xcb_render_picture_t, value_mask: u32, value_list: [*c]const xcb_render_change_picture_value_list_t) xcb_void_cookie_t;
pub extern fn xcb_render_change_picture_value_list(R: [*c]const xcb_render_change_picture_request_t) ?*anyopaque;
pub extern fn xcb_render_set_picture_clip_rectangles_sizeof(_buffer: ?*const anyopaque, rectangles_len: u32) c_int;
pub extern fn xcb_render_set_picture_clip_rectangles_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t, clip_x_origin: i16, clip_y_origin: i16, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_render_set_picture_clip_rectangles(c: ?*xcb_connection_t, picture: xcb_render_picture_t, clip_x_origin: i16, clip_y_origin: i16, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_render_set_picture_clip_rectangles_rectangles(R: [*c]const xcb_render_set_picture_clip_rectangles_request_t) [*c]xcb_rectangle_t;
pub extern fn xcb_render_set_picture_clip_rectangles_rectangles_length(R: [*c]const xcb_render_set_picture_clip_rectangles_request_t) c_int;
pub extern fn xcb_render_set_picture_clip_rectangles_rectangles_iterator(R: [*c]const xcb_render_set_picture_clip_rectangles_request_t) xcb_rectangle_iterator_t;
pub extern fn xcb_render_free_picture_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t) xcb_void_cookie_t;
pub extern fn xcb_render_free_picture(c: ?*xcb_connection_t, picture: xcb_render_picture_t) xcb_void_cookie_t;
pub extern fn xcb_render_composite_checked(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, mask: xcb_render_picture_t, dst: xcb_render_picture_t, src_x: i16, src_y: i16, mask_x: i16, mask_y: i16, dst_x: i16, dst_y: i16, width: u16, height: u16) xcb_void_cookie_t;
pub extern fn xcb_render_composite(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, mask: xcb_render_picture_t, dst: xcb_render_picture_t, src_x: i16, src_y: i16, mask_x: i16, mask_y: i16, dst_x: i16, dst_y: i16, width: u16, height: u16) xcb_void_cookie_t;
pub extern fn xcb_render_trapezoids_sizeof(_buffer: ?*const anyopaque, traps_len: u32) c_int;
pub extern fn xcb_render_trapezoids_checked(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, src_x: i16, src_y: i16, traps_len: u32, traps: [*c]const xcb_render_trapezoid_t) xcb_void_cookie_t;
pub extern fn xcb_render_trapezoids(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, src_x: i16, src_y: i16, traps_len: u32, traps: [*c]const xcb_render_trapezoid_t) xcb_void_cookie_t;
pub extern fn xcb_render_trapezoids_traps(R: [*c]const xcb_render_trapezoids_request_t) [*c]xcb_render_trapezoid_t;
pub extern fn xcb_render_trapezoids_traps_length(R: [*c]const xcb_render_trapezoids_request_t) c_int;
pub extern fn xcb_render_trapezoids_traps_iterator(R: [*c]const xcb_render_trapezoids_request_t) xcb_render_trapezoid_iterator_t;
pub extern fn xcb_render_triangles_sizeof(_buffer: ?*const anyopaque, triangles_len: u32) c_int;
pub extern fn xcb_render_triangles_checked(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, src_x: i16, src_y: i16, triangles_len: u32, triangles: [*c]const xcb_render_triangle_t) xcb_void_cookie_t;
pub extern fn xcb_render_triangles(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, src_x: i16, src_y: i16, triangles_len: u32, triangles: [*c]const xcb_render_triangle_t) xcb_void_cookie_t;
pub extern fn xcb_render_triangles_triangles(R: [*c]const xcb_render_triangles_request_t) [*c]xcb_render_triangle_t;
pub extern fn xcb_render_triangles_triangles_length(R: [*c]const xcb_render_triangles_request_t) c_int;
pub extern fn xcb_render_triangles_triangles_iterator(R: [*c]const xcb_render_triangles_request_t) xcb_render_triangle_iterator_t;
pub extern fn xcb_render_tri_strip_sizeof(_buffer: ?*const anyopaque, points_len: u32) c_int;
pub extern fn xcb_render_tri_strip_checked(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, src_x: i16, src_y: i16, points_len: u32, points: [*c]const xcb_render_pointfix_t) xcb_void_cookie_t;
pub extern fn xcb_render_tri_strip(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, src_x: i16, src_y: i16, points_len: u32, points: [*c]const xcb_render_pointfix_t) xcb_void_cookie_t;
pub extern fn xcb_render_tri_strip_points(R: [*c]const xcb_render_tri_strip_request_t) [*c]xcb_render_pointfix_t;
pub extern fn xcb_render_tri_strip_points_length(R: [*c]const xcb_render_tri_strip_request_t) c_int;
pub extern fn xcb_render_tri_strip_points_iterator(R: [*c]const xcb_render_tri_strip_request_t) xcb_render_pointfix_iterator_t;
pub extern fn xcb_render_tri_fan_sizeof(_buffer: ?*const anyopaque, points_len: u32) c_int;
pub extern fn xcb_render_tri_fan_checked(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, src_x: i16, src_y: i16, points_len: u32, points: [*c]const xcb_render_pointfix_t) xcb_void_cookie_t;
pub extern fn xcb_render_tri_fan(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, src_x: i16, src_y: i16, points_len: u32, points: [*c]const xcb_render_pointfix_t) xcb_void_cookie_t;
pub extern fn xcb_render_tri_fan_points(R: [*c]const xcb_render_tri_fan_request_t) [*c]xcb_render_pointfix_t;
pub extern fn xcb_render_tri_fan_points_length(R: [*c]const xcb_render_tri_fan_request_t) c_int;
pub extern fn xcb_render_tri_fan_points_iterator(R: [*c]const xcb_render_tri_fan_request_t) xcb_render_pointfix_iterator_t;
pub extern fn xcb_render_create_glyph_set_checked(c: ?*xcb_connection_t, gsid: xcb_render_glyphset_t, format: xcb_render_pictformat_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_glyph_set(c: ?*xcb_connection_t, gsid: xcb_render_glyphset_t, format: xcb_render_pictformat_t) xcb_void_cookie_t;
pub extern fn xcb_render_reference_glyph_set_checked(c: ?*xcb_connection_t, gsid: xcb_render_glyphset_t, existing: xcb_render_glyphset_t) xcb_void_cookie_t;
pub extern fn xcb_render_reference_glyph_set(c: ?*xcb_connection_t, gsid: xcb_render_glyphset_t, existing: xcb_render_glyphset_t) xcb_void_cookie_t;
pub extern fn xcb_render_free_glyph_set_checked(c: ?*xcb_connection_t, glyphset: xcb_render_glyphset_t) xcb_void_cookie_t;
pub extern fn xcb_render_free_glyph_set(c: ?*xcb_connection_t, glyphset: xcb_render_glyphset_t) xcb_void_cookie_t;
pub extern fn xcb_render_add_glyphs_sizeof(_buffer: ?*const anyopaque, data_len: u32) c_int;
pub extern fn xcb_render_add_glyphs_checked(c: ?*xcb_connection_t, glyphset: xcb_render_glyphset_t, glyphs_len: u32, glyphids: [*c]const u32, glyphs: [*c]const xcb_render_glyphinfo_t, data_len: u32, data: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_render_add_glyphs(c: ?*xcb_connection_t, glyphset: xcb_render_glyphset_t, glyphs_len: u32, glyphids: [*c]const u32, glyphs: [*c]const xcb_render_glyphinfo_t, data_len: u32, data: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_render_add_glyphs_glyphids(R: [*c]const xcb_render_add_glyphs_request_t) [*c]u32;
pub extern fn xcb_render_add_glyphs_glyphids_length(R: [*c]const xcb_render_add_glyphs_request_t) c_int;
pub extern fn xcb_render_add_glyphs_glyphids_end(R: [*c]const xcb_render_add_glyphs_request_t) xcb_generic_iterator_t;
pub extern fn xcb_render_add_glyphs_glyphs(R: [*c]const xcb_render_add_glyphs_request_t) [*c]xcb_render_glyphinfo_t;
pub extern fn xcb_render_add_glyphs_glyphs_length(R: [*c]const xcb_render_add_glyphs_request_t) c_int;
pub extern fn xcb_render_add_glyphs_glyphs_iterator(R: [*c]const xcb_render_add_glyphs_request_t) xcb_render_glyphinfo_iterator_t;
pub extern fn xcb_render_add_glyphs_data(R: [*c]const xcb_render_add_glyphs_request_t) [*c]u8;
pub extern fn xcb_render_add_glyphs_data_length(R: [*c]const xcb_render_add_glyphs_request_t) c_int;
pub extern fn xcb_render_add_glyphs_data_end(R: [*c]const xcb_render_add_glyphs_request_t) xcb_generic_iterator_t;
pub extern fn xcb_render_free_glyphs_sizeof(_buffer: ?*const anyopaque, glyphs_len: u32) c_int;
pub extern fn xcb_render_free_glyphs_checked(c: ?*xcb_connection_t, glyphset: xcb_render_glyphset_t, glyphs_len: u32, glyphs: [*c]const xcb_render_glyph_t) xcb_void_cookie_t;
pub extern fn xcb_render_free_glyphs(c: ?*xcb_connection_t, glyphset: xcb_render_glyphset_t, glyphs_len: u32, glyphs: [*c]const xcb_render_glyph_t) xcb_void_cookie_t;
pub extern fn xcb_render_free_glyphs_glyphs(R: [*c]const xcb_render_free_glyphs_request_t) [*c]xcb_render_glyph_t;
pub extern fn xcb_render_free_glyphs_glyphs_length(R: [*c]const xcb_render_free_glyphs_request_t) c_int;
pub extern fn xcb_render_free_glyphs_glyphs_end(R: [*c]const xcb_render_free_glyphs_request_t) xcb_generic_iterator_t;
pub extern fn xcb_render_composite_glyphs_8_sizeof(_buffer: ?*const anyopaque, glyphcmds_len: u32) c_int;
pub extern fn xcb_render_composite_glyphs_8_checked(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, glyphset: xcb_render_glyphset_t, src_x: i16, src_y: i16, glyphcmds_len: u32, glyphcmds: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_render_composite_glyphs_8(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, glyphset: xcb_render_glyphset_t, src_x: i16, src_y: i16, glyphcmds_len: u32, glyphcmds: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_render_composite_glyphs_8_glyphcmds(R: [*c]const xcb_render_composite_glyphs_8_request_t) [*c]u8;
pub extern fn xcb_render_composite_glyphs_8_glyphcmds_length(R: [*c]const xcb_render_composite_glyphs_8_request_t) c_int;
pub extern fn xcb_render_composite_glyphs_8_glyphcmds_end(R: [*c]const xcb_render_composite_glyphs_8_request_t) xcb_generic_iterator_t;
pub extern fn xcb_render_composite_glyphs_16_sizeof(_buffer: ?*const anyopaque, glyphcmds_len: u32) c_int;
pub extern fn xcb_render_composite_glyphs_16_checked(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, glyphset: xcb_render_glyphset_t, src_x: i16, src_y: i16, glyphcmds_len: u32, glyphcmds: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_render_composite_glyphs_16(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, glyphset: xcb_render_glyphset_t, src_x: i16, src_y: i16, glyphcmds_len: u32, glyphcmds: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_render_composite_glyphs_16_glyphcmds(R: [*c]const xcb_render_composite_glyphs_16_request_t) [*c]u8;
pub extern fn xcb_render_composite_glyphs_16_glyphcmds_length(R: [*c]const xcb_render_composite_glyphs_16_request_t) c_int;
pub extern fn xcb_render_composite_glyphs_16_glyphcmds_end(R: [*c]const xcb_render_composite_glyphs_16_request_t) xcb_generic_iterator_t;
pub extern fn xcb_render_composite_glyphs_32_sizeof(_buffer: ?*const anyopaque, glyphcmds_len: u32) c_int;
pub extern fn xcb_render_composite_glyphs_32_checked(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, glyphset: xcb_render_glyphset_t, src_x: i16, src_y: i16, glyphcmds_len: u32, glyphcmds: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_render_composite_glyphs_32(c: ?*xcb_connection_t, op: u8, src: xcb_render_picture_t, dst: xcb_render_picture_t, mask_format: xcb_render_pictformat_t, glyphset: xcb_render_glyphset_t, src_x: i16, src_y: i16, glyphcmds_len: u32, glyphcmds: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_render_composite_glyphs_32_glyphcmds(R: [*c]const xcb_render_composite_glyphs_32_request_t) [*c]u8;
pub extern fn xcb_render_composite_glyphs_32_glyphcmds_length(R: [*c]const xcb_render_composite_glyphs_32_request_t) c_int;
pub extern fn xcb_render_composite_glyphs_32_glyphcmds_end(R: [*c]const xcb_render_composite_glyphs_32_request_t) xcb_generic_iterator_t;
pub extern fn xcb_render_fill_rectangles_sizeof(_buffer: ?*const anyopaque, rects_len: u32) c_int;
pub extern fn xcb_render_fill_rectangles_checked(c: ?*xcb_connection_t, op: u8, dst: xcb_render_picture_t, color: xcb_render_color_t, rects_len: u32, rects: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_render_fill_rectangles(c: ?*xcb_connection_t, op: u8, dst: xcb_render_picture_t, color: xcb_render_color_t, rects_len: u32, rects: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_render_fill_rectangles_rects(R: [*c]const xcb_render_fill_rectangles_request_t) [*c]xcb_rectangle_t;
pub extern fn xcb_render_fill_rectangles_rects_length(R: [*c]const xcb_render_fill_rectangles_request_t) c_int;
pub extern fn xcb_render_fill_rectangles_rects_iterator(R: [*c]const xcb_render_fill_rectangles_request_t) xcb_rectangle_iterator_t;
pub extern fn xcb_render_create_cursor_checked(c: ?*xcb_connection_t, cid: xcb_cursor_t, source: xcb_render_picture_t, x: u16, y: u16) xcb_void_cookie_t;
pub extern fn xcb_render_create_cursor(c: ?*xcb_connection_t, cid: xcb_cursor_t, source: xcb_render_picture_t, x: u16, y: u16) xcb_void_cookie_t;
pub extern fn xcb_render_transform_next(i: [*c]xcb_render_transform_iterator_t) void;
pub extern fn xcb_render_transform_end(i: xcb_render_transform_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_set_picture_transform_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t, transform: xcb_render_transform_t) xcb_void_cookie_t;
pub extern fn xcb_render_set_picture_transform(c: ?*xcb_connection_t, picture: xcb_render_picture_t, transform: xcb_render_transform_t) xcb_void_cookie_t;
pub extern fn xcb_render_query_filters_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_render_query_filters(c: ?*xcb_connection_t, drawable: xcb_drawable_t) xcb_render_query_filters_cookie_t;
pub extern fn xcb_render_query_filters_unchecked(c: ?*xcb_connection_t, drawable: xcb_drawable_t) xcb_render_query_filters_cookie_t;
pub extern fn xcb_render_query_filters_aliases(R: [*c]const xcb_render_query_filters_reply_t) [*c]u16;
pub extern fn xcb_render_query_filters_aliases_length(R: [*c]const xcb_render_query_filters_reply_t) c_int;
pub extern fn xcb_render_query_filters_aliases_end(R: [*c]const xcb_render_query_filters_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_render_query_filters_filters_length(R: [*c]const xcb_render_query_filters_reply_t) c_int;
pub extern fn xcb_render_query_filters_filters_iterator(R: [*c]const xcb_render_query_filters_reply_t) xcb_str_iterator_t;
pub extern fn xcb_render_query_filters_reply(c: ?*xcb_connection_t, cookie: xcb_render_query_filters_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_render_query_filters_reply_t;
pub extern fn xcb_render_set_picture_filter_sizeof(_buffer: ?*const anyopaque, values_len: u32) c_int;
pub extern fn xcb_render_set_picture_filter_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t, filter_len: u16, filter: [*c]const u8, values_len: u32, values: [*c]const xcb_render_fixed_t) xcb_void_cookie_t;
pub extern fn xcb_render_set_picture_filter(c: ?*xcb_connection_t, picture: xcb_render_picture_t, filter_len: u16, filter: [*c]const u8, values_len: u32, values: [*c]const xcb_render_fixed_t) xcb_void_cookie_t;
pub extern fn xcb_render_set_picture_filter_filter(R: [*c]const xcb_render_set_picture_filter_request_t) [*c]u8;
pub extern fn xcb_render_set_picture_filter_filter_length(R: [*c]const xcb_render_set_picture_filter_request_t) c_int;
pub extern fn xcb_render_set_picture_filter_filter_end(R: [*c]const xcb_render_set_picture_filter_request_t) xcb_generic_iterator_t;
pub extern fn xcb_render_set_picture_filter_values(R: [*c]const xcb_render_set_picture_filter_request_t) [*c]xcb_render_fixed_t;
pub extern fn xcb_render_set_picture_filter_values_length(R: [*c]const xcb_render_set_picture_filter_request_t) c_int;
pub extern fn xcb_render_set_picture_filter_values_end(R: [*c]const xcb_render_set_picture_filter_request_t) xcb_generic_iterator_t;
pub extern fn xcb_render_animcursorelt_next(i: [*c]xcb_render_animcursorelt_iterator_t) void;
pub extern fn xcb_render_animcursorelt_end(i: xcb_render_animcursorelt_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_create_anim_cursor_sizeof(_buffer: ?*const anyopaque, cursors_len: u32) c_int;
pub extern fn xcb_render_create_anim_cursor_checked(c: ?*xcb_connection_t, cid: xcb_cursor_t, cursors_len: u32, cursors: [*c]const xcb_render_animcursorelt_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_anim_cursor(c: ?*xcb_connection_t, cid: xcb_cursor_t, cursors_len: u32, cursors: [*c]const xcb_render_animcursorelt_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_anim_cursor_cursors(R: [*c]const xcb_render_create_anim_cursor_request_t) [*c]xcb_render_animcursorelt_t;
pub extern fn xcb_render_create_anim_cursor_cursors_length(R: [*c]const xcb_render_create_anim_cursor_request_t) c_int;
pub extern fn xcb_render_create_anim_cursor_cursors_iterator(R: [*c]const xcb_render_create_anim_cursor_request_t) xcb_render_animcursorelt_iterator_t;
pub extern fn xcb_render_spanfix_next(i: [*c]xcb_render_spanfix_iterator_t) void;
pub extern fn xcb_render_spanfix_end(i: xcb_render_spanfix_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_trap_next(i: [*c]xcb_render_trap_iterator_t) void;
pub extern fn xcb_render_trap_end(i: xcb_render_trap_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_render_add_traps_sizeof(_buffer: ?*const anyopaque, traps_len: u32) c_int;
pub extern fn xcb_render_add_traps_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t, x_off: i16, y_off: i16, traps_len: u32, traps: [*c]const xcb_render_trap_t) xcb_void_cookie_t;
pub extern fn xcb_render_add_traps(c: ?*xcb_connection_t, picture: xcb_render_picture_t, x_off: i16, y_off: i16, traps_len: u32, traps: [*c]const xcb_render_trap_t) xcb_void_cookie_t;
pub extern fn xcb_render_add_traps_traps(R: [*c]const xcb_render_add_traps_request_t) [*c]xcb_render_trap_t;
pub extern fn xcb_render_add_traps_traps_length(R: [*c]const xcb_render_add_traps_request_t) c_int;
pub extern fn xcb_render_add_traps_traps_iterator(R: [*c]const xcb_render_add_traps_request_t) xcb_render_trap_iterator_t;
pub extern fn xcb_render_create_solid_fill_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t, color: xcb_render_color_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_solid_fill(c: ?*xcb_connection_t, picture: xcb_render_picture_t, color: xcb_render_color_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_linear_gradient_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_render_create_linear_gradient_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t, p1: xcb_render_pointfix_t, p2: xcb_render_pointfix_t, num_stops: u32, stops: [*c]const xcb_render_fixed_t, colors: [*c]const xcb_render_color_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_linear_gradient(c: ?*xcb_connection_t, picture: xcb_render_picture_t, p1: xcb_render_pointfix_t, p2: xcb_render_pointfix_t, num_stops: u32, stops: [*c]const xcb_render_fixed_t, colors: [*c]const xcb_render_color_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_linear_gradient_stops(R: [*c]const xcb_render_create_linear_gradient_request_t) [*c]xcb_render_fixed_t;
pub extern fn xcb_render_create_linear_gradient_stops_length(R: [*c]const xcb_render_create_linear_gradient_request_t) c_int;
pub extern fn xcb_render_create_linear_gradient_stops_end(R: [*c]const xcb_render_create_linear_gradient_request_t) xcb_generic_iterator_t;
pub extern fn xcb_render_create_linear_gradient_colors(R: [*c]const xcb_render_create_linear_gradient_request_t) [*c]xcb_render_color_t;
pub extern fn xcb_render_create_linear_gradient_colors_length(R: [*c]const xcb_render_create_linear_gradient_request_t) c_int;
pub extern fn xcb_render_create_linear_gradient_colors_iterator(R: [*c]const xcb_render_create_linear_gradient_request_t) xcb_render_color_iterator_t;
pub extern fn xcb_render_create_radial_gradient_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_render_create_radial_gradient_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t, inner: xcb_render_pointfix_t, outer: xcb_render_pointfix_t, inner_radius: xcb_render_fixed_t, outer_radius: xcb_render_fixed_t, num_stops: u32, stops: [*c]const xcb_render_fixed_t, colors: [*c]const xcb_render_color_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_radial_gradient(c: ?*xcb_connection_t, picture: xcb_render_picture_t, inner: xcb_render_pointfix_t, outer: xcb_render_pointfix_t, inner_radius: xcb_render_fixed_t, outer_radius: xcb_render_fixed_t, num_stops: u32, stops: [*c]const xcb_render_fixed_t, colors: [*c]const xcb_render_color_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_radial_gradient_stops(R: [*c]const xcb_render_create_radial_gradient_request_t) [*c]xcb_render_fixed_t;
pub extern fn xcb_render_create_radial_gradient_stops_length(R: [*c]const xcb_render_create_radial_gradient_request_t) c_int;
pub extern fn xcb_render_create_radial_gradient_stops_end(R: [*c]const xcb_render_create_radial_gradient_request_t) xcb_generic_iterator_t;
pub extern fn xcb_render_create_radial_gradient_colors(R: [*c]const xcb_render_create_radial_gradient_request_t) [*c]xcb_render_color_t;
pub extern fn xcb_render_create_radial_gradient_colors_length(R: [*c]const xcb_render_create_radial_gradient_request_t) c_int;
pub extern fn xcb_render_create_radial_gradient_colors_iterator(R: [*c]const xcb_render_create_radial_gradient_request_t) xcb_render_color_iterator_t;
pub extern fn xcb_render_create_conical_gradient_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_render_create_conical_gradient_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t, center: xcb_render_pointfix_t, angle: xcb_render_fixed_t, num_stops: u32, stops: [*c]const xcb_render_fixed_t, colors: [*c]const xcb_render_color_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_conical_gradient(c: ?*xcb_connection_t, picture: xcb_render_picture_t, center: xcb_render_pointfix_t, angle: xcb_render_fixed_t, num_stops: u32, stops: [*c]const xcb_render_fixed_t, colors: [*c]const xcb_render_color_t) xcb_void_cookie_t;
pub extern fn xcb_render_create_conical_gradient_stops(R: [*c]const xcb_render_create_conical_gradient_request_t) [*c]xcb_render_fixed_t;
pub extern fn xcb_render_create_conical_gradient_stops_length(R: [*c]const xcb_render_create_conical_gradient_request_t) c_int;
pub extern fn xcb_render_create_conical_gradient_stops_end(R: [*c]const xcb_render_create_conical_gradient_request_t) xcb_generic_iterator_t;
pub extern fn xcb_render_create_conical_gradient_colors(R: [*c]const xcb_render_create_conical_gradient_request_t) [*c]xcb_render_color_t;
pub extern fn xcb_render_create_conical_gradient_colors_length(R: [*c]const xcb_render_create_conical_gradient_request_t) c_int;
pub extern fn xcb_render_create_conical_gradient_colors_iterator(R: [*c]const xcb_render_create_conical_gradient_request_t) xcb_render_color_iterator_t;
pub extern var xcb_shape_id: xcb_extension_t;
pub const xcb_shape_op_t = u8;
pub const struct_xcb_shape_op_iterator_t = extern struct {
    data: [*c]xcb_shape_op_t = @import("std").mem.zeroes([*c]xcb_shape_op_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_shape_op_iterator_t = struct_xcb_shape_op_iterator_t;
pub const xcb_shape_kind_t = u8;
pub const struct_xcb_shape_kind_iterator_t = extern struct {
    data: [*c]xcb_shape_kind_t = @import("std").mem.zeroes([*c]xcb_shape_kind_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_shape_kind_iterator_t = struct_xcb_shape_kind_iterator_t;
pub const XCB_SHAPE_SO_SET: c_int = 0;
pub const XCB_SHAPE_SO_UNION: c_int = 1;
pub const XCB_SHAPE_SO_INTERSECT: c_int = 2;
pub const XCB_SHAPE_SO_SUBTRACT: c_int = 3;
pub const XCB_SHAPE_SO_INVERT: c_int = 4;
pub const enum_xcb_shape_so_t = c_uint;
pub const xcb_shape_so_t = enum_xcb_shape_so_t;
pub const XCB_SHAPE_SK_BOUNDING: c_int = 0;
pub const XCB_SHAPE_SK_CLIP: c_int = 1;
pub const XCB_SHAPE_SK_INPUT: c_int = 2;
pub const enum_xcb_shape_sk_t = c_uint;
pub const xcb_shape_sk_t = enum_xcb_shape_sk_t;
pub const struct_xcb_shape_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    shape_kind: xcb_shape_kind_t = @import("std").mem.zeroes(xcb_shape_kind_t),
    sequence: u16 = @import("std").mem.zeroes(u16),
    affected_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    extents_x: i16 = @import("std").mem.zeroes(i16),
    extents_y: i16 = @import("std").mem.zeroes(i16),
    extents_width: u16 = @import("std").mem.zeroes(u16),
    extents_height: u16 = @import("std").mem.zeroes(u16),
    server_time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    shaped: u8 = @import("std").mem.zeroes(u8),
    pad0: [11]u8 = @import("std").mem.zeroes([11]u8),
};
pub const xcb_shape_notify_event_t = struct_xcb_shape_notify_event_t;
pub const struct_xcb_shape_query_version_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_shape_query_version_cookie_t = struct_xcb_shape_query_version_cookie_t;
pub const struct_xcb_shape_query_version_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_shape_query_version_request_t = struct_xcb_shape_query_version_request_t;
pub const struct_xcb_shape_query_version_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    major_version: u16 = @import("std").mem.zeroes(u16),
    minor_version: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_shape_query_version_reply_t = struct_xcb_shape_query_version_reply_t;
pub const struct_xcb_shape_rectangles_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    operation: xcb_shape_op_t = @import("std").mem.zeroes(xcb_shape_op_t),
    destination_kind: xcb_shape_kind_t = @import("std").mem.zeroes(xcb_shape_kind_t),
    ordering: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    destination_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x_offset: i16 = @import("std").mem.zeroes(i16),
    y_offset: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_shape_rectangles_request_t = struct_xcb_shape_rectangles_request_t;
pub const struct_xcb_shape_mask_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    operation: xcb_shape_op_t = @import("std").mem.zeroes(xcb_shape_op_t),
    destination_kind: xcb_shape_kind_t = @import("std").mem.zeroes(xcb_shape_kind_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    destination_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x_offset: i16 = @import("std").mem.zeroes(i16),
    y_offset: i16 = @import("std").mem.zeroes(i16),
    source_bitmap: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
};
pub const xcb_shape_mask_request_t = struct_xcb_shape_mask_request_t;
pub const struct_xcb_shape_combine_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    operation: xcb_shape_op_t = @import("std").mem.zeroes(xcb_shape_op_t),
    destination_kind: xcb_shape_kind_t = @import("std").mem.zeroes(xcb_shape_kind_t),
    source_kind: xcb_shape_kind_t = @import("std").mem.zeroes(xcb_shape_kind_t),
    pad0: u8 = @import("std").mem.zeroes(u8),
    destination_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x_offset: i16 = @import("std").mem.zeroes(i16),
    y_offset: i16 = @import("std").mem.zeroes(i16),
    source_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_shape_combine_request_t = struct_xcb_shape_combine_request_t;
pub const struct_xcb_shape_offset_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    destination_kind: xcb_shape_kind_t = @import("std").mem.zeroes(xcb_shape_kind_t),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    destination_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x_offset: i16 = @import("std").mem.zeroes(i16),
    y_offset: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_shape_offset_request_t = struct_xcb_shape_offset_request_t;
pub const struct_xcb_shape_query_extents_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_shape_query_extents_cookie_t = struct_xcb_shape_query_extents_cookie_t;
pub const struct_xcb_shape_query_extents_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    destination_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_shape_query_extents_request_t = struct_xcb_shape_query_extents_request_t;
pub const struct_xcb_shape_query_extents_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    bounding_shaped: u8 = @import("std").mem.zeroes(u8),
    clip_shaped: u8 = @import("std").mem.zeroes(u8),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
    bounding_shape_extents_x: i16 = @import("std").mem.zeroes(i16),
    bounding_shape_extents_y: i16 = @import("std").mem.zeroes(i16),
    bounding_shape_extents_width: u16 = @import("std").mem.zeroes(u16),
    bounding_shape_extents_height: u16 = @import("std").mem.zeroes(u16),
    clip_shape_extents_x: i16 = @import("std").mem.zeroes(i16),
    clip_shape_extents_y: i16 = @import("std").mem.zeroes(i16),
    clip_shape_extents_width: u16 = @import("std").mem.zeroes(u16),
    clip_shape_extents_height: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_shape_query_extents_reply_t = struct_xcb_shape_query_extents_reply_t;
pub const struct_xcb_shape_select_input_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    destination_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    enable: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_shape_select_input_request_t = struct_xcb_shape_select_input_request_t;
pub const struct_xcb_shape_input_selected_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_shape_input_selected_cookie_t = struct_xcb_shape_input_selected_cookie_t;
pub const struct_xcb_shape_input_selected_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    destination_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_shape_input_selected_request_t = struct_xcb_shape_input_selected_request_t;
pub const struct_xcb_shape_input_selected_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    enabled: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_shape_input_selected_reply_t = struct_xcb_shape_input_selected_reply_t;
pub const struct_xcb_shape_get_rectangles_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_shape_get_rectangles_cookie_t = struct_xcb_shape_get_rectangles_cookie_t;
pub const struct_xcb_shape_get_rectangles_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    source_kind: xcb_shape_kind_t = @import("std").mem.zeroes(xcb_shape_kind_t),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_shape_get_rectangles_request_t = struct_xcb_shape_get_rectangles_request_t;
pub const struct_xcb_shape_get_rectangles_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    ordering: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    rectangles_len: u32 = @import("std").mem.zeroes(u32),
    pad0: [20]u8 = @import("std").mem.zeroes([20]u8),
};
pub const xcb_shape_get_rectangles_reply_t = struct_xcb_shape_get_rectangles_reply_t;
pub extern fn xcb_shape_op_next(i: [*c]xcb_shape_op_iterator_t) void;
pub extern fn xcb_shape_op_end(i: xcb_shape_op_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_shape_kind_next(i: [*c]xcb_shape_kind_iterator_t) void;
pub extern fn xcb_shape_kind_end(i: xcb_shape_kind_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_shape_query_version(c: ?*xcb_connection_t) xcb_shape_query_version_cookie_t;
pub extern fn xcb_shape_query_version_unchecked(c: ?*xcb_connection_t) xcb_shape_query_version_cookie_t;
pub extern fn xcb_shape_query_version_reply(c: ?*xcb_connection_t, cookie: xcb_shape_query_version_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_shape_query_version_reply_t;
pub extern fn xcb_shape_rectangles_sizeof(_buffer: ?*const anyopaque, rectangles_len: u32) c_int;
pub extern fn xcb_shape_rectangles_checked(c: ?*xcb_connection_t, operation: xcb_shape_op_t, destination_kind: xcb_shape_kind_t, ordering: u8, destination_window: xcb_window_t, x_offset: i16, y_offset: i16, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_shape_rectangles(c: ?*xcb_connection_t, operation: xcb_shape_op_t, destination_kind: xcb_shape_kind_t, ordering: u8, destination_window: xcb_window_t, x_offset: i16, y_offset: i16, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_shape_rectangles_rectangles(R: [*c]const xcb_shape_rectangles_request_t) [*c]xcb_rectangle_t;
pub extern fn xcb_shape_rectangles_rectangles_length(R: [*c]const xcb_shape_rectangles_request_t) c_int;
pub extern fn xcb_shape_rectangles_rectangles_iterator(R: [*c]const xcb_shape_rectangles_request_t) xcb_rectangle_iterator_t;
pub extern fn xcb_shape_mask_checked(c: ?*xcb_connection_t, operation: xcb_shape_op_t, destination_kind: xcb_shape_kind_t, destination_window: xcb_window_t, x_offset: i16, y_offset: i16, source_bitmap: xcb_pixmap_t) xcb_void_cookie_t;
pub extern fn xcb_shape_mask(c: ?*xcb_connection_t, operation: xcb_shape_op_t, destination_kind: xcb_shape_kind_t, destination_window: xcb_window_t, x_offset: i16, y_offset: i16, source_bitmap: xcb_pixmap_t) xcb_void_cookie_t;
pub extern fn xcb_shape_combine_checked(c: ?*xcb_connection_t, operation: xcb_shape_op_t, destination_kind: xcb_shape_kind_t, source_kind: xcb_shape_kind_t, destination_window: xcb_window_t, x_offset: i16, y_offset: i16, source_window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_shape_combine(c: ?*xcb_connection_t, operation: xcb_shape_op_t, destination_kind: xcb_shape_kind_t, source_kind: xcb_shape_kind_t, destination_window: xcb_window_t, x_offset: i16, y_offset: i16, source_window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_shape_offset_checked(c: ?*xcb_connection_t, destination_kind: xcb_shape_kind_t, destination_window: xcb_window_t, x_offset: i16, y_offset: i16) xcb_void_cookie_t;
pub extern fn xcb_shape_offset(c: ?*xcb_connection_t, destination_kind: xcb_shape_kind_t, destination_window: xcb_window_t, x_offset: i16, y_offset: i16) xcb_void_cookie_t;
pub extern fn xcb_shape_query_extents(c: ?*xcb_connection_t, destination_window: xcb_window_t) xcb_shape_query_extents_cookie_t;
pub extern fn xcb_shape_query_extents_unchecked(c: ?*xcb_connection_t, destination_window: xcb_window_t) xcb_shape_query_extents_cookie_t;
pub extern fn xcb_shape_query_extents_reply(c: ?*xcb_connection_t, cookie: xcb_shape_query_extents_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_shape_query_extents_reply_t;
pub extern fn xcb_shape_select_input_checked(c: ?*xcb_connection_t, destination_window: xcb_window_t, enable: u8) xcb_void_cookie_t;
pub extern fn xcb_shape_select_input(c: ?*xcb_connection_t, destination_window: xcb_window_t, enable: u8) xcb_void_cookie_t;
pub extern fn xcb_shape_input_selected(c: ?*xcb_connection_t, destination_window: xcb_window_t) xcb_shape_input_selected_cookie_t;
pub extern fn xcb_shape_input_selected_unchecked(c: ?*xcb_connection_t, destination_window: xcb_window_t) xcb_shape_input_selected_cookie_t;
pub extern fn xcb_shape_input_selected_reply(c: ?*xcb_connection_t, cookie: xcb_shape_input_selected_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_shape_input_selected_reply_t;
pub extern fn xcb_shape_get_rectangles_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_shape_get_rectangles(c: ?*xcb_connection_t, window: xcb_window_t, source_kind: xcb_shape_kind_t) xcb_shape_get_rectangles_cookie_t;
pub extern fn xcb_shape_get_rectangles_unchecked(c: ?*xcb_connection_t, window: xcb_window_t, source_kind: xcb_shape_kind_t) xcb_shape_get_rectangles_cookie_t;
pub extern fn xcb_shape_get_rectangles_rectangles(R: [*c]const xcb_shape_get_rectangles_reply_t) [*c]xcb_rectangle_t;
pub extern fn xcb_shape_get_rectangles_rectangles_length(R: [*c]const xcb_shape_get_rectangles_reply_t) c_int;
pub extern fn xcb_shape_get_rectangles_rectangles_iterator(R: [*c]const xcb_shape_get_rectangles_reply_t) xcb_rectangle_iterator_t;
pub extern fn xcb_shape_get_rectangles_reply(c: ?*xcb_connection_t, cookie: xcb_shape_get_rectangles_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_shape_get_rectangles_reply_t;
pub extern var xcb_xfixes_id: xcb_extension_t;
pub const struct_xcb_xfixes_query_version_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_xfixes_query_version_cookie_t = struct_xcb_xfixes_query_version_cookie_t;
pub const struct_xcb_xfixes_query_version_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    client_major_version: u32 = @import("std").mem.zeroes(u32),
    client_minor_version: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_xfixes_query_version_request_t = struct_xcb_xfixes_query_version_request_t;
pub const struct_xcb_xfixes_query_version_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    major_version: u32 = @import("std").mem.zeroes(u32),
    minor_version: u32 = @import("std").mem.zeroes(u32),
    pad1: [16]u8 = @import("std").mem.zeroes([16]u8),
};
pub const xcb_xfixes_query_version_reply_t = struct_xcb_xfixes_query_version_reply_t;
pub const XCB_XFIXES_SAVE_SET_MODE_INSERT: c_int = 0;
pub const XCB_XFIXES_SAVE_SET_MODE_DELETE: c_int = 1;
pub const enum_xcb_xfixes_save_set_mode_t = c_uint;
pub const xcb_xfixes_save_set_mode_t = enum_xcb_xfixes_save_set_mode_t;
pub const XCB_XFIXES_SAVE_SET_TARGET_NEAREST: c_int = 0;
pub const XCB_XFIXES_SAVE_SET_TARGET_ROOT: c_int = 1;
pub const enum_xcb_xfixes_save_set_target_t = c_uint;
pub const xcb_xfixes_save_set_target_t = enum_xcb_xfixes_save_set_target_t;
pub const XCB_XFIXES_SAVE_SET_MAPPING_MAP: c_int = 0;
pub const XCB_XFIXES_SAVE_SET_MAPPING_UNMAP: c_int = 1;
pub const enum_xcb_xfixes_save_set_mapping_t = c_uint;
pub const xcb_xfixes_save_set_mapping_t = enum_xcb_xfixes_save_set_mapping_t;
pub const struct_xcb_xfixes_change_save_set_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    mode: u8 = @import("std").mem.zeroes(u8),
    target: u8 = @import("std").mem.zeroes(u8),
    map: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_xfixes_change_save_set_request_t = struct_xcb_xfixes_change_save_set_request_t;
pub const XCB_XFIXES_SELECTION_EVENT_SET_SELECTION_OWNER: c_int = 0;
pub const XCB_XFIXES_SELECTION_EVENT_SELECTION_WINDOW_DESTROY: c_int = 1;
pub const XCB_XFIXES_SELECTION_EVENT_SELECTION_CLIENT_CLOSE: c_int = 2;
pub const enum_xcb_xfixes_selection_event_t = c_uint;
pub const xcb_xfixes_selection_event_t = enum_xcb_xfixes_selection_event_t;
pub const XCB_XFIXES_SELECTION_EVENT_MASK_SET_SELECTION_OWNER: c_int = 1;
pub const XCB_XFIXES_SELECTION_EVENT_MASK_SELECTION_WINDOW_DESTROY: c_int = 2;
pub const XCB_XFIXES_SELECTION_EVENT_MASK_SELECTION_CLIENT_CLOSE: c_int = 4;
pub const enum_xcb_xfixes_selection_event_mask_t = c_uint;
pub const xcb_xfixes_selection_event_mask_t = enum_xcb_xfixes_selection_event_mask_t;
pub const struct_xcb_xfixes_selection_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    subtype: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    owner: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    selection: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    timestamp: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    selection_timestamp: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    pad0: [8]u8 = @import("std").mem.zeroes([8]u8),
};
pub const xcb_xfixes_selection_notify_event_t = struct_xcb_xfixes_selection_notify_event_t;
pub const struct_xcb_xfixes_select_selection_input_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    selection: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    event_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_xfixes_select_selection_input_request_t = struct_xcb_xfixes_select_selection_input_request_t;
pub const XCB_XFIXES_CURSOR_NOTIFY_DISPLAY_CURSOR: c_int = 0;
pub const enum_xcb_xfixes_cursor_notify_t = c_uint;
pub const xcb_xfixes_cursor_notify_t = enum_xcb_xfixes_cursor_notify_t;
pub const XCB_XFIXES_CURSOR_NOTIFY_MASK_DISPLAY_CURSOR: c_int = 1;
pub const enum_xcb_xfixes_cursor_notify_mask_t = c_uint;
pub const xcb_xfixes_cursor_notify_mask_t = enum_xcb_xfixes_cursor_notify_mask_t;
pub const struct_xcb_xfixes_cursor_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    subtype: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    cursor_serial: u32 = @import("std").mem.zeroes(u32),
    timestamp: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    name: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    pad0: [12]u8 = @import("std").mem.zeroes([12]u8),
};
pub const xcb_xfixes_cursor_notify_event_t = struct_xcb_xfixes_cursor_notify_event_t;
pub const struct_xcb_xfixes_select_cursor_input_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event_mask: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_xfixes_select_cursor_input_request_t = struct_xcb_xfixes_select_cursor_input_request_t;
pub const struct_xcb_xfixes_get_cursor_image_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_xfixes_get_cursor_image_cookie_t = struct_xcb_xfixes_get_cursor_image_cookie_t;
pub const struct_xcb_xfixes_get_cursor_image_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_xfixes_get_cursor_image_request_t = struct_xcb_xfixes_get_cursor_image_request_t;
pub const struct_xcb_xfixes_get_cursor_image_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    xhot: u16 = @import("std").mem.zeroes(u16),
    yhot: u16 = @import("std").mem.zeroes(u16),
    cursor_serial: u32 = @import("std").mem.zeroes(u32),
    pad1: [8]u8 = @import("std").mem.zeroes([8]u8),
};
pub const xcb_xfixes_get_cursor_image_reply_t = struct_xcb_xfixes_get_cursor_image_reply_t;
pub const xcb_xfixes_region_t = u32;
pub const struct_xcb_xfixes_region_iterator_t = extern struct {
    data: [*c]xcb_xfixes_region_t = @import("std").mem.zeroes([*c]xcb_xfixes_region_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_xfixes_region_iterator_t = struct_xcb_xfixes_region_iterator_t;
pub const struct_xcb_xfixes_bad_region_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_xfixes_bad_region_error_t = struct_xcb_xfixes_bad_region_error_t;
pub const XCB_XFIXES_REGION_NONE: c_int = 0;
pub const enum_xcb_xfixes_region_enum_t = c_uint;
pub const xcb_xfixes_region_enum_t = enum_xcb_xfixes_region_enum_t;
pub const struct_xcb_xfixes_create_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
};
pub const xcb_xfixes_create_region_request_t = struct_xcb_xfixes_create_region_request_t;
pub const struct_xcb_xfixes_create_region_from_bitmap_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    bitmap: xcb_pixmap_t = @import("std").mem.zeroes(xcb_pixmap_t),
};
pub const xcb_xfixes_create_region_from_bitmap_request_t = struct_xcb_xfixes_create_region_from_bitmap_request_t;
pub const struct_xcb_xfixes_create_region_from_window_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    kind: xcb_shape_kind_t = @import("std").mem.zeroes(xcb_shape_kind_t),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_xfixes_create_region_from_window_request_t = struct_xcb_xfixes_create_region_from_window_request_t;
pub const struct_xcb_xfixes_create_region_from_gc_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
};
pub const xcb_xfixes_create_region_from_gc_request_t = struct_xcb_xfixes_create_region_from_gc_request_t;
pub const struct_xcb_xfixes_create_region_from_picture_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
};
pub const xcb_xfixes_create_region_from_picture_request_t = struct_xcb_xfixes_create_region_from_picture_request_t;
pub const struct_xcb_xfixes_destroy_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
};
pub const xcb_xfixes_destroy_region_request_t = struct_xcb_xfixes_destroy_region_request_t;
pub const struct_xcb_xfixes_set_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
};
pub const xcb_xfixes_set_region_request_t = struct_xcb_xfixes_set_region_request_t;
pub const struct_xcb_xfixes_copy_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    source: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    destination: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
};
pub const xcb_xfixes_copy_region_request_t = struct_xcb_xfixes_copy_region_request_t;
pub const struct_xcb_xfixes_union_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    source1: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    source2: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    destination: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
};
pub const xcb_xfixes_union_region_request_t = struct_xcb_xfixes_union_region_request_t;
pub const struct_xcb_xfixes_intersect_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    source1: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    source2: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    destination: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
};
pub const xcb_xfixes_intersect_region_request_t = struct_xcb_xfixes_intersect_region_request_t;
pub const struct_xcb_xfixes_subtract_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    source1: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    source2: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    destination: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
};
pub const xcb_xfixes_subtract_region_request_t = struct_xcb_xfixes_subtract_region_request_t;
pub const struct_xcb_xfixes_invert_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    source: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    bounds: xcb_rectangle_t = @import("std").mem.zeroes(xcb_rectangle_t),
    destination: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
};
pub const xcb_xfixes_invert_region_request_t = struct_xcb_xfixes_invert_region_request_t;
pub const struct_xcb_xfixes_translate_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    dx: i16 = @import("std").mem.zeroes(i16),
    dy: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_xfixes_translate_region_request_t = struct_xcb_xfixes_translate_region_request_t;
pub const struct_xcb_xfixes_region_extents_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    source: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    destination: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
};
pub const xcb_xfixes_region_extents_request_t = struct_xcb_xfixes_region_extents_request_t;
pub const struct_xcb_xfixes_fetch_region_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_xfixes_fetch_region_cookie_t = struct_xcb_xfixes_fetch_region_cookie_t;
pub const struct_xcb_xfixes_fetch_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
};
pub const xcb_xfixes_fetch_region_request_t = struct_xcb_xfixes_fetch_region_request_t;
pub const struct_xcb_xfixes_fetch_region_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    extents: xcb_rectangle_t = @import("std").mem.zeroes(xcb_rectangle_t),
    pad1: [16]u8 = @import("std").mem.zeroes([16]u8),
};
pub const xcb_xfixes_fetch_region_reply_t = struct_xcb_xfixes_fetch_region_reply_t;
pub const struct_xcb_xfixes_set_gc_clip_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    gc: xcb_gcontext_t = @import("std").mem.zeroes(xcb_gcontext_t),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    x_origin: i16 = @import("std").mem.zeroes(i16),
    y_origin: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_xfixes_set_gc_clip_region_request_t = struct_xcb_xfixes_set_gc_clip_region_request_t;
pub const struct_xcb_xfixes_set_window_shape_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    dest: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    dest_kind: xcb_shape_kind_t = @import("std").mem.zeroes(xcb_shape_kind_t),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    x_offset: i16 = @import("std").mem.zeroes(i16),
    y_offset: i16 = @import("std").mem.zeroes(i16),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
};
pub const xcb_xfixes_set_window_shape_region_request_t = struct_xcb_xfixes_set_window_shape_region_request_t;
pub const struct_xcb_xfixes_set_picture_clip_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    picture: xcb_render_picture_t = @import("std").mem.zeroes(xcb_render_picture_t),
    region: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    x_origin: i16 = @import("std").mem.zeroes(i16),
    y_origin: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_xfixes_set_picture_clip_region_request_t = struct_xcb_xfixes_set_picture_clip_region_request_t;
pub const struct_xcb_xfixes_set_cursor_name_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    nbytes: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_xfixes_set_cursor_name_request_t = struct_xcb_xfixes_set_cursor_name_request_t;
pub const struct_xcb_xfixes_get_cursor_name_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_xfixes_get_cursor_name_cookie_t = struct_xcb_xfixes_get_cursor_name_cookie_t;
pub const struct_xcb_xfixes_get_cursor_name_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
};
pub const xcb_xfixes_get_cursor_name_request_t = struct_xcb_xfixes_get_cursor_name_request_t;
pub const struct_xcb_xfixes_get_cursor_name_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    atom: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    nbytes: u16 = @import("std").mem.zeroes(u16),
    pad1: [18]u8 = @import("std").mem.zeroes([18]u8),
};
pub const xcb_xfixes_get_cursor_name_reply_t = struct_xcb_xfixes_get_cursor_name_reply_t;
pub const struct_xcb_xfixes_get_cursor_image_and_name_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_xfixes_get_cursor_image_and_name_cookie_t = struct_xcb_xfixes_get_cursor_image_and_name_cookie_t;
pub const struct_xcb_xfixes_get_cursor_image_and_name_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_xfixes_get_cursor_image_and_name_request_t = struct_xcb_xfixes_get_cursor_image_and_name_request_t;
pub const struct_xcb_xfixes_get_cursor_image_and_name_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    x: i16 = @import("std").mem.zeroes(i16),
    y: i16 = @import("std").mem.zeroes(i16),
    width: u16 = @import("std").mem.zeroes(u16),
    height: u16 = @import("std").mem.zeroes(u16),
    xhot: u16 = @import("std").mem.zeroes(u16),
    yhot: u16 = @import("std").mem.zeroes(u16),
    cursor_serial: u32 = @import("std").mem.zeroes(u32),
    cursor_atom: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    nbytes: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_xfixes_get_cursor_image_and_name_reply_t = struct_xcb_xfixes_get_cursor_image_and_name_reply_t;
pub const struct_xcb_xfixes_change_cursor_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    source: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    destination: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
};
pub const xcb_xfixes_change_cursor_request_t = struct_xcb_xfixes_change_cursor_request_t;
pub const struct_xcb_xfixes_change_cursor_by_name_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    src: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    nbytes: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_xfixes_change_cursor_by_name_request_t = struct_xcb_xfixes_change_cursor_by_name_request_t;
pub const struct_xcb_xfixes_expand_region_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    source: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    destination: xcb_xfixes_region_t = @import("std").mem.zeroes(xcb_xfixes_region_t),
    left: u16 = @import("std").mem.zeroes(u16),
    right: u16 = @import("std").mem.zeroes(u16),
    top: u16 = @import("std").mem.zeroes(u16),
    bottom: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_xfixes_expand_region_request_t = struct_xcb_xfixes_expand_region_request_t;
pub const struct_xcb_xfixes_hide_cursor_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_xfixes_hide_cursor_request_t = struct_xcb_xfixes_hide_cursor_request_t;
pub const struct_xcb_xfixes_show_cursor_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_xfixes_show_cursor_request_t = struct_xcb_xfixes_show_cursor_request_t;
pub const xcb_xfixes_barrier_t = u32;
pub const struct_xcb_xfixes_barrier_iterator_t = extern struct {
    data: [*c]xcb_xfixes_barrier_t = @import("std").mem.zeroes([*c]xcb_xfixes_barrier_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_xfixes_barrier_iterator_t = struct_xcb_xfixes_barrier_iterator_t;
pub const XCB_XFIXES_BARRIER_DIRECTIONS_POSITIVE_X: c_int = 1;
pub const XCB_XFIXES_BARRIER_DIRECTIONS_POSITIVE_Y: c_int = 2;
pub const XCB_XFIXES_BARRIER_DIRECTIONS_NEGATIVE_X: c_int = 4;
pub const XCB_XFIXES_BARRIER_DIRECTIONS_NEGATIVE_Y: c_int = 8;
pub const enum_xcb_xfixes_barrier_directions_t = c_uint;
pub const xcb_xfixes_barrier_directions_t = enum_xcb_xfixes_barrier_directions_t;
pub const struct_xcb_xfixes_create_pointer_barrier_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    barrier: xcb_xfixes_barrier_t = @import("std").mem.zeroes(xcb_xfixes_barrier_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    x1: u16 = @import("std").mem.zeroes(u16),
    y1: u16 = @import("std").mem.zeroes(u16),
    x2: u16 = @import("std").mem.zeroes(u16),
    y2: u16 = @import("std").mem.zeroes(u16),
    directions: u32 = @import("std").mem.zeroes(u32),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    num_devices: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_xfixes_create_pointer_barrier_request_t = struct_xcb_xfixes_create_pointer_barrier_request_t;
pub const struct_xcb_xfixes_delete_pointer_barrier_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    barrier: xcb_xfixes_barrier_t = @import("std").mem.zeroes(xcb_xfixes_barrier_t),
};
pub const xcb_xfixes_delete_pointer_barrier_request_t = struct_xcb_xfixes_delete_pointer_barrier_request_t;
pub extern fn xcb_xfixes_query_version(c: ?*xcb_connection_t, client_major_version: u32, client_minor_version: u32) xcb_xfixes_query_version_cookie_t;
pub extern fn xcb_xfixes_query_version_unchecked(c: ?*xcb_connection_t, client_major_version: u32, client_minor_version: u32) xcb_xfixes_query_version_cookie_t;
pub extern fn xcb_xfixes_query_version_reply(c: ?*xcb_connection_t, cookie: xcb_xfixes_query_version_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_xfixes_query_version_reply_t;
pub extern fn xcb_xfixes_change_save_set_checked(c: ?*xcb_connection_t, mode: u8, target: u8, map: u8, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_change_save_set(c: ?*xcb_connection_t, mode: u8, target: u8, map: u8, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_select_selection_input_checked(c: ?*xcb_connection_t, window: xcb_window_t, selection: xcb_atom_t, event_mask: u32) xcb_void_cookie_t;
pub extern fn xcb_xfixes_select_selection_input(c: ?*xcb_connection_t, window: xcb_window_t, selection: xcb_atom_t, event_mask: u32) xcb_void_cookie_t;
pub extern fn xcb_xfixes_select_cursor_input_checked(c: ?*xcb_connection_t, window: xcb_window_t, event_mask: u32) xcb_void_cookie_t;
pub extern fn xcb_xfixes_select_cursor_input(c: ?*xcb_connection_t, window: xcb_window_t, event_mask: u32) xcb_void_cookie_t;
pub extern fn xcb_xfixes_get_cursor_image_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_xfixes_get_cursor_image(c: ?*xcb_connection_t) xcb_xfixes_get_cursor_image_cookie_t;
pub extern fn xcb_xfixes_get_cursor_image_unchecked(c: ?*xcb_connection_t) xcb_xfixes_get_cursor_image_cookie_t;
pub extern fn xcb_xfixes_get_cursor_image_cursor_image(R: [*c]const xcb_xfixes_get_cursor_image_reply_t) [*c]u32;
pub extern fn xcb_xfixes_get_cursor_image_cursor_image_length(R: [*c]const xcb_xfixes_get_cursor_image_reply_t) c_int;
pub extern fn xcb_xfixes_get_cursor_image_cursor_image_end(R: [*c]const xcb_xfixes_get_cursor_image_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_xfixes_get_cursor_image_reply(c: ?*xcb_connection_t, cookie: xcb_xfixes_get_cursor_image_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_xfixes_get_cursor_image_reply_t;
pub extern fn xcb_xfixes_region_next(i: [*c]xcb_xfixes_region_iterator_t) void;
pub extern fn xcb_xfixes_region_end(i: xcb_xfixes_region_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_xfixes_create_region_sizeof(_buffer: ?*const anyopaque, rectangles_len: u32) c_int;
pub extern fn xcb_xfixes_create_region_checked(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_create_region(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_create_region_rectangles(R: [*c]const xcb_xfixes_create_region_request_t) [*c]xcb_rectangle_t;
pub extern fn xcb_xfixes_create_region_rectangles_length(R: [*c]const xcb_xfixes_create_region_request_t) c_int;
pub extern fn xcb_xfixes_create_region_rectangles_iterator(R: [*c]const xcb_xfixes_create_region_request_t) xcb_rectangle_iterator_t;
pub extern fn xcb_xfixes_create_region_from_bitmap_checked(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, bitmap: xcb_pixmap_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_create_region_from_bitmap(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, bitmap: xcb_pixmap_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_create_region_from_window_checked(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, window: xcb_window_t, kind: xcb_shape_kind_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_create_region_from_window(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, window: xcb_window_t, kind: xcb_shape_kind_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_create_region_from_gc_checked(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, gc: xcb_gcontext_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_create_region_from_gc(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, gc: xcb_gcontext_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_create_region_from_picture_checked(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, picture: xcb_render_picture_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_create_region_from_picture(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, picture: xcb_render_picture_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_destroy_region_checked(c: ?*xcb_connection_t, region: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_destroy_region(c: ?*xcb_connection_t, region: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_set_region_sizeof(_buffer: ?*const anyopaque, rectangles_len: u32) c_int;
pub extern fn xcb_xfixes_set_region_checked(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_set_region(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, rectangles_len: u32, rectangles: [*c]const xcb_rectangle_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_set_region_rectangles(R: [*c]const xcb_xfixes_set_region_request_t) [*c]xcb_rectangle_t;
pub extern fn xcb_xfixes_set_region_rectangles_length(R: [*c]const xcb_xfixes_set_region_request_t) c_int;
pub extern fn xcb_xfixes_set_region_rectangles_iterator(R: [*c]const xcb_xfixes_set_region_request_t) xcb_rectangle_iterator_t;
pub extern fn xcb_xfixes_copy_region_checked(c: ?*xcb_connection_t, source: xcb_xfixes_region_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_copy_region(c: ?*xcb_connection_t, source: xcb_xfixes_region_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_union_region_checked(c: ?*xcb_connection_t, source1: xcb_xfixes_region_t, source2: xcb_xfixes_region_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_union_region(c: ?*xcb_connection_t, source1: xcb_xfixes_region_t, source2: xcb_xfixes_region_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_intersect_region_checked(c: ?*xcb_connection_t, source1: xcb_xfixes_region_t, source2: xcb_xfixes_region_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_intersect_region(c: ?*xcb_connection_t, source1: xcb_xfixes_region_t, source2: xcb_xfixes_region_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_subtract_region_checked(c: ?*xcb_connection_t, source1: xcb_xfixes_region_t, source2: xcb_xfixes_region_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_subtract_region(c: ?*xcb_connection_t, source1: xcb_xfixes_region_t, source2: xcb_xfixes_region_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_invert_region_checked(c: ?*xcb_connection_t, source: xcb_xfixes_region_t, bounds: xcb_rectangle_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_invert_region(c: ?*xcb_connection_t, source: xcb_xfixes_region_t, bounds: xcb_rectangle_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_translate_region_checked(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, dx: i16, dy: i16) xcb_void_cookie_t;
pub extern fn xcb_xfixes_translate_region(c: ?*xcb_connection_t, region: xcb_xfixes_region_t, dx: i16, dy: i16) xcb_void_cookie_t;
pub extern fn xcb_xfixes_region_extents_checked(c: ?*xcb_connection_t, source: xcb_xfixes_region_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_region_extents(c: ?*xcb_connection_t, source: xcb_xfixes_region_t, destination: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_fetch_region_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_xfixes_fetch_region(c: ?*xcb_connection_t, region: xcb_xfixes_region_t) xcb_xfixes_fetch_region_cookie_t;
pub extern fn xcb_xfixes_fetch_region_unchecked(c: ?*xcb_connection_t, region: xcb_xfixes_region_t) xcb_xfixes_fetch_region_cookie_t;
pub extern fn xcb_xfixes_fetch_region_rectangles(R: [*c]const xcb_xfixes_fetch_region_reply_t) [*c]xcb_rectangle_t;
pub extern fn xcb_xfixes_fetch_region_rectangles_length(R: [*c]const xcb_xfixes_fetch_region_reply_t) c_int;
pub extern fn xcb_xfixes_fetch_region_rectangles_iterator(R: [*c]const xcb_xfixes_fetch_region_reply_t) xcb_rectangle_iterator_t;
pub extern fn xcb_xfixes_fetch_region_reply(c: ?*xcb_connection_t, cookie: xcb_xfixes_fetch_region_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_xfixes_fetch_region_reply_t;
pub extern fn xcb_xfixes_set_gc_clip_region_checked(c: ?*xcb_connection_t, gc: xcb_gcontext_t, region: xcb_xfixes_region_t, x_origin: i16, y_origin: i16) xcb_void_cookie_t;
pub extern fn xcb_xfixes_set_gc_clip_region(c: ?*xcb_connection_t, gc: xcb_gcontext_t, region: xcb_xfixes_region_t, x_origin: i16, y_origin: i16) xcb_void_cookie_t;
pub extern fn xcb_xfixes_set_window_shape_region_checked(c: ?*xcb_connection_t, dest: xcb_window_t, dest_kind: xcb_shape_kind_t, x_offset: i16, y_offset: i16, region: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_set_window_shape_region(c: ?*xcb_connection_t, dest: xcb_window_t, dest_kind: xcb_shape_kind_t, x_offset: i16, y_offset: i16, region: xcb_xfixes_region_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_set_picture_clip_region_checked(c: ?*xcb_connection_t, picture: xcb_render_picture_t, region: xcb_xfixes_region_t, x_origin: i16, y_origin: i16) xcb_void_cookie_t;
pub extern fn xcb_xfixes_set_picture_clip_region(c: ?*xcb_connection_t, picture: xcb_render_picture_t, region: xcb_xfixes_region_t, x_origin: i16, y_origin: i16) xcb_void_cookie_t;
pub extern fn xcb_xfixes_set_cursor_name_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_xfixes_set_cursor_name_checked(c: ?*xcb_connection_t, cursor: xcb_cursor_t, nbytes: u16, name: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_xfixes_set_cursor_name(c: ?*xcb_connection_t, cursor: xcb_cursor_t, nbytes: u16, name: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_xfixes_set_cursor_name_name(R: [*c]const xcb_xfixes_set_cursor_name_request_t) [*c]u8;
pub extern fn xcb_xfixes_set_cursor_name_name_length(R: [*c]const xcb_xfixes_set_cursor_name_request_t) c_int;
pub extern fn xcb_xfixes_set_cursor_name_name_end(R: [*c]const xcb_xfixes_set_cursor_name_request_t) xcb_generic_iterator_t;
pub extern fn xcb_xfixes_get_cursor_name_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_xfixes_get_cursor_name(c: ?*xcb_connection_t, cursor: xcb_cursor_t) xcb_xfixes_get_cursor_name_cookie_t;
pub extern fn xcb_xfixes_get_cursor_name_unchecked(c: ?*xcb_connection_t, cursor: xcb_cursor_t) xcb_xfixes_get_cursor_name_cookie_t;
pub extern fn xcb_xfixes_get_cursor_name_name(R: [*c]const xcb_xfixes_get_cursor_name_reply_t) [*c]u8;
pub extern fn xcb_xfixes_get_cursor_name_name_length(R: [*c]const xcb_xfixes_get_cursor_name_reply_t) c_int;
pub extern fn xcb_xfixes_get_cursor_name_name_end(R: [*c]const xcb_xfixes_get_cursor_name_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_xfixes_get_cursor_name_reply(c: ?*xcb_connection_t, cookie: xcb_xfixes_get_cursor_name_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_xfixes_get_cursor_name_reply_t;
pub extern fn xcb_xfixes_get_cursor_image_and_name_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_xfixes_get_cursor_image_and_name(c: ?*xcb_connection_t) xcb_xfixes_get_cursor_image_and_name_cookie_t;
pub extern fn xcb_xfixes_get_cursor_image_and_name_unchecked(c: ?*xcb_connection_t) xcb_xfixes_get_cursor_image_and_name_cookie_t;
pub extern fn xcb_xfixes_get_cursor_image_and_name_cursor_image(R: [*c]const xcb_xfixes_get_cursor_image_and_name_reply_t) [*c]u32;
pub extern fn xcb_xfixes_get_cursor_image_and_name_cursor_image_length(R: [*c]const xcb_xfixes_get_cursor_image_and_name_reply_t) c_int;
pub extern fn xcb_xfixes_get_cursor_image_and_name_cursor_image_end(R: [*c]const xcb_xfixes_get_cursor_image_and_name_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_xfixes_get_cursor_image_and_name_name(R: [*c]const xcb_xfixes_get_cursor_image_and_name_reply_t) [*c]u8;
pub extern fn xcb_xfixes_get_cursor_image_and_name_name_length(R: [*c]const xcb_xfixes_get_cursor_image_and_name_reply_t) c_int;
pub extern fn xcb_xfixes_get_cursor_image_and_name_name_end(R: [*c]const xcb_xfixes_get_cursor_image_and_name_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_xfixes_get_cursor_image_and_name_reply(c: ?*xcb_connection_t, cookie: xcb_xfixes_get_cursor_image_and_name_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_xfixes_get_cursor_image_and_name_reply_t;
pub extern fn xcb_xfixes_change_cursor_checked(c: ?*xcb_connection_t, source: xcb_cursor_t, destination: xcb_cursor_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_change_cursor(c: ?*xcb_connection_t, source: xcb_cursor_t, destination: xcb_cursor_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_change_cursor_by_name_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_xfixes_change_cursor_by_name_checked(c: ?*xcb_connection_t, src: xcb_cursor_t, nbytes: u16, name: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_xfixes_change_cursor_by_name(c: ?*xcb_connection_t, src: xcb_cursor_t, nbytes: u16, name: [*c]const u8) xcb_void_cookie_t;
pub extern fn xcb_xfixes_change_cursor_by_name_name(R: [*c]const xcb_xfixes_change_cursor_by_name_request_t) [*c]u8;
pub extern fn xcb_xfixes_change_cursor_by_name_name_length(R: [*c]const xcb_xfixes_change_cursor_by_name_request_t) c_int;
pub extern fn xcb_xfixes_change_cursor_by_name_name_end(R: [*c]const xcb_xfixes_change_cursor_by_name_request_t) xcb_generic_iterator_t;
pub extern fn xcb_xfixes_expand_region_checked(c: ?*xcb_connection_t, source: xcb_xfixes_region_t, destination: xcb_xfixes_region_t, left: u16, right: u16, top: u16, bottom: u16) xcb_void_cookie_t;
pub extern fn xcb_xfixes_expand_region(c: ?*xcb_connection_t, source: xcb_xfixes_region_t, destination: xcb_xfixes_region_t, left: u16, right: u16, top: u16, bottom: u16) xcb_void_cookie_t;
pub extern fn xcb_xfixes_hide_cursor_checked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_hide_cursor(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_show_cursor_checked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_show_cursor(c: ?*xcb_connection_t, window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_barrier_next(i: [*c]xcb_xfixes_barrier_iterator_t) void;
pub extern fn xcb_xfixes_barrier_end(i: xcb_xfixes_barrier_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_xfixes_create_pointer_barrier_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_xfixes_create_pointer_barrier_checked(c: ?*xcb_connection_t, barrier: xcb_xfixes_barrier_t, window: xcb_window_t, x1: u16, y1: u16, x2: u16, y2: u16, directions: u32, num_devices: u16, devices: [*c]const u16) xcb_void_cookie_t;
pub extern fn xcb_xfixes_create_pointer_barrier(c: ?*xcb_connection_t, barrier: xcb_xfixes_barrier_t, window: xcb_window_t, x1: u16, y1: u16, x2: u16, y2: u16, directions: u32, num_devices: u16, devices: [*c]const u16) xcb_void_cookie_t;
pub extern fn xcb_xfixes_create_pointer_barrier_devices(R: [*c]const xcb_xfixes_create_pointer_barrier_request_t) [*c]u16;
pub extern fn xcb_xfixes_create_pointer_barrier_devices_length(R: [*c]const xcb_xfixes_create_pointer_barrier_request_t) c_int;
pub extern fn xcb_xfixes_create_pointer_barrier_devices_end(R: [*c]const xcb_xfixes_create_pointer_barrier_request_t) xcb_generic_iterator_t;
pub extern fn xcb_xfixes_delete_pointer_barrier_checked(c: ?*xcb_connection_t, barrier: xcb_xfixes_barrier_t) xcb_void_cookie_t;
pub extern fn xcb_xfixes_delete_pointer_barrier(c: ?*xcb_connection_t, barrier: xcb_xfixes_barrier_t) xcb_void_cookie_t;
pub extern var xcb_input_id: xcb_extension_t;
pub const xcb_input_event_class_t = u32;
pub const struct_xcb_input_event_class_iterator_t = extern struct {
    data: [*c]xcb_input_event_class_t = @import("std").mem.zeroes([*c]xcb_input_event_class_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_event_class_iterator_t = struct_xcb_input_event_class_iterator_t;
pub const xcb_input_key_code_t = u8;
pub const struct_xcb_input_key_code_iterator_t = extern struct {
    data: [*c]xcb_input_key_code_t = @import("std").mem.zeroes([*c]xcb_input_key_code_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_key_code_iterator_t = struct_xcb_input_key_code_iterator_t;
pub const xcb_input_device_id_t = u16;
pub const struct_xcb_input_device_id_iterator_t = extern struct {
    data: [*c]xcb_input_device_id_t = @import("std").mem.zeroes([*c]xcb_input_device_id_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_id_iterator_t = struct_xcb_input_device_id_iterator_t;
pub const xcb_input_fp1616_t = i32;
pub const struct_xcb_input_fp1616_iterator_t = extern struct {
    data: [*c]xcb_input_fp1616_t = @import("std").mem.zeroes([*c]xcb_input_fp1616_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_fp1616_iterator_t = struct_xcb_input_fp1616_iterator_t;
pub const struct_xcb_input_fp3232_t = extern struct {
    integral: i32 = @import("std").mem.zeroes(i32),
    frac: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_fp3232_t = struct_xcb_input_fp3232_t;
pub const struct_xcb_input_fp3232_iterator_t = extern struct {
    data: [*c]xcb_input_fp3232_t = @import("std").mem.zeroes([*c]xcb_input_fp3232_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_fp3232_iterator_t = struct_xcb_input_fp3232_iterator_t;
pub const struct_xcb_input_get_extension_version_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_get_extension_version_cookie_t = struct_xcb_input_get_extension_version_cookie_t;
pub const struct_xcb_input_get_extension_version_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    name_len: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_get_extension_version_request_t = struct_xcb_input_get_extension_version_request_t;
pub const struct_xcb_input_get_extension_version_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    server_major: u16 = @import("std").mem.zeroes(u16),
    server_minor: u16 = @import("std").mem.zeroes(u16),
    present: u8 = @import("std").mem.zeroes(u8),
    pad0: [19]u8 = @import("std").mem.zeroes([19]u8),
};
pub const xcb_input_get_extension_version_reply_t = struct_xcb_input_get_extension_version_reply_t;
pub const XCB_INPUT_DEVICE_USE_IS_X_POINTER: c_int = 0;
pub const XCB_INPUT_DEVICE_USE_IS_X_KEYBOARD: c_int = 1;
pub const XCB_INPUT_DEVICE_USE_IS_X_EXTENSION_DEVICE: c_int = 2;
pub const XCB_INPUT_DEVICE_USE_IS_X_EXTENSION_KEYBOARD: c_int = 3;
pub const XCB_INPUT_DEVICE_USE_IS_X_EXTENSION_POINTER: c_int = 4;
pub const enum_xcb_input_device_use_t = c_uint;
pub const xcb_input_device_use_t = enum_xcb_input_device_use_t;
pub const XCB_INPUT_INPUT_CLASS_KEY: c_int = 0;
pub const XCB_INPUT_INPUT_CLASS_BUTTON: c_int = 1;
pub const XCB_INPUT_INPUT_CLASS_VALUATOR: c_int = 2;
pub const XCB_INPUT_INPUT_CLASS_FEEDBACK: c_int = 3;
pub const XCB_INPUT_INPUT_CLASS_PROXIMITY: c_int = 4;
pub const XCB_INPUT_INPUT_CLASS_FOCUS: c_int = 5;
pub const XCB_INPUT_INPUT_CLASS_OTHER: c_int = 6;
pub const enum_xcb_input_input_class_t = c_uint;
pub const xcb_input_input_class_t = enum_xcb_input_input_class_t;
pub const XCB_INPUT_VALUATOR_MODE_RELATIVE: c_int = 0;
pub const XCB_INPUT_VALUATOR_MODE_ABSOLUTE: c_int = 1;
pub const enum_xcb_input_valuator_mode_t = c_uint;
pub const xcb_input_valuator_mode_t = enum_xcb_input_valuator_mode_t;
pub const struct_xcb_input_device_info_t = extern struct {
    device_type: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    device_id: u8 = @import("std").mem.zeroes(u8),
    num_class_info: u8 = @import("std").mem.zeroes(u8),
    device_use: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_device_info_t = struct_xcb_input_device_info_t;
pub const struct_xcb_input_device_info_iterator_t = extern struct {
    data: [*c]xcb_input_device_info_t = @import("std").mem.zeroes([*c]xcb_input_device_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_info_iterator_t = struct_xcb_input_device_info_iterator_t;
pub const struct_xcb_input_key_info_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    len: u8 = @import("std").mem.zeroes(u8),
    min_keycode: xcb_input_key_code_t = @import("std").mem.zeroes(xcb_input_key_code_t),
    max_keycode: xcb_input_key_code_t = @import("std").mem.zeroes(xcb_input_key_code_t),
    num_keys: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_key_info_t = struct_xcb_input_key_info_t;
pub const struct_xcb_input_key_info_iterator_t = extern struct {
    data: [*c]xcb_input_key_info_t = @import("std").mem.zeroes([*c]xcb_input_key_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_key_info_iterator_t = struct_xcb_input_key_info_iterator_t;
pub const struct_xcb_input_button_info_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    len: u8 = @import("std").mem.zeroes(u8),
    num_buttons: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_button_info_t = struct_xcb_input_button_info_t;
pub const struct_xcb_input_button_info_iterator_t = extern struct {
    data: [*c]xcb_input_button_info_t = @import("std").mem.zeroes([*c]xcb_input_button_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_button_info_iterator_t = struct_xcb_input_button_info_iterator_t;
pub const struct_xcb_input_axis_info_t = extern struct {
    resolution: u32 = @import("std").mem.zeroes(u32),
    minimum: i32 = @import("std").mem.zeroes(i32),
    maximum: i32 = @import("std").mem.zeroes(i32),
};
pub const xcb_input_axis_info_t = struct_xcb_input_axis_info_t;
pub const struct_xcb_input_axis_info_iterator_t = extern struct {
    data: [*c]xcb_input_axis_info_t = @import("std").mem.zeroes([*c]xcb_input_axis_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_axis_info_iterator_t = struct_xcb_input_axis_info_iterator_t;
pub const struct_xcb_input_valuator_info_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    len: u8 = @import("std").mem.zeroes(u8),
    axes_len: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    motion_size: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_valuator_info_t = struct_xcb_input_valuator_info_t;
pub const struct_xcb_input_valuator_info_iterator_t = extern struct {
    data: [*c]xcb_input_valuator_info_t = @import("std").mem.zeroes([*c]xcb_input_valuator_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_valuator_info_iterator_t = struct_xcb_input_valuator_info_iterator_t;
const struct_unnamed_17 = extern struct {
    min_keycode: xcb_input_key_code_t = @import("std").mem.zeroes(xcb_input_key_code_t),
    max_keycode: xcb_input_key_code_t = @import("std").mem.zeroes(xcb_input_key_code_t),
    num_keys: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
const struct_unnamed_18 = extern struct {
    num_buttons: u16 = @import("std").mem.zeroes(u16),
};
const struct_unnamed_19 = extern struct {
    axes_len: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    motion_size: u32 = @import("std").mem.zeroes(u32),
    axes: [*c]xcb_input_axis_info_t = @import("std").mem.zeroes([*c]xcb_input_axis_info_t),
};
pub const struct_xcb_input_input_info_info_t = extern struct {
    key: struct_unnamed_17 = @import("std").mem.zeroes(struct_unnamed_17),
    button: struct_unnamed_18 = @import("std").mem.zeroes(struct_unnamed_18),
    valuator: struct_unnamed_19 = @import("std").mem.zeroes(struct_unnamed_19),
};
pub const xcb_input_input_info_info_t = struct_xcb_input_input_info_info_t;
pub const struct_xcb_input_input_info_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    len: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_input_info_t = struct_xcb_input_input_info_t;
pub extern fn xcb_input_input_info_info(R: [*c]const xcb_input_input_info_t) ?*anyopaque;
pub const struct_xcb_input_input_info_iterator_t = extern struct {
    data: [*c]xcb_input_input_info_t = @import("std").mem.zeroes([*c]xcb_input_input_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_input_info_iterator_t = struct_xcb_input_input_info_iterator_t;
pub const struct_xcb_input_device_name_t = extern struct {
    len: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_device_name_t = struct_xcb_input_device_name_t;
pub const struct_xcb_input_device_name_iterator_t = extern struct {
    data: [*c]xcb_input_device_name_t = @import("std").mem.zeroes([*c]xcb_input_device_name_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_name_iterator_t = struct_xcb_input_device_name_iterator_t;
pub const struct_xcb_input_list_input_devices_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_list_input_devices_cookie_t = struct_xcb_input_list_input_devices_cookie_t;
pub const struct_xcb_input_list_input_devices_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_list_input_devices_request_t = struct_xcb_input_list_input_devices_request_t;
pub const struct_xcb_input_list_input_devices_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    devices_len: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_list_input_devices_reply_t = struct_xcb_input_list_input_devices_reply_t;
pub const xcb_input_event_type_base_t = u8;
pub const struct_xcb_input_event_type_base_iterator_t = extern struct {
    data: [*c]xcb_input_event_type_base_t = @import("std").mem.zeroes([*c]xcb_input_event_type_base_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_event_type_base_iterator_t = struct_xcb_input_event_type_base_iterator_t;
pub const struct_xcb_input_input_class_info_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    event_type_base: xcb_input_event_type_base_t = @import("std").mem.zeroes(xcb_input_event_type_base_t),
};
pub const xcb_input_input_class_info_t = struct_xcb_input_input_class_info_t;
pub const struct_xcb_input_input_class_info_iterator_t = extern struct {
    data: [*c]xcb_input_input_class_info_t = @import("std").mem.zeroes([*c]xcb_input_input_class_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_input_class_info_iterator_t = struct_xcb_input_input_class_info_iterator_t;
pub const struct_xcb_input_open_device_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_open_device_cookie_t = struct_xcb_input_open_device_cookie_t;
pub const struct_xcb_input_open_device_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_open_device_request_t = struct_xcb_input_open_device_request_t;
pub const struct_xcb_input_open_device_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_classes: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_open_device_reply_t = struct_xcb_input_open_device_reply_t;
pub const struct_xcb_input_close_device_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_close_device_request_t = struct_xcb_input_close_device_request_t;
pub const struct_xcb_input_set_device_mode_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_set_device_mode_cookie_t = struct_xcb_input_set_device_mode_cookie_t;
pub const struct_xcb_input_set_device_mode_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_set_device_mode_request_t = struct_xcb_input_set_device_mode_request_t;
pub const struct_xcb_input_set_device_mode_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_set_device_mode_reply_t = struct_xcb_input_set_device_mode_reply_t;
pub const struct_xcb_input_select_extension_event_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    num_classes: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_select_extension_event_request_t = struct_xcb_input_select_extension_event_request_t;
pub const struct_xcb_input_get_selected_extension_events_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_get_selected_extension_events_cookie_t = struct_xcb_input_get_selected_extension_events_cookie_t;
pub const struct_xcb_input_get_selected_extension_events_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_input_get_selected_extension_events_request_t = struct_xcb_input_get_selected_extension_events_request_t;
pub const struct_xcb_input_get_selected_extension_events_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_this_classes: u16 = @import("std").mem.zeroes(u16),
    num_all_classes: u16 = @import("std").mem.zeroes(u16),
    pad0: [20]u8 = @import("std").mem.zeroes([20]u8),
};
pub const xcb_input_get_selected_extension_events_reply_t = struct_xcb_input_get_selected_extension_events_reply_t;
pub const XCB_INPUT_PROPAGATE_MODE_ADD_TO_LIST: c_int = 0;
pub const XCB_INPUT_PROPAGATE_MODE_DELETE_FROM_LIST: c_int = 1;
pub const enum_xcb_input_propagate_mode_t = c_uint;
pub const xcb_input_propagate_mode_t = enum_xcb_input_propagate_mode_t;
pub const struct_xcb_input_change_device_dont_propagate_list_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    num_classes: u16 = @import("std").mem.zeroes(u16),
    mode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_change_device_dont_propagate_list_request_t = struct_xcb_input_change_device_dont_propagate_list_request_t;
pub const struct_xcb_input_get_device_dont_propagate_list_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_get_device_dont_propagate_list_cookie_t = struct_xcb_input_get_device_dont_propagate_list_cookie_t;
pub const struct_xcb_input_get_device_dont_propagate_list_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_input_get_device_dont_propagate_list_request_t = struct_xcb_input_get_device_dont_propagate_list_request_t;
pub const struct_xcb_input_get_device_dont_propagate_list_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_classes: u16 = @import("std").mem.zeroes(u16),
    pad0: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_input_get_device_dont_propagate_list_reply_t = struct_xcb_input_get_device_dont_propagate_list_reply_t;
pub const struct_xcb_input_device_time_coord_t = extern struct {
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
};
pub const xcb_input_device_time_coord_t = struct_xcb_input_device_time_coord_t;
pub const struct_xcb_input_device_time_coord_iterator_t = extern struct {
    data: [*c]xcb_input_device_time_coord_t = @import("std").mem.zeroes([*c]xcb_input_device_time_coord_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
    num_axes: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_device_time_coord_iterator_t = struct_xcb_input_device_time_coord_iterator_t;
pub const struct_xcb_input_get_device_motion_events_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_get_device_motion_events_cookie_t = struct_xcb_input_get_device_motion_events_cookie_t;
pub const struct_xcb_input_get_device_motion_events_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    start: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    stop: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_get_device_motion_events_request_t = struct_xcb_input_get_device_motion_events_request_t;
pub const struct_xcb_input_get_device_motion_events_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_events: u32 = @import("std").mem.zeroes(u32),
    num_axes: u8 = @import("std").mem.zeroes(u8),
    device_mode: u8 = @import("std").mem.zeroes(u8),
    pad0: [18]u8 = @import("std").mem.zeroes([18]u8),
};
pub const xcb_input_get_device_motion_events_reply_t = struct_xcb_input_get_device_motion_events_reply_t;
pub const struct_xcb_input_change_keyboard_device_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_change_keyboard_device_cookie_t = struct_xcb_input_change_keyboard_device_cookie_t;
pub const struct_xcb_input_change_keyboard_device_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_change_keyboard_device_request_t = struct_xcb_input_change_keyboard_device_request_t;
pub const struct_xcb_input_change_keyboard_device_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_change_keyboard_device_reply_t = struct_xcb_input_change_keyboard_device_reply_t;
pub const struct_xcb_input_change_pointer_device_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_change_pointer_device_cookie_t = struct_xcb_input_change_pointer_device_cookie_t;
pub const struct_xcb_input_change_pointer_device_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    x_axis: u8 = @import("std").mem.zeroes(u8),
    y_axis: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_change_pointer_device_request_t = struct_xcb_input_change_pointer_device_request_t;
pub const struct_xcb_input_change_pointer_device_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_change_pointer_device_reply_t = struct_xcb_input_change_pointer_device_reply_t;
pub const struct_xcb_input_grab_device_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_grab_device_cookie_t = struct_xcb_input_grab_device_cookie_t;
pub const struct_xcb_input_grab_device_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    num_classes: u16 = @import("std").mem.zeroes(u16),
    this_device_mode: u8 = @import("std").mem.zeroes(u8),
    other_device_mode: u8 = @import("std").mem.zeroes(u8),
    owner_events: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_grab_device_request_t = struct_xcb_input_grab_device_request_t;
pub const struct_xcb_input_grab_device_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_grab_device_reply_t = struct_xcb_input_grab_device_reply_t;
pub const struct_xcb_input_ungrab_device_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_ungrab_device_request_t = struct_xcb_input_ungrab_device_request_t;
pub const XCB_INPUT_MODIFIER_DEVICE_USE_X_KEYBOARD: c_int = 255;
pub const enum_xcb_input_modifier_device_t = c_uint;
pub const xcb_input_modifier_device_t = enum_xcb_input_modifier_device_t;
pub const struct_xcb_input_grab_device_key_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    num_classes: u16 = @import("std").mem.zeroes(u16),
    modifiers: u16 = @import("std").mem.zeroes(u16),
    modifier_device: u8 = @import("std").mem.zeroes(u8),
    grabbed_device: u8 = @import("std").mem.zeroes(u8),
    key: u8 = @import("std").mem.zeroes(u8),
    this_device_mode: u8 = @import("std").mem.zeroes(u8),
    other_device_mode: u8 = @import("std").mem.zeroes(u8),
    owner_events: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_grab_device_key_request_t = struct_xcb_input_grab_device_key_request_t;
pub const struct_xcb_input_ungrab_device_key_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    grabWindow: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    modifiers: u16 = @import("std").mem.zeroes(u16),
    modifier_device: u8 = @import("std").mem.zeroes(u8),
    key: u8 = @import("std").mem.zeroes(u8),
    grabbed_device: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_ungrab_device_key_request_t = struct_xcb_input_ungrab_device_key_request_t;
pub const struct_xcb_input_grab_device_button_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    grabbed_device: u8 = @import("std").mem.zeroes(u8),
    modifier_device: u8 = @import("std").mem.zeroes(u8),
    num_classes: u16 = @import("std").mem.zeroes(u16),
    modifiers: u16 = @import("std").mem.zeroes(u16),
    this_device_mode: u8 = @import("std").mem.zeroes(u8),
    other_device_mode: u8 = @import("std").mem.zeroes(u8),
    button: u8 = @import("std").mem.zeroes(u8),
    owner_events: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_grab_device_button_request_t = struct_xcb_input_grab_device_button_request_t;
pub const struct_xcb_input_ungrab_device_button_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    modifiers: u16 = @import("std").mem.zeroes(u16),
    modifier_device: u8 = @import("std").mem.zeroes(u8),
    button: u8 = @import("std").mem.zeroes(u8),
    grabbed_device: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_ungrab_device_button_request_t = struct_xcb_input_ungrab_device_button_request_t;
pub const XCB_INPUT_DEVICE_INPUT_MODE_ASYNC_THIS_DEVICE: c_int = 0;
pub const XCB_INPUT_DEVICE_INPUT_MODE_SYNC_THIS_DEVICE: c_int = 1;
pub const XCB_INPUT_DEVICE_INPUT_MODE_REPLAY_THIS_DEVICE: c_int = 2;
pub const XCB_INPUT_DEVICE_INPUT_MODE_ASYNC_OTHER_DEVICES: c_int = 3;
pub const XCB_INPUT_DEVICE_INPUT_MODE_ASYNC_ALL: c_int = 4;
pub const XCB_INPUT_DEVICE_INPUT_MODE_SYNC_ALL: c_int = 5;
pub const enum_xcb_input_device_input_mode_t = c_uint;
pub const xcb_input_device_input_mode_t = enum_xcb_input_device_input_mode_t;
pub const struct_xcb_input_allow_device_events_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    mode: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_allow_device_events_request_t = struct_xcb_input_allow_device_events_request_t;
pub const struct_xcb_input_get_device_focus_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_get_device_focus_cookie_t = struct_xcb_input_get_device_focus_cookie_t;
pub const struct_xcb_input_get_device_focus_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_get_device_focus_request_t = struct_xcb_input_get_device_focus_request_t;
pub const struct_xcb_input_get_device_focus_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    focus: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    revert_to: u8 = @import("std").mem.zeroes(u8),
    pad0: [15]u8 = @import("std").mem.zeroes([15]u8),
};
pub const xcb_input_get_device_focus_reply_t = struct_xcb_input_get_device_focus_reply_t;
pub const struct_xcb_input_set_device_focus_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    focus: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    revert_to: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_set_device_focus_request_t = struct_xcb_input_set_device_focus_request_t;
pub const XCB_INPUT_FEEDBACK_CLASS_KEYBOARD: c_int = 0;
pub const XCB_INPUT_FEEDBACK_CLASS_POINTER: c_int = 1;
pub const XCB_INPUT_FEEDBACK_CLASS_STRING: c_int = 2;
pub const XCB_INPUT_FEEDBACK_CLASS_INTEGER: c_int = 3;
pub const XCB_INPUT_FEEDBACK_CLASS_LED: c_int = 4;
pub const XCB_INPUT_FEEDBACK_CLASS_BELL: c_int = 5;
pub const enum_xcb_input_feedback_class_t = c_uint;
pub const xcb_input_feedback_class_t = enum_xcb_input_feedback_class_t;
pub const struct_xcb_input_kbd_feedback_state_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    pitch: u16 = @import("std").mem.zeroes(u16),
    duration: u16 = @import("std").mem.zeroes(u16),
    led_mask: u32 = @import("std").mem.zeroes(u32),
    led_values: u32 = @import("std").mem.zeroes(u32),
    global_auto_repeat: u8 = @import("std").mem.zeroes(u8),
    click: u8 = @import("std").mem.zeroes(u8),
    percent: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    auto_repeats: [32]u8 = @import("std").mem.zeroes([32]u8),
};
pub const xcb_input_kbd_feedback_state_t = struct_xcb_input_kbd_feedback_state_t;
pub const struct_xcb_input_kbd_feedback_state_iterator_t = extern struct {
    data: [*c]xcb_input_kbd_feedback_state_t = @import("std").mem.zeroes([*c]xcb_input_kbd_feedback_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_kbd_feedback_state_iterator_t = struct_xcb_input_kbd_feedback_state_iterator_t;
pub const struct_xcb_input_ptr_feedback_state_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    accel_num: u16 = @import("std").mem.zeroes(u16),
    accel_denom: u16 = @import("std").mem.zeroes(u16),
    threshold: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_ptr_feedback_state_t = struct_xcb_input_ptr_feedback_state_t;
pub const struct_xcb_input_ptr_feedback_state_iterator_t = extern struct {
    data: [*c]xcb_input_ptr_feedback_state_t = @import("std").mem.zeroes([*c]xcb_input_ptr_feedback_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_ptr_feedback_state_iterator_t = struct_xcb_input_ptr_feedback_state_iterator_t;
pub const struct_xcb_input_integer_feedback_state_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    resolution: u32 = @import("std").mem.zeroes(u32),
    min_value: i32 = @import("std").mem.zeroes(i32),
    max_value: i32 = @import("std").mem.zeroes(i32),
};
pub const xcb_input_integer_feedback_state_t = struct_xcb_input_integer_feedback_state_t;
pub const struct_xcb_input_integer_feedback_state_iterator_t = extern struct {
    data: [*c]xcb_input_integer_feedback_state_t = @import("std").mem.zeroes([*c]xcb_input_integer_feedback_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_integer_feedback_state_iterator_t = struct_xcb_input_integer_feedback_state_iterator_t;
pub const struct_xcb_input_string_feedback_state_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    max_symbols: u16 = @import("std").mem.zeroes(u16),
    num_keysyms: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_string_feedback_state_t = struct_xcb_input_string_feedback_state_t;
pub const struct_xcb_input_string_feedback_state_iterator_t = extern struct {
    data: [*c]xcb_input_string_feedback_state_t = @import("std").mem.zeroes([*c]xcb_input_string_feedback_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_string_feedback_state_iterator_t = struct_xcb_input_string_feedback_state_iterator_t;
pub const struct_xcb_input_bell_feedback_state_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    percent: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    pitch: u16 = @import("std").mem.zeroes(u16),
    duration: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_bell_feedback_state_t = struct_xcb_input_bell_feedback_state_t;
pub const struct_xcb_input_bell_feedback_state_iterator_t = extern struct {
    data: [*c]xcb_input_bell_feedback_state_t = @import("std").mem.zeroes([*c]xcb_input_bell_feedback_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_bell_feedback_state_iterator_t = struct_xcb_input_bell_feedback_state_iterator_t;
pub const struct_xcb_input_led_feedback_state_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    led_mask: u32 = @import("std").mem.zeroes(u32),
    led_values: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_led_feedback_state_t = struct_xcb_input_led_feedback_state_t;
pub const struct_xcb_input_led_feedback_state_iterator_t = extern struct {
    data: [*c]xcb_input_led_feedback_state_t = @import("std").mem.zeroes([*c]xcb_input_led_feedback_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_led_feedback_state_iterator_t = struct_xcb_input_led_feedback_state_iterator_t;
const struct_unnamed_20 = extern struct {
    pitch: u16 = @import("std").mem.zeroes(u16),
    duration: u16 = @import("std").mem.zeroes(u16),
    led_mask: u32 = @import("std").mem.zeroes(u32),
    led_values: u32 = @import("std").mem.zeroes(u32),
    global_auto_repeat: u8 = @import("std").mem.zeroes(u8),
    click: u8 = @import("std").mem.zeroes(u8),
    percent: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    auto_repeats: [32]u8 = @import("std").mem.zeroes([32]u8),
};
const struct_unnamed_21 = extern struct {
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
    accel_num: u16 = @import("std").mem.zeroes(u16),
    accel_denom: u16 = @import("std").mem.zeroes(u16),
    threshold: u16 = @import("std").mem.zeroes(u16),
};
const struct_unnamed_22 = extern struct {
    max_symbols: u16 = @import("std").mem.zeroes(u16),
    num_keysyms: u16 = @import("std").mem.zeroes(u16),
    keysyms: [*c]xcb_keysym_t = @import("std").mem.zeroes([*c]xcb_keysym_t),
};
const struct_unnamed_23 = extern struct {
    resolution: u32 = @import("std").mem.zeroes(u32),
    min_value: i32 = @import("std").mem.zeroes(i32),
    max_value: i32 = @import("std").mem.zeroes(i32),
};
const struct_unnamed_24 = extern struct {
    led_mask: u32 = @import("std").mem.zeroes(u32),
    led_values: u32 = @import("std").mem.zeroes(u32),
};
const struct_unnamed_25 = extern struct {
    percent: u8 = @import("std").mem.zeroes(u8),
    pad2: [3]u8 = @import("std").mem.zeroes([3]u8),
    pitch: u16 = @import("std").mem.zeroes(u16),
    duration: u16 = @import("std").mem.zeroes(u16),
};
pub const struct_xcb_input_feedback_state_data_t = extern struct {
    keyboard: struct_unnamed_20 = @import("std").mem.zeroes(struct_unnamed_20),
    pointer: struct_unnamed_21 = @import("std").mem.zeroes(struct_unnamed_21),
    string: struct_unnamed_22 = @import("std").mem.zeroes(struct_unnamed_22),
    integer: struct_unnamed_23 = @import("std").mem.zeroes(struct_unnamed_23),
    led: struct_unnamed_24 = @import("std").mem.zeroes(struct_unnamed_24),
    bell: struct_unnamed_25 = @import("std").mem.zeroes(struct_unnamed_25),
};
pub const xcb_input_feedback_state_data_t = struct_xcb_input_feedback_state_data_t;
pub const struct_xcb_input_feedback_state_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_feedback_state_t = struct_xcb_input_feedback_state_t;
pub extern fn xcb_input_feedback_state_data(R: [*c]const xcb_input_feedback_state_t) ?*anyopaque;
pub const struct_xcb_input_feedback_state_iterator_t = extern struct {
    data: [*c]xcb_input_feedback_state_t = @import("std").mem.zeroes([*c]xcb_input_feedback_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_feedback_state_iterator_t = struct_xcb_input_feedback_state_iterator_t;
pub const struct_xcb_input_get_feedback_control_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_get_feedback_control_cookie_t = struct_xcb_input_get_feedback_control_cookie_t;
pub const struct_xcb_input_get_feedback_control_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_get_feedback_control_request_t = struct_xcb_input_get_feedback_control_request_t;
pub const struct_xcb_input_get_feedback_control_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_feedbacks: u16 = @import("std").mem.zeroes(u16),
    pad0: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_input_get_feedback_control_reply_t = struct_xcb_input_get_feedback_control_reply_t;
pub const struct_xcb_input_kbd_feedback_ctl_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    key: xcb_input_key_code_t = @import("std").mem.zeroes(xcb_input_key_code_t),
    auto_repeat_mode: u8 = @import("std").mem.zeroes(u8),
    key_click_percent: i8 = @import("std").mem.zeroes(i8),
    bell_percent: i8 = @import("std").mem.zeroes(i8),
    bell_pitch: i16 = @import("std").mem.zeroes(i16),
    bell_duration: i16 = @import("std").mem.zeroes(i16),
    led_mask: u32 = @import("std").mem.zeroes(u32),
    led_values: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_kbd_feedback_ctl_t = struct_xcb_input_kbd_feedback_ctl_t;
pub const struct_xcb_input_kbd_feedback_ctl_iterator_t = extern struct {
    data: [*c]xcb_input_kbd_feedback_ctl_t = @import("std").mem.zeroes([*c]xcb_input_kbd_feedback_ctl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_kbd_feedback_ctl_iterator_t = struct_xcb_input_kbd_feedback_ctl_iterator_t;
pub const struct_xcb_input_ptr_feedback_ctl_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    num: i16 = @import("std").mem.zeroes(i16),
    denom: i16 = @import("std").mem.zeroes(i16),
    threshold: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_input_ptr_feedback_ctl_t = struct_xcb_input_ptr_feedback_ctl_t;
pub const struct_xcb_input_ptr_feedback_ctl_iterator_t = extern struct {
    data: [*c]xcb_input_ptr_feedback_ctl_t = @import("std").mem.zeroes([*c]xcb_input_ptr_feedback_ctl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_ptr_feedback_ctl_iterator_t = struct_xcb_input_ptr_feedback_ctl_iterator_t;
pub const struct_xcb_input_integer_feedback_ctl_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    int_to_display: i32 = @import("std").mem.zeroes(i32),
};
pub const xcb_input_integer_feedback_ctl_t = struct_xcb_input_integer_feedback_ctl_t;
pub const struct_xcb_input_integer_feedback_ctl_iterator_t = extern struct {
    data: [*c]xcb_input_integer_feedback_ctl_t = @import("std").mem.zeroes([*c]xcb_input_integer_feedback_ctl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_integer_feedback_ctl_iterator_t = struct_xcb_input_integer_feedback_ctl_iterator_t;
pub const struct_xcb_input_string_feedback_ctl_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    num_keysyms: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_string_feedback_ctl_t = struct_xcb_input_string_feedback_ctl_t;
pub const struct_xcb_input_string_feedback_ctl_iterator_t = extern struct {
    data: [*c]xcb_input_string_feedback_ctl_t = @import("std").mem.zeroes([*c]xcb_input_string_feedback_ctl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_string_feedback_ctl_iterator_t = struct_xcb_input_string_feedback_ctl_iterator_t;
pub const struct_xcb_input_bell_feedback_ctl_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    percent: i8 = @import("std").mem.zeroes(i8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
    pitch: i16 = @import("std").mem.zeroes(i16),
    duration: i16 = @import("std").mem.zeroes(i16),
};
pub const xcb_input_bell_feedback_ctl_t = struct_xcb_input_bell_feedback_ctl_t;
pub const struct_xcb_input_bell_feedback_ctl_iterator_t = extern struct {
    data: [*c]xcb_input_bell_feedback_ctl_t = @import("std").mem.zeroes([*c]xcb_input_bell_feedback_ctl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_bell_feedback_ctl_iterator_t = struct_xcb_input_bell_feedback_ctl_iterator_t;
pub const struct_xcb_input_led_feedback_ctl_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
    led_mask: u32 = @import("std").mem.zeroes(u32),
    led_values: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_led_feedback_ctl_t = struct_xcb_input_led_feedback_ctl_t;
pub const struct_xcb_input_led_feedback_ctl_iterator_t = extern struct {
    data: [*c]xcb_input_led_feedback_ctl_t = @import("std").mem.zeroes([*c]xcb_input_led_feedback_ctl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_led_feedback_ctl_iterator_t = struct_xcb_input_led_feedback_ctl_iterator_t;
const struct_unnamed_26 = extern struct {
    key: xcb_input_key_code_t = @import("std").mem.zeroes(xcb_input_key_code_t),
    auto_repeat_mode: u8 = @import("std").mem.zeroes(u8),
    key_click_percent: i8 = @import("std").mem.zeroes(i8),
    bell_percent: i8 = @import("std").mem.zeroes(i8),
    bell_pitch: i16 = @import("std").mem.zeroes(i16),
    bell_duration: i16 = @import("std").mem.zeroes(i16),
    led_mask: u32 = @import("std").mem.zeroes(u32),
    led_values: u32 = @import("std").mem.zeroes(u32),
};
const struct_unnamed_27 = extern struct {
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    num: i16 = @import("std").mem.zeroes(i16),
    denom: i16 = @import("std").mem.zeroes(i16),
    threshold: i16 = @import("std").mem.zeroes(i16),
};
const struct_unnamed_28 = extern struct {
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
    num_keysyms: u16 = @import("std").mem.zeroes(u16),
    keysyms: [*c]xcb_keysym_t = @import("std").mem.zeroes([*c]xcb_keysym_t),
};
const struct_unnamed_29 = extern struct {
    int_to_display: i32 = @import("std").mem.zeroes(i32),
};
const struct_unnamed_30 = extern struct {
    led_mask: u32 = @import("std").mem.zeroes(u32),
    led_values: u32 = @import("std").mem.zeroes(u32),
};
const struct_unnamed_31 = extern struct {
    percent: i8 = @import("std").mem.zeroes(i8),
    pad2: [3]u8 = @import("std").mem.zeroes([3]u8),
    pitch: i16 = @import("std").mem.zeroes(i16),
    duration: i16 = @import("std").mem.zeroes(i16),
};
pub const struct_xcb_input_feedback_ctl_data_t = extern struct {
    keyboard: struct_unnamed_26 = @import("std").mem.zeroes(struct_unnamed_26),
    pointer: struct_unnamed_27 = @import("std").mem.zeroes(struct_unnamed_27),
    string: struct_unnamed_28 = @import("std").mem.zeroes(struct_unnamed_28),
    integer: struct_unnamed_29 = @import("std").mem.zeroes(struct_unnamed_29),
    led: struct_unnamed_30 = @import("std").mem.zeroes(struct_unnamed_30),
    bell: struct_unnamed_31 = @import("std").mem.zeroes(struct_unnamed_31),
};
pub const xcb_input_feedback_ctl_data_t = struct_xcb_input_feedback_ctl_data_t;
pub const struct_xcb_input_feedback_ctl_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_feedback_ctl_t = struct_xcb_input_feedback_ctl_t;
pub extern fn xcb_input_feedback_ctl_data(R: [*c]const xcb_input_feedback_ctl_t) ?*anyopaque;
pub const struct_xcb_input_feedback_ctl_iterator_t = extern struct {
    data: [*c]xcb_input_feedback_ctl_t = @import("std").mem.zeroes([*c]xcb_input_feedback_ctl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_feedback_ctl_iterator_t = struct_xcb_input_feedback_ctl_iterator_t;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_KEY_CLICK_PERCENT: c_int = 1;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_PERCENT: c_int = 2;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_PITCH: c_int = 4;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_DURATION: c_int = 8;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_LED: c_int = 16;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_LED_MODE: c_int = 32;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_KEY: c_int = 64;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_AUTO_REPEAT_MODE: c_int = 128;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_STRING: c_int = 1;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_INTEGER: c_int = 1;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_ACCEL_NUM: c_int = 1;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_ACCEL_DENOM: c_int = 2;
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL_MASK_THRESHOLD: c_int = 4;
pub const enum_xcb_input_change_feedback_control_mask_t = c_uint;
pub const xcb_input_change_feedback_control_mask_t = enum_xcb_input_change_feedback_control_mask_t;
pub const struct_xcb_input_change_feedback_control_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    mask: u32 = @import("std").mem.zeroes(u32),
    device_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_change_feedback_control_request_t = struct_xcb_input_change_feedback_control_request_t;
pub const struct_xcb_input_get_device_key_mapping_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_get_device_key_mapping_cookie_t = struct_xcb_input_get_device_key_mapping_cookie_t;
pub const struct_xcb_input_get_device_key_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    first_keycode: xcb_input_key_code_t = @import("std").mem.zeroes(xcb_input_key_code_t),
    count: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_get_device_key_mapping_request_t = struct_xcb_input_get_device_key_mapping_request_t;
pub const struct_xcb_input_get_device_key_mapping_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    keysyms_per_keycode: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_get_device_key_mapping_reply_t = struct_xcb_input_get_device_key_mapping_reply_t;
pub const struct_xcb_input_change_device_key_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    first_keycode: xcb_input_key_code_t = @import("std").mem.zeroes(xcb_input_key_code_t),
    keysyms_per_keycode: u8 = @import("std").mem.zeroes(u8),
    keycode_count: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_change_device_key_mapping_request_t = struct_xcb_input_change_device_key_mapping_request_t;
pub const struct_xcb_input_get_device_modifier_mapping_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_get_device_modifier_mapping_cookie_t = struct_xcb_input_get_device_modifier_mapping_cookie_t;
pub const struct_xcb_input_get_device_modifier_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_get_device_modifier_mapping_request_t = struct_xcb_input_get_device_modifier_mapping_request_t;
pub const struct_xcb_input_get_device_modifier_mapping_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    keycodes_per_modifier: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_get_device_modifier_mapping_reply_t = struct_xcb_input_get_device_modifier_mapping_reply_t;
pub const struct_xcb_input_set_device_modifier_mapping_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_set_device_modifier_mapping_cookie_t = struct_xcb_input_set_device_modifier_mapping_cookie_t;
pub const struct_xcb_input_set_device_modifier_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    keycodes_per_modifier: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_set_device_modifier_mapping_request_t = struct_xcb_input_set_device_modifier_mapping_request_t;
pub const struct_xcb_input_set_device_modifier_mapping_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_set_device_modifier_mapping_reply_t = struct_xcb_input_set_device_modifier_mapping_reply_t;
pub const struct_xcb_input_get_device_button_mapping_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_get_device_button_mapping_cookie_t = struct_xcb_input_get_device_button_mapping_cookie_t;
pub const struct_xcb_input_get_device_button_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_get_device_button_mapping_request_t = struct_xcb_input_get_device_button_mapping_request_t;
pub const struct_xcb_input_get_device_button_mapping_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    map_size: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_get_device_button_mapping_reply_t = struct_xcb_input_get_device_button_mapping_reply_t;
pub const struct_xcb_input_set_device_button_mapping_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_set_device_button_mapping_cookie_t = struct_xcb_input_set_device_button_mapping_cookie_t;
pub const struct_xcb_input_set_device_button_mapping_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    map_size: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_set_device_button_mapping_request_t = struct_xcb_input_set_device_button_mapping_request_t;
pub const struct_xcb_input_set_device_button_mapping_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_set_device_button_mapping_reply_t = struct_xcb_input_set_device_button_mapping_reply_t;
pub const struct_xcb_input_key_state_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    len: u8 = @import("std").mem.zeroes(u8),
    num_keys: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    keys: [32]u8 = @import("std").mem.zeroes([32]u8),
};
pub const xcb_input_key_state_t = struct_xcb_input_key_state_t;
pub const struct_xcb_input_key_state_iterator_t = extern struct {
    data: [*c]xcb_input_key_state_t = @import("std").mem.zeroes([*c]xcb_input_key_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_key_state_iterator_t = struct_xcb_input_key_state_iterator_t;
pub const struct_xcb_input_button_state_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    len: u8 = @import("std").mem.zeroes(u8),
    num_buttons: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    buttons: [32]u8 = @import("std").mem.zeroes([32]u8),
};
pub const xcb_input_button_state_t = struct_xcb_input_button_state_t;
pub const struct_xcb_input_button_state_iterator_t = extern struct {
    data: [*c]xcb_input_button_state_t = @import("std").mem.zeroes([*c]xcb_input_button_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_button_state_iterator_t = struct_xcb_input_button_state_iterator_t;
pub const XCB_INPUT_VALUATOR_STATE_MODE_MASK_DEVICE_MODE_ABSOLUTE: c_int = 1;
pub const XCB_INPUT_VALUATOR_STATE_MODE_MASK_OUT_OF_PROXIMITY: c_int = 2;
pub const enum_xcb_input_valuator_state_mode_mask_t = c_uint;
pub const xcb_input_valuator_state_mode_mask_t = enum_xcb_input_valuator_state_mode_mask_t;
pub const struct_xcb_input_valuator_state_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    len: u8 = @import("std").mem.zeroes(u8),
    num_valuators: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_valuator_state_t = struct_xcb_input_valuator_state_t;
pub const struct_xcb_input_valuator_state_iterator_t = extern struct {
    data: [*c]xcb_input_valuator_state_t = @import("std").mem.zeroes([*c]xcb_input_valuator_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_valuator_state_iterator_t = struct_xcb_input_valuator_state_iterator_t;
const struct_unnamed_32 = extern struct {
    num_keys: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    keys: [32]u8 = @import("std").mem.zeroes([32]u8),
};
const struct_unnamed_33 = extern struct {
    num_buttons: u8 = @import("std").mem.zeroes(u8),
    pad1: u8 = @import("std").mem.zeroes(u8),
    buttons: [32]u8 = @import("std").mem.zeroes([32]u8),
};
const struct_unnamed_34 = extern struct {
    num_valuators: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    valuators: [*c]i32 = @import("std").mem.zeroes([*c]i32),
};
pub const struct_xcb_input_input_state_data_t = extern struct {
    key: struct_unnamed_32 = @import("std").mem.zeroes(struct_unnamed_32),
    button: struct_unnamed_33 = @import("std").mem.zeroes(struct_unnamed_33),
    valuator: struct_unnamed_34 = @import("std").mem.zeroes(struct_unnamed_34),
};
pub const xcb_input_input_state_data_t = struct_xcb_input_input_state_data_t;
pub const struct_xcb_input_input_state_t = extern struct {
    class_id: u8 = @import("std").mem.zeroes(u8),
    len: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_input_state_t = struct_xcb_input_input_state_t;
pub extern fn xcb_input_input_state_data(R: [*c]const xcb_input_input_state_t) ?*anyopaque;
pub const struct_xcb_input_input_state_iterator_t = extern struct {
    data: [*c]xcb_input_input_state_t = @import("std").mem.zeroes([*c]xcb_input_input_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_input_state_iterator_t = struct_xcb_input_input_state_iterator_t;
pub const struct_xcb_input_query_device_state_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_query_device_state_cookie_t = struct_xcb_input_query_device_state_cookie_t;
pub const struct_xcb_input_query_device_state_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_query_device_state_request_t = struct_xcb_input_query_device_state_request_t;
pub const struct_xcb_input_query_device_state_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_classes: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_query_device_state_reply_t = struct_xcb_input_query_device_state_reply_t;
pub const struct_xcb_input_device_bell_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    feedback_id: u8 = @import("std").mem.zeroes(u8),
    feedback_class: u8 = @import("std").mem.zeroes(u8),
    percent: i8 = @import("std").mem.zeroes(i8),
};
pub const xcb_input_device_bell_request_t = struct_xcb_input_device_bell_request_t;
pub const struct_xcb_input_set_device_valuators_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_set_device_valuators_cookie_t = struct_xcb_input_set_device_valuators_cookie_t;
pub const struct_xcb_input_set_device_valuators_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    first_valuator: u8 = @import("std").mem.zeroes(u8),
    num_valuators: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_set_device_valuators_request_t = struct_xcb_input_set_device_valuators_request_t;
pub const struct_xcb_input_set_device_valuators_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_set_device_valuators_reply_t = struct_xcb_input_set_device_valuators_reply_t;
pub const XCB_INPUT_DEVICE_CONTROL_RESOLUTION: c_int = 1;
pub const XCB_INPUT_DEVICE_CONTROL_ABS_CALIB: c_int = 2;
pub const XCB_INPUT_DEVICE_CONTROL_CORE: c_int = 3;
pub const XCB_INPUT_DEVICE_CONTROL_ENABLE: c_int = 4;
pub const XCB_INPUT_DEVICE_CONTROL_ABS_AREA: c_int = 5;
pub const enum_xcb_input_device_control_t = c_uint;
pub const xcb_input_device_control_t = enum_xcb_input_device_control_t;
pub const struct_xcb_input_device_resolution_state_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    num_valuators: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_device_resolution_state_t = struct_xcb_input_device_resolution_state_t;
pub const struct_xcb_input_device_resolution_state_iterator_t = extern struct {
    data: [*c]xcb_input_device_resolution_state_t = @import("std").mem.zeroes([*c]xcb_input_device_resolution_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_resolution_state_iterator_t = struct_xcb_input_device_resolution_state_iterator_t;
pub const struct_xcb_input_device_abs_calib_state_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    min_x: i32 = @import("std").mem.zeroes(i32),
    max_x: i32 = @import("std").mem.zeroes(i32),
    min_y: i32 = @import("std").mem.zeroes(i32),
    max_y: i32 = @import("std").mem.zeroes(i32),
    flip_x: u32 = @import("std").mem.zeroes(u32),
    flip_y: u32 = @import("std").mem.zeroes(u32),
    rotation: u32 = @import("std").mem.zeroes(u32),
    button_threshold: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_device_abs_calib_state_t = struct_xcb_input_device_abs_calib_state_t;
pub const struct_xcb_input_device_abs_calib_state_iterator_t = extern struct {
    data: [*c]xcb_input_device_abs_calib_state_t = @import("std").mem.zeroes([*c]xcb_input_device_abs_calib_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_abs_calib_state_iterator_t = struct_xcb_input_device_abs_calib_state_iterator_t;
pub const struct_xcb_input_device_abs_area_state_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    offset_x: u32 = @import("std").mem.zeroes(u32),
    offset_y: u32 = @import("std").mem.zeroes(u32),
    width: u32 = @import("std").mem.zeroes(u32),
    height: u32 = @import("std").mem.zeroes(u32),
    screen: u32 = @import("std").mem.zeroes(u32),
    following: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_device_abs_area_state_t = struct_xcb_input_device_abs_area_state_t;
pub const struct_xcb_input_device_abs_area_state_iterator_t = extern struct {
    data: [*c]xcb_input_device_abs_area_state_t = @import("std").mem.zeroes([*c]xcb_input_device_abs_area_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_abs_area_state_iterator_t = struct_xcb_input_device_abs_area_state_iterator_t;
pub const struct_xcb_input_device_core_state_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    status: u8 = @import("std").mem.zeroes(u8),
    iscore: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_device_core_state_t = struct_xcb_input_device_core_state_t;
pub const struct_xcb_input_device_core_state_iterator_t = extern struct {
    data: [*c]xcb_input_device_core_state_t = @import("std").mem.zeroes([*c]xcb_input_device_core_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_core_state_iterator_t = struct_xcb_input_device_core_state_iterator_t;
pub const struct_xcb_input_device_enable_state_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    enable: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_device_enable_state_t = struct_xcb_input_device_enable_state_t;
pub const struct_xcb_input_device_enable_state_iterator_t = extern struct {
    data: [*c]xcb_input_device_enable_state_t = @import("std").mem.zeroes([*c]xcb_input_device_enable_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_enable_state_iterator_t = struct_xcb_input_device_enable_state_iterator_t;
const struct_unnamed_35 = extern struct {
    num_valuators: u32 = @import("std").mem.zeroes(u32),
    resolution_values: [*c]u32 = @import("std").mem.zeroes([*c]u32),
    resolution_min: [*c]u32 = @import("std").mem.zeroes([*c]u32),
    resolution_max: [*c]u32 = @import("std").mem.zeroes([*c]u32),
};
const struct_unnamed_36 = extern struct {
    min_x: i32 = @import("std").mem.zeroes(i32),
    max_x: i32 = @import("std").mem.zeroes(i32),
    min_y: i32 = @import("std").mem.zeroes(i32),
    max_y: i32 = @import("std").mem.zeroes(i32),
    flip_x: u32 = @import("std").mem.zeroes(u32),
    flip_y: u32 = @import("std").mem.zeroes(u32),
    rotation: u32 = @import("std").mem.zeroes(u32),
    button_threshold: u32 = @import("std").mem.zeroes(u32),
};
const struct_unnamed_37 = extern struct {
    status: u8 = @import("std").mem.zeroes(u8),
    iscore: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
const struct_unnamed_38 = extern struct {
    enable: u8 = @import("std").mem.zeroes(u8),
    pad1: [3]u8 = @import("std").mem.zeroes([3]u8),
};
const struct_unnamed_39 = extern struct {
    offset_x: u32 = @import("std").mem.zeroes(u32),
    offset_y: u32 = @import("std").mem.zeroes(u32),
    width: u32 = @import("std").mem.zeroes(u32),
    height: u32 = @import("std").mem.zeroes(u32),
    screen: u32 = @import("std").mem.zeroes(u32),
    following: u32 = @import("std").mem.zeroes(u32),
};
pub const struct_xcb_input_device_state_data_t = extern struct {
    resolution: struct_unnamed_35 = @import("std").mem.zeroes(struct_unnamed_35),
    abs_calib: struct_unnamed_36 = @import("std").mem.zeroes(struct_unnamed_36),
    core: struct_unnamed_37 = @import("std").mem.zeroes(struct_unnamed_37),
    enable: struct_unnamed_38 = @import("std").mem.zeroes(struct_unnamed_38),
    abs_area: struct_unnamed_39 = @import("std").mem.zeroes(struct_unnamed_39),
};
pub const xcb_input_device_state_data_t = struct_xcb_input_device_state_data_t;
pub const struct_xcb_input_device_state_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_device_state_t = struct_xcb_input_device_state_t;
pub extern fn xcb_input_device_state_data(R: [*c]const xcb_input_device_state_t) ?*anyopaque;
pub const struct_xcb_input_device_state_iterator_t = extern struct {
    data: [*c]xcb_input_device_state_t = @import("std").mem.zeroes([*c]xcb_input_device_state_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_state_iterator_t = struct_xcb_input_device_state_iterator_t;
pub const struct_xcb_input_get_device_control_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_get_device_control_cookie_t = struct_xcb_input_get_device_control_cookie_t;
pub const struct_xcb_input_get_device_control_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    control_id: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_get_device_control_request_t = struct_xcb_input_get_device_control_request_t;
pub const struct_xcb_input_get_device_control_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_get_device_control_reply_t = struct_xcb_input_get_device_control_reply_t;
pub const struct_xcb_input_device_resolution_ctl_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    first_valuator: u8 = @import("std").mem.zeroes(u8),
    num_valuators: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_device_resolution_ctl_t = struct_xcb_input_device_resolution_ctl_t;
pub const struct_xcb_input_device_resolution_ctl_iterator_t = extern struct {
    data: [*c]xcb_input_device_resolution_ctl_t = @import("std").mem.zeroes([*c]xcb_input_device_resolution_ctl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_resolution_ctl_iterator_t = struct_xcb_input_device_resolution_ctl_iterator_t;
pub const struct_xcb_input_device_abs_calib_ctl_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    min_x: i32 = @import("std").mem.zeroes(i32),
    max_x: i32 = @import("std").mem.zeroes(i32),
    min_y: i32 = @import("std").mem.zeroes(i32),
    max_y: i32 = @import("std").mem.zeroes(i32),
    flip_x: u32 = @import("std").mem.zeroes(u32),
    flip_y: u32 = @import("std").mem.zeroes(u32),
    rotation: u32 = @import("std").mem.zeroes(u32),
    button_threshold: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_device_abs_calib_ctl_t = struct_xcb_input_device_abs_calib_ctl_t;
pub const struct_xcb_input_device_abs_calib_ctl_iterator_t = extern struct {
    data: [*c]xcb_input_device_abs_calib_ctl_t = @import("std").mem.zeroes([*c]xcb_input_device_abs_calib_ctl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_abs_calib_ctl_iterator_t = struct_xcb_input_device_abs_calib_ctl_iterator_t;
pub const struct_xcb_input_device_abs_area_ctrl_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    offset_x: u32 = @import("std").mem.zeroes(u32),
    offset_y: u32 = @import("std").mem.zeroes(u32),
    width: i32 = @import("std").mem.zeroes(i32),
    height: i32 = @import("std").mem.zeroes(i32),
    screen: i32 = @import("std").mem.zeroes(i32),
    following: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_device_abs_area_ctrl_t = struct_xcb_input_device_abs_area_ctrl_t;
pub const struct_xcb_input_device_abs_area_ctrl_iterator_t = extern struct {
    data: [*c]xcb_input_device_abs_area_ctrl_t = @import("std").mem.zeroes([*c]xcb_input_device_abs_area_ctrl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_abs_area_ctrl_iterator_t = struct_xcb_input_device_abs_area_ctrl_iterator_t;
pub const struct_xcb_input_device_core_ctrl_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_device_core_ctrl_t = struct_xcb_input_device_core_ctrl_t;
pub const struct_xcb_input_device_core_ctrl_iterator_t = extern struct {
    data: [*c]xcb_input_device_core_ctrl_t = @import("std").mem.zeroes([*c]xcb_input_device_core_ctrl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_core_ctrl_iterator_t = struct_xcb_input_device_core_ctrl_iterator_t;
pub const struct_xcb_input_device_enable_ctrl_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    enable: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_device_enable_ctrl_t = struct_xcb_input_device_enable_ctrl_t;
pub const struct_xcb_input_device_enable_ctrl_iterator_t = extern struct {
    data: [*c]xcb_input_device_enable_ctrl_t = @import("std").mem.zeroes([*c]xcb_input_device_enable_ctrl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_enable_ctrl_iterator_t = struct_xcb_input_device_enable_ctrl_iterator_t;
const struct_unnamed_40 = extern struct {
    first_valuator: u8 = @import("std").mem.zeroes(u8),
    num_valuators: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    resolution_values: [*c]u32 = @import("std").mem.zeroes([*c]u32),
};
const struct_unnamed_41 = extern struct {
    min_x: i32 = @import("std").mem.zeroes(i32),
    max_x: i32 = @import("std").mem.zeroes(i32),
    min_y: i32 = @import("std").mem.zeroes(i32),
    max_y: i32 = @import("std").mem.zeroes(i32),
    flip_x: u32 = @import("std").mem.zeroes(u32),
    flip_y: u32 = @import("std").mem.zeroes(u32),
    rotation: u32 = @import("std").mem.zeroes(u32),
    button_threshold: u32 = @import("std").mem.zeroes(u32),
};
const struct_unnamed_42 = extern struct {
    status: u8 = @import("std").mem.zeroes(u8),
    pad1: [3]u8 = @import("std").mem.zeroes([3]u8),
};
const struct_unnamed_43 = extern struct {
    enable: u8 = @import("std").mem.zeroes(u8),
    pad2: [3]u8 = @import("std").mem.zeroes([3]u8),
};
const struct_unnamed_44 = extern struct {
    offset_x: u32 = @import("std").mem.zeroes(u32),
    offset_y: u32 = @import("std").mem.zeroes(u32),
    width: i32 = @import("std").mem.zeroes(i32),
    height: i32 = @import("std").mem.zeroes(i32),
    screen: i32 = @import("std").mem.zeroes(i32),
    following: u32 = @import("std").mem.zeroes(u32),
};
pub const struct_xcb_input_device_ctl_data_t = extern struct {
    resolution: struct_unnamed_40 = @import("std").mem.zeroes(struct_unnamed_40),
    abs_calib: struct_unnamed_41 = @import("std").mem.zeroes(struct_unnamed_41),
    core: struct_unnamed_42 = @import("std").mem.zeroes(struct_unnamed_42),
    enable: struct_unnamed_43 = @import("std").mem.zeroes(struct_unnamed_43),
    abs_area: struct_unnamed_44 = @import("std").mem.zeroes(struct_unnamed_44),
};
pub const xcb_input_device_ctl_data_t = struct_xcb_input_device_ctl_data_t;
pub const struct_xcb_input_device_ctl_t = extern struct {
    control_id: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_device_ctl_t = struct_xcb_input_device_ctl_t;
pub extern fn xcb_input_device_ctl_data(R: [*c]const xcb_input_device_ctl_t) ?*anyopaque;
pub const struct_xcb_input_device_ctl_iterator_t = extern struct {
    data: [*c]xcb_input_device_ctl_t = @import("std").mem.zeroes([*c]xcb_input_device_ctl_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_ctl_iterator_t = struct_xcb_input_device_ctl_iterator_t;
pub const struct_xcb_input_change_device_control_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_change_device_control_cookie_t = struct_xcb_input_change_device_control_cookie_t;
pub const struct_xcb_input_change_device_control_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    control_id: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_change_device_control_request_t = struct_xcb_input_change_device_control_request_t;
pub const struct_xcb_input_change_device_control_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_change_device_control_reply_t = struct_xcb_input_change_device_control_reply_t;
pub const struct_xcb_input_list_device_properties_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_list_device_properties_cookie_t = struct_xcb_input_list_device_properties_cookie_t;
pub const struct_xcb_input_list_device_properties_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_list_device_properties_request_t = struct_xcb_input_list_device_properties_request_t;
pub const struct_xcb_input_list_device_properties_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_atoms: u16 = @import("std").mem.zeroes(u16),
    pad0: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_input_list_device_properties_reply_t = struct_xcb_input_list_device_properties_reply_t;
pub const XCB_INPUT_PROPERTY_FORMAT_8_BITS: c_int = 8;
pub const XCB_INPUT_PROPERTY_FORMAT_16_BITS: c_int = 16;
pub const XCB_INPUT_PROPERTY_FORMAT_32_BITS: c_int = 32;
pub const enum_xcb_input_property_format_t = c_uint;
pub const xcb_input_property_format_t = enum_xcb_input_property_format_t;
pub const struct_xcb_input_change_device_property_items_t = extern struct {
    data8: [*c]u8 = @import("std").mem.zeroes([*c]u8),
    data16: [*c]u16 = @import("std").mem.zeroes([*c]u16),
    data32: [*c]u32 = @import("std").mem.zeroes([*c]u32),
};
pub const xcb_input_change_device_property_items_t = struct_xcb_input_change_device_property_items_t;
pub const struct_xcb_input_change_device_property_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    type: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    device_id: u8 = @import("std").mem.zeroes(u8),
    format: u8 = @import("std").mem.zeroes(u8),
    mode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    num_items: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_change_device_property_request_t = struct_xcb_input_change_device_property_request_t;
pub const struct_xcb_input_delete_device_property_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_delete_device_property_request_t = struct_xcb_input_delete_device_property_request_t;
pub const struct_xcb_input_get_device_property_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_get_device_property_cookie_t = struct_xcb_input_get_device_property_cookie_t;
pub const struct_xcb_input_get_device_property_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    type: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    offset: u32 = @import("std").mem.zeroes(u32),
    len: u32 = @import("std").mem.zeroes(u32),
    device_id: u8 = @import("std").mem.zeroes(u8),
    _delete: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_get_device_property_request_t = struct_xcb_input_get_device_property_request_t;
pub const struct_xcb_input_get_device_property_items_t = extern struct {
    data8: [*c]u8 = @import("std").mem.zeroes([*c]u8),
    data16: [*c]u16 = @import("std").mem.zeroes([*c]u16),
    data32: [*c]u32 = @import("std").mem.zeroes([*c]u32),
};
pub const xcb_input_get_device_property_items_t = struct_xcb_input_get_device_property_items_t;
pub const struct_xcb_input_get_device_property_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    xi_reply_type: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    type: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    bytes_after: u32 = @import("std").mem.zeroes(u32),
    num_items: u32 = @import("std").mem.zeroes(u32),
    format: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [10]u8 = @import("std").mem.zeroes([10]u8),
};
pub const xcb_input_get_device_property_reply_t = struct_xcb_input_get_device_property_reply_t;
pub const XCB_INPUT_DEVICE_ALL: c_int = 0;
pub const XCB_INPUT_DEVICE_ALL_MASTER: c_int = 1;
pub const enum_xcb_input_device_t = c_uint;
pub const xcb_input_device_t = enum_xcb_input_device_t;
pub const struct_xcb_input_group_info_t = extern struct {
    base: u8 = @import("std").mem.zeroes(u8),
    latched: u8 = @import("std").mem.zeroes(u8),
    locked: u8 = @import("std").mem.zeroes(u8),
    effective: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_group_info_t = struct_xcb_input_group_info_t;
pub const struct_xcb_input_group_info_iterator_t = extern struct {
    data: [*c]xcb_input_group_info_t = @import("std").mem.zeroes([*c]xcb_input_group_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_group_info_iterator_t = struct_xcb_input_group_info_iterator_t;
pub const struct_xcb_input_modifier_info_t = extern struct {
    base: u32 = @import("std").mem.zeroes(u32),
    latched: u32 = @import("std").mem.zeroes(u32),
    locked: u32 = @import("std").mem.zeroes(u32),
    effective: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_modifier_info_t = struct_xcb_input_modifier_info_t;
pub const struct_xcb_input_modifier_info_iterator_t = extern struct {
    data: [*c]xcb_input_modifier_info_t = @import("std").mem.zeroes([*c]xcb_input_modifier_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_modifier_info_iterator_t = struct_xcb_input_modifier_info_iterator_t;
pub const struct_xcb_input_xi_query_pointer_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_xi_query_pointer_cookie_t = struct_xcb_input_xi_query_pointer_cookie_t;
pub const struct_xcb_input_xi_query_pointer_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_xi_query_pointer_request_t = struct_xcb_input_xi_query_pointer_request_t;
pub const struct_xcb_input_xi_query_pointer_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    root_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    root_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    win_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    win_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    same_screen: u8 = @import("std").mem.zeroes(u8),
    pad1: u8 = @import("std").mem.zeroes(u8),
    buttons_len: u16 = @import("std").mem.zeroes(u16),
    mods: xcb_input_modifier_info_t = @import("std").mem.zeroes(xcb_input_modifier_info_t),
    group: xcb_input_group_info_t = @import("std").mem.zeroes(xcb_input_group_info_t),
};
pub const xcb_input_xi_query_pointer_reply_t = struct_xcb_input_xi_query_pointer_reply_t;
pub const struct_xcb_input_xi_warp_pointer_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    src_win: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    dst_win: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    src_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    src_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    src_width: u16 = @import("std").mem.zeroes(u16),
    src_height: u16 = @import("std").mem.zeroes(u16),
    dst_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    dst_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_xi_warp_pointer_request_t = struct_xcb_input_xi_warp_pointer_request_t;
pub const struct_xcb_input_xi_change_cursor_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_xi_change_cursor_request_t = struct_xcb_input_xi_change_cursor_request_t;
pub const XCB_INPUT_HIERARCHY_CHANGE_TYPE_ADD_MASTER: c_int = 1;
pub const XCB_INPUT_HIERARCHY_CHANGE_TYPE_REMOVE_MASTER: c_int = 2;
pub const XCB_INPUT_HIERARCHY_CHANGE_TYPE_ATTACH_SLAVE: c_int = 3;
pub const XCB_INPUT_HIERARCHY_CHANGE_TYPE_DETACH_SLAVE: c_int = 4;
pub const enum_xcb_input_hierarchy_change_type_t = c_uint;
pub const xcb_input_hierarchy_change_type_t = enum_xcb_input_hierarchy_change_type_t;
pub const XCB_INPUT_CHANGE_MODE_ATTACH: c_int = 1;
pub const XCB_INPUT_CHANGE_MODE_FLOAT: c_int = 2;
pub const enum_xcb_input_change_mode_t = c_uint;
pub const xcb_input_change_mode_t = enum_xcb_input_change_mode_t;
pub const struct_xcb_input_add_master_t = extern struct {
    type: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    name_len: u16 = @import("std").mem.zeroes(u16),
    send_core: u8 = @import("std").mem.zeroes(u8),
    enable: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_add_master_t = struct_xcb_input_add_master_t;
pub const struct_xcb_input_add_master_iterator_t = extern struct {
    data: [*c]xcb_input_add_master_t = @import("std").mem.zeroes([*c]xcb_input_add_master_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_add_master_iterator_t = struct_xcb_input_add_master_iterator_t;
pub const struct_xcb_input_remove_master_t = extern struct {
    type: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    return_mode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    return_pointer: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    return_keyboard: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
};
pub const xcb_input_remove_master_t = struct_xcb_input_remove_master_t;
pub const struct_xcb_input_remove_master_iterator_t = extern struct {
    data: [*c]xcb_input_remove_master_t = @import("std").mem.zeroes([*c]xcb_input_remove_master_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_remove_master_iterator_t = struct_xcb_input_remove_master_iterator_t;
pub const struct_xcb_input_attach_slave_t = extern struct {
    type: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    master: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
};
pub const xcb_input_attach_slave_t = struct_xcb_input_attach_slave_t;
pub const struct_xcb_input_attach_slave_iterator_t = extern struct {
    data: [*c]xcb_input_attach_slave_t = @import("std").mem.zeroes([*c]xcb_input_attach_slave_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_attach_slave_iterator_t = struct_xcb_input_attach_slave_iterator_t;
pub const struct_xcb_input_detach_slave_t = extern struct {
    type: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_detach_slave_t = struct_xcb_input_detach_slave_t;
pub const struct_xcb_input_detach_slave_iterator_t = extern struct {
    data: [*c]xcb_input_detach_slave_t = @import("std").mem.zeroes([*c]xcb_input_detach_slave_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_detach_slave_iterator_t = struct_xcb_input_detach_slave_iterator_t;
const struct_unnamed_45 = extern struct {
    name_len: u16 = @import("std").mem.zeroes(u16),
    send_core: u8 = @import("std").mem.zeroes(u8),
    enable: u8 = @import("std").mem.zeroes(u8),
    name: [*c]u8 = @import("std").mem.zeroes([*c]u8),
};
const struct_unnamed_46 = extern struct {
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    return_mode: u8 = @import("std").mem.zeroes(u8),
    pad1: u8 = @import("std").mem.zeroes(u8),
    return_pointer: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    return_keyboard: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
};
const struct_unnamed_47 = extern struct {
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    master: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
};
const struct_unnamed_48 = extern struct {
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad2: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const struct_xcb_input_hierarchy_change_data_t = extern struct {
    add_master: struct_unnamed_45 = @import("std").mem.zeroes(struct_unnamed_45),
    remove_master: struct_unnamed_46 = @import("std").mem.zeroes(struct_unnamed_46),
    attach_slave: struct_unnamed_47 = @import("std").mem.zeroes(struct_unnamed_47),
    detach_slave: struct_unnamed_48 = @import("std").mem.zeroes(struct_unnamed_48),
};
pub const xcb_input_hierarchy_change_data_t = struct_xcb_input_hierarchy_change_data_t;
pub const struct_xcb_input_hierarchy_change_t = extern struct {
    type: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_hierarchy_change_t = struct_xcb_input_hierarchy_change_t;
pub extern fn xcb_input_hierarchy_change_data(R: [*c]const xcb_input_hierarchy_change_t) ?*anyopaque;
pub const struct_xcb_input_hierarchy_change_iterator_t = extern struct {
    data: [*c]xcb_input_hierarchy_change_t = @import("std").mem.zeroes([*c]xcb_input_hierarchy_change_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_hierarchy_change_iterator_t = struct_xcb_input_hierarchy_change_iterator_t;
pub const struct_xcb_input_xi_change_hierarchy_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    num_changes: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_xi_change_hierarchy_request_t = struct_xcb_input_xi_change_hierarchy_request_t;
pub const struct_xcb_input_xi_set_client_pointer_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_xi_set_client_pointer_request_t = struct_xcb_input_xi_set_client_pointer_request_t;
pub const struct_xcb_input_xi_get_client_pointer_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_xi_get_client_pointer_cookie_t = struct_xcb_input_xi_get_client_pointer_cookie_t;
pub const struct_xcb_input_xi_get_client_pointer_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_input_xi_get_client_pointer_request_t = struct_xcb_input_xi_get_client_pointer_request_t;
pub const struct_xcb_input_xi_get_client_pointer_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    set: u8 = @import("std").mem.zeroes(u8),
    pad1: u8 = @import("std").mem.zeroes(u8),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad2: [20]u8 = @import("std").mem.zeroes([20]u8),
};
pub const xcb_input_xi_get_client_pointer_reply_t = struct_xcb_input_xi_get_client_pointer_reply_t;
pub const XCB_INPUT_XI_EVENT_MASK_DEVICE_CHANGED: c_int = 2;
pub const XCB_INPUT_XI_EVENT_MASK_KEY_PRESS: c_int = 4;
pub const XCB_INPUT_XI_EVENT_MASK_KEY_RELEASE: c_int = 8;
pub const XCB_INPUT_XI_EVENT_MASK_BUTTON_PRESS: c_int = 16;
pub const XCB_INPUT_XI_EVENT_MASK_BUTTON_RELEASE: c_int = 32;
pub const XCB_INPUT_XI_EVENT_MASK_MOTION: c_int = 64;
pub const XCB_INPUT_XI_EVENT_MASK_ENTER: c_int = 128;
pub const XCB_INPUT_XI_EVENT_MASK_LEAVE: c_int = 256;
pub const XCB_INPUT_XI_EVENT_MASK_FOCUS_IN: c_int = 512;
pub const XCB_INPUT_XI_EVENT_MASK_FOCUS_OUT: c_int = 1024;
pub const XCB_INPUT_XI_EVENT_MASK_HIERARCHY: c_int = 2048;
pub const XCB_INPUT_XI_EVENT_MASK_PROPERTY: c_int = 4096;
pub const XCB_INPUT_XI_EVENT_MASK_RAW_KEY_PRESS: c_int = 8192;
pub const XCB_INPUT_XI_EVENT_MASK_RAW_KEY_RELEASE: c_int = 16384;
pub const XCB_INPUT_XI_EVENT_MASK_RAW_BUTTON_PRESS: c_int = 32768;
pub const XCB_INPUT_XI_EVENT_MASK_RAW_BUTTON_RELEASE: c_int = 65536;
pub const XCB_INPUT_XI_EVENT_MASK_RAW_MOTION: c_int = 131072;
pub const XCB_INPUT_XI_EVENT_MASK_TOUCH_BEGIN: c_int = 262144;
pub const XCB_INPUT_XI_EVENT_MASK_TOUCH_UPDATE: c_int = 524288;
pub const XCB_INPUT_XI_EVENT_MASK_TOUCH_END: c_int = 1048576;
pub const XCB_INPUT_XI_EVENT_MASK_TOUCH_OWNERSHIP: c_int = 2097152;
pub const XCB_INPUT_XI_EVENT_MASK_RAW_TOUCH_BEGIN: c_int = 4194304;
pub const XCB_INPUT_XI_EVENT_MASK_RAW_TOUCH_UPDATE: c_int = 8388608;
pub const XCB_INPUT_XI_EVENT_MASK_RAW_TOUCH_END: c_int = 16777216;
pub const XCB_INPUT_XI_EVENT_MASK_BARRIER_HIT: c_int = 33554432;
pub const XCB_INPUT_XI_EVENT_MASK_BARRIER_LEAVE: c_int = 67108864;
pub const enum_xcb_input_xi_event_mask_t = c_uint;
pub const xcb_input_xi_event_mask_t = enum_xcb_input_xi_event_mask_t;
pub const struct_xcb_input_event_mask_t = extern struct {
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    mask_len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_event_mask_t = struct_xcb_input_event_mask_t;
pub const struct_xcb_input_event_mask_iterator_t = extern struct {
    data: [*c]xcb_input_event_mask_t = @import("std").mem.zeroes([*c]xcb_input_event_mask_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_event_mask_iterator_t = struct_xcb_input_event_mask_iterator_t;
pub const struct_xcb_input_xi_select_events_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    num_mask: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_xi_select_events_request_t = struct_xcb_input_xi_select_events_request_t;
pub const struct_xcb_input_xi_query_version_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_xi_query_version_cookie_t = struct_xcb_input_xi_query_version_cookie_t;
pub const struct_xcb_input_xi_query_version_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    major_version: u16 = @import("std").mem.zeroes(u16),
    minor_version: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_xi_query_version_request_t = struct_xcb_input_xi_query_version_request_t;
pub const struct_xcb_input_xi_query_version_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    major_version: u16 = @import("std").mem.zeroes(u16),
    minor_version: u16 = @import("std").mem.zeroes(u16),
    pad1: [20]u8 = @import("std").mem.zeroes([20]u8),
};
pub const xcb_input_xi_query_version_reply_t = struct_xcb_input_xi_query_version_reply_t;
pub const XCB_INPUT_DEVICE_CLASS_TYPE_KEY: c_int = 0;
pub const XCB_INPUT_DEVICE_CLASS_TYPE_BUTTON: c_int = 1;
pub const XCB_INPUT_DEVICE_CLASS_TYPE_VALUATOR: c_int = 2;
pub const XCB_INPUT_DEVICE_CLASS_TYPE_SCROLL: c_int = 3;
pub const XCB_INPUT_DEVICE_CLASS_TYPE_TOUCH: c_int = 8;
pub const enum_xcb_input_device_class_type_t = c_uint;
pub const xcb_input_device_class_type_t = enum_xcb_input_device_class_type_t;
pub const XCB_INPUT_DEVICE_TYPE_MASTER_POINTER: c_int = 1;
pub const XCB_INPUT_DEVICE_TYPE_MASTER_KEYBOARD: c_int = 2;
pub const XCB_INPUT_DEVICE_TYPE_SLAVE_POINTER: c_int = 3;
pub const XCB_INPUT_DEVICE_TYPE_SLAVE_KEYBOARD: c_int = 4;
pub const XCB_INPUT_DEVICE_TYPE_FLOATING_SLAVE: c_int = 5;
pub const enum_xcb_input_device_type_t = c_uint;
pub const xcb_input_device_type_t = enum_xcb_input_device_type_t;
pub const XCB_INPUT_SCROLL_FLAGS_NO_EMULATION: c_int = 1;
pub const XCB_INPUT_SCROLL_FLAGS_PREFERRED: c_int = 2;
pub const enum_xcb_input_scroll_flags_t = c_uint;
pub const xcb_input_scroll_flags_t = enum_xcb_input_scroll_flags_t;
pub const XCB_INPUT_SCROLL_TYPE_VERTICAL: c_int = 1;
pub const XCB_INPUT_SCROLL_TYPE_HORIZONTAL: c_int = 2;
pub const enum_xcb_input_scroll_type_t = c_uint;
pub const xcb_input_scroll_type_t = enum_xcb_input_scroll_type_t;
pub const XCB_INPUT_TOUCH_MODE_DIRECT: c_int = 1;
pub const XCB_INPUT_TOUCH_MODE_DEPENDENT: c_int = 2;
pub const enum_xcb_input_touch_mode_t = c_uint;
pub const xcb_input_touch_mode_t = enum_xcb_input_touch_mode_t;
pub const struct_xcb_input_button_class_t = extern struct {
    type: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    num_buttons: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_button_class_t = struct_xcb_input_button_class_t;
pub const struct_xcb_input_button_class_iterator_t = extern struct {
    data: [*c]xcb_input_button_class_t = @import("std").mem.zeroes([*c]xcb_input_button_class_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_button_class_iterator_t = struct_xcb_input_button_class_iterator_t;
pub const struct_xcb_input_key_class_t = extern struct {
    type: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    num_keys: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_key_class_t = struct_xcb_input_key_class_t;
pub const struct_xcb_input_key_class_iterator_t = extern struct {
    data: [*c]xcb_input_key_class_t = @import("std").mem.zeroes([*c]xcb_input_key_class_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_key_class_iterator_t = struct_xcb_input_key_class_iterator_t;
pub const struct_xcb_input_scroll_class_t = extern struct {
    type: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    number: u16 = @import("std").mem.zeroes(u16),
    scroll_type: u16 = @import("std").mem.zeroes(u16),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    flags: u32 = @import("std").mem.zeroes(u32),
    increment: xcb_input_fp3232_t = @import("std").mem.zeroes(xcb_input_fp3232_t),
};
pub const xcb_input_scroll_class_t = struct_xcb_input_scroll_class_t;
pub const struct_xcb_input_scroll_class_iterator_t = extern struct {
    data: [*c]xcb_input_scroll_class_t = @import("std").mem.zeroes([*c]xcb_input_scroll_class_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_scroll_class_iterator_t = struct_xcb_input_scroll_class_iterator_t;
pub const struct_xcb_input_touch_class_t = extern struct {
    type: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    mode: u8 = @import("std").mem.zeroes(u8),
    num_touches: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_touch_class_t = struct_xcb_input_touch_class_t;
pub const struct_xcb_input_touch_class_iterator_t = extern struct {
    data: [*c]xcb_input_touch_class_t = @import("std").mem.zeroes([*c]xcb_input_touch_class_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_touch_class_iterator_t = struct_xcb_input_touch_class_iterator_t;
pub const struct_xcb_input_valuator_class_t = extern struct {
    type: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    number: u16 = @import("std").mem.zeroes(u16),
    label: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    min: xcb_input_fp3232_t = @import("std").mem.zeroes(xcb_input_fp3232_t),
    max: xcb_input_fp3232_t = @import("std").mem.zeroes(xcb_input_fp3232_t),
    value: xcb_input_fp3232_t = @import("std").mem.zeroes(xcb_input_fp3232_t),
    resolution: u32 = @import("std").mem.zeroes(u32),
    mode: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_valuator_class_t = struct_xcb_input_valuator_class_t;
pub const struct_xcb_input_valuator_class_iterator_t = extern struct {
    data: [*c]xcb_input_valuator_class_t = @import("std").mem.zeroes([*c]xcb_input_valuator_class_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_valuator_class_iterator_t = struct_xcb_input_valuator_class_iterator_t;
const struct_unnamed_49 = extern struct {
    num_keys: u16 = @import("std").mem.zeroes(u16),
    keys: [*c]u32 = @import("std").mem.zeroes([*c]u32),
};
const struct_unnamed_50 = extern struct {
    num_buttons: u16 = @import("std").mem.zeroes(u16),
    state: [*c]u32 = @import("std").mem.zeroes([*c]u32),
    labels: [*c]xcb_atom_t = @import("std").mem.zeroes([*c]xcb_atom_t),
};
const struct_unnamed_51 = extern struct {
    number: u16 = @import("std").mem.zeroes(u16),
    label: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    min: xcb_input_fp3232_t = @import("std").mem.zeroes(xcb_input_fp3232_t),
    max: xcb_input_fp3232_t = @import("std").mem.zeroes(xcb_input_fp3232_t),
    value: xcb_input_fp3232_t = @import("std").mem.zeroes(xcb_input_fp3232_t),
    resolution: u32 = @import("std").mem.zeroes(u32),
    mode: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
const struct_unnamed_52 = extern struct {
    number: u16 = @import("std").mem.zeroes(u16),
    scroll_type: u16 = @import("std").mem.zeroes(u16),
    pad1: [2]u8 = @import("std").mem.zeroes([2]u8),
    flags: u32 = @import("std").mem.zeroes(u32),
    increment: xcb_input_fp3232_t = @import("std").mem.zeroes(xcb_input_fp3232_t),
};
const struct_unnamed_53 = extern struct {
    mode: u8 = @import("std").mem.zeroes(u8),
    num_touches: u8 = @import("std").mem.zeroes(u8),
};
pub const struct_xcb_input_device_class_data_t = extern struct {
    key: struct_unnamed_49 = @import("std").mem.zeroes(struct_unnamed_49),
    button: struct_unnamed_50 = @import("std").mem.zeroes(struct_unnamed_50),
    valuator: struct_unnamed_51 = @import("std").mem.zeroes(struct_unnamed_51),
    scroll: struct_unnamed_52 = @import("std").mem.zeroes(struct_unnamed_52),
    touch: struct_unnamed_53 = @import("std").mem.zeroes(struct_unnamed_53),
};
pub const xcb_input_device_class_data_t = struct_xcb_input_device_class_data_t;
pub const struct_xcb_input_device_class_t = extern struct {
    type: u16 = @import("std").mem.zeroes(u16),
    len: u16 = @import("std").mem.zeroes(u16),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
};
pub const xcb_input_device_class_t = struct_xcb_input_device_class_t;
pub extern fn xcb_input_device_class_data(R: [*c]const xcb_input_device_class_t) ?*anyopaque;
pub const struct_xcb_input_device_class_iterator_t = extern struct {
    data: [*c]xcb_input_device_class_t = @import("std").mem.zeroes([*c]xcb_input_device_class_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_device_class_iterator_t = struct_xcb_input_device_class_iterator_t;
pub const struct_xcb_input_xi_device_info_t = extern struct {
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    type: u16 = @import("std").mem.zeroes(u16),
    attachment: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    num_classes: u16 = @import("std").mem.zeroes(u16),
    name_len: u16 = @import("std").mem.zeroes(u16),
    enabled: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_xi_device_info_t = struct_xcb_input_xi_device_info_t;
pub const struct_xcb_input_xi_device_info_iterator_t = extern struct {
    data: [*c]xcb_input_xi_device_info_t = @import("std").mem.zeroes([*c]xcb_input_xi_device_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_xi_device_info_iterator_t = struct_xcb_input_xi_device_info_iterator_t;
pub const struct_xcb_input_xi_query_device_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_xi_query_device_cookie_t = struct_xcb_input_xi_query_device_cookie_t;
pub const struct_xcb_input_xi_query_device_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_xi_query_device_request_t = struct_xcb_input_xi_query_device_request_t;
pub const struct_xcb_input_xi_query_device_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_infos: u16 = @import("std").mem.zeroes(u16),
    pad1: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_input_xi_query_device_reply_t = struct_xcb_input_xi_query_device_reply_t;
pub const struct_xcb_input_xi_set_focus_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_xi_set_focus_request_t = struct_xcb_input_xi_set_focus_request_t;
pub const struct_xcb_input_xi_get_focus_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_xi_get_focus_cookie_t = struct_xcb_input_xi_get_focus_cookie_t;
pub const struct_xcb_input_xi_get_focus_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_xi_get_focus_request_t = struct_xcb_input_xi_get_focus_request_t;
pub const struct_xcb_input_xi_get_focus_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    focus: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    pad1: [20]u8 = @import("std").mem.zeroes([20]u8),
};
pub const xcb_input_xi_get_focus_reply_t = struct_xcb_input_xi_get_focus_reply_t;
pub const XCB_INPUT_GRAB_OWNER_NO_OWNER: c_int = 0;
pub const XCB_INPUT_GRAB_OWNER_OWNER: c_int = 1;
pub const enum_xcb_input_grab_owner_t = c_uint;
pub const xcb_input_grab_owner_t = enum_xcb_input_grab_owner_t;
pub const struct_xcb_input_xi_grab_device_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_xi_grab_device_cookie_t = struct_xcb_input_xi_grab_device_cookie_t;
pub const struct_xcb_input_xi_grab_device_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    mode: u8 = @import("std").mem.zeroes(u8),
    paired_device_mode: u8 = @import("std").mem.zeroes(u8),
    owner_events: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    mask_len: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_xi_grab_device_request_t = struct_xcb_input_xi_grab_device_request_t;
pub const struct_xcb_input_xi_grab_device_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    status: u8 = @import("std").mem.zeroes(u8),
    pad1: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_xi_grab_device_reply_t = struct_xcb_input_xi_grab_device_reply_t;
pub const struct_xcb_input_xi_ungrab_device_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_xi_ungrab_device_request_t = struct_xcb_input_xi_ungrab_device_request_t;
pub const XCB_INPUT_EVENT_MODE_ASYNC_DEVICE: c_int = 0;
pub const XCB_INPUT_EVENT_MODE_SYNC_DEVICE: c_int = 1;
pub const XCB_INPUT_EVENT_MODE_REPLAY_DEVICE: c_int = 2;
pub const XCB_INPUT_EVENT_MODE_ASYNC_PAIRED_DEVICE: c_int = 3;
pub const XCB_INPUT_EVENT_MODE_ASYNC_PAIR: c_int = 4;
pub const XCB_INPUT_EVENT_MODE_SYNC_PAIR: c_int = 5;
pub const XCB_INPUT_EVENT_MODE_ACCEPT_TOUCH: c_int = 6;
pub const XCB_INPUT_EVENT_MODE_REJECT_TOUCH: c_int = 7;
pub const enum_xcb_input_event_mode_t = c_uint;
pub const xcb_input_event_mode_t = enum_xcb_input_event_mode_t;
pub const struct_xcb_input_xi_allow_events_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    event_mode: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    touchid: u32 = @import("std").mem.zeroes(u32),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_input_xi_allow_events_request_t = struct_xcb_input_xi_allow_events_request_t;
pub const XCB_INPUT_GRAB_MODE_22_SYNC: c_int = 0;
pub const XCB_INPUT_GRAB_MODE_22_ASYNC: c_int = 1;
pub const XCB_INPUT_GRAB_MODE_22_TOUCH: c_int = 2;
pub const enum_xcb_input_grab_mode_22_t = c_uint;
pub const xcb_input_grab_mode_22_t = enum_xcb_input_grab_mode_22_t;
pub const XCB_INPUT_GRAB_TYPE_BUTTON: c_int = 0;
pub const XCB_INPUT_GRAB_TYPE_KEYCODE: c_int = 1;
pub const XCB_INPUT_GRAB_TYPE_ENTER: c_int = 2;
pub const XCB_INPUT_GRAB_TYPE_FOCUS_IN: c_int = 3;
pub const XCB_INPUT_GRAB_TYPE_TOUCH_BEGIN: c_int = 4;
pub const enum_xcb_input_grab_type_t = c_uint;
pub const xcb_input_grab_type_t = enum_xcb_input_grab_type_t;
pub const XCB_INPUT_MODIFIER_MASK_ANY: c_uint = 2147483648;
pub const enum_xcb_input_modifier_mask_t = c_uint;
pub const xcb_input_modifier_mask_t = enum_xcb_input_modifier_mask_t;
pub const struct_xcb_input_grab_modifier_info_t = extern struct {
    modifiers: u32 = @import("std").mem.zeroes(u32),
    status: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_grab_modifier_info_t = struct_xcb_input_grab_modifier_info_t;
pub const struct_xcb_input_grab_modifier_info_iterator_t = extern struct {
    data: [*c]xcb_input_grab_modifier_info_t = @import("std").mem.zeroes([*c]xcb_input_grab_modifier_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_grab_modifier_info_iterator_t = struct_xcb_input_grab_modifier_info_iterator_t;
pub const struct_xcb_input_xi_passive_grab_device_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_xi_passive_grab_device_cookie_t = struct_xcb_input_xi_passive_grab_device_cookie_t;
pub const struct_xcb_input_xi_passive_grab_device_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    cursor: xcb_cursor_t = @import("std").mem.zeroes(xcb_cursor_t),
    detail: u32 = @import("std").mem.zeroes(u32),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    num_modifiers: u16 = @import("std").mem.zeroes(u16),
    mask_len: u16 = @import("std").mem.zeroes(u16),
    grab_type: u8 = @import("std").mem.zeroes(u8),
    grab_mode: u8 = @import("std").mem.zeroes(u8),
    paired_device_mode: u8 = @import("std").mem.zeroes(u8),
    owner_events: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_xi_passive_grab_device_request_t = struct_xcb_input_xi_passive_grab_device_request_t;
pub const struct_xcb_input_xi_passive_grab_device_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_modifiers: u16 = @import("std").mem.zeroes(u16),
    pad1: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_input_xi_passive_grab_device_reply_t = struct_xcb_input_xi_passive_grab_device_reply_t;
pub const struct_xcb_input_xi_passive_ungrab_device_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    grab_window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    detail: u32 = @import("std").mem.zeroes(u32),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    num_modifiers: u16 = @import("std").mem.zeroes(u16),
    grab_type: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_xi_passive_ungrab_device_request_t = struct_xcb_input_xi_passive_ungrab_device_request_t;
pub const struct_xcb_input_xi_list_properties_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_xi_list_properties_cookie_t = struct_xcb_input_xi_list_properties_cookie_t;
pub const struct_xcb_input_xi_list_properties_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
};
pub const xcb_input_xi_list_properties_request_t = struct_xcb_input_xi_list_properties_request_t;
pub const struct_xcb_input_xi_list_properties_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_properties: u16 = @import("std").mem.zeroes(u16),
    pad1: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_input_xi_list_properties_reply_t = struct_xcb_input_xi_list_properties_reply_t;
pub const struct_xcb_input_xi_change_property_items_t = extern struct {
    data8: [*c]u8 = @import("std").mem.zeroes([*c]u8),
    data16: [*c]u16 = @import("std").mem.zeroes([*c]u16),
    data32: [*c]u32 = @import("std").mem.zeroes([*c]u32),
};
pub const xcb_input_xi_change_property_items_t = struct_xcb_input_xi_change_property_items_t;
pub const struct_xcb_input_xi_change_property_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    mode: u8 = @import("std").mem.zeroes(u8),
    format: u8 = @import("std").mem.zeroes(u8),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    type: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    num_items: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_xi_change_property_request_t = struct_xcb_input_xi_change_property_request_t;
pub const struct_xcb_input_xi_delete_property_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
};
pub const xcb_input_xi_delete_property_request_t = struct_xcb_input_xi_delete_property_request_t;
pub const struct_xcb_input_xi_get_property_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_xi_get_property_cookie_t = struct_xcb_input_xi_get_property_cookie_t;
pub const struct_xcb_input_xi_get_property_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    _delete: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    type: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    offset: u32 = @import("std").mem.zeroes(u32),
    len: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_xi_get_property_request_t = struct_xcb_input_xi_get_property_request_t;
pub const struct_xcb_input_xi_get_property_items_t = extern struct {
    data8: [*c]u8 = @import("std").mem.zeroes([*c]u8),
    data16: [*c]u16 = @import("std").mem.zeroes([*c]u16),
    data32: [*c]u32 = @import("std").mem.zeroes([*c]u32),
};
pub const xcb_input_xi_get_property_items_t = struct_xcb_input_xi_get_property_items_t;
pub const struct_xcb_input_xi_get_property_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    type: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    bytes_after: u32 = @import("std").mem.zeroes(u32),
    num_items: u32 = @import("std").mem.zeroes(u32),
    format: u8 = @import("std").mem.zeroes(u8),
    pad1: [11]u8 = @import("std").mem.zeroes([11]u8),
};
pub const xcb_input_xi_get_property_reply_t = struct_xcb_input_xi_get_property_reply_t;
pub const struct_xcb_input_xi_get_selected_events_cookie_t = extern struct {
    sequence: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const xcb_input_xi_get_selected_events_cookie_t = struct_xcb_input_xi_get_selected_events_cookie_t;
pub const struct_xcb_input_xi_get_selected_events_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
};
pub const xcb_input_xi_get_selected_events_request_t = struct_xcb_input_xi_get_selected_events_request_t;
pub const struct_xcb_input_xi_get_selected_events_reply_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    num_masks: u16 = @import("std").mem.zeroes(u16),
    pad1: [22]u8 = @import("std").mem.zeroes([22]u8),
};
pub const xcb_input_xi_get_selected_events_reply_t = struct_xcb_input_xi_get_selected_events_reply_t;
pub const struct_xcb_input_barrier_release_pointer_info_t = extern struct {
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    barrier: xcb_xfixes_barrier_t = @import("std").mem.zeroes(xcb_xfixes_barrier_t),
    eventid: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_barrier_release_pointer_info_t = struct_xcb_input_barrier_release_pointer_info_t;
pub const struct_xcb_input_barrier_release_pointer_info_iterator_t = extern struct {
    data: [*c]xcb_input_barrier_release_pointer_info_t = @import("std").mem.zeroes([*c]xcb_input_barrier_release_pointer_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_barrier_release_pointer_info_iterator_t = struct_xcb_input_barrier_release_pointer_info_iterator_t;
pub const struct_xcb_input_xi_barrier_release_pointer_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    num_barriers: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_xi_barrier_release_pointer_request_t = struct_xcb_input_xi_barrier_release_pointer_request_t;
pub const struct_xcb_input_device_valuator_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    device_state: u16 = @import("std").mem.zeroes(u16),
    num_valuators: u8 = @import("std").mem.zeroes(u8),
    first_valuator: u8 = @import("std").mem.zeroes(u8),
    valuators: [6]i32 = @import("std").mem.zeroes([6]i32),
};
pub const xcb_input_device_valuator_event_t = struct_xcb_input_device_valuator_event_t;
pub const XCB_INPUT_MORE_EVENTS_MASK_MORE_EVENTS: c_int = 128;
pub const enum_xcb_input_more_events_mask_t = c_uint;
pub const xcb_input_more_events_mask_t = enum_xcb_input_more_events_mask_t;
pub const struct_xcb_input_device_key_press_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    detail: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    root_x: i16 = @import("std").mem.zeroes(i16),
    root_y: i16 = @import("std").mem.zeroes(i16),
    event_x: i16 = @import("std").mem.zeroes(i16),
    event_y: i16 = @import("std").mem.zeroes(i16),
    state: u16 = @import("std").mem.zeroes(u16),
    same_screen: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_device_key_press_event_t = struct_xcb_input_device_key_press_event_t;
pub const xcb_input_device_key_release_event_t = xcb_input_device_key_press_event_t;
pub const xcb_input_device_button_press_event_t = xcb_input_device_key_press_event_t;
pub const xcb_input_device_button_release_event_t = xcb_input_device_key_press_event_t;
pub const xcb_input_device_motion_notify_event_t = xcb_input_device_key_press_event_t;
pub const struct_xcb_input_device_focus_in_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    detail: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    window: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    mode: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    pad0: [18]u8 = @import("std").mem.zeroes([18]u8),
};
pub const xcb_input_device_focus_in_event_t = struct_xcb_input_device_focus_in_event_t;
pub const xcb_input_device_focus_out_event_t = xcb_input_device_focus_in_event_t;
pub const xcb_input_proximity_in_event_t = xcb_input_device_key_press_event_t;
pub const xcb_input_proximity_out_event_t = xcb_input_device_key_press_event_t;
pub const XCB_INPUT_CLASSES_REPORTED_MASK_OUT_OF_PROXIMITY: c_int = 128;
pub const XCB_INPUT_CLASSES_REPORTED_MASK_DEVICE_MODE_ABSOLUTE: c_int = 64;
pub const XCB_INPUT_CLASSES_REPORTED_MASK_REPORTING_VALUATORS: c_int = 4;
pub const XCB_INPUT_CLASSES_REPORTED_MASK_REPORTING_BUTTONS: c_int = 2;
pub const XCB_INPUT_CLASSES_REPORTED_MASK_REPORTING_KEYS: c_int = 1;
pub const enum_xcb_input_classes_reported_mask_t = c_uint;
pub const xcb_input_classes_reported_mask_t = enum_xcb_input_classes_reported_mask_t;
pub const struct_xcb_input_device_state_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    num_keys: u8 = @import("std").mem.zeroes(u8),
    num_buttons: u8 = @import("std").mem.zeroes(u8),
    num_valuators: u8 = @import("std").mem.zeroes(u8),
    classes_reported: u8 = @import("std").mem.zeroes(u8),
    buttons: [4]u8 = @import("std").mem.zeroes([4]u8),
    keys: [4]u8 = @import("std").mem.zeroes([4]u8),
    valuators: [3]u32 = @import("std").mem.zeroes([3]u32),
};
pub const xcb_input_device_state_notify_event_t = struct_xcb_input_device_state_notify_event_t;
pub const struct_xcb_input_device_mapping_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    request: u8 = @import("std").mem.zeroes(u8),
    first_keycode: xcb_input_key_code_t = @import("std").mem.zeroes(xcb_input_key_code_t),
    count: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    pad1: [20]u8 = @import("std").mem.zeroes([20]u8),
};
pub const xcb_input_device_mapping_notify_event_t = struct_xcb_input_device_mapping_notify_event_t;
pub const XCB_INPUT_CHANGE_DEVICE_NEW_POINTER: c_int = 0;
pub const XCB_INPUT_CHANGE_DEVICE_NEW_KEYBOARD: c_int = 1;
pub const enum_xcb_input_change_device_t = c_uint;
pub const xcb_input_change_device_t = enum_xcb_input_change_device_t;
pub const struct_xcb_input_change_device_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    request: u8 = @import("std").mem.zeroes(u8),
    pad0: [23]u8 = @import("std").mem.zeroes([23]u8),
};
pub const xcb_input_change_device_notify_event_t = struct_xcb_input_change_device_notify_event_t;
pub const struct_xcb_input_device_key_state_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    keys: [28]u8 = @import("std").mem.zeroes([28]u8),
};
pub const xcb_input_device_key_state_notify_event_t = struct_xcb_input_device_key_state_notify_event_t;
pub const struct_xcb_input_device_button_state_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    buttons: [28]u8 = @import("std").mem.zeroes([28]u8),
};
pub const xcb_input_device_button_state_notify_event_t = struct_xcb_input_device_button_state_notify_event_t;
pub const XCB_INPUT_DEVICE_CHANGE_ADDED: c_int = 0;
pub const XCB_INPUT_DEVICE_CHANGE_REMOVED: c_int = 1;
pub const XCB_INPUT_DEVICE_CHANGE_ENABLED: c_int = 2;
pub const XCB_INPUT_DEVICE_CHANGE_DISABLED: c_int = 3;
pub const XCB_INPUT_DEVICE_CHANGE_UNRECOVERABLE: c_int = 4;
pub const XCB_INPUT_DEVICE_CHANGE_CONTROL_CHANGED: c_int = 5;
pub const enum_xcb_input_device_change_t = c_uint;
pub const xcb_input_device_change_t = enum_xcb_input_device_change_t;
pub const struct_xcb_input_device_presence_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    pad0: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    devchange: u8 = @import("std").mem.zeroes(u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
    control: u16 = @import("std").mem.zeroes(u16),
    pad1: [20]u8 = @import("std").mem.zeroes([20]u8),
};
pub const xcb_input_device_presence_notify_event_t = struct_xcb_input_device_presence_notify_event_t;
pub const struct_xcb_input_device_property_notify_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    state: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    pad0: [19]u8 = @import("std").mem.zeroes([19]u8),
    device_id: u8 = @import("std").mem.zeroes(u8),
};
pub const xcb_input_device_property_notify_event_t = struct_xcb_input_device_property_notify_event_t;
pub const XCB_INPUT_CHANGE_REASON_SLAVE_SWITCH: c_int = 1;
pub const XCB_INPUT_CHANGE_REASON_DEVICE_CHANGE: c_int = 2;
pub const enum_xcb_input_change_reason_t = c_uint;
pub const xcb_input_change_reason_t = enum_xcb_input_change_reason_t;
pub const struct_xcb_input_device_changed_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    num_classes: u16 = @import("std").mem.zeroes(u16),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    reason: u8 = @import("std").mem.zeroes(u8),
    pad0: [11]u8 = @import("std").mem.zeroes([11]u8),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_device_changed_event_t = struct_xcb_input_device_changed_event_t;
pub const XCB_INPUT_KEY_EVENT_FLAGS_KEY_REPEAT: c_int = 65536;
pub const enum_xcb_input_key_event_flags_t = c_uint;
pub const xcb_input_key_event_flags_t = enum_xcb_input_key_event_flags_t;
pub const struct_xcb_input_key_press_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    detail: u32 = @import("std").mem.zeroes(u32),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
    root_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    root_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    event_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    event_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    buttons_len: u16 = @import("std").mem.zeroes(u16),
    valuators_len: u16 = @import("std").mem.zeroes(u16),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    flags: u32 = @import("std").mem.zeroes(u32),
    mods: xcb_input_modifier_info_t = @import("std").mem.zeroes(xcb_input_modifier_info_t),
    group: xcb_input_group_info_t = @import("std").mem.zeroes(xcb_input_group_info_t),
};
pub const xcb_input_key_press_event_t = struct_xcb_input_key_press_event_t;
pub const xcb_input_key_release_event_t = xcb_input_key_press_event_t;
pub const XCB_INPUT_POINTER_EVENT_FLAGS_POINTER_EMULATED: c_int = 65536;
pub const enum_xcb_input_pointer_event_flags_t = c_uint;
pub const xcb_input_pointer_event_flags_t = enum_xcb_input_pointer_event_flags_t;
pub const struct_xcb_input_button_press_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    detail: u32 = @import("std").mem.zeroes(u32),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
    root_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    root_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    event_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    event_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    buttons_len: u16 = @import("std").mem.zeroes(u16),
    valuators_len: u16 = @import("std").mem.zeroes(u16),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    flags: u32 = @import("std").mem.zeroes(u32),
    mods: xcb_input_modifier_info_t = @import("std").mem.zeroes(xcb_input_modifier_info_t),
    group: xcb_input_group_info_t = @import("std").mem.zeroes(xcb_input_group_info_t),
};
pub const xcb_input_button_press_event_t = struct_xcb_input_button_press_event_t;
pub const xcb_input_button_release_event_t = xcb_input_button_press_event_t;
pub const xcb_input_motion_event_t = xcb_input_button_press_event_t;
pub const XCB_INPUT_NOTIFY_MODE_NORMAL: c_int = 0;
pub const XCB_INPUT_NOTIFY_MODE_GRAB: c_int = 1;
pub const XCB_INPUT_NOTIFY_MODE_UNGRAB: c_int = 2;
pub const XCB_INPUT_NOTIFY_MODE_WHILE_GRABBED: c_int = 3;
pub const XCB_INPUT_NOTIFY_MODE_PASSIVE_GRAB: c_int = 4;
pub const XCB_INPUT_NOTIFY_MODE_PASSIVE_UNGRAB: c_int = 5;
pub const enum_xcb_input_notify_mode_t = c_uint;
pub const xcb_input_notify_mode_t = enum_xcb_input_notify_mode_t;
pub const XCB_INPUT_NOTIFY_DETAIL_ANCESTOR: c_int = 0;
pub const XCB_INPUT_NOTIFY_DETAIL_VIRTUAL: c_int = 1;
pub const XCB_INPUT_NOTIFY_DETAIL_INFERIOR: c_int = 2;
pub const XCB_INPUT_NOTIFY_DETAIL_NONLINEAR: c_int = 3;
pub const XCB_INPUT_NOTIFY_DETAIL_NONLINEAR_VIRTUAL: c_int = 4;
pub const XCB_INPUT_NOTIFY_DETAIL_POINTER: c_int = 5;
pub const XCB_INPUT_NOTIFY_DETAIL_POINTER_ROOT: c_int = 6;
pub const XCB_INPUT_NOTIFY_DETAIL_NONE: c_int = 7;
pub const enum_xcb_input_notify_detail_t = c_uint;
pub const xcb_input_notify_detail_t = enum_xcb_input_notify_detail_t;
pub const struct_xcb_input_enter_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    mode: u8 = @import("std").mem.zeroes(u8),
    detail: u8 = @import("std").mem.zeroes(u8),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
    root_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    root_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    event_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    event_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    same_screen: u8 = @import("std").mem.zeroes(u8),
    focus: u8 = @import("std").mem.zeroes(u8),
    buttons_len: u16 = @import("std").mem.zeroes(u16),
    mods: xcb_input_modifier_info_t = @import("std").mem.zeroes(xcb_input_modifier_info_t),
    group: xcb_input_group_info_t = @import("std").mem.zeroes(xcb_input_group_info_t),
};
pub const xcb_input_enter_event_t = struct_xcb_input_enter_event_t;
pub const xcb_input_leave_event_t = xcb_input_enter_event_t;
pub const xcb_input_focus_in_event_t = xcb_input_enter_event_t;
pub const xcb_input_focus_out_event_t = xcb_input_enter_event_t;
pub const XCB_INPUT_HIERARCHY_MASK_MASTER_ADDED: c_int = 1;
pub const XCB_INPUT_HIERARCHY_MASK_MASTER_REMOVED: c_int = 2;
pub const XCB_INPUT_HIERARCHY_MASK_SLAVE_ADDED: c_int = 4;
pub const XCB_INPUT_HIERARCHY_MASK_SLAVE_REMOVED: c_int = 8;
pub const XCB_INPUT_HIERARCHY_MASK_SLAVE_ATTACHED: c_int = 16;
pub const XCB_INPUT_HIERARCHY_MASK_SLAVE_DETACHED: c_int = 32;
pub const XCB_INPUT_HIERARCHY_MASK_DEVICE_ENABLED: c_int = 64;
pub const XCB_INPUT_HIERARCHY_MASK_DEVICE_DISABLED: c_int = 128;
pub const enum_xcb_input_hierarchy_mask_t = c_uint;
pub const xcb_input_hierarchy_mask_t = enum_xcb_input_hierarchy_mask_t;
pub const struct_xcb_input_hierarchy_info_t = extern struct {
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    attachment: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    type: u8 = @import("std").mem.zeroes(u8),
    enabled: u8 = @import("std").mem.zeroes(u8),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    flags: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_hierarchy_info_t = struct_xcb_input_hierarchy_info_t;
pub const struct_xcb_input_hierarchy_info_iterator_t = extern struct {
    data: [*c]xcb_input_hierarchy_info_t = @import("std").mem.zeroes([*c]xcb_input_hierarchy_info_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_hierarchy_info_iterator_t = struct_xcb_input_hierarchy_info_iterator_t;
pub const struct_xcb_input_hierarchy_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    flags: u32 = @import("std").mem.zeroes(u32),
    num_infos: u16 = @import("std").mem.zeroes(u16),
    pad0: [10]u8 = @import("std").mem.zeroes([10]u8),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_hierarchy_event_t = struct_xcb_input_hierarchy_event_t;
pub const XCB_INPUT_PROPERTY_FLAG_DELETED: c_int = 0;
pub const XCB_INPUT_PROPERTY_FLAG_CREATED: c_int = 1;
pub const XCB_INPUT_PROPERTY_FLAG_MODIFIED: c_int = 2;
pub const enum_xcb_input_property_flag_t = c_uint;
pub const xcb_input_property_flag_t = enum_xcb_input_property_flag_t;
pub const struct_xcb_input_property_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    property: xcb_atom_t = @import("std").mem.zeroes(xcb_atom_t),
    what: u8 = @import("std").mem.zeroes(u8),
    pad0: [11]u8 = @import("std").mem.zeroes([11]u8),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_property_event_t = struct_xcb_input_property_event_t;
pub const struct_xcb_input_raw_key_press_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    detail: u32 = @import("std").mem.zeroes(u32),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    valuators_len: u16 = @import("std").mem.zeroes(u16),
    flags: u32 = @import("std").mem.zeroes(u32),
    pad0: [4]u8 = @import("std").mem.zeroes([4]u8),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_raw_key_press_event_t = struct_xcb_input_raw_key_press_event_t;
pub const xcb_input_raw_key_release_event_t = xcb_input_raw_key_press_event_t;
pub const struct_xcb_input_raw_button_press_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    detail: u32 = @import("std").mem.zeroes(u32),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    valuators_len: u16 = @import("std").mem.zeroes(u16),
    flags: u32 = @import("std").mem.zeroes(u32),
    pad0: [4]u8 = @import("std").mem.zeroes([4]u8),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_raw_button_press_event_t = struct_xcb_input_raw_button_press_event_t;
pub const xcb_input_raw_button_release_event_t = xcb_input_raw_button_press_event_t;
pub const xcb_input_raw_motion_event_t = xcb_input_raw_button_press_event_t;
pub const XCB_INPUT_TOUCH_EVENT_FLAGS_TOUCH_PENDING_END: c_int = 65536;
pub const XCB_INPUT_TOUCH_EVENT_FLAGS_TOUCH_EMULATING_POINTER: c_int = 131072;
pub const enum_xcb_input_touch_event_flags_t = c_uint;
pub const xcb_input_touch_event_flags_t = enum_xcb_input_touch_event_flags_t;
pub const struct_xcb_input_touch_begin_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    detail: u32 = @import("std").mem.zeroes(u32),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
    root_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    root_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    event_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    event_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    buttons_len: u16 = @import("std").mem.zeroes(u16),
    valuators_len: u16 = @import("std").mem.zeroes(u16),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    flags: u32 = @import("std").mem.zeroes(u32),
    mods: xcb_input_modifier_info_t = @import("std").mem.zeroes(xcb_input_modifier_info_t),
    group: xcb_input_group_info_t = @import("std").mem.zeroes(xcb_input_group_info_t),
};
pub const xcb_input_touch_begin_event_t = struct_xcb_input_touch_begin_event_t;
pub const xcb_input_touch_update_event_t = xcb_input_touch_begin_event_t;
pub const xcb_input_touch_end_event_t = xcb_input_touch_begin_event_t;
pub const XCB_INPUT_TOUCH_OWNERSHIP_FLAGS_NONE: c_int = 0;
pub const enum_xcb_input_touch_ownership_flags_t = c_uint;
pub const xcb_input_touch_ownership_flags_t = enum_xcb_input_touch_ownership_flags_t;
pub const struct_xcb_input_touch_ownership_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    touchid: u32 = @import("std").mem.zeroes(u32),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    child: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    flags: u32 = @import("std").mem.zeroes(u32),
    pad1: [8]u8 = @import("std").mem.zeroes([8]u8),
};
pub const xcb_input_touch_ownership_event_t = struct_xcb_input_touch_ownership_event_t;
pub const struct_xcb_input_raw_touch_begin_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    detail: u32 = @import("std").mem.zeroes(u32),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    valuators_len: u16 = @import("std").mem.zeroes(u16),
    flags: u32 = @import("std").mem.zeroes(u32),
    pad0: [4]u8 = @import("std").mem.zeroes([4]u8),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
};
pub const xcb_input_raw_touch_begin_event_t = struct_xcb_input_raw_touch_begin_event_t;
pub const xcb_input_raw_touch_update_event_t = xcb_input_raw_touch_begin_event_t;
pub const xcb_input_raw_touch_end_event_t = xcb_input_raw_touch_begin_event_t;
pub const XCB_INPUT_BARRIER_FLAGS_POINTER_RELEASED: c_int = 1;
pub const XCB_INPUT_BARRIER_FLAGS_DEVICE_IS_GRABBED: c_int = 2;
pub const enum_xcb_input_barrier_flags_t = c_uint;
pub const xcb_input_barrier_flags_t = enum_xcb_input_barrier_flags_t;
pub const struct_xcb_input_barrier_hit_event_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    extension: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
    length: u32 = @import("std").mem.zeroes(u32),
    event_type: u16 = @import("std").mem.zeroes(u16),
    deviceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    time: xcb_timestamp_t = @import("std").mem.zeroes(xcb_timestamp_t),
    eventid: u32 = @import("std").mem.zeroes(u32),
    root: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    event: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    barrier: xcb_xfixes_barrier_t = @import("std").mem.zeroes(xcb_xfixes_barrier_t),
    full_sequence: u32 = @import("std").mem.zeroes(u32),
    dtime: u32 = @import("std").mem.zeroes(u32),
    flags: u32 = @import("std").mem.zeroes(u32),
    sourceid: xcb_input_device_id_t = @import("std").mem.zeroes(xcb_input_device_id_t),
    pad0: [2]u8 = @import("std").mem.zeroes([2]u8),
    root_x: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    root_y: xcb_input_fp1616_t = @import("std").mem.zeroes(xcb_input_fp1616_t),
    dx: xcb_input_fp3232_t = @import("std").mem.zeroes(xcb_input_fp3232_t),
    dy: xcb_input_fp3232_t = @import("std").mem.zeroes(xcb_input_fp3232_t),
};
pub const xcb_input_barrier_hit_event_t = struct_xcb_input_barrier_hit_event_t;
pub const xcb_input_barrier_leave_event_t = xcb_input_barrier_hit_event_t;
pub const union_xcb_input_event_for_send_t = extern union {
    device_valuator: xcb_input_device_valuator_event_t,
    device_key_press: xcb_input_device_key_press_event_t,
    device_key_release: xcb_input_device_key_release_event_t,
    device_button_press: xcb_input_device_button_press_event_t,
    device_button_release: xcb_input_device_button_release_event_t,
    device_motion_notify: xcb_input_device_motion_notify_event_t,
    device_focus_in: xcb_input_device_focus_in_event_t,
    device_focus_out: xcb_input_device_focus_out_event_t,
    proximity_in: xcb_input_proximity_in_event_t,
    proximity_out: xcb_input_proximity_out_event_t,
    device_state_notify: xcb_input_device_state_notify_event_t,
    device_mapping_notify: xcb_input_device_mapping_notify_event_t,
    change_device_notify: xcb_input_change_device_notify_event_t,
    device_key_state_notify: xcb_input_device_key_state_notify_event_t,
    device_button_state_notify: xcb_input_device_button_state_notify_event_t,
    device_presence_notify: xcb_input_device_presence_notify_event_t,
    event_header: xcb_raw_generic_event_t,
};
pub const xcb_input_event_for_send_t = union_xcb_input_event_for_send_t;
pub const struct_xcb_input_event_for_send_iterator_t = extern struct {
    data: [*c]xcb_input_event_for_send_t = @import("std").mem.zeroes([*c]xcb_input_event_for_send_t),
    rem: c_int = @import("std").mem.zeroes(c_int),
    index: c_int = @import("std").mem.zeroes(c_int),
};
pub const xcb_input_event_for_send_iterator_t = struct_xcb_input_event_for_send_iterator_t;
pub const struct_xcb_input_send_extension_event_request_t = extern struct {
    major_opcode: u8 = @import("std").mem.zeroes(u8),
    minor_opcode: u8 = @import("std").mem.zeroes(u8),
    length: u16 = @import("std").mem.zeroes(u16),
    destination: xcb_window_t = @import("std").mem.zeroes(xcb_window_t),
    device_id: u8 = @import("std").mem.zeroes(u8),
    propagate: u8 = @import("std").mem.zeroes(u8),
    num_classes: u16 = @import("std").mem.zeroes(u16),
    num_events: u8 = @import("std").mem.zeroes(u8),
    pad0: [3]u8 = @import("std").mem.zeroes([3]u8),
};
pub const xcb_input_send_extension_event_request_t = struct_xcb_input_send_extension_event_request_t;
pub const struct_xcb_input_device_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_device_error_t = struct_xcb_input_device_error_t;
pub const struct_xcb_input_event_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_event_error_t = struct_xcb_input_event_error_t;
pub const struct_xcb_input_mode_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_mode_error_t = struct_xcb_input_mode_error_t;
pub const struct_xcb_input_device_busy_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_device_busy_error_t = struct_xcb_input_device_busy_error_t;
pub const struct_xcb_input_class_error_t = extern struct {
    response_type: u8 = @import("std").mem.zeroes(u8),
    error_code: u8 = @import("std").mem.zeroes(u8),
    sequence: u16 = @import("std").mem.zeroes(u16),
};
pub const xcb_input_class_error_t = struct_xcb_input_class_error_t;
pub extern fn xcb_input_event_class_next(i: [*c]xcb_input_event_class_iterator_t) void;
pub extern fn xcb_input_event_class_end(i: xcb_input_event_class_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_key_code_next(i: [*c]xcb_input_key_code_iterator_t) void;
pub extern fn xcb_input_key_code_end(i: xcb_input_key_code_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_id_next(i: [*c]xcb_input_device_id_iterator_t) void;
pub extern fn xcb_input_device_id_end(i: xcb_input_device_id_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_fp1616_next(i: [*c]xcb_input_fp1616_iterator_t) void;
pub extern fn xcb_input_fp1616_end(i: xcb_input_fp1616_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_fp3232_next(i: [*c]xcb_input_fp3232_iterator_t) void;
pub extern fn xcb_input_fp3232_end(i: xcb_input_fp3232_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_extension_version_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_get_extension_version(c: ?*xcb_connection_t, name_len: u16, name: [*c]const u8) xcb_input_get_extension_version_cookie_t;
pub extern fn xcb_input_get_extension_version_unchecked(c: ?*xcb_connection_t, name_len: u16, name: [*c]const u8) xcb_input_get_extension_version_cookie_t;
pub extern fn xcb_input_get_extension_version_reply(c: ?*xcb_connection_t, cookie: xcb_input_get_extension_version_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_get_extension_version_reply_t;
pub extern fn xcb_input_device_info_next(i: [*c]xcb_input_device_info_iterator_t) void;
pub extern fn xcb_input_device_info_end(i: xcb_input_device_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_key_info_next(i: [*c]xcb_input_key_info_iterator_t) void;
pub extern fn xcb_input_key_info_end(i: xcb_input_key_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_button_info_next(i: [*c]xcb_input_button_info_iterator_t) void;
pub extern fn xcb_input_button_info_end(i: xcb_input_button_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_axis_info_next(i: [*c]xcb_input_axis_info_iterator_t) void;
pub extern fn xcb_input_axis_info_end(i: xcb_input_axis_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_valuator_info_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_valuator_info_axes(R: [*c]const xcb_input_valuator_info_t) [*c]xcb_input_axis_info_t;
pub extern fn xcb_input_valuator_info_axes_length(R: [*c]const xcb_input_valuator_info_t) c_int;
pub extern fn xcb_input_valuator_info_axes_iterator(R: [*c]const xcb_input_valuator_info_t) xcb_input_axis_info_iterator_t;
pub extern fn xcb_input_valuator_info_next(i: [*c]xcb_input_valuator_info_iterator_t) void;
pub extern fn xcb_input_valuator_info_end(i: xcb_input_valuator_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_input_info_info_valuator_axes(S: [*c]const xcb_input_input_info_info_t) [*c]xcb_input_axis_info_t;
pub extern fn xcb_input_input_info_info_valuator_axes_length(R: [*c]const xcb_input_input_info_t, S: [*c]const xcb_input_input_info_info_t) c_int;
pub extern fn xcb_input_input_info_info_valuator_axes_iterator(R: [*c]const xcb_input_input_info_t, S: [*c]const xcb_input_input_info_info_t) xcb_input_axis_info_iterator_t;
pub extern fn xcb_input_input_info_info_serialize(_buffer: [*c]?*anyopaque, class_id: u8, _aux: [*c]const xcb_input_input_info_info_t) c_int;
pub extern fn xcb_input_input_info_info_unpack(_buffer: ?*const anyopaque, class_id: u8, _aux: [*c]xcb_input_input_info_info_t) c_int;
pub extern fn xcb_input_input_info_info_sizeof(_buffer: ?*const anyopaque, class_id: u8) c_int;
pub extern fn xcb_input_input_info_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_input_info_next(i: [*c]xcb_input_input_info_iterator_t) void;
pub extern fn xcb_input_input_info_end(i: xcb_input_input_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_name_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_device_name_string(R: [*c]const xcb_input_device_name_t) [*c]u8;
pub extern fn xcb_input_device_name_string_length(R: [*c]const xcb_input_device_name_t) c_int;
pub extern fn xcb_input_device_name_string_end(R: [*c]const xcb_input_device_name_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_name_next(i: [*c]xcb_input_device_name_iterator_t) void;
pub extern fn xcb_input_device_name_end(i: xcb_input_device_name_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_list_input_devices_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_list_input_devices(c: ?*xcb_connection_t) xcb_input_list_input_devices_cookie_t;
pub extern fn xcb_input_list_input_devices_unchecked(c: ?*xcb_connection_t) xcb_input_list_input_devices_cookie_t;
pub extern fn xcb_input_list_input_devices_devices(R: [*c]const xcb_input_list_input_devices_reply_t) [*c]xcb_input_device_info_t;
pub extern fn xcb_input_list_input_devices_devices_length(R: [*c]const xcb_input_list_input_devices_reply_t) c_int;
pub extern fn xcb_input_list_input_devices_devices_iterator(R: [*c]const xcb_input_list_input_devices_reply_t) xcb_input_device_info_iterator_t;
pub extern fn xcb_input_list_input_devices_infos_length(R: [*c]const xcb_input_list_input_devices_reply_t) c_int;
pub extern fn xcb_input_list_input_devices_infos_iterator(R: [*c]const xcb_input_list_input_devices_reply_t) xcb_input_input_info_iterator_t;
pub extern fn xcb_input_list_input_devices_names_length(R: [*c]const xcb_input_list_input_devices_reply_t) c_int;
pub extern fn xcb_input_list_input_devices_names_iterator(R: [*c]const xcb_input_list_input_devices_reply_t) xcb_str_iterator_t;
pub extern fn xcb_input_list_input_devices_reply(c: ?*xcb_connection_t, cookie: xcb_input_list_input_devices_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_list_input_devices_reply_t;
pub extern fn xcb_input_event_type_base_next(i: [*c]xcb_input_event_type_base_iterator_t) void;
pub extern fn xcb_input_event_type_base_end(i: xcb_input_event_type_base_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_input_class_info_next(i: [*c]xcb_input_input_class_info_iterator_t) void;
pub extern fn xcb_input_input_class_info_end(i: xcb_input_input_class_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_open_device_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_open_device(c: ?*xcb_connection_t, device_id: u8) xcb_input_open_device_cookie_t;
pub extern fn xcb_input_open_device_unchecked(c: ?*xcb_connection_t, device_id: u8) xcb_input_open_device_cookie_t;
pub extern fn xcb_input_open_device_class_info(R: [*c]const xcb_input_open_device_reply_t) [*c]xcb_input_input_class_info_t;
pub extern fn xcb_input_open_device_class_info_length(R: [*c]const xcb_input_open_device_reply_t) c_int;
pub extern fn xcb_input_open_device_class_info_iterator(R: [*c]const xcb_input_open_device_reply_t) xcb_input_input_class_info_iterator_t;
pub extern fn xcb_input_open_device_reply(c: ?*xcb_connection_t, cookie: xcb_input_open_device_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_open_device_reply_t;
pub extern fn xcb_input_close_device_checked(c: ?*xcb_connection_t, device_id: u8) xcb_void_cookie_t;
pub extern fn xcb_input_close_device(c: ?*xcb_connection_t, device_id: u8) xcb_void_cookie_t;
pub extern fn xcb_input_set_device_mode(c: ?*xcb_connection_t, device_id: u8, mode: u8) xcb_input_set_device_mode_cookie_t;
pub extern fn xcb_input_set_device_mode_unchecked(c: ?*xcb_connection_t, device_id: u8, mode: u8) xcb_input_set_device_mode_cookie_t;
pub extern fn xcb_input_set_device_mode_reply(c: ?*xcb_connection_t, cookie: xcb_input_set_device_mode_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_set_device_mode_reply_t;
pub extern fn xcb_input_select_extension_event_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_select_extension_event_checked(c: ?*xcb_connection_t, window: xcb_window_t, num_classes: u16, classes: [*c]const xcb_input_event_class_t) xcb_void_cookie_t;
pub extern fn xcb_input_select_extension_event(c: ?*xcb_connection_t, window: xcb_window_t, num_classes: u16, classes: [*c]const xcb_input_event_class_t) xcb_void_cookie_t;
pub extern fn xcb_input_select_extension_event_classes(R: [*c]const xcb_input_select_extension_event_request_t) [*c]xcb_input_event_class_t;
pub extern fn xcb_input_select_extension_event_classes_length(R: [*c]const xcb_input_select_extension_event_request_t) c_int;
pub extern fn xcb_input_select_extension_event_classes_end(R: [*c]const xcb_input_select_extension_event_request_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_selected_extension_events_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_get_selected_extension_events(c: ?*xcb_connection_t, window: xcb_window_t) xcb_input_get_selected_extension_events_cookie_t;
pub extern fn xcb_input_get_selected_extension_events_unchecked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_input_get_selected_extension_events_cookie_t;
pub extern fn xcb_input_get_selected_extension_events_this_classes(R: [*c]const xcb_input_get_selected_extension_events_reply_t) [*c]xcb_input_event_class_t;
pub extern fn xcb_input_get_selected_extension_events_this_classes_length(R: [*c]const xcb_input_get_selected_extension_events_reply_t) c_int;
pub extern fn xcb_input_get_selected_extension_events_this_classes_end(R: [*c]const xcb_input_get_selected_extension_events_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_selected_extension_events_all_classes(R: [*c]const xcb_input_get_selected_extension_events_reply_t) [*c]xcb_input_event_class_t;
pub extern fn xcb_input_get_selected_extension_events_all_classes_length(R: [*c]const xcb_input_get_selected_extension_events_reply_t) c_int;
pub extern fn xcb_input_get_selected_extension_events_all_classes_end(R: [*c]const xcb_input_get_selected_extension_events_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_selected_extension_events_reply(c: ?*xcb_connection_t, cookie: xcb_input_get_selected_extension_events_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_get_selected_extension_events_reply_t;
pub extern fn xcb_input_change_device_dont_propagate_list_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_change_device_dont_propagate_list_checked(c: ?*xcb_connection_t, window: xcb_window_t, num_classes: u16, mode: u8, classes: [*c]const xcb_input_event_class_t) xcb_void_cookie_t;
pub extern fn xcb_input_change_device_dont_propagate_list(c: ?*xcb_connection_t, window: xcb_window_t, num_classes: u16, mode: u8, classes: [*c]const xcb_input_event_class_t) xcb_void_cookie_t;
pub extern fn xcb_input_change_device_dont_propagate_list_classes(R: [*c]const xcb_input_change_device_dont_propagate_list_request_t) [*c]xcb_input_event_class_t;
pub extern fn xcb_input_change_device_dont_propagate_list_classes_length(R: [*c]const xcb_input_change_device_dont_propagate_list_request_t) c_int;
pub extern fn xcb_input_change_device_dont_propagate_list_classes_end(R: [*c]const xcb_input_change_device_dont_propagate_list_request_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_device_dont_propagate_list_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_get_device_dont_propagate_list(c: ?*xcb_connection_t, window: xcb_window_t) xcb_input_get_device_dont_propagate_list_cookie_t;
pub extern fn xcb_input_get_device_dont_propagate_list_unchecked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_input_get_device_dont_propagate_list_cookie_t;
pub extern fn xcb_input_get_device_dont_propagate_list_classes(R: [*c]const xcb_input_get_device_dont_propagate_list_reply_t) [*c]xcb_input_event_class_t;
pub extern fn xcb_input_get_device_dont_propagate_list_classes_length(R: [*c]const xcb_input_get_device_dont_propagate_list_reply_t) c_int;
pub extern fn xcb_input_get_device_dont_propagate_list_classes_end(R: [*c]const xcb_input_get_device_dont_propagate_list_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_device_dont_propagate_list_reply(c: ?*xcb_connection_t, cookie: xcb_input_get_device_dont_propagate_list_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_get_device_dont_propagate_list_reply_t;
pub extern fn xcb_input_device_time_coord_sizeof(_buffer: ?*const anyopaque, num_axes: u8) c_int;
pub extern fn xcb_input_device_time_coord_axisvalues(R: [*c]const xcb_input_device_time_coord_t) [*c]i32;
pub extern fn xcb_input_device_time_coord_axisvalues_length(R: [*c]const xcb_input_device_time_coord_t, num_axes: u8) c_int;
pub extern fn xcb_input_device_time_coord_axisvalues_end(R: [*c]const xcb_input_device_time_coord_t, num_axes: u8) xcb_generic_iterator_t;
pub extern fn xcb_input_device_time_coord_next(i: [*c]xcb_input_device_time_coord_iterator_t) void;
pub extern fn xcb_input_device_time_coord_end(i: xcb_input_device_time_coord_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_device_motion_events_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_get_device_motion_events(c: ?*xcb_connection_t, start: xcb_timestamp_t, stop: xcb_timestamp_t, device_id: u8) xcb_input_get_device_motion_events_cookie_t;
pub extern fn xcb_input_get_device_motion_events_unchecked(c: ?*xcb_connection_t, start: xcb_timestamp_t, stop: xcb_timestamp_t, device_id: u8) xcb_input_get_device_motion_events_cookie_t;
pub extern fn xcb_input_get_device_motion_events_events_length(R: [*c]const xcb_input_get_device_motion_events_reply_t) c_int;
pub extern fn xcb_input_get_device_motion_events_events_iterator(R: [*c]const xcb_input_get_device_motion_events_reply_t) xcb_input_device_time_coord_iterator_t;
pub extern fn xcb_input_get_device_motion_events_reply(c: ?*xcb_connection_t, cookie: xcb_input_get_device_motion_events_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_get_device_motion_events_reply_t;
pub extern fn xcb_input_change_keyboard_device(c: ?*xcb_connection_t, device_id: u8) xcb_input_change_keyboard_device_cookie_t;
pub extern fn xcb_input_change_keyboard_device_unchecked(c: ?*xcb_connection_t, device_id: u8) xcb_input_change_keyboard_device_cookie_t;
pub extern fn xcb_input_change_keyboard_device_reply(c: ?*xcb_connection_t, cookie: xcb_input_change_keyboard_device_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_change_keyboard_device_reply_t;
pub extern fn xcb_input_change_pointer_device(c: ?*xcb_connection_t, x_axis: u8, y_axis: u8, device_id: u8) xcb_input_change_pointer_device_cookie_t;
pub extern fn xcb_input_change_pointer_device_unchecked(c: ?*xcb_connection_t, x_axis: u8, y_axis: u8, device_id: u8) xcb_input_change_pointer_device_cookie_t;
pub extern fn xcb_input_change_pointer_device_reply(c: ?*xcb_connection_t, cookie: xcb_input_change_pointer_device_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_change_pointer_device_reply_t;
pub extern fn xcb_input_grab_device_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_grab_device(c: ?*xcb_connection_t, grab_window: xcb_window_t, time: xcb_timestamp_t, num_classes: u16, this_device_mode: u8, other_device_mode: u8, owner_events: u8, device_id: u8, classes: [*c]const xcb_input_event_class_t) xcb_input_grab_device_cookie_t;
pub extern fn xcb_input_grab_device_unchecked(c: ?*xcb_connection_t, grab_window: xcb_window_t, time: xcb_timestamp_t, num_classes: u16, this_device_mode: u8, other_device_mode: u8, owner_events: u8, device_id: u8, classes: [*c]const xcb_input_event_class_t) xcb_input_grab_device_cookie_t;
pub extern fn xcb_input_grab_device_reply(c: ?*xcb_connection_t, cookie: xcb_input_grab_device_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_grab_device_reply_t;
pub extern fn xcb_input_ungrab_device_checked(c: ?*xcb_connection_t, time: xcb_timestamp_t, device_id: u8) xcb_void_cookie_t;
pub extern fn xcb_input_ungrab_device(c: ?*xcb_connection_t, time: xcb_timestamp_t, device_id: u8) xcb_void_cookie_t;
pub extern fn xcb_input_grab_device_key_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_grab_device_key_checked(c: ?*xcb_connection_t, grab_window: xcb_window_t, num_classes: u16, modifiers: u16, modifier_device: u8, grabbed_device: u8, key: u8, this_device_mode: u8, other_device_mode: u8, owner_events: u8, classes: [*c]const xcb_input_event_class_t) xcb_void_cookie_t;
pub extern fn xcb_input_grab_device_key(c: ?*xcb_connection_t, grab_window: xcb_window_t, num_classes: u16, modifiers: u16, modifier_device: u8, grabbed_device: u8, key: u8, this_device_mode: u8, other_device_mode: u8, owner_events: u8, classes: [*c]const xcb_input_event_class_t) xcb_void_cookie_t;
pub extern fn xcb_input_grab_device_key_classes(R: [*c]const xcb_input_grab_device_key_request_t) [*c]xcb_input_event_class_t;
pub extern fn xcb_input_grab_device_key_classes_length(R: [*c]const xcb_input_grab_device_key_request_t) c_int;
pub extern fn xcb_input_grab_device_key_classes_end(R: [*c]const xcb_input_grab_device_key_request_t) xcb_generic_iterator_t;
pub extern fn xcb_input_ungrab_device_key_checked(c: ?*xcb_connection_t, grabWindow: xcb_window_t, modifiers: u16, modifier_device: u8, key: u8, grabbed_device: u8) xcb_void_cookie_t;
pub extern fn xcb_input_ungrab_device_key(c: ?*xcb_connection_t, grabWindow: xcb_window_t, modifiers: u16, modifier_device: u8, key: u8, grabbed_device: u8) xcb_void_cookie_t;
pub extern fn xcb_input_grab_device_button_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_grab_device_button_checked(c: ?*xcb_connection_t, grab_window: xcb_window_t, grabbed_device: u8, modifier_device: u8, num_classes: u16, modifiers: u16, this_device_mode: u8, other_device_mode: u8, button: u8, owner_events: u8, classes: [*c]const xcb_input_event_class_t) xcb_void_cookie_t;
pub extern fn xcb_input_grab_device_button(c: ?*xcb_connection_t, grab_window: xcb_window_t, grabbed_device: u8, modifier_device: u8, num_classes: u16, modifiers: u16, this_device_mode: u8, other_device_mode: u8, button: u8, owner_events: u8, classes: [*c]const xcb_input_event_class_t) xcb_void_cookie_t;
pub extern fn xcb_input_grab_device_button_classes(R: [*c]const xcb_input_grab_device_button_request_t) [*c]xcb_input_event_class_t;
pub extern fn xcb_input_grab_device_button_classes_length(R: [*c]const xcb_input_grab_device_button_request_t) c_int;
pub extern fn xcb_input_grab_device_button_classes_end(R: [*c]const xcb_input_grab_device_button_request_t) xcb_generic_iterator_t;
pub extern fn xcb_input_ungrab_device_button_checked(c: ?*xcb_connection_t, grab_window: xcb_window_t, modifiers: u16, modifier_device: u8, button: u8, grabbed_device: u8) xcb_void_cookie_t;
pub extern fn xcb_input_ungrab_device_button(c: ?*xcb_connection_t, grab_window: xcb_window_t, modifiers: u16, modifier_device: u8, button: u8, grabbed_device: u8) xcb_void_cookie_t;
pub extern fn xcb_input_allow_device_events_checked(c: ?*xcb_connection_t, time: xcb_timestamp_t, mode: u8, device_id: u8) xcb_void_cookie_t;
pub extern fn xcb_input_allow_device_events(c: ?*xcb_connection_t, time: xcb_timestamp_t, mode: u8, device_id: u8) xcb_void_cookie_t;
pub extern fn xcb_input_get_device_focus(c: ?*xcb_connection_t, device_id: u8) xcb_input_get_device_focus_cookie_t;
pub extern fn xcb_input_get_device_focus_unchecked(c: ?*xcb_connection_t, device_id: u8) xcb_input_get_device_focus_cookie_t;
pub extern fn xcb_input_get_device_focus_reply(c: ?*xcb_connection_t, cookie: xcb_input_get_device_focus_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_get_device_focus_reply_t;
pub extern fn xcb_input_set_device_focus_checked(c: ?*xcb_connection_t, focus: xcb_window_t, time: xcb_timestamp_t, revert_to: u8, device_id: u8) xcb_void_cookie_t;
pub extern fn xcb_input_set_device_focus(c: ?*xcb_connection_t, focus: xcb_window_t, time: xcb_timestamp_t, revert_to: u8, device_id: u8) xcb_void_cookie_t;
pub extern fn xcb_input_kbd_feedback_state_next(i: [*c]xcb_input_kbd_feedback_state_iterator_t) void;
pub extern fn xcb_input_kbd_feedback_state_end(i: xcb_input_kbd_feedback_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_ptr_feedback_state_next(i: [*c]xcb_input_ptr_feedback_state_iterator_t) void;
pub extern fn xcb_input_ptr_feedback_state_end(i: xcb_input_ptr_feedback_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_integer_feedback_state_next(i: [*c]xcb_input_integer_feedback_state_iterator_t) void;
pub extern fn xcb_input_integer_feedback_state_end(i: xcb_input_integer_feedback_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_string_feedback_state_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_string_feedback_state_keysyms(R: [*c]const xcb_input_string_feedback_state_t) [*c]xcb_keysym_t;
pub extern fn xcb_input_string_feedback_state_keysyms_length(R: [*c]const xcb_input_string_feedback_state_t) c_int;
pub extern fn xcb_input_string_feedback_state_keysyms_end(R: [*c]const xcb_input_string_feedback_state_t) xcb_generic_iterator_t;
pub extern fn xcb_input_string_feedback_state_next(i: [*c]xcb_input_string_feedback_state_iterator_t) void;
pub extern fn xcb_input_string_feedback_state_end(i: xcb_input_string_feedback_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_bell_feedback_state_next(i: [*c]xcb_input_bell_feedback_state_iterator_t) void;
pub extern fn xcb_input_bell_feedback_state_end(i: xcb_input_bell_feedback_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_led_feedback_state_next(i: [*c]xcb_input_led_feedback_state_iterator_t) void;
pub extern fn xcb_input_led_feedback_state_end(i: xcb_input_led_feedback_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_feedback_state_data_string_keysyms(S: [*c]const xcb_input_feedback_state_data_t) [*c]xcb_keysym_t;
pub extern fn xcb_input_feedback_state_data_string_keysyms_length(R: [*c]const xcb_input_feedback_state_t, S: [*c]const xcb_input_feedback_state_data_t) c_int;
pub extern fn xcb_input_feedback_state_data_string_keysyms_end(R: [*c]const xcb_input_feedback_state_t, S: [*c]const xcb_input_feedback_state_data_t) xcb_generic_iterator_t;
pub extern fn xcb_input_feedback_state_data_serialize(_buffer: [*c]?*anyopaque, class_id: u8, _aux: [*c]const xcb_input_feedback_state_data_t) c_int;
pub extern fn xcb_input_feedback_state_data_unpack(_buffer: ?*const anyopaque, class_id: u8, _aux: [*c]xcb_input_feedback_state_data_t) c_int;
pub extern fn xcb_input_feedback_state_data_sizeof(_buffer: ?*const anyopaque, class_id: u8) c_int;
pub extern fn xcb_input_feedback_state_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_feedback_state_next(i: [*c]xcb_input_feedback_state_iterator_t) void;
pub extern fn xcb_input_feedback_state_end(i: xcb_input_feedback_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_feedback_control_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_get_feedback_control(c: ?*xcb_connection_t, device_id: u8) xcb_input_get_feedback_control_cookie_t;
pub extern fn xcb_input_get_feedback_control_unchecked(c: ?*xcb_connection_t, device_id: u8) xcb_input_get_feedback_control_cookie_t;
pub extern fn xcb_input_get_feedback_control_feedbacks_length(R: [*c]const xcb_input_get_feedback_control_reply_t) c_int;
pub extern fn xcb_input_get_feedback_control_feedbacks_iterator(R: [*c]const xcb_input_get_feedback_control_reply_t) xcb_input_feedback_state_iterator_t;
pub extern fn xcb_input_get_feedback_control_reply(c: ?*xcb_connection_t, cookie: xcb_input_get_feedback_control_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_get_feedback_control_reply_t;
pub extern fn xcb_input_kbd_feedback_ctl_next(i: [*c]xcb_input_kbd_feedback_ctl_iterator_t) void;
pub extern fn xcb_input_kbd_feedback_ctl_end(i: xcb_input_kbd_feedback_ctl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_ptr_feedback_ctl_next(i: [*c]xcb_input_ptr_feedback_ctl_iterator_t) void;
pub extern fn xcb_input_ptr_feedback_ctl_end(i: xcb_input_ptr_feedback_ctl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_integer_feedback_ctl_next(i: [*c]xcb_input_integer_feedback_ctl_iterator_t) void;
pub extern fn xcb_input_integer_feedback_ctl_end(i: xcb_input_integer_feedback_ctl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_string_feedback_ctl_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_string_feedback_ctl_keysyms(R: [*c]const xcb_input_string_feedback_ctl_t) [*c]xcb_keysym_t;
pub extern fn xcb_input_string_feedback_ctl_keysyms_length(R: [*c]const xcb_input_string_feedback_ctl_t) c_int;
pub extern fn xcb_input_string_feedback_ctl_keysyms_end(R: [*c]const xcb_input_string_feedback_ctl_t) xcb_generic_iterator_t;
pub extern fn xcb_input_string_feedback_ctl_next(i: [*c]xcb_input_string_feedback_ctl_iterator_t) void;
pub extern fn xcb_input_string_feedback_ctl_end(i: xcb_input_string_feedback_ctl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_bell_feedback_ctl_next(i: [*c]xcb_input_bell_feedback_ctl_iterator_t) void;
pub extern fn xcb_input_bell_feedback_ctl_end(i: xcb_input_bell_feedback_ctl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_led_feedback_ctl_next(i: [*c]xcb_input_led_feedback_ctl_iterator_t) void;
pub extern fn xcb_input_led_feedback_ctl_end(i: xcb_input_led_feedback_ctl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_feedback_ctl_data_string_keysyms(S: [*c]const xcb_input_feedback_ctl_data_t) [*c]xcb_keysym_t;
pub extern fn xcb_input_feedback_ctl_data_string_keysyms_length(R: [*c]const xcb_input_feedback_ctl_t, S: [*c]const xcb_input_feedback_ctl_data_t) c_int;
pub extern fn xcb_input_feedback_ctl_data_string_keysyms_end(R: [*c]const xcb_input_feedback_ctl_t, S: [*c]const xcb_input_feedback_ctl_data_t) xcb_generic_iterator_t;
pub extern fn xcb_input_feedback_ctl_data_serialize(_buffer: [*c]?*anyopaque, class_id: u8, _aux: [*c]const xcb_input_feedback_ctl_data_t) c_int;
pub extern fn xcb_input_feedback_ctl_data_unpack(_buffer: ?*const anyopaque, class_id: u8, _aux: [*c]xcb_input_feedback_ctl_data_t) c_int;
pub extern fn xcb_input_feedback_ctl_data_sizeof(_buffer: ?*const anyopaque, class_id: u8) c_int;
pub extern fn xcb_input_feedback_ctl_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_feedback_ctl_next(i: [*c]xcb_input_feedback_ctl_iterator_t) void;
pub extern fn xcb_input_feedback_ctl_end(i: xcb_input_feedback_ctl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_change_feedback_control_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_change_feedback_control_checked(c: ?*xcb_connection_t, mask: u32, device_id: u8, feedback_id: u8, feedback: [*c]xcb_input_feedback_ctl_t) xcb_void_cookie_t;
pub extern fn xcb_input_change_feedback_control(c: ?*xcb_connection_t, mask: u32, device_id: u8, feedback_id: u8, feedback: [*c]xcb_input_feedback_ctl_t) xcb_void_cookie_t;
pub extern fn xcb_input_change_feedback_control_feedback(R: [*c]const xcb_input_change_feedback_control_request_t) [*c]xcb_input_feedback_ctl_t;
pub extern fn xcb_input_get_device_key_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_get_device_key_mapping(c: ?*xcb_connection_t, device_id: u8, first_keycode: xcb_input_key_code_t, count: u8) xcb_input_get_device_key_mapping_cookie_t;
pub extern fn xcb_input_get_device_key_mapping_unchecked(c: ?*xcb_connection_t, device_id: u8, first_keycode: xcb_input_key_code_t, count: u8) xcb_input_get_device_key_mapping_cookie_t;
pub extern fn xcb_input_get_device_key_mapping_keysyms(R: [*c]const xcb_input_get_device_key_mapping_reply_t) [*c]xcb_keysym_t;
pub extern fn xcb_input_get_device_key_mapping_keysyms_length(R: [*c]const xcb_input_get_device_key_mapping_reply_t) c_int;
pub extern fn xcb_input_get_device_key_mapping_keysyms_end(R: [*c]const xcb_input_get_device_key_mapping_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_device_key_mapping_reply(c: ?*xcb_connection_t, cookie: xcb_input_get_device_key_mapping_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_get_device_key_mapping_reply_t;
pub extern fn xcb_input_change_device_key_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_change_device_key_mapping_checked(c: ?*xcb_connection_t, device_id: u8, first_keycode: xcb_input_key_code_t, keysyms_per_keycode: u8, keycode_count: u8, keysyms: [*c]const xcb_keysym_t) xcb_void_cookie_t;
pub extern fn xcb_input_change_device_key_mapping(c: ?*xcb_connection_t, device_id: u8, first_keycode: xcb_input_key_code_t, keysyms_per_keycode: u8, keycode_count: u8, keysyms: [*c]const xcb_keysym_t) xcb_void_cookie_t;
pub extern fn xcb_input_change_device_key_mapping_keysyms(R: [*c]const xcb_input_change_device_key_mapping_request_t) [*c]xcb_keysym_t;
pub extern fn xcb_input_change_device_key_mapping_keysyms_length(R: [*c]const xcb_input_change_device_key_mapping_request_t) c_int;
pub extern fn xcb_input_change_device_key_mapping_keysyms_end(R: [*c]const xcb_input_change_device_key_mapping_request_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_device_modifier_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_get_device_modifier_mapping(c: ?*xcb_connection_t, device_id: u8) xcb_input_get_device_modifier_mapping_cookie_t;
pub extern fn xcb_input_get_device_modifier_mapping_unchecked(c: ?*xcb_connection_t, device_id: u8) xcb_input_get_device_modifier_mapping_cookie_t;
pub extern fn xcb_input_get_device_modifier_mapping_keymaps(R: [*c]const xcb_input_get_device_modifier_mapping_reply_t) [*c]u8;
pub extern fn xcb_input_get_device_modifier_mapping_keymaps_length(R: [*c]const xcb_input_get_device_modifier_mapping_reply_t) c_int;
pub extern fn xcb_input_get_device_modifier_mapping_keymaps_end(R: [*c]const xcb_input_get_device_modifier_mapping_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_device_modifier_mapping_reply(c: ?*xcb_connection_t, cookie: xcb_input_get_device_modifier_mapping_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_get_device_modifier_mapping_reply_t;
pub extern fn xcb_input_set_device_modifier_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_set_device_modifier_mapping(c: ?*xcb_connection_t, device_id: u8, keycodes_per_modifier: u8, keymaps: [*c]const u8) xcb_input_set_device_modifier_mapping_cookie_t;
pub extern fn xcb_input_set_device_modifier_mapping_unchecked(c: ?*xcb_connection_t, device_id: u8, keycodes_per_modifier: u8, keymaps: [*c]const u8) xcb_input_set_device_modifier_mapping_cookie_t;
pub extern fn xcb_input_set_device_modifier_mapping_reply(c: ?*xcb_connection_t, cookie: xcb_input_set_device_modifier_mapping_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_set_device_modifier_mapping_reply_t;
pub extern fn xcb_input_get_device_button_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_get_device_button_mapping(c: ?*xcb_connection_t, device_id: u8) xcb_input_get_device_button_mapping_cookie_t;
pub extern fn xcb_input_get_device_button_mapping_unchecked(c: ?*xcb_connection_t, device_id: u8) xcb_input_get_device_button_mapping_cookie_t;
pub extern fn xcb_input_get_device_button_mapping_map(R: [*c]const xcb_input_get_device_button_mapping_reply_t) [*c]u8;
pub extern fn xcb_input_get_device_button_mapping_map_length(R: [*c]const xcb_input_get_device_button_mapping_reply_t) c_int;
pub extern fn xcb_input_get_device_button_mapping_map_end(R: [*c]const xcb_input_get_device_button_mapping_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_device_button_mapping_reply(c: ?*xcb_connection_t, cookie: xcb_input_get_device_button_mapping_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_get_device_button_mapping_reply_t;
pub extern fn xcb_input_set_device_button_mapping_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_set_device_button_mapping(c: ?*xcb_connection_t, device_id: u8, map_size: u8, map: [*c]const u8) xcb_input_set_device_button_mapping_cookie_t;
pub extern fn xcb_input_set_device_button_mapping_unchecked(c: ?*xcb_connection_t, device_id: u8, map_size: u8, map: [*c]const u8) xcb_input_set_device_button_mapping_cookie_t;
pub extern fn xcb_input_set_device_button_mapping_reply(c: ?*xcb_connection_t, cookie: xcb_input_set_device_button_mapping_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_set_device_button_mapping_reply_t;
pub extern fn xcb_input_key_state_next(i: [*c]xcb_input_key_state_iterator_t) void;
pub extern fn xcb_input_key_state_end(i: xcb_input_key_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_button_state_next(i: [*c]xcb_input_button_state_iterator_t) void;
pub extern fn xcb_input_button_state_end(i: xcb_input_button_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_valuator_state_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_valuator_state_valuators(R: [*c]const xcb_input_valuator_state_t) [*c]i32;
pub extern fn xcb_input_valuator_state_valuators_length(R: [*c]const xcb_input_valuator_state_t) c_int;
pub extern fn xcb_input_valuator_state_valuators_end(R: [*c]const xcb_input_valuator_state_t) xcb_generic_iterator_t;
pub extern fn xcb_input_valuator_state_next(i: [*c]xcb_input_valuator_state_iterator_t) void;
pub extern fn xcb_input_valuator_state_end(i: xcb_input_valuator_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_input_state_data_valuator_valuators(S: [*c]const xcb_input_input_state_data_t) [*c]i32;
pub extern fn xcb_input_input_state_data_valuator_valuators_length(R: [*c]const xcb_input_input_state_t, S: [*c]const xcb_input_input_state_data_t) c_int;
pub extern fn xcb_input_input_state_data_valuator_valuators_end(R: [*c]const xcb_input_input_state_t, S: [*c]const xcb_input_input_state_data_t) xcb_generic_iterator_t;
pub extern fn xcb_input_input_state_data_serialize(_buffer: [*c]?*anyopaque, class_id: u8, _aux: [*c]const xcb_input_input_state_data_t) c_int;
pub extern fn xcb_input_input_state_data_unpack(_buffer: ?*const anyopaque, class_id: u8, _aux: [*c]xcb_input_input_state_data_t) c_int;
pub extern fn xcb_input_input_state_data_sizeof(_buffer: ?*const anyopaque, class_id: u8) c_int;
pub extern fn xcb_input_input_state_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_input_state_next(i: [*c]xcb_input_input_state_iterator_t) void;
pub extern fn xcb_input_input_state_end(i: xcb_input_input_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_query_device_state_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_query_device_state(c: ?*xcb_connection_t, device_id: u8) xcb_input_query_device_state_cookie_t;
pub extern fn xcb_input_query_device_state_unchecked(c: ?*xcb_connection_t, device_id: u8) xcb_input_query_device_state_cookie_t;
pub extern fn xcb_input_query_device_state_classes_length(R: [*c]const xcb_input_query_device_state_reply_t) c_int;
pub extern fn xcb_input_query_device_state_classes_iterator(R: [*c]const xcb_input_query_device_state_reply_t) xcb_input_input_state_iterator_t;
pub extern fn xcb_input_query_device_state_reply(c: ?*xcb_connection_t, cookie: xcb_input_query_device_state_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_query_device_state_reply_t;
pub extern fn xcb_input_device_bell_checked(c: ?*xcb_connection_t, device_id: u8, feedback_id: u8, feedback_class: u8, percent: i8) xcb_void_cookie_t;
pub extern fn xcb_input_device_bell(c: ?*xcb_connection_t, device_id: u8, feedback_id: u8, feedback_class: u8, percent: i8) xcb_void_cookie_t;
pub extern fn xcb_input_set_device_valuators_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_set_device_valuators(c: ?*xcb_connection_t, device_id: u8, first_valuator: u8, num_valuators: u8, valuators: [*c]const i32) xcb_input_set_device_valuators_cookie_t;
pub extern fn xcb_input_set_device_valuators_unchecked(c: ?*xcb_connection_t, device_id: u8, first_valuator: u8, num_valuators: u8, valuators: [*c]const i32) xcb_input_set_device_valuators_cookie_t;
pub extern fn xcb_input_set_device_valuators_reply(c: ?*xcb_connection_t, cookie: xcb_input_set_device_valuators_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_set_device_valuators_reply_t;
pub extern fn xcb_input_device_resolution_state_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_device_resolution_state_resolution_values(R: [*c]const xcb_input_device_resolution_state_t) [*c]u32;
pub extern fn xcb_input_device_resolution_state_resolution_values_length(R: [*c]const xcb_input_device_resolution_state_t) c_int;
pub extern fn xcb_input_device_resolution_state_resolution_values_end(R: [*c]const xcb_input_device_resolution_state_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_resolution_state_resolution_min(R: [*c]const xcb_input_device_resolution_state_t) [*c]u32;
pub extern fn xcb_input_device_resolution_state_resolution_min_length(R: [*c]const xcb_input_device_resolution_state_t) c_int;
pub extern fn xcb_input_device_resolution_state_resolution_min_end(R: [*c]const xcb_input_device_resolution_state_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_resolution_state_resolution_max(R: [*c]const xcb_input_device_resolution_state_t) [*c]u32;
pub extern fn xcb_input_device_resolution_state_resolution_max_length(R: [*c]const xcb_input_device_resolution_state_t) c_int;
pub extern fn xcb_input_device_resolution_state_resolution_max_end(R: [*c]const xcb_input_device_resolution_state_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_resolution_state_next(i: [*c]xcb_input_device_resolution_state_iterator_t) void;
pub extern fn xcb_input_device_resolution_state_end(i: xcb_input_device_resolution_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_abs_calib_state_next(i: [*c]xcb_input_device_abs_calib_state_iterator_t) void;
pub extern fn xcb_input_device_abs_calib_state_end(i: xcb_input_device_abs_calib_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_abs_area_state_next(i: [*c]xcb_input_device_abs_area_state_iterator_t) void;
pub extern fn xcb_input_device_abs_area_state_end(i: xcb_input_device_abs_area_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_core_state_next(i: [*c]xcb_input_device_core_state_iterator_t) void;
pub extern fn xcb_input_device_core_state_end(i: xcb_input_device_core_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_enable_state_next(i: [*c]xcb_input_device_enable_state_iterator_t) void;
pub extern fn xcb_input_device_enable_state_end(i: xcb_input_device_enable_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_state_data_resolution_resolution_values(S: [*c]const xcb_input_device_state_data_t) [*c]u32;
pub extern fn xcb_input_device_state_data_resolution_resolution_values_length(R: [*c]const xcb_input_device_state_t, S: [*c]const xcb_input_device_state_data_t) c_int;
pub extern fn xcb_input_device_state_data_resolution_resolution_values_end(R: [*c]const xcb_input_device_state_t, S: [*c]const xcb_input_device_state_data_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_state_data_resolution_resolution_min(S: [*c]const xcb_input_device_state_data_t) [*c]u32;
pub extern fn xcb_input_device_state_data_resolution_resolution_min_length(R: [*c]const xcb_input_device_state_t, S: [*c]const xcb_input_device_state_data_t) c_int;
pub extern fn xcb_input_device_state_data_resolution_resolution_min_end(R: [*c]const xcb_input_device_state_t, S: [*c]const xcb_input_device_state_data_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_state_data_resolution_resolution_max(S: [*c]const xcb_input_device_state_data_t) [*c]u32;
pub extern fn xcb_input_device_state_data_resolution_resolution_max_length(R: [*c]const xcb_input_device_state_t, S: [*c]const xcb_input_device_state_data_t) c_int;
pub extern fn xcb_input_device_state_data_resolution_resolution_max_end(R: [*c]const xcb_input_device_state_t, S: [*c]const xcb_input_device_state_data_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_state_data_serialize(_buffer: [*c]?*anyopaque, control_id: u16, _aux: [*c]const xcb_input_device_state_data_t) c_int;
pub extern fn xcb_input_device_state_data_unpack(_buffer: ?*const anyopaque, control_id: u16, _aux: [*c]xcb_input_device_state_data_t) c_int;
pub extern fn xcb_input_device_state_data_sizeof(_buffer: ?*const anyopaque, control_id: u16) c_int;
pub extern fn xcb_input_device_state_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_device_state_next(i: [*c]xcb_input_device_state_iterator_t) void;
pub extern fn xcb_input_device_state_end(i: xcb_input_device_state_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_device_control_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_get_device_control(c: ?*xcb_connection_t, control_id: u16, device_id: u8) xcb_input_get_device_control_cookie_t;
pub extern fn xcb_input_get_device_control_unchecked(c: ?*xcb_connection_t, control_id: u16, device_id: u8) xcb_input_get_device_control_cookie_t;
pub extern fn xcb_input_get_device_control_control(R: [*c]const xcb_input_get_device_control_reply_t) [*c]xcb_input_device_state_t;
pub extern fn xcb_input_get_device_control_reply(c: ?*xcb_connection_t, cookie: xcb_input_get_device_control_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_get_device_control_reply_t;
pub extern fn xcb_input_device_resolution_ctl_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_device_resolution_ctl_resolution_values(R: [*c]const xcb_input_device_resolution_ctl_t) [*c]u32;
pub extern fn xcb_input_device_resolution_ctl_resolution_values_length(R: [*c]const xcb_input_device_resolution_ctl_t) c_int;
pub extern fn xcb_input_device_resolution_ctl_resolution_values_end(R: [*c]const xcb_input_device_resolution_ctl_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_resolution_ctl_next(i: [*c]xcb_input_device_resolution_ctl_iterator_t) void;
pub extern fn xcb_input_device_resolution_ctl_end(i: xcb_input_device_resolution_ctl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_abs_calib_ctl_next(i: [*c]xcb_input_device_abs_calib_ctl_iterator_t) void;
pub extern fn xcb_input_device_abs_calib_ctl_end(i: xcb_input_device_abs_calib_ctl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_abs_area_ctrl_next(i: [*c]xcb_input_device_abs_area_ctrl_iterator_t) void;
pub extern fn xcb_input_device_abs_area_ctrl_end(i: xcb_input_device_abs_area_ctrl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_core_ctrl_next(i: [*c]xcb_input_device_core_ctrl_iterator_t) void;
pub extern fn xcb_input_device_core_ctrl_end(i: xcb_input_device_core_ctrl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_enable_ctrl_next(i: [*c]xcb_input_device_enable_ctrl_iterator_t) void;
pub extern fn xcb_input_device_enable_ctrl_end(i: xcb_input_device_enable_ctrl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_ctl_data_resolution_resolution_values(S: [*c]const xcb_input_device_ctl_data_t) [*c]u32;
pub extern fn xcb_input_device_ctl_data_resolution_resolution_values_length(R: [*c]const xcb_input_device_ctl_t, S: [*c]const xcb_input_device_ctl_data_t) c_int;
pub extern fn xcb_input_device_ctl_data_resolution_resolution_values_end(R: [*c]const xcb_input_device_ctl_t, S: [*c]const xcb_input_device_ctl_data_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_ctl_data_serialize(_buffer: [*c]?*anyopaque, control_id: u16, _aux: [*c]const xcb_input_device_ctl_data_t) c_int;
pub extern fn xcb_input_device_ctl_data_unpack(_buffer: ?*const anyopaque, control_id: u16, _aux: [*c]xcb_input_device_ctl_data_t) c_int;
pub extern fn xcb_input_device_ctl_data_sizeof(_buffer: ?*const anyopaque, control_id: u16) c_int;
pub extern fn xcb_input_device_ctl_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_device_ctl_next(i: [*c]xcb_input_device_ctl_iterator_t) void;
pub extern fn xcb_input_device_ctl_end(i: xcb_input_device_ctl_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_change_device_control_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_change_device_control(c: ?*xcb_connection_t, control_id: u16, device_id: u8, control: [*c]xcb_input_device_ctl_t) xcb_input_change_device_control_cookie_t;
pub extern fn xcb_input_change_device_control_unchecked(c: ?*xcb_connection_t, control_id: u16, device_id: u8, control: [*c]xcb_input_device_ctl_t) xcb_input_change_device_control_cookie_t;
pub extern fn xcb_input_change_device_control_reply(c: ?*xcb_connection_t, cookie: xcb_input_change_device_control_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_change_device_control_reply_t;
pub extern fn xcb_input_list_device_properties_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_list_device_properties(c: ?*xcb_connection_t, device_id: u8) xcb_input_list_device_properties_cookie_t;
pub extern fn xcb_input_list_device_properties_unchecked(c: ?*xcb_connection_t, device_id: u8) xcb_input_list_device_properties_cookie_t;
pub extern fn xcb_input_list_device_properties_atoms(R: [*c]const xcb_input_list_device_properties_reply_t) [*c]xcb_atom_t;
pub extern fn xcb_input_list_device_properties_atoms_length(R: [*c]const xcb_input_list_device_properties_reply_t) c_int;
pub extern fn xcb_input_list_device_properties_atoms_end(R: [*c]const xcb_input_list_device_properties_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_input_list_device_properties_reply(c: ?*xcb_connection_t, cookie: xcb_input_list_device_properties_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_list_device_properties_reply_t;
pub extern fn xcb_input_change_device_property_items_data_8(S: [*c]const xcb_input_change_device_property_items_t) [*c]u8;
pub extern fn xcb_input_change_device_property_items_data_8_length(R: [*c]const xcb_input_change_device_property_request_t, S: [*c]const xcb_input_change_device_property_items_t) c_int;
pub extern fn xcb_input_change_device_property_items_data_8_end(R: [*c]const xcb_input_change_device_property_request_t, S: [*c]const xcb_input_change_device_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_change_device_property_items_data_16(S: [*c]const xcb_input_change_device_property_items_t) [*c]u16;
pub extern fn xcb_input_change_device_property_items_data_16_length(R: [*c]const xcb_input_change_device_property_request_t, S: [*c]const xcb_input_change_device_property_items_t) c_int;
pub extern fn xcb_input_change_device_property_items_data_16_end(R: [*c]const xcb_input_change_device_property_request_t, S: [*c]const xcb_input_change_device_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_change_device_property_items_data_32(S: [*c]const xcb_input_change_device_property_items_t) [*c]u32;
pub extern fn xcb_input_change_device_property_items_data_32_length(R: [*c]const xcb_input_change_device_property_request_t, S: [*c]const xcb_input_change_device_property_items_t) c_int;
pub extern fn xcb_input_change_device_property_items_data_32_end(R: [*c]const xcb_input_change_device_property_request_t, S: [*c]const xcb_input_change_device_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_change_device_property_items_serialize(_buffer: [*c]?*anyopaque, num_items: u32, format: u8, _aux: [*c]const xcb_input_change_device_property_items_t) c_int;
pub extern fn xcb_input_change_device_property_items_unpack(_buffer: ?*const anyopaque, num_items: u32, format: u8, _aux: [*c]xcb_input_change_device_property_items_t) c_int;
pub extern fn xcb_input_change_device_property_items_sizeof(_buffer: ?*const anyopaque, num_items: u32, format: u8) c_int;
pub extern fn xcb_input_change_device_property_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_change_device_property_checked(c: ?*xcb_connection_t, property: xcb_atom_t, @"type": xcb_atom_t, device_id: u8, format: u8, mode: u8, num_items: u32, items: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_input_change_device_property(c: ?*xcb_connection_t, property: xcb_atom_t, @"type": xcb_atom_t, device_id: u8, format: u8, mode: u8, num_items: u32, items: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_input_change_device_property_aux_checked(c: ?*xcb_connection_t, property: xcb_atom_t, @"type": xcb_atom_t, device_id: u8, format: u8, mode: u8, num_items: u32, items: [*c]const xcb_input_change_device_property_items_t) xcb_void_cookie_t;
pub extern fn xcb_input_change_device_property_aux(c: ?*xcb_connection_t, property: xcb_atom_t, @"type": xcb_atom_t, device_id: u8, format: u8, mode: u8, num_items: u32, items: [*c]const xcb_input_change_device_property_items_t) xcb_void_cookie_t;
pub extern fn xcb_input_change_device_property_items(R: [*c]const xcb_input_change_device_property_request_t) ?*anyopaque;
pub extern fn xcb_input_delete_device_property_checked(c: ?*xcb_connection_t, property: xcb_atom_t, device_id: u8) xcb_void_cookie_t;
pub extern fn xcb_input_delete_device_property(c: ?*xcb_connection_t, property: xcb_atom_t, device_id: u8) xcb_void_cookie_t;
pub extern fn xcb_input_get_device_property_items_data_8(S: [*c]const xcb_input_get_device_property_items_t) [*c]u8;
pub extern fn xcb_input_get_device_property_items_data_8_length(R: [*c]const xcb_input_get_device_property_reply_t, S: [*c]const xcb_input_get_device_property_items_t) c_int;
pub extern fn xcb_input_get_device_property_items_data_8_end(R: [*c]const xcb_input_get_device_property_reply_t, S: [*c]const xcb_input_get_device_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_device_property_items_data_16(S: [*c]const xcb_input_get_device_property_items_t) [*c]u16;
pub extern fn xcb_input_get_device_property_items_data_16_length(R: [*c]const xcb_input_get_device_property_reply_t, S: [*c]const xcb_input_get_device_property_items_t) c_int;
pub extern fn xcb_input_get_device_property_items_data_16_end(R: [*c]const xcb_input_get_device_property_reply_t, S: [*c]const xcb_input_get_device_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_device_property_items_data_32(S: [*c]const xcb_input_get_device_property_items_t) [*c]u32;
pub extern fn xcb_input_get_device_property_items_data_32_length(R: [*c]const xcb_input_get_device_property_reply_t, S: [*c]const xcb_input_get_device_property_items_t) c_int;
pub extern fn xcb_input_get_device_property_items_data_32_end(R: [*c]const xcb_input_get_device_property_reply_t, S: [*c]const xcb_input_get_device_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_get_device_property_items_serialize(_buffer: [*c]?*anyopaque, num_items: u32, format: u8, _aux: [*c]const xcb_input_get_device_property_items_t) c_int;
pub extern fn xcb_input_get_device_property_items_unpack(_buffer: ?*const anyopaque, num_items: u32, format: u8, _aux: [*c]xcb_input_get_device_property_items_t) c_int;
pub extern fn xcb_input_get_device_property_items_sizeof(_buffer: ?*const anyopaque, num_items: u32, format: u8) c_int;
pub extern fn xcb_input_get_device_property_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_get_device_property(c: ?*xcb_connection_t, property: xcb_atom_t, @"type": xcb_atom_t, offset: u32, len: u32, device_id: u8, _delete: u8) xcb_input_get_device_property_cookie_t;
pub extern fn xcb_input_get_device_property_unchecked(c: ?*xcb_connection_t, property: xcb_atom_t, @"type": xcb_atom_t, offset: u32, len: u32, device_id: u8, _delete: u8) xcb_input_get_device_property_cookie_t;
pub extern fn xcb_input_get_device_property_items(R: [*c]const xcb_input_get_device_property_reply_t) ?*anyopaque;
pub extern fn xcb_input_get_device_property_reply(c: ?*xcb_connection_t, cookie: xcb_input_get_device_property_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_get_device_property_reply_t;
pub extern fn xcb_input_group_info_next(i: [*c]xcb_input_group_info_iterator_t) void;
pub extern fn xcb_input_group_info_end(i: xcb_input_group_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_modifier_info_next(i: [*c]xcb_input_modifier_info_iterator_t) void;
pub extern fn xcb_input_modifier_info_end(i: xcb_input_modifier_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_query_pointer_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_query_pointer(c: ?*xcb_connection_t, window: xcb_window_t, deviceid: xcb_input_device_id_t) xcb_input_xi_query_pointer_cookie_t;
pub extern fn xcb_input_xi_query_pointer_unchecked(c: ?*xcb_connection_t, window: xcb_window_t, deviceid: xcb_input_device_id_t) xcb_input_xi_query_pointer_cookie_t;
pub extern fn xcb_input_xi_query_pointer_buttons(R: [*c]const xcb_input_xi_query_pointer_reply_t) [*c]u32;
pub extern fn xcb_input_xi_query_pointer_buttons_length(R: [*c]const xcb_input_xi_query_pointer_reply_t) c_int;
pub extern fn xcb_input_xi_query_pointer_buttons_end(R: [*c]const xcb_input_xi_query_pointer_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_query_pointer_reply(c: ?*xcb_connection_t, cookie: xcb_input_xi_query_pointer_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_xi_query_pointer_reply_t;
pub extern fn xcb_input_xi_warp_pointer_checked(c: ?*xcb_connection_t, src_win: xcb_window_t, dst_win: xcb_window_t, src_x: xcb_input_fp1616_t, src_y: xcb_input_fp1616_t, src_width: u16, src_height: u16, dst_x: xcb_input_fp1616_t, dst_y: xcb_input_fp1616_t, deviceid: xcb_input_device_id_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_warp_pointer(c: ?*xcb_connection_t, src_win: xcb_window_t, dst_win: xcb_window_t, src_x: xcb_input_fp1616_t, src_y: xcb_input_fp1616_t, src_width: u16, src_height: u16, dst_x: xcb_input_fp1616_t, dst_y: xcb_input_fp1616_t, deviceid: xcb_input_device_id_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_change_cursor_checked(c: ?*xcb_connection_t, window: xcb_window_t, cursor: xcb_cursor_t, deviceid: xcb_input_device_id_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_change_cursor(c: ?*xcb_connection_t, window: xcb_window_t, cursor: xcb_cursor_t, deviceid: xcb_input_device_id_t) xcb_void_cookie_t;
pub extern fn xcb_input_add_master_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_add_master_name(R: [*c]const xcb_input_add_master_t) [*c]u8;
pub extern fn xcb_input_add_master_name_length(R: [*c]const xcb_input_add_master_t) c_int;
pub extern fn xcb_input_add_master_name_end(R: [*c]const xcb_input_add_master_t) xcb_generic_iterator_t;
pub extern fn xcb_input_add_master_next(i: [*c]xcb_input_add_master_iterator_t) void;
pub extern fn xcb_input_add_master_end(i: xcb_input_add_master_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_remove_master_next(i: [*c]xcb_input_remove_master_iterator_t) void;
pub extern fn xcb_input_remove_master_end(i: xcb_input_remove_master_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_attach_slave_next(i: [*c]xcb_input_attach_slave_iterator_t) void;
pub extern fn xcb_input_attach_slave_end(i: xcb_input_attach_slave_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_detach_slave_next(i: [*c]xcb_input_detach_slave_iterator_t) void;
pub extern fn xcb_input_detach_slave_end(i: xcb_input_detach_slave_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_hierarchy_change_data_add_master_name(S: [*c]const xcb_input_hierarchy_change_data_t) [*c]u8;
pub extern fn xcb_input_hierarchy_change_data_add_master_name_length(R: [*c]const xcb_input_hierarchy_change_t, S: [*c]const xcb_input_hierarchy_change_data_t) c_int;
pub extern fn xcb_input_hierarchy_change_data_add_master_name_end(R: [*c]const xcb_input_hierarchy_change_t, S: [*c]const xcb_input_hierarchy_change_data_t) xcb_generic_iterator_t;
pub extern fn xcb_input_hierarchy_change_data_serialize(_buffer: [*c]?*anyopaque, @"type": u16, _aux: [*c]const xcb_input_hierarchy_change_data_t) c_int;
pub extern fn xcb_input_hierarchy_change_data_unpack(_buffer: ?*const anyopaque, @"type": u16, _aux: [*c]xcb_input_hierarchy_change_data_t) c_int;
pub extern fn xcb_input_hierarchy_change_data_sizeof(_buffer: ?*const anyopaque, @"type": u16) c_int;
pub extern fn xcb_input_hierarchy_change_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_hierarchy_change_next(i: [*c]xcb_input_hierarchy_change_iterator_t) void;
pub extern fn xcb_input_hierarchy_change_end(i: xcb_input_hierarchy_change_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_change_hierarchy_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_change_hierarchy_checked(c: ?*xcb_connection_t, num_changes: u8, changes: [*c]const xcb_input_hierarchy_change_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_change_hierarchy(c: ?*xcb_connection_t, num_changes: u8, changes: [*c]const xcb_input_hierarchy_change_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_change_hierarchy_changes_length(R: [*c]const xcb_input_xi_change_hierarchy_request_t) c_int;
pub extern fn xcb_input_xi_change_hierarchy_changes_iterator(R: [*c]const xcb_input_xi_change_hierarchy_request_t) xcb_input_hierarchy_change_iterator_t;
pub extern fn xcb_input_xi_set_client_pointer_checked(c: ?*xcb_connection_t, window: xcb_window_t, deviceid: xcb_input_device_id_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_set_client_pointer(c: ?*xcb_connection_t, window: xcb_window_t, deviceid: xcb_input_device_id_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_get_client_pointer(c: ?*xcb_connection_t, window: xcb_window_t) xcb_input_xi_get_client_pointer_cookie_t;
pub extern fn xcb_input_xi_get_client_pointer_unchecked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_input_xi_get_client_pointer_cookie_t;
pub extern fn xcb_input_xi_get_client_pointer_reply(c: ?*xcb_connection_t, cookie: xcb_input_xi_get_client_pointer_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_xi_get_client_pointer_reply_t;
pub extern fn xcb_input_event_mask_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_event_mask_mask(R: [*c]const xcb_input_event_mask_t) [*c]u32;
pub extern fn xcb_input_event_mask_mask_length(R: [*c]const xcb_input_event_mask_t) c_int;
pub extern fn xcb_input_event_mask_mask_end(R: [*c]const xcb_input_event_mask_t) xcb_generic_iterator_t;
pub extern fn xcb_input_event_mask_next(i: [*c]xcb_input_event_mask_iterator_t) void;
pub extern fn xcb_input_event_mask_end(i: xcb_input_event_mask_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_select_events_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_select_events_checked(c: ?*xcb_connection_t, window: xcb_window_t, num_mask: u16, masks: [*c]const xcb_input_event_mask_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_select_events(c: ?*xcb_connection_t, window: xcb_window_t, num_mask: u16, masks: [*c]const xcb_input_event_mask_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_select_events_masks_length(R: [*c]const xcb_input_xi_select_events_request_t) c_int;
pub extern fn xcb_input_xi_select_events_masks_iterator(R: [*c]const xcb_input_xi_select_events_request_t) xcb_input_event_mask_iterator_t;
pub extern fn xcb_input_xi_query_version(c: ?*xcb_connection_t, major_version: u16, minor_version: u16) xcb_input_xi_query_version_cookie_t;
pub extern fn xcb_input_xi_query_version_unchecked(c: ?*xcb_connection_t, major_version: u16, minor_version: u16) xcb_input_xi_query_version_cookie_t;
pub extern fn xcb_input_xi_query_version_reply(c: ?*xcb_connection_t, cookie: xcb_input_xi_query_version_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_xi_query_version_reply_t;
pub extern fn xcb_input_button_class_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_button_class_state(R: [*c]const xcb_input_button_class_t) [*c]u32;
pub extern fn xcb_input_button_class_state_length(R: [*c]const xcb_input_button_class_t) c_int;
pub extern fn xcb_input_button_class_state_end(R: [*c]const xcb_input_button_class_t) xcb_generic_iterator_t;
pub extern fn xcb_input_button_class_labels(R: [*c]const xcb_input_button_class_t) [*c]xcb_atom_t;
pub extern fn xcb_input_button_class_labels_length(R: [*c]const xcb_input_button_class_t) c_int;
pub extern fn xcb_input_button_class_labels_end(R: [*c]const xcb_input_button_class_t) xcb_generic_iterator_t;
pub extern fn xcb_input_button_class_next(i: [*c]xcb_input_button_class_iterator_t) void;
pub extern fn xcb_input_button_class_end(i: xcb_input_button_class_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_key_class_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_key_class_keys(R: [*c]const xcb_input_key_class_t) [*c]u32;
pub extern fn xcb_input_key_class_keys_length(R: [*c]const xcb_input_key_class_t) c_int;
pub extern fn xcb_input_key_class_keys_end(R: [*c]const xcb_input_key_class_t) xcb_generic_iterator_t;
pub extern fn xcb_input_key_class_next(i: [*c]xcb_input_key_class_iterator_t) void;
pub extern fn xcb_input_key_class_end(i: xcb_input_key_class_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_scroll_class_next(i: [*c]xcb_input_scroll_class_iterator_t) void;
pub extern fn xcb_input_scroll_class_end(i: xcb_input_scroll_class_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_touch_class_next(i: [*c]xcb_input_touch_class_iterator_t) void;
pub extern fn xcb_input_touch_class_end(i: xcb_input_touch_class_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_valuator_class_next(i: [*c]xcb_input_valuator_class_iterator_t) void;
pub extern fn xcb_input_valuator_class_end(i: xcb_input_valuator_class_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_class_data_key_keys(S: [*c]const xcb_input_device_class_data_t) [*c]u32;
pub extern fn xcb_input_device_class_data_key_keys_length(R: [*c]const xcb_input_device_class_t, S: [*c]const xcb_input_device_class_data_t) c_int;
pub extern fn xcb_input_device_class_data_key_keys_end(R: [*c]const xcb_input_device_class_t, S: [*c]const xcb_input_device_class_data_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_class_data_button_state(S: [*c]const xcb_input_device_class_data_t) [*c]u32;
pub extern fn xcb_input_device_class_data_button_state_length(R: [*c]const xcb_input_device_class_t, S: [*c]const xcb_input_device_class_data_t) c_int;
pub extern fn xcb_input_device_class_data_button_state_end(R: [*c]const xcb_input_device_class_t, S: [*c]const xcb_input_device_class_data_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_class_data_button_labels(S: [*c]const xcb_input_device_class_data_t) [*c]xcb_atom_t;
pub extern fn xcb_input_device_class_data_button_labels_length(R: [*c]const xcb_input_device_class_t, S: [*c]const xcb_input_device_class_data_t) c_int;
pub extern fn xcb_input_device_class_data_button_labels_end(R: [*c]const xcb_input_device_class_t, S: [*c]const xcb_input_device_class_data_t) xcb_generic_iterator_t;
pub extern fn xcb_input_device_class_data_serialize(_buffer: [*c]?*anyopaque, @"type": u16, _aux: [*c]const xcb_input_device_class_data_t) c_int;
pub extern fn xcb_input_device_class_data_unpack(_buffer: ?*const anyopaque, @"type": u16, _aux: [*c]xcb_input_device_class_data_t) c_int;
pub extern fn xcb_input_device_class_data_sizeof(_buffer: ?*const anyopaque, @"type": u16) c_int;
pub extern fn xcb_input_device_class_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_device_class_next(i: [*c]xcb_input_device_class_iterator_t) void;
pub extern fn xcb_input_device_class_end(i: xcb_input_device_class_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_device_info_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_device_info_name(R: [*c]const xcb_input_xi_device_info_t) [*c]u8;
pub extern fn xcb_input_xi_device_info_name_length(R: [*c]const xcb_input_xi_device_info_t) c_int;
pub extern fn xcb_input_xi_device_info_name_end(R: [*c]const xcb_input_xi_device_info_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_device_info_classes_length(R: [*c]const xcb_input_xi_device_info_t) c_int;
pub extern fn xcb_input_xi_device_info_classes_iterator(R: [*c]const xcb_input_xi_device_info_t) xcb_input_device_class_iterator_t;
pub extern fn xcb_input_xi_device_info_next(i: [*c]xcb_input_xi_device_info_iterator_t) void;
pub extern fn xcb_input_xi_device_info_end(i: xcb_input_xi_device_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_query_device_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_query_device(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t) xcb_input_xi_query_device_cookie_t;
pub extern fn xcb_input_xi_query_device_unchecked(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t) xcb_input_xi_query_device_cookie_t;
pub extern fn xcb_input_xi_query_device_infos_length(R: [*c]const xcb_input_xi_query_device_reply_t) c_int;
pub extern fn xcb_input_xi_query_device_infos_iterator(R: [*c]const xcb_input_xi_query_device_reply_t) xcb_input_xi_device_info_iterator_t;
pub extern fn xcb_input_xi_query_device_reply(c: ?*xcb_connection_t, cookie: xcb_input_xi_query_device_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_xi_query_device_reply_t;
pub extern fn xcb_input_xi_set_focus_checked(c: ?*xcb_connection_t, window: xcb_window_t, time: xcb_timestamp_t, deviceid: xcb_input_device_id_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_set_focus(c: ?*xcb_connection_t, window: xcb_window_t, time: xcb_timestamp_t, deviceid: xcb_input_device_id_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_get_focus(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t) xcb_input_xi_get_focus_cookie_t;
pub extern fn xcb_input_xi_get_focus_unchecked(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t) xcb_input_xi_get_focus_cookie_t;
pub extern fn xcb_input_xi_get_focus_reply(c: ?*xcb_connection_t, cookie: xcb_input_xi_get_focus_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_xi_get_focus_reply_t;
pub extern fn xcb_input_xi_grab_device_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_grab_device(c: ?*xcb_connection_t, window: xcb_window_t, time: xcb_timestamp_t, cursor: xcb_cursor_t, deviceid: xcb_input_device_id_t, mode: u8, paired_device_mode: u8, owner_events: u8, mask_len: u16, mask: [*c]const u32) xcb_input_xi_grab_device_cookie_t;
pub extern fn xcb_input_xi_grab_device_unchecked(c: ?*xcb_connection_t, window: xcb_window_t, time: xcb_timestamp_t, cursor: xcb_cursor_t, deviceid: xcb_input_device_id_t, mode: u8, paired_device_mode: u8, owner_events: u8, mask_len: u16, mask: [*c]const u32) xcb_input_xi_grab_device_cookie_t;
pub extern fn xcb_input_xi_grab_device_reply(c: ?*xcb_connection_t, cookie: xcb_input_xi_grab_device_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_xi_grab_device_reply_t;
pub extern fn xcb_input_xi_ungrab_device_checked(c: ?*xcb_connection_t, time: xcb_timestamp_t, deviceid: xcb_input_device_id_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_ungrab_device(c: ?*xcb_connection_t, time: xcb_timestamp_t, deviceid: xcb_input_device_id_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_allow_events_checked(c: ?*xcb_connection_t, time: xcb_timestamp_t, deviceid: xcb_input_device_id_t, event_mode: u8, touchid: u32, grab_window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_allow_events(c: ?*xcb_connection_t, time: xcb_timestamp_t, deviceid: xcb_input_device_id_t, event_mode: u8, touchid: u32, grab_window: xcb_window_t) xcb_void_cookie_t;
pub extern fn xcb_input_grab_modifier_info_next(i: [*c]xcb_input_grab_modifier_info_iterator_t) void;
pub extern fn xcb_input_grab_modifier_info_end(i: xcb_input_grab_modifier_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_passive_grab_device_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_passive_grab_device(c: ?*xcb_connection_t, time: xcb_timestamp_t, grab_window: xcb_window_t, cursor: xcb_cursor_t, detail: u32, deviceid: xcb_input_device_id_t, num_modifiers: u16, mask_len: u16, grab_type: u8, grab_mode: u8, paired_device_mode: u8, owner_events: u8, mask: [*c]const u32, modifiers: [*c]const u32) xcb_input_xi_passive_grab_device_cookie_t;
pub extern fn xcb_input_xi_passive_grab_device_unchecked(c: ?*xcb_connection_t, time: xcb_timestamp_t, grab_window: xcb_window_t, cursor: xcb_cursor_t, detail: u32, deviceid: xcb_input_device_id_t, num_modifiers: u16, mask_len: u16, grab_type: u8, grab_mode: u8, paired_device_mode: u8, owner_events: u8, mask: [*c]const u32, modifiers: [*c]const u32) xcb_input_xi_passive_grab_device_cookie_t;
pub extern fn xcb_input_xi_passive_grab_device_modifiers(R: [*c]const xcb_input_xi_passive_grab_device_reply_t) [*c]xcb_input_grab_modifier_info_t;
pub extern fn xcb_input_xi_passive_grab_device_modifiers_length(R: [*c]const xcb_input_xi_passive_grab_device_reply_t) c_int;
pub extern fn xcb_input_xi_passive_grab_device_modifiers_iterator(R: [*c]const xcb_input_xi_passive_grab_device_reply_t) xcb_input_grab_modifier_info_iterator_t;
pub extern fn xcb_input_xi_passive_grab_device_reply(c: ?*xcb_connection_t, cookie: xcb_input_xi_passive_grab_device_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_xi_passive_grab_device_reply_t;
pub extern fn xcb_input_xi_passive_ungrab_device_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_passive_ungrab_device_checked(c: ?*xcb_connection_t, grab_window: xcb_window_t, detail: u32, deviceid: xcb_input_device_id_t, num_modifiers: u16, grab_type: u8, modifiers: [*c]const u32) xcb_void_cookie_t;
pub extern fn xcb_input_xi_passive_ungrab_device(c: ?*xcb_connection_t, grab_window: xcb_window_t, detail: u32, deviceid: xcb_input_device_id_t, num_modifiers: u16, grab_type: u8, modifiers: [*c]const u32) xcb_void_cookie_t;
pub extern fn xcb_input_xi_passive_ungrab_device_modifiers(R: [*c]const xcb_input_xi_passive_ungrab_device_request_t) [*c]u32;
pub extern fn xcb_input_xi_passive_ungrab_device_modifiers_length(R: [*c]const xcb_input_xi_passive_ungrab_device_request_t) c_int;
pub extern fn xcb_input_xi_passive_ungrab_device_modifiers_end(R: [*c]const xcb_input_xi_passive_ungrab_device_request_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_list_properties_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_list_properties(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t) xcb_input_xi_list_properties_cookie_t;
pub extern fn xcb_input_xi_list_properties_unchecked(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t) xcb_input_xi_list_properties_cookie_t;
pub extern fn xcb_input_xi_list_properties_properties(R: [*c]const xcb_input_xi_list_properties_reply_t) [*c]xcb_atom_t;
pub extern fn xcb_input_xi_list_properties_properties_length(R: [*c]const xcb_input_xi_list_properties_reply_t) c_int;
pub extern fn xcb_input_xi_list_properties_properties_end(R: [*c]const xcb_input_xi_list_properties_reply_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_list_properties_reply(c: ?*xcb_connection_t, cookie: xcb_input_xi_list_properties_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_xi_list_properties_reply_t;
pub extern fn xcb_input_xi_change_property_items_data_8(S: [*c]const xcb_input_xi_change_property_items_t) [*c]u8;
pub extern fn xcb_input_xi_change_property_items_data_8_length(R: [*c]const xcb_input_xi_change_property_request_t, S: [*c]const xcb_input_xi_change_property_items_t) c_int;
pub extern fn xcb_input_xi_change_property_items_data_8_end(R: [*c]const xcb_input_xi_change_property_request_t, S: [*c]const xcb_input_xi_change_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_change_property_items_data_16(S: [*c]const xcb_input_xi_change_property_items_t) [*c]u16;
pub extern fn xcb_input_xi_change_property_items_data_16_length(R: [*c]const xcb_input_xi_change_property_request_t, S: [*c]const xcb_input_xi_change_property_items_t) c_int;
pub extern fn xcb_input_xi_change_property_items_data_16_end(R: [*c]const xcb_input_xi_change_property_request_t, S: [*c]const xcb_input_xi_change_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_change_property_items_data_32(S: [*c]const xcb_input_xi_change_property_items_t) [*c]u32;
pub extern fn xcb_input_xi_change_property_items_data_32_length(R: [*c]const xcb_input_xi_change_property_request_t, S: [*c]const xcb_input_xi_change_property_items_t) c_int;
pub extern fn xcb_input_xi_change_property_items_data_32_end(R: [*c]const xcb_input_xi_change_property_request_t, S: [*c]const xcb_input_xi_change_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_change_property_items_serialize(_buffer: [*c]?*anyopaque, num_items: u32, format: u8, _aux: [*c]const xcb_input_xi_change_property_items_t) c_int;
pub extern fn xcb_input_xi_change_property_items_unpack(_buffer: ?*const anyopaque, num_items: u32, format: u8, _aux: [*c]xcb_input_xi_change_property_items_t) c_int;
pub extern fn xcb_input_xi_change_property_items_sizeof(_buffer: ?*const anyopaque, num_items: u32, format: u8) c_int;
pub extern fn xcb_input_xi_change_property_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_change_property_checked(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t, mode: u8, format: u8, property: xcb_atom_t, @"type": xcb_atom_t, num_items: u32, items: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_input_xi_change_property(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t, mode: u8, format: u8, property: xcb_atom_t, @"type": xcb_atom_t, num_items: u32, items: ?*const anyopaque) xcb_void_cookie_t;
pub extern fn xcb_input_xi_change_property_aux_checked(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t, mode: u8, format: u8, property: xcb_atom_t, @"type": xcb_atom_t, num_items: u32, items: [*c]const xcb_input_xi_change_property_items_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_change_property_aux(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t, mode: u8, format: u8, property: xcb_atom_t, @"type": xcb_atom_t, num_items: u32, items: [*c]const xcb_input_xi_change_property_items_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_change_property_items(R: [*c]const xcb_input_xi_change_property_request_t) ?*anyopaque;
pub extern fn xcb_input_xi_delete_property_checked(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t, property: xcb_atom_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_delete_property(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t, property: xcb_atom_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_get_property_items_data_8(S: [*c]const xcb_input_xi_get_property_items_t) [*c]u8;
pub extern fn xcb_input_xi_get_property_items_data_8_length(R: [*c]const xcb_input_xi_get_property_reply_t, S: [*c]const xcb_input_xi_get_property_items_t) c_int;
pub extern fn xcb_input_xi_get_property_items_data_8_end(R: [*c]const xcb_input_xi_get_property_reply_t, S: [*c]const xcb_input_xi_get_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_get_property_items_data_16(S: [*c]const xcb_input_xi_get_property_items_t) [*c]u16;
pub extern fn xcb_input_xi_get_property_items_data_16_length(R: [*c]const xcb_input_xi_get_property_reply_t, S: [*c]const xcb_input_xi_get_property_items_t) c_int;
pub extern fn xcb_input_xi_get_property_items_data_16_end(R: [*c]const xcb_input_xi_get_property_reply_t, S: [*c]const xcb_input_xi_get_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_get_property_items_data_32(S: [*c]const xcb_input_xi_get_property_items_t) [*c]u32;
pub extern fn xcb_input_xi_get_property_items_data_32_length(R: [*c]const xcb_input_xi_get_property_reply_t, S: [*c]const xcb_input_xi_get_property_items_t) c_int;
pub extern fn xcb_input_xi_get_property_items_data_32_end(R: [*c]const xcb_input_xi_get_property_reply_t, S: [*c]const xcb_input_xi_get_property_items_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_get_property_items_serialize(_buffer: [*c]?*anyopaque, num_items: u32, format: u8, _aux: [*c]const xcb_input_xi_get_property_items_t) c_int;
pub extern fn xcb_input_xi_get_property_items_unpack(_buffer: ?*const anyopaque, num_items: u32, format: u8, _aux: [*c]xcb_input_xi_get_property_items_t) c_int;
pub extern fn xcb_input_xi_get_property_items_sizeof(_buffer: ?*const anyopaque, num_items: u32, format: u8) c_int;
pub extern fn xcb_input_xi_get_property_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_get_property(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t, _delete: u8, property: xcb_atom_t, @"type": xcb_atom_t, offset: u32, len: u32) xcb_input_xi_get_property_cookie_t;
pub extern fn xcb_input_xi_get_property_unchecked(c: ?*xcb_connection_t, deviceid: xcb_input_device_id_t, _delete: u8, property: xcb_atom_t, @"type": xcb_atom_t, offset: u32, len: u32) xcb_input_xi_get_property_cookie_t;
pub extern fn xcb_input_xi_get_property_items(R: [*c]const xcb_input_xi_get_property_reply_t) ?*anyopaque;
pub extern fn xcb_input_xi_get_property_reply(c: ?*xcb_connection_t, cookie: xcb_input_xi_get_property_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_xi_get_property_reply_t;
pub extern fn xcb_input_xi_get_selected_events_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_get_selected_events(c: ?*xcb_connection_t, window: xcb_window_t) xcb_input_xi_get_selected_events_cookie_t;
pub extern fn xcb_input_xi_get_selected_events_unchecked(c: ?*xcb_connection_t, window: xcb_window_t) xcb_input_xi_get_selected_events_cookie_t;
pub extern fn xcb_input_xi_get_selected_events_masks_length(R: [*c]const xcb_input_xi_get_selected_events_reply_t) c_int;
pub extern fn xcb_input_xi_get_selected_events_masks_iterator(R: [*c]const xcb_input_xi_get_selected_events_reply_t) xcb_input_event_mask_iterator_t;
pub extern fn xcb_input_xi_get_selected_events_reply(c: ?*xcb_connection_t, cookie: xcb_input_xi_get_selected_events_cookie_t, e: [*c][*c]xcb_generic_error_t) [*c]xcb_input_xi_get_selected_events_reply_t;
pub extern fn xcb_input_barrier_release_pointer_info_next(i: [*c]xcb_input_barrier_release_pointer_info_iterator_t) void;
pub extern fn xcb_input_barrier_release_pointer_info_end(i: xcb_input_barrier_release_pointer_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_xi_barrier_release_pointer_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_xi_barrier_release_pointer_checked(c: ?*xcb_connection_t, num_barriers: u32, barriers: [*c]const xcb_input_barrier_release_pointer_info_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_barrier_release_pointer(c: ?*xcb_connection_t, num_barriers: u32, barriers: [*c]const xcb_input_barrier_release_pointer_info_t) xcb_void_cookie_t;
pub extern fn xcb_input_xi_barrier_release_pointer_barriers(R: [*c]const xcb_input_xi_barrier_release_pointer_request_t) [*c]xcb_input_barrier_release_pointer_info_t;
pub extern fn xcb_input_xi_barrier_release_pointer_barriers_length(R: [*c]const xcb_input_xi_barrier_release_pointer_request_t) c_int;
pub extern fn xcb_input_xi_barrier_release_pointer_barriers_iterator(R: [*c]const xcb_input_xi_barrier_release_pointer_request_t) xcb_input_barrier_release_pointer_info_iterator_t;
pub extern fn xcb_input_device_changed_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_device_changed_classes_length(R: [*c]const xcb_input_device_changed_event_t) c_int;
pub extern fn xcb_input_device_changed_classes_iterator(R: [*c]const xcb_input_device_changed_event_t) xcb_input_device_class_iterator_t;
pub extern fn xcb_input_key_press_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_key_press_button_mask(R: [*c]const xcb_input_key_press_event_t) [*c]u32;
pub extern fn xcb_input_key_press_button_mask_length(R: [*c]const xcb_input_key_press_event_t) c_int;
pub extern fn xcb_input_key_press_button_mask_end(R: [*c]const xcb_input_key_press_event_t) xcb_generic_iterator_t;
pub extern fn xcb_input_key_press_valuator_mask(R: [*c]const xcb_input_key_press_event_t) [*c]u32;
pub extern fn xcb_input_key_press_valuator_mask_length(R: [*c]const xcb_input_key_press_event_t) c_int;
pub extern fn xcb_input_key_press_valuator_mask_end(R: [*c]const xcb_input_key_press_event_t) xcb_generic_iterator_t;
pub extern fn xcb_input_key_press_axisvalues(R: [*c]const xcb_input_key_press_event_t) [*c]xcb_input_fp3232_t;
pub extern fn xcb_input_key_press_axisvalues_length(R: [*c]const xcb_input_key_press_event_t) c_int;
pub extern fn xcb_input_key_press_axisvalues_iterator(R: [*c]const xcb_input_key_press_event_t) xcb_input_fp3232_iterator_t;
pub extern fn xcb_input_key_release_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_button_press_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_button_press_button_mask(R: [*c]const xcb_input_button_press_event_t) [*c]u32;
pub extern fn xcb_input_button_press_button_mask_length(R: [*c]const xcb_input_button_press_event_t) c_int;
pub extern fn xcb_input_button_press_button_mask_end(R: [*c]const xcb_input_button_press_event_t) xcb_generic_iterator_t;
pub extern fn xcb_input_button_press_valuator_mask(R: [*c]const xcb_input_button_press_event_t) [*c]u32;
pub extern fn xcb_input_button_press_valuator_mask_length(R: [*c]const xcb_input_button_press_event_t) c_int;
pub extern fn xcb_input_button_press_valuator_mask_end(R: [*c]const xcb_input_button_press_event_t) xcb_generic_iterator_t;
pub extern fn xcb_input_button_press_axisvalues(R: [*c]const xcb_input_button_press_event_t) [*c]xcb_input_fp3232_t;
pub extern fn xcb_input_button_press_axisvalues_length(R: [*c]const xcb_input_button_press_event_t) c_int;
pub extern fn xcb_input_button_press_axisvalues_iterator(R: [*c]const xcb_input_button_press_event_t) xcb_input_fp3232_iterator_t;
pub extern fn xcb_input_button_release_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_motion_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_enter_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_enter_buttons(R: [*c]const xcb_input_enter_event_t) [*c]u32;
pub extern fn xcb_input_enter_buttons_length(R: [*c]const xcb_input_enter_event_t) c_int;
pub extern fn xcb_input_enter_buttons_end(R: [*c]const xcb_input_enter_event_t) xcb_generic_iterator_t;
pub extern fn xcb_input_leave_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_focus_in_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_focus_out_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_hierarchy_info_next(i: [*c]xcb_input_hierarchy_info_iterator_t) void;
pub extern fn xcb_input_hierarchy_info_end(i: xcb_input_hierarchy_info_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_hierarchy_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_hierarchy_infos(R: [*c]const xcb_input_hierarchy_event_t) [*c]xcb_input_hierarchy_info_t;
pub extern fn xcb_input_hierarchy_infos_length(R: [*c]const xcb_input_hierarchy_event_t) c_int;
pub extern fn xcb_input_hierarchy_infos_iterator(R: [*c]const xcb_input_hierarchy_event_t) xcb_input_hierarchy_info_iterator_t;
pub extern fn xcb_input_raw_key_press_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_raw_key_press_valuator_mask(R: [*c]const xcb_input_raw_key_press_event_t) [*c]u32;
pub extern fn xcb_input_raw_key_press_valuator_mask_length(R: [*c]const xcb_input_raw_key_press_event_t) c_int;
pub extern fn xcb_input_raw_key_press_valuator_mask_end(R: [*c]const xcb_input_raw_key_press_event_t) xcb_generic_iterator_t;
pub extern fn xcb_input_raw_key_press_axisvalues(R: [*c]const xcb_input_raw_key_press_event_t) [*c]xcb_input_fp3232_t;
pub extern fn xcb_input_raw_key_press_axisvalues_length(R: [*c]const xcb_input_raw_key_press_event_t) c_int;
pub extern fn xcb_input_raw_key_press_axisvalues_iterator(R: [*c]const xcb_input_raw_key_press_event_t) xcb_input_fp3232_iterator_t;
pub extern fn xcb_input_raw_key_press_axisvalues_raw(R: [*c]const xcb_input_raw_key_press_event_t) [*c]xcb_input_fp3232_t;
pub extern fn xcb_input_raw_key_press_axisvalues_raw_length(R: [*c]const xcb_input_raw_key_press_event_t) c_int;
pub extern fn xcb_input_raw_key_press_axisvalues_raw_iterator(R: [*c]const xcb_input_raw_key_press_event_t) xcb_input_fp3232_iterator_t;
pub extern fn xcb_input_raw_key_release_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_raw_button_press_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_raw_button_press_valuator_mask(R: [*c]const xcb_input_raw_button_press_event_t) [*c]u32;
pub extern fn xcb_input_raw_button_press_valuator_mask_length(R: [*c]const xcb_input_raw_button_press_event_t) c_int;
pub extern fn xcb_input_raw_button_press_valuator_mask_end(R: [*c]const xcb_input_raw_button_press_event_t) xcb_generic_iterator_t;
pub extern fn xcb_input_raw_button_press_axisvalues(R: [*c]const xcb_input_raw_button_press_event_t) [*c]xcb_input_fp3232_t;
pub extern fn xcb_input_raw_button_press_axisvalues_length(R: [*c]const xcb_input_raw_button_press_event_t) c_int;
pub extern fn xcb_input_raw_button_press_axisvalues_iterator(R: [*c]const xcb_input_raw_button_press_event_t) xcb_input_fp3232_iterator_t;
pub extern fn xcb_input_raw_button_press_axisvalues_raw(R: [*c]const xcb_input_raw_button_press_event_t) [*c]xcb_input_fp3232_t;
pub extern fn xcb_input_raw_button_press_axisvalues_raw_length(R: [*c]const xcb_input_raw_button_press_event_t) c_int;
pub extern fn xcb_input_raw_button_press_axisvalues_raw_iterator(R: [*c]const xcb_input_raw_button_press_event_t) xcb_input_fp3232_iterator_t;
pub extern fn xcb_input_raw_button_release_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_raw_motion_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_touch_begin_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_touch_begin_button_mask(R: [*c]const xcb_input_touch_begin_event_t) [*c]u32;
pub extern fn xcb_input_touch_begin_button_mask_length(R: [*c]const xcb_input_touch_begin_event_t) c_int;
pub extern fn xcb_input_touch_begin_button_mask_end(R: [*c]const xcb_input_touch_begin_event_t) xcb_generic_iterator_t;
pub extern fn xcb_input_touch_begin_valuator_mask(R: [*c]const xcb_input_touch_begin_event_t) [*c]u32;
pub extern fn xcb_input_touch_begin_valuator_mask_length(R: [*c]const xcb_input_touch_begin_event_t) c_int;
pub extern fn xcb_input_touch_begin_valuator_mask_end(R: [*c]const xcb_input_touch_begin_event_t) xcb_generic_iterator_t;
pub extern fn xcb_input_touch_begin_axisvalues(R: [*c]const xcb_input_touch_begin_event_t) [*c]xcb_input_fp3232_t;
pub extern fn xcb_input_touch_begin_axisvalues_length(R: [*c]const xcb_input_touch_begin_event_t) c_int;
pub extern fn xcb_input_touch_begin_axisvalues_iterator(R: [*c]const xcb_input_touch_begin_event_t) xcb_input_fp3232_iterator_t;
pub extern fn xcb_input_touch_update_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_touch_end_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_raw_touch_begin_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_raw_touch_begin_valuator_mask(R: [*c]const xcb_input_raw_touch_begin_event_t) [*c]u32;
pub extern fn xcb_input_raw_touch_begin_valuator_mask_length(R: [*c]const xcb_input_raw_touch_begin_event_t) c_int;
pub extern fn xcb_input_raw_touch_begin_valuator_mask_end(R: [*c]const xcb_input_raw_touch_begin_event_t) xcb_generic_iterator_t;
pub extern fn xcb_input_raw_touch_begin_axisvalues(R: [*c]const xcb_input_raw_touch_begin_event_t) [*c]xcb_input_fp3232_t;
pub extern fn xcb_input_raw_touch_begin_axisvalues_length(R: [*c]const xcb_input_raw_touch_begin_event_t) c_int;
pub extern fn xcb_input_raw_touch_begin_axisvalues_iterator(R: [*c]const xcb_input_raw_touch_begin_event_t) xcb_input_fp3232_iterator_t;
pub extern fn xcb_input_raw_touch_begin_axisvalues_raw(R: [*c]const xcb_input_raw_touch_begin_event_t) [*c]xcb_input_fp3232_t;
pub extern fn xcb_input_raw_touch_begin_axisvalues_raw_length(R: [*c]const xcb_input_raw_touch_begin_event_t) c_int;
pub extern fn xcb_input_raw_touch_begin_axisvalues_raw_iterator(R: [*c]const xcb_input_raw_touch_begin_event_t) xcb_input_fp3232_iterator_t;
pub extern fn xcb_input_raw_touch_update_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_raw_touch_end_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_event_for_send_next(i: [*c]xcb_input_event_for_send_iterator_t) void;
pub extern fn xcb_input_event_for_send_end(i: xcb_input_event_for_send_iterator_t) xcb_generic_iterator_t;
pub extern fn xcb_input_send_extension_event_sizeof(_buffer: ?*const anyopaque) c_int;
pub extern fn xcb_input_send_extension_event_checked(c: ?*xcb_connection_t, destination: xcb_window_t, device_id: u8, propagate: u8, num_classes: u16, num_events: u8, events: [*c]const xcb_input_event_for_send_t, classes: [*c]const xcb_input_event_class_t) xcb_void_cookie_t;
pub extern fn xcb_input_send_extension_event(c: ?*xcb_connection_t, destination: xcb_window_t, device_id: u8, propagate: u8, num_classes: u16, num_events: u8, events: [*c]const xcb_input_event_for_send_t, classes: [*c]const xcb_input_event_class_t) xcb_void_cookie_t;
pub extern fn xcb_input_send_extension_event_events(R: [*c]const xcb_input_send_extension_event_request_t) [*c]xcb_input_event_for_send_t;
pub extern fn xcb_input_send_extension_event_events_length(R: [*c]const xcb_input_send_extension_event_request_t) c_int;
pub extern fn xcb_input_send_extension_event_events_iterator(R: [*c]const xcb_input_send_extension_event_request_t) xcb_input_event_for_send_iterator_t;
pub extern fn xcb_input_send_extension_event_classes(R: [*c]const xcb_input_send_extension_event_request_t) [*c]xcb_input_event_class_t;
pub extern fn xcb_input_send_extension_event_classes_length(R: [*c]const xcb_input_send_extension_event_request_t) c_int;
pub extern fn xcb_input_send_extension_event_classes_end(R: [*c]const xcb_input_send_extension_event_request_t) xcb_generic_iterator_t;

pub const X_PROTOCOL = @as(c_int, 11);
pub const X_PROTOCOL_REVISION = @as(c_int, 0);
pub const X_TCP_PORT = @as(c_int, 6000);
pub const XCB_CONN_ERROR = @as(c_int, 1);
pub const XCB_CONN_CLOSED_EXT_NOTSUPPORTED = @as(c_int, 2);
pub const XCB_CONN_CLOSED_MEM_INSUFFICIENT = @as(c_int, 3);
pub const XCB_CONN_CLOSED_REQ_LEN_EXCEED = @as(c_int, 4);
pub const XCB_CONN_CLOSED_PARSE_ERR = @as(c_int, 5);
pub const XCB_CONN_CLOSED_INVALID_SCREEN = @as(c_int, 6);
pub const XCB_CONN_CLOSED_FDPASSING_FAILED = @as(c_int, 7);
pub inline fn XCB_TYPE_PAD(T: anytype, I: anytype) @TypeOf(-I & (if (@import("std").zig.c_translation.sizeof(T) > @as(c_int, 4)) @as(c_int, 3) else @import("std").zig.c_translation.sizeof(T) - @as(c_int, 1))) {
    _ = &T;
    _ = &I;
    return -I & (if (@import("std").zig.c_translation.sizeof(T) > @as(c_int, 4)) @as(c_int, 3) else @import("std").zig.c_translation.sizeof(T) - @as(c_int, 1));
}
pub const __XPROTO_H = "";
pub const XCB_KEY_PRESS = @as(c_int, 2);
pub const XCB_KEY_RELEASE = @as(c_int, 3);
pub const XCB_BUTTON_PRESS = @as(c_int, 4);
pub const XCB_BUTTON_RELEASE = @as(c_int, 5);
pub const XCB_MOTION_NOTIFY = @as(c_int, 6);
pub const XCB_ENTER_NOTIFY = @as(c_int, 7);
pub const XCB_LEAVE_NOTIFY = @as(c_int, 8);
pub const XCB_FOCUS_IN = @as(c_int, 9);
pub const XCB_FOCUS_OUT = @as(c_int, 10);
pub const XCB_KEYMAP_NOTIFY = @as(c_int, 11);
pub const XCB_EXPOSE = @as(c_int, 12);
pub const XCB_GRAPHICS_EXPOSURE = @as(c_int, 13);
pub const XCB_NO_EXPOSURE = @as(c_int, 14);
pub const XCB_VISIBILITY_NOTIFY = @as(c_int, 15);
pub const XCB_CREATE_NOTIFY = @as(c_int, 16);
pub const XCB_DESTROY_NOTIFY = @as(c_int, 17);
pub const XCB_UNMAP_NOTIFY = @as(c_int, 18);
pub const XCB_MAP_NOTIFY = @as(c_int, 19);
pub const XCB_MAP_REQUEST = @as(c_int, 20);
pub const XCB_REPARENT_NOTIFY = @as(c_int, 21);
pub const XCB_CONFIGURE_NOTIFY = @as(c_int, 22);
pub const XCB_CONFIGURE_REQUEST = @as(c_int, 23);
pub const XCB_GRAVITY_NOTIFY = @as(c_int, 24);
pub const XCB_RESIZE_REQUEST = @as(c_int, 25);
pub const XCB_CIRCULATE_NOTIFY = @as(c_int, 26);
pub const XCB_CIRCULATE_REQUEST = @as(c_int, 27);
pub const XCB_PROPERTY_NOTIFY = @as(c_int, 28);
pub const XCB_SELECTION_CLEAR = @as(c_int, 29);
pub const XCB_SELECTION_REQUEST = @as(c_int, 30);
pub const XCB_SELECTION_NOTIFY = @as(c_int, 31);
pub const XCB_COLORMAP_NOTIFY = @as(c_int, 32);
pub const XCB_CLIENT_MESSAGE = @as(c_int, 33);
pub const XCB_MAPPING_NOTIFY = @as(c_int, 34);
pub const XCB_GE_GENERIC = @as(c_int, 35);
pub const XCB_REQUEST = @as(c_int, 1);
pub const XCB_VALUE = @as(c_int, 2);
pub const XCB_WINDOW = @as(c_int, 3);
pub const XCB_PIXMAP = @as(c_int, 4);
pub const XCB_ATOM = @as(c_int, 5);
pub const XCB_CURSOR = @as(c_int, 6);
pub const XCB_FONT = @as(c_int, 7);
pub const XCB_MATCH = @as(c_int, 8);
pub const XCB_DRAWABLE = @as(c_int, 9);
pub const XCB_ACCESS = @as(c_int, 10);
pub const XCB_ALLOC = @as(c_int, 11);
pub const XCB_COLORMAP = @as(c_int, 12);
pub const XCB_G_CONTEXT = @as(c_int, 13);
pub const XCB_ID_CHOICE = @as(c_int, 14);
pub const XCB_NAME = @as(c_int, 15);
pub const XCB_LENGTH = @as(c_int, 16);
pub const XCB_IMPLEMENTATION = @as(c_int, 17);
pub const XCB_CREATE_WINDOW = @as(c_int, 1);
pub const XCB_CHANGE_WINDOW_ATTRIBUTES = @as(c_int, 2);
pub const XCB_GET_WINDOW_ATTRIBUTES = @as(c_int, 3);
pub const XCB_DESTROY_WINDOW = @as(c_int, 4);
pub const XCB_DESTROY_SUBWINDOWS = @as(c_int, 5);
pub const XCB_CHANGE_SAVE_SET = @as(c_int, 6);
pub const XCB_REPARENT_WINDOW = @as(c_int, 7);
pub const XCB_MAP_WINDOW = @as(c_int, 8);
pub const XCB_MAP_SUBWINDOWS = @as(c_int, 9);
pub const XCB_UNMAP_WINDOW = @as(c_int, 10);
pub const XCB_UNMAP_SUBWINDOWS = @as(c_int, 11);
pub const XCB_CONFIGURE_WINDOW = @as(c_int, 12);
pub const XCB_CIRCULATE_WINDOW = @as(c_int, 13);
pub const XCB_GET_GEOMETRY = @as(c_int, 14);
pub const XCB_QUERY_TREE = @as(c_int, 15);
pub const XCB_INTERN_ATOM = @as(c_int, 16);
pub const XCB_GET_ATOM_NAME = @as(c_int, 17);
pub const XCB_CHANGE_PROPERTY = @as(c_int, 18);
pub const XCB_DELETE_PROPERTY = @as(c_int, 19);
pub const XCB_GET_PROPERTY = @as(c_int, 20);
pub const XCB_LIST_PROPERTIES = @as(c_int, 21);
pub const XCB_SET_SELECTION_OWNER = @as(c_int, 22);
pub const XCB_GET_SELECTION_OWNER = @as(c_int, 23);
pub const XCB_CONVERT_SELECTION = @as(c_int, 24);
pub const XCB_SEND_EVENT = @as(c_int, 25);
pub const XCB_GRAB_POINTER = @as(c_int, 26);
pub const XCB_UNGRAB_POINTER = @as(c_int, 27);
pub const XCB_GRAB_BUTTON = @as(c_int, 28);
pub const XCB_UNGRAB_BUTTON = @as(c_int, 29);
pub const XCB_CHANGE_ACTIVE_POINTER_GRAB = @as(c_int, 30);
pub const XCB_GRAB_KEYBOARD = @as(c_int, 31);
pub const XCB_UNGRAB_KEYBOARD = @as(c_int, 32);
pub const XCB_GRAB_KEY = @as(c_int, 33);
pub const XCB_UNGRAB_KEY = @as(c_int, 34);
pub const XCB_ALLOW_EVENTS = @as(c_int, 35);
pub const XCB_GRAB_SERVER = @as(c_int, 36);
pub const XCB_UNGRAB_SERVER = @as(c_int, 37);
pub const XCB_QUERY_POINTER = @as(c_int, 38);
pub const XCB_GET_MOTION_EVENTS = @as(c_int, 39);
pub const XCB_TRANSLATE_COORDINATES = @as(c_int, 40);
pub const XCB_WARP_POINTER = @as(c_int, 41);
pub const XCB_SET_INPUT_FOCUS = @as(c_int, 42);
pub const XCB_GET_INPUT_FOCUS = @as(c_int, 43);
pub const XCB_QUERY_KEYMAP = @as(c_int, 44);
pub const XCB_OPEN_FONT = @as(c_int, 45);
pub const XCB_CLOSE_FONT = @as(c_int, 46);
pub const XCB_QUERY_FONT = @as(c_int, 47);
pub const XCB_QUERY_TEXT_EXTENTS = @as(c_int, 48);
pub const XCB_LIST_FONTS = @as(c_int, 49);
pub const XCB_LIST_FONTS_WITH_INFO = @as(c_int, 50);
pub const XCB_SET_FONT_PATH = @as(c_int, 51);
pub const XCB_GET_FONT_PATH = @as(c_int, 52);
pub const XCB_CREATE_PIXMAP = @as(c_int, 53);
pub const XCB_FREE_PIXMAP = @as(c_int, 54);
pub const XCB_CREATE_GC = @as(c_int, 55);
pub const XCB_CHANGE_GC = @as(c_int, 56);
pub const XCB_COPY_GC = @as(c_int, 57);
pub const XCB_SET_DASHES = @as(c_int, 58);
pub const XCB_SET_CLIP_RECTANGLES = @as(c_int, 59);
pub const XCB_FREE_GC = @as(c_int, 60);
pub const XCB_CLEAR_AREA = @as(c_int, 61);
pub const XCB_COPY_AREA = @as(c_int, 62);
pub const XCB_COPY_PLANE = @as(c_int, 63);
pub const XCB_POLY_POINT = @as(c_int, 64);
pub const XCB_POLY_LINE = @as(c_int, 65);
pub const XCB_POLY_SEGMENT = @as(c_int, 66);
pub const XCB_POLY_RECTANGLE = @as(c_int, 67);
pub const XCB_POLY_ARC = @as(c_int, 68);
pub const XCB_FILL_POLY = @as(c_int, 69);
pub const XCB_POLY_FILL_RECTANGLE = @as(c_int, 70);
pub const XCB_POLY_FILL_ARC = @as(c_int, 71);
pub const XCB_PUT_IMAGE = @as(c_int, 72);
pub const XCB_GET_IMAGE = @as(c_int, 73);
pub const XCB_POLY_TEXT_8 = @as(c_int, 74);
pub const XCB_POLY_TEXT_16 = @as(c_int, 75);
pub const XCB_IMAGE_TEXT_8 = @as(c_int, 76);
pub const XCB_IMAGE_TEXT_16 = @as(c_int, 77);
pub const XCB_CREATE_COLORMAP = @as(c_int, 78);
pub const XCB_FREE_COLORMAP = @as(c_int, 79);
pub const XCB_COPY_COLORMAP_AND_FREE = @as(c_int, 80);
pub const XCB_INSTALL_COLORMAP = @as(c_int, 81);
pub const XCB_UNINSTALL_COLORMAP = @as(c_int, 82);
pub const XCB_LIST_INSTALLED_COLORMAPS = @as(c_int, 83);
pub const XCB_ALLOC_COLOR = @as(c_int, 84);
pub const XCB_ALLOC_NAMED_COLOR = @as(c_int, 85);
pub const XCB_ALLOC_COLOR_CELLS = @as(c_int, 86);
pub const XCB_ALLOC_COLOR_PLANES = @as(c_int, 87);
pub const XCB_FREE_COLORS = @as(c_int, 88);
pub const XCB_STORE_COLORS = @as(c_int, 89);
pub const XCB_STORE_NAMED_COLOR = @as(c_int, 90);
pub const XCB_QUERY_COLORS = @as(c_int, 91);
pub const XCB_LOOKUP_COLOR = @as(c_int, 92);
pub const XCB_CREATE_CURSOR = @as(c_int, 93);
pub const XCB_CREATE_GLYPH_CURSOR = @as(c_int, 94);
pub const XCB_FREE_CURSOR = @as(c_int, 95);
pub const XCB_RECOLOR_CURSOR = @as(c_int, 96);
pub const XCB_QUERY_BEST_SIZE = @as(c_int, 97);
pub const XCB_QUERY_EXTENSION = @as(c_int, 98);
pub const XCB_LIST_EXTENSIONS = @as(c_int, 99);
pub const XCB_CHANGE_KEYBOARD_MAPPING = @as(c_int, 100);
pub const XCB_GET_KEYBOARD_MAPPING = @as(c_int, 101);
pub const XCB_CHANGE_KEYBOARD_CONTROL = @as(c_int, 102);
pub const XCB_GET_KEYBOARD_CONTROL = @as(c_int, 103);
pub const XCB_BELL = @as(c_int, 104);
pub const XCB_CHANGE_POINTER_CONTROL = @as(c_int, 105);
pub const XCB_GET_POINTER_CONTROL = @as(c_int, 106);
pub const XCB_SET_SCREEN_SAVER = @as(c_int, 107);
pub const XCB_GET_SCREEN_SAVER = @as(c_int, 108);
pub const XCB_CHANGE_HOSTS = @as(c_int, 109);
pub const XCB_LIST_HOSTS = @as(c_int, 110);
pub const XCB_SET_ACCESS_CONTROL = @as(c_int, 111);
pub const XCB_SET_CLOSE_DOWN_MODE = @as(c_int, 112);
pub const XCB_KILL_CLIENT = @as(c_int, 113);
pub const XCB_ROTATE_PROPERTIES = @as(c_int, 114);
pub const XCB_FORCE_SCREEN_SAVER = @as(c_int, 115);
pub const XCB_SET_POINTER_MAPPING = @as(c_int, 116);
pub const XCB_GET_POINTER_MAPPING = @as(c_int, 117);
pub const XCB_SET_MODIFIER_MAPPING = @as(c_int, 118);
pub const XCB_GET_MODIFIER_MAPPING = @as(c_int, 119);
pub const XCB_NO_OPERATION = @as(c_int, 127);
pub const XCB_NONE = @as(c_long, 0);
pub const XCB_COPY_FROM_PARENT = @as(c_long, 0);
pub const XCB_CURRENT_TIME = @as(c_long, 0);
pub const XCB_NO_SYMBOL = @as(c_long, 0);
pub const __XFIXES_H = "";
pub const __RENDER_H = "";
pub const XCB_RENDER_MAJOR_VERSION = @as(c_int, 0);
pub const XCB_RENDER_MINOR_VERSION = @as(c_int, 11);
pub const XCB_RENDER_PICT_FORMAT = @as(c_int, 0);
pub const XCB_RENDER_PICTURE = @as(c_int, 1);
pub const XCB_RENDER_PICT_OP = @as(c_int, 2);
pub const XCB_RENDER_GLYPH_SET = @as(c_int, 3);
pub const XCB_RENDER_GLYPH = @as(c_int, 4);
pub const XCB_RENDER_QUERY_VERSION = @as(c_int, 0);
pub const XCB_RENDER_QUERY_PICT_FORMATS = @as(c_int, 1);
pub const XCB_RENDER_QUERY_PICT_INDEX_VALUES = @as(c_int, 2);
pub const XCB_RENDER_CREATE_PICTURE = @as(c_int, 4);
pub const XCB_RENDER_CHANGE_PICTURE = @as(c_int, 5);
pub const XCB_RENDER_SET_PICTURE_CLIP_RECTANGLES = @as(c_int, 6);
pub const XCB_RENDER_FREE_PICTURE = @as(c_int, 7);
pub const XCB_RENDER_COMPOSITE = @as(c_int, 8);
pub const XCB_RENDER_TRAPEZOIDS = @as(c_int, 10);
pub const XCB_RENDER_TRIANGLES = @as(c_int, 11);
pub const XCB_RENDER_TRI_STRIP = @as(c_int, 12);
pub const XCB_RENDER_TRI_FAN = @as(c_int, 13);
pub const XCB_RENDER_CREATE_GLYPH_SET = @as(c_int, 17);
pub const XCB_RENDER_REFERENCE_GLYPH_SET = @as(c_int, 18);
pub const XCB_RENDER_FREE_GLYPH_SET = @as(c_int, 19);
pub const XCB_RENDER_ADD_GLYPHS = @as(c_int, 20);
pub const XCB_RENDER_FREE_GLYPHS = @as(c_int, 22);
pub const XCB_RENDER_COMPOSITE_GLYPHS_8 = @as(c_int, 23);
pub const XCB_RENDER_COMPOSITE_GLYPHS_16 = @as(c_int, 24);
pub const XCB_RENDER_COMPOSITE_GLYPHS_32 = @as(c_int, 25);
pub const XCB_RENDER_FILL_RECTANGLES = @as(c_int, 26);
pub const XCB_RENDER_CREATE_CURSOR = @as(c_int, 27);
pub const XCB_RENDER_SET_PICTURE_TRANSFORM = @as(c_int, 28);
pub const XCB_RENDER_QUERY_FILTERS = @as(c_int, 29);
pub const XCB_RENDER_SET_PICTURE_FILTER = @as(c_int, 30);
pub const XCB_RENDER_CREATE_ANIM_CURSOR = @as(c_int, 31);
pub const XCB_RENDER_ADD_TRAPS = @as(c_int, 32);
pub const XCB_RENDER_CREATE_SOLID_FILL = @as(c_int, 33);
pub const XCB_RENDER_CREATE_LINEAR_GRADIENT = @as(c_int, 34);
pub const XCB_RENDER_CREATE_RADIAL_GRADIENT = @as(c_int, 35);
pub const XCB_RENDER_CREATE_CONICAL_GRADIENT = @as(c_int, 36);
pub const __SHAPE_H = "";
pub const XCB_SHAPE_MAJOR_VERSION = @as(c_int, 1);
pub const XCB_SHAPE_MINOR_VERSION = @as(c_int, 1);
pub const XCB_SHAPE_NOTIFY = @as(c_int, 0);
pub const XCB_SHAPE_QUERY_VERSION = @as(c_int, 0);
pub const XCB_SHAPE_RECTANGLES = @as(c_int, 1);
pub const XCB_SHAPE_MASK = @as(c_int, 2);
pub const XCB_SHAPE_COMBINE = @as(c_int, 3);
pub const XCB_SHAPE_OFFSET = @as(c_int, 4);
pub const XCB_SHAPE_QUERY_EXTENTS = @as(c_int, 5);
pub const XCB_SHAPE_SELECT_INPUT = @as(c_int, 6);
pub const XCB_SHAPE_INPUT_SELECTED = @as(c_int, 7);
pub const XCB_SHAPE_GET_RECTANGLES = @as(c_int, 8);
pub const XCB_XFIXES_MAJOR_VERSION = @as(c_int, 5);
pub const XCB_XFIXES_MINOR_VERSION = @as(c_int, 0);
pub const XCB_XFIXES_QUERY_VERSION = @as(c_int, 0);
pub const XCB_XFIXES_CHANGE_SAVE_SET = @as(c_int, 1);
pub const XCB_XFIXES_SELECTION_NOTIFY = @as(c_int, 0);
pub const XCB_XFIXES_SELECT_SELECTION_INPUT = @as(c_int, 2);
pub const XCB_XFIXES_CURSOR_NOTIFY = @as(c_int, 1);
pub const XCB_XFIXES_SELECT_CURSOR_INPUT = @as(c_int, 3);
pub const XCB_XFIXES_GET_CURSOR_IMAGE = @as(c_int, 4);
pub const XCB_XFIXES_BAD_REGION = @as(c_int, 0);
pub const XCB_XFIXES_CREATE_REGION = @as(c_int, 5);
pub const XCB_XFIXES_CREATE_REGION_FROM_BITMAP = @as(c_int, 6);
pub const XCB_XFIXES_CREATE_REGION_FROM_WINDOW = @as(c_int, 7);
pub const XCB_XFIXES_CREATE_REGION_FROM_GC = @as(c_int, 8);
pub const XCB_XFIXES_CREATE_REGION_FROM_PICTURE = @as(c_int, 9);
pub const XCB_XFIXES_DESTROY_REGION = @as(c_int, 10);
pub const XCB_XFIXES_SET_REGION = @as(c_int, 11);
pub const XCB_XFIXES_COPY_REGION = @as(c_int, 12);
pub const XCB_XFIXES_UNION_REGION = @as(c_int, 13);
pub const XCB_XFIXES_INTERSECT_REGION = @as(c_int, 14);
pub const XCB_XFIXES_SUBTRACT_REGION = @as(c_int, 15);
pub const XCB_XFIXES_INVERT_REGION = @as(c_int, 16);
pub const XCB_XFIXES_TRANSLATE_REGION = @as(c_int, 17);
pub const XCB_XFIXES_REGION_EXTENTS = @as(c_int, 18);
pub const XCB_XFIXES_FETCH_REGION = @as(c_int, 19);
pub const XCB_XFIXES_SET_GC_CLIP_REGION = @as(c_int, 20);
pub const XCB_XFIXES_SET_WINDOW_SHAPE_REGION = @as(c_int, 21);
pub const XCB_XFIXES_SET_PICTURE_CLIP_REGION = @as(c_int, 22);
pub const XCB_XFIXES_SET_CURSOR_NAME = @as(c_int, 23);
pub const XCB_XFIXES_GET_CURSOR_NAME = @as(c_int, 24);
pub const XCB_XFIXES_GET_CURSOR_IMAGE_AND_NAME = @as(c_int, 25);
pub const XCB_XFIXES_CHANGE_CURSOR = @as(c_int, 26);
pub const XCB_XFIXES_CHANGE_CURSOR_BY_NAME = @as(c_int, 27);
pub const XCB_XFIXES_EXPAND_REGION = @as(c_int, 28);
pub const XCB_XFIXES_HIDE_CURSOR = @as(c_int, 29);
pub const XCB_XFIXES_SHOW_CURSOR = @as(c_int, 30);
pub const XCB_XFIXES_CREATE_POINTER_BARRIER = @as(c_int, 31);
pub const XCB_XFIXES_DELETE_POINTER_BARRIER = @as(c_int, 32);
pub const XCB_INPUT_MAJOR_VERSION = @as(c_int, 2);
pub const XCB_INPUT_MINOR_VERSION = @as(c_int, 3);
pub const XCB_INPUT_GET_EXTENSION_VERSION = @as(c_int, 1);
pub const XCB_INPUT_LIST_INPUT_DEVICES = @as(c_int, 2);
pub const XCB_INPUT_OPEN_DEVICE = @as(c_int, 3);
pub const XCB_INPUT_CLOSE_DEVICE = @as(c_int, 4);
pub const XCB_INPUT_SET_DEVICE_MODE = @as(c_int, 5);
pub const XCB_INPUT_SELECT_EXTENSION_EVENT = @as(c_int, 6);
pub const XCB_INPUT_GET_SELECTED_EXTENSION_EVENTS = @as(c_int, 7);
pub const XCB_INPUT_CHANGE_DEVICE_DONT_PROPAGATE_LIST = @as(c_int, 8);
pub const XCB_INPUT_GET_DEVICE_DONT_PROPAGATE_LIST = @as(c_int, 9);
pub const XCB_INPUT_GET_DEVICE_MOTION_EVENTS = @as(c_int, 10);
pub const XCB_INPUT_CHANGE_KEYBOARD_DEVICE = @as(c_int, 11);
pub const XCB_INPUT_CHANGE_POINTER_DEVICE = @as(c_int, 12);
pub const XCB_INPUT_GRAB_DEVICE = @as(c_int, 13);
pub const XCB_INPUT_UNGRAB_DEVICE = @as(c_int, 14);
pub const XCB_INPUT_GRAB_DEVICE_KEY = @as(c_int, 15);
pub const XCB_INPUT_UNGRAB_DEVICE_KEY = @as(c_int, 16);
pub const XCB_INPUT_GRAB_DEVICE_BUTTON = @as(c_int, 17);
pub const XCB_INPUT_UNGRAB_DEVICE_BUTTON = @as(c_int, 18);
pub const XCB_INPUT_ALLOW_DEVICE_EVENTS = @as(c_int, 19);
pub const XCB_INPUT_GET_DEVICE_FOCUS = @as(c_int, 20);
pub const XCB_INPUT_SET_DEVICE_FOCUS = @as(c_int, 21);
pub const XCB_INPUT_GET_FEEDBACK_CONTROL = @as(c_int, 22);
pub const XCB_INPUT_CHANGE_FEEDBACK_CONTROL = @as(c_int, 23);
pub const XCB_INPUT_GET_DEVICE_KEY_MAPPING = @as(c_int, 24);
pub const XCB_INPUT_CHANGE_DEVICE_KEY_MAPPING = @as(c_int, 25);
pub const XCB_INPUT_GET_DEVICE_MODIFIER_MAPPING = @as(c_int, 26);
pub const XCB_INPUT_SET_DEVICE_MODIFIER_MAPPING = @as(c_int, 27);
pub const XCB_INPUT_GET_DEVICE_BUTTON_MAPPING = @as(c_int, 28);
pub const XCB_INPUT_SET_DEVICE_BUTTON_MAPPING = @as(c_int, 29);
pub const XCB_INPUT_QUERY_DEVICE_STATE = @as(c_int, 30);
pub const XCB_INPUT_DEVICE_BELL = @as(c_int, 32);
pub const XCB_INPUT_SET_DEVICE_VALUATORS = @as(c_int, 33);
pub const XCB_INPUT_GET_DEVICE_CONTROL = @as(c_int, 34);
pub const XCB_INPUT_CHANGE_DEVICE_CONTROL = @as(c_int, 35);
pub const XCB_INPUT_LIST_DEVICE_PROPERTIES = @as(c_int, 36);
pub const XCB_INPUT_CHANGE_DEVICE_PROPERTY = @as(c_int, 37);
pub const XCB_INPUT_DELETE_DEVICE_PROPERTY = @as(c_int, 38);
pub const XCB_INPUT_GET_DEVICE_PROPERTY = @as(c_int, 39);
pub const XCB_INPUT_XI_QUERY_POINTER = @as(c_int, 40);
pub const XCB_INPUT_XI_WARP_POINTER = @as(c_int, 41);
pub const XCB_INPUT_XI_CHANGE_CURSOR = @as(c_int, 42);
pub const XCB_INPUT_XI_CHANGE_HIERARCHY = @as(c_int, 43);
pub const XCB_INPUT_XI_SET_CLIENT_POINTER = @as(c_int, 44);
pub const XCB_INPUT_XI_GET_CLIENT_POINTER = @as(c_int, 45);
pub const XCB_INPUT_XI_SELECT_EVENTS = @as(c_int, 46);
pub const XCB_INPUT_XI_QUERY_VERSION = @as(c_int, 47);
pub const XCB_INPUT_XI_QUERY_DEVICE = @as(c_int, 48);
pub const XCB_INPUT_XI_SET_FOCUS = @as(c_int, 49);
pub const XCB_INPUT_XI_GET_FOCUS = @as(c_int, 50);
pub const XCB_INPUT_XI_GRAB_DEVICE = @as(c_int, 51);
pub const XCB_INPUT_XI_UNGRAB_DEVICE = @as(c_int, 52);
pub const XCB_INPUT_XI_ALLOW_EVENTS = @as(c_int, 53);
pub const XCB_INPUT_XI_PASSIVE_GRAB_DEVICE = @as(c_int, 54);
pub const XCB_INPUT_XI_PASSIVE_UNGRAB_DEVICE = @as(c_int, 55);
pub const XCB_INPUT_XI_LIST_PROPERTIES = @as(c_int, 56);
pub const XCB_INPUT_XI_CHANGE_PROPERTY = @as(c_int, 57);
pub const XCB_INPUT_XI_DELETE_PROPERTY = @as(c_int, 58);
pub const XCB_INPUT_XI_GET_PROPERTY = @as(c_int, 59);
pub const XCB_INPUT_XI_GET_SELECTED_EVENTS = @as(c_int, 60);
pub const XCB_INPUT_XI_BARRIER_RELEASE_POINTER = @as(c_int, 61);
pub const XCB_INPUT_DEVICE_VALUATOR = @as(c_int, 0);
pub const XCB_INPUT_DEVICE_KEY_PRESS = @as(c_int, 1);
pub const XCB_INPUT_DEVICE_KEY_RELEASE = @as(c_int, 2);
pub const XCB_INPUT_DEVICE_BUTTON_PRESS = @as(c_int, 3);
pub const XCB_INPUT_DEVICE_BUTTON_RELEASE = @as(c_int, 4);
pub const XCB_INPUT_DEVICE_MOTION_NOTIFY = @as(c_int, 5);
pub const XCB_INPUT_DEVICE_FOCUS_IN = @as(c_int, 6);
pub const XCB_INPUT_DEVICE_FOCUS_OUT = @as(c_int, 7);
pub const XCB_INPUT_PROXIMITY_IN = @as(c_int, 8);
pub const XCB_INPUT_PROXIMITY_OUT = @as(c_int, 9);
pub const XCB_INPUT_DEVICE_STATE_NOTIFY = @as(c_int, 10);
pub const XCB_INPUT_DEVICE_MAPPING_NOTIFY = @as(c_int, 11);
pub const XCB_INPUT_CHANGE_DEVICE_NOTIFY = @as(c_int, 12);
pub const XCB_INPUT_DEVICE_KEY_STATE_NOTIFY = @as(c_int, 13);
pub const XCB_INPUT_DEVICE_BUTTON_STATE_NOTIFY = @as(c_int, 14);
pub const XCB_INPUT_DEVICE_PRESENCE_NOTIFY = @as(c_int, 15);
pub const XCB_INPUT_DEVICE_PROPERTY_NOTIFY = @as(c_int, 16);
pub const XCB_INPUT_DEVICE_CHANGED = @as(c_int, 1);
pub const XCB_INPUT_KEY_PRESS = @as(c_int, 2);
pub const XCB_INPUT_KEY_RELEASE = @as(c_int, 3);
pub const XCB_INPUT_BUTTON_PRESS = @as(c_int, 4);
pub const XCB_INPUT_BUTTON_RELEASE = @as(c_int, 5);
pub const XCB_INPUT_MOTION = @as(c_int, 6);
pub const XCB_INPUT_ENTER = @as(c_int, 7);
pub const XCB_INPUT_LEAVE = @as(c_int, 8);
pub const XCB_INPUT_FOCUS_IN = @as(c_int, 9);
pub const XCB_INPUT_FOCUS_OUT = @as(c_int, 10);
pub const XCB_INPUT_HIERARCHY = @as(c_int, 11);
pub const XCB_INPUT_PROPERTY = @as(c_int, 12);
pub const XCB_INPUT_RAW_KEY_PRESS = @as(c_int, 13);
pub const XCB_INPUT_RAW_KEY_RELEASE = @as(c_int, 14);
pub const XCB_INPUT_RAW_BUTTON_PRESS = @as(c_int, 15);
pub const XCB_INPUT_RAW_BUTTON_RELEASE = @as(c_int, 16);
pub const XCB_INPUT_RAW_MOTION = @as(c_int, 17);
pub const XCB_INPUT_TOUCH_BEGIN = @as(c_int, 18);
pub const XCB_INPUT_TOUCH_UPDATE = @as(c_int, 19);
pub const XCB_INPUT_TOUCH_END = @as(c_int, 20);
pub const XCB_INPUT_TOUCH_OWNERSHIP = @as(c_int, 21);
pub const XCB_INPUT_RAW_TOUCH_BEGIN = @as(c_int, 22);
pub const XCB_INPUT_RAW_TOUCH_UPDATE = @as(c_int, 23);
pub const XCB_INPUT_RAW_TOUCH_END = @as(c_int, 24);
pub const XCB_INPUT_BARRIER_HIT = @as(c_int, 25);
pub const XCB_INPUT_BARRIER_LEAVE = @as(c_int, 26);
pub const XCB_INPUT_SEND_EXTENSION_EVENT = @as(c_int, 31);
pub const XCB_INPUT_DEVICE = @as(c_int, 0);
pub const XCB_INPUT_EVENT = @as(c_int, 1);
pub const XCB_INPUT_MODE = @as(c_int, 2);
pub const XCB_INPUT_DEVICE_BUSY = @as(c_int, 3);
pub const XCB_INPUT_CLASS = @as(c_int, 4);
pub const xcb_special_event = struct_xcb_special_event;
