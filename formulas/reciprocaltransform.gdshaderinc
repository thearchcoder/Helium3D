// [ID]
// Reciprocal Transform
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-4, 4] = 0
// template transform_range
// [CODE]

void reciprocaltransform_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, freciprocaltransform_range)) {
		if (freciprocaltransform_axis == 0) z4.x = sign(z4.x) / (abs(z4.x) + freciprocaltransform_offset);
		if (freciprocaltransform_axis == 1) z4.y = sign(z4.y) / (abs(z4.y) + freciprocaltransform_offset);
		if (freciprocaltransform_axis == 2) z4.z = sign(z4.z) / (abs(z4.z) + freciprocaltransform_offset);
		if (freciprocaltransform_axis == 3) z4.w = sign(z4.w) / (abs(z4.w) + freciprocaltransform_offset);
	}
}
