//! Describes the entire state of keyboard, mouse and cursor input at a given point in time

//TODO: Button action only requires 2 bits, store these in a dense bit array
buttons_keyboard: std.EnumArray(input.KeyboardKey, input.ButtonAction) = .initFill(.release),
buttons_mouse: std.EnumArray(input.MouseButton, input.ButtonAction) = .initFill(.release),

mouse_scroll: i32 = 0,

cursor_position: [2]i16 = @splat(-1),
cursor_motion: [2]i16 = @splat(0),

pub fn getKeyboardKey(self: State, key: input.KeyboardKey) input.ButtonAction {
    return self.buttons_keyboard.get(key);
}

pub fn getMouseButton(self: State, key: input.MouseButton) input.ButtonAction {
    return self.buttons_mouse.get(key);
}

///Returns the motion of the mouse device. Returns relative motion.
pub fn getMouseMotion(self: State) [2]i16 {
    //TODO: implement actual mouse motion
    return self.cursor_motion;
}

pub fn getMouseScroll(self: State) i32 {
    return self.mouse_scroll;
}

///Returns the motion of the mouse device. Returns relative motion.
pub fn getCursorPosition(self: State) [2]i16 {
    return self.cursor_position;
}

const input = @import("../input.zig");
const std = @import("std");
const State = @This();
