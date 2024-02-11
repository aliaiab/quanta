pub const EditorContext = opaque {};
pub const NodeId = u32;
pub const LinkId = u32;
pub const PinId = u32;

pub const PinKind = enum(u32) {
    input = 0,
    output = 1,
};

pub const LinkFlow = enum(u32) {
    forward,
    backward,
};

pub extern fn im_node_create_editor() callconv(.C) *EditorContext;
pub extern fn im_node_destroy_editor(editor: *EditorContext) callconv(.C) void;
pub extern fn im_node_set_current_editor(editor: ?*EditorContext) callconv(.C) void;
pub extern fn im_node_begin(id: [*:0]const u8, size: cimgui.ImVec2) callconv(.C) void;
pub extern fn im_node_end() callconv(.C) void;
pub extern fn im_node_begin_node(node: NodeId) callconv(.C) void;
pub extern fn im_node_end_node() callconv(.C) void;
pub extern fn im_node_begin_pin(node: PinId, kind: PinKind) callconv(.C) void;
pub extern fn im_node_end_pin() callconv(.C) void;
pub extern fn im_node_set_node_position(node: NodeId, position: cimgui.ImVec2) callconv(.C) void;
pub extern fn im_node_link(id: LinkId, start_pin: PinId, end_pin: PinId) callconv(.C) bool;
pub extern fn im_node_link_flow(id: LinkId, flow: LinkFlow) callconv(.C) void;
pub extern fn im_node_get_selected_nodes(nodes: [*]NodeId, size: usize) usize;

const cimgui = @import("cimgui.zig");
const std = @import("std");
