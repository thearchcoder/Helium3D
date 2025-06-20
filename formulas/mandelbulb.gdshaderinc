// [ID]
// Mandelbulb
// [ESCAPE]
// [INDEX]
// 1
// [VARS]
// float phase[0.0, 30.0] = 13.901
// float power[2.0, 16.0] = 8.0
// advanced float z_mul[-1, 1] = 1
// advanced bool conjugate[false, true] = false
// advanced bool abs_x[false, true] = false
// advanced bool abs_y[false, true] = false
// advanced bool abs_z[false, true] = false
// bool is_julia[false, true] = false
// vec4 julia_c[(-3, -3, -3, -3), (3, 3, 3, 3)] = (0.5, 0.5, 0.5, 0.3)
// advanced float derivative_bias[0.0, 2.0] = 1.0
// advanced selection number_system[Triplex, Quaternion, Bicomplex] = Triplex
// advanced selection quaternion_mode[Negative X, Negative Y] = Negative Y
// [CODE]

void mandelbulb_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	float power = fmandelbulb_power;
	vec4 c = fmandelbulb_is_julia ? fmandelbulb_julia_c : original_z;
	dz = max(dz * fmandelbulb_derivative_bias, pow(length(z), power - 1.0) * dz * power + 1.0);

	if (fmandelbulb_conjugate) {
		if (fmandelbulb_number_system == 0) z.xyz = triplex_conj(z.xyz).xyz;
		else z = quaternion_conj(z); // I assume bicomplex_conj(b) == quaternion_conj(q), no?
	}

	if (fmandelbulb_number_system == 0) z.xyz = triplex_pow(z.xyz, power, fmandelbulb_phase, fmandelbulb_z_mul) + c.xyz;
	if (fmandelbulb_number_system == 1) z = quaternion_pow(z, power, fmandelbulb_phase, fmandelbulb_quaternion_mode) + c;
	if (fmandelbulb_number_system == 2) z = bicomplex_pow(z, power) + c;

	if (fmandelbulb_abs_x) z.x = abs(z.x);
	if (fmandelbulb_abs_y) z.y = abs(z.y);
	if (fmandelbulb_abs_z) z.z = abs(z.z);

	//vec3 limit = vec3(1.0);
	//if (z.y > limit.y) z.y -= 2.0f * limit.y;
	//z.y += 1.0;

	//z.xz = abs(z.xz + 1.0) - abs(z.xz - 1.0) - z.xz;

	//z = clamp(z, -1.0, 1.0) * 2.0 - z;

	//z -= min(z, vec4(0.2)) * 0.2;

	//if (z.x + z.y < 0.0) z.xy = -z.yx;
	//if (z.x + z.z < 0.0) z.xz = -z.zx;
	//if (z.y + z.z < 0.0) z.yz = -z.zy;

	//r = length(z);
	//if (coloring_mode == 0 && i > color_min_iterations && i < color_max_iterations) orbit_trap = min(orbit_trap, dot(z, z));
	//else orbit_trap = min(orbit_trap, process_orbit_trap4d(z, i));
}

//vec2 mandelbulb_sdf(vec3 p) {
	//vec4 c = fmandelbulb_is_julia ? fmandelbulb_julia_c : vec4(p, 0.0001);
	//vec4 z = vec4(p, 0.0001);
	//float orbit_trap = 100000.0;
	//float r = length(z);
	//float dz = 1.0;
//
	//float powers[5];
	//powers[0] = fmandelbulb_power;
	//powers[1] = fmandelbulb_alternating_powers.x;
	//powers[2] = fmandelbulb_alternating_powers.y;
	//powers[3] = fmandelbulb_alternating_powers.z;
	//powers[4] = fmandelbulb_alternating_powers.w;
//
	//int valid_powers[5];
	//int num_valid_powers = 0;
//
	//for (int i = 0; i < 5; i++) {
		//if (powers[i] != 0.0) {
			//valid_powers[num_valid_powers] = i;
			//num_valid_powers++;
		//}
	//}
//
	//for (int i = 0; i < iterations; i++) {
		//int power_idx = valid_powers[int(mod(float(i), float(num_valid_powers)))];
		//float power = powers[power_idx];
//
		//dz = max(dz * fmandelbulb_derivative_bias, pow(r, power - 1.0) * dz * power + 1.0);
//
		//if (fmandelbulb_conjugate) {
			//if (fmandelbulb_number_system == 0) z.xyz = triplex_conj(z.xyz).xyz;
			//else z = quaternion_conj(z); // I assume bicomplex_conj(b) == quaternion_conj(q), no?
		//}
//
		//if (fmandelbulb_abs_x) z.x = abs(z.x);
		//if (fmandelbulb_abs_y) z.y = abs(z.y);
		//if (fmandelbulb_abs_z) z.z = abs(z.z);
//
		//if (fmandelbulb_number_system == 0) z.xyz = triplex_pow(z.xyz, power, fmandelbulb_phase, fmandelbulb_triplex_mode == 1 ? -1.0 : 1.0) + c.xyz;
		//if (fmandelbulb_number_system == 1) z = quaternion_pow(z, power, fmandelbulb_phase, fmandelbulb_quaternion_mode) + c;
		//if (fmandelbulb_number_system == 2) z = bicomplex_pow(z, power) + c;
//
		////vec3 limit = vec3(1.0);
		////if (z.y > limit.y) z.y -= 2.0f * limit.y;
		////z.y += 1.0;
//
		////z.xz = abs(z.xz + 1.0) - abs(z.xz - 1.0) - z.xz;
//
		////z = clamp(z, -1.0, 1.0) * 2.0 - z;
//
		////z -= min(z, vec4(0.2)) * 0.2;
//
		////if (z.x + z.y < 0.0) z.xy = -z.yx;
		////if (z.x + z.z < 0.0) z.xz = -z.zx;
		////if (z.y + z.z < 0.0) z.yz = -z.zy;
//
		//r = length(z);
		//if (coloring_mode == 0 && i > color_min_iterations && i < color_max_iterations) orbit_trap = min(orbit_trap, dot(z, z));
		//else orbit_trap = min(orbit_trap, process_orbit_trap4d(z, i));
//
		//if (r > escape_radius) break;
	//}
//
	//float de = 0.5 * log(r) * r / dz;
	//if (fmandelbulb_number_system == 2) de *= 0.5;
//
	//return vec2(de, orbit_trap);
//}