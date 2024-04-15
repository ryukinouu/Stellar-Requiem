shader_type spatial;
render_mode unshaded;

uniform float saturation = 0.5; // 0.0 is fully desaturated, 1.0 is fully saturated

void fragment() {
    vec2 uv = UV;
    vec3 color = vec3(0.0);

    color.r = sin(uv.x * 6.2831 + TIME) * 0.5 + 0.5;
    color.g = sin(uv.x * 6.2831 + 2.0944 + TIME) * 0.5 + 0.5;
    color.b = sin(uv.x * 6.2831 + 4.18879 + TIME) * 0.5 + 0.5;

    // Calculate the luminance of the color
    float luminance = dot(color, vec3(0.3, 0.59, 0.11));
    // Create a grayscale color based on the luminance
    vec3 grayscale = vec3(luminance);
    // Interpolate between the grayscale and the original color based on saturation
    vec3 desaturatedColor = mix(grayscale, color, saturation);

    float glowStrength = 1.5 + sin(TIME * 2.0) * 0.5; // Pulsating glow strength
    ALBEDO = desaturatedColor;
    EMISSION = desaturatedColor * glowStrength; // Adjust the glow strength as needed
}