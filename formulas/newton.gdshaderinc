// [ID]
// Newton
// [INDEX]
// 15
// [VARS]
// float epsilon[0.0, 1.0] = 0.05
// float relax[1.0, 5.0] = 2.0
// selection plane[XZ, YZ, XY] = YZ
// bool intersection_mode[false, true] = true
// float symmetry1[1.0, 100.0] = 1.0
// float symmetry2[1.0, 100.0] = 1.0
// vec4 pole1[(-2, -2, -1, -1), (2, 2, 1, 1)] = (1.0, 0.0, 1.0, 0.0)
// vec4 pole2[(-2, -2, -1, -1), (2, 2, 1, 1)] = (-0.5, 0.866, 1.0, 0.0)
// vec4 pole3[(-2, -2, -1, -1), (2, 2, 1, 1)] = (-0.5, -0.866, 1.0, 0.0)
// vec4 invsphere[(-2, -2, -2, -2), (2, 2, 2, 2)] = (1, 0.037, 0, 1)
// bool invert[false, true] = false
// [CODE]
uniform float fnewton_epsilon;
uniform float fnewton_relax;
uniform int fnewton_plane;
uniform bool fnewton_intersection_mode;
uniform vec4 fnewton_pole1;
uniform vec4 fnewton_pole2;
uniform vec4 fnewton_pole3;
uniform vec4 fnewton_invsphere;
uniform bool fnewton_invert;
uniform float fnewton_symmetry1;
uniform float fnewton_symmetry2;

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

//float newton_sdf2d(vec2 z0, inout float trap) {
	//const int nzero = 3;
	//vec2 zeros[5];
	//vec2 zerop[5];
//
	//zeros[0] = fnewton_pole1.xy;
	//zeros[1] = fnewton_pole2.xy;
	//zeros[2] = fnewton_pole3.xy;
//
	//zerop[0] = fnewton_pole1.zw;
	//zerop[1] = fnewton_pole2.zw;
	//zerop[2] = fnewton_pole3.zw;
//
	//const int npole = 0;
	//vec2 poles[5];
	//vec2 polep[5];
//
	//vec2 z = z0;
	//vec2 dz = vec2(1.0, 0.0);
	//float eps = 0.001;
//
	//for (int k = 0; k < iterations; k++) {
		//for (int i = 0; i < nzero; i++) {
			//float e = complex_abs(z - zeros[i]);
			//if (e < eps) {
				//float de = e * -log(e) / length(dz);
				////de = min(de, sphere_sdf2d(z0, fnewton_pole1.xy, 0.3));
				////de = min(de, sphere_sdf2d(z0, fnewton_pole2.xy, 0.3));
				////de = min(de, sphere_sdf2d(z0, fnewton_pole3.xy, 0.3));
				//return de;
			//}
		//}
//
		//vec2 sz = vec2(0.0, 0.0);
		//vec2 sz2 = vec2(0.0, 0.0);
//
		//for (int i = 0; i < nzero; ++i) {
			//vec2 d = z - zeros[i];
			//sz += complex_div(zerop[i], d);
			//sz2 += complex_div(zerop[i], complex_mul(d, d));
		//}
//
		//vec2 sp = vec2(0.0, 0.0);
		//vec2 sp2 = vec2(0.0, 0.0);
//
		//for (int j = 0; j < npole; ++j) {
			//vec2 d = z - poles[j];
			//sp += complex_div(polep[j], d);
			//sp2 += complex_div(polep[j], complex_mul(d, d));
		//}
//
		//vec2 d = sz - sp;
		//z -= complex_div(vec2(1.0, 0.0), d);
//
		//vec2 temp = complex_div(sp2 - sz2, complex_mul(d, d));
		//dz = complex_mul(dz, temp + vec2(1.0, 0.0));
		//
		//if (k > color_min_iterations && k < color_max_iterations) trap = min(trap, dot(z, z));
	//}
//
	//return 0.0;
//}

vec2 complex_sin(vec2 z) {
    return vec2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y));
}

vec2 complex_cos(vec2 z) {
    return vec2(cos(z.x) * cosh(z.y), -sin(z.x) * sinh(z.y));
}

float newton_sdf2d(vec2 z, inout float ob_trap) {
    vec2 dz = vec2(1.0, 0.0);
    float eps = fnewton_epsilon;

    for (int k = 0; k < iterations + (k-k); k++) {
        vec2 sin_z = complex_sin(z);
        vec2 cos_z = complex_cos(z);

        float e = complex_abs(sin_z);
        if (e < eps) {
            float de = e * -log(e) / length(dz);
            return de;
        }

        vec2 d = cos_z;
        z -= complex_div(fnewton_relax*sin_z, cos_z);
        dz = complex_mul(dz, cos_z);
    }

    float e = complex_abs(complex_sin(z));
    float de = e * -log(e) / length(dz);

    return de;
}

float newton3d_de_intersection(vec3 p, int plane_combo, inout float trap) {
	float angle1 = 3.14159265 / fnewton_symmetry1;
	float angle2 = 3.14159265 / fnewton_symmetry2;
	float theta1 = 0.0;
	float theta2 = 0.0;
	float r = 0.0;
	vec3 p_rotated1 = p;
	vec3 p_rotated2 = p;

	if (plane_combo == 0) {
		// XZ rotation for both vectors
		r = length(p.xz);

		// First rotation with angle1
		theta1 = atan(p.z, p.x);
		theta1 = mod(theta1 + angle1, 2.0 * angle1) - angle1;
		p_rotated1.xz = vec2(cos(theta1), sin(theta1)) * r;

		// Second rotation with angle2
		theta2 = atan(p.z, p.x);
		theta2 = mod(theta2 + angle2, 2.0 * angle2) - angle2;
		p_rotated2.xz = vec2(cos(theta2), sin(theta2)) * r;

		float a = newton_sdf2d(p_rotated1.xy, trap);
		float b = newton_sdf2d(p_rotated2.yz, trap);
		return max(a, b);
	} else if (plane_combo == 1) {
		// XY rotation for both vectors
		r = length(p.xy);

		// First rotation with angle1
		theta1 = atan(p.x, p.y);
		theta1 = mod(theta1 + angle1, 2.0 * angle1) - angle1;
		p_rotated1.xy = vec2(cos(theta1), sin(theta1)) * r;

		// Second rotation with angle2
		theta2 = atan(p.x, p.y);
		theta2 = mod(theta2 + angle2, 2.0 * angle2) - angle2;
		p_rotated2.xy = vec2(cos(theta2), sin(theta2)) * r;

		float a = newton_sdf2d(p_rotated1.zx, trap);
		float b = newton_sdf2d(p_rotated2.xy, trap);
		return max(a, b);
	} else {
		// YZ rotation for both vectors
		r = length(p.yz);

		// First rotation with angle1
		theta1 = atan(p.y, p.z);
		theta1 = mod(theta1 + angle1, 2.0 * angle1) - angle1;
		p_rotated1.yz = vec2(cos(theta1), sin(theta1)) * r;

		// Second rotation with angle2
		theta2 = atan(p.y, p.z);
		theta2 = mod(theta2 + angle2, 2.0 * angle2) - angle2;
		p_rotated2.yz = vec2(cos(theta2), sin(theta2)) * r;

		float a = newton_sdf2d(p_rotated1.yz, trap);
		float b = newton_sdf2d(p_rotated2.zx, trap);
		return max(a, b);
	}
}

float newton3d_de_rotation(vec3 p, int plane_id, inout float trap) {
	float angle = 3.14159265 / fnewton_symmetry1;
	float theta = 0.0;
	float r = 0.0;

	if (plane_id == 0) {
		r = length(p.yz);
		theta = atan(p.z, p.y);
		theta = mod(theta + angle, 2.0 * angle) - angle;
		p.yz = vec2(cos(theta), sin(theta)) * r;
		p = vec3(length(p.yz), p.x, 0.0);
	} else if (plane_id == 1) {
		r = length(p.yz);
		theta = atan(p.z, p.y);
		theta = mod(theta + angle, 2.0 * angle) - angle;
		p.yz = vec2(cos(theta), sin(theta)) * r;
		p = vec3(p.x, length(p.yz), 0.0);
	} else {
		r = length(p.xz);
		theta = atan(p.z, p.x);
		theta = mod(theta + angle, 2.0 * angle) - angle;
		p.xz = vec2(cos(theta), sin(theta)) * r;
		p = vec3(p.x, p.y, length(p.xz));
	}

	return sqrt(pow(newton_sdf2d(p.xy, trap), 2.0) + pow(p.z, 3.0));
}

vec2 newton_sdf(vec3 p) {
	float d = 0.0;
	float d2 = 0.0;
	float trap = 100000.0;

	if (fnewton_invert) {
		p -= fnewton_invsphere.xyz;
		d = length(p);
		d2 = d * d;
		p = (fnewton_invsphere.w * fnewton_invsphere.w / d2) * p;
		p += fnewton_invsphere.xyz;
	}

	float de;
	if (fnewton_intersection_mode) de = newton3d_de_intersection(p, fnewton_plane, trap);
	else de = newton3d_de_rotation(p, fnewton_plane, trap);

	if (fnewton_invert) de = de * d2 / (fnewton_invsphere.w + d * de);
	de *= 0.5;

	return vec2(de, trap);
}