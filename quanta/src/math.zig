pub const zalgebra = @compileError("Deprecated, use quanta math functions instead");

pub const vector = @import("math/vector.zig");
pub const matrix = @import("math/matrix.zig");
pub const geometric = @import("math/geometric.zig");

test {
    _ = vector;
    _ = matrix;
}
