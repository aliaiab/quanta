const std = @import("std");
const quanta = @import("../main.zig");
const imgui = quanta.imgui.cimgui;
const widgets = quanta.imgui.widgets;
const ecs = quanta.ecs;
const ComponentStore = ecs.ComponentStore;
const CommandBuffer = ecs.CommandBuffer;

pub fn entityViewer(
    ecs_scene: *ComponentStore,
    commands: *CommandBuffer,
) void
{
    defer widgets.end();

    if (!widgets.begin("Entity Debugger")) return;

    for (ecs_scene.getEntities()) |entity|
    {
        if (widgets.treeNodePush("{}", .{ entity }))
        {
            defer widgets.treeNodePop();

            if (widgets.button("Clone"))
            {
                commands.entityClone(entity);
            }

            imgui.igSameLine(0, 10);

            if (widgets.button("Clear"))
            {
                commands.entityClear(entity);
            }

            imgui.igSameLine(0, 10);

            if (widgets.button("Destroy"))
            {
                commands.entityDestroy(entity);
            }

            for (ecs_scene.entityGetComponentTypes(entity)) |component_type_info|
            {
                imgui.igSeparator();

                if (widgets.collapsingHeader("{s}", .{ component_type_info.name() }))
                {
                    imgui.igPushID_Str(component_type_info.name().ptr);
                    defer imgui.igPopID();

                    if (widgets.button("Remove Component"))
                    {
                        commands.addCommand(.{ 
                            .remove_component = .{
                                .entity = entity,
                                .component_id = component_type_info,
                            } 
                        });
                    }

                    switch (component_type_info.*) 
                    {
                        .Struct => |struct_info| {
                            for (struct_info.fields) |field|
                            {
                                switch (field.type.*)
                                {
                                    .Int => unreachable,
                                    .Float => {
                                        const ptr_to_struct = ecs_scene.entityGetComponentPtr(entity, component_type_info);

                                        const ptr_to_field = @ptrCast([*]u8, ptr_to_struct) + field.offset;

                                        const ptr_to_float: *f32 = @ptrCast(*f32, @alignCast(@alignOf(f32), ptr_to_field));

                                        widgets.dragFloat(field.name, ptr_to_float);
                                    },
                                    else => {
                                        widgets.textFormat("{s} = {*}", .{ field.name, ecs_scene.entityGetComponentPtr(entity, component_type_info) });
                                    },
                                }
                            }
                        },
                        .Enum => |enum_info| {
                            const ptr_to_enum = @ptrCast([*]u8, ecs_scene.entityGetComponentPtr(entity, component_type_info));

                            var items: [256][*c]const u8 = undefined;

                            for (enum_info.fields, 0..) |field, i|
                            {
                                items[i] = field.name.ptr;
                            }

                            var current_item: c_int = @intCast(c_int, ptr_to_enum[0]);

                            if (imgui.igCombo_Str_arr(
                                "value", 
                                &current_item, 
                                &items, 
                                @intCast(c_int, enum_info.fields.len),
                                0
                            ))
                            {
                                ptr_to_enum[0] = @intCast(u8, current_item);
                            }
                        },
                        .Union => |union_info| {
                            const ptr_to_enum = @ptrCast([*]u8, ecs_scene.entityGetComponentPtr(entity, component_type_info)) + union_info.tag_offset;

                            var items: [256][*c]const u8 = undefined;

                            for (union_info.fields, 0..) |field, i|
                            {
                                items[i] = field.name.ptr;

                                widgets.textFormat("{s}", .{ field.name });
                            }

                            var current_item: c_int = @intCast(c_int, ptr_to_enum[0]);

                            if (imgui.igCombo_Str_arr(
                                "value", 
                                &current_item, 
                                &items, 
                                @intCast(c_int, union_info.fields.len),
                                0
                            ))
                            {
                                ptr_to_enum[0] = @intCast(u8, current_item);
                            } 

                            for (union_info.fields, 0..) |field, i|
                            {
                                if (i != @intCast(usize, current_item))
                                {
                                    // continue;
                                }

                                widgets.textFormat("{s}", .{ field.name });
                                
                                switch (field.type.*)
                                {
                                    .Int => |int_info| {
                                        widgets.textFormat("{}", .{ int_info });
                                    },
                                    .Void => {},
                                    else => {},
                                }
                            }
                        },
                        else => {},
                    }
                }
            }                            
        }
    }
}

pub fn chunkViewer(
    ecs_scene: *ComponentStore,
) void 
{
    defer widgets.end();

    if (!widgets.begin("Entity Chunk Viewer")) return;

    var total_chunk_entity_count: usize = 0;
    var total_used_chunk_entity_count: usize = 0;
    
    var total_chunk_size: usize = 0;

    for (ecs_scene.archetypes.items[1..]) |archetype|
    {
        const chunk: *const quanta.ecs.ComponentStore.Chunk = &archetype.chunk;

        if (chunk.data == null) continue;

        total_chunk_entity_count += archetype.chunk_max_entity_count;
        total_used_chunk_entity_count += chunk.row_count;

        total_chunk_size += quanta.ecs.ComponentStore.Chunk.max_size;
    }

    widgets.textFormat("total entity utilization: {d:.1}%", .{ (@intToFloat(f32, total_used_chunk_entity_count) / @intToFloat(f32, total_chunk_entity_count)) * 100.0 });                        

    const log_2_size = std.math.log2_int(usize, total_chunk_size);

    switch (log_2_size)
    {
        10...19 => {
            widgets.textFormat("total size: {}kb", .{ total_chunk_size / 1024 });
        },
        20...29 => {
            widgets.textFormat("total size: {}mb", .{ total_chunk_size / (1024 * 1024) });
        },
        else => {
            widgets.textFormat("total size: {}b", .{ total_chunk_size });
        },
    }

    for (ecs_scene.archetypes.items[1..], 1..) |archetype, archetype_index|
    {
        const chunk_index = archetype_index;
        const chunk: *const quanta.ecs.ComponentStore.Chunk = &archetype.chunk;

        if (chunk.data == null) continue;

        imgui.igSeparator();

        if (widgets.collapsingHeader("Chunk ({})", .{ chunk_index }))
        {
            widgets.textFormat("alignment: {}", .{ quanta.ecs.ComponentStore.Chunk.alignment });
            widgets.textFormat("size: {}", .{ quanta.ecs.ComponentStore.Chunk.max_size });
            widgets.textFormat("address: {x}", .{ @ptrToInt(chunk.data) });
            widgets.textFormat("entity_count: {}", .{ chunk.row_count });
            widgets.textFormat("max_entity_count: {}", .{ archetype.chunk_max_entity_count });                        
            widgets.textFormat("entity utilization: {d:.1}%", .{ (@intToFloat(f32, chunk.row_count) / @intToFloat(f32, archetype.chunk_max_entity_count)) * 100.0 });                        
        }
    }
}