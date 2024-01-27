#version 450
#extension GL_EXT_scalar_block_layout : enable
#extension GL_ARB_shader_draw_parameters : enable
#extension GL_EXT_mesh_shader : enable

//Perhaps this should be specified at runtime by the pipeline
layout(local_size_x = 128, local_size_y = 1, local_size_z = 1) in;
layout(triangles, max_vertices = 256, max_primitives = 256) out;

struct Vertex 
{
    uint normal;
    uint color;
    uint uv;
};

struct Meshlet 
{
    uint primitive_count;
    vec3 aabb_min;
    vec3 aabb_max;  
};

layout(set = 0, binding = 0, scalar) restrict readonly buffer VertexPositions
{
    uvec2 vertex_positions[];
};

layout(set = 0, binding = 1, scalar) restrict readonly buffer Vertices
{
    Vertex vertices[];
};

layout(set = 0, binding = 2, scalar) restrict readonly buffer Transforms
{
    mat4x3 transforms[];
};

layout(set = 0, binding = 10, scalar) restrict readonly buffer Transforms
{
    mat4x3 transforms[];
};

layout(set = 0, binding = 11, scalar) restrict readonly buffer Meshlet
{
    Meshlet meshlets[];
};

layout(location = 0) out VertexOut
{
    vec3 position;
    vec4 position_light_space;
    vec3 normal;
    vec4 color;
    vec2 uv;
} vertex_out[];

///Essentially 'flat' data
layout(location = 1) out perprimitiveEXT PrimitiveOut {
    uint material_index;
    uint triangle_index;
} primitive_out[];

void main() {
    SetMeshOutputsEXT(256, 256);

    gl_MeshVerticesEXT[0].gl_Position = vec4(0);
    gl_PrimitiveTriangleIndicesEXT[0] = uvec3(0, 0 ,0);
}