// [ID]
// Baird delta
// [INDEX]
// 4
// [VARS]
// float angle[60.01, 90.0] = 84.0
// vec3 rotation1[(-2, -2, -2), (2, 2, 2)] = (0, 0, 0)
// vec3 rotation2[(-2, -2, -2), (2, 2, 2)] = (0, 0, 0)
// float scale[1.0, 3.0] = 2.0
// [CODE]
uniform float fbairddelta_angle;
uniform float fbairddelta_scale;
uniform vec3 fbairddelta_rotation1;
uniform vec3 fbairddelta_rotation2;

vec2 bairddelta_sdf(vec3 p) {
	float angle = clamp(fbairddelta_angle, 60.0001, 90.0);
	float beta = (PI / 360.0) * angle;
	float t = tan(beta);
	vec3 n1 = vec3(cos(PI / 6.0), -sin(PI / 6.0), 0.0);
	vec3 n2 = vec3(0.5, 0.0, sqrt(3.0 * t * t - 1.0) * 0.25);
	vec3 n3 = normalize(vec3(1.0, 0.0, -0.5 * sqrt(3.0 * t * t - 1.0)));
	t = cos(beta);
	float scale = fbairddelta_scale * 2.0 * t * t;
	float orbit_trap = 10000.0;
	float r2 = dot(p, p);
	float s = 1.0;

	for (int i = 0; i < iterations; i++) {
		p = rotate3d_point(p, fbairddelta_rotation1);

		// Sierpinski triangle symmetry + fold about xy plane
		p.yz = abs(p.yz);
		float t = 2.0 * min(0.0, dot(p, n1));
		p -= t * n1;
		p.y = abs(p.y);

		// Koch curve fold
		p -= n2;
		t = 2.0 * min(0.0, dot(p, n3));
		p -= t * n3;
		p += n2;

		// Scale and rotate
		p.x -= 1.0;
		p *= scale;
		p.x += 1.0;
		s *= scale;

		p = rotate3d_point(p, fbairddelta_rotation2);

		r2 = dot(p, p);
		if (coloring_mode == 0) orbit_trap = min(orbit_trap, abs(r2));
		else orbit_trap = min(orbit_trap, process_orbit_trap(p));
	}
	return vec2((sqrt(r2) - 3.0) / s, orbit_trap);
}
