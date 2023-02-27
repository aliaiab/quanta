
pub const Force = struct 
{
    x: f32,
    y: f32,
    z: f32,
};

pub const Mass = struct 
{
    value: f32,
};

pub const TerminalVelocity = struct 
{
    x: f32,
    y: f32,
    z: f32,
};

pub const Velocity = struct 
{
    x: f32,
    y: f32,
    z: f32,
};

pub const Acceleration = struct 
{
    x: f32,
    y: f32,
    z: f32,
};

pub const Position = struct 
{ 
    x: f32,
    y: f32,
    z: f32,    
};

pub const Rotation = struct 
{
    x: f32,
    y: f32,
    z: f32,
};

pub const UniformScale = struct 
{
    value: f32,
};

pub const NonUniformScale = struct 
{
    x: f32,
    y: f32,
    z: f32,
};

pub const RendererMesh = struct 
{
    const Renderer3D = @import("../renderer.zig").Renderer3D;

    mesh: Renderer3D.MeshHandle,
    material: Renderer3D.MaterialHandle,
};