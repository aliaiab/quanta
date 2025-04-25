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

                log.info("sub_directory_path = {s}", .{sub_directory_path});

                var sub_directory = try std.fs.cwd().openDir(sub_directory_path, .{ .iterate = true });
                defer sub_directory.close();

                try iterateDirectory(context, sub_directory, sub_directory_path);
            },
            .file => {
                log.info("Potential asset file: {s}", .{entry.name});

                const metadata_path = try std.mem.concat(context.allocator, u8, &[_][]const u8{ entry.name, ".zon" });
                defer context.allocator.free(metadata_path);

                const metadata_file = directory.openFile(metadata_path, .{}) catch null;
                defer if (metadata_file != null) metadata_file.?.close();

                const path = try std.fs.path.join(context.allocator, &[_][]const u8{ directory_path, entry.name });
                defer context.allocator.free(path);

                log.info("metadata file: {s}", .{metadata_path});
                log.info("path: {s}", .{path});

                if (metadata_file != null) {
                    const metadata = try metadata_file.?.readToEndAllocOptions(
                        context.allocator,
                        std.math.maxInt(usize),
                        null,
                        .fromByteUnits(@alignOf(u8)),
                        0,
                    );
                    defer context.allocator.free(metadata);

                    try context.compile(path, metadata);
                } else {
                    try context.compile(path, null);
                }
            },
            else => {},
        }
    }
}

pub fn main() !void {
    //TODO: We don't actually have to necessarily free most data
    //as this is usually a short lived program---apart from source and archive data, which will result in a large rss
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer if (false) std.debug.assert(gpa.deinit() != .leak);

    const allocator = std.heap.smp_allocator;

    var process_args = std.process.args();

    _ = process_args.next();

    const optimize_mode = process_args.next().?;

    log.info("assets root optimize_mode = {s}", .{optimize_mode});

    //TODO: allow for multiple asset directories
    const asset_directory_path = process_args.next().?;

    const install_directory = process_args.next().?;
    const archive_name = process_args.next().?;

    var previous_exists: bool = true;

    const archive_path = try std.fs.path.join(allocator, &.{ install_directory, archive_name });
    defer allocator.free(archive_path);

    log.info("Archive path: {s}", .{archive_path});

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
        previous_archive = try Archive.decodeHeaderOnlyFromFile(allocator, asset_archive_file);
        // const archive_all = try asset_archive_file.readToEndAlloc(allocator, std.math.maxInt(usize));
        // previous_archive = try Archive.decode(allocator, previous_archive_data);

        log.info("Previous archive exists: count: {}", .{previous_archive.assets.len});
    }

    // defer if (previous_exists) previous_archive.decodeFree(allocator);

    const asset_compilers = [_]compiler.AssetCompilerInfo{
        // compiler.AssetCompilerInfo.fromType(frontends.gltf.Import),
        // compiler.AssetCompilerInfo.fromType(CubeMap),
        // compiler.AssetCompilerInfo.fromType(frontends.png.Import),
        compiler.AssetCompilerInfo.fromType(frontends.aseprite.Import),
    };

    var context = compiler.CompilerContext{
        .allocator = allocator,
        .compilers = &asset_compilers,
        .file_paths = &.{},
        .assets = .{},
        .directory_path = asset_directory_path,
        .hasher = std.Build.Cache.Hasher.init("ASSET" ++ [_]u8{0} ** 11),
        .previous_archive = previous_archive,
        .archive_path = archive_path,
        .compiled_asset_count = 0,
    };
    defer context.deinit();

    var sub_directory = try std.fs.cwd().openDir(context.directory_path, .{ .iterate = true });
    try iterateDirectory(&context, sub_directory, context.directory_path);
    sub_directory.close();

    for (context.assets.items, 0..) |asset_desc, i| {
        log.info("Asset[{}]: size = {}, content_hash = 0x{x}", .{
            i,
            asset_desc.mapped_data_size,
            asset_desc.content_hash,
        });
    }

    log.info("Recompiled {} assets", .{context.compiled_asset_count});

    const asset_archive = try Archive.encode(std.heap.page_allocator, context.assets.items);

    try asset_archive_file.setEndPos(0);
    try asset_archive_file.seekTo(0);

    log.info("length of asset archive = {}", .{asset_archive.len});

    try asset_archive_file.writeAll(asset_archive);
}

pub const std_options: std.Options = .{
    .log_level = .err,
};

const std = @import("std");
const quanta = @import("quanta");
const compiler = quanta.asset.compiler;
const frontends = quanta.asset.frontends;
const CubeMap = quanta.asset.CubeMap;
const log = quanta.log;
const Archive = quanta.asset.Archive;
