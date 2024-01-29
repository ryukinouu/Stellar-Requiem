shader_type spatial;
render_mode blend_mix; // Use the appropriate blend mode for transparency

uniform float transparency : hint_range(0.0, 1.0) = 0.05;
uniform vec4 neon_color = vec4(1.0, 1.0, 1.0, 1.0); 
uniform float radius : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D albedo_texture;

void fragment() {
	vec4 texcolor = texture(albedo_texture, UV);
	
    vec2 centered_uv = (UV - vec2(0.5, 0.5)) * 2.0; 
    float angle = atan(centered_uv.y, centered_uv.x);
    if (angle < 0.0) {
        angle += 2.0 * PI; 
    }

    float angle_threshold = radius * 2.0 * PI;

    if (angle > angle_threshold) {
        discard;
    }
	
	ALBEDO = neon_color.rgb;
	EMISSION = texcolor.rgb;
	ALPHA = texcolor.a * transparency; // Apply transparency
}