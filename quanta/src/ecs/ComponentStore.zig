const std = @import("std");

const ComponentStore = @This(); 

///Associated flags as part of the entity
pub const EntityFlags = packed struct(u16)
{
    enabled: bool = false,
    padding: u15 = 0,
};

///Unique identifier which describes an entity
pub const Entity = packed struct(u64) 
{
    index: u32,
    generation: u16,
    flags: EntityFlags,
};

///Unique identifier for a component type
pub const ComponentId = enum(u64) { _ };

pub const ComponentType = struct 
{
    id: ComponentId,
    size: usize,
    alignment: usize,
};

pub const Column = struct 
{
    data: std.ArrayListUnmanaged(u8) = .{},

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
            return undefined;
        }

        const byte_offset = index * @sizeOf(T);

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
    });

    return self;
}

pub fn deinit(self: *ComponentStore) void 
{
    self.archetypes.deinit(self.allocator);
    self.entity_index.deinit(self.allocator);
    self.component_index.deinit(self.allocator);

    self.* = undefined;
}

pub fn entityCreate(self: *ComponentStore, components: anytype) !Entity
{
    var entity = Entity 
    { 
        .index = self.next_entity_index, 
        .generation = self.next_entity_generation,
        .flags = .{},
    };

    try self.entity_index.put(self.allocator, entity, .{
        .archetype_index = 0,
        .row_index = 0,
    });

    self.next_entity_index += 1;

    if (std.meta.fields(@TypeOf(components)).len > 0)
    {
        self.entityAddComponents(entity, components);
    }

    return entity;
}

pub fn entityDestroy(self: *ComponentStore, entity: Entity) void
{
    _ = self.entity_index.swapRemove(entity);

    self.next_entity_generation +%= 1;
}

pub fn entityAddComponent(
    self: *ComponentStore,
    entity: Entity,
    component: anytype,
) !void 
{
    const T = @TypeOf(component);
    const component_id = componentId(T);

    const entity_description = self.entity_index.getPtr(entity).?;

    const source_archetype_index = entity_description.archetype_index;
    const source_archetype = &self.archetypes.items[source_archetype_index];

    _ = source_archetype;

    const archetype_index = try self.addToArchetype(source_archetype_index, component_id);

    std.log.info("orig_archetype + component = {}", .{ archetype_index });

    entity_description.archetype_index = archetype_index;

    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    const component_description = self.component_index.get(component_id).?;

    const archetype_record = component_description.archetypes.get(archetype_index).?;

    if (@sizeOf(T) == 0)
    {
        return;
    }

    entity_description.row_index = @intCast(u32, archetype.columns.items[archetype_record.column].data.items.len / @sizeOf(T));

    _ = try archetype.columns.items[archetype_record.column].addComponent(self.allocator, T, component); 
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

pub const entityRemoveComponent = @compileError("Not Implemented");

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
    return entityGetComponent(self, entity, T) != null;
}

///Returns a query which can access all the components specified in component_types
pub fn query(
    self: *ComponentStore,
    component_types: anytype,
) void 
{
    _ = self;
    _ = component_types;
}

///Returns an archetype with the components of the source archetype and the component specified by component_id 
fn addToArchetype(
    self: *ComponentStore,
    source_archetype_index: ArchetypeIndex,
    component_id: ComponentId,
) !ArchetypeIndex
{
    const source_archetype: *Archetype = &self.archetypes.items[source_archetype_index];

    const potential_source_edge = source_archetype.edges.get(component_id);

    if (
        potential_source_edge != null and 
        potential_source_edge.?.add != null
    )
    {
        return potential_source_edge.?.add.?;
    }

    const archetype_index = @intCast(ArchetypeIndex, self.archetypes.items.len);

    try self.archetypes.append(self.allocator, .{
        .component_ids = .{},
        .columns = .{},
        .edges = .{},
    });

    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    const component_description = try self.component_index.getOrPutValue(self.allocator, component_id, .{});

    const archetype_record = try component_description.value_ptr.archetypes.getOrPutValue(self.allocator, archetype_index, .{ .column = 0 });

    archetype_record.value_ptr.column = @intCast(u32, source_archetype.columns.items.len);

    try archetype.component_ids.ensureTotalCapacity(self.allocator, source_archetype.component_ids.items.len + 1);    

    try archetype.component_ids.appendSlice(self.allocator, source_archetype.component_ids.items);
    try archetype.component_ids.append(self.allocator, component_id);

    try archetype.columns.appendNTimes(self.allocator, .{}, source_archetype.columns.items.len + 1);

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
    _ = self;
    _ = source_archetype_index;
    _ = component_id;
}

///Returns a unique ComponentId for the given type 
fn componentId(comptime T: type) ComponentId
{
    return @intToEnum(ComponentId, typeId(T));
} 

///Returns a unique integer id for the given type
fn typeId(comptime T: type) usize
{
    _ = T;

    const Tag = struct 
    {
        var name: u8 = 0;
    };

    return @ptrToInt(&Tag.name);
}