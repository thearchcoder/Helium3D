// [ID]
// Sierpinski octahedron
// [INDEX]
// 8
// [VARS]
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 offset[(-2, -2, -2), (2, 2, 2)] = (1, 0, 0)
// float scale[1.0, 3.0] = 2.0
// [CODE]
uniform float fsierpinskioctahedron_scale;
uniform vec3 fsierpinskioctahedron_rotation1;
uniform vec3 fsierpinskioctahedron_rotation2;
uniform vec3 fsierpinskioctahedron_offset;

vec2 sierpinskioctahedron_sdf(vec3 z) {
	float scale = fsierpinskioctahedron_scale;
	vec3 offset = fsierpinskioctahedron_offset;
	float orbit_trap = 100000.0;
	float r;
	float s = 1.0;
	int n = 0;

	while (n < iterations) {
		z = rotate3d_point(z, fsierpinskioctahedron_rotation1);

		z = abs(z);
		if (z.x - z.y < 0.0) z.xy = z.yx;
		if (z.x - z.z < 0.0) z.xz = z.zx;

		z = z * scale - offset * (scale - 1.0);
		s /= scale;

		z = rotate3d_point(z, fsierpinskioctahedron_rotation2);

		r = dot(z, z);
		if (coloring_mode == 0) orbit_trap = min(orbit_trap, abs(r));
		else orbit_trap = min(orbit_trap, process_orbit_trap(z));
		n++;
	}

	//float d = length(z) * pow(scale, float(-n));
	float d = octahedron_sdf3d(z, 1.0) * s;
	return vec2(d, orbit_trap);
}
