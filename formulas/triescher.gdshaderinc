// [ID]
// Triescher
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

void triescher_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	float scale = ftriescher_scale;
	vec3 offset = ftriescher_offset;
	vec3 z = z4.xyz;
	
	z.xy = kalaido(z.xy, ftriescher_symmetry, int(mod(float(i), 4.0)));
	z.xz = -z.zx;
	z = ftriescher_clamp.x * clamp(z, ftriescher_clamp.y, ftriescher_clamp.z) - z;
	z = abs(abs(z - ftriescher_add.x) - ftriescher_add.y);
	if (z.y - z.z < 0.0) z.yz = z.zy;
	if (z.y > z.x) z.yx = z.xy;

	z = z * scale - offset * (scale - 1.0);
	dz = dz * scale + 5.0;

	if (z.y > ftriescher_limit.x) z.y -= ftriescher_limit.y;
	z.z += ftriescher_add.z;
	
	z4.xyz = z;
}
