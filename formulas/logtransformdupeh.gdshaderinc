// [ID]
// Log transform Dupe H
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-5, 5] = 1
// float scale[1, 10] = 1
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void logtransformdupeh_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, flogtransformdupeh_range)) {
		if (flogtransformdupeh_axis == 0) z.x = flogtransformdupeh_scale * log(z.x + sqrt(z.x * z.x + flogtransformdupeh_offset));
		if (flogtransformdupeh_axis == 1) z.y = flogtransformdupeh_scale * log(z.y + sqrt(z.y * z.y + flogtransformdupeh_offset));
		if (flogtransformdupeh_axis == 2) z.z = flogtransformdupeh_scale * log(z.z + sqrt(z.z * z.z + flogtransformdupeh_offset));
		if (flogtransformdupeh_axis == 3) z.w = flogtransformdupeh_scale * log(z.w + sqrt(z.w * z.w + flogtransformdupeh_offset));
	}
}