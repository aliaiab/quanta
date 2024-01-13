//! The program responsible for compiling all the assets in a project

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (false) std.debug.assert(gpa.deinit() != .leak);

    const allocator = gpa.allocator();

    const asset_compilers = [_]compiler.AssetCompilerInfo{
        compiler.AssetCompilerInfo.fromType(importers.gltf.Import),
    };

    var context = compiler.CompilerContext{
        .allocator = allocator,
        .compilers = &asset_compilers,
        .file_paths = &.{},
        .assets = .{},
    };
    defer context.deinit();

    const asset_directory_path = "example/src/assets/light_test/";

    var asset_directory = try std.fs.cwd().openDir(asset_directory_path, .{});
    defer asset_directory.close();

    var asset_directory_iterator = asset_directory.iterate();

    while (try asset_directory_iterator.next()) |entry| {
        std.log.info("Potential asset file: {s}", .{entry.name});

        const metadata_path = try std.mem.concat(allocator, u8, &[_][]const u8{ entry.name, ".zon" });
        defer allocator.free(metadata_path);

        const metadata_file = asset_directory.openFile(metadata_path, .{}) catch null;
        defer if (metadata_file != null) metadata_file.?.close();

        if (metadata_file != null) {
            std.log.info("metadata file: {s}", .{metadata_path});

            const path = try std.fs.path.join(allocator, &[_][]const u8{ asset_directory_path, entry.name });
            defer allocator.free(path);

            std.log.info("path: {s}", .{path});

            try context.compile(path);
        }
    }

    for (context.assets.items, 0..) |asset_desc, i| {
        std.log.info("Asset[{}] = {}", .{ i, asset_desc.mapped_data_size });
    }

    std.log.info("Hello from asset compile!", .{});

    // return error.Sus;
}

const std = @import("std");
const quanta = @import("quanta");
const compiler = quanta.asset.compiler;
const zon = quanta.zon;
const importers = quanta.asset.importers;
const Archive = quanta.asset.Archive;
