///The backend used to implement windowing, known at compile time
pub const Backend = enum {
    wayland,
    win32,
    xcb,
};

pub const Window = @import("windowing/Window.zig");
pub const WindowSystem = @import("windowing/WindowSystem.zig");

///Module level options
pub const Options = struct {
    ///The window system backend to be used
    preferred_backend: Backend = switch (@import("builtin").os.tag) {
        .linux,
        .freebsd,
        .openbsd,
        => .xcb,
        .windows => .win32,
        else => @compileError("quanta.windowing not supported on this target"),
    },
};

test {
    @import("std").testing.refAllDecls(@This());
}
