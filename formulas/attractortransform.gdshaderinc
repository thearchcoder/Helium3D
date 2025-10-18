// [ID]
// Attractor Transform
// [DISABLED]
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// float dt[0, 0.2] = 0.01
// float sigma[2, 21] = 10
// float ro[17, 39] = 28
// float beta[1, 5] = 2.66666
// template transform_range
// [CODE]

void attractortransform_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fattractortransform_range)) {
		float dt = fattractortransform_dt;
		float SIGMA = fattractortransform_sigma;
		float RO = fattractortransform_ro;
		float BETA = fattractortransform_beta;
		vec3 p = z4.xyz;

		z4.xyz = vec3(
			p.x + SIGMA * (p.y - p.x) * dt,
			p.y + (p.x * (RO - p.z) - p.y) * dt,
			p.z + (p.x * p.y - BETA * p.z) * dt
		);
	}
}
