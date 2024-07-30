//! The quanta init system, responsible for initializing and deinitializing engine subsystems and dispatching to application code
//! This is an optional component, and is not required to use quanta's features

pub const boostrap = @import("init/boostrap.zig");

pub const InitOptions = struct {
    ///A global general purpose allocator
    gpa: std.mem.Allocator,
    ///An initialization arena for application lifetime allocations only
    ///You should use this instead of gpa for most init functions, unless you need to realloc or resize an allocation during the run phase
    ///Don't try to reset this arena, it is global to the init instance and doing so will destroy engine internals
    arena: std.mem.Allocator,
};

pub const DeinitOptions = InitOptions;

pub const UpdateState = struct {
    gpa: std.mem.Allocator,
    ///An arena which is reset after each update cycle
    transient_arena: std.mem.Allocator,
};

pub const UpdateResult = enum {
    ///Continue to the next update
    pass,
    ///Exit the update loop
    exit,
};

pub const InitFn = fn (options: InitOptions) anyerror!void;
pub const DeinitFn = fn (options: DeinitOptions) void;
pub const UpdateFn = fn (options: UpdateState) anyerror!UpdateResult;

///A top level initialization system
pub const TopLevel = struct {
    init: InitFn,
    deinit: DeinitFn,
    update: UpdateFn,
};

test {
    @import("std").testing.refAllDecls(@This());
}

const std = @import("std");
