//! Hand maintained imgui bindings

pub fn createContext(
    options: struct {},
) *Context {
    _ = options; // autofix
    return @ptrCast(cimgui.igCreateContext(null));
}

pub fn getIO() *IO {
    return @ptrCast(cimgui.igGetIO());
}

pub fn showDemoWindow(options: struct {}) void {
    _ = options; // autofix
    cimgui.igShowDemoWindow(null);
}

pub fn dockSpace(
    id: Id,
    options: struct {},
) void {
    _ = options; // autofix
    _ = cimgui.igDockSpace(@bitCast(id.value), .{ .x = 0, .y = 0 }, 0, null);
}

pub fn separator(
    options: struct {},
) void {
    _ = options; // autofix
    cimgui.igSeparator();
}

pub fn newLine() void {
    cimgui.igNewLine();
}

pub fn beginMenuBar() bool {
    return cimgui.igBeginMenuBar();
}

pub fn endMenuBar() void {
    cimgui.igEndMenuBar();
}

pub fn beginMenu(
    label: [:0]const u8,
    options: struct {
        enabled: bool = true,
    },
) bool {
    return cimgui.igBeginMenu(label.ptr, options.enabled);
}

pub fn endMenu() void {
    return cimgui.igEndMenu();
}

pub fn menuItem(
    label: [:0]const u8,
    options: struct {
        shortcut: ?[:0]const u8 = null,
        selected: bool = false,
        enabled: bool = true,
    },
) bool {
    return cimgui.igMenuItem_Bool(
        label.ptr,
        if (options.shortcut != null) options.shortcut.?.ptr else null,
        options.selected,
        options.enabled,
    );
}

///Push and id value, can be an integer, pointer or a string
pub fn pushId(value: anytype) void {
    const T = @TypeOf(value);

    switch (@typeInfo(T)) {
        .int => |int_info| {
            const cint: c_int = switch (int_info.signedness) {
                .signed => @intCast(value),
                //TODO: handle unsigned ints differently
                .unsigned => @intCast(value),
            };

            cimgui.igPushID_Int(cint);
        },
        else => @compileError("type of value not supported for id creation!"),
    }
}

pub fn popId() void {
    cimgui.igPopID();
}

pub fn begin(
    name: [:0]const u8,
    options: struct {
        open: ?*bool = null,
        flags: WindowFlags = .{},
    },
) bool {
    return cimgui.igBegin(name.ptr, options.open, @bitCast(options.flags));
}

pub fn end() void {
    return cimgui.igEnd();
}

pub fn setNextWindowBgAlpha(alpha: f32) void {
    return cimgui.igSetNextWindowBgAlpha(alpha);
}

pub fn sameLine(
    options: struct {
        offset_from_start_x: f32 = 0,
        spacing: f32 = -1,
    },
) void {
    return cimgui.igSameLine(options.offset_from_start_x, options.spacing);
}

pub fn text(
    comptime fmt: []const u8,
    args: anytype,
    options: struct {},
) void {
    _ = options; // autofix
    var fmt_buffer: [1024]u8 = undefined;

    const formatted = std.fmt.bufPrint(&fmt_buffer, fmt, args) catch @panic("Format allocation failed!");

    cimgui.igTextEx(formatted.ptr, formatted.ptr + formatted.len, 0);
}

pub fn textUnformatted(string: []const u8) void {
    cimgui.igTextUnformatted(string.ptr, string.ptr + string.len);
}

pub fn checkbox(
    label: [:0]const u8,
    value: *bool,
) bool {
    return cimgui.igCheckbox(label, value);
}

pub fn button(
    label: [:0]const u8,
    options: struct {
        size: [2]f32 = .{ 0, 0 },
        button_flags: ButtonFlags = .{},
    },
) bool {
    return cimgui.igButtonEx(
        label.ptr,
        .{ .x = options.size[0], .y = options.size[1] },
        @bitCast(options.button_flags),
    );
}

pub fn image(
    ///Must be a pointer sized value
    user_texture_id: anytype,
    image_size: [2]f32,
    options: struct {
        uv0: [2]f32 = .{ 0, 0 },
        uv1: [2]f32 = .{ 1, 1 },
        tint_col: [4]f32 = .{ 1, 1, 1, 1 },
        border_col: [4]f32 = .{ 0, 0, 0, 0 },
    },
) void {
    const imgui_texture_id = userImageToImTextureID(user_texture_id);

    return cimgui.igImage(
        imgui_texture_id,
        .{ .x = image_size[0], .y = image_size[1] },
        .{ .x = options.uv0[0], .y = options.uv0[1] },
        .{ .x = options.uv1[0], .y = options.uv1[1] },
        .{ .x = options.tint_col[0], .y = options.tint_col[1], .z = options.tint_col[2], .w = options.tint_col[3] },
        .{ .x = options.border_col[0], .y = options.border_col[1], .z = options.border_col[2], .w = options.border_col[3] },
    );
}

pub fn imageButton(
    id: Id,
    ///Must be a pointer sized value
    user_texture_id: anytype,
    image_size: [2]f32,
    options: struct {
        uv0: [2]f32 = .{ 0, 0 },
        uv1: [2]f32 = .{ 1, 1 },
        tint_col: [4]f32 = .{ 1, 1, 1, 1 },
        border_col: [4]f32 = .{ 0, 0, 0, 0 },
        flags: ButtonFlags = .{},
    },
) bool {
    const imgui_texture_id = userImageToImTextureID(user_texture_id);

    return cimgui.igImageButtonEx(
        @bitCast(id),
        imgui_texture_id,
        .{ .x = image_size[0], .y = image_size[1] },
        .{ .x = options.uv0[0], .y = options.uv0[1] },
        .{ .x = options.uv1[0], .y = options.uv1[1] },
        .{ .x = options.border_col[0], .y = options.border_col[1], .z = options.border_col[2], .w = options.border_col[3] },
        .{ .x = options.tint_col[0], .y = options.tint_col[1], .z = options.tint_col[2], .w = options.tint_col[3] },
        @bitCast(options.flags),
    );
}

pub fn dragFloat(
    label: []const u8,
    comptime fmt: []const u8,
    value: *f32,
    options: struct {
        speed: f32 = 0.1,
        value_min: f32 = 0,
        value_max: f32 = 0,
        flags: SliderFlags = .{},
    },
) bool {
    return reimpls.dragScalar(
        f32,
        label,
        fmt,
        value,
        options.speed,
        options.value_min,
        options.value_max,
        @bitCast(options.flags),
    );
}

pub fn newFrame() void {
    cimgui.igNewFrame();
}

pub fn endFrame() void {
    cimgui.igEndFrame();
}

pub fn render() void {
    cimgui.igRender();
}

pub fn getDrawData() *DrawData {
    return @ptrCast(cimgui.igGetDrawData());
}

pub const Id = packed struct(u32) {
    value: u32,

    pub fn fromStr(string: []const u8) Id {
        const value = cimgui.igGetID_StrStr(string.ptr, string.ptr + string.len);

        return .{ .value = value };
    }

    pub fn fromFmt(comptime fmt: []const u8, args: anytype) Id {
        var fmt_buffer: [256]u8 = undefined;

        const str_id = std.fmt.bufPrint(&fmt_buffer, fmt, args) catch @panic("Fmt allocation failed");

        return .fromStr(str_id);
    }
};

pub const WindowFlags = packed struct(u32) {
    no_title_bar: bool = false,
    no_resize: bool = false,
    no_move: bool = false,
    no_scroll_bar: bool = false,
    no_scroll_with_mouse: bool = false,
    no_collapse: bool = false,
    always_auto_resize: bool = false,
    no_background: bool = false,
    no_saved_settings: bool = false,
    no_mouse_inputs: bool = false,
    menu_bar: bool = false,
    horizontal_scroll_bar: bool = false,
    no_focus_on_appearing: bool = false,
    no_bring_to_front_on_focus: bool = false,
    always_vertical_scroll_bar: bool = false,
    always_horizontal_scroll_bar: bool = false,
    no_nav_inputs: bool = false,
    no_nav_focus: bool = false,
    unsaved_document: bool = false,
    no_docking: bool = false,
    nav_flattened: bool = false,
    child_window: bool = false,
    tooltip: bool = false,
    popup: bool = false,
    modal: bool = false,
    child_menu: bool = false,
    dock_node_host: bool = false,

    _: u5 = 0,

    pub const no_nav: WindowFlags = .{
        .no_nav_focus = true,
        .no_nav_inputs = true,
    };

    pub const no_decoration: WindowFlags = .{
        .no_resize = true,
        .no_title_bar = true,
        .no_scroll_bar = true,
        .no_collapse = true,
    };

    pub const no_inputs: WindowFlags = .{
        .no_nav_inputs = true,
        .no_nav_focus = true,
    };

    comptime {
        std.debug.assert(@as(u32, @bitCast(no_decoration)) == 43);
    }

    pub fn combine(flags: []const WindowFlags) WindowFlags {
        var result: u32 = 0;

        for (flags) |flag| {
            result |= @bitCast(flag);
        }

        return @bitCast(result);
    }
};

pub const ButtonFlags = packed struct(u32) {
    mouse_button_left: bool = true,
    mouse_button_right: bool = false,
    mouse_button_middle: bool = false,

    _: u29 = 0,
};

pub const SliderFlags = packed struct(u32) {
    always_clamp: bool = true,
    logarithmic: bool = false,
    no_round_to_format: bool = false,
    no_input: bool = false,

    _: u28 = 0,
};

pub const Context = cimgui.ImGuiContext;
pub const DrawData = cimgui.ImDrawData;
pub const IO = cimgui.ImGuiIO;

fn userImageToImTextureID(
    user_image: anytype,
) cimgui.ImTextureID {
    const UserImage = @TypeOf(user_image);

    const user_texture_integer: usize = blk: switch (@typeInfo(UserImage)) {
        .@"enum" => {
            break :blk @intFromEnum(user_image);
        },
        .@"struct" => |struct_info| {
            if (struct_info.layout != .@"packed") {
                @compileError("User image type must be a packed struct!");
            }

            break :blk @bitCast(user_image);
        },
        else => @compileError("User image type not allowed! Must be a packed struct or enum"),
    };

    const imgui_tex_id: cimgui.ImTextureID = @ptrFromInt(user_texture_integer);

    return imgui_tex_id;
}

///Reimplementations in zig of some dear imgui functions
const reimpls = struct {
    pub fn dragScalar(
        comptime T: type,
        label: []const u8,
        comptime fmt: []const u8,
        p_data: *T,
        v_speed: f32,
        p_min: T,
        p_max: T,
        flags: u32,
    ) bool {
        _ = v_speed; // autofix
        const DRAG_MOUSE_THRESHOLD_FACTOR = 0.50;

        const window: *cimgui_extras.ImGuiWindow = @ptrCast(@alignCast(cimgui.igGetCurrentWindow().?));
        if (window.SkipItems)
            return false;

        const g: *cimgui.ImGuiContext = @ptrCast(cimgui.igGetCurrentContext().?);
        const style: *cimgui.ImGuiStyle = @ptrCast(cimgui.igGetStyle());
        const id = cimgui.ImGuiWindow_GetID_Str(@ptrCast(window), label.ptr, label.ptr + label.len);

        const w = cimgui.igCalcItemWidth();

        var label_size: cimgui.ImVec2 = undefined;

        cimgui.igCalcTextSize(&label_size, label.ptr, label.ptr + label.len, true, 0);
        const frame_bb: cimgui.ImRect = .{
            .Min = window.DC.CursorPos,
            .Max = cimgui.ImVec2{ .x = w + window.DC.CursorPos.x, .y = window.DC.CursorPos.y + label_size.y + style.FramePadding.y * 2.0 },
        };
        const total_bb: cimgui.ImRect = .{
            .Min = frame_bb.Min,
            .Max = cimgui.ImVec2{ .x = frame_bb.Max.x + if (label_size.x > 0.0) style.ItemInnerSpacing.x + label_size.x else 0.0, .y = frame_bb.Max.y },
        };

        const temp_input_allowed = (flags & cimgui.ImGuiSliderFlags_NoInput) == 0;

        cimgui.igItemSize_Rect(total_bb, style.FramePadding.y);

        if (!cimgui.igItemAdd(total_bb, id, &frame_bb, if (temp_input_allowed) cimgui.ImGuiItemFlags_Inputable else 0))
            return false;

        // Default format string when passing null
        // if (format == null)
        // format = DataTypeGetInfo(data_type)->PrintFmt;

        const hovered = cimgui.igItemHoverable(frame_bb, id, g.LastItemData.InFlags);
        var temp_input_is_active = temp_input_allowed and cimgui.igTempInputIsActive(id);

        if (!temp_input_is_active) {
            // Tabbing or CTRL-clicking on Drag turns it into an InputText
            const clicked = hovered and cimgui.igIsMouseClicked_ID(0, id, 0);
            const double_clicked = (hovered and g.IO.MouseClickedCount[0] == 2 and cimgui.igTestKeyOwner(cimgui.ImGuiKey_MouseLeft, id));
            const make_active = (clicked or double_clicked or g.NavActivateId == id);
            if (make_active and (clicked or double_clicked))
                cimgui.igSetKeyOwner(cimgui.ImGuiKey_MouseLeft, id, 0);
            if (make_active and temp_input_allowed) {
                if ((clicked and g.IO.KeyCtrl) or double_clicked or (g.NavActivateId == id and (g.NavActivateFlags & cimgui.ImGuiActivateFlags_PreferInput != 0))) {
                    temp_input_is_active = true;
                }
            }

            // (Optional) simple click (without moving) turns Drag into an InputText
            if (g.IO.ConfigDragClickToInputText and temp_input_allowed and !temp_input_is_active) {
                if (g.ActiveId == id and hovered and g.IO.MouseReleased[0] and !cimgui.igIsMouseDragPastThreshold(0, g.IO.MouseDragThreshold * DRAG_MOUSE_THRESHOLD_FACTOR)) {
                    g.NavActivateId = id;
                    g.NavActivateFlags = cimgui.ImGuiActivateFlags_PreferInput;
                    temp_input_is_active = true;
                }
            }

            if (make_active and !temp_input_is_active) {
                cimgui.igSetActiveID(id, @ptrCast(window));
                cimgui.igSetFocusID(id, @ptrCast(window));
                cimgui.igFocusWindow(@ptrCast(window), 0);
                g.ActiveIdUsingNavDirMask = (1 << cimgui.ImGuiDir_Left) | (1 << cimgui.ImGuiDir_Right);
            }
        }

        if (temp_input_is_active) {
            return tempInputScalar(T, frame_bb, id, label, p_data, fmt, p_min, p_max);
        }

        // Draw frame
        const frame_col: u32 = cimgui.igGetColorU32_Col(if (g.ActiveId == id) cimgui.ImGuiCol_FrameBgActive else if (hovered) cimgui.ImGuiCol_FrameBgHovered else cimgui.ImGuiCol_FrameBg, 1);

        cimgui.igRenderNavHighlight(frame_bb, id, 0);
        cimgui.igRenderFrame(frame_bb.Min, frame_bb.Max, frame_col, true, style.FrameRounding);

        // Drag behavior
        // const value_changed = cimgui.igDragBehavior(id, data_type, p_data, v_speed, p_min, p_max, format, flags);
        const value_changed = false;

        if (value_changed)
            cimgui.igMarkItemEdited(id);

        var value_buf: [64]u8 = undefined;
        // const value_buf_end = value_buf + DataTypeFormatString(value_buf, value_buf.len, data_type, p_data, format);

        const value_buf_str = std.fmt.bufPrint(&value_buf, fmt, .{p_data.*}) catch @panic("");
        const value_buf_end = value_buf_str.ptr + value_buf_str.len;

        cimgui.igRenderTextClipped(
            frame_bb.Min,
            frame_bb.Max,
            &value_buf,
            value_buf_end,
            null,
            .{ .x = 0.5, .y = 0.5 },
            null,
        );

        if (label_size.x > 0.0) {
            cimgui.igRenderText(
                .{ .x = frame_bb.Max.x + style.ItemInnerSpacing.x, .y = frame_bb.Min.y + style.FramePadding.y },
                label.ptr,
                label.ptr + label.len,
                true,
            );
        }

        return value_changed;
    }

    fn tempInputScalar(
        comptime ScalarType: type,
        bb: cimgui.ImRect,
        id: cimgui.ImGuiID,
        label: []const u8,
        p_data: *ScalarType,
        comptime fmt: []const u8,
        clamp_min: ?ScalarType,
        clamp_max: ?ScalarType,
    ) bool {
        var fmt_buf: [32]u8 = undefined;
        var data_buf: [32]u8 = undefined;

        _ = std.fmt.bufPrint(&fmt_buf, fmt, .{p_data.*}) catch @panic("");

        cimgui.igImStrTrimBlanks(&data_buf);

        const flags = cimgui.ImGuiInputTextFlags_AutoSelectAll | cimgui.ImGuiInputTextFlags_NoMarkEdited;

        var value_changed: bool = false;

        if (cimgui.igTempInputText(bb, id, label.ptr, &data_buf, data_buf.len, flags)) {
            // Backup old value
            const data_backup: ScalarType = p_data.*;

            p_data.* = std.fmt.parseFloat(ScalarType, &data_buf) catch p_data.*;

            if (clamp_min != null or clamp_max != null) {
                var actual_min: ScalarType = clamp_min orelse 0;
                var actual_max: ScalarType = clamp_max orelse 0;

                if (clamp_min != null and clamp_max != null) {
                    if (clamp_max.? < clamp_min.?) {
                        std.mem.swap(ScalarType, &actual_min, &actual_max);
                    }
                }

                if (clamp_max != null) {
                    p_data.* = @min(p_data.*, clamp_max.?);
                }

                if (clamp_min != null) {
                    p_data.* = @max(p_data.*, clamp_min.?);
                }
            }

            // Only mark as edited if new value is different
            value_changed = data_backup != p_data.*;

            if (value_changed) {
                cimgui.igMarkItemEdited(id);
            }
        }
        return value_changed;
    }
};

const cimgui_extras = struct {
    pub const ImGuiWindow = extern struct {
        Ctx: [*c]cimgui.ImGuiContext,
        Name: [*c]u8,
        ID: cimgui.ImGuiID,
        Flags: cimgui.ImGuiWindowFlags,
        FlagsPreviousFrame: cimgui.ImGuiWindowFlags,
        ChildFlags: cimgui.ImGuiChildFlags,
        WindowClass: cimgui.ImGuiWindowClass,
        Viewport: [*c]cimgui.ImGuiViewportP,
        ViewportId: cimgui.ImGuiID,
        ViewportPos: cimgui.ImVec2,
        ViewportAllowPlatformMonitorExtend: c_int,
        Pos: cimgui.ImVec2,
        Size: cimgui.ImVec2,
        SizeFull: cimgui.ImVec2,
        ContentSize: cimgui.ImVec2,
        ContentSizeIdeal: cimgui.ImVec2,
        ContentSizeExplicit: cimgui.ImVec2,
        WindowPadding: cimgui.ImVec2,
        WindowRounding: f32,
        WindowBorderSize: f32,
        DecoOuterSizeX1: f32,
        DecoOuterSizeY1: f32,
        DecoOuterSizeX2: f32,
        DecoOuterSizeY2: f32,
        DecoInnerSizeX1: f32,
        DecoInnerSizeY1: f32,
        NameBufLen: c_int,
        MoveId: cimgui.ImGuiID,
        TabId: cimgui.ImGuiID,
        ChildId: cimgui.ImGuiID,
        Scroll: cimgui.ImVec2,
        ScrollMax: cimgui.ImVec2,
        ScrollTarget: cimgui.ImVec2,
        ScrollTargetCenterRatio: cimgui.ImVec2,
        ScrollTargetEdgeSnapDist: cimgui.ImVec2,
        ScrollbarSizes: cimgui.ImVec2,
        ScrollbarX: bool,
        ScrollbarY: bool,
        ViewportOwned: bool,
        Active: bool,
        WasActive: bool,
        WriteAccessed: bool,
        Collapsed: bool,
        WantCollapseToggle: bool,
        SkipItems: bool,
        Appearing: bool,
        Hidden: bool,
        IsFallbackWindow: bool,
        IsExplicitChild: bool,
        HasCloseButton: bool,
        ResizeBorderHovered: i8,
        ResizeBorderHeld: i8,
        BeginCount: i16,
        BeginCountPreviousFrame: i16,
        BeginOrderWithinParent: i16,
        BeginOrderWithinContext: i16,
        FocusOrder: i16,
        PopupId: cimgui.ImGuiID,
        AutoFitFramesX: cimgui.ImS8,
        AutoFitFramesY: cimgui.ImS8,
        AutoFitOnlyGrows: bool,
        AutoPosLastDirection: cimgui.ImGuiDir,
        HiddenFramesCanSkipItems: cimgui.ImS8,
        HiddenFramesCannotSkipItems: cimgui.ImS8,
        HiddenFramesForRenderOnly: cimgui.ImS8,
        DisableInputsFrames: cimgui.ImS8,

        bit_field_zero: packed struct(u32) {
            SetWindowPosAllowFlags: u8,
            SetWindowSizeAllowFlags: u8,
            SetWindowCollapsedAllowFlags: u8,
            SetWindowDockAllowFlags: u8,
        },

        SetWindowPosVal: cimgui.ImVec2,
        SetWindowPosPivot: cimgui.ImVec2,
        IDStack: cimgui.ImVector_ImGuiID,
        DC: cimgui.ImGuiWindowTempData,
        OuterRectClipped: cimgui.ImRect,
        InnerRect: cimgui.ImRect,
        InnerClipRect: cimgui.ImRect,
        WorkRect: cimgui.ImRect,
        ParentWorkRect: cimgui.ImRect,
        ClipRect: cimgui.ImRect,
        ContentRegionRect: cimgui.ImRect,
        HitTestHoleSize: cimgui.ImVec2ih,
        HitTestHoleOffset: cimgui.ImVec2ih,
        LastFrameActive: c_int,
        LastFrameJustFocused: c_int,
        LastTimeActive: f32,
        ItemWidthDefault: f32,
        StateStorage: cimgui.ImGuiStorage,
        ColumnsStorage: cimgui.ImVector_ImGuiOldColumns,
        FontWindowScale: f32,
        FontDpiScale: f32,
        SettingsOffset: c_int,
        DrawList: *cimgui.ImDrawList,
        DrawListInst: cimgui.ImDrawList,
        ParentWindow: *cimgui.ImGuiWindow,
        ParentWindowInBeginStack: *cimgui.ImGuiWindow,
        RootWindow: *cimgui.ImGuiWindow,
        RootWindowPopupTree: *cimgui.ImGuiWindow,
        RootWindowDockTree: *cimgui.ImGuiWindow,
        RootWindowForTitleBarHighlight: *cimgui.ImGuiWindow,
        RootWindowForNav: *cimgui.ImGuiWindow,
        NavLastChildNavWindow: *cimgui.ImGuiWindow,
        NavLastIds: [cimgui.ImGuiNavLayer_COUNT]cimgui.ImGuiID,
        NavRectRel: [cimgui.ImGuiNavLayer_COUNT]cimgui.ImRect,
        NavPreferredScoringPosRel: [cimgui.ImGuiNavLayer_COUNT]cimgui.ImVec2,
        NavRootFocusScopeId: cimgui.ImGuiID,
        MemoryDrawListIdxCapacity: c_int,
        MemoryDrawListVtxCapacity: c_int,
        MemoryCompacted: bool,

        bit_field_two: packed struct(u8) {
            dock_is_active: bool,
            dock_node_is_visible: bool,
            dock_tab_is_visible: bool,
            dock_tab_want_close: bool,
            _: u4,
        },

        DockOrder: i16,
        DockStyle: cimgui.ImGuiWindowDockStyle,
        DockNode: *cimgui.ImGuiDockNode,
        DockNodeAsHost: *cimgui.ImGuiDockNode,
        DockId: cimgui.ImGuiID,
        DockTabItemStatusFlags: cimgui.ImGuiItemStatusFlags,
        DockTabItemRect: cimgui.ImRect,
    };
};

const cimgui = @import("imgui/cimgui.zig");
const std = @import("std");
