// [ID]
// Attractor Transform Dupe A
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

void attractortransformdupea_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fattractortransformdupea_range)) {
		float dt = fattractortransformdupea_dt;
		float SIGMA = fattractortransformdupea_sigma;
		float RO = fattractortransformdupea_ro;
		float BETA = fattractortransformdupea_beta;
		vec3 p = z4.xyz;

		z4.xyz = vec3(
			p.x + SIGMA * (p.y - p.x) * dt,
			p.y + (p.x * (RO - p.z) - p.y) * dt,
			p.z + (p.x * p.y - BETA * p.z) * dt
		);
	}
}
