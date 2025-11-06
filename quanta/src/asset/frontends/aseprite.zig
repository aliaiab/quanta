//! Implements compiling aseprite files directly.
//! Aseprite file format is fully specified by https://github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md

pub const Import = extern struct {
    //Currently just takes all frames and creates a static image
    //TODO: implement layers and animations
    data: encoded_format.RelativeSlice(u8, u16, u16),
    width: u32,
    height: u32,

    pub fn assetCompile(
        context: *compiler.CompilerContext,
        file_path: []const u8,
        data: []const u8,
        meta_data: ?Metadata,
    ) ![]const u8 {
        _ = file_path; // autofix
        _ = meta_data; // autofix

        var reader = std.Io.Reader.fixed(data);

        var header: Header = undefined;

        try reader.readSliceAll(std.mem.asBytes(&header));

        std.debug.assert(header.magic_number == Header.valid_magic_number);
        std.debug.assert(header.file_size == data.len);

        log.info("header: {}", .{header});

        var pixel_data: ?[]u8 = null;
        var width: u32 = 0;
        var height: u32 = 0;

        for (0..header.frames) |frame_index| {
            var frame: Frame = undefined;

            try reader.readSliceAll(std.mem.asBytes(&frame));

            std.debug.assert(frame.magic_number == Frame.valid_magic_number);

            log.info("frame[{}]: {}", .{ frame_index, frame });

            for (0..frame.chunk_count) |chunk_index| {
                _ = chunk_index; // autofix
                var chunk_size: u32 = undefined;

                try reader.readSliceAll(std.mem.asBytes(&chunk_size));

                var chunk_type: Chunk.Type = undefined;

                try reader.readSliceAll(std.mem.asBytes(&chunk_type));

                //chunk.chunk_size includes the size of the header itself
                const chunk_data_size = chunk_size - @sizeOf(u32) - @sizeOf(Chunk.Type);

                const chunk_data = try context.allocator.alloc(u8, chunk_data_size);

                switch (chunk_type) {
                    .cel_chunk => {
                        var cel_chunk: CelChunk = undefined;

                        try reader.readSliceAll(std.mem.asBytes(&cel_chunk));

                        switch (cel_chunk.cel_type) {
                            .raw_image => {
                                var raw_image_extra: CelChunk.RawImageDataExtra = undefined;

                                try reader.readSliceAll(std.mem.asBytes(&raw_image_extra));

                                log.info("raw_image_extra = {}", .{raw_image_extra});

                                const chunk_width: u32 = raw_image_extra.width;
                                const chunk_height: u32 = raw_image_extra.height;

                                width = chunk_width;
                                height = chunk_height;

                                const raw_image_data = try context.allocator.alloc(u8, chunk_width * chunk_height * @sizeOf(u32));

                                log.info("raw_image_data.len = {}", .{raw_image_data.len});

                                try reader.readSliceAll(raw_image_data);

                                pixel_data = raw_image_data;
                            },
                            else => {
                                var compressed_image_extra: CelChunk.CompressedImage = undefined;

                                try reader.readSliceAll(std.mem.asBytes(&compressed_image_extra));

                                width = compressed_image_extra.width;
                                height = compressed_image_extra.height;

                                const uncompressed_size = width * height * @sizeOf(u32);

                                const uncompressed_data = try context.allocator.alloc(u8, uncompressed_size);

                                var decompression_writer = std.Io.Writer.fixed(uncompressed_data);

                                var decompress = std.compress.flate.Decompress.init(
                                    &reader,
                                    .zlib,
                                    &.{},
                                );

                                const decompressed_len = try decompress.reader.streamRemaining(&decompression_writer);
                                _ = decompressed_len; // autofix

                                pixel_data = uncompressed_data;
                            },
                        }
                    },
                    else => {
                        try reader.readSliceAll(chunk_data);
                    },
                }
            }
        }

        if (pixel_data == null) return error.FailedToGetPixelData;

        //Encode the imported data

        const fixed_buffer = try context.allocator.alignedAlloc(u8, .fromByteUnits(@alignOf(Import)), @sizeOf(Import) + pixel_data.?.len);
        errdefer context.allocator.free(fixed_buffer);

        var bump: u32 = 0;

        const encoded_import_data: *Import = @alignCast(@ptrCast(fixed_buffer.ptr));

        bump += @sizeOf(Import);

        encoded_import_data.width = width;
        encoded_import_data.height = height;

        encoded_import_data.data.set(fixed_buffer[bump..]);

        @memcpy(fixed_buffer[bump..], pixel_data.?);

        return fixed_buffer;
    }

    pub const Metadata = struct {};

    ///TODO: add extension alternatives to handle the .ase extension
    pub const file_extension = ".aseprite";

    pub const base_hash = compiler.getBaseHashFromBytes(@embedFile("aseprite.zig"));
};

const Header = extern struct {
    file_size: u32,
    magic_number: u16,
    frames: u16,
    width: u16,
    height: u16,
    color_depth: u16,
    flags: u32 align(1),
    speed: u16 align(1),
    padding_0: u32,
    padding_1: u32,
    palette: u8,
    padding_2: [3]u8,
    color_count: u16,
    pixel_width: u8,
    pixel_height: u8,
    ///X position of grid
    grid_x: i16,
    ///Y position of grid
    grid_y: i16,
    grid_width: u16,
    grid_height: u16,
    padding_reserved: [84]u8,

    pub const valid_magic_number = 0xA5E0;
};

comptime {
    std.debug.assert(@sizeOf(Header) == 128);
}

const Frame = extern struct {
    bytes: u32,
    magic_number: u16,
    deprecated_chunk_count: u16,
    frame_duration: u16,
    padding_reserved: [2]u8,
    chunk_count: u32,

    pub const valid_magic_number = 0xF1FA;
};

comptime {
    std.debug.assert(@sizeOf(Frame) == 16);
}

const Chunk = packed struct(u48) {
    chunk_size: u32,
    chunk_type: Type,

    pub const Type = enum(u16) {
        layer_chunk = 0x2004,
        cel_chunk = 0x2005,
        cel_extra_chunk = 0x2006,
        color_profile = 0x2007,
        external_files_chunk = 0x2008,
        mask_chunk = 0x2016,
        path_chunk = 0x2017,
        tags_chunk = 0x2018,
        palette_chunk = 0x2019,
        deprecated_palette_chunk = 0x0004,
        deprecated_palette_chunk_2 = 0x0011,
        _,
    };
};

const ColorProfile = extern struct {
    type: u16,
    flags: u16,
    gamma: Fixed,
    padding_reserved: [8]u8,

    pub const Type = enum(u16) {
        none = 0,
        use_srgb = 1,
        use_icc = 2,
    };

    ///Extra data for type == icc
    pub const ICCExtra = extern struct {
        data_length: u32,
    };
};

///A fixed point number
const Fixed = packed struct(u32) {
    major: u16,
    fractional: u16,
};

const CelChunk = extern struct {
    layer_index: u16 align(1),
    x_position: i16 align(1),
    y_position: i16 align(1),
    opacity_level: u8 align(1),
    cel_type: CelType align(1),
    z_index: i16 align(1),
    padding_reserved: [5]u8 align(1),

    pub const CelType = enum(u16) {
        raw_image = 0,
        linked_cel = 1,
        compressed_image = 2,
        compressed_tilemap = 3,
    };

    pub const RawImageDataExtra = packed struct {
        width: u16,
        height: u16,
    };

    pub const CompressedImage = packed struct(u32) {
        width: u16,
        height: u16,
    };
};

const compiler = @import("../compiler.zig");
const encoded_format = @import("../encoded_format.zig");
const std = @import("std");
const log = @import("../../log.zig").log;
