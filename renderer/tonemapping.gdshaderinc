vec3 linear_tone_mapping(vec3 color) {
	return clamp(exposure * color, 0.0, 1.0);
}

vec3 simple_reinhard_tone_mapping(vec3 color) {
	color *= (exposure + 0.5) / (1.0 + color / exposure);
	return color;
}

vec3 luma_based_reinhard_tone_mapping(vec3 color)
{
	float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
	float tone_mapped_luma = luma / (1. + luma);
	color *= tone_mapped_luma / luma;

	return color * exposure;
}

vec3 white_preserving_luma_based_reinhard_tone_mapping(vec3 color)
{
	float white = 2.0;
	float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
	float tone_mapped_luma = luma * (1.0 + luma / (white * white)) / (1.0 + luma);
	color *= tone_mapped_luma / luma;

	return color * exposure;
}

vec3 rom_bin_da_house_tone_mapping(vec3 color) {
	color = exp(-1.0 / (2.72 * color + 0.15));
	return color * exposure;
}

vec3 filmic_tone_mapping(vec3 color) {
	color = max(vec3(0.), color - vec3(0.004));
	color = (color * (6.2 * color + .5)) / (color * (6.2 * color + 1.7) + 0.06);
	return color * exposure;
}

vec3 uncharted2_tone_mapping(vec3 color) {
	float a = 0.15;
	float b = 0.50;
	float c = 0.10;
	float d = 0.20;
	float e = 0.02;
	float f = 0.30;
	float w = 11.2;
	color *= exposure + 1.0;
	color = ((color * (a * color + c * b) + d * e) / (color * (a * color + b) + d * f)) - e / f;
	float white = ((w * (a * w + c * b) + d * e) / (w * (a * w + b) + d * f)) - e / f;
	color /= white;

	return color;
}

vec3 aces_tonemapping(vec3 color){
	mat3 m1 = mat3(
		vec3(0.59719, 0.07600, 0.02840),
		vec3(0.35458, 0.90834, 0.13383),
		vec3(0.04823, 0.01566, 0.83777)
	);
	mat3 m2 = mat3(
		vec3(1.60475, -0.10208, -0.00327),
		vec3(-0.53108,  1.10813, -0.07276),
		vec3(-0.07367, -0.00605,  1.07602)
	);
	vec3 v = m1 * color;
	vec3 a = v * (v + 0.0245786) - 0.000090537;
	vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;

	color = pow(clamp(m2 * (a / b), 0.0, 1.0), vec3(1.0 / 2.2));

	return color * exposure;
}

vec3 gamma_correct(vec3 color) {
	return pow(color, vec3(1.0 / gamma));
}

vec3 tonemap_color(vec3 color) {
	switch (tone_mapping) {
		case 0:
			return linear_tone_mapping(color);
		case 1:
			return simple_reinhard_tone_mapping(color);
		case 2:
			return luma_based_reinhard_tone_mapping(color);
		case 3:
			return white_preserving_luma_based_reinhard_tone_mapping(color);
		case 4:
			return rom_bin_da_house_tone_mapping(color);
		case 5:
			return filmic_tone_mapping(color);
		case 6:
			return uncharted2_tone_mapping(color);
		case 7:
			return aces_tonemapping(color);
	}

	return linear_tone_mapping(color);
}
