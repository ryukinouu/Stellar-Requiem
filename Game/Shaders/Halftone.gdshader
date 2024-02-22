shader_type canvas_item;

uniform float bend_strength : hint_range(-2.0, 2.0) = 1.0;

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5, 0.5);
    uv -= center;
    
    // Calculate radius from the center
    float radius = length(uv);
    
    // Apply the bending effect
    float bend = pow(radius, 2.0) * bend_strength;
    
    // Adjust the UV coordinates
    uv = uv + uv * bend;
    
    // Restore the coordinates to their original space
    uv += center;
    
    // Use the modified UV coordinates to get the correct color from the texture
    COLOR = texture(TEXTURE, uv);
}