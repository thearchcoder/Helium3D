shader_type canvas_item;

uniform int color_min_iterations = 0;
uniform int color_max_iterations = 0;
uniform int coloring_mode = 0;
uniform float coloring_offset = 0.0;
uniform bool exponential_smoothing = false;
uniform sampler2D normal_map;
uniform bool normal_map_enabled;
uniform int normal_map_projection;
uniform float normal_map_triplanar_sharpness;
uniform float normal_map_scale;
uniform float normal_map_height;

uniform vec3 fgyroid_position = vec3(0.0, 0.0, 0.0);
uniform float fgyroid_scale = 6.0;
uniform float fgyroid_sphere_radius = 1.0;
#define fgyroid_time TIME
uniform float fgyroid_thickness = 0.025;
uniform float fgyroid_bias = 0.015;
uniform vec4 fgyroid_control = vec4(0.5, 0.7, 2.0, 2.0);
uniform vec2 fgyroid_offset = vec2(0.0, 0.0);
uniform bool fgyroid_oriented = true;
uniform bool fgyroid_abs = false;
#include "res://renderer/math.gdshaderinc"
#include "res://formulas/gyroid.gdshaderinc"

void fragment() {
	vec3 p = vec3(UV * 2.0 - 1.0, 0.0);
	float brightness = gyroid_sdf(vec4(p, 0.0)).x;

	brightness = 1.0 - brightness;
	brightness = pow(brightness, 16./TEXTURE_PIXEL_SIZE.y);
	COLOR = vec4(vec3(brightness), brightness);
}
