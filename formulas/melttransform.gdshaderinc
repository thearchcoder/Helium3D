// [ID]
// Melt transform
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec4 a[(0, 0, 0, 0), (2, 2, 2, 2)] = (1, 0.3, 0, 0)
// vec4 b[(0, 0, 0, 0), (2, 2, 2, 2)] = (0, 1, 0, 0)
// vec4 c[(0, 0, 0, 0), (2, 2, 2, 2)] = (0, 0, 1, 0)
// vec4 d[(0, 0, 0, 0), (2, 2, 2, 2)] = (0, 0, 0, 1)
// template transform_range
// [CODE]

void melttransform_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fmelttransform_range)) {
		z *= mat4(fmelttransform_a, fmelttransform_b, fmelttransform_c, fmelttransform_d);
	}
}
