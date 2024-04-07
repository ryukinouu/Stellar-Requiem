shader_type spatial;
// 'unshaded' tells Godot not to apply any lighting calculations to this shader
render_mode unshaded;

uniform float timeScaleFactor = .04;
uniform sampler2D noise_texture;

float localTime() {
return TIME * timeScaleFactor;
}

mat2 makem2(float theta) {
	float c = cos(theta);
	float s = sin(theta);
	return mat2(vec2(c, -s), vec2(s, c));
}

float noise(vec2 x) {
// Fetching noise based on the UV scaled down for a more "zoomed in" look
	return texture(noise_texture, x * .01).r;
}

vec2 gradn(vec2 p) {
	float ep = .09;
	float gradx = noise(vec2(p.x + ep, p.y)) - noise(vec2(p.x - ep, p.y));
	float grady = noise(vec2(p.x, p.y + ep)) - noise(vec2(p.x, p.y - ep));
	return vec2(gradx, grady);
}

float flow(vec2 p) {
	float z = 2.;
	float rz = 0.;
	vec2 bp = p;

	for(float i = 1.; i < 7.; ++i) {
		p += localTime() * .6;
		bp += localTime() * 1.9;
		vec2 gr = gradn(i * p * .34 + localTime() * 1.);
		gr *= makem2(localTime() * 6. - (.05 * p.x + 0.03 * p.y) * 40.);
		p += gr * .5;
		rz += (sin(noise(p) * 7.) *.5 + .5) / z;
		p = mix(bp, p, .77);
		z *= 1.4;
		p *= 2.;
		bp *= 1.9;
	}
	return rz;
}

void fragment() {
// Convert fragment position to a 2D noise coordinate
// You might need to scale the 'VERTEX' depending on the size of your model
	vec2 noiseCoord = (VERTEX.xz + vec2(1.0)) * 0.5;

// Apply the noise function to get the flow effect based on 3D position
	float rz = flow(noiseCoord);

// Calculate color based on the flow effect
// The color values may need to be tweaked to get the lava-like appearance
	vec3 col = vec3(1.0, 0.5, 0.0) * rz;
	col = pow(col, vec3(1.4)); // Adjust the exponent as needed to brighten or darken the effect

// Set the albedo color of the material
	ALBEDO = col;
}
