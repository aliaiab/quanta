#version 450
#extension GL_EXT_scalar_block_layout : enable
#extension GL_ARB_shader_draw_parameters : enable

struct Vertex {
    vec2 position;
    vec2 uv;
    uint color;
};

struct DrawData {
    ivec2 scissor_min;
    ivec2 scissor_max;
    uint texture_index;
};

layout(binding = 0, scalar) restrict readonly buffer Vertices {
    Vertex vertices[];
};

layout(binding = 1, scalar) restrict readonly buffer DrawDataBuffer {
    DrawData draws_data[];
};

layout(push_constant) uniform PushConstants {
    mat4 projection;
} push_constants;

out Out {
    vec2 uv;
    vec4 color;
    flat uint texture_index;
} out_data;

void main() {
    uint draw_index = gl_DrawIDARB;

    DrawData draw_data = draws_data[draw_index];

    Vertex vertex = vertices[gl_VertexIndex];

    vec2 clipped_position = clamp(vertex.position, draw_data.scissor_min, draw_data.scissor_min + draw_data.scissor_max);

    // vec2 clipped_position = vertex.position;

    out_data.uv = vertex.uv;
    out_data.color = unpackUnorm4x8(vertex.color);
    out_data.texture_index = draw_data.texture_index;

    gl_Position = push_constants.projection * vec4(clipped_position, 0, 1);
}
