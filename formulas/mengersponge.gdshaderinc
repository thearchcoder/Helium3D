// [ID]
// Mengersponge
// [OFFICIAL]
// [KIFS]
// [LINEAR-DE]
// [VARS]
// vec3 offset[(0, 0, 0), (2.5, 2.5, 2.5)] = (1, 1, 1)
// template kifs_rotation
// float scale[2.0, 4.0] = 3.0
// [CODE]

void mengersponge_iter(inout vec4 p4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = p4.xyz;
	float scale = fmengersponge_scale;

	p = rotate3d_point(p, fmengersponge_rotation1);

	p = abs(p);
	if (p.x < p.y) p.xy = p.yx;
	if (p.x < p.z) p.xz = p.zx;
	if (p.y < p.z) p.zy = p.yz;

	p.z -= 0.5 * fmengersponge_offset.z * (scale - 1.0) / scale;
	p.z = -abs(p.z);
	p.z += 0.5 * fmengersponge_offset.z * (scale - 1.0) / scale;

	p *= scale;
	dz = dz * abs(scale) + 2.0;

	p.x -= fmengersponge_offset.x * (scale - 1.0);
	p.y -= fmengersponge_offset.y * (scale - 1.0);

	p = rotate3d_point(p, fmengersponge_rotation2);

	p4.xyz = p;
}
