const std = @import("std");
const Renderer3D = @import("../../renderer/Renderer3D.zig");
const zalgebra = @import("zalgebra");
const png = @import("png.zig");
const zgltf = @import("zgltf");
const AssetStorage = @import("../AssetStorage.zig");
const Asset = AssetStorage.Asset;

pub const Import = struct {
    vertex_positions: []Renderer3D.VertexPosition,
    vertices: []Renderer3D.Vertex,
    indices: []u32,
    sub_meshes: []SubMesh,
    materials: []Material,
    textures: []Texture,
    point_lights: []Renderer3D.PointLight,

    pub const SubMesh = extern struct {
        vertex_offset: u32,
        vertex_count: u32,
        index_offset: u32,
        index_count: u32,
        material_index: u32,
        transform: [4][4]f32,
        bounding_min: [3]f32,
        bounding_max: [3]f32,
    };

    pub const Material = extern struct {
        albedo: [4]f32,
        albedo_texture_index: u32,
        metalness: f32,
        metalness_texture_index: u32,
        roughness: f32,
        roughness_texture_index: u32,
    };

    pub const Texture = struct {
        data: []u8,
        width: u32,
        height: u32,
    };

    pub fn assetLoad(
        storage: *AssetStorage,
        handle: Asset(Import),
        asset: *Import,
        data: []u8,
    ) !void {
        _ = handle;

        asset.* = try decode(storage.allocator, data);
    }

    pub fn assetUnload(
        storage: *AssetStorage,
        handle: Asset(Import),
        asset: *Import,
    ) void {
        _ = handle;

        decodeFree(asset.*, storage.allocator);
    }
};

pub fn importZgltf(allocator: std.mem.Allocator, file_path: []const u8) !Import {
    var import_data: Import = .{
        .vertex_positions = &.{},
        .vertices = &.{},
        .indices = &.{},
        .sub_meshes = &.{},
        .materials = &.{},
        .textures = &.{},
        .point_lights = &.{},
    };

    const file_directory_name = std.fs.path.dirname(file_path) orelse unreachable;

    var file_directory = try std.fs.cwd().openDir(file_directory_name, .{});
    defer file_directory.close();

    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_data = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(file_data);

    var gltf = zgltf.init(allocator);
    defer gltf.deinit();

    try gltf.parse(file_data);

    const buffer_file_datas = try allocator.alloc([]const u8, gltf.data.buffers.items.len);
    defer allocator.free(buffer_file_datas);

    for (gltf.data.buffers.items, 0..) |buffer, i| {
        if (buffer.uri == null) continue;

        std.log.info("{s}", .{buffer.uri.?});

        const bin_file = try file_directory.openFile(buffer.uri.?, .{});
        defer bin_file.close();

        const bin_file_data = try bin_file.readToEndAlloc(allocator, std.math.maxInt(usize));

        buffer_file_datas[i] = bin_file_data;
    }

    defer for (buffer_file_datas) |buffer_file_data| {
        allocator.free(buffer_file_data);
    };

    const texture_count = gltf.data.textures.items.len;

    var model_vertices = std.ArrayList(Renderer3D.Vertex).init(allocator);
    errdefer model_vertices.deinit();

    var model_vertex_positions = std.ArrayList(Renderer3D.VertexPosition).init(allocator);
    errdefer model_vertex_positions.deinit();

    var model_indices = std.ArrayList(u32).init(allocator);
    errdefer model_indices.deinit();

    var sub_meshes = std.ArrayList(Import.SubMesh).init(allocator);
    errdefer sub_meshes.deinit();

    var textures = try std.ArrayList(Import.Texture).initCapacity(allocator, texture_count);
    errdefer textures.deinit();

    var materials = std.ArrayList(Import.Material).init(allocator);
    errdefer materials.deinit();

    var point_lights = std.ArrayList(Renderer3D.PointLight).init(allocator);
    errdefer point_lights.deinit();

    for (gltf.data.images.items) |image| {
        if (image.uri == null) continue;

        const path = image.uri.?;

        std.log.info("file path: {s}", .{path});

        const image_file = try file_directory.openFile(path, .{});
        defer image_file.close();

        const raw_data = try image_file.readToEndAlloc(allocator, std.math.maxInt(u64));
        defer allocator.free(raw_data);

        const png_import = try png.import(allocator, raw_data);

        try textures.append(.{
            .data = png_import.data,
            .width = png_import.width,
            .height = png_import.height,
        });
    }

    for (gltf.data.lights.items) |light| {
        switch (light.type) {
            .point => {
                try point_lights.append(Renderer3D.PointLight{
                    .position = .{ 0, 10, 0 },
                    .intensity = light.intensity,
                    .diffuse = std.math.maxInt(u32),
                });
            },
            else => continue,
        }
    }

    for (gltf.data.nodes.items) |node| {
        if (node.mesh == null) continue;

        const transform_matrix = zgltf.getGlobalTransform(&gltf.data, node);

        const mesh: *zgltf.Mesh = &gltf.data.meshes.items[node.mesh.?];

        std.log.info("mesh.primitive_count = {}", .{mesh.primitives.items.len});

        for (mesh.primitives.items) |primitive| {
            const vertex_start = model_vertices.items.len;
            const index_start = model_indices.items.len;

            var bounding_min: @Vector(3, f32) = .{ std.math.floatMax(f32), std.math.floatMax(f32), std.math.floatMax(f32) };
            var bounding_max: @Vector(3, f32) = .{ std.math.floatMin(f32), std.math.floatMin(f32), std.math.floatMin(f32) };

            var vertex_count: usize = 0;

            var positions = std.ArrayList(f32).init(allocator);
            defer positions.deinit();

            var normals = std.ArrayList(f32).init(allocator);
            defer normals.deinit();

            var texture_coordinates = std.ArrayList(f32).init(allocator);
            defer texture_coordinates.deinit();

            var colors = std.ArrayList(f32).init(allocator);
            defer colors.deinit();

            for (primitive.attributes.items) |attribute| {
                switch (attribute) {
                    .position => |accessor_index| {
                        const accessor = gltf.data.accessors.items[accessor_index];
                        const buffer_view = gltf.data.buffer_views.items[accessor.buffer_view.?];
                        const buffer_data = buffer_file_datas[buffer_view.buffer];

                        vertex_count = @as(usize, @intCast(accessor.count));

                        try positions.ensureTotalCapacity(@as(usize, @intCast(accessor.count)));

                        gltf.getDataFromBufferView(f32, &positions, accessor, buffer_data);
                    },
                    .normal => |accessor_index| {
                        const accessor = gltf.data.accessors.items[accessor_index];
                        const buffer_view = gltf.data.buffer_views.items[accessor.buffer_view.?];
                        const buffer_data = buffer_file_datas[buffer_view.buffer];

                        try normals.ensureTotalCapacity(@as(usize, @intCast(accessor.count)));

                        gltf.getDataFromBufferView(f32, &normals, accessor, buffer_data);
                    },
                    .tangent => {},
                    .texcoord => |accessor_index| {
                        const accessor = gltf.data.accessors.items[accessor_index];
                        const buffer_view = gltf.data.buffer_views.items[accessor.buffer_view.?];
                        const buffer_data = buffer_file_datas[buffer_view.buffer];

                        try texture_coordinates.ensureTotalCapacity(@as(usize, @intCast(accessor.count)));

                        gltf.getDataFromBufferView(f32, &texture_coordinates, accessor, buffer_data);
                    },
                    .color => |accessor_index| {
                        const accessor = gltf.data.accessors.items[accessor_index];
                        const buffer_view = gltf.data.buffer_views.items[accessor.buffer_view.?];
                        const buffer_data = buffer_file_datas[buffer_view.buffer];

                        try colors.ensureTotalCapacity(@as(usize, @intCast(accessor.count)));

                        std.debug.assert(accessor.component_type == .float);

                        gltf.getDataFromBufferView(f32, &colors, accessor, buffer_data);
                    },
                    .joints => {},
                    .weights => {},
                }
            }

            std.debug.assert(vertex_count != 0);

            try model_vertices.ensureTotalCapacity(model_vertices.items.len + vertex_count);

            //Vertices
            {
                var position_index: usize = 0;
                var normal_index: usize = 0;
                var uv_index: usize = 0;
                var color_index: usize = 0;

                std.log.info("vertex position accessor.count = {}", .{vertex_count});

                while (position_index < vertex_count * 3) : ({
                    position_index += 3;
                    normal_index += 3;
                    uv_index += 2;
                    color_index += 4;
                }) {
                    const position_source_x = positions.items[position_index];
                    const position_source_y = positions.items[position_index + 1];
                    const position_source_z = positions.items[position_index + 2];

                    const position_vector = @Vector(3, f32){ position_source_x, position_source_y, position_source_z };

                    const position_quantised = quantisePosition(position_vector);
                    const normal_quantised = quantiseNormal(.{ normals.items[normal_index], normals.items[normal_index + 1], normals.items[normal_index + 2] });
                    const uv_quantised = quantiseUV(.{ texture_coordinates.items[uv_index], texture_coordinates.items[uv_index + 1] });

                    std.log.info("vtx normal: {d}, {d}, {d}", .{ normals.items[normal_index], normals.items[normal_index + 1], normals.items[normal_index + 2] });
                    std.log.info("vtx normal quantised({b}): {}, {}, {}", .{ @as(u32, @bitCast(normal_quantised)), normal_quantised.x, normal_quantised.y, normal_quantised.z });

                    try model_vertex_positions.append(position_quantised);
                    try model_vertices.append(.{
                        .normal = normal_quantised,
                        .uv = uv_quantised,
                        .color = if (colors.items.len != 0) packUnorm4x8(.{ colors.items[color_index], colors.items[color_index + 1], colors.items[color_index + 2], 1 }) else packUnorm4x8(.{ 1, 1, 1, 1 }),
                    });

                    bounding_min = @min(bounding_min, position_vector);
                    bounding_max = @max(bounding_max, position_vector);
                }
            }

            std.log.info("bounding_min: {d}", .{bounding_min});
            std.log.info("bounding_max: {d}", .{bounding_max});

            //Indices
            {
                const index_accessor = gltf.data.accessors.items[primitive.indices.?];
                const buffer_view = gltf.data.buffer_views.items[index_accessor.buffer_view.?];
                const buffer_data = buffer_file_datas[buffer_view.buffer];

                switch (index_accessor.component_type) {
                    .byte => unreachable,
                    .unsigned_byte => unreachable,
                    .short => unreachable,
                    .unsigned_short => {
                        var indices_u16 = std.ArrayList(u16).init(allocator);
                        defer indices_u16.deinit();

                        gltf.getDataFromBufferView(u16, &indices_u16, index_accessor, buffer_data);

                        try model_indices.ensureTotalCapacity(indices_u16.items.len);

                        for (indices_u16.items) |index_u16| {
                            try model_indices.append(@as(u32, index_u16));
                        }
                    },
                    .unsigned_integer => {
                        gltf.getDataFromBufferView(u32, &model_indices, index_accessor, buffer_data);
                    },
                    .float => unreachable,
                }
            }

            const has_material = primitive.material != null;

            var material_index: u32 = 0;

            //material
            if (has_material) {
                const material = gltf.data.materials.items[primitive.material.?];

                const pbr = material.metallic_roughness;

                const has_albedo_texture = pbr.base_color_texture != null;

                const has_roughness_texture = pbr.metallic_roughness_texture != null;

                var albedo_index: ?u32 = null;

                if (has_albedo_texture) {
                    const albedo_texture = gltf.data.textures.items[pbr.base_color_texture.?.index];

                    albedo_index = @as(u32, @intCast(albedo_texture.source.?)) + 1;
                }

                var roughness_index: ?u32 = null;

                if (has_roughness_texture) {
                    const roughness_texture = gltf.data.textures.items[pbr.metallic_roughness_texture.?.index];

                    roughness_index = @as(u32, @intCast(roughness_texture.source.?)) + 1;
                }

                material_index = @as(u32, @intCast(materials.items.len));

                std.log.info("Material {any}", .{pbr});

                try materials.append(.{
                    .albedo = pbr.base_color_factor,
                    .albedo_texture_index = albedo_index orelse 0,
                    .roughness = pbr.roughness_factor,
                    .roughness_texture_index = roughness_index orelse 0,
                    .metalness = pbr.metallic_factor,
                    .metalness_texture_index = 0,
                });
            }

            try sub_meshes.append(.{
                .vertex_offset = @as(u32, @intCast(vertex_start)),
                .vertex_count = @as(u32, @intCast(model_vertices.items.len - vertex_start)),
                .index_offset = @as(u32, @intCast(index_start)),
                .index_count = @as(u32, @intCast(model_indices.items.len - index_start)),
                .material_index = material_index,
                .transform = transform_matrix,
                .bounding_min = bounding_min,
                .bounding_max = bounding_max,
            });
        }
    }

    std.log.info("unique vertex count: {}", .{model_vertices.items.len});
    std.log.info("rendered vertex count: {}", .{model_indices.items.len});

    _ = allocator.resize(model_vertex_positions.allocatedSlice(), model_vertex_positions.items.len);
    _ = allocator.resize(model_vertices.allocatedSlice(), model_vertices.items.len);
    _ = allocator.resize(model_indices.allocatedSlice(), model_indices.items.len);
    _ = allocator.resize(sub_meshes.allocatedSlice(), sub_meshes.items.len);
    _ = allocator.resize(materials.allocatedSlice(), materials.items.len);
    _ = allocator.resize(textures.allocatedSlice(), textures.items.len);
    _ = allocator.resize(point_lights.allocatedSlice(), point_lights.items.len);

    import_data.vertex_positions = model_vertex_positions.items;
    import_data.vertices = model_vertices.items;
    import_data.indices = model_indices.items;
    import_data.sub_meshes = sub_meshes.items;
    import_data.materials = materials.items;
    import_data.textures = textures.items;
    import_data.point_lights = point_lights.items;

    return import_data;
}

pub fn importFree(gltf_import: Import, allocator: std.mem.Allocator) void {
    allocator.free(gltf_import.vertex_positions);
    allocator.free(gltf_import.vertices);
    allocator.free(gltf_import.indices);
    allocator.free(gltf_import.sub_meshes);
    allocator.free(gltf_import.materials);
    allocator.free(gltf_import.textures);
    allocator.free(gltf_import.point_lights);
}

///Header for the binary format
pub const ImportBinHeader = packed struct {
    vertex_count: u32,
    index_count: u32,
    sub_mesh_count: u32,
    material_count: u32,
    texture_count: u32,
    point_light_count: u32,
};

pub const ImportBinTexture = packed struct {
    data_size: u32,
    width: u32,
    height: u32,
};

///Platform specific runtime binary format
///Note that the binary format is not necessarily stable or backwards compatible
///Use runtime imports for modding purposes
pub fn encode(allocator: std.mem.Allocator, import_data: Import) ![]u8 {
    var size: usize = 0;

    // size = std.mem.alignForward(size, @alignOf(ImportBinHeader));
    size += @sizeOf(ImportBinHeader);

    size = std.mem.alignForward(usize, size, @alignOf(Renderer3D.VertexPosition));
    size += @sizeOf(Renderer3D.VertexPosition) * import_data.vertex_positions.len;

    size = std.mem.alignForward(usize, size, @alignOf(Renderer3D.Vertex));
    size += @sizeOf(Renderer3D.Vertex) * import_data.vertices.len;

    size = std.mem.alignForward(usize, size, @alignOf(u32));
    size += @sizeOf(u32) * import_data.indices.len;

    size = std.mem.alignForward(usize, size, @alignOf(Import.SubMesh));
    size += @sizeOf(Import.SubMesh) * import_data.sub_meshes.len;

    size = std.mem.alignForward(usize, size, @alignOf(Import.Material));
    size += @sizeOf(Import.Material) * import_data.materials.len;

    size = std.mem.alignForward(usize, size, @alignOf(ImportBinTexture));
    size += @sizeOf(ImportBinTexture) * import_data.textures.len;

    var texture_data_size: usize = 0;

    for (import_data.textures) |texture| {
        texture_data_size += texture.data.len;
    }

    size += texture_data_size;

    size = std.mem.alignForward(usize, size, @alignOf(Renderer3D.PointLight));
    size += @sizeOf(Renderer3D.PointLight) * import_data.point_lights.len;

    const data = try allocator.alloc(u8, size);

    var data_fba = std.heap.FixedBufferAllocator.init(data);

    const fba = data_fba.allocator();

    const header = try fba.create(ImportBinHeader);

    header.vertex_count = @as(u32, @intCast(import_data.vertices.len));
    header.index_count = @as(u32, @intCast(import_data.indices.len));
    header.sub_mesh_count = @as(u32, @intCast(import_data.sub_meshes.len));
    header.material_count = @as(u32, @intCast(import_data.materials.len));
    header.texture_count = @as(u32, @intCast(import_data.textures.len));
    header.point_light_count = @as(u32, @intCast(import_data.point_lights.len));

    _ = try fba.dupe(Renderer3D.VertexPosition, import_data.vertex_positions);
    _ = try fba.dupe(Renderer3D.Vertex, import_data.vertices);
    _ = try fba.dupe(u32, import_data.indices);
    _ = try fba.dupe(Import.SubMesh, import_data.sub_meshes);
    _ = try fba.dupe(Import.Material, import_data.materials);

    const textures = try fba.alloc(ImportBinTexture, import_data.textures.len);

    for (textures, 0..) |*texture, i| {
        _ = try fba.dupe(u8, import_data.textures[i].data);

        texture.* = .{
            .data_size = @as(u32, @intCast(import_data.textures[i].data.len)),
            .width = import_data.textures[i].width,
            .height = import_data.textures[i].height,
        };
    }

    std.log.info("point_light_offset: {}", .{data_fba.end_index});

    _ = try fba.dupe(Renderer3D.PointLight, import_data.point_lights);

    return data_fba.buffer[0..data_fba.end_index];
}

///Should probably use a specialized structure for decodes
pub fn decode(allocator: std.mem.Allocator, data: []u8) !Import {
    var import_data = Import{
        .vertex_positions = &.{},
        .vertices = &.{},
        .indices = &.{},
        .sub_meshes = &.{},
        .materials = &.{},
        .textures = &.{},
        .point_lights = &.{},
    };

    var offset: usize = 0;

    const header = @as(*const ImportBinHeader, @ptrCast(@alignCast(data.ptr + offset)));

    std.log.info("header: {}", .{header});

    offset += @sizeOf(ImportBinHeader);

    const vertex_positions_offset = offset;

    offset = std.mem.alignForward(usize, offset, @alignOf(Renderer3D.VertexPosition));
    offset += @sizeOf(Renderer3D.VertexPosition) * header.vertex_count;

    const vertices_offset = offset;

    offset = std.mem.alignForward(usize, offset, @alignOf(Renderer3D.Vertex));
    offset += @sizeOf(Renderer3D.Vertex) * header.vertex_count;

    const indices_offset = offset;

    offset = std.mem.alignForward(usize, offset, @alignOf(u32));
    offset += @sizeOf(u32) * header.index_count;

    const sub_meshs_offset = offset;

    offset = std.mem.alignForward(usize, offset, @alignOf(Import.SubMesh));
    offset += @sizeOf(Import.SubMesh) * header.sub_mesh_count;

    offset = std.mem.alignForward(usize, offset, @alignOf(Import.Material));
    const materials_offset = offset;

    offset += @sizeOf(Import.Material) * header.material_count;

    offset = std.mem.alignForward(usize, offset, @alignOf(ImportBinTexture));

    const textures_offset = offset;
    offset += @sizeOf(ImportBinTexture) * header.texture_count;

    const texture_data_offset = offset;

    const bin_textures = @as([*]ImportBinTexture, @ptrCast(@alignCast(data.ptr + textures_offset)))[0..header.texture_count];

    import_data.textures = try allocator.alloc(Import.Texture, bin_textures.len);
    errdefer allocator.free(import_data.textures);

    {
        var current_texture_data_offset: usize = texture_data_offset;

        for (bin_textures, 0..) |bin_texture, i| {
            import_data.textures[i] = .{
                .data = (data.ptr + current_texture_data_offset)[0..bin_texture.data_size],
                .width = bin_texture.width,
                .height = bin_texture.height,
            };

            current_texture_data_offset += bin_texture.data_size;
        }

        offset = current_texture_data_offset;
    }

    offset = std.mem.alignForward(usize, offset, @alignOf(Renderer3D.PointLight));

    const point_light_offset = offset;

    offset += @sizeOf(Renderer3D.PointLight) * header.point_light_count;

    import_data.vertex_positions = @as([*]Renderer3D.VertexPosition, @ptrCast(@alignCast(data.ptr + vertex_positions_offset)))[0..header.vertex_count];
    import_data.vertices = @as([*]Renderer3D.Vertex, @ptrCast(@alignCast(data.ptr + vertices_offset)))[0..header.vertex_count];
    import_data.indices = @as([*]u32, @ptrCast(@alignCast(data.ptr + indices_offset)))[0..header.index_count];
    import_data.sub_meshes = @as([*]Import.SubMesh, @ptrCast(@alignCast(data.ptr + sub_meshs_offset)))[0..header.sub_mesh_count];
    import_data.materials = @as([*]Import.Material, @ptrCast(@alignCast(data.ptr + materials_offset)))[0..header.material_count];
    import_data.point_lights = @as([*]Renderer3D.PointLight, @ptrCast(@alignCast(data.ptr + point_light_offset)))[0..header.point_light_count];

    std.log.info("point_light_offset = {}", .{point_light_offset});

    for (import_data.point_lights) |point_light| {
        std.log.info("{}", .{point_light});
    }

    return import_data;
}

pub fn decodeFree(import_data: Import, allocator: std.mem.Allocator) void {
    allocator.free(import_data.textures);
}

///I think u32 should be enough to represent most if not all vertices in a normalized
///Mesh, but there will be some, tho minimal, precision problems as always.
///Overall, it's worth it as it gives us a theoretical 3x bandwidth reduction
fn quantisePosition(
    pos: @Vector(3, f32),
) Renderer3D.VertexPosition {
    const quantised = Renderer3D.VertexPosition{
        .x = @floatCast(pos[0]),
        .y = @floatCast(pos[1]),
        .z = @floatCast(pos[2]),
    };

    return quantised;
}

fn quantiseNormal(normal: @Vector(3, f32)) Renderer3D.VertexNormal {
    const quantised = Renderer3D.VertexNormal{
        .x = quantiseFloat(i10, normal[0]),
        .y = quantiseFloat(i10, normal[1]),
        .z = quantiseFloat(i10, normal[2]),
    };

    return quantised;
}

fn quantiseUV(uv: @Vector(2, f32)) Renderer3D.VertexUV {
    const quantised = Renderer3D.VertexUV{
        .u = @floatCast(uv[0]),
        .v = @floatCast(uv[1]),
    };

    return quantised;
}

fn quantiseFloat(comptime T: type, float: f32) T {
    if (@typeInfo(T).Int.signedness == .unsigned) {
        const normalized = std.math.fabs(std.math.clamp(float, -1, 1));

        return @intFromFloat(normalized * std.math.maxInt(T));
    } else {
        const normalized = std.math.clamp(float, -1, 1);

        return @intFromFloat(normalized * std.math.maxInt(T));
    }
}

fn packUnorm4x8(v: [4]f32) u32 {
    const Unorm4x8 = packed struct(u32) {
        x: u8,
        y: u8,
        z: u8,
        w: u8,
    };

    const x = quantiseFloat(u8, v[0]);
    const y = quantiseFloat(u8, v[1]);
    const z = quantiseFloat(u8, v[2]);
    const w = quantiseFloat(u8, v[3]);

    return @as(u32, @bitCast(Unorm4x8{
        .x = x,
        .y = y,
        .z = z,
        .w = w,
    }));
}
