shader_type canvas_item;

uniform float camera_kalaidoscope = 1.0;
uniform bool display_tiled_render = false;
uniform sampler2D tiled_render;
uniform sampler2D previous_frame: hint_default_transparent, filter_nearest;
uniform sampler2D pixels_to_render: hint_default_transparent, filter_nearest;
uniform bool mix_with_previous = false;

#include "res://renderer/utility.gdshaderinc"
#include "res://renderer/kalaidoscope.gdshaderinc"

void fragment() {
	vec2 uv = UV;
	if (uv.x < 0.0) discard;

	vec2 pixel_size = SCREEN_PIXEL_SIZE;
	vec2 viewport_size = 1.0 / pixel_size;
	float aspect_ratio = viewport_size.x / viewport_size.y;

	vec2 centered_uv = uv - 0.5;

	centered_uv.x *= aspect_ratio;
	centered_uv = kalaido(centered_uv, camera_kalaidoscope, 0);
	centered_uv.x /= aspect_ratio;
	uv = centered_uv + 0.5;

	COLOR = texture(TEXTURE, uv);

	if (display_tiled_render) {
		COLOR = texture(tiled_render, uv);
	}
}