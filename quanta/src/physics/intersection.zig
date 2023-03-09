const std = @import("std");

///Fast branchless ray-aabb intersection test courtesy of https://tavianator.com/2011/ray_box.html
///For fast bulk tests, a hoisted version should be used
pub inline fn rayAABBIntersection(
    ray_origin: @Vector(3, f32), 
    ray_direction: @Vector(3, f32), 
    box_min: @Vector(3, f32),
    box_max: @Vector(3, f32),
) ?struct { t_min: f32, t_max: f32 } 
{
    var inv_ray_direction = @splat(3, @as(f32, 1)) / ray_direction;

    var tx1: f32 = (box_min[0] - ray_origin[0]) * inv_ray_direction[0];
    var tx2: f32 = (box_max[0] - ray_origin[0]) * inv_ray_direction[0];

    var t_min: f32 = @min(tx1, tx2);
    var t_max: f32 = @max(tx1, tx2);

    var ty1: f32 = (box_min[1] - ray_origin[1]) * inv_ray_direction[1];
    var ty2: f32 = (box_max[1] - ray_origin[1]) * inv_ray_direction[1];

    t_min = @max(t_min, @min(ty1, ty2));
    t_max = @min(t_max, @max(ty1, ty2));

    return if (t_max >= t_min) .{ .t_min = t_min, .t_max = t_max } else null;
}

test "Basic AABB Intersection"
{
    const ray_origin = @Vector(3, f32) { -1, -1, -1 };
    const ray_direction = @Vector(3, f32) { 10, 10, 10 };

    const box_min = @Vector(3, f32) { 0, 0, 0 };
    const box_max = @Vector(3, f32) { 1, 1, 1 };

    try std.testing.expect(rayAABBIntersection(ray_origin, ray_direction, box_min, box_max).hit);
}