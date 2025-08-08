// [ID]
// Basic transform
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec4 offset[(-4, -4, -4, -4), (4, 4, 4, 4)] = (0.3, 0, 0, 0)
// vec4 scale[(-4, -4, -4, -4), (4, 4, 4, 4)] = (1, 1, 1, 1)
// template transform_range
// [CODE]

void basictransform_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fbasictransform_range)) {
		dz *= length(fbasictransform_scale) / 2.0;
		z *= fbasictransform_scale;
		z += fbasictransform_offset;
	}
}