layout(rgba16f, binding = 0) uniform restrict readonly image2D read_target;
layout(rgba8, binding = 1) uniform restrict writeonly image2D write_target;

layout(push_constant) uniform PushConstants
{
    float exposure;
} push_constants;

layout(local_size_x_id = 0, local_size_y_id = 1, local_size_z_id = 2) in;

void main() 
{
    ivec2 target_size = imageSize(read_target);
    ivec2 write_target_size = imageSize(write_target);

    if (
        !(gl_GlobalInvocationID.x < write_target_size.x && gl_GlobalInvocationID.y < write_target_size.y)
    )
    {
        return;
    }

    ivec2 position = ivec2(gl_GlobalInvocationID.xy);

    vec2 position_uv = vec2(position) / vec2(write_target_size);

    ivec2 out_position = ivec2(round(position_uv * vec2(target_size))); 

    vec4 pixel = imageLoad(read_target, out_position);

    float gamma = 2.2;
    float exposure = push_constants.exposure;

    pixel.rgb = vec3(1.0) - exp(-pixel.rgb * exposure);
    pixel.rgb = pow(pixel.rgb, vec3(1.0 / gamma));

    imageStore(write_target, position, pixel);
}