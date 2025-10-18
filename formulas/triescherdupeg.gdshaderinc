// [ID]
// Triescher Dupe G
// [OFFICIAL]
// [IFS]
// [VARS]
// float scale[2, 4] = 3
// vec3 offset[(0, 0, 0), (1.5, 1.5, 1.5)] = (0.7983, 0.626, 0.0)
// advanced vec3 clamp[(1, 0, 0), (3, 1, 1)] = (2, 0.1, 0.3)
// advanced vec3 add[(0, 0, 0), (0.8, 0.8, 0.8)] = (0.3, 0.3, 0.3)
// vec2 limit[(0, 0.5), (1, 2)] = (0.5, 1)
// float symmetry[1, 8] = 3
// [CODE]

void triescherdupeg_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	float scale = ftriescherdupeg_scale;
	vec3 offset = ftriescherdupeg_offset;
	vec3 z = z4.xyz;
	
	z.xy = kalaido(z.xy, ftriescherdupeg_symmetry, int(mod(float(i), 4.0)));
	z.xz = -z.zx;
	z = ftriescherdupeg_clamp.x * clamp(z, ftriescherdupeg_clamp.y, ftriescherdupeg_clamp.z) - z;
	z = abs(abs(z - ftriescherdupeg_add.x) - ftriescherdupeg_add.y);
	if (z.y - z.z < 0.0) z.yz = z.zy;
	if (z.y > z.x) z.yx = z.xy;

	z = z * scale - offset * (scale - 1.0);
	dz = dz * scale + 5.0;

	if (z.y > ftriescherdupeg_limit.x) z.y -= ftriescherdupeg_limit.y;
	z.z += ftriescherdupeg_add.z;
	
	z4.xyz = z;
}
