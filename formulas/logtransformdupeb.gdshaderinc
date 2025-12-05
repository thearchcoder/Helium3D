// [ID]
// Log transform Dupe B
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-5, 5] = 1
// float scale[1, 10] = 1
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void logtransformdupeb_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, flogtransformdupeb_range)) {
		if (flogtransformdupeb_axis == 0) z.x = flogtransformdupeb_scale * log(z.x + sqrt(z.x * z.x + flogtransformdupeb_offset));
		if (flogtransformdupeb_axis == 1) z.y = flogtransformdupeb_scale * log(z.y + sqrt(z.y * z.y + flogtransformdupeb_offset));
		if (flogtransformdupeb_axis == 2) z.z = flogtransformdupeb_scale * log(z.z + sqrt(z.z * z.z + flogtransformdupeb_offset));
		if (flogtransformdupeb_axis == 3) z.w = flogtransformdupeb_scale * log(z.w + sqrt(z.w * z.w + flogtransformdupeb_offset));
	}
}