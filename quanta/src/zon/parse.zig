pub fn parse(comptime T: type, allocator: std.mem.Allocator, source: [:0]const u8) !T {
    const root_value = try Value.parse(allocator, source);

    const data = try structLiteralAsType(T, allocator, root_value.struct_literal);

    return data;
}

pub fn parseFree(comptime T: type, allocator: std.mem.Allocator, data: T) void {
    inline for (std.meta.fields(T)) |field| {
        switch (@typeInfo(field.type)) {
            .Struct => {},
            .Pointer => |pointer_type_info| {
                switch (pointer_type_info.size) {
                    .Slice => {
                        allocator.free(@field(data, field.name));
                    },
                    else => {},
                }
            },
            else => {},
        }
    }
}

fn valueAsType(comptime T: type, allocator: std.mem.Allocator, value: Value) !T {
    var data: T = undefined;

    if (value == .undefined) {
        data = undefined;

        return data;
    }

    switch (@typeInfo(T)) {
        .Float => {
            data = switch (value) {
                .float => @floatCast(value.float),
                .integer => @floatFromInt(value.integer),
                else => unreachable,
            };
        },
        .Int => {
            data = @intCast(value.integer);
        },
        .Bool => {
            data = value.boolean;
        },
        .Enum => {
            data = std.meta.stringToEnum(T, value.enum_literal).?;
        },
        .Union => {
            const active_field_name = value.struct_literal.keys()[0];

            inline for (std.meta.fields(T)) |field| {
                if (std.mem.eql(
                    u8,
                    field.name,
                    active_field_name,
                )) {
                    data = @unionInit(
                        T,
                        field.name,
                        try valueAsType(field.type, allocator, value.struct_literal.get(field.name).?),
                    );
                }
            }
        },
        .Struct => {
            data = try structLiteralAsType(T, allocator, value.struct_literal);
        },
        .Array => {
            data = try arrayValueAsType(T, allocator, value.array);
        },
        .Vector => |vector_info| {
            data = try arrayValueAsType([vector_info.len]vector_info.child, allocator, value.array);
        },
        .Pointer => |pointer_type_info| {
            switch (pointer_type_info.size) {
                .Slice => {
                    switch (pointer_type_info.child) {
                        u8 => {
                            data = switch (value) {
                                .array => try arrayValueAsSliceType(T, allocator, value.array),
                                .string => try allocator.dupe(u8, value.string[1 .. value.string.len - 1]),
                                else => unreachable,
                            };
                        },
                        else => {
                            data = try arrayValueAsSliceType(T, allocator, value.array);
                        },
                    }
                },
                else => {},
            }
        },
        .Optional => |optional_info| {
            data = switch (value) {
                .null => null,
                else => try valueAsType(optional_info.child, allocator, value),
            };
        },
        else => {},
    }

    return data;
}

fn arrayValueAsType(comptime T: type, allocator: std.mem.Allocator, array: Value.Array) !T {
    var data: T = undefined;

    for (array, &data) |value, *data_value| {
        data_value.* = try valueAsType(std.meta.Child(T), allocator, value);
    }

    return data;
}

fn arrayValueAsSliceType(comptime T: type, allocator: std.mem.Allocator, array: Value.Array) !T {
    const data = try allocator.alloc(std.meta.Child(T), array.len);
    errdefer allocator.free(data);

    for (array, data) |value, *data_value| {
        data_value.* = try valueAsType(std.meta.Child(T), allocator, value);
    }

    return data;
}

fn structLiteralAsType(comptime T: type, allocator: std.mem.Allocator, struct_literal: Value.StructLiteral) !T {
    var data: T = undefined;

    inline for (std.meta.fields(T)) |field| {
        const value = struct_literal.get(field.name);

        if (value == null and field.default_value != null) {
            @field(data, field.name) = @as(*const field.type, @ptrCast(@alignCast(field.default_value.?))).*;
        }

        if (value != null) {
            @field(data, field.name) = try valueAsType(field.type, allocator, value.?);
        }
    }

    return data;
}

const Value = union(enum) {
    null,
    undefined,
    boolean: bool,
    integer: i64,
    float: f64,
    string: []const u8,
    enum_literal: []const u8,
    struct_literal: StructLiteral,
    array: Array,
    tuple: Tuple,

    pub const StructLiteral = std.StringArrayHashMapUnmanaged(Value);
    pub const Array = []Value;
    pub const Tuple = []Value;

    pub fn parse(allocator: std.mem.Allocator, source: [:0]const u8) !Value {
        var ast = try std.zig.Ast.parse(allocator, source, .zon);
        defer ast.deinit(allocator);

        for (ast.errors) |error_value| {
            //TODO: render full, zig style error messages with colour formatting
            try ast.renderError(error_value, std.io.getStdOut().writer());
            _ = try std.io.getStdOut().write("\n");
        }

        if (ast.errors.len != 0) {
            return error.ParserError;
        }

        for (0..ast.nodes.len) |node_index| {
            const node_tag = ast.nodes.items(.tag)[node_index];
            _ = node_tag;
        }

        const root = ast.nodes.get(0);

        var struct_init_buffer: [2]std.zig.Ast.Node.Index = undefined;

        const struct_init = ast.fullStructInit(&struct_init_buffer, root.data.lhs).?;
        _ = struct_init;

        const root_value = try structLiteralValue(allocator, ast, root.data.lhs);

        return root_value;
    }

    fn anyValue(allocator: std.mem.Allocator, ast: std.zig.Ast, node_index: std.zig.Ast.Node.Index) anyerror!Value {
        const node_type = ast.nodes.items(.tag)[node_index];
        const field_expr = ast.tokenSlice(ast.nodes.get(node_index).main_token);

        var value: Value = .null;

        switch (node_type) {
            .number_literal => {
                const is_float = std.mem.count(u8, field_expr, ".") != 0;

                if (is_float) {
                    const float_value = try std.fmt.parseFloat(f64, field_expr);

                    value = .{ .float = float_value };
                } else {
                    const int_value = try std.fmt.parseInt(i64, field_expr, 0);

                    value = .{ .integer = int_value };
                }
            },
            .string_literal => {
                const string_value = field_expr;

                value = .{ .string = string_value };
            },
            .enum_literal => {
                const string_value = field_expr;

                value = .{ .enum_literal = string_value };
            },
            .struct_init_dot,
            .struct_init_dot_comma,
            .struct_init_dot_two,
            .struct_init_dot_two_comma,
            => {
                value = try structLiteralValue(allocator, ast, node_index);
            },
            .array_init_dot,
            .array_init_dot_comma,
            .array_init_dot_two_comma,
            .array_init,
            => {
                value = try arrayValue(allocator, ast, node_index);
            },
            .identifier => {
                if (std.mem.eql(u8, field_expr, "true")) {
                    value = .{ .boolean = true };
                } else if (std.mem.eql(u8, field_expr, "false")) {
                    value = .{ .boolean = false };
                } else if (std.mem.eql(u8, field_expr, "null")) {
                    value = .null;
                } else if (std.mem.eql(u8, field_expr, "undefined")) {
                    value = .undefined;
                }
            },
            else => {},
        }

        return value;
    }

    fn structLiteralValue(allocator: std.mem.Allocator, ast: std.zig.Ast, node_index: std.zig.Ast.Node.Index) anyerror!Value {
        var struct_init_buffer: [2]std.zig.Ast.Node.Index = undefined;
        const struct_init = ast.fullStructInit(&struct_init_buffer, node_index).?;

        var value_map: Value.StructLiteral = .{};

        for (struct_init.ast.fields) |field_index| {
            const node_type = ast.nodes.items(.tag)[field_index];

            const offset: u32 = switch (node_type) {
                .enum_literal,
                .struct_init_dot,
                .struct_init_dot_two,
                .struct_init_dot_two_comma,
                .array_init,
                .array_init_dot,
                .array_init_dot_comma,
                .array_init_dot_two,
                .array_init_dot_two_comma,
                => 3,
                .identifier,
                .number_literal,
                .string_literal,
                => 2,
                else => {
                    std.log.err("node_type = {}", .{node_type});

                    unreachable;
                },
            };

            const field_name = ast.tokenSlice(ast.nodes.get(field_index).main_token - offset);

            const value = try anyValue(allocator, ast, field_index);

            try value_map.put(allocator, field_name, value);
        }

        return .{ .struct_literal = value_map };
    }

    fn arrayValue(allocator: std.mem.Allocator, ast: std.zig.Ast, node_index: std.zig.Ast.Node.Index) anyerror!Value {
        var array_init_buffer: [2]std.zig.Ast.Node.Index = undefined;
        const array_init = ast.fullArrayInit(&array_init_buffer, node_index).?;

        const values: Value.Array = try allocator.alloc(Value, array_init.ast.elements.len);
        errdefer allocator.free(values);

        for (values, array_init.ast.elements) |*value, element_node| {
            value.* = try anyValue(allocator, ast, element_node);
        }

        return .{ .array = values };
    }
};

test {
    std.testing.refAllDecls(@This());
}

const std = @import("std");
