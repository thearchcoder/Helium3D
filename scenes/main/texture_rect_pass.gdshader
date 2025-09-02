shader_type canvas_item;

uniform float sharpness = 1.0;
uniform float camera_kalaidoscope = 1.0;
uniform bool display_tiled_render = false;
uniform sampler2D tiled_render;
uniform sampler2D previous_frame: hint_default_black, filter_nearest;
uniform sampler2D pixels_to_render: hint_default_black, filter_nearest;

#include "res://renderer/utility.gdshaderinc"
#include "res://renderer/kalaidoscope.gdshaderinc"

void fragment() {
	vec2 uv = UV;
	if (uv.x < 0.0) discard;

	vec4 result;
	vec2 pixel_size = SCREEN_PIXEL_SIZE;
	vec2 viewport_size = 1.0 / pixel_size;
	float aspect_ratio = viewport_size.x / viewport_size.y;

	vec2 centered_uv = uv - 0.5;

	centered_uv.x *= aspect_ratio;
	centered_uv = kalaido(centered_uv, camera_kalaidoscope, 0);
	centered_uv.x /= aspect_ratio;
	uv = centered_uv + 0.5;

	vec4 center, up, down, left, right;

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

	vec4 prev = texture(previous_frame, uv);
	vec4 pxinfo = texture(pixels_to_render, UV);

	if (length(result.rgb) <= 0.0001 && length(prev.rgb) >= 0.0001) {
		COLOR = prev;
	} else {
		COLOR = result;
	}
}