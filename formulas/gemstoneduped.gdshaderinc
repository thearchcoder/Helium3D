// [ID]
// Gemstone Dupe D
// [OFFICIAL]
// [IFS]
// [VARS]
// float scale[1, 3] = 2
// vec3 clamp[(0, 0, 0), (1, 1, 2)] = (0.1, 1, 1.3)
// vec3 offset[(0, 0, 0), (8, 8, 8)] = (0.7, 0.3, 5.5)
// [CODE]

void gemstoneduped_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = z4.xyz;
	
	if (i == 0) {
		p = abs(p) - fgemstoneduped_clamp.z;
		if (p.x < p.z) p.xz = p.zx;
		if (p.y < p.z) p.yz = p.zy;
		if (p.x < p.y) p.xy = p.yx;
	}

	float r2 = fgemstoneduped_scale / clamp(dot(p, p), fgemstoneduped_clamp.x, fgemstoneduped_clamp.y);
	p = abs(p) * r2;
	p -= fgemstoneduped_offset;
	dz = dz * r2 + 4.0;
	z4.xyz = p;
}