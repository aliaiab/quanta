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

        const output_offset = graph.passes.items(.output_offset)[pass_index];
        const output_count = graph.passes.items(.output_count)[pass_index];

        const command_offset = graph.passes.items(.command_offset)[pass_index];
        const command_count = graph.passes.items(.command_count)[pass_index];
        const command_data_offset = graph.passes.items(.command_data_offset)[pass_index];

        widgets.textFormat("pass_inputs: count = {}", .{input_count});

        for (0..input_count) |input_index| {
            widgets.textFormat("=> input[{}]: reference_count: {}", .{
                input_index,
                graph.pass_inputs.items(.reference_count)[input_offset + input_index],
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

        widgets.textFormat("pass_outputs: count = {}", .{output_count});

        for (0..output_count) |output_index| {
            widgets.textFormat("<= output[{}]: reference_count: {}", .{
                output_index,
                graph.pass_inputs.items(.reference_count)[output_offset + output_index],
            });
        }
    }
}

const std = @import("std");
const quanta = @import("quanta");
const imgui = @import("cimgui.zig");
const widgets = @import("widgets.zig");
