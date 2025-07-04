// [ID]
// Quadratic koch
// [OFFICIAL]
// [KIFS]
// [LINEAR-DE]
// [VARS]
// advanced vec2 octahedron_limit[(-2, -2), (2, 2)] = (0.5, 1.0)
// vec3 octahedron_offset[(-2, -2, -2), (2, 2, 2)] = (0, 0, 0)
// advanced vec3 octahedron_offset2[(-2, -2, -2), (2, 2, 2)] = (1, 0, 0)
// vec3 octahedron_[(-2, -2, -2), (2, 2, 2)] = (0, 0, 0)
// vec3 offset[(-2, -2, -2), (2, 2, 2)] = (1, 1, 1)
// vec2 scale[(1, 1), (5, 3)] = (3, 1)
// template kifs_rotation
// simple float abs_offset[-2, 2] = 0
// [CODE]

void quadratickoch_iter(inout vec4 p4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = p4.xyz;
	float scale = fquadratickoch_scale.x;
	float scale_octa = fquadratickoch_scale.y;
	vec3 offset = fquadratickoch_offset;

	z = rotate3d_point(z, fquadratickoch_rotation1);

	if (mod(float(i), 2.0) != 1.0) {
		z = abs(z);
		if (z.x - z.y < 0.0) z.xy = z.yx;
		if (z.x - z.z < 0.0) z.xz = z.zx;
		if (z.z - z.y < 0.0) z.zy = z.yz;

		dz = dz * abs(scale) + 3.0;

		// Compute branches
		vec3 z2 = z * scale - vec3(offset.x, 0.0, 0.0) * (scale - 1.0);
		vec3 z3 = z * scale - vec3(offset * 0.5) * (scale - 1.0);
		vec3 z1 = z * scale - vec3(offset.x * 0.5, 0.0, offset.z * 0.5) * (scale - 1.0);

		// Distance of each branch
		float d1 = cube_sdf3d(z1, vec3(0.5));
		float d2 = cube_sdf3d(z2, vec3(0.5));
		float d3 = cube_sdf3d(z3, vec3(0.5));

		// Combine branches
		vec3 newz = z1;
		if (d1 < d2 && d1 < d3) newz = z1;
		if (d2 < d1 && d2 < d3) newz = z2;
		if (d3 < d1 && d3 < d2) newz = z3;
		z = newz;
	} else {
		z = abs(z - fquadratickoch_abs_offset) + fquadratickoch_abs_offset;
		dz = dz * abs(scale_octa) + 3.0;

		if (z.x - z.y < 0.0) z.xy = z.yx;
		if (z.x - z.z < 0.0) z.xz = z.zx;

		z = z * scale_octa - fquadratickoch_octahedron_offset2 * (scale_octa - 1.0);
		if (z.y > fquadratickoch_octahedron_limit.x) z.y -= fquadratickoch_octahedron_limit.y;
		z += fquadratickoch_octahedron_offset;
	}

	z = rotate3d_point(z, fquadratickoch_rotation2);

	p4.xyz = z;
}
