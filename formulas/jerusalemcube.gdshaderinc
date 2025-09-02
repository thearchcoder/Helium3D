// [ID]
// Jerusalem Cube
// [OFFICIAL]
// [KIFS]
// [VARS]
// vec2 scale[(1, 1), (8, 8)] = (5, 2.5)
// vec3 offset[(-1, -1, -1), (1, 1, 1)] = (1, 1, 1)
// template kifs_rotation
// vec3 abs_add[(-1, -1, -1), (1, 1, 1)] = (0, 0, 0)
// vec3 abs_minus[(-1, -1, -1), (1, 1, 1)] = (0, 0, 0)
// [CODE]

void jerusalemcube_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	float scale_large = fjerusalemcube_scale.x;
	float scale_small = fjerusalemcube_scale.y;
	vec3 offset = fjerusalemcube_offset;

	z = rotate3d_point(z, fjerusalemcube_rotation1);

	z = abs(z + fjerusalemcube_abs_add) - fjerusalemcube_abs_minus;
	if (z.x - z.y < 0.0) z.xy = z.yx;
	if (z.z - z.y < 0.0) z.zy = z.yz;

	vec3 z1 = z;
	z1 = z1 * scale_small - offset * (scale_small - 1.0);

	vec3 z2 = z;
	z2 = z2 * scale_large - vec3(offset.x, 0.0, offset.z) * (scale_large - 1.0);

	float d1 = cube_sdf3d(z1, vec3(1.0));
	float d2 = cube_sdf3d(z2, vec3(1.0));

	if (d1 < d2) {
		z = z1;
		dz = dz * abs(scale_small) + 6.0;
	} else {
		z = z2;
		dz = dz * abs(scale_large) + 6.0;
	}

	z = rotate3d_point(z, fjerusalemcube_rotation2);

	z4.xyz = z;
}