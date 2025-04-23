// [ID]
// Mengersponge
// [INDEX]
// 7
// [VARS]
// vec3 offset[(0, 0, 0), (2.5, 2.5, 2.5)] = (1, 1, 1)
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// float scale[2.0, 4.0] = 3.0
// [CODE]
uniform vec3 fmengersponge_rotation1;
uniform vec3 fmengersponge_rotation2;
uniform vec3 fmengersponge_offset;
uniform float fmengersponge_scale;

vec2 mengersponge_sdf(vec3 p) {
    float scale = fmengersponge_scale;
	float orbit_trap = 1000000.0;
	float s = 1.0;
	int n = 0;

	for (; n < iterations; n++) {
		p = rotate3d_point(p, fmengersponge_rotation1);

		p = abs(p);
		if (n < 6) orbit_trap += fract(p.x);
		if (p.x < p.y) p.xy = p.yx;
		if (p.x < p.z) { p.xz = p.zx; orbit_trap *= coloring_mode == 0 ? 2.0 : 1.0; }
		if (p.y < p.z) p.zy = p.yz;

		if (coloring_mode == 0) orbit_trap = min(orbit_trap, abs(dot(p, p)));
		else orbit_trap = min(orbit_trap, process_orbit_trap(p));

		p.z -= 0.5 * fmengersponge_offset.z * (scale - 1.0) / scale;
		p.z = -abs(p.z);
		p.z += 0.5 * fmengersponge_offset.z * (scale - 1.0) / scale;

		p *= scale;
		s /= scale;

		p.x -= fmengersponge_offset.x * (scale - 1.0);
		p.y -= fmengersponge_offset.y * (scale - 1.0);

		p = rotate3d_point(p, fmengersponge_rotation2);
	}

	float d = cube_sdf3d(p, vec3(1.0)) * s;
	return vec2(d, orbit_trap);
}