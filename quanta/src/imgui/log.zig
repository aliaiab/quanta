const std = @import("std");
const quanta = @import("../main.zig");
const imgui = quanta.imgui.cimgui;
const widgets = quanta.imgui.widgets;

const Message = struct 
{
    level: std.log.Level,
    scope: ?[]const u8,
    timestamp: i64,
    text_offset: u32,
    text_length: u32,
};

var messages: std.ArrayListUnmanaged(Message) = .{};
var string_buffer: std.ArrayListUnmanaged(u8) = undefined;

var show_info: bool = true;
var show_warn: bool = true;
var show_err: bool = true;
var show_debug: bool = true;

pub fn viewer(name: [:0]const u8) void 
{
    defer widgets.end();

    if (!widgets.begin(name)) return;

    _ = widgets.checkbox("info", &show_info);
    imgui.igSameLine(0, 10);
    _ = widgets.checkbox("warn", &show_warn);
    imgui.igSameLine(0, 10);
    _ = widgets.checkbox("err", &show_err);
    imgui.igSameLine(0, 10);
    _ = widgets.checkbox("debug", &show_debug);

    imgui.igSeparator();

    const reserve_height = (imgui.igGetStyle().*.ItemSpacing.y * 2) + imgui.igGetFrameHeightWithSpacing();

    if (imgui.igBeginChild_Str("Scroll Area", .{ .x = 0, .y = -reserve_height }, false, imgui.ImGuiWindowFlags_HorizontalScrollbar))
    {        
        for (messages.items) |message|
        {
            if (!show_info and message.level == .info) continue;
            if (!show_warn and message.level == .warn) continue;
            if (!show_err and message.level == .err) continue;
            if (!show_debug and message.level == .debug) continue;

            const level_text = switch (message.level)
            {
                .err => "error",
                .warn => "warning",
                .info => "info",
                .debug => "debug",
            };

            const level_color: imgui.ImVec4 = switch (message.level)
            {
                .err => .{ .x = 1, .y = 0, .z = 0, .w = 1 },
                .warn => .{ .x = 1, .y = 1, .z = 0, .w = 1 },
                .info => .{ .x = 0, .y = 0, .z = 1, .w = 1 },
                .debug => .{ .x = 0, .y = 1, .z = 0, .w = 1 },
            };

            imgui.igSeparator();

            if (false)
            {
                widgets.textFormat("[{}]", .{ message.timestamp });

                imgui.igSameLine(0, 0);
            }

            imgui.igPushStyleColor_Vec4(imgui.ImGuiCol_Text, level_color);

            widgets.textFormat("[{s}]", .{ level_text });

            imgui.igSameLine(0, 0);

            imgui.igPopStyleColor(1);

            if (message.scope != null)
            {
                widgets.textFormat("[{s}]", .{ message.scope.? });

                imgui.igSameLine(0, 0);
            }

            widgets.textFormat(": {s}\n", .{ 
                string_buffer.items[message.text_offset..message.text_offset + message.text_length] 
            });
        }
    }
    imgui.igEndChild();
}

///Call this to send a log message to the log viewer
pub fn logMessage(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) !void 
{
    const fmt_size = std.fmt.count(format, args);

    const text_offset = string_buffer.items.len;

    try string_buffer.appendNTimes(std.heap.c_allocator, 0, fmt_size);

    const message_string = try std.fmt.bufPrint(string_buffer.items[text_offset..], format, args);

    try messages.append(std.heap.c_allocator, .{ 
        .level = message_level,
        .timestamp = std.time.timestamp(),
        .scope = if (scope == .default) null else std.meta.tagName(scope),
        .text_offset = @intCast(u32, text_offset), 
        .text_length = @intCast(u32, message_string.len),
    });
}