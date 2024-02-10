pub fn renderGraphDebug(graph: quanta.rendering.graph.Builder) void {
    defer widgets.end();
    if (!widgets.beginWindow("Graph Debug", .{})) return;

    widgets.textFormat("Passes: {}", .{graph.passes.len});

    for (graph.raster_pipelines.items(.reference_count), 0..) |reference_count, index| {
        widgets.textFormat("Referenced raster pipline[{}] {} times", .{ index, reference_count });
    }

    for (graph.buffers.items(.reference_count), 0..) |reference_count, index| {
        widgets.textFormat("Referenced buffer[{}] {} times", .{ index, reference_count });
    }

    for (0..graph.passes.len) |pass_index| {
        const pass_data = graph.passes.items(.data)[pass_index];
        const pass_id = graph.passes.items(.handle)[pass_index];
        _ = pass_id;

        if (!widgets.treeNodePush("Pass({s}): {}", .{ @tagName(pass_data), pass_index }, false)) continue;
        defer widgets.treeNodePop();

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

const std = @import("std");
const quanta = @import("quanta");
const imgui = @import("../root.zig").cimgui;
const widgets = @import("widgets.zig");
