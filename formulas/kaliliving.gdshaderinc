// [ID]
// Kali living
// [INDEX]
// 17
// [VARS]
// vec3 c[(-2, -2, -2), (2, 2, 2)] = (-3.0, -1.5, -0.5)
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (1, 1, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (1.6, 0, 0)
// float scale[1.0, 3.0] = 1.15
// [CODE]
uniform vec3 fkaliliving_c;
uniform vec3 fkaliliving_rotation1;
uniform vec3 fkaliliving_rotation2;
uniform float fkaliliving_scale;

vec2 kaliliving_sdf(vec3 p) {
	p *= 14.0;
	p = p.zxy;
	p.x *= 0.75;

	float scale = fkaliliving_scale;
	float orbit_trap = 100000.0;
	vec3 z = p;
	vec3 c = fkaliliving_c;
	float r;

	for (int i = 0; i < iterations; i++) {
		p = rotate3d_point(p, fkaliliving_rotation1);

		p.xy = abs(p.xy);
		p = p * scale + c;
		r = length(p);

		p = rotate3d_point(p, fkaliliving_rotation2);

		if (coloring_mode == 0) orbit_trap = min(orbit_trap, length(p.x));
		else orbit_trap = min(orbit_trap, process_orbit_trap(p));
	}

	float d = r * pow(scale, -float(iterations)) - 0.1;
	return vec2(d / 14.0, orbit_trap);
}