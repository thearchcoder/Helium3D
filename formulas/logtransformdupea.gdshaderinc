// [ID]
// Log transform Dupe A
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-5, 5] = 1
// float scale[1, 10] = 1
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void logtransformdupea_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, flogtransformdupea_range)) {
		if (flogtransformdupea_axis == 0) z.x = flogtransformdupea_scale * log(z.x + sqrt(z.x * z.x + flogtransformdupea_offset));
		if (flogtransformdupea_axis == 1) z.y = flogtransformdupea_scale * log(z.y + sqrt(z.y * z.y + flogtransformdupea_offset));
		if (flogtransformdupea_axis == 2) z.z = flogtransformdupea_scale * log(z.z + sqrt(z.z * z.z + flogtransformdupea_offset));
		if (flogtransformdupea_axis == 3) z.w = flogtransformdupea_scale * log(z.w + sqrt(z.w * z.w + flogtransformdupea_offset));
	}
}