pub const Force = struct {
    x: f32,
    y: f32,
    z: f32,
};

pub const Mass = struct {
    value: f32,
};

pub const TerminalVelocity = struct {
    x: f32,
    y: f32,
    z: f32,
};

pub const Velocity = struct {
    x: f32,
    y: f32,
    z: f32,
};

pub const Acceleration = struct {
    x: f32,
    y: f32,
    z: f32,
};

pub const Position = struct {
    vector: @Vector(3, f32),
};

pub const Orientation = struct {
    ///Normal vector orientation
    ///Should be normalized
    vector: @Vector(3, f32),
};

pub const NonUniformScale = struct {
    x: f32,
    y: f32,
    z: f32,
};

//Represents a rigid transformation of an entities' vector basis to its position vector in space R3
pub const RigidTransform = struct {
    _: ecs.ComponentStore.IsComponentSet = .{},

    position: Position,
    orientation: Orientation = .{ .x = 0, .y = 0, .z = 0 },
    scale: NonUniformScale = .{ .x = 1, .y = 1, .z = 1 },
};

pub const Visibility = struct {
    is_visible: bool,
};

pub const RendererMesh = struct {
    mesh: Renderer3D.MeshHandle,
    material: Renderer3D.MaterialHandle,
};

pub const DirectionalLight = struct {
    intensity: f32,
    diffuse: [3]f32,

    pub const editor = EditorInfo{ .diffuse = .{ .edit_type = "color" } };

    pub const EditorInfo = struct {
        diffuse: struct { edit_type: []const u8 },
    };
};

pub const PointLight = struct {
    intensity: f32,
    diffuse: [3]f32,

    pub const editor = EditorInfo{ .diffuse = .{ .edit_type = "color" } };

    pub const EditorInfo = struct {
        diffuse: struct { edit_type: []const u8 },
    };
};

pub const RendererMeshInstance = struct {
    mesh: u32,
    material: renderer_3d_graph.Material,
};

const Renderer3D = @import("renderer_3d.zig").Renderer3D;
const renderer_3d_graph = @import("renderer_3d/renderer_3d_graph.zig");
const ecs = @import("ecs.zig");
