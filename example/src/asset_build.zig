const std = @import("std");
const quanta = @import("quanta");
const asset = quanta.asset;
const gltf = quanta.asset.importers.gltf;
const png = quanta.asset.importers.png;

pub fn main() !void {
    std.log.info("Building assets:", .{});

    const cache_directory = "zig-out/bin/assets/";

    std.fs.cwd().makeDir(cache_directory) catch {};

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer std.debug.assert(gpa.deinit() != .leak);

    const allocator = gpa.allocator();

    var assets = std.ArrayListUnmanaged(asset.Archive.AssetDescription){};
    defer assets.deinit(allocator);

    const gm_construct_bsp = try quanta.asset.importers.bsp.importFile(allocator, "example/src/assets/gm_construct.bsp");
    defer quanta.asset.importers.bsp.importFree(allocator, gm_construct_bsp);

    const gm_construct_gltf = try quanta.asset.importers.bsp.convertToGltfImport(allocator, gm_construct_bsp);

    const gm_construct_gltf_encoded = try gltf.encode(allocator, gm_construct_gltf);

    try assets.append(allocator, .{
        .name = "example/src/assets/gm_construct.bsp",
        .source_data = gm_construct_gltf_encoded,
        .source_data_alignment = @alignOf(gltf.ImportBinHeader),
        .mapped_data_size = gm_construct_gltf_encoded.len,
    });

    const gm_castle_island_bsp = try quanta.asset.importers.bsp.importFile(allocator, "example/src/assets/gm_castle_island.bsp");
    defer quanta.asset.importers.bsp.importFree(allocator, gm_castle_island_bsp);

    const gm_castle_island_gltf = try quanta.asset.importers.bsp.convertToGltfImport(allocator, gm_castle_island_bsp);

    const gm_castle_island_gltf_encoded = try gltf.encode(allocator, gm_castle_island_gltf);

    try assets.append(allocator, .{
        .name = "example/src/assets/gm_castle_island.bsp",
        .source_data = gm_castle_island_gltf_encoded,
        .source_data_alignment = @alignOf(gltf.ImportBinHeader),
        .mapped_data_size = gm_castle_island_gltf_encoded.len,
    });

    var environment_map = try png.importCubeFile(allocator, [_][]const u8{
        "example/src/assets/skybox/right.png", //x+
        "example/src/assets/skybox/left.png", //x-
        "example/src/assets/skybox/top.png", //y+
        "example/src/assets/skybox/bottom.png", //y-
        "example/src/assets/skybox/back.png", //z+
        "example/src/assets/skybox/front.png", //z-
    });
    defer png.free(&environment_map, allocator);

    try assets.append(allocator, .{
        .name = "example/src/assets/skybox/right.png",
        .source_data = environment_map.data,
        .source_data_alignment = @alignOf(u32),
        .mapped_data_size = environment_map.data.len,
    });

    if (false) {
        const ZonTest = struct {
            optimize: std.builtin.OptimizeMode,
            scale: f32 = 1,
            lod_count: u32 = 0,
            union_test: union(enum) {
                int: u32,
                float: f32,
            } = .{ .int = 1 },
            struct_init: struct {
                lol: []const u8,
            } = .{ .lol = "default_lol" },
            array: @Vector(4, f32) = .{ 0, 0, 0, 0 },
            slice: []const f32,
            optional: ?bool = null,
        };

        const zon_test = try asset.metadata.load(ZonTest, allocator, "example/src/assets/light_test/light_test.gltf.zon");
        defer asset.metadata.loadFree(ZonTest, allocator, zon_test);

        // std.log.info("zon_test: {any}", .{zon_test});
        // std.log.info("zon_test.struct_init.lol = {s}", .{zon_test.struct_init.lol});

        // return;
    }

    const test_scene = try gltf.importZgltf(allocator, "example/src/assets/shambler/scene.gltf");
    defer gltf.importFree(test_scene, allocator);

    const test_scene_encoded = try gltf.encode(allocator, test_scene);

    try assets.append(allocator, .{
        .name = "example/src/assets/test_scene/test_scene.gltf",
        .source_data = test_scene_encoded,
        .source_data_alignment = @alignOf(gltf.ImportBinHeader),
        .mapped_data_size = test_scene_encoded.len,
    });

    const asset_archive = try asset.Archive.encode(allocator, assets.items);

    const asset_archive_file = std.fs.cwd().openFile(cache_directory ++ "example_assets_archive", .{ .mode = .write_only }) catch try std.fs.cwd().createFile(cache_directory ++ "example_assets_archive", .{});
    defer asset_archive_file.close();

    try asset_archive_file.setEndPos(0);
    try asset_archive_file.seekTo(0);

    std.log.info("length of asset archive = {}", .{asset_archive.len});

    try asset_archive_file.writeAll(asset_archive);
}
