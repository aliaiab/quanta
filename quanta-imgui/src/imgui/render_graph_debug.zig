pub fn renderGraphDebug(graph: *quanta.rendering.graph.Builder) void {
    defer widgets.end();
    if (!widgets.beginWindow("Render Graph Debug", .{})) return;

    const Globals = struct {
        var editor_context: ?*node_editor.EditorContext = null;
        var first_frame: bool = true;
    };

    if (Globals.editor_context == null) {
        Globals.editor_context = node_editor.im_node_create_editor();
    }

    if (!rendering.debug.debug_info_enabled) {
        widgets.text("Render graph debug info is disabled");
        return;
    }

    var pass_deps: std.ArrayListUnmanaged(u32) = .{};
    defer pass_deps.deinit(std.heap.c_allocator);

    createDepGraph(graph.*, &pass_deps);

    if (pass_deps.items.len == 0) return;

    defer Globals.first_frame = false;

    var selected_pass_index: ?u32 = null;

    imgui.igColumns(2, "columns", true);
    defer imgui.igEndColumns();

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
        }
    }

    imgui.igNextColumn();

    _ = imgui.igBeginChild_Str("Pass Content Viewer", .{}, 0, imgui.ImGuiWindowFlags_HorizontalScrollbar);
    defer imgui.igEndChild();

    if (selected_pass_index) |pass_index| {
        const pass_data = graph.passes.items(.data)[pass_index];
        const pass_handle = graph.passes.items(.handle)[pass_index];
        _ = pass_data;

        const pass_source: std.builtin.SourceLocation = graph.debug_info.passes.get(pass_handle).?.source_location;

        const pass_name = graph.debug_info.getPassName(graph.*, pass_handle);

        widgets.textFormat("fn {s}(...) from {s}:{}:{}", .{
            pass_source.fn_name,
            std.fs.path.basename(pass_source.file),
            pass_source.line,
            pass_source.column,
        });

        if (pass_name) |comment| {
            imgui.igPushStyleColor_Vec4(imgui.ImGuiCol_Text, .{ .x = 0, .y = 1 * 0.8, .z = 0.5 * 0.8, .w = 1 });

            widgets.text(comment);

            imgui.igPopStyleColor(1);
        }

        if (false) {
            var line_buffer: [1024]u8 = undefined;

            const line_text = std.fmt.bufPrintZ(&line_buffer, "{s}", .{"pass_line"}) catch unreachable;

            var tokenizer = std.zig.Tokenizer.init(line_text);

            var paren_depth: u32 = 1;

            var previous_token: ?std.zig.Token = null;

            while (tokenizer.index < tokenizer.buffer.len) {
                const token = tokenizer.next();
                defer previous_token = token;

                const trailing_text: []const u8 = if (previous_token != null) block: {
                    break :block tokenizer.buffer[previous_token.?.loc.end..token.loc.start];
                } else "";

                const token_text = tokenizer.buffer[token.loc.start..token.loc.end];

                const token_color: imgui.ImVec4 = switch (token.tag) {
                    .builtin => .{ .x = 0.93, .y = 0.7, .z = 0.5, .w = 1 },
                    .identifier => .{ .x = 0, .y = 0.5, .z = 0.9, .w = 1 },
                    .l_paren, .r_paren => switch (paren_depth % 2) {
                        0 => .{ .x = 0, .y = 0.2, .z = 0.8, .w = 1 },
                        1 => .{ .x = 0.6, .y = 0.4, .z = 0.01, .w = 1 },
                        else => unreachable,
                    },
                    else => .{ .x = 1, .y = 1, .z = 1, .w = 1 },
                };

                widgets.text(trailing_text);
                widgets.sameLine();

                imgui.igPushStyleColor_Vec4(imgui.ImGuiCol_Text, token_color);

                widgets.text(token_text);
                widgets.sameLine();

                imgui.igPopStyleColor(1);

                switch (token.tag) {
                    .l_paren => paren_depth += 1,
                    .r_paren => paren_depth -= 1,
                    else => {},
                }
            }

            imgui.igNewLine();
        }

        if (imgui.igBeginTabBar("Pass Information", 0)) {
            defer imgui.igEndTabBar();

            if (imgui.igBeginTabItem("Commands", null, 0)) {
                defer imgui.igEndTabItem();

                var iterator = graph.passCommandIterator(pass_index);

                var command_index: u32 = 0;

                while (iterator.next()) |command| : (command_index += 1) {
                    switch (command) {
                        .draw_indexed => |draw_indexed| {
                            widgets.textFormat("[{:0>2}]: {s}({}, {}, {})", .{
                                command_index,
                                @tagName(command),
                                draw_indexed.index_count,
                                draw_indexed.instance_count,
                                draw_indexed.first_index,
                            });
                        },
                        else => {
                            widgets.textFormat("[{:0>2}]: {s}", .{ command_index, @tagName(command) });
                        },
                    }
                }
            }

            if (imgui.igBeginTabItem("Input Resources", null, 0)) {
                defer imgui.igEndTabItem();

                const input_offset = graph.passes.items(.input_offset)[pass_index];
                const input_count = graph.passes.items(.input_count)[pass_index];

                for (0..input_count) |input_index| {
                    const input_pass = graph.pass_inputs.items(.pass_index)[input_offset + input_index];

                    widgets.textFormat("=> input[{}]: from pass #{}", .{
                        input_index,
                        input_pass,
                    });
                }
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
        .image => |image| image.pass_index.?,
        .buffer => |buffer| buffer.pass_index.?,
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
const rendering = quanta.rendering;
const imgui = @import("../root.zig").cimgui;
const widgets = @import("widgets.zig");
const node_editor = @import("node_editor.zig");
