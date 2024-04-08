shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo_texture;
uniform float roughness : hint_range(0, 1) = 0.05;
uniform float metallic : hint_range(0, 1) = 1.0;
uniform vec3 reflection_color = vec3(1, 0.843, 0); // Gold color, you can adjust this to match the road's color in the image

void fragment() {
    vec3 albedo = texture(albedo_texture, UV).rgb;
    vec3 base_color = albedo * reflection_color;

    vec3 view_dir = normalize(-VERTEX);
    vec3 reflected_dir = reflect(view_dir, NORMAL);

    // Placeholder for reflection; use actual environmental mapping in your project.
    vec3 reflection = vec3(1.0); // Assuming a white environment for this example

    // The reflection color can be more complex depending on the actual environment
    // Normally you would use scene's environment for reflections like this:
    // vec3 reflection = textureLod(ENVIRONMENT, reflected_dir, roughness).rgb;

    float reflection_factor = pow(1.0 - dot(view_dir, NORMAL), 5.0);
    reflection_factor = mix(1.0, reflection_factor, roughness);

    ALBEDO = mix(base_color, reflection * reflection_color, reflection_factor);
    METALLIC = metallic;
    ROUGHNESS = roughness;
}