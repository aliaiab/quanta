//Standard interface for loading material parameters
//Include this file into material vertex and fragment shaders

//Standard vertex format
//Currently the only format, as the renderer has fixed function mesh layouts
struct Vertex 
{
    //Quantised vertex normal in i10_10_10_2 format 
    i32 normal;
    u32 color;
    u32 uv;
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

layout(set = 0, binding = 3, scalar) restrict readonly buffer MaterialIndicies
{
    u32 material_indices[];
};

struct DrawIndexedIndirectCommand
{
    u32 index_count;
    u32 instance_count;
    u32 first_index;
    u32 vertex_offset;
    u32 first_instance; 
    u32 instance_index;
};

layout(set = 0, binding = 4, scalar) restrict readonly buffer DrawCommands
{
    DrawIndexedIndirectCommand draw_commands[];
};

struct AmbientLight 
{
    u32 diffuse;
};

struct DirectionalLight 
{
    vec3 direction;
    f32 intensity;
    u32 diffuse;
    mat4 view_projection;
};

struct PointLight 
{
    vec3 position;
    f32 intensity;
    u32 diffuse;
};

//Should really be a uniform buffer, not a storage buffer
layout(binding = 10, scalar) restrict readonly buffer SceneUniforms
{
    mat4 view_projection;
    vec3 view_position;

    u32 point_light_count;
    AmbientLight ambient_light;

    //The shadow casting directional light
    u32 primary_directional_light_index;
} scene_uniforms;

layout(binding = 6) uniform sampler2D samplers[16000];

layout(binding = 7, scalar) restrict readonly buffer PointLights 
{
    PointLight point_lights[];
};

layout(binding = 11, scalar) restrict readonly buffer DirectionalLights
{
    DirectionalLight directional_lights[];
};

layout(binding = 8) uniform samplerCube environment_sampler;
layout(binding = 9) uniform sampler2D shadow_sampler;

//Used to index into samplers. Use this to store textures in material data structs
#define TextureHandle u32