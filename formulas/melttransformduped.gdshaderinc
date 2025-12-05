// [ID]
// Melt transform Dupe D
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec4 a[(0, 0, 0, 0), (2, 2, 2, 2)] = (1, 0.3, 0, 0)
// vec4 b[(0, 0, 0, 0), (2, 2, 2, 2)] = (0, 1, 0, 0)
// vec4 c[(0, 0, 0, 0), (2, 2, 2, 2)] = (0, 0, 1, 0)
// vec4 d[(0, 0, 0, 0), (2, 2, 2, 2)] = (0, 0, 0, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void melttransformduped_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fmelttransformduped_range)) {
		z *= mat4(fmelttransformduped_a, fmelttransformduped_b, fmelttransformduped_c, fmelttransformduped_d);
	}
}
