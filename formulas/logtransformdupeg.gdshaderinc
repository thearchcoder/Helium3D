// [ID]
// Log transform Dupe G
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-5, 5] = 1
// float scale[1, 10] = 1
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void logtransformdupeg_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, flogtransformdupeg_range)) {
		if (flogtransformdupeg_axis == 0) z.x = flogtransformdupeg_scale * log(z.x + sqrt(z.x * z.x + flogtransformdupeg_offset));
		if (flogtransformdupeg_axis == 1) z.y = flogtransformdupeg_scale * log(z.y + sqrt(z.y * z.y + flogtransformdupeg_offset));
		if (flogtransformdupeg_axis == 2) z.z = flogtransformdupeg_scale * log(z.z + sqrt(z.z * z.z + flogtransformdupeg_offset));
		if (flogtransformdupeg_axis == 3) z.w = flogtransformdupeg_scale * log(z.w + sqrt(z.w * z.w + flogtransformdupeg_offset));
	}
}