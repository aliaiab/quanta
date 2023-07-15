//! The program responsible for compiling all the assets in a project

pub const CompilerContext = struct {
    allocator: std.mem.Allocator,
    compilers: []const AssetCompilerInfo,
    ///Paths of files to compile
    file_paths: [][]const u8,
    assets: std.ArrayListUnmanaged(Archive.AssetDescription),

    pub fn deinit(self: *CompilerContext) void {
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
                const compiled_data = try compiler.compile(self, path, source_data, metadata);

                try self.assets.append(self.allocator, .{
                    .name = try self.allocator.dupe(u8, path),
                    .source_data = compiled_data,
                    .source_data_alignment = @alignOf(u32),
                    .mapped_data_size = compiled_data.len,
                });

                return;
            }
        }
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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer std.debug.assert(gpa.deinit() != .leak);

    const allocator = gpa.allocator();

    const asset_compilers = [_]AssetCompilerInfo{
        AssetCompilerInfo.fromType(importers.gltf.Import),
    };

    var context = CompilerContext{
        .allocator = allocator,
        .compilers = &asset_compilers,
        .file_paths = &.{},
        .assets = .{},
    };
    defer context.deinit();

    const asset_directory_path = "example/src/assets/light_test/";

    var asset_directory = try std.fs.cwd().openIterableDir(asset_directory_path, .{});
    defer asset_directory.close();

    var asset_directory_iterator = asset_directory.iterate();

    while (try asset_directory_iterator.next()) |entry| {
        std.log.info("Potential asset file: {s}", .{entry.name});

        const metadata_path = try std.mem.concat(allocator, u8, &[_][]const u8{ entry.name, ".zon" });
        defer allocator.free(metadata_path);

        const metadata_file = asset_directory.dir.openFile(metadata_path, .{}) catch null;
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
const zon = @import("zon");
const importers = @import("importers.zig");
const Archive = @import("Archive.zig");
