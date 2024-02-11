pub fn renderGraphDebug(graph: quanta.rendering.graph.Builder) void {
    defer widgets.end();
    if (!widgets.beginWindow("Render Graph Debug", .{})) return;

    imgui.igColumns(2, "columns", true);
    defer imgui.igEndColumns();

    const Globals = struct {
        var editor_context: ?*node_editor.EditorContext = null;
        var first_frame: bool = true;
    };

    if (Globals.editor_context == null) {
        Globals.editor_context = node_editor.im_node_create_editor();
    }

    var pass_deps: std.ArrayListUnmanaged(u32) = .{};
    defer pass_deps.deinit(std.heap.c_allocator);

    createDepGraph(graph, &pass_deps);

    if (pass_deps.items.len == 0) return;

    defer Globals.first_frame = false;

    var selected_pass_index: ?u32 = null;

    {
        node_editor.im_node_set_current_editor(Globals.editor_context);
        node_editor.im_node_begin("Render Graph Debug", .{ .x = 0, .y = 0 });

        defer {
            var node_id: [1]u32 = undefined;

            const selected_node_count = node_editor.im_node_get_selected_nodes(&node_id, 1);

            if (selected_node_count >= 1) {
                selected_pass_index = node_id[0] - 1;
            }

            node_editor.im_node_end();
            node_editor.im_node_set_current_editor(null);
        }

        var unique_id: u32 = 1;

        var pass_infos: std.ArrayListUnmanaged(struct {
            input_pin: u32,
            output_pin: u32,
        }) = .{};
        defer pass_infos.deinit(std.heap.c_allocator);

        pass_infos.ensureTotalCapacityPrecise(std.heap.c_allocator, pass_deps.items.len) catch unreachable;

        for (pass_deps.items) |pass_index| {
            const pass_data = graph.passes.items(.data)[pass_index];

            const pass_id = graph.passes.items(.handle)[pass_index];
            _ = pass_id;

            defer if (Globals.first_frame) {
                node_editor.im_node_set_node_position(
                    @intCast(pass_index + 1),
                    .{
                        .x = 100 * @as(f32, @floatFromInt(pass_index)),
                        .y = 100 * @as(f32, @floatFromInt(pass_index)),
                    },
                );
            };

            node_editor.im_node_begin_node(@intCast(pass_index + 1));

            widgets.textFormat("Pass({s})[{}]", .{ @tagName(pass_data), pass_index + 1 });

            defer {
                node_editor.im_node_end_node();
                imgui.igSameLine(10, 10);
            }

            const input_pin: u32 = block: {
                node_editor.im_node_begin_pin(unique_id, .input);
                defer {
                    node_editor.im_node_end_pin();

                    unique_id += 1;
                }

                widgets.textFormat("-> In{}", .{unique_id});

                break :block unique_id;
            };

            const output_pin: u32 = block: {
                node_editor.im_node_begin_pin(unique_id, .output);
                defer {
                    node_editor.im_node_end_pin();
                    unique_id += 1;
                }

                widgets.textFormat("Out -> {}", .{unique_id});

                break :block unique_id;
            };

            pass_infos.append(std.heap.c_allocator, .{
                .input_pin = input_pin,
                .output_pin = output_pin,
            }) catch unreachable;
        }

        for (0..pass_deps.items.len) |reverse_dep_index| {
            const dep_index = pass_deps.items.len - reverse_dep_index - 1;
            const pass_index = pass_deps.items[dep_index];

            const input_offset = graph.passes.items(.input_offset)[pass_index];
            const input_count = graph.passes.items(.input_count)[pass_index];

            const command_offset = graph.passes.items(.command_offset)[pass_index];
            const command_count = graph.passes.items(.command_count)[pass_index];
            const command_data_offset = graph.passes.items(.command_data_offset)[pass_index];

            const output_pass_info = pass_infos.items[dep_index];

            for (0..input_count) |input_index| {
                const input_pass = graph.pass_inputs.items(.pass_index)[input_offset + input_index];

                const input_pass_info = pass_infos.items[getDepIndexFromPass(pass_deps.items, input_pass)];

                _ = node_editor.im_node_link(unique_id, input_pass_info.output_pin, output_pass_info.input_pin);

                //Currently disabled as this can create a lot of geometry for the flow beads, causing editor performance problems
                //Do the beads need to be so geometrically detailed? (They are only circles after all)
                if (false) {
                    node_editor.im_node_link_flow(unique_id, .forward);
                }

                unique_id += 1;
            }

            const iterator = graph.commands.iterator(
                command_offset,
                command_count,
                command_data_offset,
            );
            _ = iterator;
        }
    }

    imgui.igNextColumn();

    _ = imgui.igBeginChild_Str("Pass Content Viewer", .{}, 0, 0);
    defer imgui.igEndChild();

    widgets.textFormat("Passes: {}", .{graph.passes.len});

    for (graph.raster_pipelines.items(.reference_count), 0..) |reference_count, index| {
        widgets.textFormat("Referenced raster pipline[{}] {} times", .{ index, reference_count });
    }

    for (graph.buffers.items(.reference_count), 0..) |reference_count, index| {
        widgets.textFormat("Referenced buffer[{}] {} times", .{ index, reference_count });
    }

    if (selected_pass_index) |pass_index| {
        const pass_data = graph.passes.items(.data)[pass_index];
        const pass_id = graph.passes.items(.handle)[pass_index];
        _ = pass_id;
        _ = pass_data;

        // if (!widgets.treeNodePush("Pass({s}): {}", .{ @tagName(pass_data), pass_index }, false)) break :block;
        // defer widgets.treeNodePop();

        widgets.text("Commands:");
        imgui.igNewLine();

        const input_offset = graph.passes.items(.input_offset)[pass_index];
        const input_count = graph.passes.items(.input_count)[pass_index];

        const command_offset = graph.passes.items(.command_offset)[pass_index];
        const command_count = graph.passes.items(.command_count)[pass_index];
        const command_data_offset = graph.passes.items(.command_data_offset)[pass_index];

        for (0..input_count) |input_index| {
            const input_pass = graph.pass_inputs.items(.pass_index)[input_offset + input_index];

            widgets.textFormat("=> input[{}]: from pass #{}", .{
                input_index,
                input_pass,
            });
        }

        widgets.textFormat("pass_commands: count = {}", .{command_count});

        var iterator = graph.commands.iterator(
            command_offset,
            command_count,
            command_data_offset,
        );

        var command_index: u32 = 0;

        while (iterator.next()) |command| : (command_index += 1) {
            switch (command) {
                .draw_indexed => |draw_indexed| {
                    widgets.textFormat("[{}]: {s}({}, {}, {})", .{
                        command_index,
                        @tagName(command),
                        draw_indexed.index_count,
                        draw_indexed.instance_count,
                        draw_indexed.first_index,
                    });
                },
                else => {
                    widgets.textFormat("[{}]: {s}", .{ command_index, @tagName(command) });
                },
            }
        }
    }
}

fn getDepIndexFromPass(
    dependencies: []const u32,
    index: u32,
) usize {
    for (dependencies, 0..) |pass_index, dep_index| {
        if (pass_index == index) {
            return dep_index;
        }
    }

    unreachable;
}

fn createDepGraph(
    builder: quanta.rendering.graph.Builder,
    dependencies: *std.ArrayListUnmanaged(u32),
) void {
    if (builder.export_resource == null) return;

    const root_pass_index: u32 = switch (builder.export_resource.?) {
        .image => |image| image.from_pass.pass_index,
        .buffer => |buffer| buffer.from_pass.pass_index,
    };

    createDepGraphRecursive(builder, root_pass_index, dependencies) catch unreachable;
}

fn createDepGraphRecursive(
    builder: quanta.rendering.graph.Builder,
    pass_index: u32,
    dependencies: *std.ArrayListUnmanaged(u32),
) !void {
    const passes = &builder.passes;

    const input_offset = passes.items(.input_offset)[pass_index];
    const input_count = passes.items(.input_count)[pass_index];

    const pass_dependencies = try std.heap.c_allocator.alloc(u32, input_count);
    defer std.heap.c_allocator.free(pass_dependencies);

    var dependency_count: u32 = 0;

    for (0..input_count) |input_index| {
        const pass_dependency_index = builder.pass_inputs.items(.pass_index)[input_offset + input_index];

        const existing_index = block: for (pass_dependencies, 0..) |pass_dep, dependency_index| {
            if (pass_dep == pass_dependency_index) break :block dependency_index;
        } else dependency_count;

        const found_existing = existing_index != dependency_count;

        if (found_existing) continue;

        pass_dependencies[dependency_count] = pass_dependency_index;

        dependency_count += 1;
    }

    for (pass_dependencies[0..dependency_count]) |dep| {
        try createDepGraphRecursive(
            builder,
            dep,
            dependencies,
        );
    } else {
        try dependencies.append(std.heap.c_allocator, pass_index);
    }
}

const std = @import("std");
const quanta = @import("quanta");
const imgui = @import("../root.zig").cimgui;
const widgets = @import("widgets.zig");
const node_editor = @import("node_editor.zig");
