shader_type spatial;
render_mode blend_add, unshaded;

uniform sampler2D albedo_tex;
uniform sampler2D noise_tex_1;
uniform sampler2D noise_tex_2;
uniform float distortion_factor;
uniform float distortion_speed;

varying vec2 noise_uv;
varying vec2 noise_uv2;

uniform float saturation: hint_range(0.5,5) = 1.0;
uniform float pulse_rate = 5.0;
uniform float pulse_intensity = 0.1;
uniform float opacity : hint_range(0,1) = 1.0;


void vertex() {
	noise_uv = fma(vec2(TIME), vec2(distortion_speed), UV);
	noise_uv2 = fma(vec2(TIME), vec2(distortion_speed), vec2(0.3, 0.6) - UV);
	float pulse_freq = TIME * pulse_rate * 6.2831853;
	float pulse_val = 0.5 * (sin(pulse_freq) + 1.0);
	pulse_val = pow(pulse_val, 4);
	VERTEX += NORMAL * (pulse_val * pulse_intensity);
}

void fragment() {
	vec2 noise = vec2(texture(noise_tex_1, noise_uv).r, texture(noise_tex_2, noise_uv).r);
	vec2 noise2 = vec2(texture(noise_tex_1, noise_uv2).r, texture(noise_tex_2, noise_uv2).r);
	vec2 base_uv = UV + (noise + noise2) * distortion_factor;
	
	float normal_dot = dot(NORMAL, vec3(0,0,1));
	float arc = asin(normal_dot*saturation)/0.785398;
	float alpha_value = arc * opacity;
	
	normal_dot = max(normal_dot, 0.0);
	arc = pow(arc,10);
	alpha_value = min(opacity, alpha_value);
	ALPHA = (alpha_value);
	ALBEDO = texture(albedo_tex, base_uv).rgb;
}