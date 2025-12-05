// [ID]
// Melt transform Dupe I
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec4 a[(0, 0, 0, 0), (2, 2, 2, 2)] = (1, 0.3, 0, 0)
// vec4 b[(0, 0, 0, 0), (2, 2, 2, 2)] = (0, 1, 0, 0)
// vec4 c[(0, 0, 0, 0), (2, 2, 2, 2)] = (0, 0, 1, 0)
// vec4 d[(0, 0, 0, 0), (2, 2, 2, 2)] = (0, 0, 0, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void melttransformdupei_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fmelttransformdupei_range)) {
		z *= mat4(fmelttransformdupei_a, fmelttransformdupei_b, fmelttransformdupei_c, fmelttransformdupei_d);
	}
}
