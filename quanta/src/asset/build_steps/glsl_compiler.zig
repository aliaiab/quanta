//!A replacement for google's shaderc. A frontend to khronos glslang for use in zig build.
//!As such, this frontend does not need to provide a human readable command line interface.

const glslang_c = @cImport(
    @cInclude("glslang/Include/glslang_c_interface.h"),
);

extern fn glslang_default_resource() callconv(.C) *const glslang_c.glslang_resource_t;

pub fn main() !void {
    std.log.info("Hello from glsl_compiler", .{});

    if (glslang_c.glslang_initialize_process() == 0) {
        return error.FailedToInitializeProcess;
    }

    defer glslang_c.glslang_finalize_process();

    //TODO: deduce from file name
    const shader_stage = glslang_c.GLSLANG_STAGE_VERTEX;

    const input = glslang_c.glslang_input_t{
        .language = glslang_c.GLSLANG_SOURCE_GLSL,
        .stage = shader_stage,
        .client = glslang_c.GLSLANG_CLIENT_VULKAN,
        .client_version = glslang_c.GLSLANG_TARGET_VULKAN_1_3,
        .target_language = glslang_c.GLSLANG_TARGET_SPV,
        .target_language_version = glslang_c.GLSLANG_TARGET_SPV_1_6,
        .code = test_glsl_vertex_shader,
        .default_version = 450,
        .default_profile = glslang_c.GLSLANG_NO_PROFILE,
        .force_default_version_and_profile = @intFromBool(false),
        .forward_compatible = @intFromBool(false),
        .messages = glslang_c.GLSLANG_MSG_DEFAULT_BIT,
        .resource = glslang_default_resource(),
    };

    const shader = glslang_c.glslang_shader_create(&input) orelse return error.FailedToCreateShader;
    defer glslang_c.glslang_shader_delete(shader);

    errdefer {
        std.log.err("{s}", .{glslang_c.glslang_shader_get_info_log(shader)});
        std.log.err("{s}", .{glslang_c.glslang_shader_get_info_debug_log(shader)});
    }

    if (glslang_c.glslang_shader_preprocess(shader, &input) == 0) {
        return error.CompileFailed;
    }

    if (glslang_c.glslang_shader_parse(shader, &input) == 0) {
        return error.CompileFailed;
    }

    const program = glslang_c.glslang_program_create() orelse return error.FailedToCreateProgram;
    defer glslang_c.glslang_program_delete(program);

    glslang_c.glslang_program_add_shader(program, shader);

    if (glslang_c.glslang_program_link(program, glslang_c.GLSLANG_MSG_SPV_RULES_BIT | glslang_c.GLSLANG_MSG_VULKAN_RULES_BIT) == 0) {
        return error.LinkFailed;
    }

    glslang_c.glslang_program_SPIRV_generate(program, shader_stage);

    const spirv_messages = glslang_c.glslang_program_SPIRV_get_messages(program);

    if (spirv_messages != null) {
        std.log.err("{s}", .{spirv_messages});
    }

    const binary_size = glslang_c.glslang_program_SPIRV_get_size(program);
    const spirv_ptr = glslang_c.glslang_program_SPIRV_get_ptr(program);

    const spirv_data = spirv_ptr[0..binary_size];

    std.log.info("Generated binary: len = {}", .{spirv_data.len});

    std.fs.cwd().makeDir("zig-out/") catch {};

    try std.fs.cwd().writeFile("zig-out/compiled.vert.spv", std.mem.sliceAsBytes(spirv_data));
}

const std = @import("std");

const test_glsl_vertex_shader =
    \\#version 450
    \\#extension GL_EXT_scalar_block_layout : enable
    \\#extension GL_ARB_shader_draw_parameters : enable
    \\
    \\#define u32 uint
    \\
    \\layout(push_constant, scalar) uniform Constants
    \\{
    \\    mat4 view_projection;
    \\    u32 point_light_count;
    \\    vec3 view_position;
    \\} constants;
    \\
    \\struct AmbientLight 
    \\{
    \\    uint diffuse;
    \\};
    \\
    \\struct DirectionalLight 
    \\{
    \\    vec3 direction;
    \\    float intensity;
    \\    uint diffuse;
    \\};
    \\
    \\//Should really be a uniform buffer, not a storage buffer
    \\layout(binding = 10, scalar) restrict readonly buffer SceneUniforms
    \\{
    \\    mat4 view_projection;
    \\    vec3 view_position;
    \\
    \\    u32 point_light_count;
    \\    AmbientLight ambient_light;
    \\
    \\    DirectionalLight directional_light;
    \\    bool use_directional_light;
    \\    mat4 directional_light_view_projection;
    \\} scene_uniforms;
    \\
    \\struct Vertex 
    \\{
    \\    int normal;
    \\    uint color;
    \\    uint uv;
    \\};
    \\
    \\layout(set = 0, binding = 0, scalar) restrict readonly buffer VertexPositions
    \\{
    \\    uvec2 vertex_positions[];
    \\};
    \\
    \\layout(set = 0, binding = 1, scalar) restrict readonly buffer Vertices
    \\{
    \\    Vertex vertices[];
    \\};
    \\
    \\layout(set = 0, binding = 2, scalar) restrict readonly buffer Transforms
    \\{
    \\    mat4x3 transforms[];
    \\};
    \\
    \\layout(set = 0, binding = 3, scalar) restrict readonly buffer MaterialIndicies
    \\{
    \\    uint material_indices[];
    \\};
    \\
    \\struct DrawIndexedIndirectCommand
    \\{
    \\    u32 index_count;
    \\    u32 instance_count;
    \\    u32 first_index;
    \\    u32 vertex_offset;
    \\    u32 first_instance; 
    \\    u32 instance_index;
    \\};
    \\
    \\layout(set = 0, binding = 4, scalar) restrict readonly buffer DrawCommands
    \\{
    \\    DrawIndexedIndirectCommand draw_commands[];
    \\};
    \\
    \\layout(location = 0) out Out
    \\{
    \\    flat uint material_index;
    \\    flat uint triangle_index;
    \\    vec3 position;
    \\    vec4 position_light_space;
    \\    vec3 normal;
    \\    vec4 color;
    \\    vec2 uv;
    \\} out_data;
    \\
    \\void main() 
    \\{
    \\    uint instance_index = draw_commands[gl_DrawIDARB].instance_index;
    \\    
    \\    Vertex vertex = vertices[gl_VertexIndex]; 
    \\    mat4 transform = mat4(transforms[instance_index]);
    \\
    \\    uvec2 position_quantised = vertex_positions[gl_VertexIndex];
    \\
    \\    vec2 position_xy = unpackHalf2x16(position_quantised[0]);
    \\    vec2 position_zw = unpackHalf2x16(position_quantised[1]);
    \\
    \\    vec3 dequantised_position = vec3(position_xy.x, position_xy.y, position_zw.x);
    \\
    \\    vec4 translation = transform * vec4(dequantised_position, 1.0);
    \\
    \\    float quantisation_scale = float((1 << (10 - 1)) - 1);
    \\
    \\    vec3 dequantised_normal = vec3(
    \\        (float(int(bitfieldExtract(vertex.normal, 0, 10)))),
    \\        (float(int(bitfieldExtract(vertex.normal, 10, 10)))),
    \\        (float(int(bitfieldExtract(vertex.normal, 20, 10))))
    \\    ) / quantisation_scale;
    \\
    \\    vec2 dequantised_uv = unpackHalf2x16(vertex.uv);
    \\
    \\    out_data.position = vec3(translation);
    \\    out_data.position_light_space = scene_uniforms.directional_light_view_projection * vec4(out_data.position, 1);
    \\    out_data.color = unpackUnorm4x8(vertex.color);
    \\    out_data.normal = normalize(mat3(transpose(inverse(transform))) * dequantised_normal);
    \\    out_data.uv = dequantised_uv;
    \\    out_data.material_index = material_indices[instance_index];
    \\    out_data.triangle_index = gl_VertexIndex / 3;
    \\
    \\    gl_Position = scene_uniforms.view_projection * translation;
    \\}
;
