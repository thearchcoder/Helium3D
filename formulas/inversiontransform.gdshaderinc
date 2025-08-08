// [ID]
// Inversion transform
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec4 sphere[(-4, -4, -4, -4), (4, 4, 4, 4)] = (1, 1, 0, 1)
// template transform_range
// [CODE]

void inversiontransform_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	// func from sphairahedron formula
	if (check_range(i, finversiontransform_range))
		SphereInvert(z.xyz, dz, finversiontransform_sphere);
}