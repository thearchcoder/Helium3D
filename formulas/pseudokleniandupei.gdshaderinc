// [ID]
// Pseudoklenian Dupe I
// [OFFICIAL]
// [IFS]
// [VARS]
// vec4 min[(-2, -2, -2, -2), (2, 2, 2, 2)] = (-0.8323, -0.694, -0.5045, 2)
// vec4 max[(-2, -2, -2, -2), (2, 2, 2, 2)] = (1, 1, 1, 1.316)
// float sign[0.0, 0.2] = 0.0
// float scale[1.0, 2.0] = 1.228
// [CODE]

void pseudokleniandupei_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 q = z4.xyz;

	q = 2.0 * clamp(q, fpseudokleniandupei_min.xyz, fpseudokleniandupei_max.xyz) - q;
	q -= sign(q) * fpseudokleniandupei_sign;

	float rp2 = dot(q, q) * fpseudokleniandupei_scale;
	float k1 = max(fpseudokleniandupei_min.w / rp2, 1.0);
	q *= k1;
	dz *= abs(k1);

	z4.xyz = q;
}
