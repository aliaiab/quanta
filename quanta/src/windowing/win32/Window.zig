hwnd: win32.foundation.HWND,
window_system: *WindowSystem,

pub fn init(
    self: *Window,
    window_system: *WindowSystem,
    allocator: std.mem.Allocator,
    options: windowing.WindowSystem.CreateWindowOptions,
) !void {
    const title_z = try allocator.dupeZ(u8, options.title);
    //Are we allowed to free this?
    defer allocator.free(title_z);

    const window_class_name = "Test";

    const window_class = win32.ui.windows_and_messaging.WNDCLASSA{
        .style = .{
            .HREDRAW = 1,
            .VREDRAW = 1,
        },
        .lpfnWndProc = &wndProc,
        .hInstance = window_system.instance,
        .hIcon = win32.ui.windows_and_messaging.LoadIconW(
            null,
            win32.ui.windows_and_messaging.IDI_APPLICATION,
        ),
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hCursor = win32.ui.windows_and_messaging.LoadCursorW(
            null,
            win32.ui.windows_and_messaging.IDC_ARROW,
        ),
        .hbrBackground = @ptrFromInt(@intFromEnum(win32.ui.windows_and_messaging.COLOR_WINDOW)),
        .lpszMenuName = "Test",
        .lpszClassName = window_class_name,
    };

    const class_result = win32.ui.windows_and_messaging.RegisterClassA(&window_class);

    if (class_result == 0) {
        return error.Win32WindowClassRegisterFailed;
    }

    const maybe_window_handle = win32.ui.windows_and_messaging.CreateWindowExA(
        win32.ui.windows_and_messaging.WS_EX_COMPOSITED,
        window_class_name,
        //TODO: does this require UTF-16? I'm assuming Ex'A' refers to ANSI
        title_z.ptr,
        win32.ui.windows_and_messaging.WS_OVERLAPPEDWINDOW,
        win32.ui.windows_and_messaging.CW_USEDEFAULT,
        win32.ui.windows_and_messaging.CW_USEDEFAULT,
        @intCast(options.preferred_width orelse win32.ui.windows_and_messaging.CW_USEDEFAULT),
        @intCast(options.preferred_height orelse win32.ui.windows_and_messaging.CW_USEDEFAULT),
        null,
        null,
        window_system.instance,
        null,
    );

    if (maybe_window_handle == null) {
        return error.Win32WindowCreateFailed;
    }

    self.hwnd = maybe_window_handle.?;
    self.window_system = window_system;

    try window_system.window_states.put(allocator, self.hwnd, .{});

    _ = win32.windowlongptr.SetWindowLongPtrA(maybe_window_handle.?, .P_USERDATA, @intCast(@intFromPtr(window_system)));

    //TODO: we need to pass in the show cmd from win main, or some other way of getting it
    //This ensures that the user can control whether a window starts off 'shown' or not
    _ = win32.ui.windows_and_messaging.ShowWindow(maybe_window_handle.?, win32.ui.windows_and_messaging.SW_SHOWNORMAL);
}

pub fn deinit(
    self: *Window,
    allocator: std.mem.Allocator,
) void {
    _ = allocator; // autofix
    _ = self.window_system.window_states.swapRemove(self.hwnd);

    self.* = undefined;
}

pub fn pollEvents(self: *Window) !void {
    var message: win32.ui.windows_and_messaging.MSG = undefined;

    //Get message is a blocking, use peek message for polling
    while (win32.ui.windows_and_messaging.PeekMessageA(
        &message,
        self.hwnd,
        0,
        0,
        .{ .REMOVE = 1 },
    ) > 0) {
        _ = win32.ui.windows_and_messaging.TranslateMessage(&message);
        _ = win32.ui.windows_and_messaging.DispatchMessageA(&message);
    }
}

pub fn shouldClose(self: *Window) bool {
    //TODO: application currently depends on shouldClose implicitly polling events, it shouldn't work like this in future
    self.pollEvents() catch @panic("Polly events failed");

    return self.window_system.window_states.get(self.hwnd).?.should_close;
}

pub fn getWidth(self: Window) u16 {
    _ = self; // autofix
    return 1600;
}

pub fn getHeight(self: Window) u16 {
    _ = self; // autofix
    return 900;
}

pub fn getKey(self: Window, key: windowing.Key) windowing.Action {
    _ = self; // autofix
    _ = key; // autofix
    return .release;
}

pub fn getMouseButton(self: Window, key: windowing.MouseButton) windowing.Action {
    _ = self; // autofix
    _ = key; // autofix
    return .release;
}

pub fn getMouseMotion(self: Window) @Vector(2, i16) {
    _ = self; // autofix
    return .release;
}

pub fn getCursorPosition(self: Window) @Vector(2, i16) {
    _ = self; // autofix
    return .{ 0, 0 };
}

pub fn getCursorMotion(self: Window) @Vector(2, i16) {
    _ = self; // autofix
    return .{ 0, 0 };
}

pub fn captureCursor(self: *Window) void {
    _ = self; // autofix
}

pub fn uncaptureCursor(self: *Window) void {
    _ = self; // autofix
}

pub fn isCursorCaptured(self: Window) bool {
    _ = self; // autofix
    return false;
}

pub fn hideCursor(self: *Window) void {
    _ = self; // autofix
}

pub fn unhideCursor(self: *Window) void {
    _ = self; // autofix
}

pub fn isCursorHidden(self: Window) bool {
    _ = self; // autofix
    return false;
}

pub fn isFocused(self: Window) bool {
    _ = self; // autofix
    return false;
}

pub fn getMouseScroll(self: Window) i32 {
    _ = self; // autofix
    return 0;
}

pub fn getUtf8Input(self: Window) []const u8 {
    _ = self; // autofix
    return &.{};
}

///The window processing function that handles window messages
fn wndProc(
    wnd: win32.foundation.HWND,
    msg: u32,
    param2: win32.foundation.WPARAM,
    param3: win32.foundation.LPARAM,
) callconv(@import("std").os.windows.WINAPI) win32.foundation.LRESULT {
    const user_data = win32.windowlongptr.GetWindowLongPtrA(wnd, .P_USERDATA);

    const user_data_ptr: ?*anyopaque = @ptrFromInt(@as(usize, @intCast(user_data)));

    if (user_data_ptr == null) {
        return win32.ui.windows_and_messaging.DefWindowProcA(
            wnd,
            msg,
            param2,
            param3,
        );
    }

    const window_system: *WindowSystem = @alignCast(@ptrCast(user_data_ptr.?));
    const window_state: *State = window_system.window_states.getPtr(wnd).?;

    log.info("wndProc = {}, {}, {}, {}", .{ wnd, msg, param2, param3 });
    log.info("user_data_ptr = {?*}", .{user_data_ptr});

    switch (msg) {
        win32.ui.windows_and_messaging.WM_CLOSE => {
            window_state.should_close = true;
        },
        win32.ui.windows_and_messaging.WM_DESTROY => {
            window_state.should_close = true;
        },
        else => {},
    }

    return win32.ui.windows_and_messaging.DefWindowProcA(
        wnd,
        msg,
        param2,
        param3,
    );
}

///Stored by the window system
pub const State = struct {
    should_close: bool = false,
};

const win32 = @import("win32");
const std = @import("std");
const Window = @This();
const WindowSystem = @import("WindowSystem.zig");
const windowing = @import("../../windowing.zig");
const log = @import("../../log.zig").log;
