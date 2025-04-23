// [ID]
// Newton
// [INDEX]
// 15
// [VARS]
// vec4 pole1[(-2, -2, -1, -1), (2, 2, 1, 1)] = (0.0, 0.0, 1.0, 0.0)
// vec4 pole2[(-2, -2, -1, -1), (2, 2, 1, 1)] = (-0.595, 0.866, 1.0, 0.0)
// vec4 pole3[(-2, -2, -1, -1), (2, 2, 1, 1)] = (2.0, -0.866, 1.0, 0.0)
// vec4 invsphere[(-2, -2, -2, -2), (2, 2, 2, 2)] = (1, 0.037, 0, 1)
// bool invert[false, true] = true
// [CODE]
uniform vec4 fnewton_pole1;
uniform vec4 fnewton_pole2;
uniform vec4 fnewton_pole3;
uniform vec4 fnewton_invsphere;
uniform bool fnewton_invert;

float complex_abs(vec2 z) { return length(z); }
vec2 complex_mul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
vec2 complex_div(vec2 a, vec2 b) {
    float denom = b.x * b.x + b.y * b.y;
    return vec2(
        (a.x * b.x + a.y * b.y) / denom,
        (a.y * b.x - a.x * b.y) / denom
    );
}

vec2 complex_reciprocal(vec2 z) {
    float denom = z.x * z.x + z.y * z.y;
    return vec2(z.x / denom, -z.y / denom);
}

float newton_sdf2d(vec2 z0) {
	const int nzero = 3;
	vec2 zeros[5];
	vec2 zerop[5];

	zeros[0] = fnewton_pole1.xy;
	zeros[1] = fnewton_pole2.xy;
	zeros[2] = fnewton_pole3.xy;

	zerop[0] = fnewton_pole1.zw;
	zerop[1] = fnewton_pole2.zw;
	zerop[2] = fnewton_pole3.zw;

	const int npole = 0;
	vec2 poles[5];
	vec2 polep[5];

	vec2 z = z0;
	vec2 dz = vec2(1.0, 0.0);
	float eps = 0.001;

	for (int k = 0; k < iterations; k++) {
		for (int i = 0; i < nzero; i++) {
			float e = complex_abs(z - zeros[i]);
			if (e < eps) {
				float de = e * -log(e) / length(dz);
				//de = min(de, sphere_sdf2d(z0, fnewton_pole1.xy, 0.3));
				//de = min(de, sphere_sdf2d(z0, fnewton_pole2.xy, 0.3));
				//de = min(de, sphere_sdf2d(z0, fnewton_pole3.xy, 0.3));
				return de;
			}
		}

		vec2 sz = vec2(0.0, 0.0);
		vec2 sz2 = vec2(0.0, 0.0);

		for (int i = 0; i < nzero; ++i) {
			vec2 d = z - zeros[i];
			sz += complex_div(zerop[i], d);
			sz2 += complex_div(zerop[i], complex_mul(d, d));
		}

		vec2 sp = vec2(0.0, 0.0);
		vec2 sp2 = vec2(0.0, 0.0);

		for (int j = 0; j < npole; ++j) {
			vec2 d = z - poles[j];
			sp += complex_div(polep[j], d);
			sp2 += complex_div(polep[j], complex_mul(d, d));
		}

		vec2 d = sz - sp;
		z -= complex_div(vec2(1.0, 0.0), d);

		vec2 temp = complex_div(sp2 - sz2, complex_mul(d, d));
		dz = complex_mul(dz, temp + vec2(1.0, 0.0));
	}

	return 0.0;
}

vec2 newton_sdf(vec3 p) {
	vec3 q = vec3(p.x, length(p.yz), 0.0);
	float d = 0.0;
	float d2 = 0.0;

	if (fnewton_invert) {
		q -= fnewton_invsphere.xyz;
		d = length(q);
		d2 = d * d;
		q = (fnewton_invsphere.w * fnewton_invsphere.w / d2) * q;
		q += fnewton_invsphere.xyz;
	}

	float de = sqrt(pow(newton_sdf2d(q.xy), 2.0) + pow(q.z, 3.0));

	if (fnewton_invert) de = de * d2 / (fnewton_invsphere.w + d * de);
	de *= 0.5;

	return vec2(de, 0.0);
}