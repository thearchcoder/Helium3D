// [ID]
// Inversion transform
// [INDEX]
// 29
// [VARS]
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// vec4 sphere[(-4, -4, -4, -4), (4, 4, 4, 4)] = (1, 1, 0, 1)
// [CODE]
uniform vec4 finversiontransform_sphere;
uniform vec2 finversiontransform_range;

void inversiontransform_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	// func from sphairahedron formula
	if (check_range(i, finversiontransform_range))
		SphereInvert(z.xyz, dz, finversiontransform_sphere);
}