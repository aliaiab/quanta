const std = @import("std");
const imgui = @import("../root.zig").cimgui;
const zalgebra = @import("quanta").math.zalgebra;

pub fn begin(title: [:0]const u8) bool {
    return imgui.igBegin(title.ptr, null, 0);
}

pub fn beginWindow(comptime format: []const u8, args: anytype) bool {
    var format_buf: [4096 * 16]u8 = undefined;

    const title_buf = std.fmt.bufPrintZ(&format_buf, format, args) catch unreachable;

    return imgui.igBegin(title_buf.ptr, null, 0);
}

pub fn end() void {
    imgui.igEnd();
}

pub fn text(string: []const u8) void {
    imgui.igTextUnformatted(string.ptr, string.ptr + string.len);
}

pub fn textFormat(comptime format: []const u8, args: anytype) void {
    var format_buf: [4096 * 16]u8 = undefined;

    text(std.fmt.bufPrint(&format_buf, format, args) catch unreachable);
}

pub fn button(label: [:0]const u8) bool {
    return imgui.igButton(label.ptr, .{ .x = 0, .y = 0 });
}

pub fn checkbox(label: [:0]const u8, value: *bool) bool {
    return imgui.igCheckbox(label, value);
}

pub fn treeNodePush(comptime format: []const u8, args: anytype, default_open: bool) bool {
    var format_buf: [4096 * 8]u8 = undefined;

    const label = std.fmt.bufPrint(&format_buf, format, args) catch unreachable;

    const widget_id = imgui.ImGuiWindow_GetID_Str(imgui.igGetCurrentWindow(), label.ptr, label.ptr + label.len);

    return imgui.igTreeNodeBehavior(widget_id, if (default_open) imgui.ImGuiTreeNodeFlags_DefaultOpen else 0, label.ptr, label.ptr + label.len);
}

pub fn treeNodePop() void {
    imgui.igTreePop();
}

pub fn collapsingHeader(comptime format: []const u8, args: anytype) bool {
    var format_buf: [4096 * 8]u8 = undefined;

    const label = std.fmt.bufPrintZ(&format_buf, format, args) catch unreachable;

    return imgui.igCollapsingHeader_BoolPtr(label.ptr, null, 0);
}

pub fn dragFloat(label: []const u8, float: *f32) void {
    _ = imgui.igInputFloat(label.ptr, float, 0.1, 0, 0, 0);
}

pub fn drawBillboard(
    view_projection: zalgebra.Mat4,
    position: @Vector(3, f32),
    radius: f32,
) void {
    const viewport = imgui.igGetWindowViewport();
    const draw_list = imgui.igGetBackgroundDrawList_ViewportPtr(viewport);

    const screen_pos = worldToScreenPos(position, view_projection, viewport) orelse return;

    imgui.ImDrawList_AddCircleFilled(
        draw_list,
        .{ .x = screen_pos[0], .y = screen_pos[1] },
        radius,
        0xffffffff,
        32,
    );
}

pub fn drawBoundingBox(
    view_projection: zalgebra.Mat4,
    transform: zalgebra.Mat4,
    min: @Vector(3, f32),
    max: @Vector(3, f32),
) void {
    const model_view_projection = view_projection.mul(transform);

    const lines = [_][2]@Vector(3, f32){
        .{ .{ min[0], min[1], min[2] }, .{ max[0], min[1], min[2] } },
        .{ .{ min[0], min[1], min[2] }, .{ min[0], max[1], min[2] } },
        .{ .{ min[0], min[1], min[2] }, .{ min[0], min[1], max[2] } },
        .{ .{ min[0], max[1], min[2] }, .{ max[0], max[1], min[2] } },
        .{ .{ max[0], max[1], min[2] }, .{ max[0], min[1], min[2] } },
        .{ .{ max[0], min[1], min[2] }, .{ max[0], min[1], max[2] } },
        .{ .{ max[0], max[1], min[2] }, .{ max[0], max[1], max[2] } },
        .{ .{ min[0], max[1], min[2] }, .{ min[0], max[1], max[2] } },
        .{ .{ min[0], max[1], max[2] }, .{ max[0], max[1], max[2] } },
        .{ .{ min[0], max[1], max[2] }, .{ min[0], min[1], max[2] } },
        .{ .{ min[0], min[1], max[2] }, .{ max[0], min[1], max[2] } },
        .{ .{ max[0], max[1], max[2] }, .{ max[0], min[1], max[2] } },
    };

    const camera_pos = model_view_projection.mulByVec4(zalgebra.Vec4.zero());

    //Primitive clipping
    if (camera_pos.x() < -1 or camera_pos.x() > 1 or
        camera_pos.y() < -1 or camera_pos.y() > 1 or
        camera_pos.z() < -1 or camera_pos.z() > 1)
    {
        return;
    }

    const viewport = imgui.igGetWindowViewport();

    for (lines) |line_pair| {
        drawLine(model_view_projection, viewport, line_pair);
    }
}

pub fn drawLine(model_view_projection: zalgebra.Mat4, viewport: *imgui.ImGuiViewport, line: [2]@Vector(3, f32)) void {
    const p0 = worldToScreenPos(line[0], model_view_projection, viewport) orelse return;
    const p1 = worldToScreenPos(line[1], model_view_projection, viewport) orelse return;

    const draw_list = imgui.igGetBackgroundDrawList_ViewportPtr(viewport);

    imgui.ImDrawList_AddLine(draw_list, .{ .x = p0[0], .y = p0[1] }, .{ .x = p1[0], .y = p1[1] }, 0xffffffff, 2);
}

const OutCode = packed struct(u6) {
    left: bool = false,
    right: bool = false,
    forward: bool = false,
    backward: bool = false,
    bottom: bool = false,
    top: bool = false,

    pub const inside = OutCode{};
};

fn lineComputeOutCodeNormalized(point: @Vector(3, f32)) OutCode {
    var out_code = OutCode.inside;

    const min = -1;
    const max = 1;

    if (point[0] < min) {
        out_code.left = true;
    } else if (point[0] > max) {
        out_code.right = true;
    }

    if (point[1] < min) {
        out_code.bottom = true;
    } else if (point[1] > max) {
        out_code.top = true;
    }

    if (point[2] < min) {
        out_code.backward = true;
    } else if (point[2] > max) {
        out_code.forward = true;
    }

    return out_code;
}

///Clips the input line to a -1 to +1 clip volume
fn lineClipNormalized(line: [2]@Vector(3, f32)) ?[2]@Vector(3, f32) {
    var outcode_0 = lineComputeOutCodeNormalized(line[0]);
    var outcode_1 = lineComputeOutCodeNormalized(line[1]);

    const new_line = line;

    while (true) {
        if (outcode_0 == OutCode.inside and outcode_1 == OutCode.inside) {
            return new_line;
        } else if (outcode_0 != OutCode.inside and outcode_1 == OutCode.inside) {
            break;
        } else {
            const min = -1;
            const max = 1;

            const outcode_out = if (outcode_0 != OutCode.inside) outcode_0 else outcode_1;

            var endpoint: @Vector(3, f32) = .{ 0, 0, 0 };

            if (outcode_out.top) {
                endpoint[0] = new_line[0][0] + (new_line[1][0] - new_line[0][0]) * (max - new_line[0][1]) / (new_line[1][1] - new_line[0][1]);
                endpoint[1] = max;
                endpoint[2] = min;
            } else if (outcode_out.bottom) {} else if (outcode_out.left) {} else if (outcode_out.right) {} else if (outcode_out.forward) {} else if (outcode_out.backward) {}

            if (outcode_out == outcode_0) {
                outcode_0 = lineComputeOutCodeNormalized(new_line[0]);
            } else {
                outcode_1 = lineComputeOutCodeNormalized(new_line[1]);
            }
        }
    }

    return null;
}

///Returns null if world_pos doesn't map to a position on the screen (and should be clipped)
pub fn worldToScreenPos(
    world_pos: @Vector(3, f32),
    matrix: zalgebra.Mat4,
    viewport: *imgui.ImGuiViewport,
) ?@Vector(2, f32) {
    var screen_ndc = matrix.mulByVec4(.{ .data = .{ world_pos[0], world_pos[1], world_pos[2], 1 } });

    screen_ndc.data /= @as(@Vector(4, f32), @splat(screen_ndc.w()));

    //TODO: use a general line clipping algorithm
    if (screen_ndc.z() < -1 or screen_ndc.z() > 1) {
        return null;
    }

    screen_ndc.data *= @as(@Vector(4, f32), @splat(0.5));
    screen_ndc.data += @as(@Vector(4, f32), @splat(0.5));

    var translation: @Vector(2, f32) = .{ screen_ndc.x(), screen_ndc.y() };

    translation[1] = 1 - translation[1];

    const screen_width = viewport.Size.x;
    const screen_height = viewport.Size.y;

    translation[0] *= screen_width;
    translation[1] *= screen_height;

    translation[0] += viewport.Pos.x;
    translation[1] += viewport.Pos.y;

    return translation;
}
