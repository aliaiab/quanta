const std = @import("std");

pub fn main() !void 
{
    std.log.info("hello from gltf_import_cmd!!", .{});

    // const import = try gltf.import(self.builder.allocator, self.source_path);
    // errdefer gltf.importFree(import, self.builder.allocator);

    // const import_encoded = try gltf.encode(self.builder.allocator, import);
}