//! An immediate mode gui module

///Contains all the gui state
pub const Context = struct {
    gpa: std.mem.Allocator,
    init_arena: std.mem.Allocator,

    pub fn init() Context {}

    pub fn deinit() void {}
};

const std = @import("std");
