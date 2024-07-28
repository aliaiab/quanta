pub const Library = struct {
    functions: struct {
        context_new: *const fn (flags: ContextFlags) callconv(.C) *Context,
        context_unref: *const fn (context: *Context) callconv(.C) void,
        state_new: *const fn (keymap: *Keymap) callconv(.C) *State,
        state_unref: *const fn (state: *State) callconv(.C) void,
        keymap_new_from_names: *const fn (context: *Context, names: ?*const RuleNames, flags: KeymapCompileFlags) callconv(.C) *Keymap,
        keymap_unref: *const fn (keymap: *Keymap) callconv(.C) void,
        state_key_get_one_sym: *const fn (state: *State, key: KeyCode) callconv(.C) KeySym,
        state_key_get_utf8: *const fn (state: *State, key: KeyCode, buffer: [*]u8, size: usize) callconv(.C) u32,
        state_update_key: *const fn (state: *State, key: KeyCode, direction: KeyDirection) callconv(.C) StateComponent,
    },

    dynamic_library: std.DynLib,

    pub fn unload(self: *Library) void {
        self.dynamic_library.close();

        self.* = undefined;
    }

    pub inline fn contextNew(self: Library, flags: ContextFlags) *Context {
        return self.functions.context_new(flags);
    }

    pub inline fn contextUnref(self: Library, context: *Context) void {
        self.functions.context_unref(context);
    }

    pub inline fn stateNew(
        self: Library,
        keymap: *Keymap,
    ) *State {
        return self.functions.state_new(keymap);
    }

    pub inline fn stateUnref(self: Library, state: *State) void {
        self.functions.state_unref(state);
    }

    pub inline fn keymapNewFromNames(self: Library, context: *Context, names: ?*const RuleNames, flags: KeymapCompileFlags) *Keymap {
        return self.functions.keymap_new_from_names(context, names, flags);
    }

    pub inline fn keymapUnref(self: Library, keymap: *Keymap) void {
        self.functions.keymap_unref(keymap);
    }

    pub inline fn stateKeyGetOneSym(
        self: Library,
        state: *State,
        key: KeyCode,
    ) KeySym {
        return self.functions.state_key_get_one_sym(state, key);
    }

    pub inline fn stateKeyGetUtf8(
        self: Library,
        state: *State,
        key: KeyCode,
        buffer: [*]u8,
        size: usize,
    ) u32 {
        return self.functions.state_key_get_utf8(state, key, buffer, size);
    }

    pub inline fn stateUpdateKey(
        self: Library,
        state: *State,
        key: KeyCode,
        direction: KeyDirection,
    ) StateComponent {
        return self.functions.state_update_key(state, key, direction);
    }
};

pub fn load() !Library {
    var library = Library{
        .dynamic_library = try std.DynLib.open("libxkbcommon.so.0"),
        .functions = undefined,
    };

    errdefer library.dynamic_library.close();

    inline for (comptime std.meta.fieldNames(@TypeOf(library.functions))) |field_name| {
        @field(library.functions, field_name) = library.dynamic_library.lookup(
            @TypeOf(@field(library.functions, field_name)),
            "xkb_" ++ field_name,
        ).?;
    }

    return library;
}

pub const KeyCode = enum(u32) { _ };
pub const KeySym = @import("xkb_keys.zig").KeySym;

pub const KeyDirection = enum(u32) {
    up,
    down,
    _,
};

pub const StateComponent = packed struct(u32) {
    mods_depressed: bool = false,
    mods_latched: bool = false,
    mods_locked: bool = false,
    mods_effective: bool = false,
    layout_depressed: bool = false,
    layout_latched: bool = false,
    layout_locked: bool = false,
    layout_effective: bool = false,
    leds: bool = false,
    padding: u23,
};

pub const KeymapCompileFlags = packed struct(u32) {
    padding: u32 = 0,
};

pub const RuleNames = extern struct {
    rules: [*:0]const u8,
    model: [*:0]const u8,
    layout: [*:0]const u8,
    variant: [*:0]const u8,
    options: [*:0]const u8,
};

pub const ContextFlags = packed struct(u32) {
    no_flags: bool = false,
    default_includes: bool = false,
    environment_names: bool = false,
    padding: u29 = 0,
};

pub const Context = opaque {};
pub const Keymap = opaque {};
pub const State = opaque {};

const std = @import("std");
