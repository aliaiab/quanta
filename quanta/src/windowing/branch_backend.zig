pub fn BranchWindowSystem(
    comptime Backend: type,
    comptime initFn: anytype,
) type {
    _ = initFn; // autofix
    _ = Backend; // autofix
    return union(enum) {};
}

pub fn BranchWindow(
    comptime Backend: type,
) type {
    return struct {
        impl: Backend,

        pub fn pollEvents(
            self: *Window,
            out_input: *input.State,
        ) !void {
            return switch (self.impl) {
                inline else => |impl| impl.pollEvents(out_input),
            };
        }

        pub fn shouldClose(self: *Window) bool {
            return switch (self.impl) {
                inline else => |impl| impl.shouldClose(),
            };
        }

        pub fn getWidth(self: Window) u16 {
            return switch (self.impl) {
                inline else => |impl| impl.getWidth(),
            };
        }

        pub fn getHeight(self: Window) u16 {
            return switch (self.impl) {
                inline else => |impl| impl.getHeight(),
            };
        }

        pub fn captureCursor(self: *Window) void {
            return switch (self.impl) {
                inline else => |impl| impl.captureCursor(),
            };
        }

        pub fn uncaptureCursor(self: *Window) void {
            return self.impl.uncaptureCursor();
        }

        pub fn isCursorCaptured(self: Window) bool {
            return switch (self.impl) {
                inline else => |impl| impl.isCursorCaptured(),
            };
        }

        pub fn hideCursor(self: *Window) void {
            return switch (self.impl) {
                inline else => |impl| impl.hideCursor(),
            };
        }

        pub fn unhideCursor(self: *Window) void {
            return switch (self.impl) {
                inline else => |impl| impl.unhideCursor(),
            };
        }

        pub fn isCursorHidden(self: Window) bool {
            return switch (self.impl) {
                inline else => |impl| impl.isCursorHidden(),
            };
        }

        pub fn isFocused(self: Window) bool {
            return switch (self.impl) {
                inline else => |impl| impl.isFocused(),
            };
        }

        pub fn getUtf8Input(self: Window) []const u8 {
            return switch (self.impl) {
                inline else => |impl| impl.getUtf8Input(),
            };
        }

        const Window = @This();
    };
}

const input = @import("../input.zig");
const windowing = @import("../windowing.zig");
