pub const CompilerContext = struct {
    allocator: std.mem.Allocator,
    compilers: []const AssetCompilerInfo,
    ///Paths of files to compile
    file_paths: [][]const u8,
    assets: std.ArrayListUnmanaged(Archive.AssetDescription),

    pub fn deinit(self: *CompilerContext) void {
        for (self.assets.items) |asset| {
            self.allocator.free(asset.name);
            self.allocator.free(asset.source_data);
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

const quanta = @import("quanta");
const std = @import("std");
const zon = quanta.zon;
const importers = importers;
const Archive = quanta.asset.Archive;
