const std = @import("std");
const quanta = @import("quanta");
const imgui = @import("../root.zig").cimgui;
const imguizmo = @import("guizmo.zig");
const widgets = @import("widgets.zig");
const Window = quanta.windowing.Window;
const ecs = quanta.ecs;
const zalgebra = quanta.math.zalgebra;
const ComponentStore = ecs.ComponentStore;
const CommandBuffer = ecs.CommandBuffer;
const Entity = ecs.ComponentStore.Entity;

pub fn entitySelector(
    ecs_scene: *ComponentStore,
    commands: *CommandBuffer,
    camera: quanta.renderer_3d.Renderer3D.Camera,
    selected_entities: *std.ArrayList(Entity),
    window: *Window,
) !void {
    {
        const len = selected_entities.items.len;

        for (0..len) |i| {
            const index = len - i - 1;
            const entity = selected_entities.items[index];

            if (!ecs_scene.entityExists(entity)) {
                _ = selected_entities.swapRemove(index);
            }
        }
    }

    //Duplicate
    if (imgui.igIsKeyDown_Nil(imgui.ImGuiKey_LeftCtrl) and
        imgui.igIsKeyPressed_Bool(imgui.ImGuiKey_D, false) and
        // !state.cloned_entity_last_frame and
        selected_entities.items.len != 0)
    {
        for (selected_entities.items) |entity| {
            commands.entityClone(entity);
        }
    }

    if (selected_entities.items.len != 0 and imgui.igIsKeyPressed_Bool(imgui.ImGuiKey_Delete, false)) {
        for (selected_entities.items) |entity| {
            commands.entityDestroy(entity);
        }
    }

    if (imgui.igIsMouseClicked_Bool(imgui.ImGuiMouseButton_Left, false) and
        // !imguizmo.ImGuizmo_IsUsing() and
        // !imguizmo.ImGuizmo_IsOver() and
        !imgui.igIsAnyItemFocused())
    {
        var mouse_pos_imgui: imgui.ImVec2 = undefined;

        imgui.igGetMousePos(&mouse_pos_imgui);

        const mouse_pos = @Vector(2, f32){ mouse_pos_imgui.x, mouse_pos_imgui.y };

        var light_query = ecs_scene.query(.{
            quanta.components.Position,
            // quanta.components.PointLight,
        }, .{});

        const camera_view = camera.getView();
        const camera_projection = camera.getProjectionNonInverse(window);
        const camera_view_projection = zalgebra.Mat4.mul(.{ .data = camera_projection }, .{ .data = camera_view });

        var found_entity: ?quanta.ecs.ComponentStore.Entity = null;
        var found_entity_position: @Vector(3, f32) = .{ std.math.floatMax(f32), std.math.floatMax(f32), std.math.floatMax(f32) };

        while (light_query.nextBlock()) |block| {
            for (block.entities, block.Position) |entity, position| {
                const viewport = imgui.igGetWindowViewport();

                const position_vector = @Vector(3, f32){ position.x, position.y, position.z };

                const screen_pos = widgets.worldToScreenPos(position_vector, camera_view_projection, viewport) orelse continue;

                const selector_radius = 10;

                if (mouse_pos[0] > screen_pos[0] - selector_radius and mouse_pos[1] > screen_pos[1] - selector_radius and
                    mouse_pos[0] < screen_pos[0] + selector_radius and mouse_pos[1] < screen_pos[1] + selector_radius)
                {
                    found_entity_position = @min(found_entity_position, position_vector);

                    if (@reduce(.And, found_entity_position == position_vector)) {
                        found_entity = entity;
                    }
                }
            }
        }

        if (found_entity != null) {
            if (!imgui.igIsKeyDown_Nil(imgui.ImGuiKey_LeftCtrl)) {
                selected_entities.clearAndFree();
            }

            const contains_entity: bool = block: for (selected_entities.items) |selected_entity| {
                if (selected_entity == found_entity.?) {
                    break :block true;
                }
            } else false;

            if (!contains_entity) {
                try selected_entities.append(found_entity.?);
            }
        }
    }
}

pub fn entityViewer(
    ecs_scene: *ComponentStore,
    commands: *CommandBuffer,
    selected_entities: *std.ArrayList(Entity),
) void {
    defer widgets.end();

    if (!widgets.begin("Entity Debugger")) return;

    var query = ecs_scene.query(.{}, .{});

    while (query.nextBlock()) |block| {
        for (block.entities) |entity| {
            if (imgui.igBeginDragDropSource(imgui.ImGuiDragDropFlags_SourceAllowNullID)) {
                defer imgui.igEndDragDropSource();

                _ = imgui.igSetDragDropPayload("Entity Drag Drop", &entity, @sizeOf(@TypeOf(entity)), imgui.ImGuiCond_None);
            }

            var selected: bool = false;

            for (selected_entities.items) |selected_entity| {
                if (entity == selected_entity) {
                    selected = true;
                }
            }

            if (widgets.treeNodePush("{}", .{entity}, selected)) {
                defer widgets.treeNodePop();

                if (widgets.button("Clone")) {
                    commands.entityClone(entity);
                }

                imgui.igSameLine(0, 10);

                if (widgets.button("Clear")) {
                    commands.entityClear(entity);
                }

                imgui.igSameLine(0, 10);

                if (widgets.button("Destroy")) {
                    commands.entityDestroy(entity);
                }

                for (ecs_scene.entityGetComponentTypes(entity)) |component_type_info| {
                    imgui.igSeparator();

                    if (widgets.collapsingHeader("{s}", .{component_type_info.name()})) {
                        var header_min: imgui.ImVec2 = undefined;
                        var header_max: imgui.ImVec2 = undefined;

                        imgui.igGetItemRectMin(&header_min);
                        imgui.igGetItemRectMin(&header_max);

                        imgui.igPushID_Str(component_type_info.name().ptr);
                        defer imgui.igPopID();

                        if (widgets.button("Remove Component")) {
                            commands.addCommand(.{ .remove_component = .{
                                .entity = entity,
                                .component_id = component_type_info,
                            } });
                        }

                        if (component_type_info == quanta.reflect.Type.info(ComponentStore.Entity)) {
                            const ptr_to_entity = @as(*ComponentStore.Entity, @ptrCast(@alignCast(ecs_scene.entityGetComponentPtr(entity, component_type_info))));

                            if (imgui.igBeginDragDropTarget()) {
                                defer imgui.igEndDragDropTarget();

                                const payload = imgui.igAcceptDragDropPayload("Entity Drag Drop", imgui.ImGuiDragDropFlags_AcceptBeforeDelivery);

                                if (!payload.*.Preview) {
                                    const dragged_entity = @as(*ComponentStore.Entity, @ptrCast(@alignCast(payload.*.Data.?)));

                                    ptr_to_entity.* = dragged_entity.*;
                                }
                            }

                            if (ecs_scene.entityExists(ptr_to_entity.*)) {
                                if (imgui.igSmallButton("x")) {
                                    ptr_to_entity.* = ComponentStore.Entity.nil;
                                }

                                imgui.igSameLine(0, 5);
                            }

                            if (ecs_scene.entityExists(ptr_to_entity.*)) {
                                widgets.textFormat("{}", .{ptr_to_entity.*});
                            } else {
                                widgets.text("null");
                            }
                        } else {
                            //Find meta data related to this editor
                            const edit_info = component_type_info.*.getDecl("editor");

                            switch (component_type_info.*) {
                                .Struct => |struct_info| {
                                    for (struct_info.fields) |field| {
                                        const field_editor_info = if (edit_info == null) null else edit_info.?.type.getStructField(field.name);

                                        switch (field.type.*) {
                                            .Bool => {
                                                const ptr_to_struct = ecs_scene.entityGetComponentPtr(entity, component_type_info);
                                                const ptr_to_field = @as([*]u8, @ptrCast(ptr_to_struct)) + field.offset;

                                                const ptr_to_bool = @as(*bool, @ptrCast(ptr_to_field));

                                                _ = imgui.igCheckbox(field.name.ptr, ptr_to_bool);
                                            },
                                            .Int => unreachable,
                                            .Float => {
                                                const ptr_to_struct = ecs_scene.entityGetComponentPtr(entity, component_type_info);

                                                const ptr_to_field = @as([*]u8, @ptrCast(ptr_to_struct)) + field.offset;

                                                const ptr_to_float: *f32 = @as(*f32, @ptrCast(@alignCast(ptr_to_field)));

                                                widgets.dragFloat(field.name, ptr_to_float);
                                            },
                                            .Array => |array_info| {
                                                const ptr_to_array = @as([*]u8, @ptrCast(ecs_scene.entityGetComponentPtr(entity, component_type_info))) + field.offset;

                                                switch (array_info.len) {
                                                    1 => unreachable,
                                                    2 => unreachable,
                                                    3 => {
                                                        const array_ptr_f32 = @as(*f32, @ptrCast(@alignCast(ptr_to_array)));

                                                        if (field_editor_info == null) {
                                                            _ = imgui.igDragFloat3(field.name.ptr, array_ptr_f32, 0.1, std.math.floatMin(f32), std.math.floatMax(f32), null, 0);

                                                            continue;
                                                        }

                                                        widgets.textFormat("{any}", .{field_editor_info});

                                                        const edit_type_field = field_editor_info.?.type.getStructField("edit_type");

                                                        const edit_type_ptr = quanta.reflect.Type.getStructFieldValue([]const u8, edit_info.?.value, edit_type_field.?);

                                                        widgets.textFormat("edit_type = {s}", .{edit_type_ptr.*});

                                                        if (std.mem.eql(u8, edit_type_ptr.*, "color")) {
                                                            _ = imgui.igColorEdit3(field.name.ptr, array_ptr_f32, 0);
                                                        } else {
                                                            _ = imgui.igDragFloat3(field.name.ptr, array_ptr_f32, 0.1, std.math.floatMin(f32), std.math.floatMax(f32), null, 0);
                                                        }
                                                    },
                                                    else => unreachable,
                                                }
                                            },
                                            else => {
                                                widgets.textFormat("{s} = {*}", .{ field.name, ecs_scene.entityGetComponentPtr(entity, component_type_info) });
                                            },
                                        }
                                    }
                                },
                                .Enum => |enum_info| {
                                    const ptr_to_enum = @as([*]u8, @ptrCast(ecs_scene.entityGetComponentPtr(entity, component_type_info)));

                                    var items: [256][*c]const u8 = undefined;

                                    for (enum_info.fields, 0..) |field, i| {
                                        items[i] = field.name.ptr;
                                    }

                                    var current_item: c_int = @as(c_int, @intCast(ptr_to_enum[0]));

                                    if (imgui.igCombo_Str_arr("value", &current_item, &items, @as(c_int, @intCast(enum_info.fields.len)), 0)) {
                                        ptr_to_enum[0] = @as(u8, @intCast(current_item));
                                    }
                                },
                                .Union => |union_info| {
                                    const ptr_to_enum = @as([*]u8, @ptrCast(ecs_scene.entityGetComponentPtr(entity, component_type_info))) + union_info.tag_offset;

                                    var items: [256][*c]const u8 = undefined;

                                    for (union_info.fields, 0..) |field, i| {
                                        items[i] = field.name.ptr;

                                        widgets.textFormat("{s}", .{field.name});
                                    }

                                    var current_item: c_int = @as(c_int, @intCast(ptr_to_enum[0]));

                                    if (imgui.igCombo_Str_arr("value", &current_item, &items, @as(c_int, @intCast(union_info.fields.len)), 0)) {
                                        ptr_to_enum[0] = @as(u8, @intCast(current_item));
                                    }

                                    for (union_info.fields, 0..) |field, i| {
                                        if (i != @as(usize, @intCast(current_item))) {
                                            // continue;
                                        }

                                        widgets.textFormat("{s}", .{field.name});

                                        switch (field.type.*) {
                                            .Int => |int_info| {
                                                widgets.textFormat("{}", .{int_info});
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
    }
}

pub fn chunkViewer(
    ecs_scene: *ComponentStore,
) void {
    defer widgets.end();

    if (!widgets.begin("Entity Chunk Viewer")) return;

    var total_chunk_entity_count: usize = 0;
    var total_used_chunk_entity_count: usize = 0;

    var total_chunk_size: usize = 0;

    for (ecs_scene.archetypes.items[1..]) |archetype| {
        for (archetype.chunks.items) |chunk| {
            if (chunk.data == null) continue;

            total_chunk_entity_count += chunk.max_row_count;
            total_used_chunk_entity_count += chunk.row_count;

            total_chunk_size += chunk.data.?.len;
        }
    }

    widgets.textFormat("total entity utilization: {d:.1}%", .{(@as(f32, @floatFromInt(total_used_chunk_entity_count)) / @as(f32, @floatFromInt(total_chunk_entity_count))) * 100.0});

    const log_2_size = std.math.log2_int(usize, total_chunk_size);

    switch (log_2_size) {
        10...19 => {
            widgets.textFormat("total size: {}kb", .{total_chunk_size / 1024});
        },
        20...29 => {
            widgets.textFormat("total size: {}mb", .{total_chunk_size / (1024 * 1024)});
        },
        else => {
            widgets.textFormat("total size: {}b", .{total_chunk_size});
        },
    }

    for (ecs_scene.archetypes.items[1..], 1..) |archetype, archetype_index| {
        for (archetype.chunks.items, 0..) |chunk, chunk_index| {
            if (chunk.data == null) continue;

            imgui.igSeparator();

            if (widgets.collapsingHeader("Chunk ({}):({})", .{ archetype_index, chunk_index })) {
                widgets.textFormat("alignment: {}", .{quanta.ecs.ComponentStore.Chunk.alignment});
                widgets.textFormat("size: {}", .{chunk.data.?.len});
                widgets.textFormat("address: {x}", .{@intFromPtr(chunk.data.?.ptr)});
                widgets.textFormat("entity_count: {}", .{chunk.row_count});
                widgets.textFormat("max_entity_count: {}", .{chunk.max_row_count});
                widgets.textFormat("entity utilization: {d:.1}%", .{(@as(f32, @floatFromInt(chunk.row_count)) / @as(f32, @floatFromInt(chunk.max_row_count))) * 100.0});
            }
        }
    }
}
