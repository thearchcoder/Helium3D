// [ID]
// Basic transform Dupe I
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec4 offset[(-4, -4, -4, -4), (4, 4, 4, 4)] = (0.3, 0, 0, 0)
// vec4 scale[(-4, -4, -4, -4), (4, 4, 4, 4)] = (1, 1, 1, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void basictransformdupei_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fbasictransformdupei_range)) {
		dz *= length(fbasictransformdupei_scale) / 2.0;
		z *= fbasictransformdupei_scale;
		z += fbasictransformdupei_offset;
	}
}