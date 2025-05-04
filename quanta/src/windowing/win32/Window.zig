hwnd: win32.foundation.HWND,
window_system: *WindowSystem,

pub fn init(
    self: *Window,
    window_system: *WindowSystem,
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
    options: windowing.WindowSystem.CreateWindowOptions,
) !void {
    var title_alloc = std.heap.stackFallback(16, arena);

    const title_z = try title_alloc.get().dupeZ(u8, options.title);

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
        .lpszMenuName = null,
        .lpszClassName = window_class_name,
    };

    const class_result = win32.ui.windows_and_messaging.RegisterClassA(&window_class);

    if (class_result == 0) {
        return error.Win32WindowClassRegisterFailed;
    }

    const maybe_window_handle = win32.ui.windows_and_messaging.CreateWindowExA(
        win32.ui.windows_and_messaging.WS_EX_COMPOSITED,
        window_class_name,
        title_z.ptr,
        win32.ui.windows_and_messaging.WS_OVERLAPPEDWINDOW,
        win32.ui.windows_and_messaging.CW_USEDEFAULT,
        win32.ui.windows_and_messaging.CW_USEDEFAULT,
        options.preferred_width orelse win32.ui.windows_and_messaging.CW_USEDEFAULT,
        options.preferred_height orelse win32.ui.windows_and_messaging.CW_USEDEFAULT,
        null,
        null,
        window_system.instance,
        window_system,
    );

    if (maybe_window_handle == null) {
        return error.Win32WindowCreateFailed;
    }

    self.hwnd = maybe_window_handle.?;
    self.window_system = window_system;

    var window_rect: win32.foundation.RECT = undefined;

    _ = win32.ui.windows_and_messaging.GetWindowRect(self.hwnd, &window_rect);

    try window_system.window_states.put(gpa, self.hwnd, .{
        .width = @truncate(@abs(window_rect.right - window_rect.left)),
        .height = @truncate(@abs(window_rect.top - window_rect.bottom)),
    });

    //TODO: we need to pass in the show cmd from win main, or some other way of getting it
    //This ensures that the user can control whether a window starts off 'shown' or not
    _ = win32.ui.windows_and_messaging.ShowWindow(maybe_window_handle.?, win32.ui.windows_and_messaging.SW_SHOWNORMAL);
    _ = win32.graphics.gdi.UpdateWindow(self.hwnd);
}

pub fn deinit(
    self: *Window,
    gpa: std.mem.Allocator,
) void {
    _ = gpa; // autofix
    _ = self.window_system.window_states.swapRemove(self.hwnd);

    self.* = undefined;
}

pub fn pollEvents(self: *Window, out_input: *input.State) !void {
    var message: win32.ui.windows_and_messaging.MSG = undefined;
    @memset(std.mem.asBytes(&message), 0);

    const window_state: *State = self.window_system.window_states.getPtr(self.hwnd).?;

    window_state.previous_mouse_button_state = window_state.mouse_button_state;

    window_state.mouse_button_state = .initFill(false);

    //Get message is a blocking, use peek message for polling
    while (win32.ui.windows_and_messaging.PeekMessageA(
        &message,
        self.hwnd,
        0,
        0,
        .{
            .REMOVE = 1,
            .NOYIELD = 1,
        },
    ) > 0) {
        _ = win32.ui.windows_and_messaging.TranslateMessage(&message);
        _ = win32.ui.windows_and_messaging.DispatchMessageA(&message);

        if (message.message == win32.ui.windows_and_messaging.WM_PAINT) {
            break;
        }

        if (message.message == win32.ui.windows_and_messaging.WM_QUIT) {
            window_state.should_close = true;
            break;
        }
    }

    var window_rect: win32.foundation.RECT = undefined;

    _ = win32.ui.windows_and_messaging.GetWindowRect(self.hwnd, &window_rect);

    window_state.width = @truncate(@abs(window_rect.right - window_rect.left));
    window_state.height = @truncate(@abs(window_rect.top - window_rect.bottom));

    var cursor_pos: win32.foundation.POINT = undefined;

    _ = win32.ui.windows_and_messaging.GetCursorPos(&cursor_pos);

    window_state.cursor_pos_x = @truncate(cursor_pos.x - window_rect.left);
    window_state.cursor_pos_y = @truncate(cursor_pos.y - window_rect.top);

    out_input.cursor_position = .{ window_state.cursor_pos_x, window_state.cursor_pos_y };

    for (std.enums.values(input.MouseButton)) |button| {
        out_input.buttons_mouse.set(button, self.getMouseButton(button));
    }

    for (std.enums.values(input.KeyboardKey)) |button| {
        _ = button; // autofix
        // out_input.buttons_keyboard.set(button, self.getKey(button));
    }
}

pub fn shouldClose(self: *Window) bool {
    return self.window_system.window_states.get(self.hwnd).?.should_close;
}

pub fn getWidth(self: Window) u16 {
    return self.window_system.window_states.getPtr(self.hwnd).?.width;
}

pub fn getHeight(self: Window) u16 {
    return self.window_system.window_states.getPtr(self.hwnd).?.height;
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

pub fn getUtf8Input(self: Window) []const u8 {
    _ = self; // autofix
    return &.{};
}

fn getMouseButton(self: Window, key: input.MouseButton) input.ButtonAction {
    const state = self.window_system.window_states.getPtr(self.hwnd).?;

    if (!state.mouse_button_state.get(key) and state.previous_mouse_button_state.get(key)) {
        return .press;
    }

    if (state.mouse_button_state.get(key)) {
        return .down;
    }

    return .release;
}

fn getCursorPosition(self: Window) @Vector(2, i16) {
    const window_state = self.window_system.window_states.getPtr(self.hwnd).?;

    return .{ window_state.cursor_pos_x, window_state.cursor_pos_y };
}

///The window processing function that handles window messages
fn wndProc(
    wnd: win32.foundation.HWND,
    msg: u32,
    wparam: win32.foundation.WPARAM,
    lparam: win32.foundation.LPARAM,
) callconv(@import("std").os.windows.WINAPI) win32.foundation.LRESULT {
    std.debug.print("wndproc msg = {}\n", .{msg});

    switch (msg) {
        win32.ui.windows_and_messaging.WM_GETMINMAXINFO => {
            return 1;
        },
        win32.ui.windows_and_messaging.WM_NCCREATE => {
            return 1;
        },
        win32.ui.windows_and_messaging.WM_NCCALCSIZE => {
            return 1;
        },
        win32.ui.windows_and_messaging.WM_CREATE => {
            const CreateStruct = win32.ui.windows_and_messaging.CREATESTRUCTA;

            const create_struct: *CreateStruct = @ptrFromInt(@as(usize, @bitCast(lparam)));

            const window_system: *WindowSystem = @ptrCast(@alignCast(create_struct.lpCreateParams));

            _ = win32.windowlongptr.SetWindowLongPtrA(wnd, .P_USERDATA, @bitCast(@intFromPtr(window_system)));

            return 1;
        },
        else => {},
    }

    const user_data = win32.windowlongptr.GetWindowLongPtrA(wnd, .P_USERDATA);

    const user_data_ptr: ?*anyopaque = @ptrFromInt(@as(usize, @bitCast(user_data)));

    if (user_data_ptr == null) {
        @panic("GetWindowLongPtrA returned null");
    }

    const window_system: *WindowSystem = @alignCast(@ptrCast(user_data_ptr.?));

    if (window_system.window_states.getPtr(wnd) == null) {
        std.debug.print("window state is null\n", .{});
        return win32.ui.windows_and_messaging.DefWindowProcA(
            wnd,
            msg,
            wparam,
            lparam,
        );
    }

    const window_state: *State = window_system.window_states.getPtr(wnd).?;

    switch (msg) {
        win32.ui.windows_and_messaging.WM_CLOSE => {
            window_state.should_close = true;
        },
        win32.ui.windows_and_messaging.WM_DESTROY => {
            window_state.should_close = true;
            win32.ui.windows_and_messaging.PostQuitMessage(0);
        },
        win32.ui.windows_and_messaging.WM_SIZE => {
            const resize_size: packed struct(u64) {
                width: u32,
                height: u32,
            } = @bitCast(lparam);

            window_state.width = @truncate(resize_size.width);
            window_state.height = @truncate(resize_size.height);
        },
        win32.ui.windows_and_messaging.WM_SIZING => {
            const rect: *win32.devices.display.RECTFX = @ptrFromInt(@as(usize, @bitCast(lparam)));

            window_state.width = @truncate(@abs(rect.xRight - rect.xLeft));
            window_state.height = @truncate(@abs(rect.yTop - rect.yBottom));
        },
        win32.ui.windows_and_messaging.WM_LBUTTONDOWN => {
            window_state.mouse_button_state.set(.left, true);
        },
        win32.ui.windows_and_messaging.WM_RBUTTONDOWN => {
            window_state.mouse_button_state.set(.right, true);
        },
        win32.ui.windows_and_messaging.WM_MBUTTONDOWN => {
            window_state.mouse_button_state.set(.middle, true);
        },
        else => {
            return win32.ui.windows_and_messaging.DefWindowProcA(
                wnd,
                msg,
                wparam,
                lparam,
            );
        },
    }

    return 0;
}

///Stored by the window system
pub const State = struct {
    should_close: bool = false,
    width: u16 = 0,
    height: u16 = 0,
    cursor_pos_x: i16 = 0,
    cursor_pos_y: i16 = 0,
    mouse_button_state: std.EnumArray(input.MouseButton, bool) = .initFill(false),
    previous_mouse_button_state: std.EnumArray(input.MouseButton, bool) = .initFill(false),
};

const win32 = @import("win32");
const std = @import("std");
const Window = @This();
const WindowSystem = @import("WindowSystem.zig");
const windowing = @import("../../windowing.zig");
const input = @import("../../input.zig");
const log = @import("../../log.zig").log;
