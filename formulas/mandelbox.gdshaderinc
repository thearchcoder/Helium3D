// [ID]
// Mandelbox
// [KIFS]
// [INDEX]
// 2
// [VARS]
// float scale[1.0, 3.0] = 2.5
// float radius1[0.0, 3.0] = 1.0
// advanced float fold1[0.0, 3.0] = 0.2
// advanced float fold1_strength[0.0, 3.0] = 0.0
// float radius2[0.0, 3.0] = 0.0
// vec3 box_folds[(-2, -2, -2), (2, 2, 2)] = (1, 0, 0)
// advanced bool is_julia[false, true] = false
// advanced vec3 julia_c[(-8, -8, -8), (8, 8, 8)] = (5, 5, 5)
// template kifs_rotation
// [CODE]

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
	
	z = rotate3d_point(z, fmandelbox_rotation1);
	
	if (length(fmandelbox_box_folds.x) >= 0.0001) boxFold(z, vec3(fmandelbox_box_folds.x));
	if (length(fmandelbox_box_folds.y) >= 0.0001) boxFold(z, vec3(fmandelbox_box_folds.y));
	if (length(fmandelbox_box_folds.z) >= 0.0001) boxFold(z, vec3(fmandelbox_box_folds.z));
	z -= min(z, fmandelbox_fold1) * fmandelbox_fold1_strength;
	sphereFold(z, dz);
	z *= fmandelbox_scale;
	z += c;
	
	z = rotate3d_point(z, fmandelbox_rotation2);
	
	dz = dz * abs(fmandelbox_scale) + 18.5;
	if (fmandelbox_is_julia) dz += 6.0;

	z4.xyz = z;
}