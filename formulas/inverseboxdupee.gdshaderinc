// [ID]
// Inverse Box Dupe E
// [OFFICIAL]
// [DIFS]
// [DESCRIPTION]
// Implementation 100% by me (TheArchCoder),
// But the idea was taken from https://www.youtube.com/watch?v=0jwkZKDOzfc&t=357s
// [VARS]
// float scale[2, 4] = 3
// float thickness[0, 0.01] = 0
// vec3 offset[(-2, -2, -2), (2, 2, 2)] = (0.85, 0.85, 0.85)
// [CODE]

vec2 inverseboxdupee_sdf(vec4 z4d) {
	vec3 z = z4d.xyz;
	float scale = finverseboxdupee_scale;
	float d = 10000.0;
	vec3 p = z;

	for (int i = 0; i < iterations; i++) {
		d = min(d, (length(z) - 1.0) * pow(1.0 / scale, float(i)));
		z = abs(z);
		if (z.y > z.x) z.yx = z.xy;
		if (z.z > z.y) z.zy = z.yz;

		if (z.z * scale > 0.5 * finverseboxdupee_offset.z * (scale - 1.0)) {
			z *= scale;
			z -= finverseboxdupee_offset * (scale - 1.0);
		} else {
			z *= scale;
			z -= vec3(finverseboxdupee_offset.x, finverseboxdupee_offset.y, 0) * (scale - 1.0);
		}
	}

	return vec2(max(cube_sdf3d(p, finverseboxdupee_offset), -d) - finverseboxdupee_thickness, 0.0);
}