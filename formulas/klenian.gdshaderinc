// [ID]
// Klenian
// [INDEX]
// 11
// [VARS]
// float x[0.0, 3.0] = 1.8
// float y[0.0, 3.0] = 1.8
// float box_size_x[0.0, 2.0] = 1.0
// float box_size_z[0.0, 2.0] = 1.0
// float slice_start[-2.0, 2.0] = -1.0
// float slice_end[-2.0, 2.0] = 1.0
// float fractal_size[0.5, 2.0] = 1.1
// bool sphere_inversion[false, true] = true
// vec4 inversion_sphere[(-2, -2, -2, -2), (2, 2, 2, 2)] = (1.0, 0.96, 0.0, 0.8)
// [CODE]
uniform float fklenian_x = 1.8;
uniform float fklenian_y = 1.8;
uniform float fklenian_box_size_x = 1.0;
uniform float fklenian_box_size_z = 1.0;
uniform float fklenian_slice_start = -1.0;
uniform float fklenian_slice_end = 1.0;
uniform float fklenian_fractal_size = 1.1;
uniform bool fklenian_sphere_inversion = true;
uniform vec4 fklenian_inversion_sphere = vec4(1.0, 0.96, 0.0, 0.8);

vec2 wrap(vec2 x, vec2 a, vec2 s){
	x -= s;
	return (x - a * floor(x / a)) + s;
}

vec2 klenian_sdf(vec3 z) {
	float KleinR = fklenian_x;
	float KleinI = fklenian_y;

	z /= fklenian_fractal_size;
	z += vec3(0.9, 0.8, 0.0);

	vec3 lz = z + vec3(1.0);
	vec3 llz = z + vec3(-1.0);
	float d = 0.0;
	float d2 = 0.0;

    if (fklenian_sphere_inversion) {
		z -= fklenian_inversion_sphere.xyz;
		d = length(z);
		d2 = d * d;
		z = (fklenian_inversion_sphere.w * fklenian_inversion_sphere.w / d2) * z;
		z += fklenian_inversion_sphere.xyz;
    }

	float DF = 1.0;
	float a = KleinR;
    float b = KleinI;
	float f = sign(b);
    float orbit_trap = 10000.0;

	for (int i = 0; i < iterations; i++) {
		z.x += b / a * z.y;
		z.xz = wrap(z.xz, vec2(2.0 * fklenian_box_size_x, 2.0 * fklenian_box_size_z), vec2(-fklenian_box_size_x, -fklenian_box_size_z));
		z.x = z.x - b / a * z.y;

		if (z.y >= a * 0.5 + f *(2.*a-1.95)/4. * sign(z.x + b * 0.5)* (1. - exp(-(7.2-(1.95-a)*15.)* abs(z.x + b * 0.5))))	{
			z = vec3(-b, a, 0.) - z;
		}

		// Mobius
		float ir = 1.0 / dot(z,z);
		z *= -ir;
		z.x = -b - z.x; z.y = a + z.y;
		DF *= ir;

		if (coloring_mode == 0) orbit_trap = min(orbit_trap, dot(z, z));
		else orbit_trap = min(orbit_trap, process_orbit_trap(z));

		if (dot(z - llz, z - llz) < 1e-5) break;

		llz = lz;
		lz = z;
	}

	float y =  min(z.y, a-z.y) ;
	float DE = min(y, 0.3) / max(DF, 2.0);

	if (fklenian_sphere_inversion) DE = DE * d2 / (fklenian_inversion_sphere.w + d * DE);

	return vec2(0.5 * fklenian_fractal_size * DE, orbit_trap);
}