//! Represents a graphical window
//! Has no observable notion of positioning and most state is left to the underlying window system to control (the operating system/window manager)

impl: Impl,

///Polls window events and reads inputs relevent to that window into out_input
pub fn pollEvents(
    self: *Window,
    ///Inputs from the window are written into here
    out_input: *input.State,
    ///The viewport inputs are written to here
    out_viewport: *input.Viewport,
) !void {
    return self.impl.pollEvents(
        out_input,
        out_viewport,
    );
}

///Returns true if the user requested to close the window
pub fn shouldClose(self: *Window) bool {
    return self.impl.shouldClose();
}

///Confines the cursor to the bounds of the window and hides it
pub fn captureCursor(self: *Window) void {
    return self.impl.captureCursor();
}

///Releases the cursor from window confinement and unhides it
pub fn uncaptureCursor(self: *Window) void {
    return self.impl.uncaptureCursor();
}

pub fn isCursorCaptured(self: Window) bool {
    return self.impl.isCursorCaptured();
}

pub fn hideCursor(self: *Window) void {
    return self.impl.hideCursor();
}

pub fn unhideCursor(self: *Window) void {
    return self.impl.unhideCursor();
}

pub fn isCursorHidden(self: Window) bool {
    return self.impl.isCursorHidden();
}

pub fn isFocused(self: Window) bool {
    return self.impl.isFocused();
}

///Returns a buffer of the text input pressed in this polling window
///Returns a zero length slice when there is no text input
pub fn getUtf8Input(self: Window) []const u8 {
    return self.impl.getUtf8Input();
}

///Implementation structure
const Impl = switch (quanta_options.windowing.preferred_backend) {
    .wayland => @compileError("Wayland not supported"),
    .xcb => @import("xcb/Window.zig"),
    .win32 => @import("win32/Window.zig"),
};

test {
    std.testing.refAllDecls(@This());
}

const Window = @This();
const windowing = @import("../windowing.zig");
const input = @import("../input.zig");
const std = @import("std");
const quanta_options = @import("../root.zig").quanta_options;
