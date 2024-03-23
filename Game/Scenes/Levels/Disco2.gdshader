shader_type spatial;

const float TWO_PI = 6.283185307179586;

uniform float grid_size = 15.0;
uniform float tile_speed = 2.0;
uniform vec4 color1 = vec4(0.62, 0.14, 0.0, 1.0); // These are vec4 because of the alpha channel
uniform vec4 color2 = vec4(0.93, 0.54, 1.0, 1.0);
uniform vec4 color3 = vec4(0.36, 0.29, 0.41, 1.0);

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

vec3 getColor(in vec2 coord, in vec2 tile_coord) {
    float tile_mod = mod(tile_coord.x + tile_coord.y, 3.0);
    if (tile_mod == 1.0) {
        return color1.rgb;
    } else if (tile_mod == 2.0) { 
        return color2.rgb;
    }
    return color3.rgb;
}

void fragment() {
    vec2 uv = UV; // Use the UV directly for 3D objects.

    vec2 grid_uv = fract(uv * grid_size);
    vec2 tile_coord = floor(uv * grid_size);

    vec3 color = getColor(grid_uv, tile_coord);
    vec2 black = smoothstep(1.08, 0.95, cos(grid_uv * TWO_PI));

    // Correct potential misassignment here
    // Ensuring operations are component-wise where necessary
    color *= black.x * black.y * smoothstep(1.0, 0.0, length(fract(grid_uv) - 0.5));

    // Correcting this line to ensure there's no 'vec3 = float' situation
    //float randomValue = 0.1 + 0.5 * cos(random(floor(uv * grid_size)) + TIME * tile_speed);
    //color *= randomValue; // Correctly applying the float to each component of the vec3

    ALBEDO = color;
}