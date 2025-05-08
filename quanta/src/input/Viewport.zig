//! Describes an input viewport in which a cursor exists

///The width of the viewport in arbitrary units
width: u16 = 0,
///The height of the viewport in arbitrary units
height: u16 = 0,

cursor_position: [2]i16 = @splat(-1),
//TODO: handle HiDpi by scaling
cursor_motion: [2]i16 = @splat(0),

///A default input state will not result in any actions in well behaved code
pub const default_inert: Viewport = .{};

///Returns the aspect ratio of the viewport as a floating point type T
pub fn aspectRatio(self: @This(), comptime T: type) T {
    const width: T = @floatFromInt(self.width);
    const height: T = @floatFromInt(self.height);

    return width / height;
}

///Returns the cursor position normalized with respect to the viewport width and height
///T must be a floating point type
pub fn normalizedCursorPosition(self: @This(), comptime T: type) [2]T {
    var x: T = @floatFromInt(self.cursor_position[0]);
    var y: T = @floatFromInt(self.cursor_position[1]);

    x /= @floatFromInt(self.width);
    y /= @floatFromInt(self.height);

    return .{ x, y };
}

///Returns the cursor motion normalized with respect to the viewport width and height
///T must be a floating point type
pub fn normalizedCursorMotion(self: @This(), comptime T: type) [2]T {
    var x: T = @floatFromInt(self.cursor_motion[0]);
    var y: T = @floatFromInt(self.cursor_motion[1]);

    x /= @floatFromInt(self.width);
    y /= @floatFromInt(self.height);

    return .{ x, y };
}

const Viewport = @import("Viewport.zig");
