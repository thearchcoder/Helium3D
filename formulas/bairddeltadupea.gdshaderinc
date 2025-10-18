// [ID]
// Baird delta Dupe A
// [OFFICIAL]
// [KIFS]
// [VARS]
// float angle[60.01, 90.0] = 84.0
// vec3 rotation1[(-2, -2, -2), (2, 2, 2)] = (0, 0, 0)
// vec3 rotation2[(-2, -2, -2), (2, 2, 2)] = (0, 0, 0)
// float scale[1.0, 3.0] = 2.0
// [CODE]

void bairddeltadupea_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = z.xyz;
	float angle = clamp(fbairddeltadupea_angle, 60.0001, 90.0);
	float beta = (PI / 360.0) * angle;
	float t = tan(beta);
	vec3 n1 = vec3(cos(PI / 6.0), -sin(PI / 6.0), 0.0);
	vec3 n2 = vec3(0.5, 0.0, sqrt(3.0 * t * t - 1.0) * 0.25);
	vec3 n3 = normalize(vec3(1.0, 0.0, -0.5 * sqrt(3.0 * t * t - 1.0)));
	t = cos(beta);
	float scale = fbairddeltadupea_scale * 2.0 * t * t;

	p = rotate3d_point(p, fbairddeltadupea_rotation1);

	// Sierpinski triangle symmetry + fold about xy plane
	p.yz = abs(p.yz);
	p -= 2.0 * min(0.0, dot(p, n1)) * n1;
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
	dz = dz * abs(scale) + 1.5;

	p = rotate3d_point(p, fbairddeltadupea_rotation2);

	z.xyz = p;
}
