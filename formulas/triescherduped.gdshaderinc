// [ID]
// Triescher Dupe D
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

void triescherduped_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	float scale = ftriescherduped_scale;
	vec3 offset = ftriescherduped_offset;
	vec3 z = z4.xyz;
	
	z.xy = kalaido(z.xy, ftriescherduped_symmetry, int(mod(float(i), 4.0)));
	z.xz = -z.zx;
	z = ftriescherduped_clamp.x * clamp(z, ftriescherduped_clamp.y, ftriescherduped_clamp.z) - z;
	z = abs(abs(z - ftriescherduped_add.x) - ftriescherduped_add.y);
	if (z.y - z.z < 0.0) z.yz = z.zy;
	if (z.y > z.x) z.yx = z.xy;

	z = z * scale - offset * (scale - 1.0);
	dz = dz * scale + 5.0;

	if (z.y > ftriescherduped_limit.x) z.y -= ftriescherduped_limit.y;
	z.z += ftriescherduped_add.z;
	
	z4.xyz = z;
}
