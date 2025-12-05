// [ID]
// Log transform
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-5, 5] = 1
// float scale[1, 10] = 1
// template transform_range
// [CODE]

void logtransform_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, flogtransform_range)) {
		if (flogtransform_axis == 0) z.x = flogtransform_scale * log(z.x + sqrt(z.x * z.x + flogtransform_offset));
		if (flogtransform_axis == 1) z.y = flogtransform_scale * log(z.y + sqrt(z.y * z.y + flogtransform_offset));
		if (flogtransform_axis == 2) z.z = flogtransform_scale * log(z.z + sqrt(z.z * z.z + flogtransform_offset));
		if (flogtransform_axis == 3) z.w = flogtransform_scale * log(z.w + sqrt(z.w * z.w + flogtransform_offset));
	}
}