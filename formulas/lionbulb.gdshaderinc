// [ID]
// Lionbulb
// [OFFICIAL]
// [ESCAPE]
// [VARS]
// float power[1.0, 16.0] = 4.0
// float phase[0.0, 30.0] = 1.815142
// vec3 c[(-2, -2, -2), (2, 2, 2)] = (1.035, -0.317, 0.013)
// bool coral[false, true] = false
// [CODE]

vec3 triplexPow(vec3 z, float phase, float power) {
	float r = length(z);
	float theta = atan(z.y, z.x);
	float phi = acos(z.z / r);
	r = pow(r, power);
	theta *= power;
	phi = phi * power + phase;
	return vec3(r * sin(phi) * cos(theta), r * sin(phi) * sin(theta), r * cos(phi));
}

void lionbulb_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	vec3 c = flionbulb_c;
	float power = flionbulb_power;

	//dz = power * pow(length(z), (power - 1.0) * 0.5) * dz + 2.0;
	dz = max(dz, pow(length(z), power - 1.0) * dz * power + 1.0);

	if (z.z > z.x) z.zx = z.xz;
	if (z.z > z.y) z.zy = z.yz;
	if (z.x > z.y) z.xy = z.yx;
	z.xy = z.yx;
	if (flionbulb_coral) z.xy = -z.xy;

	//z = triplexPow(z, flionbulb_phase, power) + c;
	z = triplex_mul(c, z - triplexPow(z, flionbulb_phase, power));
	//dz = power * pow(length(z), power - 1.0) * dz + 1.0;
	//dz = max(dz * 1.0, pow(length(z), power - 1.0) * dz * power + 1.0);
	z = 2.0 * clamp(z, vec3(0.0), vec3(0.5)) - z;
	z4.xyz = z;
}

//vec2 lionbulb_sdf(vec3 p) {
	//vec3 z = p;
	//vec3 c = flionbulb_c;
	//float r1 = length(c);
	//float theta1 = atan(c.y, c.x);
	//float phi1 = asin(c.z / r1);
	//float orbit_trap = 10000000.0;
	//float r = length(z);
	//float dz = 1.0;
	//float power = flionbulb_power;
//
	//for (int i = 0; i < int(iterations); i++) {
		//dz = power * pow(r, (power - 1.0) * 0.5) * dz + 2.0;
//
		//if (z.z > z.x) z.zx = z.xz;
		//if (z.z > z.y) z.zy = z.yz;
		//if (z.x > z.y) z.xy = z.yx;
		//z.xy = z.yx;
		//if (flionbulb_coral) z.xy = -z.xy;
//
		//z = triplex_mul(c, z - triplexPow(z, flionbulb_phase, power), r1, theta1, phi1);
		//z = 2.0 * clamp(z, vec3(0.0), vec3(0.5)) - z;
//
		//r = length(z);
//
		//if (coloring_mode == 0 && i > color_min_iterations && i < color_max_iterations) orbit_trap = min(orbit_trap, r);
		//else orbit_trap = min(orbit_trap, process_orbit_trap(z, i));
//
		//if (r > escape_radius) break;
	//}
//
	//return vec2(0.5 * log(r) * sqrt(r) / dz, orbit_trap);
//}