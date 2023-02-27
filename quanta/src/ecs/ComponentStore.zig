const std = @import("std");
const reflect = @import("../reflect/reflect.zig");

const ComponentStore = @This(); 

///Associated flags as part of the entity
const EntityFlags = packed struct(u16)
{
    enabled: bool = false,
    padding: u15 = 0,
};

///Unique identifier which describes an entity
const EntityData = packed struct(u64) 
{
    index: u32,
    generation: u16,
    flags: EntityFlags,

    pub fn toHandle(self: EntityData) Entity
    {
        return @intToEnum(Entity, @bitCast(u64, self));
    }

    pub fn fromHandle(entity: Entity) EntityData
    {
        return @bitCast(EntityData, @enumToInt(entity));
    }
};

///Unique identifier which describes an entity
pub const Entity = enum(u64) { _ };

///Unique identifier for a component type
pub const ComponentId = *const reflect.Type;

pub const ComponentType = struct 
{
    id: ComponentId,
    size: u32,
    alignment: u32,

    pub fn fromTypeInfo(type_info: *const reflect.Type) ComponentType
    {
        return .{
            .id = type_info,
            .size = @intCast(u32, type_info.size()),
            .alignment = @intCast(u32, type_info.alignment()),
        };
    }
};

pub const Column = struct 
{
    data: std.ArrayListUnmanaged(u8) = .{},
    element_size: u32, 

    pub fn addComponent(self: *Column, allocator: std.mem.Allocator, comptime T: type, component: T) !*T
    {
        if (@sizeOf(T) == 0)
        {
            return undefined;
        }

        const byte_offset = self.data.items.len;

        try self.data.appendSlice(allocator, std.mem.asBytes(&component));

        return @ptrCast(*T, @alignCast(@alignOf(T), self.data.items.ptr + byte_offset));
    }

    pub fn getComponent(self: Column, comptime T: type, index: usize) *T
    {
        if (@sizeOf(T) == 0)
        {
            @compileError("Cannot get zero-bit component");
        }

        const byte_offset = index * @sizeOf(T);

        std.log.warn("data_len = {}", .{ self.data.items.len });
        std.log.warn("byte_offset = {}", .{ byte_offset });

        return @ptrCast(*T, @alignCast(@alignOf(T), self.data.items.ptr + byte_offset));
    }  
};

pub const ArchetypeId = packed struct (u32)
{
    id: u32,
};

pub const ArchetypeIndex = u32;

///Stores the data for components on entities with the same component permutation
pub const Archetype = struct 
{
    pub const Edge = struct 
    {
        add: ?u31,
        remove: ?u31,
    };

    component_ids: std.ArrayListUnmanaged(ComponentId) = .{},
    columns: std.ArrayListUnmanaged(Column) = .{},
    edges: std.AutoHashMapUnmanaged(ComponentId, Edge) = .{},
    entities: std.ArrayListUnmanaged(Entity) = .{},
    row_count: u32,
};

pub const EntityDescription = struct 
{
    archetype_index: ArchetypeIndex,
    row_index: u32,
};

pub const ArchetypeRecord = struct 
{
    ///The column where the associated component type exists 
    column: u32,
};

pub const ComponentTypeDescription = struct 
{
    archetypes: std.AutoArrayHashMapUnmanaged(ArchetypeIndex, ArchetypeRecord) = .{},
};

allocator: std.mem.Allocator,
archetypes: std.ArrayListUnmanaged(Archetype),
entity_index: std.AutoArrayHashMapUnmanaged(Entity, EntityDescription), 
component_index: std.AutoArrayHashMapUnmanaged(ComponentId, ComponentTypeDescription),
next_entity_index: u32,
next_entity_generation: u16,

pub fn init(allocator: std.mem.Allocator) !ComponentStore
{
    var self = ComponentStore
    {
        .allocator = allocator,
        .archetypes = .{},
        .entity_index = .{},
        .component_index = .{},
        .next_entity_index = 0,
        .next_entity_generation = 0,
    };

    try self.archetypes.append(self.allocator, .{
        .component_ids = .{},
        .columns = .{},
        .edges = .{},
        .row_count = 0,
    });

    return self;
}

pub fn deinit(self: *ComponentStore) void 
{
    for (self.archetypes.items) |*archetype|
    {
        archetype.component_ids.deinit(self.allocator);
        archetype.edges.deinit(self.allocator);

        for (archetype.columns.items) |*column|
        {
            column.data.deinit(self.allocator);
        }

        archetype.columns.deinit(self.allocator);
        archetype.entities.deinit(self.allocator);
    }

    for (self.component_index.values()) |*component_type_desc|
    {
        component_type_desc.archetypes.deinit(self.allocator);
    }

    self.archetypes.deinit(self.allocator);
    self.entity_index.deinit(self.allocator);
    self.component_index.deinit(self.allocator);

    self.* = undefined;
}

pub fn getEntities(self: ComponentStore) []const Entity
{
    return self.entity_index.keys();
}

///Creates a new entity handle adds components to it.
///The returned entity handle is guaranteed to be new and unique
pub fn entityCreate(self: *ComponentStore, components: anytype) !Entity
{
    var entity = EntityData 
    { 
        .index = self.next_entity_index, 
        .generation = self.next_entity_generation,
        .flags = .{},
    };

    try self.entity_index.put(self.allocator, entity.toHandle(), .{
        .archetype_index = 0,
        .row_index = 0,
    });

    self.next_entity_index += 1;

    if (std.meta.fields(@TypeOf(components)).len > 0)
    {
        try self.entityAddComponents(entity.toHandle(), components);
    }

    return entity.toHandle();
}

///Removes all components on an entity and invalidates the entity handle 
pub fn entityDestroy(self: *ComponentStore, entity: Entity) void
{
    self.entityClear(entity);

    _ = self.entity_index.swapRemove(entity);

    self.next_entity_generation +%= 1;
}

///Removes all components on an entity, returning it to the empty state
pub fn entityClear(self: *ComponentStore, entity: Entity) void 
{
    const entity_description = self.entity_index.getPtr(entity).?;

    self.archetypeRemoveRow(entity_description.archetype_index, entity_description.row_index);

    entity_description.archetype_index = 0;
    entity_description.row_index = 0;
}

pub fn entityAddComponent(
    self: *ComponentStore,
    entity: Entity,
    component: anytype,
) !void 
{
    if (@TypeOf(component) == type and @sizeOf(component) != 0)
    {
        @compileError("Non-zero size component types must be initialized with a value!");
    } 

    const T = if (@TypeOf(component) == type) component else @TypeOf(component);

    const component_type = componentType(T);

    const entity_description = self.entity_index.getPtr(entity).?;

    const source_archetype_index = entity_description.archetype_index;

    const archetype_index = try self.addToArchetype(source_archetype_index, component_type);

    entity_description.archetype_index = archetype_index;
    entity_description.row_index = @intCast(u32, try self.archetypeMoveRow(source_archetype_index, archetype_index, entity_description.row_index, entity));

    if (@sizeOf(T) == 0)
    {
        return;
    }

    self.entitySetComponent(entity, component);
}

pub fn entityAddComponents(
    self: *ComponentStore,
    entity: Entity,
    components: anytype,
) !void 
{
    inline for (components) |component|
    {
        try self.entityAddComponent(entity, component);
    }
}

pub fn entityRemoveComponent(
    self: *ComponentStore,
    entity: Entity,
    comptime Component: type,
) !void 
{
    const component_type = componentType(Component);

    const entity_description = self.entity_index.getPtr(entity).?;

    const source_archetype_index = entity_description.archetype_index;

    const archetype_index = try self.removeFromArchetype(source_archetype_index, component_type);

    entity_description.archetype_index = archetype_index;

    if (archetype_index == 0)
    {
        entity_description.row_index = 0;

        return;
    }

    entity_description.row_index = @intCast(u32, try self.archetypeMoveRow(source_archetype_index, archetype_index, entity_description.row_index, entity));
}

pub fn entityRemoveComponentId(
    self: *ComponentStore,
    entity: Entity,
    component_id: ComponentId,
) !void 
{
    const entity_description = self.entity_index.getPtr(entity).?;

    const source_archetype_index = entity_description.archetype_index;

    const archetype_index = try self.removeFromArchetype(source_archetype_index, component_id);

    entity_description.archetype_index = archetype_index;

    if (archetype_index == 0)
    {
        return;
    }

    entity_description.row_index = @intCast(u32, try self.archetypeMoveRow(source_archetype_index, archetype_index, entity_description.row_index, entity));
}

pub fn entitySetComponent(
    self: *ComponentStore, 
    entity: Entity, 
    component: anytype,
) void 
{   
    const T = @TypeOf(component);

    self.entityGetComponent(entity, T).?.* = component;
}

///Returns a pointer to the component of type T if present, otherwise returns null
pub fn entityGetComponent(
    self: *ComponentStore, 
    entity: Entity, 
    comptime T: type,
    ) ?*T
{
    const component_id = componentId(T);

    const entity_description = self.entity_index.get(entity).?;
    const entity_archetype: Archetype = self.archetypes.items[entity_description.archetype_index];

    const component_archetypes = self.component_index.get(component_id) orelse return null;

    const archetype_record = component_archetypes.archetypes.get(entity_description.archetype_index) orelse return null;

    const column = entity_archetype.columns.items[archetype_record.column];

    return column.getComponent(T, entity_description.row_index);
}

///Returns true if the entity exists in the ComponentStore
pub fn entityExists(
    self: *ComponentStore,
    entity: Entity,
) bool
{
    return self.entity_index.contains(entity);
}

///Returns true if the entity has no components
pub fn entityIsEmpty(
    self: *ComponentStore,
    entity: Entity,
) bool
{
    const entity_description = self.entity_index.get(entity).?;

    return entity_description.archetype_index == 0;
}

///Returns true if the entity has a component of type T
pub fn entityHasComponent(
    self: *ComponentStore, 
    entity: Entity, 
    comptime T: type,
) bool 
{
    const component_id = componentId(T);

    const entity_description = self.entity_index.get(entity).?;

    const component_archetypes = self.component_index.get(component_id) orelse return false;

    return component_archetypes.archetypes.contains(entity_description.archetype_index);
}

///Returns true if the entity has all components
pub fn entityHasComponents(
    self: *ComponentStore, 
    entity: Entity, 
    comptime components: anytype,
) bool 
{
    for (components) |Component|
    {
        if (!self.entityHasComponent(entity, Component))
        {
            return false;
        }
    } 

    return true;
}

///Returns the number of components bound to an entity
pub fn entityCount(
    self: *ComponentStore, 
    entity: Entity, 
) usize
{
    const entity_data = self.entity_index.get(entity).?;

    const archetype = &self.archetypes.items[entity_data.archetype_index];

    return archetype.component_ids.items.len;
}

///If the entity_a and entity_b are of the same archetype, returns true
pub fn entitiesAreIsomers(
    self: *ComponentStore,
    entity_a: Entity,
    entity_b: Entity,
) bool 
{
    const entity_a_data = self.entity_index.get(entity_a).?;
    const entity_b_data = self.entity_index.get(entity_b).?;

    return entity_a_data.archetype_index == entity_b_data.archetype_index;
}

///Return a list of Type information for each component on this entity
pub fn entityGetComponentTypes(
    self: *ComponentStore,
    entity: Entity,
) []const *const reflect.Type 
{
    const entity_data = self.entity_index.get(entity).?;

    const archetype: *Archetype = &self.archetypes.items[entity_data.archetype_index];

    return archetype.component_ids.items;
}

pub fn entityGetComponentPtr(
    self: *ComponentStore,
    entity: Entity,
    component_id: ComponentId,
) *anyopaque 
{
    const entity_description = self.entity_index.get(entity).?;
    const entity_archetype: Archetype = self.archetypes.items[entity_description.archetype_index];

    const component_archetypes = self.component_index.get(component_id) orelse unreachable;

    const archetype_record = component_archetypes.archetypes.get(entity_description.archetype_index) orelse unreachable;

    const column = entity_archetype.columns.items[archetype_record.column];

    return @ptrCast(*anyopaque, column.data.items.ptr + entity_description.row_index * column.element_size); 
}

///A query filter with the type T
pub fn FilterWith(comptime T: type) Filter 
{
    return .{ .with = T };
}

///A query filter without the type T
pub fn FilterWithout(comptime T: type) Filter
{
    return .{ .without = T };
}

///A query or filter 
pub fn FilterOr(comptime T: type, comptime U: type) Filter
{
    return .{ .@"or" = .{ T, U } };
}

///A filter for changed components of type T
pub fn FilterChanged(comptime T: type) Filter
{
    return .{ .changed = T };
}

pub const Filter = union(enum)
{
    with: type,
    without: type,
    @"or": struct { type, type },
    changed: type,
};

pub fn QueryIterator(comptime component_fetches: anytype, comptime filters: anytype) type 
{   
    comptime var component_fetches_slice: []const type = &.{};

    inline for (component_fetches) |component_fetch|
    {
        component_fetches_slice = component_fetches_slice ++ &[_]type { component_fetch };

        if (componentIsTag(component_fetch))
        {
            @compileError("Query cannot fetch a tag component!");
        }
    }

    comptime var required_component_slice: []const type = &(component_fetches_slice[0..].*);
    comptime var excluded_component_slice: []const type = &.{};

    inline for (filters) |filter|
    {
        switch (filter)
        {
            .with => |with_type| 
            {
                required_component_slice = required_component_slice ++ &[_]type { with_type };
            },
            .without => |without_type| 
            {
                excluded_component_slice = excluded_component_slice ++ &[_]type { without_type };
            },
            else => {},
        }
    }

    const required_components = std.meta.Tuple(required_component_slice);
    const excluded_component = std.meta.Tuple(excluded_component_slice);

    _ = excluded_component;

    return struct 
    {
        component_store: *const ComponentStore,
        archetype_index: ArchetypeIndex,
        row_index: u32,

        pub fn init(component_store: *const ComponentStore) @This()
        {
            return .{
                .component_store = component_store,
                .archetype_index = 1,
                .row_index = 0,
            };
        } 

        pub const Block = block: {
            comptime var fields: [required_component_slice.len + 1]std.builtin.Type.StructField = undefined; 

            fields[0] = .{
                .name = "entities",
                .type = []const Entity,
                .default_value = null,
                .is_comptime = false,
                .alignment = @alignOf([]const Entity),
            };

            for (required_component_slice, 1..) |component_type, i|
            {
                fields[i] = .{
                    .name = componentName(component_type),
                    .type = []component_type,
                    .default_value = null,
                    .is_comptime = false,
                    .alignment = @alignOf([]component_type),
                };
            }

            break: block @Type(.{ .Struct = 
            .{
                .layout = .Auto,
                .backing_integer = null,
                .fields = &fields,
                .decls = &.{},
                .is_tuple = false,
            }});
        };

        pub fn nextBlock(self: *@This()) ?Block 
        {
            if (self.archetype_index >= self.component_store.archetypes.items.len)
            {
                return null;
            }

            var archetype: *Archetype = &self.component_store.archetypes.items[self.archetype_index];

            while (
                !(
                    self.component_store.archetypeHasComponents(self.archetype_index, required_component_slice) and
                    !self.component_store.archetypeHasComponents(self.archetype_index, excluded_component_slice) and 
                    self.component_store.archetypes.items[self.archetype_index].row_count > 0
                )
            )
            {
                self.archetype_index += 1;
                self.row_index = 0;

                if (self.archetype_index >= self.component_store.archetypes.items.len)
                {
                    return null;
                }

                archetype = &self.component_store.archetypes.items[self.archetype_index];
            }

            var block: Block = undefined;

            block.entities = archetype.entities.items;

            inline for (component_fetches) |component_type|
            {
                const component_type_desc = self.component_store.component_index.get(componentId(component_type)).?;

                const archetype_record = component_type_desc.archetypes.get(self.archetype_index).?;

                const column: *Column = &archetype.columns.items[archetype_record.column];

                @field(block, componentName(component_type)) = @ptrCast([*]component_type, @alignCast(@alignOf(component_type), column.data.items.ptr))[0..archetype.row_count];
            }

            self.archetype_index += 1;

            return block;
        }

        pub fn next(self: *@This()) ?Entity 
        {
            var archetype = &self.component_store.archetypes.items[self.archetype_index];

            while (
                !(
                    self.component_store.archetypeHasComponents(self.archetype_index, required_components) and
                    self.row_index < archetype.row_count
                )
            )
            {
                self.archetype_index += 1;
                self.row_index = 0;

                if (self.archetype_index >= self.component_store.archetypes.items.len)
                {
                    return null;
                }

                archetype = &self.component_store.archetypes.items[self.archetype_index];
            }

            self.row_index +%= 1;

            return .{ .index = 0, .generation = 0, .flags = .{} }; 
        }

        pub fn getComponent(self: *@This(), comptime T: type) *T 
        {
            const component_id = componentId(T);

            const component_archetypes = self.component_store.component_index.get(component_id) orelse unreachable;

            const archetype = self.component_store.archetypes.items[self.archetype_index];

            const archetype_record = component_archetypes.archetypes.get(self.archetype_index) orelse unreachable;

            const column = archetype.columns.items[archetype_record.column];

            return column.getComponent(T, self.row_index - 1);
        }

        fn componentName(comptime T: type) []const u8
        {
            const full_type_name = @typeName(T);

            const index_of_name = std.mem.lastIndexOf(u8, full_type_name, &.{ '.' }).? + 1;

            return full_type_name[index_of_name..];
        }
    };
}

///Returns a query which can access all the components specified in component_fetches
pub fn query(
    self: *ComponentStore,
    comptime component_fetches: anytype,
    comptime component_filters: anytype,
) QueryIterator(component_fetches, component_filters) 
{
    return QueryIterator(component_fetches, component_filters).init(self);
}

pub fn foreach(
    self: *ComponentStore,
    comptime Fn: anytype,
) void 
{
    const args_types = std.meta.ArgsTuple(@TypeOf(Fn));

    comptime var args_type_fields = std.meta.fields(args_types);

    const ArgsType = @Type(.{ .Struct = .{ 
        .layout = .Auto,
        .is_tuple = true,
        .fields = args_type_fields,
        .decls = &[_]std.builtin.Type.Declaration {},
    }});

    comptime var component_types: [if (args_type_fields[0].type == Entity) args_type_fields.len - 1 else args_type_fields.len]type = undefined;

    comptime for (&component_types, args_type_fields[if (args_type_fields[0].type == Entity) 1 else 0..]) |*component_type, arg_type|
    {
        if (std.meta.trait.isSingleItemPtr(arg_type.type))
        {
            component_type.* = std.meta.Child(arg_type.type);
        }
        else 
        {
            component_type.* = arg_type.type;
        }
    };

    var foreach_query = self.query(component_types, .{});

    while (foreach_query.next()) |entity|
    {
        var args: ArgsType = undefined;

        if (args_type_fields[0].type == Entity)
        {
            args[0] = entity;
        }

        const arg_start = if (args_type_fields[0].type == Entity) 1 else 0;

        inline for (args_type_fields[arg_start..], arg_start..) |arg_type, i|
        {
            if (std.meta.trait.isSingleItemPtr(arg_type.type))
            {
                args[i] = foreach_query.getComponent(std.meta.Child(arg_type.type)); 
            }
            else 
            {
                args[i] = foreach_query.getComponent(arg_type.type).*;
            }
        }

        @call(.always_inline, Fn, args);
    }
}

///Returns an archetype with the components of the source archetype and the component specified by component_id 
fn addToArchetype(
    self: *ComponentStore,
    source_archetype_index: ArchetypeIndex,
    component_type: ComponentType,
) !ArchetypeIndex
{
    const component_id = component_type.id;

    std.debug.assert(source_archetype_index < self.archetypes.items.len);

    var source_archetype: *Archetype = &self.archetypes.items[source_archetype_index];

    if (source_archetype_index == 0)
    {
        std.debug.assert(source_archetype.component_ids.items.len == 0);   
    }

    const potential_source_edge = source_archetype.edges.get(component_id);

    if (
        potential_source_edge != null and 
        potential_source_edge.?.add != null
    )
    {
        return potential_source_edge.?.add.?;
    }

    //Find a suitable adjacent archetype
    const existing_archetype_index: ?ArchetypeIndex = block:
    { 
        for (self.archetypes.items[1..], 1..) |archetype, new_archetype_index|
        {
            // std.log.warn("component_to_add = {}", .{ component_id });
            // std.log.warn("source_archetypes = {any}", .{ source_archetype.component_ids.items });
            // std.log.warn("destination_archetypes = {any}", .{ archetype.component_ids.items });

            if (archetype.component_ids.items.len != source_archetype.component_ids.items.len + 1)
            {
                continue;
            }

            const common_length = std.math.min(archetype.component_ids.items.len, source_archetype.component_ids.items.len);

            const share_common_base = std.mem.eql(ComponentId, source_archetype.component_ids.items[0..common_length], archetype.component_ids.items[0..common_length]);

            if (!share_common_base)
            {
                continue;
            }

            if (archetype.component_ids.items[archetype.component_ids.items.len - 1] != component_id)
            {
                continue;
            }

            break: block @intCast(ArchetypeIndex, new_archetype_index);
        }   

        break: block null;     
    };

    if (existing_archetype_index != null) 
    {
        std.debug.assert(existing_archetype_index.? != 0); 
        std.debug.assert(false);

        const source_edge = try source_archetype.edges.getOrPutValue(self.allocator, component_id, .{
            .add = null,
            .remove = null,
        });

        const existing_archetype: *Archetype = &self.archetypes.items[existing_archetype_index.?];

        const destination_edge = try existing_archetype.edges.getOrPutValue(self.allocator, component_id, .{
            .add = null, 
            .remove = null,
        });

        source_edge.value_ptr.add = @intCast(u31, existing_archetype_index.?);
        destination_edge.value_ptr.remove = @intCast(u31, source_archetype_index);

        return existing_archetype_index.?;
    }

    const archetype_index = @intCast(ArchetypeIndex, self.archetypes.items.len);

    try self.archetypes.append(self.allocator, .{
        .component_ids = .{},
        .columns = .{},
        .edges = .{},
        .entities = .{},
        .row_count = 0,
    });

    source_archetype = &self.archetypes.items[source_archetype_index];

    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    try archetype.component_ids.ensureTotalCapacity(self.allocator, source_archetype.component_ids.items.len + 1);    

    try archetype.component_ids.appendSlice(self.allocator, source_archetype.component_ids.items);
    try archetype.component_ids.append(self.allocator, component_id);

    for (archetype.component_ids.items, 0..) |new_component_id, i|
    {
        const component_description = try self.component_index.getOrPutValue(self.allocator, new_component_id, .{});

        const archetype_record = try component_description.value_ptr.archetypes.getOrPut(self.allocator, archetype_index);

        archetype_record.value_ptr.column = @intCast(u32, i);
    }

    try archetype.columns.ensureTotalCapacity(self.allocator, source_archetype.columns.items.len + 1);

    for (source_archetype.columns.items) |source_column|
    {
        try archetype.columns.append(self.allocator, .{
            .data = .{},
            .element_size = source_column.element_size,
        });
    }

    try archetype.columns.append(self.allocator, .{
        .data = .{},
        .element_size = component_type.size,
    });

    const source_edge = try source_archetype.edges.getOrPutValue(self.allocator, component_id, .{
        .add = null,
        .remove = null,
    });

    const destination_edge = try archetype.edges.getOrPutValue(self.allocator, component_id, .{
        .add = null, 
        .remove = null,
    });

    source_edge.value_ptr.add = @intCast(u31, archetype_index);
    destination_edge.value_ptr.remove = @intCast(u31, source_archetype_index);

    return archetype_index;
}

///Returns an archetype with the components of the source archetype without the component specified by component_id 
fn removeFromArchetype(
    self: *ComponentStore,
    source_archetype_index: ArchetypeIndex,
    component_id: ComponentId,
) !ArchetypeIndex
{
    std.debug.assert(source_archetype_index != 0);

    var source_archetype: *Archetype = &self.archetypes.items[source_archetype_index];

    const potential_source_edge = source_archetype.edges.get(component_id);

    if (
        potential_source_edge != null and
        potential_source_edge.?.remove != null
    )
    {
        return potential_source_edge.?.remove.?;
    }

    const existing_archetype_index: ?ArchetypeIndex = block:
    { 
        for (self.archetypes.items[1..], 1..) |archetype, new_archetype_index|
        {
            if (archetype.component_ids.items.len != source_archetype.component_ids.items.len - 1)
            {
                continue;
            }

            const common_length = std.math.min(archetype.component_ids.items.len, source_archetype.component_ids.items.len);

            const share_common_base = std.mem.eql(ComponentId, source_archetype.component_ids.items[0..common_length], archetype.component_ids.items[0..common_length]);

            if (!share_common_base)
            {
                continue;
            }

            break: block @intCast(ArchetypeIndex, new_archetype_index);
        }   

        break: block null;     
    };

    if (existing_archetype_index != null)
    {
        const new_edge = try source_archetype.edges.getOrPutValue(self.allocator, component_id, .{ .add = null, .remove = null });

        new_edge.value_ptr.*.remove = @intCast(u31, existing_archetype_index.?);

        return existing_archetype_index.?;
    }

    unreachable;
}

///Removes the row at row_index from the source archetype and adds a row to dest archetype and moves it there  
///Returns an index to the new row
fn archetypeMoveRow(
    self: *ComponentStore,
    source_archetype_index: ArchetypeIndex,
    destination_archetype_index: ArchetypeIndex,
    source_row_index: usize,
    entity: Entity,
) !usize
{
    if (source_archetype_index == 0) 
    {
        return try self.archetypeAddRow(destination_archetype_index, entity);
    }

    const source_archetype: *Archetype = &self.archetypes.items[source_archetype_index];
    const destination_archetype: *Archetype = &self.archetypes.items[destination_archetype_index];

    const destination_row_index = try self.archetypeAddRow(destination_archetype_index, entity);

    const common_length = std.math.min(source_archetype.columns.items.len, destination_archetype.columns.items.len);

    for (
        source_archetype.columns.items[0..common_length], 
        destination_archetype.columns.items[0..common_length]
    ) |*source_column, *destination_column|
    {
        const dst_start = destination_column.element_size * destination_row_index;
        const dst = destination_column.data.items[dst_start .. dst_start + destination_column.element_size];

        const src_start = source_column.element_size * source_row_index;
        const src = source_column.data.items[src_start .. src_start + source_column.element_size];

        const src_end_start = source_column.data.items.len - source_column.element_size;
        const src_end = source_column.data.items[src_end_start .. src_end_start + source_column.element_size];

        std.mem.copy(u8, dst, src);
        std.mem.copy(u8, src, src_end);

        source_column.data.items.len -= source_column.element_size;
    }

    const entity_to_update = source_archetype.entities.items[source_archetype.entities.items.len - 1];

    _ = source_archetype.entities.swapRemove(source_row_index);

    const entity_to_update_description = self.entity_index.getPtr(entity_to_update).?;

    entity_to_update_description.row_index = @intCast(u32, source_row_index);

    source_archetype.row_count -= 1;

    return destination_row_index;
}

fn archetypeRemoveRow(
    self: *ComponentStore,
    archetype_index: ArchetypeIndex,
    row_index: usize,
) void
{
    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    if (archetype.row_count < 1) 
    {
        return;
    }

    for (archetype.columns.items) |*column|
    {
        const dst_start = column.element_size * row_index;
        const dst = column.data.items[dst_start .. dst_start + column.element_size];
        const src_start = column.data.items.len - column.element_size;
        const src = column.data.items[src_start .. src_start + column.element_size];

        std.mem.copy(u8, dst, src);

        column.data.items.len -= column.element_size;
    }

    const entity_to_update = archetype.entities.items[archetype.entities.items.len - 1];

    _ = archetype.entities.swapRemove(row_index);

    const entity_to_update_description = self.entity_index.getPtr(entity_to_update).?;

    entity_to_update_description.row_index = @intCast(u32, row_index);

    archetype.row_count -= 1;
}

fn archetypeAddRow(
    self: *ComponentStore,
    archetype_index: ArchetypeIndex,
    entity: ?Entity,
) !u32 
{
    std.debug.assert(archetype_index != 0);

    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    const row_index = archetype.row_count;

    archetype.row_count += 1;

    for (archetype.columns.items) |*column|
    {
        try column.data.appendNTimes(self.allocator, 0, column.element_size);
    }

    if (entity != null)
    {
        try archetype.entities.append(self.allocator, entity.?);
    }

    return row_index;
}

fn archetypeHasComponents(
    self: *const ComponentStore,
    archetype_index: ArchetypeIndex,
    comptime components: anytype,
) bool
{
    if (components.len == 0)
    {
        return false;
    }

    inline for (components) |Component|
    {
        if (!self.archetypeHasComponent(archetype_index, Component))
        {
            return false;
        }
    }

    return true;
}

fn archetypeHasComponent(
    self: *const ComponentStore,
    archetype_index: ArchetypeIndex,
    comptime Component: type,
) bool
{
    const component_description = self.component_index.getPtr(componentId(Component)) orelse return false;

    return component_description.archetypes.contains(archetype_index);
}

///Returns a unique ComponentId for the given type 
pub fn componentId(comptime T: type) ComponentId
{
    if (!(
        @typeInfo(T) == .Struct or
        @typeInfo(T) == .Enum or
        @typeInfo(T) == .Union
    ))
    {
        @compileError("T must be a struct, enum or union");
    }

    return reflect.Type.info(T);
} 

fn componentType(comptime T: type) ComponentType
{
    return .{
        .id = componentId(T),
        .size = @sizeOf(T),
        .alignment = @alignOf(T),
    };
}

fn componentIsTag(comptime T: type) bool
{
    return @sizeOf(T) == 0;
}

test 
{
    _ = std.testing.refAllDecls(@This());
}

test "Basic component store"
{
    var ecs_scene = try ComponentStore.init(std.testing.allocator);
    defer ecs_scene.deinit();

    const entity = try ecs_scene.entityCreate(.{});

    const PosComponent = struct 
    {
        x: f32,
        y: f32,
        z: f32,
    };

    const TagComponent = struct {};

    try ecs_scene.entityAddComponents(entity, .{
        PosComponent { .x = 0, .y = 10, .z = 0 },
        TagComponent,
    });

    try std.testing.expect(ecs_scene.entityHasComponent(entity, PosComponent));
    try std.testing.expect(ecs_scene.entityHasComponent(entity, TagComponent));

    const pos_component = ecs_scene.entityGetComponent(entity, PosComponent).?.*;

    try std.testing.expect(std.meta.eql(pos_component, PosComponent { .x = 0, .y = 10, .z = 0 }));

    try ecs_scene.entityRemoveComponent(entity, TagComponent);

    try std.testing.expect(!ecs_scene.entityHasComponent(entity, TagComponent));

    try ecs_scene.entityRemoveComponent(entity, PosComponent);

    try std.testing.expect(!ecs_scene.entityHasComponent(entity, TagComponent));
    try std.testing.expect(!ecs_scene.entityHasComponent(entity, PosComponent));

    try ecs_scene.entityAddComponents(entity, .{
        PosComponent { .x = 0, .y = 10, .z = 0 },
        TagComponent,
    });

    try std.testing.expect(ecs_scene.entityHasComponent(entity, PosComponent));
    try std.testing.expect(ecs_scene.entityHasComponent(entity, TagComponent));

    ecs_scene.entityDestroy(entity);

    try std.testing.expect(!ecs_scene.entityExists(entity));

    try std.testing.expect(try ecs_scene.entityCreate(.{}) != entity);
}

test "Queries"
{
    var ecs_scene = try ComponentStore.init(std.testing.allocator);
    defer ecs_scene.deinit();

    const test_entity = try ecs_scene.entityCreate(.{});

    const Position = struct 
    {
        x: f32,
        y: f32,
        z: f32,
    };

    const Rotation = struct 
    {
        x: f32 = 0,
        y: f32 = 0,
        z: f32 = 0,
    };

    const EnumComponent = enum
    {
        one,
        two,
        three,
    };

    const UnionComponent = union(enum) 
    {
        one: Position,
        two: Rotation,
        three
    };

    //Zero-size struct component that won't have storage
    const Tag = struct {};

    try ecs_scene.entityAddComponents(test_entity, .{
        Position { .x = 0, .y = 10, .z = 0 },
        EnumComponent.one,
        UnionComponent { .one = .{ .x = 0, .y = 0, .z = 0 } },
        Tag,
        Rotation { .x = 0, .y = 900, .z = 0 },
    });

    std.log.warn("test_entity.count = {}", .{ ecs_scene.entityCount(test_entity) });

    const test_entity_2 = try ecs_scene.entityCreate(.{ Position { .x = 10, .y = 69, .z = 420 } });

    try ecs_scene.entityAddComponent(test_entity_2, Rotation { .x = 0, .y = 0, .z = 0 });
    try ecs_scene.entityAddComponent(test_entity_2, EnumComponent.one);

    try std.testing.expect(ecs_scene.entityHasComponent(test_entity_2, Position));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity_2, Rotation));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity_2, EnumComponent));

    _ = try ecs_scene.entityCreate(.{ Position { .x = 10, .y = 69, .z = 420 } });
    _ = try ecs_scene.entityCreate(.{ Tag, Position { .x = 10, .y = 69, .z = 420 } });
    _ = try ecs_scene.entityCreate(.{ Position { .x = 10, .y = 69, .z = 420 * 2 }, Rotation { .x = 200, .y = 200, .z = 9 } });
    _ = try ecs_scene.entityCreate(.{ Tag, Position { .x = 10, .y = 69 / 2, .z = 420 }, Rotation { .x = 0, .y = 10003, .z = 20 } });
    _ = try ecs_scene.entityCreate(.{ Tag, Position { .x = 10, .y = 69 / 2, .z = 420 }, Rotation { .x = 0, .y = 10003, .z = 20 } });

    //Example of a query:
    //Create a query for all entities with PosComponent but must have TagComponent
    var pos_query = ecs_scene.query(.{ Position, Rotation }, .{ FilterWith(Tag) });

    while (pos_query.nextBlock()) |block|
    {
        std.log.warn("New block", .{});

        const entities: []const Entity = block.entities;
        const pos_components: []const Position = block.Position;
        const rot_components: []const Rotation = block.Rotation;

        for (entities, pos_components, rot_components) |entity, pos, rot|
        {
            std.log.warn("entity({}):", .{ entity });
            std.log.warn("pos = {any}", .{ pos });
            std.log.warn("rot = {any}", .{ rot });
        }
    }

    try std.testing.expect(ecs_scene.entityHasComponent(test_entity, Position));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity, EnumComponent));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity, UnionComponent));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity, Tag));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity, Rotation));
}

test "Reflection"
{
    var ecs_scene = try ComponentStore.init(std.testing.allocator);
    defer ecs_scene.deinit();

    const Position = struct 
    {
        x: f32 = 0,
        y: f32 = 0,
        z: f32 = 0,
    };

    const Rotation = struct 
    {
        x: f32 = 0,
        y: f32 = 0,
        z: f32 = 0,
    };

    const entity = try ecs_scene.entityCreate(.{
        Position {},
        Rotation {},
    });       

    for (ecs_scene.entityGetComponentTypes(entity)) |type_info|
    {
        if (type_info.is(Rotation))
        {
            std.log.warn("We FOUND A ROTATION COMPONENT TYPE!!!", .{});
        }

        std.log.warn("type_info.fields = {any}", .{ type_info.*.Struct.fields });
        std.log.warn("type_info.fields[0].name = {s}", .{ type_info.*.Struct.fields[0].name });
        std.log.warn("type_info.fields[1].name = {s}", .{ type_info.*.Struct.fields[1].name });
    }
}