const std = @import("std");
const ComponentStore = @import("ComponentStore.zig");
const reflect = @import("../reflect/reflect.zig");

pub fn filterWith(comptime T: type) Filter {
    return .{ .with = T };
}

pub fn filterWithout(comptime T: type) Filter {
    return .{ .without = T };
}

pub fn filterOr(comptime T: type, comptime U: type) Filter {
    return .{ .@"or" = .{ T, U } };
}

pub const Filter = union(enum) {
    with: type,
    without: type,
    @"or": struct { type, type },
};

///Each query has a set of filters which can describe it
///constness is erased as part of this id, as two queries
///with different access requirements will observe the same
///set of chunks
///This hash is meant for quick query comparison, and is type erased
pub const QueryId = packed struct(u64) {
    hash: u64,

    pub fn create(comptime descriptor: QueryDescriptor) QueryId {
        var hash: u64 = 0;

        for (descriptor.filters) |filter| {
            switch (filter) {
                .with => |component_type| {
                    const id = @intFromPtr(ComponentStore.componentId(component_type));

                    hash |= id;
                },
                .without => |component_type| {
                    const id = @intFromPtr(ComponentStore.componentId(component_type));

                    hash -= id;
                },
                .@"or" => comptime unreachable,
            }
        }

        return .{ .hash = hash };
    }
};

pub const QueryDescriptor = struct {
    filters: []Filter,
};

///Each query maintains a list of chunks that it observes
///Invalidating the query means updating this chunk list
pub const QueryData = struct {
    chunks: []*ComponentStore.Chunk,
    query_id: QueryId,
};
