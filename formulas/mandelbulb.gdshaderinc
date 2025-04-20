// [ID]
// mandelbulb
// [INDEX]
// 1
// [VARS]
// float phase[0.0, 30.0] = 11.0
// float power[2.0, 16.0] = 8.0
// bool is_julia[false, true] = false
// vec3 julia_c[(-3, -3, -3), (3, 3, 3)] = (1.3, 1.3, 1.3)
// float derivative_bias[0.0, 2.0] = 1.0
// selection number_system[Triplex, Quaternion, Bicomplex] = Triplex
// selection triplex_mode[Positive Z, Negative Z] = Negative Z
// selection quaternion_mode[All Positive, Negative X, Negative Y, Negative Z] = Negative Y
// [CODE]

uniform float fmandelbulb_derivative_bias;
uniform int fmandelbulb_triplex_mode;
uniform int fmandelbulb_quaternion_mode;
uniform float fmandelbulb_power;
uniform float fmandelbulb_phase;
uniform bool fmandelbulb_is_julia;
uniform vec3 fmandelbulb_julia_c;
uniform int fmandelbulb_number_system;

vec3 sphericalReflection3D(vec3 z, float r) {
    // transform the X component using Mobius Cylinder calculation
    float distX = abs(z.x) - r;
    if (z.x > r) {
        z.x = distX - r;
        z.y *= -1.0;
    } else if (z.x < 0.0 - r) {
        z.x = z.x - distX;
        z.y *= -1.0;
    }

    // transform the Z component using similar Mobius Cylinder calculation
    float distZ = abs(z.z) - r;
    if (z.z > r) {
        z.z = distZ - r;
        z.y *= -1.0;  // Flipping y when crossing z boundary as well
    } else if (z.z < 0.0 - r) {
        z.z = z.z - distZ;
        z.y *= -1.0;  // Flipping y when crossing z boundary as well
    }

    return z;
}

vec2 mandelbulb_sdf(vec3 p) {
	vec4 c = vec4(p, 0.0001);
	vec4 z = vec4(p, 0.0001);
	float orbit_trap = 100000.0;
	float r = length(z);
	float dz = 1.0;
	float power = fmandelbulb_power;

    for (int i = 0; i < int(iterations); i++) {
		dz = max(dz * fmandelbulb_derivative_bias, pow(r, power - 1.0) * dz * power + 1.0);

		// Apply the power functions
		if (fmandelbulb_number_system == 0) z.xyz = triplex_pow(z.xyz, power, fmandelbulb_phase, fmandelbulb_triplex_mode == 1 ? -1.0 : 1.0) + c.xyz;
		if (fmandelbulb_number_system == 1) z = quaternion_pow(z, power, fmandelbulb_phase, fmandelbulb_quaternion_mode) + c;
		if (fmandelbulb_number_system == 2) z = bicomplex_pow(z, power) + c;

		r = length(z);
		if (coloring_mode == 0) orbit_trap = min(orbit_trap, dot(z, z));
		else orbit_trap = min(orbit_trap, process_orbit_trap4d(z));
		if (r > escape_radius) break;
	}

	return vec2(0.5 * log(r) * r / dz, orbit_trap);
}