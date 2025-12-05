// [ID]
// Mandelbox Dupe D
// [OFFICIAL]
// [KIFS]
// [VARS]
// selection shape[Tetrahedron, Cube, Octahedron, Dodecahedron, Truncated Octahedron] = Cube
// float scale[1.0, 3.0] = 2.5
// float radius1[0.0, 3.0] = 1.0
// advanced float fold1[0.0, 3.0] = 0.2
// advanced float fold1_strength[0.0, 3.0] = 0.0
// float radius2[0.0, 3.0] = 0.0
// vec3 box_folds[(-2, -2, -2), (2, 2, 2)] = (1, 0, 0)
// advanced bool is_julia[false, true] = false
// advanced vec3 julia_c[(-8, -8, -8), (8, 8, 8)] = (5, 5, 5)
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// [CODE]

vec3 mandelboxduped_generalized_box_fold(vec3 z, float folding_limit, float folding_value) {
	int poly_type = int(folding_limit);
	int sides;

	vec3 nv_tet[4] = vec3[] (
		vec3( sqrt_i3,  sqrt_i3, -sqrt_i3),
		vec3( sqrt_i3, -sqrt_i3,  sqrt_i3),
		vec3(-sqrt_i3,  sqrt_i3,  sqrt_i3),
		vec3(-sqrt_i3, -sqrt_i3, -sqrt_i3)
	);

	vec3 nv_cube[6] = vec3[] (
		vec3( 1.0,  0.0,  0.0),
		vec3(-1.0,  0.0,  0.0),
		vec3( 0.0,  1.0,  0.0),
		vec3( 0.0, -1.0,  0.0),
		vec3( 0.0,  0.0,  1.0),
		vec3( 0.0,  0.0, -1.0)
	);

	vec3 nv_oct[8] = vec3[] (
		vec3( sqrt_i3,  sqrt_i3, -sqrt_i3),
		vec3( sqrt_i3, -sqrt_i3,  sqrt_i3),
		vec3(-sqrt_i3,  sqrt_i3,  sqrt_i3),
		vec3(-sqrt_i3, -sqrt_i3, -sqrt_i3),
		vec3( sqrt_i3,  sqrt_i3,  sqrt_i3),
		vec3(-sqrt_i3, -sqrt_i3,  sqrt_i3),
		vec3(-sqrt_i3,  sqrt_i3, -sqrt_i3),
		vec3( sqrt_i3, -sqrt_i3, -sqrt_i3)
	);

	vec3 nv_oct_cube[14] = vec3[] (
		vec3( sqrt_i3,  sqrt_i3, -sqrt_i3),
		vec3( sqrt_i3, -sqrt_i3,  sqrt_i3),
		vec3(-sqrt_i3,  sqrt_i3,  sqrt_i3),
		vec3(-sqrt_i3, -sqrt_i3, -sqrt_i3),
		vec3( sqrt_i3,  sqrt_i3,  sqrt_i3),
		vec3(-sqrt_i3, -sqrt_i3,  sqrt_i3),
		vec3(-sqrt_i3,  sqrt_i3, -sqrt_i3),
		vec3( sqrt_i3, -sqrt_i3, -sqrt_i3),
		vec3( 1.0,  0.0,  0.0),
		vec3(-1.0,  0.0,  0.0),
		vec3( 0.0,  1.0,  0.0),
		vec3( 0.0, -1.0,  0.0),
		vec3( 0.0,  0.0,  1.0),
		vec3( 0.0,  0.0, -1.0)
	);

	vec3 nv_dodeca[12] = vec3[] (
		vec3( 0.0,  bb,  aa*bb),
		vec3( 0.0,  bb, -aa*bb),
		vec3( 0.0, -bb,  aa*bb),
		vec3( 0.0, -bb, -aa*bb),
		vec3( bb,  aa*bb,  0.0),
		vec3( bb, -aa*bb,  0.0),
		vec3(-bb,  aa*bb,  0.0),
		vec3(-bb, -aa*bb,  0.0),
		vec3( aa*bb,  0.0,  bb),
		vec3(-aa*bb,  0.0,  bb),
		vec3( aa*bb,  0.0, -bb),
		vec3(-aa*bb,  0.0, -bb)
	);
	
	ivec3 sort_indices;
	float tmp_sort;
	vec3 z_dot_nv;
	float tmp_z_dot_nv;
	
	sort_indices[0] = 0;
	sort_indices[1] = 1;
	sort_indices[2] = 2;
	
	if (poly_type == 1) {
		sides = 4;
		z_dot_nv[0] = dot(z, nv_tet[0]);
		z_dot_nv[1] = dot(z, nv_tet[1]);
		z_dot_nv[2] = dot(z, nv_tet[2]);
	} else if (poly_type == 2) {
		sides = 6;
		z_dot_nv[0] = dot(z, nv_cube[0]);
		z_dot_nv[1] = dot(z, nv_cube[1]);
		z_dot_nv[2] = dot(z, nv_cube[2]);
	} else if (poly_type == 3) {
		sides = 8;
		z_dot_nv[0] = dot(z, nv_oct[0]);
		z_dot_nv[1] = dot(z, nv_oct[1]);
		z_dot_nv[2] = dot(z, nv_oct[2]);
	} else if (poly_type == 4) {
		sides = 12;
		z_dot_nv[0] = dot(z, nv_dodeca[0]);
		z_dot_nv[1] = dot(z, nv_dodeca[1]);
		z_dot_nv[2] = dot(z, nv_dodeca[2]);
	} else if (poly_type == 5) {
		sides = 14;
		z_dot_nv[0] = dot(z, nv_oct_cube[0]);
		z_dot_nv[1] = dot(z, nv_oct_cube[1]);
		z_dot_nv[2] = dot(z, nv_oct_cube[2]);
	} else {
		sides = 4;
		z_dot_nv[0] = dot(z, nv_tet[0]);
		z_dot_nv[1] = dot(z, nv_tet[1]);
		z_dot_nv[2] = dot(z, nv_tet[2]);
	}
	
	if (z_dot_nv[1] > z_dot_nv[0]) {
		int tmp_sort = sort_indices[0];
		tmp_z_dot_nv = z_dot_nv[0];
		sort_indices[0] = sort_indices[1];
		z_dot_nv[0] = z_dot_nv[1];
		sort_indices[1] = tmp_sort;
		z_dot_nv[1] = tmp_z_dot_nv;
	}
	if (z_dot_nv[2] > z_dot_nv[1]) {
		int tmp_sort = sort_indices[1];
		tmp_z_dot_nv = z_dot_nv[1];
		sort_indices[1] = sort_indices[2];
		z_dot_nv[1] = z_dot_nv[2];
		sort_indices[2] = tmp_sort;
		z_dot_nv[2] = tmp_z_dot_nv;
	}
	if (z_dot_nv[1] > z_dot_nv[0]) {
		int tmp_sort = sort_indices[0];
		tmp_z_dot_nv = z_dot_nv[0];
		sort_indices[0] = sort_indices[1];
		z_dot_nv[0] = z_dot_nv[1];
		sort_indices[1] = tmp_sort;
		z_dot_nv[1] = tmp_z_dot_nv;
	}
	
	for (int i = 3; i < sides; i++) {
		if (poly_type == 1) {
			tmp_z_dot_nv = dot(z, nv_tet[i]);
		} else if (poly_type == 2) {
			tmp_z_dot_nv = dot(z, nv_cube[i]);
		} else if (poly_type == 3) {
			tmp_z_dot_nv = dot(z, nv_oct[i]);
		} else if (poly_type == 4) {
			tmp_z_dot_nv = dot(z, nv_dodeca[i]);
		} else if (poly_type == 5) {
			tmp_z_dot_nv = dot(z, nv_oct_cube[i]);
		} else {
			tmp_z_dot_nv = dot(z, nv_tet[i]);
		}
		
		int tmp_sort = i;
		if (tmp_z_dot_nv > z_dot_nv[2]) {
			sort_indices[2] = tmp_sort;
			z_dot_nv[2] = tmp_z_dot_nv;
			if (tmp_z_dot_nv > z_dot_nv[1]) {
				sort_indices[2] = sort_indices[1];
				z_dot_nv[2] = z_dot_nv[1];
				sort_indices[1] = tmp_sort;
				z_dot_nv[1] = tmp_z_dot_nv;
				if (tmp_z_dot_nv > z_dot_nv[0]) {
					sort_indices[1] = sort_indices[0];
					z_dot_nv[1] = z_dot_nv[0];
					sort_indices[0] = tmp_sort;
					z_dot_nv[0] = tmp_z_dot_nv;
				}
			}
		}
	}
	
	vec3 nv0, nv1, nv2;
	if (poly_type == 1) {
		nv0 = nv_tet[sort_indices[0]];
		nv1 = nv_tet[sort_indices[1]];
		nv2 = nv_tet[sort_indices[2]];
	} else if (poly_type == 2) {
		nv0 = nv_cube[sort_indices[0]];
		nv1 = nv_cube[sort_indices[1]];
		nv2 = nv_cube[sort_indices[2]];
	} else if (poly_type == 3) {
		nv0 = nv_oct[sort_indices[0]];
		nv1 = nv_oct[sort_indices[1]];
		nv2 = nv_oct[sort_indices[2]];
	} else if (poly_type == 4) {
		nv0 = nv_dodeca[sort_indices[0]];
		nv1 = nv_dodeca[sort_indices[1]];
		nv2 = nv_dodeca[sort_indices[2]];
	} else if (poly_type == 5) {
		nv0 = nv_oct_cube[sort_indices[0]];
		nv1 = nv_oct_cube[sort_indices[1]];
		nv2 = nv_oct_cube[sort_indices[2]];
	} else {
		nv0 = nv_tet[sort_indices[0]];
		nv1 = nv_tet[sort_indices[1]];
		nv2 = nv_tet[sort_indices[2]];
	}
	
	vec3 new_z = z;
	float new_z_sqr = dot(new_z, new_z);
	
	vec3 zm = z - (nv0 + nv0) * (dot(z, nv0) - folding_value);
	if (new_z_sqr > dot(zm, zm)) {
		new_z = zm;
		new_z_sqr = dot(new_z, new_z);
	}
	
	vec3 t01, l01;
	l01 = cross_product(nv0, nv1);
	l01 = l01 * (1.0 / length(l01));
	t01 = (nv0 + nv1) * (folding_value / (1.0 + dot(nv0, nv1)));
	vec3 zr = (t01 + l01 * dot(z, l01)) * 2.0 - z;
	if (new_z_sqr > dot(zr, zr)) {
		new_z = zr;
		new_z_sqr = dot(new_z, new_z);
	}
	
	vec3 zi;
	float a = (folding_value - dot(t01, nv2)) / dot(l01, nv2);
	zi = (l01 * a + t01) * 2.0 - z;
	if (new_z_sqr > dot(zi, zi)) {
		new_z = zi;
		new_z_sqr = dot(new_z, new_z);
	}
	
	return new_z;
}

void mandelboxduped_box_fold(inout vec3 z, vec3 r) {
	z = 2.0 * clamp(z, -r, r) - z;
}

void mandelboxduped_sphere_fold(inout vec3 z, inout float dz) {
	float r2 = dot(z,z);
	if (r2 < fmandelboxduped_radius2) {
		float temp = fmandelboxduped_radius1 / fmandelboxduped_radius2;
		z *= temp;
		dz *= temp;
	}
	else if (r2 < fmandelboxduped_radius1) {
		float temp = fmandelboxduped_radius1 / r2;
		z *= temp;
		dz *= temp;
	}
}

void mandelboxduped_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	vec3 c = fmandelboxduped_is_julia ? fmandelboxduped_julia_c : original_z.xyz * 5.5;
	if (i == 0) z *= 5.5;

	z = rotate3d_point(z, fmandelboxduped_rotation1);
	
	if (fmandelboxduped_shape == 1) {
		if (length(fmandelboxduped_box_folds.x) >= 0.0001) mandelboxduped_box_fold(z, vec3(fmandelboxduped_box_folds.x));
		if (length(fmandelboxduped_box_folds.y) >= 0.0001) mandelboxduped_box_fold(z, vec3(fmandelboxduped_box_folds.y));
		if (length(fmandelboxduped_box_folds.z) >= 0.0001) mandelboxduped_box_fold(z, vec3(fmandelboxduped_box_folds.z));
	} else {
		if (length(fmandelboxduped_box_folds.x) >= 0.0001) z = mandelboxduped_generalized_box_fold(z, float(fmandelboxduped_shape + 1), fmandelboxduped_box_folds.x);
		if (length(fmandelboxduped_box_folds.y) >= 0.0001) z = mandelboxduped_generalized_box_fold(z, float(fmandelboxduped_shape + 1), fmandelboxduped_box_folds.y);
		if (length(fmandelboxduped_box_folds.z) >= 0.0001) z = mandelboxduped_generalized_box_fold(z, float(fmandelboxduped_shape + 1), fmandelboxduped_box_folds.z);
	}
	
	z -= min(z, fmandelboxduped_fold1) * fmandelboxduped_fold1_strength;
	mandelboxduped_sphere_fold(z, dz);
	z *= fmandelboxduped_scale;
	z += c;

	z = rotate3d_point(z, fmandelboxduped_rotation2);

	dz = dz * abs(fmandelboxduped_scale) + 18.5;
	if (fmandelboxduped_is_julia) dz += 6.0;

	z4.xyz = z;
}
