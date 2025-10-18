// [ID]
// Attractor Transform Dupe E
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

void attractortransformdupee_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fattractortransformdupee_range)) {
		float dt = fattractortransformdupee_dt;
		float SIGMA = fattractortransformdupee_sigma;
		float RO = fattractortransformdupee_ro;
		float BETA = fattractortransformdupee_beta;
		vec3 p = z4.xyz;

		z4.xyz = vec3(
			p.x + SIGMA * (p.y - p.x) * dt,
			p.y + (p.x * (RO - p.z) - p.y) * dt,
			p.z + (p.x * p.y - BETA * p.z) * dt
		);
	}
}
