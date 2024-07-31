const std = @import("std");
const reflect = @import("../reflect/reflect.zig");

const ComponentStore = @This();

///Associated flags as part of the entity
const EntityFlags = packed struct(u16) {
    enabled: bool = false,
    padding: u15 = 0,
};

///Unique identifier which describes an entity
const EntityData = packed struct(u64) {
    index: u32,
    generation: u16,
    flags: EntityFlags,

    pub fn toHandle(self: EntityData) Entity {
        return @as(Entity, @enumFromInt(@as(u64, @bitCast(self))));
    }

    pub fn fromHandle(entity: Entity) EntityData {
        return @as(EntityData, @bitCast(@intFromEnum(entity)));
    }
};

///Unique identifier which describes an entity
pub const Entity = enum(u64) {
    _,

    ///Nil entity is an entity handle which is always invalid
    pub const nil = @as(Entity, @enumFromInt(std.math.maxInt(u64)));
};

///Unique identifier for a component type
pub const ComponentId = *const reflect.Type;

pub const ComponentType = struct {
    id: ComponentId,
    size: u32,
    alignment: u32,

    pub fn fromTypeInfo(type_info: *const reflect.Type) ComponentType {
        return .{
            .id = type_info,
            .size = @as(u32, @intCast(type_info.size())),
            .alignment = @as(u32, @intCast(type_info.alignment())),
        };
    }
};

pub const ChunkOffset = u16;

pub const Chunk = struct {
    ///The alignment of the chunk block in memory
    ///Always Aligned on cache line boundaries
    ///Always aligned on a multiple of @alignOf(Entity)
    pub const alignment: usize = 64;

    ///The maximum size of a chunk
    ///Always a multiple of a cache line
    pub const max_size: usize = 16 * 1024;

    ///Valid dynamic logarithmic sizes for chunks
    pub const Size = enum(u8) {
        @"64b",
        @"128b",
        @"256b",
        @"512b",
        @"1kb",
        @"2kb",
        @"4kb",
        @"8kb",
        @"16kb",
        @"32kb",
        @"64kb",

        pub inline fn toSize(self: Size) usize {
            return @as(usize, 64) << @as(u6, @intCast(@intFromEnum(self)));
        }

        pub inline fn fromSize(size: usize) Size {
            return @as(Size, @enumFromInt((@bitSizeOf(usize) - @clz(size / 64) - 1)));
        }
    };

    ///The maximum possible address space for a chunk is 65kb approx
    pub const Address = u16;

    pub const RowIndex = u16;

    //Ensures that max_size is a multiple of alignment
    comptime {
        std.debug.assert(@rem(max_size, alignment) == 0);
        std.debug.assert(@rem(alignment, @alignOf(Entity)) == 0);

        std.debug.assert(Size.@"64b".toSize() == 64);
        std.debug.assert(Size.@"16kb".toSize() == 16 * 1024);
        std.debug.assert(Size.fromSize(1024).toSize() == 1024);
        std.debug.assert(Size.fromSize(1024 * 2).toSize() == 1024 * 2);
        std.debug.assert(Size.fromSize(1024 * 4).toSize() == 1024 * 4);
        std.debug.assert(Size.fromSize(1024 * 8).toSize() == 1024 * 8);
        std.debug.assert(Size.fromSize(1024 * 16).toSize() == 1024 * 16);

        _ = Size;
    }

    data: ?[]u8 align(alignment),
    columns: []ChunkColumn,
    row_count: RowIndex,
    max_row_count: RowIndex,

    ///Entity ids are stored at the beginning of the chunk
    inline fn entities(self: Chunk) []Entity {
        return @as([*]Entity, @ptrCast(@alignCast(self.data.?.ptr)))[0..self.row_count];
    }

    inline fn getComponents(self: Chunk, comptime T: type, offset: usize) []T {
        return @as([*]T, @ptrCast(@alignCast(self.data.?.ptr + offset)))[0..self.row_count];
    }
};

pub const ChunkColumn = struct {
    offset: ChunkOffset,
    element_size: u16,
    element_alignment: u16,
};

///Standard allocator for allocating new chunks quickly
pub const ChunkPool = struct {
    pub const FreeList = struct {
        offset: u16 = 0,
        count: u16 = 0,
        max_count: u16 = 0,
    };

    free_lists: [std.enums.values(Chunk.Size).len]FreeList,
    chunk_ptrs: [][*]u8 align(Chunk.alignment),

    ///Creates a new query pool, limiting the number of stored free chunks in each free list
    ///To max_free_chunks
    pub fn init(allocator: std.mem.Allocator, max_free_chunks: usize) !ChunkPool {
        var pool = ChunkPool{
            .free_lists = std.mem.zeroes([11]ChunkPool.FreeList),
            .chunk_ptrs = &.{},
        };

        var chunk_ptr_count: usize = 0;

        for (&pool.free_lists, 0..) |*free_list, i| {
            const size = @as(Chunk.Size, @enumFromInt(i));

            _ = size;

            free_list.offset = @as(u16, @intCast(chunk_ptr_count));
            free_list.count = 0;
            free_list.max_count = @as(u16, @intCast(max_free_chunks));

            chunk_ptr_count += max_free_chunks;
        }

        pool.chunk_ptrs = try allocator.alloc([*]u8, chunk_ptr_count);
        errdefer allocator.free(pool.chunk_ptrs);

        return pool;
    }

    pub fn deinit(self: ChunkPool, allocator: std.mem.Allocator) void {
        allocator.free(self.chunk_ptrs);
    }

    pub fn alloc(self: *ChunkPool, size: Chunk.Size) ![]u8 {
        const free_list_index = @intFromEnum(size);
        const free_list = &self.free_lists[free_list_index];

        if (free_list.count == 0) {
            const chunk_data = try std.heap.page_allocator.alignedAlloc(u8, Chunk.alignment, size.toSize());

            return chunk_data;
        }

        const free_chunks = self.chunk_ptrs[free_list.offset .. free_list.offset + free_list.count];

        const chunk_data = free_chunks[free_chunks.len - 1];

        free_list.count -= 1;

        return chunk_data[0..size.toSize()];
    }

    pub fn free(self: *ChunkPool, ptr: [*]u8, size: Chunk.Size) void {
        const free_list_index = @intFromEnum(size);
        const free_list = &self.free_lists[free_list_index];

        if (free_list.count == free_list.max_count) {
            std.heap.page_allocator.free(ptr[0..size.toSize()]);

            return;
        }

        const free_chunks = self.chunk_ptrs[free_list.offset .. free_list.offset + free_list.count + 1];

        free_chunks[free_chunks.len - 1] = ptr;

        free_list.count += 1;
    }
};

pub const ArchetypeId = packed struct(u32) {
    id: u32,
};

pub const ArchetypeIndex = u32;

pub const max_archetype_count = std.math.maxInt(ArchetypeIndex);

pub const ChunkIndex = u16;

pub const max_chunk_count = std.math.maxInt(ChunkIndex);

///Stores the data for components on entities with the same component permutation
pub const Archetype = struct {
    pub const Edge = struct {
        add: ?u31,
        remove: ?u31,
    };

    component_ids: std.ArrayListUnmanaged(ComponentId) = .{},
    edges: std.AutoHashMapUnmanaged(ComponentId, Edge) = .{},
    chunks: std.ArrayListUnmanaged(Chunk) = .{},
    next_free_chunk_index: ChunkIndex = 0,
    entity_count: u32 = 0,
};

pub const EntityDescription = packed struct(u64) {
    archetype_index: ArchetypeIndex,
    row: RowLocation,
};

pub const ArchetypeRecord = struct {
    ///The column where the associated component type exists
    column: u32,
};

pub const ComponentTypeDescription = struct {
    archetypes: std.AutoArrayHashMapUnmanaged(ArchetypeIndex, ArchetypeRecord) = .{},
};

pub const ChunkLocation = packed struct(u32) {
    ///Index into the store's list of archetypes
    archetype_index: u16,
    ///Index into archetype's chunk list
    chunk_index: u16,
};

///Data structure for tracking changes to the store
pub const Changes = struct {
    ///List of chunks that were added
    added_chunks: std.ArrayListUnmanaged(ChunkLocation) = .{},
    added_archetypes: bool = false,
    removed_chunks: bool = false,

    pub fn reset(self: *@This()) void {
        self.added_chunks.clearRetainingCapacity();
        self.added_archetypes = false;
        self.removed_chunks = false;
    }
};

///Defines a unique mapping of entiy ids to storage locations
///Allows random access of stable entity ids
const EntityMap = struct {
    ///Number of entities per entity description chunk
    pub const chunk_size: usize = 1 * 1024;

    chunks: std.SegmentedList(*[chunk_size]EntityDescription, 16) = .{},
    entity_count: u32 = 0,
    next_entity_index: u32 = 0,
    next_entity_generation: u16 = 0,

    comptime {
        std.debug.assert(@rem(@sizeOf([chunk_size]EntityDescription), std.mem.page_size) == 0);
    }

    pub fn deinit(self: *EntityMap, allocator: std.mem.Allocator) void {
        var iterator = self.chunks.iterator(0);

        while (iterator.next()) |chunk| {
            std.heap.page_allocator.destroy(chunk.*);
        }

        self.chunks.deinit(allocator);
    }

    pub fn createChunk(self: *EntityMap, allocator: std.mem.Allocator) !*[chunk_size]EntityDescription {
        //Need to create a zero page
        const chunk = try std.heap.page_allocator.create([chunk_size]EntityDescription);
        errdefer std.heap.page_allocator.destroy(chunk);

        try self.chunks.append(allocator, chunk);

        return chunk;
    }

    pub fn getFreeChunk(self: *EntityMap, allocator: std.mem.Allocator) !*[chunk_size]EntityDescription {
        const chunk_index = @divTrunc(self.entity_count, chunk_size);

        if (chunk_index >= self.chunks.len) {
            _ = try self.createChunk(allocator);
        }

        return self.chunks.at(chunk_index).*;
    }

    pub fn mapEntity(self: *EntityMap, allocator: std.mem.Allocator, entity: Entity) !*EntityDescription {
        self.entity_count += 1;

        //TODO: lazily create chunks for new empty entities
        const chunk = try self.getFreeChunk(allocator);
        _ = chunk;

        return self.getUnchecked(entity);
    }

    pub fn addEntity(self: *EntityMap, allocator: std.mem.Allocator) !Entity {
        var entity = EntityData{
            .index = self.next_entity_index,
            .generation = self.next_entity_generation,
            .flags = .{},
        };

        const description = try self.mapEntity(allocator, entity.toHandle());

        description.archetype_index = 0;
        description.row = .{};

        self.next_entity_index += 1;

        return entity.toHandle();
    }

    pub fn removeEntity(self: *EntityMap, entity: Entity) void {
        const entity_description = self.getUnchecked(entity);

        entity_description.archetype_index = std.math.maxInt(ArchetypeIndex);
        entity_description.row = .{};

        self.next_entity_generation +%= 1;
    }

    pub inline fn contains(self: *EntityMap, entity: Entity) bool {
        const entity_data = EntityData.fromHandle(entity);

        return entity_data.index < self.entity_count and
            self.getUnchecked(entity).archetype_index != std.math.maxInt(ArchetypeIndex);
    }

    ///Returns null if the entity doesn't exist
    pub fn get(self: *EntityMap, entity: Entity) ?*EntityDescription {
        if (!self.contains(entity)) {
            return null;
        }

        return self.getUnchecked(entity);
    }

    pub fn getUnchecked(self: *EntityMap, entity: Entity) *EntityDescription {
        const entity_data = EntityData.fromHandle(entity);

        const index = entity_data.index;

        const chunk_index = @divTrunc(index, chunk_size);

        const chunk_begin = chunk_index * chunk_size;

        const offset = index - chunk_begin;

        const chunk = self.chunks.at(chunk_index).*;

        return &chunk[offset];
    }
};

allocator: std.mem.Allocator,
changes: Changes,
archetypes: std.ArrayListUnmanaged(Archetype),
chunk_pool: ChunkPool,
entity_map: EntityMap,
component_index: std.AutoArrayHashMapUnmanaged(ComponentId, ComponentTypeDescription),
resource_index: std.AutoArrayHashMapUnmanaged(ComponentId, ResourceDescription),
resource_data: std.ArrayListUnmanaged(u8),

pub const ResourceDescription = struct {
    offset: u32,
    size: u32,
};

pub fn init(allocator: std.mem.Allocator) !ComponentStore {
    var self = ComponentStore{
        .allocator = allocator,
        .archetypes = .{},
        .changes = .{},
        .entity_map = .{},
        .component_index = .{},
        .chunk_pool = try ChunkPool.init(allocator, 4),
        .resource_index = .{},
        .resource_data = .{},
    };

    try self.archetypes.append(self.allocator, .{
        .component_ids = .{},
        .edges = .{},
    });

    return self;
}

pub fn deinit(self: *ComponentStore) void {
    for (self.archetypes.items[0..], 0..) |*archetype, index| {
        archetype.edges.deinit(self.allocator);

        if (index == 0) continue;

        archetype.component_ids.deinit(self.allocator);

        for (0..archetype.chunks.items.len) |i| {
            self.archetypeFreeChunk(@as(u32, @intCast(index)), @as(u16, @intCast(i)));
        }

        archetype.chunks.deinit(self.allocator);
    }

    for (self.component_index.values()) |*component_type_desc| {
        component_type_desc.archetypes.deinit(self.allocator);
    }

    self.archetypes.deinit(self.allocator);
    self.chunk_pool.deinit(self.allocator);
    self.entity_map.deinit(self.allocator);
    self.component_index.deinit(self.allocator);
    self.changes.added_chunks.deinit(self.allocator);

    self.* = undefined;
}

pub fn beginQueryWindow(self: *ComponentStore) void {
    _ = self;
}

pub fn endQueryWindow(self: *ComponentStore) void {
    self.changes.reset();
}

pub fn setResource(self: *ComponentStore, resource: anytype) void {
    const T = @TypeOf(resource);

    const resource_description = try self.resource_index.getOrPutValue(self.allocator, componentId(T), .{ .offset = @as(u32, @intCast(self.resource_data.items.len)), .size = @sizeOf(T) });

    if (!resource_description.found_existing) {
        try self.resource_data.appendSlice(self.allocator, std.mem.asBytes(&resource));
    }

    unreachable;
}

pub fn getResource(self: ComponentStore, comptime T: type) *T {
    const resource_description = self.resource_index.get(componentId(T)) orelse unreachable;

    const pointer = self.resource_data.items.ptr + resource_description.offset;

    return @as(*T, @ptrCast(@alignCast(pointer)));
}

///Creates a new entity handle adds components to it.
///The returned entity handle is guaranteed to be new and unique
pub fn entityCreate(self: *ComponentStore, components: anytype) !Entity {
    const entity = try self.entity_map.addEntity(self.allocator);

    if (std.meta.fields(@TypeOf(components)).len > 0) {
        try self.entityAddComponents(entity, components);
    }

    return entity;
}

///Removes all components on an entity and invalidates the entity handle
pub fn entityDestroy(self: *ComponentStore, entity: Entity) void {
    self.entityClear(entity);

    self.entity_map.removeEntity(entity);
}

///Creates a new entity with identical components to entity
pub fn entityClone(self: *ComponentStore, src_entity: Entity) !Entity {
    const dst_entity = try self.entityCreate(.{});
    errdefer self.entityDestroy(dst_entity);

    const src_entity_desc = self.entity_map.get(src_entity) orelse unreachable;
    const dest_entity_desc = self.entity_map.get(dst_entity) orelse unreachable;

    const row = try self.archetypeAddRow(src_entity_desc.archetype_index, dst_entity);

    try self.archetypeCopyRow(
        src_entity_desc.archetype_index,
        src_entity_desc.row,
        row,
    );

    dest_entity_desc.archetype_index = src_entity_desc.archetype_index;
    dest_entity_desc.row = row;

    return dst_entity;
}

///Removes all components on an entity, returning it to the empty state
pub fn entityClear(self: *ComponentStore, entity: Entity) void {
    const entity_description = self.entity_map.get(entity).?;

    self.archetypeRemoveRow(entity_description.archetype_index, entity_description.row);

    entity_description.archetype_index = 0;
    entity_description.row = .{};
}

comptime {
    std.debug.assert(isComponentSet(f32) == false);
}

pub fn entityAddComponent(
    self: *ComponentStore,
    entity: Entity,
    component: anytype,
) !void {
    if (@TypeOf(component) == type and @sizeOf(component) != 0) {
        @compileError("Non-zero size component types must be initialized with a value!");
    }

    const T = if (@TypeOf(component) == type) component else @TypeOf(component);

    const component_type = componentType(T);

    const entity_description = self.entity_map.get(entity).?;

    const source_archetype_index = entity_description.archetype_index;

    const archetype_index = try self.addToArchetype(source_archetype_index, component_type);

    std.debug.assert(archetype_index != source_archetype_index);
    std.debug.assert(self.archetypeHasComponent(archetype_index, T));

    const row = try self.archetypeMoveRow(
        source_archetype_index,
        archetype_index,
        entity_description.row,
        entity,
    );

    entity_description.archetype_index = archetype_index;
    entity_description.row = row;

    if (@sizeOf(T) == 0) {
        return;
    }

    self.entitySetComponent(entity, component);
}

pub fn entityAddComponents(
    self: *ComponentStore,
    entity: Entity,
    components: anytype,
) !void {
    inline for (std.meta.fields(@TypeOf(components))) |component_field| {
        if (comptime isComponentSet(component_field.type)) {
            inline for (std.meta.fields(component_field.type)) |component_field_2| {
                if (component_field_2.type == IsComponentSet) continue;

                try self.entityAddComponent(entity, @field(@field(components, component_field.name), component_field_2.name));
            }
        } else {
            try self.entityAddComponent(entity, @field(components, component_field.name));
        }
    }
}

pub fn entityRemoveComponent(
    self: *ComponentStore,
    entity: Entity,
    comptime Component: type,
) !void {
    if (isComponentSet(Component)) {
        // @compileError("We don't yet support component sets");
    }

    //Doesn't seem to work when using componentId(Component) instead of this, why?
    //I suspect it might be an issue with the compiler and compile time function memoisation but I have no clue
    const component_type = componentType(Component);

    return try self.entityRemoveComponentId(entity, component_type.id);
}

pub fn entityRemoveComponentId(
    self: *ComponentStore,
    entity: Entity,
    component_id: ComponentId,
) !void {
    const entity_description = self.entity_map.get(entity).?;

    const source_archetype_index = entity_description.archetype_index;

    const archetype_index = try self.removeFromArchetype(source_archetype_index, component_id);

    entity_description.archetype_index = archetype_index;

    std.debug.assert(archetype_index != source_archetype_index);

    if (archetype_index == 0) {
        entity_description.row = .{};

        return;
    }

    entity_description.row = try self.archetypeMoveRow(source_archetype_index, archetype_index, entity_description.row, entity);
}

pub fn entitySetComponent(
    self: *ComponentStore,
    entity: Entity,
    component: anytype,
) void {
    const T = @TypeOf(component);

    self.entityGetComponent(entity, T).?.* = component;
}

///Returns a pointer to the component of type T if present, otherwise returns null
pub fn entityGetComponent(
    self: *ComponentStore,
    entity: Entity,
    comptime T: type,
) ?*T {
    if (comptime isComponentSet(T)) {
        // @compileError("We don't yet support component sets");
    }

    const component_id = componentId(T);

    const entity_description = self.entity_map.get(entity) orelse return null;
    const entity_archetype: *const Archetype = &self.archetypes.items[entity_description.archetype_index];
    const entity_chunk: *const Chunk = &entity_archetype.chunks.items[entity_description.row.chunk_index];

    std.debug.assert(entity_chunk.data != null);

    const component_archetypes = self.component_index.get(component_id) orelse return null;

    const archetype_record = component_archetypes.archetypes.get(entity_description.archetype_index) orelse return null;

    const column = entity_chunk.columns[archetype_record.column];

    return &entity_chunk.getComponents(T, column.offset)[entity_description.row.row_index];
}

///Returns true if the entity exists in the ComponentStore
pub fn entityExists(
    self: *ComponentStore,
    entity: Entity,
) bool {
    return self.entity_map.contains(entity);
}

///Returns true if the entity has no components
pub fn entityIsEmpty(
    self: *ComponentStore,
    entity: Entity,
) bool {
    const entity_description = self.entity_map.get(entity).?;

    return entity_description.archetype_index == 0;
}

///Returns true if the entity has a component of type T
pub fn entityHasComponent(
    self: *ComponentStore,
    entity: Entity,
    comptime T: type,
) bool {
    const component_id = componentId(T);

    const entity_description = self.entity_map.get(entity).?;

    const component_archetypes = self.component_index.get(component_id) orelse return false;

    return component_archetypes.archetypes.contains(entity_description.archetype_index);
}

///Returns true if the entity has all components
pub fn entityHasComponents(
    self: *ComponentStore,
    entity: Entity,
    comptime components: anytype,
) bool {
    for (components) |Component| {
        if (!self.entityHasComponent(entity, Component)) {
            return false;
        }
    }

    return true;
}

///Returns the number of components bound to an entity
pub fn entityCount(
    self: *ComponentStore,
    entity: Entity,
) usize {
    const entity_data = self.entity_map.get(entity).?;

    const archetype = &self.archetypes.items[entity_data.archetype_index];

    return archetype.component_ids.items.len;
}

///If the entity_a and entity_b are of the same archetype, returns true
pub fn entitiesAreIsomers(
    self: *ComponentStore,
    entity_a: Entity,
    entity_b: Entity,
) bool {
    const entity_a_data = self.entity_map.get(entity_a).?;
    const entity_b_data = self.entity_map.get(entity_b).?;

    return entity_a_data.archetype_index == entity_b_data.archetype_index;
}

///Return a list of Type information for each component on this entity
pub fn entityGetComponentTypes(
    self: *ComponentStore,
    entity: Entity,
) []const *const reflect.Type {
    const entity_data = self.entity_map.get(entity).?;

    const archetype: *Archetype = &self.archetypes.items[entity_data.archetype_index];

    return archetype.component_ids.items;
}

pub fn entityGetComponentPtr(
    self: *ComponentStore,
    entity: Entity,
    component_id: ComponentId,
) *anyopaque {
    const entity_description = self.entity_map.get(entity).?;
    const entity_archetype: *const Archetype = &self.archetypes.items[entity_description.archetype_index];
    const entity_chunk: *const Chunk = &entity_archetype.chunks.items[entity_description.row.chunk_index];

    const component_archetypes = self.component_index.get(component_id) orelse unreachable;

    const archetype_record = component_archetypes.archetypes.get(entity_description.archetype_index) orelse unreachable;

    const column = entity_chunk.columns[archetype_record.column];

    return @as(*anyopaque, @ptrCast(entity_chunk.data.?.ptr + column.offset + entity_description.row.row_index * column.element_size));
}

pub fn filterWith(comptime T: type) Filter {
    return .{ .with = T };
}

pub fn filterWithout(comptime T: type) Filter {
    return .{ .without = T };
}

pub fn filterOr(comptime T: type, comptime U: type) Filter {
    return .{ .@"or" = .{ T, U } };
}

pub fn filterAnd(comptime T: type, comptime U: type) Filter {
    return .{ .@"and" = .{ T, U } };
}

pub const Filter = union(enum) {
    with: type,
    without: type,
    @"or": struct { type, type },
    @"and": struct { type, type },
};

pub fn QueryIterator(comptime component_fetches: anytype, comptime filters: anytype) type {
    comptime var component_fetches_slice: []const type = &.{};
    comptime var components_optional: []const type = &.{};

    inline for (component_fetches) |component_fetch| {
        const component_Fetch_info = @typeInfo(component_fetch);

        switch (component_Fetch_info) {
            .Optional => {
                components_optional = components_optional ++ &[_]type{std.meta.Child(component_fetch)};
            },
            else => {
                component_fetches_slice = component_fetches_slice ++ &[_]type{component_fetch};
            },
        }
        if (componentIsTag(component_fetch)) {
            @compileError("Query cannot fetch a tag component!");
        }
    }

    comptime var required_component_slice_var: []const type = &(component_fetches_slice[0..].*);
    comptime var excluded_component_slice_var: []const type = &.{};

    inline for (filters) |filter| {
        if (@TypeOf(filter) != @TypeOf(.enum_literal)) {
            required_component_slice_var = required_component_slice_var ++ &[_]type{filter};
        } else {
            switch (filter) {
                .with => |with_type| {
                    required_component_slice_var = required_component_slice_var ++ &[_]type{with_type};
                },
                .without => |without_type| {
                    excluded_component_slice_var = excluded_component_slice_var ++ &[_]type{without_type};
                },
                else => {},
            }
        }
    }

    const required_component_slice = required_component_slice_var[0..].*;
    const excluded_component_slice = excluded_component_slice_var[0..].*;

    return struct {
        component_store: *const ComponentStore,
        archetype_index: ArchetypeIndex,
        chunk_index: ChunkIndex,
        blocks: std.ArrayListUnmanaged(CachedBlock),

        pub fn init(component_store: *const ComponentStore) @This() {
            const self = @This(){
                .component_store = component_store,
                .archetype_index = 1,
                .chunk_index = 0,
                .blocks = .{},
            };

            return self;
        }

        pub fn deinit(self: *@This()) void {
            self.blocks.deinit(self.component_store.allocator);
        }

        pub const Block = block: {
            const field_count = required_component_slice.len + components_optional.len + 1;

            var fields: [field_count]std.builtin.Type.StructField = undefined;

            var field_index = 0;

            fields[field_index] = .{
                .name = "entities",
                .type = []const Entity,
                .default_value = null,
                .is_comptime = false,
                .alignment = @alignOf([]const Entity),
            };
            field_index += 1;

            for (required_component_slice, 0..) |component_type, i| {
                fields[field_index + i] = .{
                    .name = componentFieldName(component_type),
                    .type = []component_type,
                    .default_value = null,
                    .is_comptime = false,
                    .alignment = @alignOf([]component_type),
                };
            }

            field_index += required_component_slice.len;

            for (components_optional, 0..) |component_type, i| {
                fields[field_index + i] = .{
                    .name = componentFieldName(component_type),
                    .type = ?[]component_type,
                    .default_value = null,
                    .is_comptime = false,
                    .alignment = @alignOf(?[]component_type),
                };
            }

            field_index += required_component_slice.len;

            break :block @Type(.{ .Struct = .{
                .layout = .auto,
                .backing_integer = null,
                .fields = &fields,
                .decls = &.{},
                .is_tuple = false,
            } });
        };

        pub const CachedBlock = block: {
            var fields: [required_component_slice.len + 2]std.builtin.Type.StructField = undefined;

            fields[0] = .{
                .name = "entity_count",
                .type = *const u16,
                .default_value = null,
                .is_comptime = false,
                .alignment = @alignOf(*const u16),
            };

            fields[1] = .{
                .name = "entities",
                .type = [*]const Entity,
                .default_value = null,
                .is_comptime = false,
                .alignment = @alignOf([*]const Entity),
            };

            for (required_component_slice, 2..) |component_type, i| {
                fields[i] = .{
                    .name = componentFieldName(component_type),
                    .type = [*]component_type,
                    .default_value = null,
                    .is_comptime = false,
                    .alignment = @alignOf([*]component_type),
                };
            }

            break :block @Type(.{ .Struct = .{
                .layout = .auto,
                .backing_integer = null,
                .fields = &fields,
                .decls = &.{},
                .is_tuple = false,
            } });
        };

        pub fn isInvalid(self: *@This()) bool {
            if (!(self.component_store.changes.added_archetypes or
                self.component_store.changes.added_chunks.items.len != 0 or
                self.component_store.changes.removed_chunks))
            {
                return false;
            }

            return true;
        }

        pub fn invalidate(self: *@This()) !void {
            if (!self.isInvalid()) return;

            self.blocks.clearRetainingCapacity();

            if (required_component_slice.len == 0) {
                return;
            }

            const component_type_desc: *ComponentTypeDescription = self.component_store.component_index.getPtr(componentId(required_component_slice[0])) orelse return;

            for (component_type_desc.archetypes.keys(), component_type_desc.archetypes.values()) |archetype_index, archetype_record| {
                if (!(self.component_store.archetypeHasAllComponents(archetype_index, required_component_slice[1..]) and
                    !self.component_store.archetypeHasAnyComponents(archetype_index, excluded_component_slice) and
                    self.component_store.archetypes.items[archetype_index].chunks.items.len > 0))
                {
                    continue;
                }

                const archetype: *Archetype = &self.component_store.archetypes.items[archetype_index];

                for (archetype.chunks.items) |*chunk| {
                    var block: CachedBlock = undefined;

                    if (chunk.row_count == 0) {
                        continue;
                    }

                    block.entity_count = &chunk.row_count;
                    block.entities = chunk.entities().ptr;

                    inline for (component_fetches) |component_type| {
                        const column: *ChunkColumn = &chunk.columns[archetype_record.column];

                        @field(block, componentFieldName(component_type)) = chunk.getComponents(component_type, column.offset).ptr;
                    }

                    try self.blocks.append(self.component_store.allocator, block);
                }
            }
        }

        fn nextArchetype(self: *@This()) ?ArchetypeIndex {
            if (self.archetype_index >= self.component_store.archetypes.items.len) {
                return null;
            }

            var archetype: *const Archetype = &self.component_store.archetypes.items[self.archetype_index];

            while (!(self.component_store.archetypeHasAllComponents(self.archetype_index, required_component_slice) and
                !self.component_store.archetypeHasAnyComponents(self.archetype_index, excluded_component_slice) and
                self.component_store.archetypes.items[self.archetype_index].chunks.items.len > 0))
            {
                self.archetype_index += 1;
                self.chunk_index = 0;

                if (self.archetype_index >= self.component_store.archetypes.items.len) {
                    return null;
                }

                archetype = &self.component_store.archetypes.items[self.archetype_index];
            }

            if (self.chunk_index >= archetype.chunks.items.len) {
                self.archetype_index += 1;
                self.chunk_index = 0;

                if (self.archetype_index >= self.component_store.archetypes.items.len) {
                    return null;
                }

                return self.archetype_index;
            }

            return self.archetype_index;
        }

        pub fn nextBlock(self: *@This()) ?Block {
            const archetype_index: ArchetypeIndex = self.nextArchetype() orelse return null;

            var archetype: *const Archetype = &self.component_store.archetypes.items[archetype_index];

            if (self.chunk_index >= archetype.chunks.items.len) {
                return null;
            }

            var chunk = &archetype.chunks.items[self.chunk_index];

            if (chunk.data == null or chunk.row_count == 0) {
                self.chunk_index += 1;
                return self.nextBlock();
            }

            var block: Block = undefined;

            block.entities = chunk.entities();

            inline for (required_component_slice) |component_type| {
                const component_type_desc = self.component_store.component_index.get(componentId(component_type)).?;

                const archetype_record = component_type_desc.archetypes.get(archetype_index).?;

                const column: *ChunkColumn = &chunk.columns[archetype_record.column];

                @field(block, componentFieldName(component_type)) = chunk.getComponents(component_type, column.offset);
            }

            inline for (components_optional) |component_type| {
                const component_type_desc = self.component_store.component_index.get(componentId(component_type)).?;

                const maybe_archetype_record = component_type_desc.archetypes.get(archetype_index);

                if (maybe_archetype_record) |archetype_record| {
                    const column: *ChunkColumn = &chunk.columns[archetype_record.column];

                    @field(block, componentFieldName(component_type)) = chunk.getComponents(component_type, column.offset);
                } else {
                    @field(block, componentFieldName(component_type)) = null;
                }
            }

            self.chunk_index += 1;

            return block;
        }

        ///Returns the name of the field in Block that contains the []T
        pub fn componentFieldName(comptime T: type) [:0]const u8 {
            const full_type_name = @typeName(if (@typeInfo(T) == .Optional) std.meta.Child(T) else T);

            const index_of_name = std.mem.lastIndexOf(u8, full_type_name, &.{'.'}).? + 1;

            const name: [full_type_name.len - index_of_name:0]u8 = full_type_name[index_of_name..].*;

            return &name;
        }
    };
}

///Returns a query which can access all the components specified in component_fetches
pub fn query(
    self: *ComponentStore,
    comptime component_fetches: anytype,
    comptime component_filters: anytype,
) QueryIterator(component_fetches, component_filters) {
    return QueryIterator(component_fetches, component_filters).init(self);
}

///Indicates a set type which defines a weak relationship between its components.
///Allows for optional components and default components, which are components that don't have to be on an entity for it to conform to the set.
///Queries allow for querying a component set, which will ensure the correct optionality and defaulting rules of the set type.
pub const IsComponentSet = struct {};

pub fn isComponentSet(comptime T: type) bool {
    switch (@typeInfo(T)) {
        .Struct => inline for (std.meta.fields(T)) |field| {
            if (field.type == IsComponentSet) {
                return true;
            }
        },
        else => return false,
    }

    return false;
}

pub fn foreach(
    self: *ComponentStore,
    context: anytype,
    comptime function: anytype,
) void {
    if (true) @compileError("");

    const ContextType = @TypeOf(context);

    const args_types = std.meta.ArgsTuple(@TypeOf(function));

    comptime var args_type_fields = std.meta.fields(args_types);

    const ArgsType = @Type(.{ .Struct = .{
        .layout = .auto,
        .is_tuple = true,
        .fields = args_type_fields,
        .decls = &[_]std.builtin.Type.Declaration{},
    } });

    const arg_start = if (args_type_fields[1].type == Entity) 2 else 1;

    const component_count = if (args_type_fields[1].type == Entity) args_type_fields.len - 2 else args_type_fields.len - 1;

    comptime var component_types: [component_count]type = undefined;

    comptime for (&component_types, args_type_fields[arg_start..]) |*component_type, arg_type| {
        if (@typeInfo(arg_type.type) == .Pointer and @typeInfo(arg_type.type).Pointer.size == .One) {
            component_type.* = std.meta.Child(arg_type.type);
        } else {
            component_type.* = arg_type.type;
        }
    };

    var foreach_query = self.query(component_types, .{});

    while (foreach_query.nextBlock()) |block| {
        const entities = block.entities;

        for (entities, 0..) |entity, entity_index| {
            var args: ArgsType = undefined;

            if (args_type_fields[0].type == ContextType) {
                args[0] = context;
            }

            if (args_type_fields[1].type == Entity) {
                args[1] = entity;
            }

            inline for (args_type_fields[arg_start..], arg_start..) |arg_type, i| {
                if (@typeInfo(arg_type.type) == .Pointer) {
                    const field_name = comptime @TypeOf(foreach_query).componentFieldName(std.meta.Child(arg_type.type));

                    args[i] = &@field(block, field_name)[entity_index];
                } else {
                    const field_name = comptime @TypeOf(foreach_query).componentFieldName(arg_type.type);

                    if (@typeInfo(arg_type.type) == .Optional) {
                        args[i] = @field(block, field_name).?[entity_index];
                    } else {
                        args[i] = @field(block, field_name)[entity_index];
                    }
                }
            }

            @call(.always_inline, function, args);
        }
    }
}

///Returns an archetype with the components of the source archetype and the component specified by component_id
fn addToArchetype(
    self: *ComponentStore,
    source_archetype_index: ArchetypeIndex,
    component_type: ComponentType,
) !ArchetypeIndex {
    const component_id = component_type.id;

    std.debug.assert(source_archetype_index < self.archetypes.items.len);

    var source_archetype: *Archetype = &self.archetypes.items[source_archetype_index];

    if (source_archetype_index == 0) {
        std.debug.assert(source_archetype.component_ids.items.len == 0);
    }

    const potential_source_edge = source_archetype.edges.get(component_id);

    if (potential_source_edge != null and
        potential_source_edge.?.add != null)
    {
        return potential_source_edge.?.add.?;
    }

    //Find a suitable adjacent archetype
    const existing_archetype_index: ?ArchetypeIndex = block: {
        const component_description = self.component_index.getPtr(component_id);

        if (component_description == null) break :block null;

        archetype_loop: for (component_description.?.archetypes.keys()) |new_archetype_index| {
            const archetype: *Archetype = &self.archetypes.items[new_archetype_index];

            if (archetype.component_ids.items.len != source_archetype.component_ids.items.len + 1) {
                continue;
            }

            if (!std.mem.containsAtLeast(ComponentId, archetype.component_ids.items, 1, &.{component_id})) {
                continue;
            }

            for (source_archetype.component_ids.items) |new_component_id| {
                if (!std.mem.containsAtLeast(ComponentId, archetype.component_ids.items, 1, &.{new_component_id})) {
                    continue :archetype_loop;
                }
            }

            break :block @as(ArchetypeIndex, @intCast(new_archetype_index));
        }

        break :block null;
    };

    if (existing_archetype_index != null) {
        std.debug.assert(existing_archetype_index.? != 0);

        std.log.info("ARCHETYPE GRAPH CACHE HIT", .{});

        const existing_archetype: *Archetype = &self.archetypes.items[existing_archetype_index.?];

        for (existing_archetype.component_ids.items) |existing_component_id| {
            std.log.info("cached component: nameof({s})", .{existing_component_id.name()});
        }

        try self.archetypeCreateAddEdge(source_archetype_index, existing_archetype_index.?, component_id);

        return existing_archetype_index.?;
    }

    const component_ids = try self.allocator.alloc(ComponentId, source_archetype.component_ids.items.len + 1);
    errdefer self.allocator.free(component_ids);

    var component_index: usize = 0;

    for (source_archetype.component_ids.items) |source_component_id| {
        component_ids[component_index] = source_component_id;

        component_index += 1;
    }

    component_ids[component_index] = component_id;

    for (component_ids) |new_comp| {
        std.log.warn("component_id.name = {s}, size = {}", .{ new_comp.name(), new_comp.size() });
    }

    const archetype_index = try self.createArchetype(component_ids);

    try self.archetypeCreateAddEdge(source_archetype_index, archetype_index, component_id);

    return archetype_index;
}

///Creates a by-directional edge between the two archetypes
fn archetypeCreateAddEdge(
    self: *ComponentStore,
    source_archetype_index: ArchetypeIndex,
    destination_archetype_index: ArchetypeIndex,
    component_id: ComponentId,
) !void {
    const source_archetype: *Archetype = &self.archetypes.items[source_archetype_index];
    const destination_archetype: *Archetype = &self.archetypes.items[destination_archetype_index];

    const source_edge = try source_archetype.edges.getOrPutValue(self.allocator, component_id, .{
        .add = null,
        .remove = null,
    });

    const destination_edge = try destination_archetype.edges.getOrPutValue(self.allocator, component_id, .{
        .add = null,
        .remove = null,
    });

    source_edge.value_ptr.add = @as(u31, @intCast(destination_archetype_index));
    destination_edge.value_ptr.remove = @as(u31, @intCast(source_archetype_index));
}

///Returns an archetype with the components of the source archetype without the component specified by component_id
fn removeFromArchetype(
    self: *ComponentStore,
    source_archetype_index: ArchetypeIndex,
    component_id: ComponentId,
) !ArchetypeIndex {
    std.debug.assert(source_archetype_index != 0);

    var source_archetype: *Archetype = &self.archetypes.items[source_archetype_index];

    const potential_source_edge = source_archetype.edges.get(component_id);

    if (potential_source_edge != null and
        potential_source_edge.?.remove != null)
    {
        return potential_source_edge.?.remove.?;
    }

    //Find a suitable adjacent archetype
    const existing_archetype_index: ?ArchetypeIndex = block: {
        const component_description = self.component_index.getPtr(component_id);

        if (component_description == null) break :block null;

        archetype_loop: for (component_description.?.archetypes.keys()) |new_archetype_index| {
            const archetype: *Archetype = &self.archetypes.items[new_archetype_index];

            if (archetype.component_ids.items.len != source_archetype.component_ids.items.len - 1) {
                continue;
            }

            if (std.mem.containsAtLeast(ComponentId, archetype.component_ids.items, 1, &.{component_id})) {
                continue;
            }

            for (source_archetype.component_ids.items) |new_component_id| {
                if (new_component_id == component_id) continue;

                if (!std.mem.containsAtLeast(ComponentId, archetype.component_ids.items, 1, &.{new_component_id})) {
                    continue :archetype_loop;
                }
            }

            break :block @as(ArchetypeIndex, @intCast(new_archetype_index));
        }

        break :block null;
    };

    if (existing_archetype_index != null) {
        try self.archetypeCreateRemoveEdge(source_archetype_index, existing_archetype_index.?, component_id);

        return existing_archetype_index.?;
    }

    const component_ids = try self.allocator.alloc(ComponentId, source_archetype.component_ids.items.len - 1);
    errdefer self.allocator.free(component_ids);

    var component_index: usize = 0;

    for (source_archetype.component_ids.items) |source_component_id| {
        if (source_component_id == component_id) {
            continue;
        }

        component_ids[component_index] = source_component_id;

        component_index += 1;
    }

    const new_archetype_index = try self.createArchetype(component_ids);

    try self.archetypeCreateRemoveEdge(source_archetype_index, new_archetype_index, component_id);

    return new_archetype_index;
}

///Creates a by-directional edge between the two archetypes
fn archetypeCreateRemoveEdge(
    self: *ComponentStore,
    source_archetype_index: ArchetypeIndex,
    destination_archetype_index: ArchetypeIndex,
    component_id: ComponentId,
) !void {
    const source_archetype: *Archetype = &self.archetypes.items[source_archetype_index];
    const destination_archetype: *Archetype = &self.archetypes.items[destination_archetype_index];

    const source_edge = try source_archetype.edges.getOrPutValue(self.allocator, component_id, .{
        .add = null,
        .remove = null,
    });

    const destination_edge = try destination_archetype.edges.getOrPutValue(self.allocator, component_id, .{
        .add = null,
        .remove = null,
    });

    source_edge.value_ptr.remove = @as(u31, @intCast(destination_archetype_index));
    destination_edge.value_ptr.add = @as(u31, @intCast(source_archetype_index));
}

fn componentLessThan(_: void, a: ComponentId, b: ComponentId) bool {
    return @intFromPtr(a) < @intFromPtr(b);
}

fn createArchetype(
    self: *ComponentStore,
    component_ids: []ComponentId,
) !ArchetypeIndex {
    const archetype_index = @as(ArchetypeIndex, @intCast(self.archetypes.items.len));

    std.sort.insertion(ComponentId, component_ids, {}, componentLessThan);

    try self.archetypes.append(self.allocator, .{
        .component_ids = std.ArrayListUnmanaged(ComponentId).fromOwnedSlice(component_ids),
        .edges = .{},
    });

    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    for (archetype.component_ids.items, 0..) |new_component_id, i| {
        const component_description = try self.component_index.getOrPutValue(self.allocator, new_component_id, .{});

        const archetype_record = try component_description.value_ptr.archetypes.getOrPut(self.allocator, archetype_index);

        archetype_record.value_ptr.column = @as(u32, @intCast(i));
    }

    self.changes.added_archetypes = true;

    return archetype_index;
}

///Returns an index to the chunk within the archetype
fn archetypeAllocateChunk(
    self: *ComponentStore,
    archetype_index: ArchetypeIndex,
    size: Chunk.Size,
) !ChunkIndex {
    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    const chunk_data = try self.chunk_pool.alloc(size);
    errdefer self.chunk_pool.free(chunk_data.ptr, size);

    const chunk_index: ChunkIndex = @as(ChunkIndex, @intCast(archetype.chunks.items.len));

    try archetype.chunks.append(self.allocator, Chunk{
        .data = chunk_data,
        .columns = &.{},
        .row_count = 0,
        .max_row_count = 0,
    });

    const chunk: *Chunk = &archetype.chunks.items[chunk_index];

    chunk.columns = try self.allocator.alloc(ChunkColumn, archetype.component_ids.items.len);
    errdefer self.allocator.free(chunk.columns);

    //The maximum byte overhead for entites in this archetype
    var bytes_per_entity: usize = @sizeOf(Entity);
    //The maximum byte overhead of the padding required to align the components
    var max_padding: usize = 0;

    for (archetype.component_ids.items) |component_id| {
        bytes_per_entity += component_id.size();
        max_padding += component_id.alignment();
    }

    //Maximum size the chunk to be allocated with alignment padding subtracted
    const max_size_without_padding = size.toSize() - max_padding;

    //The maximium number of entities that can be stored in a chunk based on the size of
    //The size of an entity id, the size of the components and their alignment
    const max_entity_count = max_size_without_padding / bytes_per_entity;

    chunk.max_row_count = @as(u16, @intCast(max_entity_count));

    std.log.warn("max_entity_count for this chunk = {}", .{max_entity_count});

    const entity_end_offset = max_entity_count * @sizeOf(Entity);

    var running_offset: usize = entity_end_offset;

    for (
        chunk.columns,
        archetype.component_ids.items,
    ) |*destination_column, component_type| {
        if (component_type.size() == 0) {
            destination_column.* = .{
                .offset = 0,
                .element_size = 0,
                .element_alignment = 0,
            };

            continue;
        }

        running_offset = std.mem.alignForward(usize, running_offset, @as(u8, @intCast(component_type.alignment())));

        destination_column.* = .{
            .offset = @as(ChunkOffset, @intCast(running_offset)),
            .element_size = @as(u16, @intCast(component_type.size())),
            .element_alignment = @as(u16, @intCast(component_type.alignment())),
        };

        running_offset += @as(ChunkOffset, @intCast(max_entity_count)) * @as(ChunkOffset, @intCast(destination_column.element_size));
    }

    try self.changes.added_chunks.append(self.allocator, .{ .archetype_index = @intCast(archetype_index), .chunk_index = chunk_index });

    return chunk_index;
}

fn archetypeFreeChunk(
    self: *ComponentStore,
    archetype_index: ArchetypeIndex,
    chunk_index: ChunkIndex,
) void {
    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    //Should use a swap remove, but that has complex implications
    var chunk: *Chunk = &archetype.chunks.items[chunk_index];

    if (chunk.data == null) {
        return;
    }

    self.allocator.free(chunk.columns);
    self.chunk_pool.free(chunk.data.?.ptr, Chunk.Size.fromSize(chunk.data.?.len));

    chunk.data = null;
    chunk.columns = &.{};
    chunk.max_row_count = 0;
    chunk.row_count = 0;

    self.changes.removed_chunks = true;
}

///Finds or creates a chunk which can fit the specified number of rows
///Will return a chunk which can fit desired_row_count contigiously
fn archetypeGetOrAllocateChunk(
    self: *ComponentStore,
    archetype_index: ArchetypeIndex,
    desired_row_count: u16,
) !ChunkIndex {
    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    if (archetype.chunks.items.len == 0) {
        const chunk_index = try self.archetypeAllocateChunk(archetype_index, .@"4kb");

        archetype.next_free_chunk_index = @as(ChunkIndex, @intCast(chunk_index));

        return chunk_index;
    }

    const next_free_chunk_index = archetype.next_free_chunk_index;

    const next_free_chunk: *Chunk = &archetype.chunks.items[next_free_chunk_index];

    const free_row_count = next_free_chunk.max_row_count - next_free_chunk.row_count;

    if (free_row_count == 0) {
        const chunk_index = try self.archetypeAllocateChunk(archetype_index, .@"4kb");

        archetype.next_free_chunk_index = @as(ChunkIndex, @intCast(chunk_index));

        return archetype.next_free_chunk_index;
    }

    if (desired_row_count <= free_row_count) {
        return next_free_chunk_index;
    }

    for (archetype.chunks.items[next_free_chunk_index..], 0..) |chunk, chunk_index| {
        if (desired_row_count <= (chunk.max_row_count - chunk.row_count)) {
            archetype.next_free_chunk_index = @as(ChunkIndex, @intCast(chunk_index));

            return archetype.next_free_chunk_index;
        }
    }

    return next_free_chunk_index;
}

///Adds a row to the archetype, leaving the component data undefined
fn archetypeAddRow(
    self: *ComponentStore,
    archetype_index: ArchetypeIndex,
    entity: Entity,
) !RowLocation {
    std.debug.assert(archetype_index != 0);

    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    const chunk_index = try self.archetypeGetOrAllocateChunk(archetype_index, 1);

    const chunk: *Chunk = &archetype.chunks.items[chunk_index];

    std.debug.assert(chunk.row_count + 1 <= chunk.max_row_count);

    const row_index = chunk.row_count;

    archetype.entity_count += 1;
    chunk.row_count += 1;

    std.log.info("chunk.max_row_count = {}", .{chunk.max_row_count});

    std.debug.assert(chunk.data != null);

    const entities = chunk.entities();

    std.debug.assert(entities.len != 0);

    entities[entities.len - 1] = entity;

    const entity_description = self.entity_map.get(entity).?;

    const row = RowLocation{
        .chunk_index = chunk_index,
        .row_index = row_index,
    };

    entity_description.row = row;

    return row;
}

///Performs a swap removal (O(1)) in order to keep the arrays parralel and contigious
fn archetypeRemoveRow(
    self: *ComponentStore,
    archetype_index: ArchetypeIndex,
    row: RowLocation,
) void {
    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    defer {
        archetype.entity_count -|= 1;
    }

    if (archetype.chunks.items.len == 0) {
        return;
    }

    const chunk: *Chunk = &archetype.chunks.items[row.chunk_index];

    defer {
        chunk.row_count -|= 1;

        if (chunk.row_count == 0) {
            self.archetypeFreeChunk(archetype_index, row.chunk_index);

            archetype.next_free_chunk_index = @min(archetype.next_free_chunk_index, row.chunk_index);
        }
    }

    if (chunk.row_count == 1 or row.row_index == chunk.row_count - 1) {
        return;
    }

    for (chunk.columns) |*column| {
        if (column.element_size == 0) continue;

        const dst_start = column.offset + row.row_index * column.element_size;
        const dst = chunk.data.?[dst_start .. dst_start + column.element_size];

        const src_start = column.offset + (chunk.row_count - 1) * column.element_size;
        const src = chunk.data.?[src_start .. src_start + column.element_size];

        @memcpy(dst, src);
    }

    const entities = chunk.entities();

    const entity_to_update = entities[entities.len - 1];

    entities[row.row_index] = entities[entities.len - 1];

    const entity_to_update_description = self.entity_map.get(entity_to_update) orelse return;

    entity_to_update_description.row = row;
}

const RowLocation = packed struct(u32) {
    chunk_index: u16 = 0,
    row_index: u16 = 0,
};

///Copies the data from src_row_index to dst_row_index within the same archetype
fn archetypeCopyRow(
    self: *ComponentStore,
    archetype_index: ArchetypeIndex,
    src_row: RowLocation,
    dst_row: RowLocation,
) !void {
    std.debug.assert(archetype_index != 0);

    const archetype: *Archetype = &self.archetypes.items[archetype_index];

    const src_chunk: *Chunk = &archetype.chunks.items[src_row.chunk_index];
    const dst_chunk: *Chunk = &archetype.chunks.items[dst_row.chunk_index];

    for (
        src_chunk.columns,
        dst_chunk.columns,
    ) |*src_column, *dst_column| {
        if (src_column.element_size == 0 or dst_column.element_size == 0) continue;

        const dst_start = dst_column.offset + dst_row.row_index * dst_column.element_size;
        const dst = dst_chunk.data.?[dst_start .. dst_start + dst_column.element_size];
        const src_start = src_column.offset + src_row.row_index * src_column.element_size;
        const src = src_chunk.data.?[src_start .. src_start + src_column.element_size];

        @memcpy(dst, src);
    }
}

fn archetypeCopyRowMultiArchetype(
    self: *ComponentStore,
    source_archetype_index: ArchetypeIndex,
    destination_archetype_index: ArchetypeIndex,
    source_row: RowLocation,
    destination_row: RowLocation,
) !void {
    std.debug.assert(source_archetype_index != 0);

    const source_archetype: *Archetype = &self.archetypes.items[source_archetype_index];
    const destination_archetype: *Archetype = &self.archetypes.items[destination_archetype_index];

    const source_chunk: *Chunk = &source_archetype.chunks.items[source_row.chunk_index];
    const destination_chunk: *Chunk = &destination_archetype.chunks.items[destination_row.chunk_index];

    const minimum_length = @min(source_chunk.columns.len, destination_chunk.columns.len);

    for (0..minimum_length) |i| {
        var source_column = &source_chunk.columns[i];
        var destination_column = &destination_chunk.columns[i];

        var src_id = source_archetype.component_ids.items[i];
        var dst_id = destination_archetype.component_ids.items[i];

        if (src_id != dst_id) {
            for (destination_chunk.columns[0..], 0..) |*new_destination_column, j| {
                const new_dst_id = destination_archetype.component_ids.items[j];

                if (src_id == new_dst_id) {
                    dst_id = new_dst_id;
                    destination_column = new_destination_column;

                    break;
                }
            }
        }

        if (src_id != dst_id) {
            for (source_chunk.columns[0..], 0..) |*new_source_column, j| {
                const new_src_id = source_archetype.component_ids.items[j];

                if (dst_id == new_src_id) {
                    src_id = new_src_id;
                    source_column = new_source_column;

                    break;
                }
            }
        }

        std.debug.assert(src_id == dst_id);
        std.debug.assert(source_column.element_size == destination_column.element_size);
        std.debug.assert(source_column.element_alignment == destination_column.element_alignment);

        if (source_column.element_size == 0 or destination_column.element_size == 0) {
            continue;
        }

        const dst_start = destination_column.offset + destination_column.element_size * destination_row.row_index;
        const dst = destination_chunk.data.?[dst_start .. dst_start + destination_column.element_size];

        const src_start = source_column.offset + source_column.element_size * source_row.row_index;
        const src = source_chunk.data.?[src_start .. src_start + source_column.element_size];

        @memcpy(dst, src);
    }
}

///Removes the row at row_index from the source archetype and adds a row to dest archetype and moves it there
///Returns an index to the new row
fn archetypeMoveRow(
    self: *ComponentStore,
    source_archetype_index: ArchetypeIndex,
    destination_archetype_index: ArchetypeIndex,
    source_row: RowLocation,
    entity: Entity,
) !RowLocation {
    std.debug.assert(destination_archetype_index != 0);

    const destination_row = try self.archetypeAddRow(destination_archetype_index, entity);

    if (source_archetype_index == 0) {
        return destination_row;
    }

    try self.archetypeCopyRowMultiArchetype(
        source_archetype_index,
        destination_archetype_index,
        source_row,
        destination_row,
    );

    self.archetypeRemoveRow(source_archetype_index, source_row);

    return destination_row;
}

fn archetypeHasAllComponents(
    self: *const ComponentStore,
    archetype_index: ArchetypeIndex,
    comptime components: anytype,
) bool {
    if (components.len == 0) {
        return true;
    }

    inline for (components) |Component| {
        if (!self.archetypeHasComponent(archetype_index, Component)) {
            return false;
        }
    }

    return true;
}

fn archetypeHasAnyComponents(
    self: *const ComponentStore,
    archetype_index: ArchetypeIndex,
    comptime components: anytype,
) bool {
    if (components.len == 0) {
        return false;
    }

    inline for (components) |Component| {
        if (self.archetypeHasComponent(archetype_index, Component)) {
            return true;
        }
    }

    return false;
}

fn archetypeHasComponent(
    self: *const ComponentStore,
    archetype_index: ArchetypeIndex,
    comptime Component: type,
) bool {
    const component_description = self.component_index.getPtr(componentId(Component)) orelse return false;

    return component_description.archetypes.contains(archetype_index);
}

///Returns a unique ComponentId for the given type
pub fn componentId(comptime T: type) ComponentId {
    if (!(@typeInfo(T) == .Struct or
        @typeInfo(T) == .Enum or
        @typeInfo(T) == .Union))
    {
        @compileError("T must be a struct, enum or union");
    }

    return reflect.Type.info(T);
}

pub fn componentType(comptime T: type) ComponentType {
    return .{
        .id = componentId(T),
        .size = @sizeOf(T),
        .alignment = @alignOf(T),
    };
}

pub fn componentIsTag(comptime T: type) bool {
    return @sizeOf(T) == 0;
}

test {
    _ = std.testing.refAllDecls(@This());
}

test "Basic component store" {
    var ecs_scene = try ComponentStore.init(std.testing.allocator);
    defer ecs_scene.deinit();

    const entity = try ecs_scene.entityCreate(.{});

    const PosComponent = struct {
        x: f32,
        y: f32,
        z: f32,
    };

    const TagComponent = struct {};

    try ecs_scene.entityAddComponents(entity, .{
        PosComponent{ .x = 0, .y = 10, .z = 0 },
        TagComponent,
    });

    try std.testing.expect(ecs_scene.entityHasComponent(entity, PosComponent));
    try std.testing.expect(ecs_scene.entityHasComponent(entity, TagComponent));

    const pos_component = ecs_scene.entityGetComponent(entity, PosComponent).?.*;

    try std.testing.expect(std.meta.eql(pos_component, PosComponent{ .x = 0, .y = 10, .z = 0 }));

    try ecs_scene.entityRemoveComponent(entity, TagComponent);

    try std.testing.expect(!ecs_scene.entityHasComponent(entity, TagComponent));

    try ecs_scene.entityRemoveComponent(entity, PosComponent);

    try std.testing.expect(!ecs_scene.entityHasComponent(entity, TagComponent));
    try std.testing.expect(!ecs_scene.entityHasComponent(entity, PosComponent));

    try ecs_scene.entityAddComponents(entity, .{
        PosComponent{ .x = 0, .y = 10, .z = 0 },
        TagComponent,
    });

    try std.testing.expect(ecs_scene.entityHasComponent(entity, PosComponent));
    try std.testing.expect(ecs_scene.entityHasComponent(entity, TagComponent));

    ecs_scene.entityDestroy(entity);

    try std.testing.expect(!ecs_scene.entityExists(entity));

    try std.testing.expect(try ecs_scene.entityCreate(.{}) != entity);
}

test "Queries" {
    var ecs_scene = try ComponentStore.init(std.testing.allocator);
    defer ecs_scene.deinit();

    if (true) return error.ZigSkipTest;

    const test_entity = try ecs_scene.entityCreate(.{});

    const Position = struct {
        x: f32 align(1),
        y: f32,
        z: f32,
    };

    const Rotation = struct {
        x: f32 align(1) = 0,
        y: f32 = 0,
        z: f32 = 0,
    };

    const EnumComponent = enum {
        one,
        two,
        three,
    };

    const UnionComponent = union(enum) { one: Position, two: Rotation, three };

    //Zero-size struct component that won't have storage
    const Tag = struct {};

    try ecs_scene.entityAddComponents(test_entity, .{
        Position{ .x = 0, .y = 10, .z = 0 },
        UnionComponent{ .one = .{ .x = 0, .y = 0, .z = 0 } },
        EnumComponent.one,
        Tag,
        Rotation{ .x = 0, .y = 900, .z = 0 },
    });

    std.log.warn("test_entity.count = {}", .{ecs_scene.entityCount(test_entity)});

    const test_entity_2 = try ecs_scene.entityCreate(.{Position{ .x = 10, .y = 69, .z = 420 }});

    try ecs_scene.entityAddComponent(test_entity_2, Rotation{ .x = 0, .y = 0, .z = 0 });
    try ecs_scene.entityAddComponent(test_entity_2, EnumComponent.one);

    try std.testing.expect(ecs_scene.entityHasComponent(test_entity_2, Position));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity_2, Rotation));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity_2, EnumComponent));

    _ = try ecs_scene.entityCreate(.{Position{ .x = 10, .y = 69, .z = 420 }});
    _ = try ecs_scene.entityCreate(.{ Tag, Position{ .x = 10, .y = 69, .z = 420 } });
    _ = try ecs_scene.entityCreate(.{ Position{ .x = 10, .y = 69, .z = 420 * 2 }, Rotation{ .x = 200, .y = 200, .z = 9 } });
    _ = try ecs_scene.entityCreate(.{ Tag, Position{ .x = 10, .y = 69 / 2, .z = 420 }, Rotation{ .x = 0, .y = 10003, .z = 20 } });
    _ = try ecs_scene.entityCreate(.{ Tag, Position{ .x = 10, .y = 69 / 2, .z = 420 }, Rotation{ .x = 0, .y = 10003, .z = 20 } });

    //Example of a query:
    //Create a query for all entities with PosComponent but must have TagComponent
    var pos_query = ecs_scene.query(.{ Position, Rotation }, .{filterWith(Tag)});

    while (pos_query.nextBlock()) |block| {
        std.log.warn("New block", .{});

        const entities: []const Entity = block.entities;
        const pos_components: []const Position = block.Position;
        const rot_components: []const Rotation = block.Rotation;

        std.log.warn("entities = {any}", .{entities});

        for (entities, pos_components, rot_components) |entity, pos, rot| {
            std.log.warn("entity({}):", .{entity});
            std.log.warn("pos = {any}", .{pos});
            std.log.warn("rot = {any}", .{rot});
        }
    }

    try std.testing.expect(ecs_scene.entityHasComponent(test_entity, Position));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity, EnumComponent));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity, UnionComponent));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity, Tag));
    try std.testing.expect(ecs_scene.entityHasComponent(test_entity, Rotation));
}

test "Reflection" {
    var ecs_scene = try ComponentStore.init(std.testing.allocator);
    defer ecs_scene.deinit();

    const Position = struct {
        x: f32 = 0,
        y: f32 = 0,
        z: f32 = 0,
    };

    const Rotation = struct {
        x: f32 = 0,
        y: f32 = 0,
        z: f32 = 0,
    };

    const entity = try ecs_scene.entityCreate(.{
        Position{},
        Rotation{},
    });

    for (ecs_scene.entityGetComponentTypes(entity)) |type_info| {
        if (type_info.is(Rotation)) {
            std.log.warn("We FOUND A ROTATION COMPONENT TYPE!!!", .{});
        }

        std.log.warn("type_info.fields = {any}", .{type_info.*.Struct.fields});
        std.log.warn("type_info.fields[0].name = {s}", .{type_info.*.Struct.fields[0].name});
        std.log.warn("type_info.fields[1].name = {s}", .{type_info.*.Struct.fields[1].name});
    }
}
