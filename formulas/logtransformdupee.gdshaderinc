// [ID]
// Log transform Dupe E
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-5, 5] = 1
// float scale[1, 10] = 1
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void logtransformdupee_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, flogtransformdupee_range)) {
		if (flogtransformdupee_axis == 0) z.x = flogtransformdupee_scale * log(z.x + sqrt(z.x * z.x + flogtransformdupee_offset));
		if (flogtransformdupee_axis == 1) z.y = flogtransformdupee_scale * log(z.y + sqrt(z.y * z.y + flogtransformdupee_offset));
		if (flogtransformdupee_axis == 2) z.z = flogtransformdupee_scale * log(z.z + sqrt(z.z * z.z + flogtransformdupee_offset));
		if (flogtransformdupee_axis == 3) z.w = flogtransformdupee_scale * log(z.w + sqrt(z.w * z.w + flogtransformdupee_offset));
	}
}