// [ID]
// Klenian
// [INDEX]
// 11
// [VARS]
// bool show_balls[false, true] = true
// float x[0.0, 3.0] = 1.8
// float y[0.0, 3.0] = 1.8
// float box_size_x[0.0, 2.0] = 1.0
// float box_size_z[0.0, 2.0] = 1.0
// [CODE]
uniform bool fklenian_show_balls;
uniform float fklenian_x;
uniform float fklenian_y;
uniform float fklenian_box_size_x;
uniform float fklenian_box_size_z;

vec2 wrap(vec2 x, vec2 a, vec2 s){
	x -= s;
	return (x - a * floor(x / a)) + s;
}

void klenian_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i, inout float DF, inout float a, inout float b, inout float f, inout vec3 llz, inout vec3 lz, inout bool escaped) {
	vec3 z = z4.xyz;
	float KleinR = fklenian_x;
	float KleinI = fklenian_y;

	if (i == 0) z += vec3(0.9, 0.8, 0.0);

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

	if (dot(z - llz, z - llz) < 1e-5) { escaped = true; return; }

	llz = lz;
	lz = z;
	z4.xyz = z;

	//float y = min(z.y, a-z.y);
	//float DE = min(y, 0.3) / max(DF, 2.0);
}

//vec2 klenian_sdf(vec3 z, float DF, float a, float b, float f) {
	//float KleinR = fklenian_x;
	//float KleinI = fklenian_y;
	//z += vec3(0.9, 0.8, 0.0);
//
	//vec3 lz = z + vec3(1.0);
	//vec3 llz = z + vec3(-1.0);
//
	//float DF = 1.0;
	//float a = KleinR;
	//float b = KleinI;
	//float f = sign(b);
    //float orbit_trap = 10000.0;
//
	//for (int i = 0; i < iterations; i++) {
		//z.x += b / a * z.y;
		//z.xz = wrap(z.xz, vec2(2.0 * fklenian_box_size_x, 2.0 * fklenian_box_size_z), vec2(-fklenian_box_size_x, -fklenian_box_size_z));
		//z.x = z.x - b / a * z.y;
//
		//if (z.y >= a * 0.5 + f *(2.*a-1.95)/4. * sign(z.x + b * 0.5)* (1. - exp(-(7.2-(1.95-a)*15.)* abs(z.x + b * 0.5))))	{
			//z = vec3(-b, a, 0.) - z;
		//}
//
		//// Mobius
		//float ir = 1.0 / dot(z,z);
		//z *= -ir;
		//z.x = -b - z.x; z.y = a + z.y;
		//DF *= ir;
//
		//if (coloring_mode == 0 && i > color_min_iterations && i < color_max_iterations) orbit_trap = min(orbit_trap, dot(z, z));
		//else orbit_trap = min(orbit_trap, process_orbit_trap(z, i));
//
		//if (dot(z - llz, z - llz) < 1e-5) break;
//
		//llz = lz;
		//lz = z;
	//}
//
	//float y = min(z.y, a-z.y);
	//float DE = min(y, 0.3) / max(DF, 2.0);
//
	//return vec2(0.5 * DE, orbit_trap);
//}