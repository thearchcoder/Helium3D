// [ID]
// Kali living Dupe C
// [OFFICIAL]
// [KIFS]
// [VARS]
// vec3 c[(-2, -2, -2), (2, 2, 2)] = (-0.088, -1.035, 0.570)
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (1, 1, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (1.6, 0, 0)
// float scale[1.0, 3.0] = 1.15
// [CODE]

void kalilivingdupec_iter(inout vec4 p4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = p4.xyz;

	if (i == 0) {
		//p *= 14.0;
		p = p.zxy;
		p.x *= 0.75;
	}

	float scale = fkalilivingdupec_scale;
	vec3 c = fkalilivingdupec_c;
	p = rotate3d_point(p, fkalilivingdupec_rotation1);

	p.xy = abs(p.xy);
	p = p * scale + c;
	dz = dz * abs(scale) + 1.0;

	p = rotate3d_point(p, fkalilivingdupec_rotation2);
	p4.xyz = p;
}

//vec2 kalilivingdupec_sdf(vec3 p) {
	//p *= 14.0;
	//p = p.zxy;
	//p.x *= 0.75;
//
	//float scale = fkalilivingdupec_scale;
	//float orbit_trap = 100000.0;
	//vec3 z = p;
	//vec3 c = fkalilivingdupec_c;
	//float r;
//
	//for (int i = 0; i < iterations; i++) {
		//p = rotate3d_point(p, fkalilivingdupec_rotation1);
//
		//p.xy = abs(p.xy);
		//p = p * scale + c;
		//r = length(p);
//
		//p = rotate3d_point(p, fkalilivingdupec_rotation2);
//
		//if (coloring_mode == 0 && i > color_min_iterations && i < color_max_iterations) orbit_trap = min(orbit_trap, length(p.x));
		//else orbit_trap = min(orbit_trap, process_orbit_trap(p, i));
	//}
//
	//float d = r * pow(scale, -float(iterations)) - 0.1;
	//return vec2(d / 14.0, orbit_trap);
//}