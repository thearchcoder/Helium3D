// [ID]
// Log transform Dupe F
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-5, 5] = 1
// float scale[1, 10] = 1
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void logtransformdupef_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, flogtransformdupef_range)) {
		if (flogtransformdupef_axis == 0) z.x = flogtransformdupef_scale * log(z.x + sqrt(z.x * z.x + flogtransformdupef_offset));
		if (flogtransformdupef_axis == 1) z.y = flogtransformdupef_scale * log(z.y + sqrt(z.y * z.y + flogtransformdupef_offset));
		if (flogtransformdupef_axis == 2) z.z = flogtransformdupef_scale * log(z.z + sqrt(z.z * z.z + flogtransformdupef_offset));
		if (flogtransformdupef_axis == 3) z.w = flogtransformdupef_scale * log(z.w + sqrt(z.w * z.w + flogtransformdupef_offset));
	}
}