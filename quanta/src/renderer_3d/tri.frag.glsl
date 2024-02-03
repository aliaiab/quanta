#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_scalar_block_layout : enable
#extension GL_EXT_nonuniform_qualifier : enable

#include "std/std.glsl"
#include "material_interface.glsl"

in Out
{
    flat u32 material_index;
    flat u32 triangle_index;
    vec3 position;
    vec4 position_light_space;
    vec3 normal;
    vec4 color;
    vec2 uv;
} in_data;

out vec4 output_color;

struct Material
{
    TextureHandle albedo_index;
    u32 albedo;
    TextureHandle metalness_index;
    f32 metalness;
    TextureHandle roughness_index;
    f32 roughness;
};

//This is specific to this material implementation
layout(binding = 5, scalar) restrict readonly buffer Materials
{
    Material materials[];
};

f32 distributionGGX(vec3 N, vec3 H, f32 roughness)
{
    f32 a = roughness * roughness;
    f32 a2 = a * a;
    f32 n_dot_h = max(dot(N, H), 0.0);
    f32 n_dot_h2 = n_dot_h * n_dot_h;

    f32 num = a2;
    f32 denom = n_dot_h2 * (a2 - 1.0) + 1.0;
    denom = PI * denom * denom;

    return num / denom;
}

f32 geometrySchlickGGX(f32 n_dot_v, f32 roughness)
{
    f32 r = roughness + 1.0;
    f32 k = (r * r) / 8.0;

    f32 num = n_dot_v;
    f32 denom = n_dot_v * (1.0 - k) + k;

    return num / denom;
}

f32 geometrySmith(vec3 N, vec3 V, vec3 L, f32 roughness)
{
    f32 NdotV = max(dot(N, V), 0.0);
    f32 NdotL = max(dot(N, L), 0.0);
    f32 ggx2 = geometrySchlickGGX(NdotV, roughness);
    f32 ggx1 = geometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}

vec3 fresnelSchlick(f32 cos_theta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cos_theta, 0.0, 1.0), 5.0);
}

vec4 directionalLightContribution(
    vec4 albedo,
    f32 roughness,
    f32 metallic,
    vec3 F0,
    DirectionalLight directional_light,
    vec3 normal,
    vec3 position,
    vec3 view_direction
)
{
    vec4 light_color = unpackUnorm4x8(directional_light.diffuse);

    vec3 light_direction = normalize(-directional_light.direction);
    vec3 half_direction = normalize(view_direction + light_direction);
    vec3 radiance = vec3(light_color);

    f32 NDF = distributionGGX(normal, half_direction, roughness);
    f32 G = geometrySmith(normal, view_direction, light_direction, roughness);
    vec3 F = fresnelSchlick(max(dot(half_direction, view_direction), 0.0), F0);

    vec3 kS = F;
    vec3 kD = vec3(1.0) - kS;
    kD *= 1.0 - metallic;

    f32 n_dot_l = max(dot(normal, light_direction), 0.0);

    vec3 numerator = NDF * G * F;
    f32 denominator = 4.0 * max(dot(normal, view_direction), 0.0) * n_dot_l + 0.0001;
    vec3 specular = numerator / denominator;

    return vec4((kD * albedo.rgb / PI + specular) * radiance * n_dot_l * directional_light.intensity, 0);
}

vec4 pointLightContribution(
    vec4 albedo,
    f32 roughness,
    f32 metallic,
    vec3 F0,
    PointLight point_light,
    vec3 normal,
    vec3 position,
    vec3 view_direction
)
{
    //point lights are spheres with a radius of 1cm
    const f32 emitter_radius = 0.01;

    vec4 light_color = unpackUnorm4x8(point_light.diffuse);

    vec3 light_direction = normalize(point_light.position - position);
    vec3 half_direction = normalize(view_direction + light_direction);
    f32 light_distance = distance(position, point_light.position);
    f32 attenuation = point_light.intensity / max(light_distance * light_distance, emitter_radius * emitter_radius);
    vec3 radiance = vec3(light_color) * attenuation;

    f32 NDF = distributionGGX(normal, half_direction, roughness);
    f32 G = geometrySmith(normal, view_direction, light_direction, roughness);
    vec3 F = fresnelSchlick(max(dot(half_direction, view_direction), 0.0), F0);

    vec3 kS = F;
    vec3 kD = vec3(1.0) - kS;
    kD *= 1.0 - metallic;

    f32 n_dot_l = max(dot(normal, light_direction), 0.0);

    vec3 numerator = NDF * G * F;
    f32 denominator = 4.0 * max(dot(normal, view_direction), 0.0) * n_dot_l + 0.0001;
    vec3 specular = numerator / denominator;

    return vec4((kD * albedo.rgb / PI + specular) * radiance * n_dot_l, 0);
}

void main()
{
    Material material = materials[in_data.material_index];

    vec3 view_direction = normalize(scene_uniforms.view_position - in_data.position);

    vec4 albedo = in_data.color * unpackUnorm4x8(material.albedo);
    f32 roughness = material.roughness;
    f32 metallic = material.metalness;

    if (material.albedo_index != 0)
    {
        albedo *= texture(samplers[nonuniformEXT(material.albedo_index)], in_data.uv);
    }

    if (material.roughness_index != 0)
    {
        metallic *= texture(samplers[nonuniformEXT(material.roughness_index)], in_data.uv).r;
        roughness *= texture(samplers[nonuniformEXT(material.roughness_index)], in_data.uv).g;
    }

    vec4 ambient_light = unpackUnorm4x8(scene_uniforms.ambient_light.diffuse);

    vec4 light_color = vec4(0);

    vec3 F0 = vec3(0.04);
    F0 = mix(F0, vec3(albedo), metallic);

    for (int i = 0; i < directional_lights.length(); i += 1)
    {
        DirectionalLight directional_light = directional_lights[i];

        vec3 projection_coordinates = in_data.position_light_space.xyz;

        projection_coordinates = projection_coordinates * 0.5 + 0.5;

        f32 current_depth = projection_coordinates.z;
        f32 closest_depth = texture(shadow_sampler, projection_coordinates.xy).r;

        f32 shadow = current_depth < closest_depth ? 1 : 0;

        // if (projection_coordinates.z > 1)
        // {
        // shadow = 0;
        // }

        light_color += directionalLightContribution(
                albedo,
                roughness,
                metallic,
                F0,
                directional_light,
                in_data.normal,
                in_data.position,
                view_direction
            ) * (1 - shadow);
    }

    u32 point_light_count = scene_uniforms.point_light_count;

    {
        u32 i = 0;

        while (i < point_light_count)
        {
            PointLight point_light = point_lights[i];

            light_color += pointLightContribution(
                    albedo,
                    roughness,
                    metallic,
                    F0,
                    point_light,
                    in_data.normal,
                    in_data.position,
                    view_direction
                );

            i += 1;
        }
    }

    vec4 ambient = ambient_light * albedo;

    output_color = ambient + vec4(vec3(light_color), 0);
    // output_color *= unpackUnorm4x8(in_data.triangle_index);
    // output_color = albedo;
    // output_color = vec4(in_data.normal, 1);
}
