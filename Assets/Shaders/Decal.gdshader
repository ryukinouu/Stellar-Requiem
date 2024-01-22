shader_type spatial;
render_mode blend_mix; // Use the appropriate blend mode for transparency

uniform float transparency : hint_range(0.0, 1.0) = 0.05;
uniform sampler2D albedo_texture;

void fragment() {
    vec4 texcolor = texture(albedo_texture, UV);
    ALBEDO = texcolor.rgb;
    ALPHA = texcolor.a * transparency; // Apply transparency
}