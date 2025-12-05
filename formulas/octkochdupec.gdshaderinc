// [ID]
// Octkoch Dupe C
// [OFFICIAL]
// [IFS]
// [LINEAR-DE]
// [VARS]
// float scale[1, 3] = 2.0
// vec3 offset[(-3, -3, -3), (3, 3, 3)] = (-0.75, 0.25, 0.25)
// vec3 fold[(-3, -3, -3), (3, 3, 3)] = (2, 1, 1)
// bool abs[false, true] = false
// advanced vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// advanced vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// [CODE]

void octkochdupec_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	float scale = foctkochdupec_scale;

	if (i == 0) z *= 3.5;

	z = rotate3d_point(z, foctkochdupec_rotation1);

	z = abs(z);
	if (z.x - z.y < 0.0) z.xy = z.yx;
	if (z.x - z.z < 0.0) z.xz = z.zx;

	z.x = z.x - foctkochdupec_fold.x * (scale - 1.0);
	z.x = (-abs(z.x - foctkochdupec_fold.y) - z.x) + abs(z.x + foctkochdupec_fold.z);
	if (foctkochdupec_abs) z.x = abs(z.x);

	if (z.x - z.y < 0.0) z.xy = z.yx;
	if (z.x - z.z < 0.0) z.xz = z.zx;
	z -= foctkochdupec_offset * (scale - 1.0);
	z *= scale;

	z = rotate3d_point(z, foctkochdupec_rotation2);

	dz *= abs(scale) + 0.25;
	dz += 7.0 * 1.3;
	z4.xyz = z;
}
