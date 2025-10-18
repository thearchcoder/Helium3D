// [ID]
// Wavy sponge Dupe C
// [OFFICIAL]
// [IFS]
// [VARS]
// float scale[1.0, 2.0] = 1.88
// vec3 clamp[(2, 0, 0), (3, 2, 2)] = (2, 1, 1)
// vec3 offset[(0, 0, 0), (2, 2, 2)] = (1, 0.6, 0)
// [CODE]

void wavyspongedupec_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	float scale = fwavyspongedupec_scale;
	vec3 offset = fwavyspongedupec_offset;

	if (i == 0) z *= 2.0;

	z = abs(z);
	if (z.x + z.y < 0.0) z.xy = -z.yx;
	if (z.x + z.z < 0.0) z.xz = -z.zx;
	if (z.x - z.y < 0.0) z.xy = z.yx;
	if (z.z - z.x < 0.0) z.zx = z.xz;
	
	z = z * scale - offset * (scale - 1.0);
	dz = dz * abs(scale) + 8.0;
	z = fwavyspongedupec_clamp.x * clamp(z, vec3(fwavyspongedupec_clamp.y), vec3(fwavyspongedupec_clamp.z)) - z;
	
	z4.xyz = z;
}
