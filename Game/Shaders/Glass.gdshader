shader_type spatial;
render_mode blend_mix, specular_schlick_ggx, ambient_light_disabled;

uniform vec4 Color = vec4(0.5, 0.5, 0.8, 1.0);  // Light grey tint with full opacity
uniform float Shine = 0.2;
uniform float Roughness = 0.2;

void vertex() {
}

void fragment() {
    vec3 albedoColor = Color.rgb;
    float alpha = Color.a;

    ALBEDO = albedoColor;
    ALPHA = alpha;
    METALLIC = Shine;
    ROUGHNESS = Roughness;
	
	
}

void light() {
}