// [ID]
// Log transform Dupe C
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-5, 5] = 1
// float scale[1, 10] = 1
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void logtransformdupec_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, flogtransformdupec_range)) {
		if (flogtransformdupec_axis == 0) z.x = flogtransformdupec_scale * log(z.x + sqrt(z.x * z.x + flogtransformdupec_offset));
		if (flogtransformdupec_axis == 1) z.y = flogtransformdupec_scale * log(z.y + sqrt(z.y * z.y + flogtransformdupec_offset));
		if (flogtransformdupec_axis == 2) z.z = flogtransformdupec_scale * log(z.z + sqrt(z.z * z.z + flogtransformdupec_offset));
		if (flogtransformdupec_axis == 3) z.w = flogtransformdupec_scale * log(z.w + sqrt(z.w * z.w + flogtransformdupec_offset));
	}
}