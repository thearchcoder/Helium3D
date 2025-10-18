// [ID]
// Attractor Transform Dupe C
// [DISABLED]
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// float dt[0, 0.2] = 0.01
// float sigma[2, 21] = 10
// float ro[17, 39] = 28
// float beta[1, 5] = 2.66666
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void attractortransformdupec_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fattractortransformdupec_range)) {
		float dt = fattractortransformdupec_dt;
		float SIGMA = fattractortransformdupec_sigma;
		float RO = fattractortransformdupec_ro;
		float BETA = fattractortransformdupec_beta;
		vec3 p = z4.xyz;

		z4.xyz = vec3(
			p.x + SIGMA * (p.y - p.x) * dt,
			p.y + (p.x * (RO - p.z) - p.y) * dt,
			p.z + (p.x * p.y - BETA * p.z) * dt
		);
	}
}
