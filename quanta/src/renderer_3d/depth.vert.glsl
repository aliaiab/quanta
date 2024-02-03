#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_scalar_block_layout : enable
#extension GL_ARB_shader_draw_parameters : enable

#include "std/std.glsl"

layout(push_constant) uniform Constants
{
    mat4 view_projection;
} constants;

layout(set = 0, binding = 0, scalar) restrict readonly buffer VertexPositions
{
    uvec2 vertex_positions[];
};

layout(set = 0, binding = 1, scalar) restrict readonly buffer Transforms
{
    mat4x3 transforms[];
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

layout(set = 0, binding = 2, scalar) restrict readonly buffer DrawCommands
{
    DrawIndexedIndirectCommand draw_commands[];
};

void main() 
{
    uint instance_index = draw_commands[gl_DrawIDARB].instance_index;
    
    uvec2 position_quantised = vertex_positions[gl_VertexIndex];

    vec2 position_xy = unpackHalf2x16(position_quantised[0]);
    vec2 position_zw = unpackHalf2x16(position_quantised[1]);

    vec3 dequantised_position = vec3(position_xy.x, position_xy.y, position_zw.x);

    vec3 vertex_position = dequantised_position; 
    mat4 transform = mat4(transforms[instance_index]);

    gl_Position = constants.view_projection * transform * vec4(vertex_position, 1.0);
}
