// [ID]
// Inversion transform Dupe B
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec4 sphere[(-4, -4, -4, -4), (4, 4, 4, 4)] = (1, 1, 0, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void inversiontransformdupeb_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	// func from sphairahedron formula
	if (check_range(i, finversiontransformdupeb_range))
		SphereInvert(z.xyz, dz, finversiontransformdupeb_sphere);
}