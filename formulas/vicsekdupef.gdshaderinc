// [ID]
// Vicsek Dupe F
// [OFFICIAL]
// [LINEAR-DE]
// [KIFS]
// [VARS]
// bool preserve[false, true] = false
// advanced bool hex_fold1[false, true] = false
// advanced selection hex_fold2[Disabled, xz, xy, zx, zy] = Disabled
// advanced bool abs1_x[false, true] = true
// advanced bool abs1_z[false, true] = true
// vec3 limit[(-1, -1, -1), (1, 1, 1)] = (0, 0, 0)
// advanced vec3 abs2_minus[(0, 0, 0), (2, 2, 2)] = (0, 0, 0)
// advanced vec3 abs2_plus[(0, 0, 0), (2, 2, 2)] = (0, 0, 0)
// vec3 offset[(-2, -2, -2), (2, 2, 2)] = (1, 1, 1)
// vec2 foldt[(-2, -2), (2, 2)] = (0, 0)
// float scale[1.0, 4.0] = 3.0
// advanced vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// advanced vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// [CODE]
const vec2 fvicsekdupef_pl1 = vec2(-0.5, 0.8657);
const vec2 fvicsekdupef_pl2 = vec2(-0.8657, 0.4);

void vicsekdupef_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	float scale = fvicsekdupef_scale;

	z = rotate3d_point(z, fvicsekdupef_rotation1);

	if (fvicsekdupef_abs1_x) z.x = abs(z.x);
	if (fvicsekdupef_abs1_z) z.z = abs(z.z);

	if (fvicsekdupef_hex_fold1) z.xz -= fvicsekdupef_pl1.xy * 2.0 * min(0.0, dot(z.xz, fvicsekdupef_pl1.xy));

	if (fvicsekdupef_hex_fold2 == 1) z.yz -= fvicsekdupef_pl2 * 2.0 * min(0.0, dot(z.yz, fvicsekdupef_pl2));
	if (fvicsekdupef_hex_fold2 == 2) z.xz -= fvicsekdupef_pl2 * 2.0 * min(0.0, dot(z.xz, fvicsekdupef_pl2));
	if (fvicsekdupef_hex_fold2 == 3) z.zx -= fvicsekdupef_pl2 * 2.0 * min(0.0, dot(z.zx, fvicsekdupef_pl2));
	if (fvicsekdupef_hex_fold2 == 4) z.yx -= fvicsekdupef_pl2 * 2.0 * min(0.0, dot(z.yx, fvicsekdupef_pl2));

	z.xy = fvicsekdupef_foldt.xy - abs(abs(z.xy) - fvicsekdupef_foldt.xy);

	z = abs(z - fvicsekdupef_abs2_minus) - fvicsekdupef_abs2_plus;

	// Compute z1 branch
	vec3 z1 = z;
	if (z1.y < z1.z) z1.yz = z1.zy;
	if (z1.y < z1.x) z1.yx = z1.xy;
	z1 = z1 * scale - vec3(0.0, fvicsekdupef_offset.y, 0.0) * scale / 2.0;

	if (fvicsekdupef_preserve) {
		vec3 dir3 = vec3(1.0, 0.0, 0.0);
		z -= 2.0 * min(0.0, dot(z - (1.0 / 3.0), dir3)) * dir3;
	}

	// Compute z branch
	z = z * scale - fvicsekdupef_offset * scale / 2.0;

	// Combine
	float d1 = cube_sdf3d(z1, vec3(0.5));
	float d2 = cube_sdf3d(z, vec3(0.5));

	z = mix(z, z1, step(d1, d2));

	if (z.x > fvicsekdupef_limit.x * 0.5f) z.x -= fvicsekdupef_limit.x * scale;
	if (z.y > fvicsekdupef_limit.y * 0.5f) z.y -= fvicsekdupef_limit.y;
	if (z.z > fvicsekdupef_limit.z) z.z -= 2.0f * fvicsekdupef_limit.z;

	dz = dz * abs(scale) + 3.0;

	z = rotate3d_point(z, fvicsekdupef_rotation2);

	//de = min(de, hollow_cube_sdf3d(z, vec3(1.0), fvicsekdupef_thickness) * s);
	z4.xyz = z;
}
