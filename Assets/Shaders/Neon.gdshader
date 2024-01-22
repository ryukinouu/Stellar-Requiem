shader_type spatial;
render_mode unshaded; // Ensure the material is unaffected by lighting

uniform vec4 neon_color = vec4(0.0, 1.0, 0.0, 1.0); // Neon green as an example

void fragment() {
    EMISSION = neon_color.rgb; // The material will glow with this color
    ALPHA = neon_color.a; // Set the alpha to the alpha of the neon color
}