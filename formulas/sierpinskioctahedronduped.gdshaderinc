// [ID]
// Sierpinski octahedron Dupe D
// [OFFICIAL]
// [KIFS]
// [VARS]
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 offset[(-2, -2, -2), (2, 2, 2)] = (1, 0, 0)
// float scale[1.0, 3.0] = 2.0
// [CODE]

void sierpinskioctahedronduped_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	float scale = fsierpinskioctahedronduped_scale;
	vec3 offset = fsierpinskioctahedronduped_offset;
	z = rotate3d_point(z, fsierpinskioctahedronduped_rotation1);

	z = abs(z);
	if (z.x - z.y < 0.0) z.xy = z.yx;
	if (z.x - z.z < 0.0) z.xz = z.zx;

	z = z * scale - offset * (scale - 1.0);
	dz = dz * abs(scale) + 1.0;

	z = rotate3d_point(z, fsierpinskioctahedronduped_rotation2);
	z4.xyz = z;
}
