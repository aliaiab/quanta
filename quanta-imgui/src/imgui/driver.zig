var time: i64 = 0;

pub fn init() !void {
    const io: *imgui.ImGuiIO = @as(*imgui.ImGuiIO, @ptrCast(imgui.igGetIO()));

    io.ConfigFlags |= imgui.ImGuiConfigFlags_DockingEnable;
}

pub fn deinit() void {}

pub fn begin(
    window: *Window,
    input_state: quanta.input.State,
    viewport: quanta.input.Viewport,
) !void {
    const io: *imgui.ImGuiIO = @as(*imgui.ImGuiIO, @ptrCast(imgui.igGetIO()));

    const width = @as(f32, @floatFromInt(viewport.width));
    const height = @as(f32, @floatFromInt(viewport.height));

    io.DisplaySize = imgui.ImVec2{
        .x = width,
        .y = height,
    };
    io.DisplayFramebufferScale = imgui.ImVec2{ .x = 1, .y = 1 };

    const current_time = std.time.timestamp();

    io.DeltaTime = if (@as(f32, @floatFromInt(current_time - time)) > 0) @as(f32, @floatFromInt(current_time - time)) else @as(f32, 1) / @as(f32, 60);

    time = current_time;

    imgui.ImGuiIO_AddFocusEvent(io, window.isFocused());

    updateInputs(window, input_state, viewport);
}

pub fn end() void {}

fn updateInputs(
    window: *Window,
    input: quanta.input.State,
    viewport: quanta.input.Viewport,
) void {
    const io = @as(*imgui.ImGuiIO, @ptrCast(imgui.igGetIO()));

    if (io.WantCaptureMouse) {} else {}

    //Allow calling code to handle cursor capture (now possible with quanta.input)
    if (io.ConfigFlags & imgui.ImGuiConfigFlags_NoMouseCursorChange == 1 or window.isCursorCaptured()) {
        imgui.ImGuiIO_AddMouseButtonEvent(io, imgui.ImGuiMouseButton_Left, false);
        imgui.ImGuiIO_AddMouseButtonEvent(io, imgui.ImGuiMouseButton_Right, false);
        imgui.ImGuiIO_AddMouseButtonEvent(io, imgui.ImGuiMouseButton_Middle, false);

        imgui.ImGuiIO_AddMousePosEvent(io, -1, -1);

        imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Ctrl, false);
        imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Shift, false);
        imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Alt, false);
        imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Super, false);

        for (std.enums.values(quanta.input.KeyboardKey)) |key| {
            imgui.ImGuiIO_AddKeyEvent(io, quantaToImGuiKey(key), false);
        }

        imgui.ImGuiIO_ClearInputKeys(io);

        return;
    }

    const imgui_cursor = @as(usize, @intCast(imgui.igGetMouseCursor()));

    if (imgui_cursor == imgui.ImGuiMouseCursor_None or io.MouseDrawCursor) {
        window.hideCursor();
    } else {
        window.unhideCursor();
    }

    imgui.ImGuiIO_AddMousePosEvent(
        io,
        @as(f32, @floatFromInt(viewport.cursor_position[0])),
        @as(f32, @floatFromInt(viewport.cursor_position[1])),
    );

    imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Ctrl, input.getKeyboardKey(.left_control) == .down or input.getKeyboardKey(.right_control) == .down);
    imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Shift, input.getKeyboardKey(.left_shift) == .down or input.getKeyboardKey(.right_shift) == .down);
    imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Alt, input.getKeyboardKey(.left_alt) == .down or input.getKeyboardKey(.right_alt) == .down);
    imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Super, input.getKeyboardKey(.left_super) == .down or input.getKeyboardKey(.right_super) == .down);

    for (std.enums.values(quanta.input.KeyboardKey)) |key| {
        imgui.ImGuiIO_AddKeyEvent(io, quantaToImGuiKey(key), input.getKeyboardKey(key) != .release);
    }

    const input_text = window.getUtf8Input();

    for (input_text) |character| {
        const string: [2]u8 = .{ character, 0 };

        imgui.ImGuiIO_AddInputCharactersUTF8(io, &string);
    }

    imgui.ImGuiIO_AddMouseButtonEvent(io, imgui.ImGuiMouseButton_Left, input.getMouseButton(.left) == .down);
    imgui.ImGuiIO_AddMouseButtonEvent(io, imgui.ImGuiMouseButton_Right, input.getMouseButton(.right) == .down);
    imgui.ImGuiIO_AddMouseButtonEvent(io, imgui.ImGuiMouseButton_Middle, input.getMouseButton(.middle) == .down);

    imgui.ImGuiIO_AddMouseWheelEvent(io, 0, @floatFromInt(input.getMouseScroll()));
}

fn quantaToImGuiKey(key: quanta.input.KeyboardKey) c_uint {
    return switch (key) {
        .tab => imgui.ImGuiKey_Tab,
        .left => imgui.ImGuiKey_LeftArrow,
        .right => imgui.ImGuiKey_RightArrow,
        .up => imgui.ImGuiKey_UpArrow,
        .down => imgui.ImGuiKey_DownArrow,
        .page_up => imgui.ImGuiKey_PageUp,
        .page_down => imgui.ImGuiKey_PageDown,
        .home => imgui.ImGuiKey_Home,
        .end => imgui.ImGuiKey_End,
        .insert => imgui.ImGuiKey_Insert,
        .delete => imgui.ImGuiKey_Delete,
        .backspace => imgui.ImGuiKey_Backspace,
        .space => imgui.ImGuiKey_Space,
        .enter => imgui.ImGuiKey_Enter,
        .escape => imgui.ImGuiKey_Escape,
        .apostrophe => imgui.ImGuiKey_Apostrophe,
        .comma => imgui.ImGuiKey_Comma,
        .minus => imgui.ImGuiKey_Minus,
        .period => imgui.ImGuiKey_Period,
        .slash => imgui.ImGuiKey_Slash,
        .semicolon => imgui.ImGuiKey_Semicolon,
        .equal => imgui.ImGuiKey_Equal,
        .left_bracket => imgui.ImGuiKey_LeftBracket,
        .backslash => imgui.ImGuiKey_Backslash,
        .right_bracket => imgui.ImGuiKey_RightBracket,
        .grave_accent => imgui.ImGuiKey_GraveAccent,
        .caps_lock => imgui.ImGuiKey_CapsLock,
        .scroll_lock => imgui.ImGuiKey_ScrollLock,
        .num_lock => imgui.ImGuiKey_NumLock,
        .print_screen => imgui.ImGuiKey_PrintScreen,
        .pause => imgui.ImGuiKey_Pause,
        .kp_0 => imgui.ImGuiKey_Keypad0,
        .kp_1 => imgui.ImGuiKey_Keypad1,
        .kp_2 => imgui.ImGuiKey_Keypad2,
        .kp_3 => imgui.ImGuiKey_Keypad3,
        .kp_4 => imgui.ImGuiKey_Keypad4,
        .kp_5 => imgui.ImGuiKey_Keypad5,
        .kp_6 => imgui.ImGuiKey_Keypad6,
        .kp_7 => imgui.ImGuiKey_Keypad7,
        .kp_8 => imgui.ImGuiKey_Keypad8,
        .kp_9 => imgui.ImGuiKey_Keypad9,
        .kp_decimal => imgui.ImGuiKey_KeypadDecimal,
        .kp_divide => imgui.ImGuiKey_KeypadDivide,
        .kp_multiply => imgui.ImGuiKey_KeypadMultiply,
        .kp_subtract => imgui.ImGuiKey_KeypadSubtract,
        .kp_add => imgui.ImGuiKey_KeypadAdd,
        .kp_enter => imgui.ImGuiKey_KeypadEnter,
        .kp_equal => imgui.ImGuiKey_KeypadEqual,
        .left_shift => imgui.ImGuiKey_LeftShift,
        .left_control => imgui.ImGuiKey_LeftCtrl,
        .left_alt => imgui.ImGuiKey_LeftAlt,
        .left_super => imgui.ImGuiKey_LeftSuper,
        .right_shift => imgui.ImGuiKey_RightShift,
        .right_control => imgui.ImGuiKey_RightCtrl,
        .right_alt => imgui.ImGuiKey_RightAlt,
        .right_super => imgui.ImGuiKey_RightSuper,
        .menu => imgui.ImGuiKey_Menu,
        .zero => imgui.ImGuiKey_0,
        .one => imgui.ImGuiKey_1,
        .two => imgui.ImGuiKey_2,
        .three => imgui.ImGuiKey_3,
        .four => imgui.ImGuiKey_4,
        .five => imgui.ImGuiKey_5,
        .six => imgui.ImGuiKey_6,
        .seven => imgui.ImGuiKey_7,
        .eight => imgui.ImGuiKey_8,
        .nine => imgui.ImGuiKey_9,
        .a => imgui.ImGuiKey_A,
        .b => imgui.ImGuiKey_B,
        .c => imgui.ImGuiKey_C,
        .d => imgui.ImGuiKey_D,
        .e => imgui.ImGuiKey_E,
        .f => imgui.ImGuiKey_F,
        .g => imgui.ImGuiKey_G,
        .h => imgui.ImGuiKey_H,
        .i => imgui.ImGuiKey_I,
        .j => imgui.ImGuiKey_J,
        .k => imgui.ImGuiKey_K,
        .l => imgui.ImGuiKey_L,
        .m => imgui.ImGuiKey_M,
        .n => imgui.ImGuiKey_N,
        .o => imgui.ImGuiKey_O,
        .p => imgui.ImGuiKey_P,
        .q => imgui.ImGuiKey_Q,
        .r => imgui.ImGuiKey_R,
        .s => imgui.ImGuiKey_S,
        .t => imgui.ImGuiKey_T,
        .u => imgui.ImGuiKey_U,
        .v => imgui.ImGuiKey_V,
        .w => imgui.ImGuiKey_W,
        .x => imgui.ImGuiKey_X,
        .y => imgui.ImGuiKey_Y,
        .z => imgui.ImGuiKey_Z,
        .F1 => imgui.ImGuiKey_F1,
        .F2 => imgui.ImGuiKey_F2,
        .F3 => imgui.ImGuiKey_F3,
        .F4 => imgui.ImGuiKey_F4,
        .F5 => imgui.ImGuiKey_F5,
        .F6 => imgui.ImGuiKey_F6,
        .F7 => imgui.ImGuiKey_F7,
        .F8 => imgui.ImGuiKey_F8,
        .F9 => imgui.ImGuiKey_F9,
        .F10 => imgui.ImGuiKey_F10,
        .F11 => imgui.ImGuiKey_F11,
        .F12 => imgui.ImGuiKey_F12,
        else => imgui.ImGuiKey_None,
    };
}

const std = @import("std");
const imgui = @import("../root.zig").cimgui;
const windowing = quanta.windowing;
const Window = quanta.windowing.Window;
const quanta = @import("quanta");
