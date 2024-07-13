pub const graph = @import("rendering/graph.zig");
pub const compile = @import("rendering/compile.zig");
pub const debug = @import("rendering/debug.zig");

pub const Options = struct {
    ///Enables the use of debug info for graphics debuggers like renderdoc
    ///This will result in source files being loaded at runtime, which need to be available
    debug_info_enabled: bool = @import("builtin").mode == .Debug,
    debug_source_path: DebugSourcePath = .absolute,

    pub const DebugSourcePath = union(enum) {
        ///Uses absolute paths obtained from the @src() builtin
        absolute,
    };
};

test {
    @import("std").testing.refAllDecls(@This());
}
