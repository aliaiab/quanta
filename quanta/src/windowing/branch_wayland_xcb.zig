//! The branch backend for wayland with xcb fallback

fn initSelect(
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
) !WindowSystemUnion {
    const xdg_session_type = try std.process.getEnvVarOwned(arena, "XDG_SESSION_TYPE");

    if (std.mem.eql(u8, xdg_session_type, "wayland")) {
        return .{ .wayland = try .init(arena, gpa) };
    } else if (std.mem.eql(u8, xdg_session_type, "x11")) {
        return .{ .xcb = try .init(arena, gpa) };
    }

    return error.XdgSessionTypeUnsupported;
}

const WindowSystemUnion = union(BackendTag) {
    xcb: @import("xcb/WindowSystem.zig"),
    wayland: @import("wayland/WindowSystem.zig"),
};

pub const WindowSystem = branch_backend.BranchWindowSystem(
    WindowSystemUnion,
    Window,
    initSelect,
);

pub const Window = branch_backend.BranchWindow(
    union(BackendTag) {
        xcb: @import("xcb/Window.zig"),
        wayland: @import("wayland/Window.zig"),
    },
);

const BackendTag = enum {
    xcb,
    wayland,
};

const branch_backend = @import("branch_backend.zig");
const std = @import("std");
