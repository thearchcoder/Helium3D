shader_type canvas_item;
uniform float sharpness : hint_range(0.0, 10.0) = 1.0;
uniform float camera_kalaidoscope = 1.0;
uniform bool display_tiled_render = false;
uniform sampler2D tiled_render;
#include "res://renderer/utility.gdshaderinc"
#include "res://renderer/kalaidoscope.gdshaderinc"

void fragment() {
	vec2 uv = UV;
	vec4 result;
	vec2 pixel_size;
	vec4 center, up, down, left, right;

	// Get aspect ratio
	vec2 tex_size = vec2(textureSize(display_tiled_render ? tiled_render : TEXTURE, 0));
	float aspect = tex_size.x / tex_size.y;

	// Center, apply aspect correction, kaleidoscope, restore aspect
	vec2 centered_uv = uv - 0.5;
	centered_uv.x *= aspect;
	centered_uv = kalaido(centered_uv, camera_kalaidoscope, 0);
	centered_uv.x /= aspect;
	uv = centered_uv + 0.5;

	if (display_tiled_render) {
		pixel_size = 1.0 / vec2(textureSize(tiled_render, 0));
		center = texture(tiled_render, uv);
		up = texture(tiled_render, uv + vec2(0.0, -pixel_size.y));
		down = texture(tiled_render, uv + vec2(0.0, pixel_size.y));
		left = texture(tiled_render, uv + vec2(-pixel_size.x, 0.0));
		right = texture(tiled_render, uv + vec2(pixel_size.x, 0.0));
	} else {
		pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
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