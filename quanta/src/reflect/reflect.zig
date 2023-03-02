const std = @import("std");

///If this is true, then the reflection api can be used
///If this is false, then uses of the reflection api will throw an error
///This value should be checked when before using the reflection api 
pub const reflect_enabled: bool = true;

pub const Type = union(enum)
{
    Struct: Struct,
    Enum: Enum,
    Union: Union,
    Int: Int,
    Float: Float,
    Bool: void,

    pub const Struct = struct 
    {
        name: []const u8,
        size: u32,
        alignment: u32,
        layout: std.builtin.Type.ContainerLayout,
        fields: []const StructField,
        decls: []const Declaration,
        is_tuple: bool,
    };

    pub const StructField = struct 
    {
        name: []const u8,
        offset: u32,
        type: *const Type,
        default_value: ?*const anyopaque,
        is_comptime: bool,
        alignment: u32,
    };

    pub const Enum = struct 
    {
        name: []const u8,
        size: u32,
        alignment: u32,
        tag_type: *const Type,
        fields: []const EnumField,
        decls: []const Declaration,
        is_exhaustive: bool,
    };

    pub const EnumField = struct {
        name: []const u8,
        value: u64,
    };

    pub const Declaration = struct 
    {
        name: []const u8,
        type: *const Type,
        value: *anyopaque,
        is_pub: bool,
    };

    pub const Int = struct {
        signedness: std.builtin.Signedness,
        bits: u16,
    };

    pub const Float = struct {
        bits: u16,
    };

    pub const UnionField = struct {
        name: []const u8,
        type: *const Type,
        alignment: u32,
    };

    pub const Union = struct {
        name: []const u8,
        size: u32,
        alignment: u32,
        layout: std.builtin.Type.ContainerLayout,
        tag_type: ?*const Type,
        fields: []const UnionField,
        decls: []const Declaration,
    };

    ///Returns a pointer to the canonical Type for T
    pub fn info(comptime T: type) *const Type
    {
        const Static = struct 
        {
            pub const @"type": Type = infoValue(T);
        };

        return &Static.@"type";
    }

    pub inline fn infoValue(comptime T: type) Type
    {
        var type_data: Type = undefined;

        switch (@typeInfo(T)) 
        {
            .Struct => |struct_info| {
                comptime var fields: [struct_info.fields.len]StructField = undefined;

                inline for (&fields, struct_info.fields) |*struct_field, comptime_struct_field|
                {
                    struct_field.* = .{
                        .name = comptime_struct_field.name,
                        .offset = @offsetOf(T, comptime_struct_field.name),
                        .alignment = comptime_struct_field.alignment,
                        .default_value = comptime_struct_field.default_value,
                        .is_comptime = comptime_struct_field.is_comptime,
                        .type = info(comptime_struct_field.type),
                    };
                }

                type_data = .{ 
                    .Struct = .{
                        .name = @typeName(T),
                        .size = @sizeOf(T),
                        .alignment = @alignOf(T),
                        .layout = struct_info.layout,
                        .fields = &fields,
                        .decls = &.{},
                        .is_tuple = struct_info.is_tuple,
                    } 
                };
            },
            .Union => |union_info| {
                type_data = .{
                    .Union = .{
                        .name = @typeName(T),
                        .size = @sizeOf(T),
                        .alignment = @alignOf(T),
                        .layout = union_info.layout,
                        .tag_type = if (union_info.tag_type != null) info(union_info.tag_type.?) else null, 
                        .fields = &.{},
                        .decls = &.{},
                    }
                };
            },
            .Enum => |enum_info| {
                type_data = .{
                    .Enum = .{
                        .name = @typeName(T),
                        .size = @sizeOf(T),
                        .alignment = @alignOf(T),
                        .tag_type = info(enum_info.tag_type),
                        .fields = &.{},
                        .decls = &.{},
                        .is_exhaustive = enum_info.is_exhaustive,
                    }
                };
            },
            .Int => |int_info| {
                type_data = .{ 
                    .Int = .{  
                        .signedness = int_info.signedness,
                        .bits = int_info.bits,
                    } 
                };
            },
            .Float => |float_info| {
                type_data = .{
                    .Float = .{
                        .bits = float_info.bits,
                    },
                };
            },
            .Bool => {
                type_data = .Bool;
            },
            else => unreachable,
        }

        return type_data;  
    }

    ///Returns the full, unambigious name of the type
    pub fn name(self: Type) []const u8 
    {
        return switch (self)
        {
            .Struct => |struct_info| struct_info.name,
            .Enum => |enum_info| enum_info.name,
            .Union => |union_info| union_info.name,
            else => "",
        };
    }

    ///Equivalent of @sizeOf(T) builtin
    pub fn size(self: Type) usize 
    {
        switch (self) {
            .Struct => |struct_info| return struct_info.size,
            .Enum => |enum_info| return enum_info.size,
            .Union => |union_info| return union_info.size,
            else => unreachable, 
        }
    }

    ///Equivalent of @alignOf(T) builtin
    pub fn alignment(self: Type) usize 
    {
        switch (self) {
            .Struct => |struct_info| return struct_info.alignment,
            .Enum => |enum_info| return enum_info.alignment,
            .Union => |union_info| return union_info.alignment,
            else => unreachable, 
        }
    }

    ///Returns true if self represents the type T
    pub fn is(self: *const Type, comptime T: type) bool 
    {
        return self == info(T);
    } 

    pub fn format(
        self: Type,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("name: {s}", .{ self.name() });
    }
};

test 
{
    const expect = std.testing.expect;

    const ExampleStruct = struct 
    {
        a: f32,
        b: u32,
        c: bool,
    };

    const type_info = Type.info(ExampleStruct);

    try expect(type_info == Type.info(ExampleStruct));

    std.log.warn("type_info.sizeOf() = {}", .{ type_info.size()});

    try expect(type_info.is(ExampleStruct));
    try expect(type_info.size() == @sizeOf(ExampleStruct));
    try expect(type_info.alignment() == @alignOf(ExampleStruct));
    try expect(type_info.* == .Struct);

    switch (type_info.*)
    {
        .Struct => |struct_info| {
            for (struct_info.fields) |field|
            {
                std.log.warn("field = {s}", .{ field.name });

                std.log.warn("type(field) = {any}", .{ field.type.* });
            }
        },
        else => unreachable,
    }
}