// [ID]
// Newton
// [DIFS]
// [INDEX]
// 15
// [VARS]
// selection plane[XZ, YZ, XY] = YZ
// bool intersection_mode[false, true] = true
// int power[3, 12] = 3
// [CODE]

vec2 complex_mul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
vec2 complex_div(vec2 a, vec2 b) {
	float denom = b.x * b.x + b.y * b.y;
	return vec2(
		(a.x * b.x + a.y * b.y) / denom,
		(a.y * b.x - a.x * b.y) / denom
	);
}

float newton_sdf2d(vec2 z0, inout float trap) {
	const int nzero = 3;
	const vec2 zeros[3] = vec2[3](
		vec2(1.0, 0.0),
		vec2(-0.5, 0.866),
		vec2(-0.5, -0.866)
	);

	vec2 z = z0;
	vec2 dz = vec2(1.0, 0.0);
	float eps = 0.001;

	for (int k = 0; k < iterations; k++) {
		vec2 sz, sz2;

		for (int i = 0; i < nzero; i++) {
			float e = length(z - zeros[i]);
			if (e < eps) return e * -log(e) / length(dz);

			vec2 d = z - zeros[i];
			sz += complex_div(vec2(1.0, 0.0), d);
			sz2 += complex_div(vec2(1.0, 0.0), complex_mul(d, d));
		}

		z -= complex_div(vec2(1.0, 0.0), sz);
		dz = complex_mul(dz, complex_div(-sz2, complex_mul(sz, sz)) + vec2(1.0, 0.0));

		if (k > color_min_iterations && k < color_max_iterations) trap = min(trap, dot(z, z));
	}

	return 0.0;
}

float newton3d_de_intersection(vec3 p, int plane_combo, inout float trap) {
	if (plane_combo == 0) {
		float a = newton_sdf2d(p.xy, trap);
		float b = newton_sdf2d(p.yz, trap);
		return max(a, b);
	} else if (plane_combo == 1) {
		float a = newton_sdf2d(p.zx, trap);
		float b = newton_sdf2d(p.xy, trap);
		return max(a, b);
	} else {
		float a = newton_sdf2d(p.yz, trap);
		float b = newton_sdf2d(p.zx, trap);
		return max(a, b);
	}
}

float newton3d_de_rotation(vec3 p, int plane_id, inout float trap) {
	if (plane_id == 0) {
		p = vec3(length(p.yz), p.x, 0.0);
	} else if (plane_id == 1) {
		p = vec3(p.x, length(p.yz), 0.0);
	} else {
		p = vec3(p.x, p.y, length(p.xz));
	}

	return sqrt(pow(newton_sdf2d(p.xy, trap), 2.0) + pow(p.z, 3.0));
}

vec2 newton_sdf(vec4 z4d) {
	vec3 p = z4d.xyz;
	float d = 0.0;
	float d2 = 0.0;
	float trap = 100000.0;

	float de;
	if (fnewton_intersection_mode) de = newton3d_de_intersection(p, fnewton_plane, trap);
	else de = newton3d_de_rotation(p, fnewton_plane, trap);

	return vec2(de * 0.5, trap);
}