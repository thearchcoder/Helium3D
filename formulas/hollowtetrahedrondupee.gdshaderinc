// [ID]
// Hollow Tetrahedron Dupe E
// [OFFICIAL]
// [DIFS]
// [VARS]
// float scale[1.0, 3.0] = 2.0
// float thickness[0.0, 0.1] = 0.02
// vec3 offset[(0.25, 0.25, 0.25), (1, 1, 1)] = (0.5, 0.5, 0.5)
// [CODE]

vec2 hollowtetrahedrondupee_sdf(vec4 z4d) {
	vec3 z = z4d.xyz;
	float de = 10000.0;
	float orbit_trap = 100000.0;
	float scale = fhollowtetrahedrondupee_scale;
	float s = 1.0;
	int i = 0;

	for (; i < iterations; i++) {
		de = min(de, hollow_cube_sdf3d(z, vec3(1.0), fhollowtetrahedrondupee_thickness) * s);
		
		if (z.z - z.x < 0.0) z.zx = z.xz;
		if (z.z - z.y < 0.0) z.zy = z.yz;
		
		vec3 n3 = normalize(vec3(1.0, 1.0, 0.0));
		z -= 2.0 * min(0.0, dot(z, n3)) * n3;

		z = z * scale - fhollowtetrahedrondupee_offset * scale;
		s /= scale;
		orbit_trap = min(orbit_trap, dot(z, z));
	}
	return vec2(de, orbit_trap);
}