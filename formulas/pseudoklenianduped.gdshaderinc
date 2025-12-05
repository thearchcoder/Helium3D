// [ID]
// Pseudoklenian Dupe D
// [OFFICIAL]
// [IFS]
// [VARS]
// vec4 min[(-2, -2, -2, -2), (2, 2, 2, 2)] = (-0.8323, -0.694, -0.5045, 2)
// vec4 max[(-2, -2, -2, -2), (2, 2, 2, 2)] = (1, 1, 1, 1.316)
// float sign[0.0, 0.2] = 0.0
// float scale[1.0, 2.0] = 1.228
// [CODE]

void pseudoklenianduped_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 q = z4.xyz;

	q = 2.0 * clamp(q, fpseudoklenianduped_min.xyz, fpseudoklenianduped_max.xyz) - q;
	q -= sign(q) * fpseudoklenianduped_sign;

	float rp2 = dot(q, q) * fpseudoklenianduped_scale;
	float k1 = max(fpseudoklenianduped_min.w / rp2, 1.0);
	q *= k1;
	dz *= abs(k1);

	z4.xyz = q;
}
