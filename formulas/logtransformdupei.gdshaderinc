// [ID]
// Log transform Dupe I
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-5, 5] = 1
// float scale[1, 10] = 1
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void logtransformdupei_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, flogtransformdupei_range)) {
		if (flogtransformdupei_axis == 0) z.x = flogtransformdupei_scale * log(z.x + sqrt(z.x * z.x + flogtransformdupei_offset));
		if (flogtransformdupei_axis == 1) z.y = flogtransformdupei_scale * log(z.y + sqrt(z.y * z.y + flogtransformdupei_offset));
		if (flogtransformdupei_axis == 2) z.z = flogtransformdupei_scale * log(z.z + sqrt(z.z * z.z + flogtransformdupei_offset));
		if (flogtransformdupei_axis == 3) z.w = flogtransformdupei_scale * log(z.w + sqrt(z.w * z.w + flogtransformdupei_offset));
	}
}