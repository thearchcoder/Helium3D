// [ID]
// Klenian Dupe D
// [OFFICIAL]
// [DIFS]
// [VARS]
// bool show_balls[false, true] = true
// float x[0.0, 3.0] = 1.8
// float y[0.0, 3.0] = 1.8
// float box_size_x[0.0, 2.0] = 1.0
// float box_size_z[0.0, 2.0] = 1.0
// [CODE]

void klenianduped_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i, inout float DF, inout float a, inout float b, inout float f, inout vec3 llz, inout vec3 lz, inout bool escaped) {
	vec3 z = z4.xyz;
	float KleinR = fklenianduped_x;
	float KleinI = fklenianduped_y;

	if (i == 0) z += vec3(0.9, 0.8, 0.0);

	z.x += b / a * z.y;
	z.xz = wrap(z.xz, vec2(2.0 * fklenianduped_box_size_x, 2.0 * fklenianduped_box_size_z), vec2(-fklenianduped_box_size_x, -fklenianduped_box_size_z));
	z.x = z.x - b / a * z.y;

	if (z.y >= a * 0.5 + f *(2.*a-1.95)/4. * sign(z.x + b * 0.5)* (1. - exp(-(7.2-(1.95-a)*15.)* abs(z.x + b * 0.5))))	{
		z = vec3(-b, a, 0.) - z;
	}

	// Mobius
	float ir = 1.0 / dot(z,z);
	z *= -ir;
	z.x = -b - z.x; z.y = a + z.y;
	DF *= ir;

	if (dot(z - llz, z - llz) < 1e-5) { escaped = true; return; }

	llz = lz;
	lz = z;
	z4.xyz = z;
}

vec2 klenianduped_sdf(vec4 z4) {
	vec4 z = z4;
	vec4 original_z = z;

	// kleinian precompute
	vec3 lz = z.xyz + vec3(1.0);
	vec3 llz = z.xyz + vec3(-1.0);
	float DF = 1.0;
	float a = fklenianduped_x;
	float b = fklenianduped_y;
	float f = sign(b);
	float dz = 1.0;
	float orbit = 100000.0;

	for (int i = 0; i < iterations; i++) {
		bool escaped = false;
		klenianduped_iter(z, dz, original_z, orbit, i, DF, a, b, f, llz, lz, escaped);
		if (escaped) break;
	}

	float de = min(fklenianduped_show_balls ? min(z.y, a - z.y) : z.y, 0.3) / max(DF, 2.0);
	return vec2(de * 0.5, 0.0);
}
