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
    const s = vector.unit(f32, 3, vector.cross(f32, f, up));
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

pub fn perspectiveNonReversedZ(
    ///Field of view in radians
    field_of_view: f32,
    aspect_ratio: f32,
    z_near: f32,
    z_far: f32,
) Matrix(4, 4, f32) {
    var result = identity;

    const f = 1 / @tan(field_of_view * 0.5);

    result[0][0] = f / aspect_ratio;
    result[1][1] = f;
    result[2][2] = (z_near + z_far) / (z_near - z_far);
    result[2][3] = -1;
    result[3][2] = 2 * z_far * z_near / (z_near - z_far);
    result[3][3] = 0;

    return result;
}

///Reverse-z perspective
pub fn perspectiveProjectionReversedZ(
    ///Field of view in radians
    field_of_view: f32,
    aspect_ratio: f32,
    z_near: f32,
) [4][4]f32 {
    const f = 1 / @tan(field_of_view / 2);

    return .{
        .{ f / aspect_ratio, 0, 0, 0 },
        .{ 0, f, 0, 0 },
        .{ 0, 0, 0, -1 },
        .{ 0, 0, z_near, 0 },
    };
}

fn detsubs(self: Matrix(4, 4, f32)) [12]f32 {
    return .{
        self[0][0] * self[1][1] - self[1][0] * self[0][1],
        self[0][0] * self[1][2] - self[1][0] * self[0][2],
        self[0][0] * self[1][3] - self[1][0] * self[0][3],
        self[0][1] * self[1][2] - self[1][1] * self[0][2],
        self[0][1] * self[1][3] - self[1][1] * self[0][3],
        self[0][2] * self[1][3] - self[1][2] * self[0][3],

        self[2][0] * self[3][1] - self[3][0] * self[2][1],
        self[2][0] * self[3][2] - self[3][0] * self[2][2],
        self[2][0] * self[3][3] - self[3][0] * self[2][3],
        self[2][1] * self[3][2] - self[3][1] * self[2][2],
        self[2][1] * self[3][3] - self[3][1] * self[2][3],
        self[2][2] * self[3][3] - self[3][2] * self[2][3],
    };
}

/// Calculate determinant of the given 4x4 matrix.
pub fn det(self: Matrix(4, 4, f32)) f32 {
    const s = detsubs(self);
    return s[0] * s[11] - s[1] * s[10] + s[2] * s[9] + s[3] * s[8] - s[4] * s[7] + s[5] * s[6];
}

/// Construct inverse 4x4 from given matrix.
/// Note: This is not the most efficient way to do this.
/// TODO: Make it more efficient.
pub fn inv(self: Matrix(4, 4, f32)) Matrix(4, 4, f32) {
    var inv_mat: Matrix(4, 4, f32) = undefined;

    const s = detsubs(self);

    const determ = 1 / (s[0] * s[11] - s[1] * s[10] + s[2] * s[9] + s[3] * s[8] - s[4] * s[7] + s[5] * s[6]);

    inv_mat[0][0] = determ * (self[1][1] * s[11] - self[1][2] * s[10] + self[1][3] * s[9]);
    inv_mat[0][1] = determ * -(self[0][1] * s[11] - self[0][2] * s[10] + self[0][3] * s[9]);
    inv_mat[0][2] = determ * (self[3][1] * s[5] - self[3][2] * s[4] + self[3][3] * s[3]);
    inv_mat[0][3] = determ * -(self[2][1] * s[5] - self[2][2] * s[4] + self[2][3] * s[3]);

    inv_mat[1][0] = determ * -(self[1][0] * s[11] - self[1][2] * s[8] + self[1][3] * s[7]);
    inv_mat[1][1] = determ * (self[0][0] * s[11] - self[0][2] * s[8] + self[0][3] * s[7]);
    inv_mat[1][2] = determ * -(self[3][0] * s[5] - self[3][2] * s[2] + self[3][3] * s[1]);
    inv_mat[1][3] = determ * (self[2][0] * s[5] - self[2][2] * s[2] + self[2][3] * s[1]);

    inv_mat[2][0] = determ * (self[1][0] * s[10] - self[1][1] * s[8] + self[1][3] * s[6]);
    inv_mat[2][1] = determ * -(self[0][0] * s[10] - self[0][1] * s[8] + self[0][3] * s[6]);
    inv_mat[2][2] = determ * (self[3][0] * s[4] - self[3][1] * s[2] + self[3][3] * s[0]);
    inv_mat[2][3] = determ * -(self[2][0] * s[4] - self[2][1] * s[2] + self[2][3] * s[0]);

    inv_mat[3][0] = determ * -(self[1][0] * s[9] - self[1][1] * s[7] + self[1][2] * s[6]);
    inv_mat[3][1] = determ * (self[0][0] * s[9] - self[0][1] * s[7] + self[0][2] * s[6]);
    inv_mat[3][2] = determ * -(self[3][0] * s[3] - self[3][1] * s[1] + self[3][2] * s[0]);
    inv_mat[3][3] = determ * (self[2][0] * s[3] - self[2][1] * s[1] + self[2][2] * s[0]);

    return inv_mat;
}

pub fn mulByVec4(self: Matrix(4, 4, f32), v: @Vector(4, f32)) @Vector(4, f32) {
    const x = (self[0][0] * v[0]) + (self[1][0] * v[1]) + (self[2][0] * v[2]) + (self[3][0] * v[3]);
    const y = (self[0][1] * v[0]) + (self[1][1] * v[1]) + (self[2][1] * v[2]) + (self[3][1] * v[3]);
    const z = (self[0][2] * v[0]) + (self[1][2] * v[1]) + (self[2][2] * v[2]) + (self[3][2] * v[3]);
    const w = (self[0][3] * v[0]) + (self[1][3] * v[1]) + (self[2][3] * v[2]) + (self[3][3] * v[3]);

    return .{ x, y, z, w };
}

const std = @import("std");
const vector = @import("vector.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
