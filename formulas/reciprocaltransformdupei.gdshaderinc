// [ID]
// Reciprocal Transform Dupe I
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-4, 4] = 0
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void reciprocaltransformdupei_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, freciprocaltransformdupei_range)) {
		if (freciprocaltransformdupei_axis == 0) z4.x = sign(z4.x) / (abs(z4.x) + freciprocaltransformdupei_offset);
		if (freciprocaltransformdupei_axis == 1) z4.y = sign(z4.y) / (abs(z4.y) + freciprocaltransformdupei_offset);
		if (freciprocaltransformdupei_axis == 2) z4.z = sign(z4.z) / (abs(z4.z) + freciprocaltransformdupei_offset);
		if (freciprocaltransformdupei_axis == 3) z4.w = sign(z4.w) / (abs(z4.w) + freciprocaltransformdupei_offset);
	}
}
