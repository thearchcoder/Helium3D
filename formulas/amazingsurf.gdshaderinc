// [ID]
// Amazing surf
// [INDEX]
// 3
// [VARS]
// vec3 c[(-2, -2, -2), (2, 2, 2)] = (-1, -2, 0)
// vec3 rotation[(-2, -2, -2), (2, 2, 2)] = (2, -2, 1.6)
// vec2 fold[(-1, -1), (1, 1)] = (1, 1)
// float min_radius[0.0, 1.0] = 0.25
// vec3 offset[(-2, -2, -2), (2, 2, 2)] = (0, 0, -0.5)
// float scale[1.0, 3.0] = 1.5
// [CODE]
uniform vec2 famazingsurf_fold;
uniform vec3 famazingsurf_rotation;
uniform vec3 famazingsurf_offset;
uniform vec3 famazingsurf_c;
uniform float famazingsurf_min_radius;
uniform float famazingsurf_scale;

void amazingsurf_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = z4.xyz;

	if (i == 0) p.z = -p.z;

	float scale = famazingsurf_scale;

	p.xy = famazingsurf_fold - abs(abs(p.xy) - famazingsurf_fold);
	p.xyz += famazingsurf_offset;

	float r2 = dot(p.xyz, p.xyz);
	p *= scale / clamp(r2, famazingsurf_min_radius, 1.0);

	dz = dz * (scale / clamp(r2, famazingsurf_min_radius, 1.0)) + 4.0;

	p.xyz += famazingsurf_c;

	p.xyz = rotate3d_point(p.xyz, famazingsurf_rotation);
	z4.xyz = p;

	//float dist = (length(p.xyz) - abs(1.0 - power)) / p.w - pow(power, float(1 - iterations));
	//return vec2(0.5 * dist, orbit_trap);
}


//vec2 amazingsurf_sdf(vec3 pos) {
	//vec2 famazingsurf_fold = vec2(famazingsurf_fold_x, famazingsurf_fold_y);
	//vec4 p = vec4(pos, 1.0);
	//float power = famazingsurf_scale;
	//float orbit_trap = 1e4;
//
	//for (int i = 0; i < iterations; i++) {
		//p.xy = famazingsurf_fold - abs(abs(p.xy) - famazingsurf_fold);
		//p.xyz += famazingsurf_offset;
//
		//float r2 = dot(p.xyz, p.xyz);
		//p *= power / clamp(r2, famazingsurf_min_radius, 1.0);
		//p.xyz += famazingsurf_c;
//
		//if (coloring_mode == 0 && i > color_min_iterations && i < color_max_iterations) orbit_trap = min(orbit_trap, r2);
		//else orbit_trap = min(orbit_trap, process_orbit_trap4d(p, i));
//
		//p.xyz = rotate3d_point(p.xyz, famazingsurf_rotation);
	//}
//
	//float dist = (length(p.xyz) - abs(1.0 - power)) / p.w - pow(power, float(1 - iterations));
	//return vec2(0.5 * dist, orbit_trap);
//}
