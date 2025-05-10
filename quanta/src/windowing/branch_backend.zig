pub fn BranchWindowSystem(
    comptime Backend: type,
    comptime Window: type,
    ///Selects the backend to use, also inits the window system
    comptime initSelectFn: anytype,
) type {
    return struct {
        impl: Backend,

        pub fn init(
            arena: std.mem.Allocator,
            gpa: std.mem.Allocator,
        ) !WindowSystem {
            return .{ .impl = try initSelectFn(arena, gpa) };
        }

        pub fn deinit(self: *WindowSystem, gpa: std.mem.Allocator) void {
            return switch (self.impl) {
                inline else => |*impl| impl.deinit(gpa),
            };
        }

        pub fn createWindow(
            self: *WindowSystem,
            arena: std.mem.Allocator,
            gpa: std.mem.Allocator,
            options: windowing.WindowSystem.CreateWindowOptions,
        ) !struct { Window, windowing.SurfaceRegion } {
            switch (self.impl) {
                inline else => |*impl| {
                    const Type = @TypeOf(impl.*);

                    const window_union_fields = std.meta.fields(Backend);

                    const BackendUnion = @FieldType(Window, "impl");

                    const field_name: []const u8 = blk: inline for (window_union_fields) |window_field| {
                        if (window_field.type == Type) {
                            break :blk window_field.name;
                        }
                    } else @compileError("Window system and window unions have a field mismatch");

                    const backend_window, const surface_region = try impl.createWindow(arena, gpa, options);

                    return .{
                        .{
                            .impl = @unionInit(BackendUnion, field_name, backend_window),
                        },
                        surface_region,
                    };
                },
            }
        }

        pub fn destroyWindow(
            self: *WindowSystem,
            window: *Window,
            gpa: std.mem.Allocator,
        ) void {
            switch (self.impl) {
                inline else => |*impl| {
                    const Type = @TypeOf(impl.*);

                    const window_union_fields = std.meta.fields(Backend);

                    const field_name: []const u8 = blk: inline for (window_union_fields) |window_field| {
                        if (window_field.type == Type) {
                            break :blk window_field.name;
                        }
                    } else @compileError("Window system and window unions have a field mismatch");

                    return impl.destroyWindow(&@field(window.impl, field_name), gpa);
                },
            }
        }

        const WindowSystem = @This();
    };
}

pub fn BranchWindow(
    comptime Backend: type,
) type {
    return struct {
        impl: Backend,

        pub fn pollEvents(
            self: *Window,
            out_input: *input.State,
            out_viewport: *input.Viewport,
            out_surface_region: *windowing.SurfaceRegion,
        ) !void {
            return switch (self.impl) {
                inline else => |*impl| impl.pollEvents(out_input, out_viewport, out_surface_region),
            };
        }

        pub fn shouldClose(self: *Window) bool {
            return switch (self.impl) {
                inline else => |*impl| impl.shouldClose(),
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
                inline else => |*impl| impl.captureCursor(),
            };
        }

        pub fn uncaptureCursor(self: *Window) void {
            return switch (self.impl) {
                inline else => |*impl| impl.uncaptureCursor(),
            };
        }

        pub fn isCursorCaptured(self: Window) bool {
            return switch (self.impl) {
                inline else => |impl| impl.isCursorCaptured(),
            };
        }

        pub fn hideCursor(self: *Window) void {
            return switch (self.impl) {
                inline else => |*impl| impl.hideCursor(),
            };
        }

        pub fn unhideCursor(self: *Window) void {
            return switch (self.impl) {
                inline else => |*impl| impl.unhideCursor(),
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

const std = @import("std");
const input = @import("../input.zig");
const windowing = @import("../windowing.zig");
