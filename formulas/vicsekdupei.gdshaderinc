// [ID]
// Vicsek Dupe I
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
const vec2 fvicsekdupei_pl1 = vec2(-0.5, 0.8657);
const vec2 fvicsekdupei_pl2 = vec2(-0.8657, 0.4);

void vicsekdupei_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	float scale = fvicsekdupei_scale;

	z = rotate3d_point(z, fvicsekdupei_rotation1);

	if (fvicsekdupei_abs1_x) z.x = abs(z.x);
	if (fvicsekdupei_abs1_z) z.z = abs(z.z);

	if (fvicsekdupei_hex_fold1) z.xz -= fvicsekdupei_pl1.xy * 2.0 * min(0.0, dot(z.xz, fvicsekdupei_pl1.xy));

	if (fvicsekdupei_hex_fold2 == 1) z.yz -= fvicsekdupei_pl2 * 2.0 * min(0.0, dot(z.yz, fvicsekdupei_pl2));
	if (fvicsekdupei_hex_fold2 == 2) z.xz -= fvicsekdupei_pl2 * 2.0 * min(0.0, dot(z.xz, fvicsekdupei_pl2));
	if (fvicsekdupei_hex_fold2 == 3) z.zx -= fvicsekdupei_pl2 * 2.0 * min(0.0, dot(z.zx, fvicsekdupei_pl2));
	if (fvicsekdupei_hex_fold2 == 4) z.yx -= fvicsekdupei_pl2 * 2.0 * min(0.0, dot(z.yx, fvicsekdupei_pl2));

	z.xy = fvicsekdupei_foldt.xy - abs(abs(z.xy) - fvicsekdupei_foldt.xy);

	z = abs(z - fvicsekdupei_abs2_minus) - fvicsekdupei_abs2_plus;

	// Compute z1 branch
	vec3 z1 = z;
	if (z1.y < z1.z) z1.yz = z1.zy;
	if (z1.y < z1.x) z1.yx = z1.xy;
	z1 = z1 * scale - vec3(0.0, fvicsekdupei_offset.y, 0.0) * scale / 2.0;

	if (fvicsekdupei_preserve) {
		vec3 dir3 = vec3(1.0, 0.0, 0.0);
		z -= 2.0 * min(0.0, dot(z - (1.0 / 3.0), dir3)) * dir3;
	}

	// Compute z branch
	z = z * scale - fvicsekdupei_offset * scale / 2.0;

	// Combine
	float d1 = cube_sdf3d(z1, vec3(0.5));
	float d2 = cube_sdf3d(z, vec3(0.5));

	z = mix(z, z1, step(d1, d2));

	if (z.x > fvicsekdupei_limit.x * 0.5f) z.x -= fvicsekdupei_limit.x * scale;
	if (z.y > fvicsekdupei_limit.y * 0.5f) z.y -= fvicsekdupei_limit.y;
	if (z.z > fvicsekdupei_limit.z) z.z -= 2.0f * fvicsekdupei_limit.z;

	dz = dz * abs(scale) + 3.0;

	z = rotate3d_point(z, fvicsekdupei_rotation2);

	//de = min(de, hollow_cube_sdf3d(z, vec3(1.0), fvicsekdupei_thickness) * s);
	z4.xyz = z;
}
