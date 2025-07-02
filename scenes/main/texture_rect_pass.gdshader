shader_type canvas_item;

uniform float sharpness = 1.0;
uniform float camera_kalaidoscope = 1.0;
uniform bool display_tiled_render = false;
uniform sampler2D tiled_render;

#include "res://renderer/utility.gdshaderinc"
#include "res://renderer/kalaidoscope.gdshaderinc"

void fragment() {
	vec2 uv = UV;
	vec4 result;
	vec2 pixel_size = SCREEN_PIXEL_SIZE;
	vec4 center, up, down, left, right;
	uv = kalaido(uv - 0.5, camera_kalaidoscope, 0) + 0.5;

	if (display_tiled_render) {
		center = texture(tiled_render, uv);
		up = texture(tiled_render, uv + vec2(0.0, -pixel_size.y));
		down = texture(tiled_render, uv + vec2(0.0, pixel_size.y));
		left = texture(tiled_render, uv + vec2(-pixel_size.x, 0.0));
		right = texture(tiled_render, uv + vec2(pixel_size.x, 0.0));
	} else {
		center = texture(TEXTURE, uv);
		up = texture(TEXTURE, uv + vec2(0.0, -pixel_size.y));
		down = texture(TEXTURE, uv + vec2(0.0, pixel_size.y));
		left = texture(TEXTURE, uv + vec2(-pixel_size.x, 0.0));
		right = texture(TEXTURE, uv + vec2(pixel_size.x, 0.0));
	}

	if (sharpness >= 0.0001) result = center * (1.0 + 4.0 * sharpness) - (up + down + left + right) * sharpness;
	else result = center;
	COLOR = result;
}