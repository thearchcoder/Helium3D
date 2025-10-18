// [ID]
// Triescher Dupe F
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

void triescherdupef_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	float scale = ftriescherdupef_scale;
	vec3 offset = ftriescherdupef_offset;
	vec3 z = z4.xyz;
	
	z.xy = kalaido(z.xy, ftriescherdupef_symmetry, int(mod(float(i), 4.0)));
	z.xz = -z.zx;
	z = ftriescherdupef_clamp.x * clamp(z, ftriescherdupef_clamp.y, ftriescherdupef_clamp.z) - z;
	z = abs(abs(z - ftriescherdupef_add.x) - ftriescherdupef_add.y);
	if (z.y - z.z < 0.0) z.yz = z.zy;
	if (z.y > z.x) z.yx = z.xy;

	z = z * scale - offset * (scale - 1.0);
	dz = dz * scale + 5.0;

	if (z.y > ftriescherdupef_limit.x) z.y -= ftriescherdupef_limit.y;
	z.z += ftriescherdupef_add.z;
	
	z4.xyz = z;
}
