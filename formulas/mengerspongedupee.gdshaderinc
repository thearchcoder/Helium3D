// [ID]
// Mengersponge Dupe E
// [OFFICIAL]
// [KIFS]
// [LINEAR-DE]
// [VARS]
// vec3 offset[(0, 0, 0), (2.5, 2.5, 2.5)] = (1, 1, 1)
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// float scale[2.0, 4.0] = 3.0
// [CODE]

void mengerspongedupee_iter(inout vec4 p4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = p4.xyz;
	float scale = fmengerspongedupee_scale;

	p = rotate3d_point(p, fmengerspongedupee_rotation1);

	p = abs(p);
	if (p.x < p.y) p.xy = p.yx;
	if (p.x < p.z) p.xz = p.zx;
	if (p.y < p.z) p.zy = p.yz;

	p.z -= 0.5 * fmengerspongedupee_offset.z * (scale - 1.0) / scale;
	p.z = -abs(p.z);
	p.z += 0.5 * fmengerspongedupee_offset.z * (scale - 1.0) / scale;

	p *= scale;
	dz = dz * abs(scale) + 2.0;

	p.x -= fmengerspongedupee_offset.x * (scale - 1.0);
	p.y -= fmengerspongedupee_offset.y * (scale - 1.0);

	p = rotate3d_point(p, fmengerspongedupee_rotation2);

	p4.xyz = p;
}
