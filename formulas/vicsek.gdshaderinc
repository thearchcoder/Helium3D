// [ID]
// Vicsek
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
// template advanced_kifs_rotation
// [CODE]
const vec2 fvicsek_pl1 = vec2(-0.5, 0.8657);
const vec2 fvicsek_pl2 = vec2(-0.8657, 0.4);

void vicsek_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	float scale = fvicsek_scale;

	z = rotate3d_point(z, fvicsek_rotation1);

	if (fvicsek_abs1_x) z.x = abs(z.x);
	if (fvicsek_abs1_z) z.z = abs(z.z);

	if (fvicsek_hex_fold1) z.xz -= fvicsek_pl1.xy * 2.0 * min(0.0, dot(z.xz, fvicsek_pl1.xy));

	if (fvicsek_hex_fold2 == 1) z.yz -= fvicsek_pl2 * 2.0 * min(0.0, dot(z.yz, fvicsek_pl2));
	if (fvicsek_hex_fold2 == 2) z.xz -= fvicsek_pl2 * 2.0 * min(0.0, dot(z.xz, fvicsek_pl2));
	if (fvicsek_hex_fold2 == 3) z.zx -= fvicsek_pl2 * 2.0 * min(0.0, dot(z.zx, fvicsek_pl2));
	if (fvicsek_hex_fold2 == 4) z.yx -= fvicsek_pl2 * 2.0 * min(0.0, dot(z.yx, fvicsek_pl2));

	z.xy = fvicsek_foldt.xy - abs(abs(z.xy) - fvicsek_foldt.xy);

	z = abs(z - fvicsek_abs2_minus) - fvicsek_abs2_plus;

	// Compute z1 branch
	vec3 z1 = z;
	if (z1.y < z1.z) z1.yz = z1.zy;
	if (z1.y < z1.x) z1.yx = z1.xy;
	z1 = z1 * scale - vec3(0.0, fvicsek_offset.y, 0.0) * scale / 2.0;

	if (fvicsek_preserve) {
		vec3 dir3 = vec3(1.0, 0.0, 0.0);
		z -= 2.0 * min(0.0, dot(z - (1.0 / 3.0), dir3)) * dir3;
	}

	// Compute z branch
	z = z * scale - fvicsek_offset * scale / 2.0;

	// Combine
	float d1 = cube_sdf3d(z1, vec3(0.5));
	float d2 = cube_sdf3d(z, vec3(0.5));

	z = mix(z, z1, step(d1, d2));

	if (z.x > fvicsek_limit.x * 0.5f) z.x -= fvicsek_limit.x * scale;
	if (z.y > fvicsek_limit.y * 0.5f) z.y -= fvicsek_limit.y;
	if (z.z > fvicsek_limit.z) z.z -= 2.0f * fvicsek_limit.z;

	dz = dz * abs(scale) + 3.0;

	z = rotate3d_point(z, fvicsek_rotation2);

	//de = min(de, hollow_cube_sdf3d(z, vec3(1.0), fvicsek_thickness) * s);
	z4.xyz = z;
}
