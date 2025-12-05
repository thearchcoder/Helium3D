// [ID]
// Bristorbrot Dupe C
// [OFFICIAL]
// [ESCAPE]
// [VARS]
// bool is_julia[false, true] = false
// vec3 julia_c[(-2, -2, -2), (2, 2, 2)] = (-0.844, -0.031, -0.302)
// vec3 multiply[(-2, -2, -2), (2, 2, 2)] = (2, 1, -1)
// [CODE]

void bristorbrotdupec_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 c = fbristorbrotdupec_is_julia ? fbristorbrotdupec_julia_c : original_z.xyz;
	dz = length(z) * dz * 2.0 + 1.0;

	z.xyz = bristor_square(z.xyz, fbristorbrotdupec_multiply) + c;
}
