pub const CompilerContext = struct {
    allocator: std.mem.Allocator,
    compilers: []const AssetCompilerInfo,
    directory_path: []const u8,
    file_paths: [][]const u8,
    assets: std.ArrayListUnmanaged(Archive.AssetDescription),
    compiled_asset_count: usize,
    previous_archive: Archive,
    hasher: Hasher,

    pub fn deinit(self: *CompilerContext) void {
        for (self.assets.items) |asset| {
            self.allocator.free(asset.name);
            // if (asset.is_new) self.allocator.free(asset.source_data);
        }

        self.assets.deinit(self.allocator);

        self.* = undefined;
    }

    pub fn compile(self: *CompilerContext, path: []const u8) !void {
        const extension = std.fs.path.extension(path);

        const source_file = try std.fs.cwd().openFile(path, .{});
        defer source_file.close();

        const source_data = try source_file.readToEndAlloc(self.allocator, std.math.maxInt(usize));
        defer self.allocator.free(source_data);

        const metadata_file_path = try std.mem.concat(self.allocator, u8, &.{ path, ".zon" });
        defer self.allocator.free(metadata_file_path);

        const metadata_file = try std.fs.cwd().openFile(metadata_file_path, .{});
        defer metadata_file.close();

        const metadata = try metadata_file.readToEndAllocOptions(
            self.allocator,
            std.math.maxInt(usize),
            null,
            @alignOf(u8),
            0,
        );
        defer self.allocator.free(metadata);

        std.log.info("metadata: {s}", .{metadata});

        for (self.compilers) |compiler| {
            if (std.mem.eql(u8, compiler.file_extension, extension)) {
                self.hasher = std.Build.Cache.Hasher.init("ASSET" ++ [_]u8{0} ** 11);

                //TODO: use parsed metadata representation instead of text
                self.hasher.update(metadata);
                self.hasher.update(source_data);

                const hash = self.hasher.finalInt();

                std.log.info("New Hash = 0x{x}", .{hash});

                const name = try std.fs.path.relative(self.allocator, self.directory_path, path);

                std.log.info("Name = {s}", .{name});

                std.log.info("prev archive: asset_count = {}", .{self.previous_archive.asset_name_hashes.len});

                //handle when the asset doesn't exist in the prev archive (the asset is new)
                const old_asset_index = self.previous_archive.getAssetIndexFromName(name) orelse null;

                const old_asset_content_hash = if (old_asset_index != null) self.previous_archive.asset_content_hashes[old_asset_index.?] else null;

                //The asset contents are the same, don't compile---use the old one
                if (old_asset_content_hash != null and old_asset_content_hash.? == hash) {
                    std.log.info("Old Hash = 0x{x}", .{old_asset_content_hash.?});

                    const previous_asset_header = self.previous_archive.assets[old_asset_index.?];

                    try self.assets.append(self.allocator, .{
                        .name = name,
                        .source_data = self.previous_archive.image[previous_asset_header.source_data_offset .. previous_asset_header.source_data_offset + previous_asset_header.source_data_size],
                        .source_data_alignment = previous_asset_header.mapped_data_alignment,
                        .mapped_data_size = previous_asset_header.mapped_data_size,
                        .content_hash = hash,
                    });

                    return;
                }

                const compiled_data = try compiler.compile(self, path, source_data, metadata);

                try self.assets.append(self.allocator, .{
                    .name = name,
                    .source_data = compiled_data,
                    //Specify alignment from Asset.compile() functions
                    .source_data_alignment = @alignOf(u32),
                    .mapped_data_size = compiled_data.len,
                    .content_hash = hash,
                });

                self.compiled_asset_count += 1;

                return;
            }
        }
    }

    pub fn pathFromRoot(
        self: CompilerContext,
        path: []const u8,
    ) ![]u8 {
        return try std.fs.path.join(self.allocator, &.{ self.directory_path, path });
    }
};

pub const AssetCompilerInfo = struct {
    pub const CompileFn = fn (
        context: *CompilerContext,
        file_path: []const u8,
        data: []const u8,
        meta_data: ?[:0]const u8,
    ) anyerror![]const u8;

    compile: *const CompileFn,
    file_extension: []const u8,

    pub fn fromType(comptime T: type) AssetCompilerInfo {
        return .{
            .compile = compileFn(T),
            .file_extension = T.file_extension,
        };
    }

    pub fn compileFn(comptime T: type) CompileFn {
        const compile_fn = T.assetCompile;

        const static = struct {
            fn function(context: *CompilerContext, file_path: []const u8, data: []const u8, meta_data: ?[:0]const u8) anyerror![]const u8 {
                const args = @typeInfo(@TypeOf(compile_fn)).Fn.params;

                const MetaDataType = std.meta.Child(args[3].type.?);

                const meta_data_parsed = if (meta_data != null) try zon.parse.parse(MetaDataType, context.allocator, meta_data.?) else null;
                defer if (meta_data_parsed != null) zon.parse.parseFree(MetaDataType, context.allocator, meta_data_parsed.?);

                return @call(.always_inline, compile_fn, .{
                    context,
                    file_path,
                    data,
                    meta_data_parsed,
                });
            }
        };

        return static.function;
    }
};

const std = @import("std");
const quanta = @import("quanta");
const zon = quanta.zon;
const Archive = quanta.asset.Archive;
const Hasher = std.Build.Cache.Hasher;
