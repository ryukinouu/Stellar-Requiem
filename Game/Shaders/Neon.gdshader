shader_type spatial;
render_mode unshaded; // Ensure the material is unaffected by lighting

uniform vec4 neon_color = vec4(1.0, 1.0, 1.0, 1.0); // Neon green as an example
uniform float transparency : hint_range(0.0, 1.0) = 0.2;

void fragment() {
	ALBEDO = neon_color.rgb;
    EMISSION = neon_color.rgb; // The material will glow with this color
    ALPHA = neon_color.a * transparency; // Set the alpha to the alpha of the neon color
}