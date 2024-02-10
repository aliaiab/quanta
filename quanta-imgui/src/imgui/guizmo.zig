const cimgui = @import("../root.zig").cimgui;

pub const Mode = enum(u32) { local, world };

pub const Operation = packed struct(u32) {
    translate_x: bool = false,
    translate_y: bool = false,
    translate_z: bool = false,
    rotate_x: bool = false,
    rotate_y: bool = false,
    rotate_z: bool = false,
    rotate_screen: bool = false,
    scale_x: bool = false,
    scale_y: bool = false,
    scale_z: bool = false,
    bounds: bool = false,
    scale_xu: bool = false,
    scale_yu: bool = false,
    scale_zu: bool = false,

    padding: u18 = 0,

    pub const translate = Operation{ .translate_x = true, .translate_y = true, .translate_z = true };
    pub const scale = Operation{ .scale_x = true, .scale_y = true, .scale_z = true };
    pub const rotate = Operation{ .rotate_x = true, .rotate_y = true, .rotate_z = true, .rotate_screen = true };
    pub const universal = Operation{
        .translate_x = true,
        .translate_y = true,
        .translate_z = true,
        .rotate_x = true,
        .rotate_y = true,
        .rotate_z = true,
        .rotate_screen = true,
        .scale_x = true,
        .scale_Y = true,
        .scale_z = true,
    };
};

pub extern fn ImGuizmo_SetDrawlist(drawlist: [*c]cimgui.ImDrawList) void;
pub extern fn ImGuizmo_BeginFrame() void;
pub extern fn ImGuizmo_SetImGuiContext(ctx: [*c]cimgui.ImGuiContext) void;
pub extern fn ImGuizmo_IsOver() bool;
pub extern fn ImGuizmo_IsUsing() bool;
pub extern fn ImGuizmo_Enable(enable: bool) void;
pub extern fn ImGuizmo_DecomposeMatrixToComponents(matrix: [*]f32, translation: [*]f32, rotation: [*]f32, scale: [*]f32) void;
pub extern fn ImGuizmo_RecomposeMatrixFromComponents(translation: [*]const f32, rotation: [*]const f32, scale: [*]const f32, matrix: [*]f32) void;
pub extern fn ImGuizmo_SetRect(x: f32, y: f32, width: f32, height: f32) void;
pub extern fn ImGuizmo_SetOrthographic(is_orthographic: bool) void;
pub extern fn ImGuizmo_DrawCubes(view: [*]const f32, projection: [*]const f32, matrices: [*]const f32, matrix_count: c_int) void;
pub extern fn ImGuizmo_DrawGrid(view: [*]const f32, projection: [*]const f32, matrix: [*]const f32, grid_size: f32) void;
pub extern fn ImGuizmo_Manipulate(view: [*]const f32, projection: [*]const f32, operation: Operation, mode: Mode, matrix: [*]f32, delta_matrix: ?[*]f32, snap: ?[*]f32, local_bounds: ?[*]const f32, bounds_snap: ?[*]const f32) bool;
pub extern fn ImGuizmo_ViewManipulate(view: [*]f32, length: f32, position: cimgui.ImVec2, size: cimgui.ImVec2, background_color: u32) void;
pub extern fn ImGuizmo_ViewManipulateExt(view: [*]f32, projection: [*]const f32, operation: Operation, mode: Mode, matrix: [*]f32, length: f32, position: cimgui.ImVec2, size: cimgui.ImVec2, background_color: u32) void;
pub extern fn ImGuizmo_SetID(id: u32) void;
pub extern fn ImGuizmo_IsOperationOver(op: Operation) bool;
pub extern fn ImGuizmo_SetGizmoSizeClipSpace(value: f32) void;
pub extern fn ImGuizmo_AllowAxisFlip(value: bool) void;
