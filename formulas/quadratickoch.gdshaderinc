// [ID]
// Quadratic koch
// [INDEX]
// 16
// [VARS]
// selection variant[Quadratic, Octahedral, Octahedral 2, Octahedral 3] = Quadratic
// float scale_octa[1, 3] = 2
// float scale[1, 5] = 3
// [CODE]

uniform int fquadratickoch_variant;
uniform float fquadratickoch_scale;
uniform float fquadratickoch_scale_octa;

void quadratickoch_iter(inout vec4 p4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = p4.xyz;
	float scale = fquadratickoch_scale;
	float scale_octa = fquadratickoch_scale_octa;

	if (mod(float(i), 2.0) != 1.0 || fquadratickoch_variant == 0) {
		z = abs(z);
		if (z.x - z.y < 0.0) z.xy = z.yx;
		if (z.x - z.z < 0.0) z.xz = z.zx;
		if (z.z - z.y < 0.0) z.zy = z.yz;
		
		dz = dz * abs(scale) + 3.0;
		
		// Compute branches
		vec3 z2 = z * fquadratickoch_scale - vec3(1.0, 0.0, 0.0) * (fquadratickoch_scale - 1.0);
		vec3 z3 = z * fquadratickoch_scale - vec3(0.5, 0.5, 0.5) * (fquadratickoch_scale - 1.0);
		vec3 z1 = z * fquadratickoch_scale - vec3(0.5, 0.0, 0.5) * (fquadratickoch_scale - 1.0);
		// Distance of each branch
		float d1 = cube_sdf3d(z1, vec3(0.5));
		float d2 = cube_sdf3d(z2, vec3(0.5));
		float d3 = cube_sdf3d(z3, vec3(0.5));

		// Combine branches
		vec3 newz = z1;
		if (d1 < d2 && d1 < d3) newz = z1;
		if (d2 < d1 && d2 < d3) newz = z2;
		if (d3 < d1 && d3 < d2) newz = z3;
		z = newz;
	} else {
		if (fquadratickoch_variant == 1 || fquadratickoch_variant == 3) z = abs(z - 0.1) + 0.1;
		else if (fquadratickoch_variant == 2) z = abs(z);

		dz = dz * abs(scale_octa) + 3.0;

		if (z.x - z.y < 0.0) z.xy = z.yx;
        if (z.x - z.z < 0.0 && fquadratickoch_variant == 3) z.xz = z.zx;

		z = z * scale_octa - vec3(1.0, 0.0, 0.0) * (scale_octa - 1.0);

		if (z.y > 0.5) z.y -= 1.0;
	}

	p4.xyz = z;
}

//vec2 quadratickoch_sdf(vec3 z) {
	//float orbit_trap = 1.0;
	//z /= 2.0;
//
	//for (int i = 0; i < iterations; i++) {
		//if (mod(float(i), 2.0) != 1.0 || fquadratickoch_variant == 0) {
			//z = abs(z);
			//if (z.x - z.y < 0.0) z.xy = z.yx;
			//if (z.x - z.z < 0.0) z.xz = z.zx;
			//if (z.z - z.y < 0.0) z.zy = z.yz;
//
			////z.x -= power;
			////z.y -= power;
			////z.z -= power;
//
			//// Compute branches
			//vec3 z2 = z * 3.0 - vec3(1.0, 0.0, 0.0) * (3.0 - 1.0);
			//vec3 z3 = z * 3.0 - vec3(0.5, 0.5, 0.5) * (3.0 - 1.0);
			//vec3 z1 = z * 3.0 - vec3(0.5, 0.0, 0.5) * (3.0 - 1.0);
			//// Distance of each branch
			//float d1 = cube_sdf3d(z1, vec3(0.5));
			//float d2 = cube_sdf3d(z2, vec3(0.5));
			//float d3 = cube_sdf3d(z3, vec3(0.5));
//
			//// Combine branches
			//vec3 newz = z1;
			//if (d1 < d2 && d1 < d3) newz = z1;
			//if (d2 < d1 && d2 < d3) newz = z2;
			//if (d3 < d1 && d3 < d2) newz = z3;
			//z = newz;
		//} else {
			//if (fquadratickoch_variant == 1 || fquadratickoch_variant == 3) z = abs(z - 0.1) + 0.1;
			//else if (fquadratickoch_variant == 2) z = abs(z);
//
			//if (z.x - z.y < 0.0) z.xy = z.yx;
            //if (z.x - z.z < 0.0 && fquadratickoch_variant == 3) z.xz = z.zx;
//
			//z = z * 2.0 - vec3(1.0, 0.0, 0.0) * (2.0 - 1.0);
//
			//if (z.y > 0.5) z.y -= 1.0;
		//}
//
		//if (coloring_mode == 0 && i > color_min_iterations && i < color_max_iterations) orbit_trap = min(orbit_trap, dot(z, z));
		//else orbit_trap = min(orbit_trap, process_orbit_trap(z, i));
	//}
//
	//float factor = fquadratickoch_variant == 0 ? 3.0 : 2.5;
	//float d = cube_sdf3d(z, vec3(0.5)) * pow(1.0 / factor, float(iterations));
	//return vec2(0.6 * d, orbit_trap);
//}
