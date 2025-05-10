///The backend used to implement windowing, known at compile time
pub const Backend = enum {
    ///An implementation which contains both wayland and xcb support
    ///Wayland will be used if wayland is found on the system, otherwise xcb is a fallback
    branch_wayland_xcb,
    wayland,
    win32,
    xcb,
};

pub const Window = @import("windowing/Window.zig");
pub const WindowSystem = @import("windowing/WindowSystem.zig");

///Represents the pixel surface of a window
pub const SurfaceRegion = struct {
    ///Width in pixels
    width: u32,
    ///Height in pixels
    height: u32,
};

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
