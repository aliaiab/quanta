const std = @import("std");
const ComponentStore = @import("ComponentStore.zig");

const CommandBuffer = @This();
const Entity = ComponentStore.Entity;

allocator: std.mem.Allocator,
commands: std.ArrayListUnmanaged(Command),

pub fn init(allocator: std.mem.Allocator) CommandBuffer
{
    return .{
        .allocator = allocator,
        .commands = .{},
    };
}

pub fn deinit(self: *CommandBuffer) void 
{
    self.commands.deinit(self.allocator);

    self.* = undefined; 
}

pub const Command = union(enum)
{
    create_entity: void,
    destroy_entity: struct { entity: Entity },
    add_component: struct { entity: Entity, component_id: ComponentStore.ComponentId },
    remove_component: struct { entity: Entity, component_id: ComponentStore.ComponentId },
};

pub fn addCommand(self: *CommandBuffer, command: Command) void 
{
    self.commands.append(self.allocator, command) catch unreachable;
}

///Encodes a command to add a component to an entity
pub fn entityAddComponent(
    self: *CommandBuffer, 
    entity: Entity, 
    component: anytype
) void 
{
    const T = @TypeOf(component);
    const component_id = ComponentStore.componentId(T);

    self.addCommand(Command { .add_component = .{ .entity = entity, .component_id = component_id } });
} 

///Encodes a command to remove a component from an entity
pub fn entityRemoveComponent(
    self: *CommandBuffer, 
    entity: Entity, 
    comptime Component: type
) void 
{
    const component_id = ComponentStore.componentId(Component);

    self.addCommand(Command { .remove_component = .{ .entity = entity, .component_id = component_id } });
}

///Clears the commands from the command buffer
pub fn clear(self: *CommandBuffer) void 
{
    self.commands.clearRetainingCapacity();
}

///Executes the commands on the component_store
///Clears the commands from the command buffer
pub fn execute(self: *CommandBuffer, component_store: *ComponentStore) !void 
{
    for (self.commands.items) |command|
    {
        switch (command)
        {
            .remove_component => |args| 
            {
                try component_store.entityRemoveComponentId(args.entity, args.component_id);
            },
            else => unreachable,
        }
    }

    self.clear();
}