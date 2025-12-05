// [ID]
// Sierpinski tetrahedron Dupe E
// [OFFICIAL]
// [KIFS]
// [VARS]
// vec3 offset[(-1, -1, -1), (1, 1, 1)] = (1, 1, 1)
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// float scale[1.0, 3.0] = 2.0
// [CODE]

void sierpinskitetrahedrondupee_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	float scale = fsierpinskitetrahedrondupee_scale;
	vec3 offset = fsierpinskitetrahedrondupee_offset;

	z = rotate3d_point(z, fsierpinskitetrahedrondupee_rotation1);

	if (z.x + z.y < 0.0) z.xy = -z.yx;
	if (z.x + z.z < 0.0) z.xz = -z.zx;
	if (z.y + z.z < 0.0) z.zy = -z.yz;

	z = z * scale - offset * (scale - 1.0);
	dz = dz * abs(scale) + 1.0;

	z = rotate3d_point(z, fsierpinskitetrahedrondupee_rotation2);
	z4.xyz = z;
}
