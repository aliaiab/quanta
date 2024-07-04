///Returns an alias to a row_count * column_count array, used as a matrix type
///Meant to feel like @Vector in its usage
pub fn Matrix(
    comptime row_count: comptime_int,
    comptime column_count: comptime_int,
    comptime T: type,
) type {
    return [row_count][column_count]T;
}

pub const identity: Matrix(4, 4, f32) = .{
    // zig fmt: off
    .{ 1, 0, 0, 0, },
    .{ 0, 1, 0, 0, },
    .{ 0, 0, 1, 0, },
    .{ 0, 0, 0, 1, },
};
// zig fmt: on

pub fn mul(left: [4][4]f32, right: [4][4]f32) [4][4]f32 {
    var result = identity;

    for (0..result.len) |column| {
        for (0..result[column].len) |row| {
            var sum: f32 = 0;

            for (0..left.len) |left_column| {
                sum += left[left_column][row] * right[column][left_column];
            }

            result[column][row] = sum;
        }
    }

    return result;
}

pub fn fromTranslation(
    translation: @Vector(3, f32),
) Matrix(4, 4, f32) {
    var result = identity;

    result[3][0] = translation[0];
    result[3][1] = translation[1];
    result[3][2] = translation[2];

    return result;
}

///Translate the input matrix, returning the translated matrix
pub fn translate(
    matrix: Matrix(4, 4, f32),
    translation: @Vector(3, f32),
) Matrix(4, 4, f32) {
    return mul(matrix, fromTranslation(translation));
}

pub fn fromScale(
    scale_vector: @Vector(3, f32),
) Matrix(4, 4, f32) {
    var result = identity;

    result[0][0] = scale_vector[0];
    result[1][1] = scale_vector[1];
    result[2][2] = scale_vector[2];

    return result;
}

pub fn scale(
    matrix: Matrix(4, 4, f32),
    scale_vector: @Vector(3, f32),
) Matrix(4, 4, f32) {
    return mul(matrix, fromScale(scale_vector));
}

pub fn lookAt(
    eye: @Vector(3, f32),
    target: @Vector(3, f32),
    up: @Vector(3, f32),
) [4][4]f32 {
    const f = vector.unit(f32, 3, target - eye);
    const s = vector.cross(f32, f, up);
    const u = vector.cross(f32, s, f);

    var result: [4][4]f32 = undefined;

    result[0][0] = s[0];
    result[0][1] = u[0];
    result[0][2] = -f[0];
    result[0][3] = 0;

    result[1][0] = s[1];
    result[1][1] = u[1];
    result[1][2] = -f[1];
    result[1][3] = 0;

    result[2][0] = s[2];
    result[2][1] = u[2];
    result[2][2] = -f[2];
    result[2][3] = 0;

    result[3][0] = -vector.dot(f32, 3, s, eye);
    result[3][1] = -vector.dot(f32, 3, u, eye);
    result[3][2] = vector.dot(f32, 3, f, eye);
    result[3][3] = 1;

    return result;
}

///Reverse-z perspective
pub fn perspectiveProjectionReversedZ(
    ///Field of view in radians
    field_of_view: f32,
    aspect_ratio: f32,
    znear: f32,
) [4][4]f32 {
    const f = 1 / std.math.tan(field_of_view / 2);

    return .{
        .{ f / aspect_ratio, 0, 0, 0 },
        .{ 0, f, 0, 0 },
        .{ 0, 0, 0, -1 },
        .{ 0, 0, znear, 0 },
    };
}

const std = @import("std");
const vector = @import("vector.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
