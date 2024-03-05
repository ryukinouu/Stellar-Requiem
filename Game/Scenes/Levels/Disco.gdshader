shader_type spatial;

//uniform bool enabled : hint_bool;

void fragment() {
    //if (enabled) {
        vec2 ires = 1.0 / VIEWPORT_SIZE.xy;
        float s = 0.0, v = 0.0;
        vec2 uv = (FRAGCOORD.xy * ires) * 2.0 - 1.0;
        float itime = (TIME - 2.0) * 58.0;
        vec3 col = vec3(0);
        vec3 init = vec3(sin(itime * .0032) * .3, .35 - cos(itime * .005) * .3, itime * 0.002);
        for (int r = 0; r < 100; r++) {
            vec3 p = init + s * vec3(uv, 0.05);
            p.z = fract(p.z);
            // Thanks to Kali's little chaotic loop...
            for (int i = 0; i < 10; i++) p = abs(p * 2.04) / dot(p, p) - .9;
            v += pow(dot(p, p), .7) * .06;
            col += vec3(v * 0.2 + .4, 12.0 - s * 2.0, .1 + v * 1.0) * v * 0.00003;
            s += .025;
        }
        ALBEDO = clamp(col, 0.0, 1.0);
    //}
}

// No light() function needed unless custom lighting is required. In most cases, the lighting is handled by Godot.