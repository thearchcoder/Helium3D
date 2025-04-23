// [ID]
// Mandelbox
// [INDEX]
// 2
// [VARS]
// float scale[1.0, 3.0] = 2.5
// float radius1[0.0, 3.0] = 1.0
// float radius2[0.0, 3.0] = 0.0
// vec3 box_folds[(-2, -2, -2), (2, 2, 2)] = (1, 0, 0)
// [CODE]
uniform float fmandelbox_scale;
uniform float fmandelbox_radius1;
uniform float fmandelbox_radius2;
uniform vec3 fmandelbox_box_folds;

void boxFold(inout vec3 z, vec3 r) {
	z = 2.0 * clamp(z, -r, r) - z;
}

void sphereFold(inout vec3 z, inout float dz) {
	float r2 = dot(z,z);
	if (r2 < fmandelbox_radius2) {
		float temp = fmandelbox_radius1 / fmandelbox_radius2;
		z *= temp;
		dz *= temp;
	}
	else if (r2 < fmandelbox_radius1) {
		float temp = fmandelbox_radius1 / r2;
		z *= temp;
		dz *= temp;
	}
}

vec2 mandelbox_sdf(vec3 p) {
	vec3 z = p * 5.5;
	vec3 c = z;
	float dz = 1.0;
	float orbit_trap = 10000.0;

	for (int i = 0; i < iterations; i++) {
		//if (z.x - z.z < 0.0) z.xz = z.zx;
		if (length(fmandelbox_box_folds.x) >= 0.0001) boxFold(z, vec3(fmandelbox_box_folds.x));
		if (length(fmandelbox_box_folds.y) >= 0.0001) boxFold(z, vec3(fmandelbox_box_folds.y));
		if (length(fmandelbox_box_folds.z) >= 0.0001) boxFold(z, vec3(fmandelbox_box_folds.z));
		//z.xz = abs(z.xz + 0.3) - abs(z.xz - 1.0) - z.xz;
		sphereFold(z, dz);
		z *= fmandelbox_scale;
		z += c;
		dz = dz * abs(fmandelbox_scale) + 1.0;

		if (coloring_mode == 0) orbit_trap = min(orbit_trap, length(z));
		else orbit_trap = min(orbit_trap, process_orbit_trap(z));
	}

	return vec2(length(z) / abs(dz) / 5.5, orbit_trap);
}