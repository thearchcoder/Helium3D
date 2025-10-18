// [ID]
// Lionbulb Dupe G
// [OFFICIAL]
// [ESCAPE]
// [VARS]
// float power[1.0, 16.0] = 4.0
// float phase[0.0, 30.0] = 1.815142
// vec3 c[(-2, -2, -2), (2, 2, 2)] = (1.035, -0.317, 0.013)
// bool coral[false, true] = false
// [CODE]

vec3 lionbulbdupeg_triplex_pow(vec3 z, float phase, float power) {
	float r = length(z);
	float theta = atan(z.y, z.x);
	float phi = acos(z.z / r);
	r = pow(r, power);
	theta *= power;
	phi = phi * power + phase;
	return vec3(r * sin(phi) * cos(theta), r * sin(phi) * sin(theta), r * cos(phi));
}

void lionbulbdupeg_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	vec3 c = flionbulbdupeg_c;
	float power = flionbulbdupeg_power;

	//dz = power * pow(length(z), (power - 1.0) * 0.5) * dz + 2.0;
	dz = max(dz, pow(length(z), power - 1.0) * dz * power + 1.0);

	if (z.z > z.x) z.zx = z.xz;
	if (z.z > z.y) z.zy = z.yz;
	if (z.x > z.y) z.xy = z.yx;
	z.xy = z.yx;
	if (flionbulbdupeg_coral) z.xy = -z.xy;

	//z = lionbulbdupeg_triplex_pow(z, flionbulbdupeg_phase, power) + c;
	z = triplex_mul(c, z - lionbulbdupeg_triplex_pow(z, flionbulbdupeg_phase, power));
	//dz = power * pow(length(z), power - 1.0) * dz + 1.0;
	//dz = max(dz * 1.0, pow(length(z), power - 1.0) * dz * power + 1.0);
	z = 2.0 * clamp(z, vec3(0.0), vec3(0.5)) - z;
	z4.xyz = z;
}
