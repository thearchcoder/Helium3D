// [ID]
// Sierpinski icosahedron
// [OFFICIAL]
// [KIFS]
// [VARS]
// vec3 offset[(-1, -1, -1), (1, 1, 1)] = (0.85065, 0.52573, 0.0)
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// float scale[1.0, 3.0] = 2.0
// [CODE]
const vec3 fsierpinskiicosahedron_n1 = vec3(-0.809, 0.309, 0.5);
const vec3 fsierpinskiicosahedron_n2 = vec3(0.305, -0.494, 0.799);
const vec3 fsierpinskiicosahedron_n3 = vec3(0.0, 0.0, -1.0);

void sierpinskiicosahedron_iter(inout vec4 p4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = p4.xyz;
	float scale = fsierpinskiicosahedron_scale;
	vec3 offset = fsierpinskiicosahedron_offset;
	float t = 0.0;

	if (i == 0) {
		p = abs(p);
		t = dot(p, fsierpinskiicosahedron_n1); if (t > 0.0) p -= 2.0 * t * fsierpinskiicosahedron_n1;
		t = dot(p, fsierpinskiicosahedron_n2); if (t > 0.0) p -= 2.0 * t * fsierpinskiicosahedron_n2;
		t = dot(p, fsierpinskiicosahedron_n3); if (t > 0.0) p -= 2.0 * t * fsierpinskiicosahedron_n3;
		t = dot(p, fsierpinskiicosahedron_n2); if (t > 0.0) p -= 2.0 * t * fsierpinskiicosahedron_n2;
	}

	p = rotate3d_point(p, fsierpinskiicosahedron_rotation1);

	p = abs(p);
	t = dot(p, fsierpinskiicosahedron_n1);
	if (t > 0.0) p -= 2.0 * t * fsierpinskiicosahedron_n1;

	p = scale * p - offset * (scale - 1.0);
	dz = dz * abs(scale) + 1.0;

	p = rotate3d_point(p, fsierpinskiicosahedron_rotation2);

	p4.xyz = p;
}

//vec2 sierpinskiicosahedron_sdf(vec3 z) {
	//float scale = fsierpinskiicosahedron_scale;
	//vec3 offset = fsierpinskiicosahedron_offset;
	//float orbit_trap = 100000.0;
	//float s = 1.0;
	//float r = 0.0;
	//float t = 0.0;
	//int n = 0;
//
	//z = abs(z);
	//t = dot(z, fsierpinskiicosahedron_n1); if (t > 0.0) z -= 2.0 * t * fsierpinskiicosahedron_n1;
	//t = dot(z, fsierpinskiicosahedron_n2); if (t > 0.0) z -= 2.0 * t * fsierpinskiicosahedron_n2;
	//t = dot(z, fsierpinskiicosahedron_n3); if (t > 0.0) z -= 2.0 * t * fsierpinskiicosahedron_n3;
	//t = dot(z, fsierpinskiicosahedron_n2); if (t > 0.0) z -= 2.0 * t * fsierpinskiicosahedron_n2;
//
	//for (; n < iterations; n++) {
		//z = rotate3d_point(z, fsierpinskiicosahedron_rotation1);
//
		//z = abs(z);
		//t = dot(z, fsierpinskiicosahedron_n1);
		//if (t > 0.0) z -= 2.0 * t * fsierpinskiicosahedron_n1;
//
		//z = scale * z - offset * (scale - 1.0);
		//s /= scale;
//
		//r = dot(z, z);
		//if (coloring_mode == 0 && n > color_min_iterations && n < color_max_iterations) orbit_trap = min(orbit_trap, abs(r));
		//else orbit_trap = min(orbit_trap, process_orbit_trap(z, n));
//
		//z = rotate3d_point(z, fsierpinskiicosahedron_rotation2);
	//}
//
	//return vec2(sphere_sdf3d(z, vec3(0.0), 1.0) * s, orbit_trap);
//}