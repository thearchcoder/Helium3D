// [ID]
// Mandelbox
// [INDEX]
// 2
// [VARS]
// float scale[1.0, 3.0] = 2.5
// float radius1[0.0, 3.0] = 1.0
// float radius2[0.0, 3.0] = 0.0
// vec3 box_folds[(-2, -2, -2), (2, 2, 2)] = (1, 0, 0)
// bool is_julia[false, true] = false
// vec3 julia_c[(-8, -8, -8), (8, 8, 8)] = (5, 5, 5)
// [CODE]
uniform float fmandelbox_scale;
uniform float fmandelbox_radius1;
uniform float fmandelbox_radius2;
uniform vec3 fmandelbox_box_folds;
uniform vec3 fmandelbox_julia_c;
uniform bool fmandelbox_is_julia;

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

void mandelbox_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	vec3 c = fmandelbox_is_julia ? fmandelbox_julia_c : original_z.xyz * 5.5;
	if (i == 0) z *= 5.5;

	//if (z.x - z.z < 0.0) z.xz = z.zx;
	if (length(fmandelbox_box_folds.x) >= 0.0001) boxFold(z, vec3(fmandelbox_box_folds.x));
	if (length(fmandelbox_box_folds.y) >= 0.0001) boxFold(z, vec3(fmandelbox_box_folds.y));
	if (length(fmandelbox_box_folds.z) >= 0.0001) boxFold(z, vec3(fmandelbox_box_folds.z));
	//z.xz = abs(z.xz + 0.3) - abs(z.xz - 1.0) - z.xz;
	sphereFold(z, dz);
	z *= fmandelbox_scale;
	z += c;
	dz = dz * abs(fmandelbox_scale) + 18.5;

	if (fmandelbox_is_julia) dz += 6.0;

	z4.xyz = z;
}