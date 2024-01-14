//!Geomtric algebra objects

//0-vector
pub fn Scalar(comptime T: type) type {
    return T;
}

//1-vector
pub fn Vector(comptime T: type, comptime N: comptime_int) type {
    return struct {
        components: @Vector(N, T),
    };
}

pub fn BiVector(comptime T: type, comptime N: comptime_int) type {
    //assume 3D for now
    std.debug.assert(N == 3);

    return struct {
        components: @Vector(N, T),
    };
}

const Rotorf32 = Rotor(f32, 3);

//Rotor (multivector) which describes the geometric product of two vectors
pub fn Rotor(comptime T: type, comptime N: comptime_int) type {
    std.debug.assert(N == 3);

    return struct {
        a: T,
        b: BiVector(T, N),
    };
}

pub fn add() void {}
pub fn sub() void {}
pub fn mul() void {}
pub fn div() void {}
pub fn wedge() void {}
pub fn dot() void {}

const std = @import("std");
