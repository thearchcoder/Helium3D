shader_type canvas_item;

uniform float sharpness : hint_range(0.0, 10.0) = 1.0;
uniform bool display_tiled_render = false;
uniform sampler2D tiled_render;

// Chroma key parameters
uniform vec3 chroma_key_color = vec3(0.0, 1.0, 0.0); // Default green
uniform float chroma_key_similarity = 0.5;
uniform float chroma_key_smoothness = 0.1;

vec4 apply_chroma_key(vec4 color) {
    float dist = distance(color.rgb, chroma_key_color);
    float edge = chroma_key_similarity;
    float alpha = smoothstep(edge - chroma_key_smoothness, edge + chroma_key_smoothness, dist);
    return vec4(color.rgb, color.a * alpha);
}

void fragment() {
    vec4 result;
    vec2 pixel_size;
    vec4 center, up, down, left, right;

    if (display_tiled_render) {
        pixel_size = 1.0 / vec2(textureSize(tiled_render, 0));
        center = texture(tiled_render, UV);
        up = texture(tiled_render, UV + vec2(0.0, -pixel_size.y));
        down = texture(tiled_render, UV + vec2(0.0, pixel_size.y));
        left = texture(tiled_render, UV + vec2(-pixel_size.x, 0.0));
        right = texture(tiled_render, UV + vec2(pixel_size.x, 0.0));
    } else {
        pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
        center = texture(TEXTURE, UV);
        up = texture(TEXTURE, UV + vec2(0.0, -pixel_size.y));
        down = texture(TEXTURE, UV + vec2(0.0, pixel_size.y));
        left = texture(TEXTURE, UV + vec2(-pixel_size.x, 0.0));
        right = texture(TEXTURE, UV + vec2(pixel_size.x, 0.0));
    }

    if (sharpness >= 0.0001) {
        result = center * (1.0 + 4.0 * sharpness) - (up + down + left + right) * sharpness;
    } else {
        result = center;
    }

    //result = apply_chroma_key(result);
    COLOR = result;
}