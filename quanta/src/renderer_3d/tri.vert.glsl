#extension GL_GOOGLE_include_directive : enable
#extension GL_ARB_shader_draw_parameters : enable
#extension GL_EXT_scalar_block_layout : enable

#include "std/stdint.glsl"
#include "material_interface.glsl"

layout(push_constant, scalar) uniform Constants
{
    mat4 view_projection;
    u32 point_light_count;
    vec3 view_position;
} constants;

out Out
{
    flat u32 material_index;
    flat u32 triangle_index;
    vec3 position;
    vec4 position_light_space;
    vec3 normal;
    vec4 color;
    vec2 uv;
} out_data;

void main() 
{
    u32 instance_index = draw_commands[gl_DrawIDARB].instance_index;
    
    Vertex vertex = vertices[gl_VertexIndex]; 

    mat4 transform = mat4(transforms[instance_index]);

    uvec2 position_quantised = vertex_positions[gl_VertexIndex];

    vec2 position_xy = unpackHalf2x16(position_quantised[0]);
    vec2 position_zw = unpackHalf2x16(position_quantised[1]);

    vec3 dequantised_position = vec3(position_xy.x, position_xy.y, position_zw.x);

    vec4 translation = transform * vec4(dequantised_position, 1.0);

    f32 quantisation_scale = f32((1 << (10 - 1)) - 1);

    vec3 dequantised_normal = vec3(
        (f32(i32(bitfieldExtract(vertex.normal, 0, 10)))),
        (f32(i32(bitfieldExtract(vertex.normal, 10, 10)))),
        (f32(i32(bitfieldExtract(vertex.normal, 20, 10))))
    ) / quantisation_scale;

    vec2 dequantised_uv = unpackHalf2x16(vertex.uv);

    DirectionalLight directional_light = directional_lights[scene_uniforms.primary_directional_light_index];

    out_data.position = vec3(translation);
    out_data.position_light_space = directional_light.view_projection * vec4(out_data.position, 1);
    out_data.color = unpackUnorm4x8(vertex.color);
    out_data.normal = normalize(mat3(transpose(inverse(transform))) * dequantised_normal);
    out_data.uv = dequantised_uv;
    out_data.material_index = material_indices[instance_index];
    out_data.triangle_index = gl_VertexIndex / 3;

    gl_Position = scene_uniforms.view_projection * translation;
}
