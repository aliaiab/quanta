//! General functions for working with the encoded formats of assets in archive/memory

///Relative pointer address calculation
pub inline fn relativeAddressFromPtr(
    comptime BaseType: type,
    comptime PointeeType: type,
    comptime AddressType: type,
    base: *const BaseType,
    ptr: *PointeeType,
) AddressType {
    const base_address: isize = @bitCast(@intFromPtr(base));
    const to_address: isize = @bitCast(@intFromPtr(ptr));

    const difference = to_address - base_address;

    return @intCast(@divTrunc(difference, @alignOf(PointeeType)));
}

///Relative pointer pointer calculation
pub inline fn ptrFromRelativeAddress(
    comptime BaseType: type,
    comptime PointeeType: type,
    comptime AddressType: type,
    base: *const BaseType,
    relative_address: AddressType,
) ?*PointeeType {
    if (relative_address == 0) return null;

    const base_address: isize = @bitCast(@intFromPtr(base));
    const difference: isize = @intCast(relative_address * @alignOf(PointeeType));

    const to = base_address + difference;

    const address: usize = @bitCast(to);

    return @ptrFromInt(address);
}

///A relative pointer, which refers to an address in memory relative to the location of the pointer itself
///This is non-const
pub fn RelativePtr(
    comptime Parent: type,
    comptime BackingInteger: type,
) type {
    return packed struct(BackingInteger) {
        integer: BackingInteger,

        pub const nil = Self{ .integer = 0 };

        //TODO: implement 'of' function when/if userspace RLS referencing functionality is added IE: @Result()
        pub fn set(self: *Self, to_ptr: *Parent) void {
            self.integer = relativeAddressFromPtr(
                Self,
                Parent,
                BackingInteger,
                self,
                to_ptr,
            );
        }

        ///Returns the absoloute pointer that the relative pointer points to
        pub fn ptr(self: *const Self) *Parent {
            return ptrFromRelativeAddress(
                Self,
                Parent,
                BackingInteger,
                self,
                self.integer,
            ).?;
        }

        ///Loads the value from that the pointer points to
        pub fn value(self: *const Self) Parent {
            return self.ptr().*;
        }

        const Self = @This();
    };
}

///A relative pointer, which refers to an address in memory relative to the location of the pointer itself
///This is non-const
pub fn RelativeSlice(
    comptime Parent: type,
    comptime PtrBackingInteger: type,
    comptime LenBackingInteger: type,
) type {
    return packed struct(std.meta.Int(.unsigned, @bitSizeOf(PtrBackingInteger) + @bitSizeOf(LenBackingInteger))) {
        integer_ptr: PtrBackingInteger,
        len: LenBackingInteger,

        pub const empty = Self{
            .integer_ptr = 0,
            .len = 0,
        };

        pub fn set(self: *Self, to_slice: []Parent) void {
            self.integer_ptr = relativeAddressFromPtr(
                Self,
                Parent,
                PtrBackingInteger,
                self,
                @ptrCast(to_slice.ptr),
            );
            self.len = @intCast(to_slice.len);
        }

        ///Returns the absoloute pointer that the relative pointer points to
        pub fn ptr(self: *const Self) [*]Parent {
            const pointer: [*]Parent = @ptrCast(ptrFromRelativeAddress(
                Self,
                Parent,
                PtrBackingInteger,
                self,
                self.integer_ptr,
            ).?);

            return pointer;
        }

        pub fn slice(self: *const Self) []Parent {
            return self.ptr()[0..self.len];
        }

        const Self = @This();
    };
}

///A forward relative slice with more advanced comptime features. Analogous to a slice
pub fn RelativeLinearStream(
    ///The parent structure which the relative stream is stored in
    comptime Parent: type,
    ///The name of the field of Parent that will contain the stream
    comptime field_name: []const u8,
    ///The type that the stream is pointing to
    comptime Pointee: type,
    ///The backing integer for the len field
    comptime LenBackingInteger: type,
) type {
    return packed struct(LenBackingInteger) {
        len: LenBackingInteger,

        ///Indicates this type is a relative linear stream, as a way to detect what fields are streams and which are not
        pub const is_relative_linear_stream: void = {};

        pub const ParentType = Parent;
        pub const PointeeType = Pointee;

        ///Returns the total size of the stream data including padding
        pub inline fn size(self: Self) usize {
            return self.len * @sizeOf(Pointee);
        }

        pub fn slice(self: *Self) []Pointee {
            const parent_base: *Parent = @alignCast(@fieldParentPtr(field_name, self));
            const parent_base_bytes: [*]u8 = @ptrCast(parent_base);
            const parent_end = parent_base_bytes + @sizeOf(Parent);

            var offset: usize = 0;

            inline for (comptime std.meta.fields(Parent)) |field| {
                if (@typeInfo(field.type) != .@"struct" or !@hasDecl(field.type, "is_relative_linear_stream")) {
                    comptime continue;
                }

                offset = std.mem.alignForward(usize, offset, @alignOf(field.type.PointeeType));

                if (comptime std.mem.eql(u8, field.name, field_name)) {
                    comptime break;
                }

                offset += @field(parent_base, field.name).size();
            }

            const stream_ptr: [*]Pointee = @alignCast(@ptrCast(parent_end + offset));

            return stream_ptr[0..self.len];
        }

        const Self = @This();
    };
}

///A forward relative multi slice with more advanced comptime features. Analogous to MultiArrayList
pub fn RelativeLinearMultiStream(
    ///The parent structure which the relative stream is stored in
    comptime Parent: type,
    ///The name of the field of Parent that will contain the stream
    comptime field_name: []const u8,
    ///The type that the stream is pointing to
    comptime PointeeStruct: type,
    ///The backing integer for the len field
    comptime LenBackingInteger: type,
) type {
    return packed struct(LenBackingInteger) {
        len: LenBackingInteger,

        ///Indicates this type is a relative linear stream, as a way to detect what fields are streams and which are not
        pub const is_relative_linear_stream: void = {};

        pub const ParentType = Parent;
        pub const PointeeType = PointeeStruct;

        ///Returns the total size of the stream data including padding
        pub inline fn size(self: Self) usize {
            return self.len * @sizeOf(PointeeStruct);
        }

        pub const Field = std.meta.FieldEnum(PointeeStruct);

        fn FieldType(comptime field: Field) type {
            return std.meta.fieldInfo(PointeeStruct, field).type;
        }

        pub fn slice(self: *Self, comptime field: Field) []FieldType(field) {
            const parent_base: *Parent = @alignCast(@fieldParentPtr(field_name, self));
            const parent_base_bytes: [*]u8 = @ptrCast(parent_base);
            const parent_end = parent_base_bytes + @sizeOf(Parent);

            var offset: usize = 0;

            inline for (comptime std.meta.fields(Parent)) |parent_field| {
                if (@typeInfo(parent_field.type) != .Struct or !@hasDecl(parent_field.type, "is_relative_linear_stream")) {
                    comptime continue;
                }

                offset = std.mem.alignForward(usize, offset, @alignOf(parent_field.type.PointeeType));

                if (comptime std.mem.eql(u8, parent_field.name, field_name)) {
                    comptime break;
                }

                offset += @field(parent_base, parent_field.name).size();
            }

            const stream_ptr: [*]FieldType(field) = @alignCast(@ptrCast(parent_end + offset));

            return stream_ptr[0..self.len];
        }

        const Self = @This();
    };
}

///For a type containing relative linear streams, compute the size of the data following the header, not including the size of the header
pub fn relativeStreamSizeOf(header: anytype) usize {
    var offset: usize = 0;

    inline for (comptime std.meta.fields(@TypeOf(header))) |field| {
        if (@typeInfo(field.type) != .@"struct" or !@hasDecl(field.type, "is_relative_linear_stream")) {
            comptime continue;
        }

        offset = std.mem.alignForward(usize, offset, @alignOf(field.type.PointeeType));
        offset += @field(header, field.name).size();
    }

    return offset;
}

test "Relative Linear MultiStream" {
    const Header = extern struct {
        first_buffer: RelativeLinearMultiStream(
            @This(),
            "first_buffer",
            struct {
                a: u32,
                b: u32,
            },
            u16,
        ),
        some_data_to_ignore: u32,
        some_other_data_to_ignore: u32,
        second_buffer: RelativeLinearMultiStream(
            @This(),
            "second_buffer",
            struct {
                a: u32,
                b: u32,
                c: u32,
            },
            u16,
        ),
    };

    var buffer: [4 * 1024]u8 = undefined;

    var fixed_alloc = std.heap.FixedBufferAllocator.init(&buffer);

    var header = try fixed_alloc.allocator().create(Header);

    const first_array_len = 10;
    const second_array_len = 20;

    const first_array_a = try fixed_alloc.allocator().alloc(u32, first_array_len);
    const first_array_b = try fixed_alloc.allocator().alloc(u32, first_array_len);

    const second_array_a = try fixed_alloc.allocator().alloc(u32, second_array_len);
    const second_array_b = try fixed_alloc.allocator().alloc(u32, second_array_len);
    _ = second_array_b; // autofix
    const second_array_c = try fixed_alloc.allocator().alloc(u32, second_array_len);
    _ = second_array_c; // autofix

    header.first_buffer.len = @intCast(first_array_a.len);
    header.second_buffer.len = @intCast(second_array_a.len);

    for (first_array_a, first_array_b, 0..) |*elem_a, *elem_b, i| {
        elem_a.* = @intCast(i);
        elem_b.* = @intCast(i + 100);
    }

    for (second_array_a, 0..) |*elem_a, i| {
        elem_a.* = @intCast(second_array_a.len - i);
    }

    //Useful for allocating the whole data structure in one hit from a page allocator
    const stream_size = relativeStreamSizeOf(header.*);

    std.log.err("stream size = {}", .{stream_size});
}

test "Relative Linear Stream" {
    const Header = extern struct {
        first_buffer: RelativeLinearStream(
            @This(),
            "first_buffer",
            u32,
            u16,
        ),
        some_data_to_ignore: u32,
        some_other_data_to_ignore: u32,
        second_buffer: RelativeLinearStream(
            @This(),
            "second_buffer",
            u32,
            u16,
        ),
    };

    var buffer: [4 * 1024]u8 = undefined;

    var fixed_alloc = std.heap.FixedBufferAllocator.init(&buffer);

    var header = try fixed_alloc.allocator().create(Header);

    const first_array = try fixed_alloc.allocator().alloc(u32, 10);
    const second_array = try fixed_alloc.allocator().alloc(u32, 20);

    header.first_buffer.len = @intCast(first_array.len);
    header.second_buffer.len = @intCast(second_array.len);

    for (first_array, 0..) |*elem, i| {
        elem.* = @intCast(i);
    }

    for (second_array, 0..) |*elem, i| {
        elem.* = @intCast(second_array.len - i);
    }

    //Useful for allocating the whole data structure in one hit from a page allocator
    const stream_size = relativeStreamSizeOf(header.*);

    std.log.warn("stream size = {}", .{stream_size});

    std.log.warn("header.first_buffer.slice() = {any}", .{header.first_buffer.slice()});
    std.log.warn("header.second_buffer.slice() = {any}", .{header.second_buffer.slice()});
}

test "Relative Ptr" {
    var data: u16 = 0;

    var ptr = RelativePtr(u16, i32).nil;

    //set the relative pointer to point to data
    ptr.set(&data);

    try std.testing.expect(ptr.ptr() == &data);
    try std.testing.expect(ptr.value() == data);
}

test "Relative Slice" {
    const buffer = try std.testing.allocator.alloc(u32, 1024);
    defer std.testing.allocator.free(buffer);

    const SliceType = RelativeSlice(
        u32,
        i16,
        u16,
    );

    const slice_index_begin: u32 = 504;
    var slice_end: u32 = slice_index_begin;

    buffer[slice_end] = 42;
    slice_end += 1;
    buffer[slice_end] = 43;
    slice_end += 1;
    buffer[slice_end] = 44;
    slice_end += 1;
    buffer[slice_end] = 45;
    slice_end += 1;

    const relative_slice: *SliceType = @ptrCast(&buffer[0]);

    relative_slice.set(buffer[slice_index_begin..slice_end]);

    std.log.err("relative_slice = {any}", .{relative_slice.slice()});

    try std.testing.expect(std.mem.eql(u32, relative_slice.slice(), &.{ 42, 43, 44, 45 }));
}

const std = @import("std");
