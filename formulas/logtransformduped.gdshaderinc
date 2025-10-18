// [ID]
// Log transform Dupe D
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-5, 5] = 1
// float scale[1, 10] = 1
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void logtransformduped_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, flogtransformduped_range)) {
		if (flogtransformduped_axis == 0) z.x = flogtransformduped_scale * log(z.x + sqrt(z.x * z.x + flogtransformduped_offset));
		if (flogtransformduped_axis == 1) z.y = flogtransformduped_scale * log(z.y + sqrt(z.y * z.y + flogtransformduped_offset));
		if (flogtransformduped_axis == 2) z.z = flogtransformduped_scale * log(z.z + sqrt(z.z * z.z + flogtransformduped_offset));
		if (flogtransformduped_axis == 3) z.w = flogtransformduped_scale * log(z.w + sqrt(z.w * z.w + flogtransformduped_offset));
	}
}