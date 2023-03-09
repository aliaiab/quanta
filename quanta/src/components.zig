
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

pub const Visibility = struct 
{
    is_visible: bool,
};

pub const RendererMesh = struct 
{
    mesh: Renderer3D.MeshHandle,
    material: Renderer3D.MaterialHandle,
};

pub const PointLight = struct 
{
    intensity: f32,
    diffuse: [3]f32,

    ///Tells the editor how to serialize this field
    // pub const editor = .{
    //     .diffuse = .{
    //         .edit_type = "color",
    //     },
    // };

    pub const editor = EditorInfo
    {
        .diffuse = .{
            .edit_type = "color"
        }
    };

    pub const EditorInfo = struct 
    {
        diffuse: struct {
            edit_type: []const u8
        },
    };
};

const Renderer3D = @import("renderer.zig").Renderer3D;