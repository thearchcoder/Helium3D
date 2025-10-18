// [ID]
// Kali redux Dupe A
// [OFFICIAL]
// [KIFS]
// [VARS]
// vec4 folds[(-2, -2, -2, -2), (2, 2, 2, 2)] = (0, 0, 0.3, 1.0)
// vec3 minus[(-2, -2, -2), (2, 2, 2)] = (0, 2, 0)
// float scale[1.0, 3.0] = 2.0
// [CODE]

void kalireduxdupea_iter(inout vec4 p, inout float dz, vec4 original_z, float orbit, int i) {
	p = rotate4d_point(p, vec4(0.0, 0.0, 0.0, fkalireduxdupea_folds.x));

	dz = dz * abs(fkalireduxdupea_scale) + 5.0;

	p = abs(p) - vec4(0.5, 1.5, 0.5, 0);
	p = p * fkalireduxdupea_scale / clamp(dot(p.xyz, p.xyz), fkalireduxdupea_folds.z, fkalireduxdupea_folds.w) - vec4(fkalireduxdupea_minus, 0.0);

	p = rotate4d_point(p, vec4(0.0, 0.0, 0.0, fkalireduxdupea_folds.y));

	//if (coloring_mode == 0 && i > color_min_iterations && i < color_max_iterations) orbit_trap = min(orbit_trap, dot(p, p));
	//else orbit_trap = min(orbit_trap, process_orbit_trap4d(p, i));

	//float d = max(abs(p.z / p.w) - 0.01, length(p.zx) / p.w - 0.002);
	//return vec2(d, orbit_trap);
}

//vec2 kalireduxdupea_sdf(vec3 pos) {
	//vec4 p = vec4(pos, 1.0);
	//float orbit_trap = 100000.0;
	////p.y = abs(3.0 - mod(p.y - 1.0, 6.0));
//
	//for (int i = 0; i < iterations; i++) {
		//p = rotate4d_point(p, vec4(0.0, 0.0, 0.0, fkalireduxdupea_folds.x));
//
		//p = abs(p) - vec4(0.5, 1.5, 0.5, 0);
		//p = p * fkalireduxdupea_scale / clamp(dot(p.xyz, p.xyz), fkalireduxdupea_folds.z, fkalireduxdupea_folds.w) - vec4(fkalireduxdupea_minus, 0.0);
//
		//p = rotate4d_point(p, vec4(0.0, 0.0, 0.0, fkalireduxdupea_folds.y));
//
		//if (coloring_mode == 0 && i > color_min_iterations && i < color_max_iterations) orbit_trap = min(orbit_trap, dot(p, p));
		//else orbit_trap = min(orbit_trap, process_orbit_trap4d(p, i));
	//}
//
	//float d = max(abs(p.z / p.w) - 0.01, length(p.zx) / p.w - 0.002);
	//return vec2(d, orbit_trap);
//}
