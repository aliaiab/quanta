var time: i64 = 0;

pub fn init() !void {
    const io = imgui.getIO();

    io.ConfigFlags |= cimgui.ImGuiConfigFlags_DockingEnable;

    var pixel_pointer: [*c]u8 = undefined;
    var width: c_int = 0;
    var height: c_int = 0;
    var out_bytes_per_pixel: c_int = 0;

    //imgui asserts that we've called this function before imgui::NewFrame.
    //We call this in the render graph build for renderer_gui, which hasn't ran yet.s
    //We need to solve this as an high level api problem (when do we run grap build?)
    cimgui.ImFontAtlas_GetTexDataAsAlpha8(
        io.Fonts,
        &pixel_pointer,
        &width,
        &height,
        &out_bytes_per_pixel,
    );
}

pub fn deinit() void {}

pub fn begin(
    window: *Window,
    input_state: quanta.input.State,
    viewport: quanta.input.Viewport,
) !void {
    const io: *cimgui.ImGuiIO = @as(*cimgui.ImGuiIO, @ptrCast(cimgui.igGetIO()));

    const width = @as(f32, @floatFromInt(viewport.width));
    const height = @as(f32, @floatFromInt(viewport.height));

    io.DisplaySize = cimgui.ImVec2{
        .x = width,
        .y = height,
    };
    io.DisplayFramebufferScale = cimgui.ImVec2{ .x = 1, .y = 1 };

    const current_time = std.time.microTimestamp();

    const delta_time_micros = @as(f32, @floatFromInt(current_time - time));

    io.DeltaTime = if (time != 0) delta_time_micros / std.time.us_per_s else @as(f32, 1) / @as(f32, 60);

    time = current_time;

    cimgui.ImGuiIO_AddFocusEvent(io, window.isFocused());

    updateInputs(window, input_state, viewport);
}

pub fn end() void {}

fn updateInputs(
    window: *Window,
    input: quanta.input.State,
    viewport: quanta.input.Viewport,
) void {
    const io = @as(*cimgui.ImGuiIO, @ptrCast(cimgui.igGetIO()));

    if (io.WantCaptureMouse) {} else {}

    //Allow calling code to handle cursor capture (now possible with quanta.input)
    if (io.ConfigFlags & cimgui.ImGuiConfigFlags_NoMouseCursorChange == 1 or window.isCursorCaptured()) {
        cimgui.ImGuiIO_AddMouseButtonEvent(io, cimgui.ImGuiMouseButton_Left, false);
        cimgui.ImGuiIO_AddMouseButtonEvent(io, cimgui.ImGuiMouseButton_Right, false);
        cimgui.ImGuiIO_AddMouseButtonEvent(io, cimgui.ImGuiMouseButton_Middle, false);

        cimgui.ImGuiIO_AddMousePosEvent(io, -1, -1);

        cimgui.ImGuiIO_AddKeyEvent(io, cimgui.ImGuiMod_Ctrl, false);
        cimgui.ImGuiIO_AddKeyEvent(io, cimgui.ImGuiMod_Shift, false);
        cimgui.ImGuiIO_AddKeyEvent(io, cimgui.ImGuiMod_Alt, false);
        cimgui.ImGuiIO_AddKeyEvent(io, cimgui.ImGuiMod_Super, false);

        for (std.enums.values(quanta.input.KeyboardKey)) |key| {
            cimgui.ImGuiIO_AddKeyEvent(io, quantaToImGuiKey(key), false);
        }

        cimgui.ImGuiIO_ClearInputKeys(io);

        return;
    }

    const imgui_cursor = @as(usize, @intCast(cimgui.igGetMouseCursor()));

    if (imgui_cursor == cimgui.ImGuiMouseCursor_None or io.MouseDrawCursor) {
        window.hideCursor();
    } else {
        window.unhideCursor();
    }

    cimgui.ImGuiIO_AddMousePosEvent(
        io,
        @as(f32, @floatFromInt(viewport.cursor_position[0])),
        @as(f32, @floatFromInt(viewport.cursor_position[1])),
    );

    cimgui.ImGuiIO_AddKeyEvent(io, cimgui.ImGuiMod_Ctrl, input.getKeyboardKey(.left_control) == .down or input.getKeyboardKey(.right_control) == .down);
    cimgui.ImGuiIO_AddKeyEvent(io, cimgui.ImGuiMod_Shift, input.getKeyboardKey(.left_shift) == .down or input.getKeyboardKey(.right_shift) == .down);
    cimgui.ImGuiIO_AddKeyEvent(io, cimgui.ImGuiMod_Alt, input.getKeyboardKey(.left_alt) == .down or input.getKeyboardKey(.right_alt) == .down);
    cimgui.ImGuiIO_AddKeyEvent(io, cimgui.ImGuiMod_Super, input.getKeyboardKey(.left_super) == .down or input.getKeyboardKey(.right_super) == .down);

    for (std.enums.values(quanta.input.KeyboardKey)) |key| {
        cimgui.ImGuiIO_AddKeyEvent(io, quantaToImGuiKey(key), input.getKeyboardKey(key) != .release);
    }

    const input_text = window.getUtf8Input();

    for (input_text) |character| {
        const string: [2]u8 = .{ character, 0 };

        cimgui.ImGuiIO_AddInputCharactersUTF8(io, &string);
    }

    cimgui.ImGuiIO_AddMouseButtonEvent(io, cimgui.ImGuiMouseButton_Left, input.getMouseButton(.left) == .down);
    cimgui.ImGuiIO_AddMouseButtonEvent(io, cimgui.ImGuiMouseButton_Right, input.getMouseButton(.right) == .down);
    cimgui.ImGuiIO_AddMouseButtonEvent(io, cimgui.ImGuiMouseButton_Middle, input.getMouseButton(.middle) == .down);

    cimgui.ImGuiIO_AddMouseWheelEvent(io, 0, @floatFromInt(input.getMouseScroll()));
}

fn quantaToImGuiKey(key: quanta.input.KeyboardKey) c_uint {
    return switch (key) {
        .tab => cimgui.ImGuiKey_Tab,
        .left => cimgui.ImGuiKey_LeftArrow,
        .right => cimgui.ImGuiKey_RightArrow,
        .up => cimgui.ImGuiKey_UpArrow,
        .down => cimgui.ImGuiKey_DownArrow,
        .page_up => cimgui.ImGuiKey_PageUp,
        .page_down => cimgui.ImGuiKey_PageDown,
        .home => cimgui.ImGuiKey_Home,
        .end => cimgui.ImGuiKey_End,
        .insert => cimgui.ImGuiKey_Insert,
        .delete => cimgui.ImGuiKey_Delete,
        .backspace => cimgui.ImGuiKey_Backspace,
        .space => cimgui.ImGuiKey_Space,
        .enter => cimgui.ImGuiKey_Enter,
        .escape => cimgui.ImGuiKey_Escape,
        .apostrophe => cimgui.ImGuiKey_Apostrophe,
        .comma => cimgui.ImGuiKey_Comma,
        .minus => cimgui.ImGuiKey_Minus,
        .period => cimgui.ImGuiKey_Period,
        .slash => cimgui.ImGuiKey_Slash,
        .semicolon => cimgui.ImGuiKey_Semicolon,
        .equal => cimgui.ImGuiKey_Equal,
        .left_bracket => cimgui.ImGuiKey_LeftBracket,
        .backslash => cimgui.ImGuiKey_Backslash,
        .right_bracket => cimgui.ImGuiKey_RightBracket,
        .grave_accent => cimgui.ImGuiKey_GraveAccent,
        .caps_lock => cimgui.ImGuiKey_CapsLock,
        .scroll_lock => cimgui.ImGuiKey_ScrollLock,
        .num_lock => cimgui.ImGuiKey_NumLock,
        .print_screen => cimgui.ImGuiKey_PrintScreen,
        .pause => cimgui.ImGuiKey_Pause,
        .kp_0 => cimgui.ImGuiKey_Keypad0,
        .kp_1 => cimgui.ImGuiKey_Keypad1,
        .kp_2 => cimgui.ImGuiKey_Keypad2,
        .kp_3 => cimgui.ImGuiKey_Keypad3,
        .kp_4 => cimgui.ImGuiKey_Keypad4,
        .kp_5 => cimgui.ImGuiKey_Keypad5,
        .kp_6 => cimgui.ImGuiKey_Keypad6,
        .kp_7 => cimgui.ImGuiKey_Keypad7,
        .kp_8 => cimgui.ImGuiKey_Keypad8,
        .kp_9 => cimgui.ImGuiKey_Keypad9,
        .kp_decimal => cimgui.ImGuiKey_KeypadDecimal,
        .kp_divide => cimgui.ImGuiKey_KeypadDivide,
        .kp_multiply => cimgui.ImGuiKey_KeypadMultiply,
        .kp_subtract => cimgui.ImGuiKey_KeypadSubtract,
        .kp_add => cimgui.ImGuiKey_KeypadAdd,
        .kp_enter => cimgui.ImGuiKey_KeypadEnter,
        .kp_equal => cimgui.ImGuiKey_KeypadEqual,
        .left_shift => cimgui.ImGuiKey_LeftShift,
        .left_control => cimgui.ImGuiKey_LeftCtrl,
        .left_alt => cimgui.ImGuiKey_LeftAlt,
        .left_super => cimgui.ImGuiKey_LeftSuper,
        .right_shift => cimgui.ImGuiKey_RightShift,
        .right_control => cimgui.ImGuiKey_RightCtrl,
        .right_alt => cimgui.ImGuiKey_RightAlt,
        .right_super => cimgui.ImGuiKey_RightSuper,
        .menu => cimgui.ImGuiKey_Menu,
        .zero => cimgui.ImGuiKey_0,
        .one => cimgui.ImGuiKey_1,
        .two => cimgui.ImGuiKey_2,
        .three => cimgui.ImGuiKey_3,
        .four => cimgui.ImGuiKey_4,
        .five => cimgui.ImGuiKey_5,
        .six => cimgui.ImGuiKey_6,
        .seven => cimgui.ImGuiKey_7,
        .eight => cimgui.ImGuiKey_8,
        .nine => cimgui.ImGuiKey_9,
        .a => cimgui.ImGuiKey_A,
        .b => cimgui.ImGuiKey_B,
        .c => cimgui.ImGuiKey_C,
        .d => cimgui.ImGuiKey_D,
        .e => cimgui.ImGuiKey_E,
        .f => cimgui.ImGuiKey_F,
        .g => cimgui.ImGuiKey_G,
        .h => cimgui.ImGuiKey_H,
        .i => cimgui.ImGuiKey_I,
        .j => cimgui.ImGuiKey_J,
        .k => cimgui.ImGuiKey_K,
        .l => cimgui.ImGuiKey_L,
        .m => cimgui.ImGuiKey_M,
        .n => cimgui.ImGuiKey_N,
        .o => cimgui.ImGuiKey_O,
        .p => cimgui.ImGuiKey_P,
        .q => cimgui.ImGuiKey_Q,
        .r => cimgui.ImGuiKey_R,
        .s => cimgui.ImGuiKey_S,
        .t => cimgui.ImGuiKey_T,
        .u => cimgui.ImGuiKey_U,
        .v => cimgui.ImGuiKey_V,
        .w => cimgui.ImGuiKey_W,
        .x => cimgui.ImGuiKey_X,
        .y => cimgui.ImGuiKey_Y,
        .z => cimgui.ImGuiKey_Z,
        .F1 => cimgui.ImGuiKey_F1,
        .F2 => cimgui.ImGuiKey_F2,
        .F3 => cimgui.ImGuiKey_F3,
        .F4 => cimgui.ImGuiKey_F4,
        .F5 => cimgui.ImGuiKey_F5,
        .F6 => cimgui.ImGuiKey_F6,
        .F7 => cimgui.ImGuiKey_F7,
        .F8 => cimgui.ImGuiKey_F8,
        .F9 => cimgui.ImGuiKey_F9,
        .F10 => cimgui.ImGuiKey_F10,
        .F11 => cimgui.ImGuiKey_F11,
        .F12 => cimgui.ImGuiKey_F12,
        else => cimgui.ImGuiKey_None,
    };
}

const std = @import("std");
const imgui = @import("../imgui.zig");
const cimgui = @import("../root.zig").cimgui;
const windowing = quanta.windowing;
const Window = quanta.windowing.Window;
const quanta = @import("quanta");
