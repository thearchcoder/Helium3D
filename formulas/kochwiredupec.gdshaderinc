// [ID]
// Koch wire Dupe C
// [OFFICIAL]
// [KIFS]
// [VARS]
// advanced bool fold1[false, true] = true
// advanced bool fold2[false, true] = true
// advanced bool fold3[false, true] = true
// advanced bool abs_x[false, true] = false
// advanced bool abs_y[false, true] = false
// advanced bool abs_z[false, true] = true
// advanced bool abs2_zx[false, true] = true
// advanced vec3 abs_plus[(-2, -2, -2), (2, 2, 2)] = (0.1, 0.1, 0.1)
// vec3 abs_minus[(-2, -2, -2), (2, 2, 2)] = (0.0, 0.0, 0.0)
// float scale[1.0, 4.0] = 3.0
// float symmetry[1.0, 100.0] = 3.0
// vec3 offset[(-2, -2, -2), (2, 2, 2)] = (1, 0, 0)
// advanced vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// advanced vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// [CODE]

void kochwiredupec_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	if (i == 0) z4 *= 2.0;
	vec3 z = z4.xyz;

	float scale = fkochwiredupec_scale;
	vec3 offset = fkochwiredupec_offset;

	z = rotate3d_point(z, fkochwiredupec_rotation1);

	if (fkochwiredupec_fold1 && z.x - z.z < 0.0) z.xz = z.zx;

	float angle = 3.14159265 / fkochwiredupec_symmetry;
	float theta = atan(z.z, z.x);
	float r = length(z.xz);
	theta = mod(theta + angle, 2.0 * angle) - angle;
	z.xz = vec2(cos(theta), sin(theta)) * r;

	if (fkochwiredupec_abs_x) z.x = abs(z.x + fkochwiredupec_abs_minus.x) - fkochwiredupec_abs_plus.x;
	if (fkochwiredupec_abs_y) z.y = abs(z.y + fkochwiredupec_abs_minus.y) - fkochwiredupec_abs_plus.y;
	if (fkochwiredupec_abs_z) z.z = abs(z.z + fkochwiredupec_abs_minus.z) - fkochwiredupec_abs_plus.z;

	if (fkochwiredupec_abs2_zx) z.xy = abs(z.xy);
	const vec2 pl1 = vec2(-0.5, 0.8657);
	const vec2 pl2 = vec2(-0.8657, 0.4);

	z = abs(z - 0.1);
	vec3 absz = z;
	absz.xz -= vec2(1.0, 0.5);
	absz = abs(absz);

	z = abs(z);
	z = min(absz, z);
	if (fkochwiredupec_fold2 && z.x - z.y < 0.0) z.xy = z.yx;
	if (fkochwiredupec_fold3 && z.x - z.z < 0.0) z.xz = z.zx;

	z = z * scale - offset * (scale - 1.0);

	z = rotate3d_point(z, fkochwiredupec_rotation2);

	dz = dz * abs(scale) + 8.0;
	z4.xyz = z;
}
