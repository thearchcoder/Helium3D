shader_type canvas_item;

uniform float base_selection_ratio = 0.1;
uniform sampler2D previous_pixels : filter_nearest, hint_default_black;
uniform float time;

uint murmurHash11(uint src) {
	const uint M = 0x5bd1e995u;
	uint h = 1190494759u;
	src *= M; src ^= src>>24u; src *= M;
	h *= M; h ^= src;
	h ^= h>>13u; h *= M; h ^= h>>15u;
	return h;
}

float hash11(float src) {
	uint h = murmurHash11(floatBitsToUint(src));
	return uintBitsToFloat(h & 0x007fffffu | 0x3f800000u) - 1.0;
}

void fragment() {
	vec2 pixel_coord = UV * TEXTURE_PIXEL_SIZE;
	float rand_val = hash11((pixel_coord.x * tanh(pixel_coord.y + pixel_coord.x) * pixel_coord.y + atan(pixel_coord.x) + TIME) * 100.0);
	
	vec3 prev_pixel_color = texture(previous_pixels, UV).rgb;
	float prev_pixel = prev_pixel_color.r + prev_pixel_color.g;
	bool is_available = prev_pixel < 0.5;
	
	float adjusted_ratio = base_selection_ratio * exp(time * 2.0);
	adjusted_ratio = min(adjusted_ratio, 1.0);
	
	bool should_select = is_available && (rand_val < adjusted_ratio);
	
	if (!is_available) COLOR = vec4(0.0, 1.0, 0.0, 1.0);
	else COLOR = vec4(should_select ? 1.0 : 0.0, 0.0, 0.0, 1.0);
}