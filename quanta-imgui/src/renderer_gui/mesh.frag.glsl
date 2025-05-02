#version 450 
#extension GL_EXT_nonuniform_qualifier : enable

in Out 
{
    vec2 uv;
    vec4 color;
} in_data;

out vec4 out_color;

layout(binding = 1) uniform sampler2D textures[2048];

layout(push_constant) uniform PushConstants
{
    mat4 projection;
    uint texture_index;
} push_constants;

void main() 
{   
    vec4 texture_sample;

    if (push_constants.texture_index != 0)
    {
        texture_sample = texture(textures[nonuniformEXT(push_constants.texture_index - 1)], in_data.uv);

        //Check if the texture is the font atlas, which is always at texture index 1 right now
        if (push_constants.texture_index == 1) {
            //TODO: add component swizzles to quanta images/views
            texture_sample.a = texture_sample.r;
            texture_sample.rgb = vec3(1);
        }
        else if (push_constants.texture_index > 1) {
            texture_sample.r = pow(texture_sample.r, 1 / 2.2);
            texture_sample.g = pow(texture_sample.g, 1 / 2.2);
            texture_sample.b = pow(texture_sample.b, 1 / 2.2);
            texture_sample.a = pow(texture_sample.a, 1 / 2.2);
        }
    }
    else 
    {
        texture_sample = vec4(1);
    }

    out_color = in_data.color * texture_sample;
}