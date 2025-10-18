// [ID]
// Log transform Dupe J
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-5, 5] = 1
// float scale[1, 10] = 1
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void logtransformdupej_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, flogtransformdupej_range)) {
		if (flogtransformdupej_axis == 0) z.x = flogtransformdupej_scale * log(z.x + sqrt(z.x * z.x + flogtransformdupej_offset));
		if (flogtransformdupej_axis == 1) z.y = flogtransformdupej_scale * log(z.y + sqrt(z.y * z.y + flogtransformdupej_offset));
		if (flogtransformdupej_axis == 2) z.z = flogtransformdupej_scale * log(z.z + sqrt(z.z * z.z + flogtransformdupej_offset));
		if (flogtransformdupej_axis == 3) z.w = flogtransformdupej_scale * log(z.w + sqrt(z.w * z.w + flogtransformdupej_offset));
	}
}