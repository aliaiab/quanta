const std = @import("std");
const ComponentStore = @import("ComponentStore.zig");
const CommandBuffer = @import("CommandBuffer.zig");

pub const QueryIterator = ComponentStore.QueryIterator;

pub const System = struct 
{
    pub const depencencies = .{
        //some other system
    };

    ///Each system has a run function
    pub fn run(
        command_buffer: *CommandBuffer,
        query: QueryIterator(.{}, .{}),
    ) void 
    {
        _ = command_buffer;
        _ = query;
    }
};

///Register, schedule and run systems
pub fn run(
    component_store: *ComponentStore,
    command_buffer: *CommandBuffer,
    comptime systems: anytype
) !void 
{
    inline for (systems) |system|
    {
        const run_type_info = @typeInfo(@TypeOf(system.run)).Fn;

        const QueryIteratorType = run_type_info.params[1].type.?;

        var iter = std.meta.Child(QueryIteratorType).init(component_store);

        @call(.always_inline, system.run, .{
            command_buffer,
            &iter,
        });
    }

    try command_buffer.execute(component_store);
}