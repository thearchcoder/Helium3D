// [ID]
// Sierpinski icosahedron
// [INDEX]
// 5
// [VARS]
// vec3 offset[(-1, -1, -1), (1, 1, 1)] = (0.85065, 0.52573, 0.0)
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 n1[(-2, -2, -2), (2, 2, 2)] = (-0.809, 0.309, 0.5)
// vec3 n2[(-2, -2, -2), (2, 2, 2)] = (0.305, -0.494, 0.799)
// vec3 n3[(-2, -2, -2), (2, 2, 2)] = (0.0, 0.0, -1.0)
// float scale[1.0, 3.0] = 2.0
// [CODE]
uniform float fsierpinskiicosahedron_scale;
uniform vec3 fsierpinskiicosahedron_rotation1;
uniform vec3 fsierpinskiicosahedron_rotation2;
uniform vec3 fsierpinskiicosahedron_offset;
uniform vec3 fsierpinskiicosahedron_n1;
uniform vec3 fsierpinskiicosahedron_n2;
uniform vec3 fsierpinskiicosahedron_n3;

vec2 sierpinskiicosahedron_sdf(vec3 z) {
	float scale = fsierpinskiicosahedron_scale;
	vec3 offset = fsierpinskiicosahedron_offset;
	float orbit_trap = 100000.0;
	float s = 1.0;
	float r = 0.0;
	float t = 0.0;
	int n = 0;

	z = abs(z);
	t = dot(z, fsierpinskiicosahedron_n1); if (t > 0.0) z -= 2.0 * t * fsierpinskiicosahedron_n1;
	t = dot(z, fsierpinskiicosahedron_n2); if (t > 0.0) z -= 2.0 * t * fsierpinskiicosahedron_n2;
	t = dot(z, fsierpinskiicosahedron_n3); if (t > 0.0) z -= 2.0 * t * fsierpinskiicosahedron_n3;
	t = dot(z, fsierpinskiicosahedron_n2); if (t > 0.0) z -= 2.0 * t * fsierpinskiicosahedron_n2;

	for (; n < iterations; n++) {
		z = rotate3d_point(z, fsierpinskiicosahedron_rotation1);

		z = abs(z);
		t = dot(z, fsierpinskiicosahedron_n1);
		if (t > 0.0) z -= 2.0 * t * fsierpinskiicosahedron_n1;
		
		z = scale * z - offset * (scale - 1.0);
		s /= scale;

		r = dot(z, z);
		if (coloring_mode == 0) orbit_trap = min(orbit_trap, abs(r));
		else orbit_trap = min(orbit_trap, process_orbit_trap(z));

		z = rotate3d_point(z, fsierpinskiicosahedron_rotation2);
	}

	return vec2(sphere_sdf3d(z, vec3(0.0), 1.0) * s, orbit_trap);
}