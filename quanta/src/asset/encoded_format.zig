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
