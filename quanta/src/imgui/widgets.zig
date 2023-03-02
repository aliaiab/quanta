const std = @import("std");
const imgui = @import("cimgui.zig");

pub fn begin(title: [:0]const u8) bool
{
    return imgui.igBegin(title.ptr, null, 0);
}

pub fn end() void 
{
    imgui.igEnd();
}

pub fn text(string: []const u8) void 
{
    imgui.igTextUnformatted(string.ptr, string.ptr + string.len);
}

pub fn textFormat(comptime format: []const u8, args: anytype) void 
{
    var format_buf: [4096 * 8]u8 = undefined;

    text(std.fmt.bufPrint(&format_buf, format, args) catch unreachable);
}

pub fn button(label: [:0]const u8) bool
{
    return imgui.igButton(label.ptr, .{ .x = 0, .y = 0 });
}

pub fn treeNodePush(comptime format: []const u8, args: anytype) bool 
{
    var format_buf: [4096 * 8]u8 = undefined;

    const label = std.fmt.bufPrint(&format_buf, format, args) catch unreachable;

    const widget_id = imgui.ImGuiWindow_GetID_Str(imgui.igGetCurrentWindow(), label.ptr, label.ptr + label.len);

    return imgui.igTreeNodeBehavior(widget_id, 0, label.ptr, label.ptr + label.len);
}

pub fn treeNodePop() void 
{
    imgui.igTreePop();
}

pub fn collapsingHeader(comptime format: []const u8, args: anytype) bool 
{
    var format_buf: [4096 * 8]u8 = undefined;

    const label = std.fmt.bufPrintZ(&format_buf, format, args) catch unreachable;

    return imgui.igCollapsingHeader_BoolPtr(label.ptr, null, 0);
}

pub fn dragFloat(label: []const u8, float: *f32) void 
{
    _ = imgui.igDragFloat(label.ptr, float, 0.1, std.math.f32_min, std.math.f32_max, null, 0);
}