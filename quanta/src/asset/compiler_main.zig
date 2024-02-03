//! The program responsible for compiling all the assets in a project

pub fn iterateDirectory(
    context: *compiler.CompilerContext,
    directory: std.fs.Dir,
    directory_path: []const u8,
) !void {
    var asset_directory_iterator = directory.iterate();

    while (try asset_directory_iterator.next()) |entry| {
        switch (entry.kind) {
            .directory => {
                const sub_directory_path = try std.fs.path.join(context.allocator, &.{ directory_path, entry.name });
                defer context.allocator.free(sub_directory_path);

                std.log.info("sub_directory_path = {s}", .{sub_directory_path});

                var sub_directory = try std.fs.cwd().openDir(sub_directory_path, .{ .iterate = true });
                defer sub_directory.close();

                try iterateDirectory(context, sub_directory, sub_directory_path);
            },
            .file => {
                std.log.info("Potential asset file: {s}", .{entry.name});

                const metadata_path = try std.mem.concat(context.allocator, u8, &[_][]const u8{ entry.name, ".zon" });
                defer context.allocator.free(metadata_path);

                const metadata_file = directory.openFile(metadata_path, .{}) catch null;
                defer if (metadata_file != null) metadata_file.?.close();

                if (metadata_file != null) {
                    std.log.info("metadata file: {s}", .{metadata_path});

                    const path = try std.fs.path.join(context.allocator, &[_][]const u8{ directory_path, entry.name });
                    defer context.allocator.free(path);

                    std.log.info("path: {s}", .{path});

                    try context.compile(path);
                }
            },
            else => {},
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (false) std.debug.assert(gpa.deinit() != .leak);

    const allocator = gpa.allocator();

    var process_args = std.process.args();

    _ = process_args.next();

    const optimize_mode = process_args.next().?;

    std.log.info("assets root optimize_mode = {s}", .{optimize_mode});

    //TODO: allow for multiple asset directories
    const asset_directory_path = process_args.next().?;

    const install_directory = process_args.next().?;
    const archive_name = process_args.next().?;

    var previous_exists: bool = true;

    const archive_path = try std.fs.path.join(allocator, &.{ install_directory, archive_name });
    defer allocator.free(archive_path);

    const asset_archive_file = std.fs.cwd().openFile(
        archive_path,
        .{ .mode = .read_write },
    ) catch blk: {
        previous_exists = false;

        break :blk try std.fs.cwd().createFile(archive_path, .{});
    };
    defer asset_archive_file.close();

    var previous_archive = Archive{
        .image = &.{},
        .assets = &.{},
        .asset_content = &.{},
        .asset_name_hashes = &.{},
        .asset_content_hashes = &.{},
    };

    if (previous_exists) {
        //TODO: only read headers and lazily load old artifacts
        // var previous_archive = try Archive.decodeHeaderOnlyFromFile(allocator, asset_archive_file);
        const archive_all = try asset_archive_file.readToEndAlloc(allocator, std.math.maxInt(usize));
        previous_archive = try Archive.decode(allocator, archive_all);
    }

    defer if (previous_exists) previous_archive.decodeFree(allocator);

    const asset_compilers = [_]compiler.AssetCompilerInfo{
        compiler.AssetCompilerInfo.fromType(importers.gltf.Import),
        compiler.AssetCompilerInfo.fromType(CubeMap),
    };

    var context = compiler.CompilerContext{
        .allocator = allocator,
        .compilers = &asset_compilers,
        .file_paths = &.{},
        .assets = .{},
        .directory_path = asset_directory_path,
        .hasher = std.Build.Cache.Hasher.init("ASSET" ++ [_]u8{0} ** 11),
        .previous_archive = previous_archive,
        .compiled_asset_count = 0,
    };
    defer context.deinit();

    var sub_directory = try std.fs.cwd().openDir(context.directory_path, .{ .iterate = true });
    try iterateDirectory(&context, sub_directory, context.directory_path);
    sub_directory.close();

    for (context.assets.items, 0..) |asset_desc, i| {
        std.log.info("Asset[{}]: size = {}, content_hash = 0x{x}", .{
            i,
            asset_desc.mapped_data_size,
            asset_desc.content_hash,
        });
    }

    std.log.info("Recompiled {} assets", .{context.compiled_asset_count});

    const asset_archive = try Archive.encode(allocator, context.assets.items);

    try asset_archive_file.setEndPos(0);
    try asset_archive_file.seekTo(0);

    std.log.info("length of asset archive = {}", .{asset_archive.len});

    try asset_archive_file.writeAll(asset_archive);
}

const std = @import("std");
const quanta = @import("quanta");
const compiler = quanta.asset.compiler;
const zon = quanta.zon;
const importers = quanta.asset.importers;
const CubeMap = quanta.asset.CubeMap;
const Archive = quanta.asset.Archive;
