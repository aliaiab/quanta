//!Optional debugging code for tracking and introspecting the various parts of a render graph

///TODO: allow root source file to specify this like in std.Options
pub const debug_info_enabled = @import("builtin").mode == .Debug;

///Debug information about the source code that generated a graph
///This type is equal to the empty struct when debugging is disabled
///Functions returning void can be safely relied upon without need for upfront checking on the consuming code side
///Functions returning a value will return null if debug info is disabled
pub const DebugInfo = if (debug_info_enabled) struct {
    passes: std.AutoArrayHashMapUnmanaged(graph.PassHandle, struct {
        source_location: std.builtin.SourceLocation,
        pass_name: ?[]const u8 = null,
    }) = .{},
    file_map: std.StringHashMapUnmanaged(struct {
        source_code: []u8,
    }) = .{},

    pub fn deinit(self: *@This(), builder: Builder) void {
        for (self.passes.values()) |pass| {
            if (pass.pass_name == null) continue;

            builder.allocator.free(pass.pass_name.?);
        }

        self.passes.deinit(builder.allocator);

        var file_map_values = self.file_map.valueIterator();

        while (file_map_values.next()) |file_data| {
            builder.allocator.free(file_data.source_code);
        }

        self.file_map.deinit(builder.allocator);

        self.* = undefined;
    }

    pub fn reset(self: *@This(), builder: Builder) void {
        _ = self;
        _ = builder;
    }

    pub fn addPass(
        self: *@This(),
        builder: Builder,
        comptime src: std.builtin.SourceLocation,
        pass_index: u32,
    ) void {
        const pass_handle = builder.passes.items(.handle)[pass_index];

        _ = self.passes.getOrPutValue(builder.allocator, pass_handle, .{
            .source_location = src,
        }) catch unreachable;
    }

    ///Parses the zig files associated with passes and resources to find their names
    ///Lazily loads and analyzes file data into memory
    pub fn getPassName(self: *@This(), builder: Builder, pass: graph.PassHandle) ?[]const u8 {
        var pass_info = self.passes.getPtr(pass) orelse return null;

        if (pass_info.pass_name == null) {
            const pass_source: std.builtin.SourceLocation = pass_info.source_location;

            const file_data = self.file_map.getOrPut(builder.allocator, pass_source.file) catch unreachable;

            if (!file_data.found_existing) {
                //TODO: only read source in when trying to read debug info
                const file_source = std.fs.cwd().readFileAlloc(builder.allocator, pass_source.file, std.math.maxInt(usize)) catch unreachable;

                file_data.value_ptr.* = .{
                    .source_code = file_source,
                };
            }

            const file_source: []const u8 = file_data.value_ptr.source_code;

            var pass_line_comment: ?[]const u8 = null;
            var pass_line: []const u8 = "";
            var pass_line_index: u32 = 0;

            {
                var line_index: u32 = 1;

                var source_lines = std.mem.splitScalar(u8, file_source, '\n');

                var previous_line: []const u8 = "";

                while (source_lines.next()) |source_line| : (line_index += 1) {
                    defer previous_line = source_line;

                    if (line_index + 1 == pass_source.line) {
                        const is_comment = std.mem.containsAtLeast(u8, source_line, 1, "//");

                        if (is_comment) {
                            pass_line_comment = source_line;
                        }

                        //If the pass call has it's args split between multiple lines, then
                        //the @src() builtin will have a comma after it.
                        //We have made it in graph.Builder that @src() will ALWAYS be the first argument (after self)
                        const is_multiline = std.mem.endsWith(u8, source_lines.peek().?, ",");

                        if (is_multiline) {
                            pass_line = source_line;
                            break;
                        }
                    }

                    if (line_index == pass_source.line) {
                        pass_line = source_line;
                        break;
                    }
                }

                pass_line_index = line_index - 1;

                source_lines.reset();

                line_index = 0;

                while (source_lines.next()) |source_line| : (line_index += 1) {
                    if (line_index + 1 == pass_line_index) {
                        const is_comment = std.mem.containsAtLeast(u8, source_line, 1, "//");

                        if (is_comment) {
                            const comment_start = std.mem.indexOf(u8, source_line, "//").?;

                            pass_line_comment = source_line[comment_start..];
                            break;
                        }
                    }
                }
            }

            const name = std.mem.concat(builder.allocator, u8, &.{
                std.fs.path.stem(std.fs.path.basename(pass_source.file)),
                ".",
                pass_source.fn_name,
                "(...)",
                ": ",
                pass_line_comment orelse "",
            }) catch unreachable;

            pass_info.pass_name = name;
        }

        return pass_info.pass_name orelse null;
    }
} else struct {
    passes: void,

    pub inline fn deinit(_: *@This(), _: Builder) void {}
    pub inline fn reset(_: *@This()) void {}
    pub inline fn addPass(_: *@This(), _: Builder, _: std.builtin.SourceLocation) void {}

    pub inline fn getPassName(_: *@This(), _: Builder, _: graph.PassHandle) ?[]const u8 {
        return null;
    }
};

test {
    std.testing.refAllDecls(@This());
}

const std = @import("std");
const graph = @import("graph.zig");
const Builder = graph.Builder;
