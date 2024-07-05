///The dot product
pub inline fn dot(
    comptime T: type,
    comptime dimension: comptime_int,
    left: @Vector(dimension, T),
    right: @Vector(dimension, T),
) f32 {
    return @reduce(.Add, left * right);
}

///Populates each elements of a SIMD vector with the scalar product
///Useful for making use of simd
pub inline fn dotSplat(
    comptime T: type,
    comptime dimension: comptime_int,
    left: @Vector(dimension, T),
    right: @Vector(dimension, T),
) @Vector(dimension, T) {
    return @splat(dot(T, dimension, left, right));
}

///The cross product, defined in 3 dimensions only
pub inline fn cross(
    comptime T: type,
    left: @Vector(3, T),
    right: @Vector(3, T),
) @Vector(3, T) {
    const x1 = left[0];
    const y1 = left[1];
    const z1 = left[2];

    const x2 = right[0];
    const y2 = right[1];
    const z2 = right[2];

    const result_x = (y1 * z2) - (z1 * y2);
    const result_y = (z1 * x2) - (x1 * z2);
    const result_z = (x1 * y2) - (y1 * x2);

    return .{ result_x, result_y, result_z };
}

///The vector square, the same as dot(left, right)
pub inline fn square(
    comptime T: type,
    comptime dimension: comptime_int,
    vector: @Vector(dimension, T),
) f32 {
    return dot(T, dimension, vector, vector);
}

///The vector magnitude, the same as @sqrt(square(vector))
pub inline fn magnitude(
    comptime T: type,
    comptime dimension: comptime_int,
    vector: @Vector(dimension, T),
) f32 {
    return @sqrt(square(T, dimension, vector));
}

///The vector unit, or normalized vector, the same as vector / magnitude(vector)
pub inline fn unit(
    comptime T: type,
    comptime dimension: comptime_int,
    vector: @Vector(dimension, T),
) @Vector(dimension, T) {
    const scale: @Vector(dimension, T) = @splat(magnitude(T, dimension, vector));

    return vector / scale;
}

test "unit length" {
    const test_vector: @Vector(3, f32) = .{ 0, 5, 0 };

    try std.testing.expect(unit(f32, 3, test_vector)[1] == 1);
}

test {
    @import("std").testing.refAllDecls(@This());
}

const std = @import("std");
