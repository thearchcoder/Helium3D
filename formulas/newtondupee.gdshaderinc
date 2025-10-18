// [ID]
// Newton Dupe E
// [OFFICIAL]
// [DIFS]
// [INDEX]
// [VARS]
// selection plane[XZ, YZ, XY] = YZ
// bool intersection_mode[false, true] = true
// [CODE]
float newtondupee_complex_abs(vec2 z) { return length(z); }
vec2 newtondupee_complex_mul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
vec2 newtondupee_complex_div(vec2 a, vec2 b) {
	float denom = b.x * b.x + b.y * b.y;
	return vec2(
		(a.x * b.x + a.y * b.y) / denom,
		(a.y * b.x - a.x * b.y) / denom
	);
}
vec2 newtondupee_complex_reciprocal(vec2 z) {
	float denom = z.x * z.x + z.y * z.y;
	return vec2(z.x / denom, -z.y / denom);
}
float newtondupee_sdf2d(vec2 z0, inout float trap) {
	vec2 z = z0;
	vec2 dz = vec2(1.0, 0.0);
	float eps = 0.001;
	for (int k = 0; k < iterations; k++) {
		float min_distance = newtondupee_complex_abs(z - vec2(1.0, 0.0));
		if (min_distance < eps) return min_distance * -log(min_distance) / length(dz);
		float dist1 = newtondupee_complex_abs(z - vec2(-0.5, 0.866));
		if (dist1 < eps) return dist1 * -log(dist1) / length(dz);
		if (dist1 < min_distance) min_distance = dist1;
		float dist2 = newtondupee_complex_abs(z - vec2(-0.5, -0.866));
		if (dist2 < eps) return dist2 * -log(dist2) / length(dz);
		if (dist2 < min_distance) min_distance = dist2;
		vec2 d0 = z - vec2(1.0, 0.0);
		vec2 d1 = z - vec2(-0.5, 0.866);
		vec2 d2 = z - vec2(-0.5, -0.866);
		vec2 sz = newtondupee_complex_div(vec2(1.0, 0.0), d0) + newtondupee_complex_div(vec2(1.0, 0.0), d1) + newtondupee_complex_div(vec2(1.0, 0.0), d2);
		vec2 sz2 = newtondupee_complex_div(vec2(1.0, 0.0), newtondupee_complex_mul(d0, d0)) + newtondupee_complex_div(vec2(1.0, 0.0), newtondupee_complex_mul(d1, d1)) + newtondupee_complex_div(vec2(1.0, 0.0), newtondupee_complex_mul(d2, d2));
		vec2 sp = vec2(0.0, 0.0);
		vec2 sp2 = vec2(0.0, 0.0);
		vec2 d = sz - sp;
		z -= newtondupee_complex_div(vec2(1.0, 0.0), d);
		vec2 temp = newtondupee_complex_div(sp2 - sz2, newtondupee_complex_mul(d, d));
		dz = newtondupee_complex_mul(dz, temp + vec2(1.0, 0.0));
		if (k > color_min_iterations && k < color_max_iterations) trap = min(trap, dot(z, z));
	}
	return 0.0;
}
float newtondupee_3d_de_intersection(vec3 p, int plane_combo, inout float trap) {
	if (plane_combo == 0) {
		float a = newtondupee_sdf2d(p.xy, trap);
		float b = newtondupee_sdf2d(p.yz, trap);
		return max(a, b);
	} else if (plane_combo == 1) {
		float a = newtondupee_sdf2d(p.zx, trap);
		float b = newtondupee_sdf2d(p.xy, trap);
		return max(a, b);
	} else {
		float a = newtondupee_sdf2d(p.yz, trap);
		float b = newtondupee_sdf2d(p.zx, trap);
		return max(a, b);
	}
}
float newtondupee_3d_de_rotation(vec3 p, int plane_id, inout float trap) {
	if (plane_id == 0) p = vec3(length(p.yz), p.x, 0.0);
	 else if (plane_id == 1) p = vec3(p.x, length(p.yz), 0.0);
	 else p = vec3(p.x, p.y, length(p.xz));
	return sqrt(pow(newtondupee_sdf2d(p.xy, trap), 2.0) + pow(p.z, 3.0));
}
vec2 newtondupee_sdf(vec4 z4d) {
	vec3 p = z4d.xyz;
	float d = 0.0;
	float d2 = 0.0;
	float trap = 100000.0;
	float de;
	if (fnewtondupee_intersection_mode) de = newtondupee_3d_de_intersection(p, fnewtondupee_plane, trap);
	else de = newtondupee_3d_de_rotation(p, fnewtondupee_plane, trap);
	return vec2(de * 0.5, trap);
}