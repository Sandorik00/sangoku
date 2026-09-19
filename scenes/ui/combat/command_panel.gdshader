shader_type canvas_item;

uniform float border_width_px = 2.0;
uniform float border_radius_px = 8.0;

uniform vec4 color_start : source_color = vec4(0.745, 0.745, 0.745, 0.8);
uniform vec4 color_end   : source_color = vec4(0.345, 0.345, 0.345, 0.8);
uniform float gradient_stop = 0.75;

void fragment() {
    vec2 uv = UV;
    vec2 element_size = vec2(1.0) / TEXTURE_PIXEL_SIZE;

    float t = clamp(uv.y / gradient_stop, 0.0, 1.0);
    vec4 grad_color = mix(color_start, color_end, t);

    float bw = border_width_px / element_size.y;
    float br = border_radius_px / element_size.y;

    vec2 q = abs(uv - 0.5) - 0.5 + br;
    float dist = length(max(q, 0.0)) - br;

    float outer = smoothstep(0.002, -0.002, dist);
    float inner = smoothstep(0.002, -0.002, dist + bw);

    COLOR = grad_color * (outer - inner);
}
