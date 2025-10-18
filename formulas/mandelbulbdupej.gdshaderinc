// [ID]
// Mandelbulb Dupe J
// [OFFICIAL]
// [ESCAPE]
// [VARS]
// float phase[0.0, 34.5575] = 13.90
// float power[2.0, 16.0] = 8.0001
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

void mandelbulbdupej_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	float power = fmandelbulbdupej_power;
	vec4 c = fmandelbulbdupej_is_julia ? fmandelbulbdupej_julia_c : original_z;
	dz = max(dz * fmandelbulbdupej_derivative_bias, pow(length(z), power - 1.0) * dz * power + 1.0);

	if (fmandelbulbdupej_conjugate) {
		if (fmandelbulbdupej_number_system == 0) z.xyz = triplex_conj(z.xyz).xyz;
		else z = quaternion_conj(z); // I assume bicomplex_conj(b) == quaternion_conj(q), no?
	}

	if (fmandelbulbdupej_abs_x) z.x = abs(z.x);
	if (fmandelbulbdupej_abs_y) z.y = abs(z.y);
	if (fmandelbulbdupej_abs_z) z.z = abs(z.z);
	
	if (fmandelbulbdupej_number_system == 0) z.xyz = triplex_pow(z.xyz, power, fmandelbulbdupej_phase, fmandelbulbdupej_z_mul) + c.xyz;
	if (fmandelbulbdupej_number_system == 1) z = quaternion_pow(z, power, fmandelbulbdupej_phase, fmandelbulbdupej_quaternion_mode) + c;
	if (fmandelbulbdupej_number_system == 2) z = bicomplex_pow(z, power) + c;

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
