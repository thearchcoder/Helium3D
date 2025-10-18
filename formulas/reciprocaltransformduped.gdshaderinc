// [ID]
// Reciprocal Transform Dupe D
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-4, 4] = 0
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void reciprocaltransformduped_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, freciprocaltransformduped_range)) {
		if (freciprocaltransformduped_axis == 0) z4.x = sign(z4.x) / (abs(z4.x) + freciprocaltransformduped_offset);
		if (freciprocaltransformduped_axis == 1) z4.y = sign(z4.y) / (abs(z4.y) + freciprocaltransformduped_offset);
		if (freciprocaltransformduped_axis == 2) z4.z = sign(z4.z) / (abs(z4.z) + freciprocaltransformduped_offset);
		if (freciprocaltransformduped_axis == 3) z4.w = sign(z4.w) / (abs(z4.w) + freciprocaltransformduped_offset);
	}
}
