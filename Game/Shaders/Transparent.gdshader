shader_type spatial;

// Declare a shader parameter for transparency
uniform float transparency : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    // Use the transparency parameter for alpha
    ALPHA = transparency;
}