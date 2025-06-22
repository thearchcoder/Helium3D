// [ID]
// Amazing surf
// [OFFICIAL]
// [KIFS]
// [VARS]
// advanced bool is_julia[false, true] = true
// vec3 julia_c[(-2, -2, -2), (2, 2, 2)] = (-1, -2, 0)
// vec3 rotation[(-2, -2, -2), (2, 2, 2)] = (2, -2, 1.6)
// advanced vec3 fold[(-1, -1, -1), (1, 1, 1)] = (1, 1, 1)
// advanced bool fold_z[false, true] = false
// float min_radius[0.0, 1.0] = 0.25
// vec3 offset[(-2, -2, -2), (2, 2, 2)] = (0, 0, -0.5)
// float scale[1.0, 3.0] = 1.5
// advanced vec2 fold2[(-2, -2), (2, 2)] = (0.3, 0.0)
// [CODE]

void amazingsurf_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = z4.xyz;

	p.xyz -= min(p.xyz, famazingsurf_fold2.x) * famazingsurf_fold2.y;

	// fold
	p.xy = famazingsurf_fold.xy - abs(abs(p.xy) - famazingsurf_fold.xy);
	if (famazingsurf_fold_z) p.z = famazingsurf_fold.z - abs(abs(p.z) - famazingsurf_fold.z);

	// offset
	p.xyz += famazingsurf_offset;

	// fold
	float r2 = dot(p.xyz, p.xyz);
	p *= famazingsurf_scale / clamp(r2, famazingsurf_min_radius, 1.0);

	// offset
	p.xyz += famazingsurf_is_julia ? famazingsurf_julia_c : original_z.xyz;

	p.xyz = rotate3d_point(p.xyz, famazingsurf_rotation);
	dz = dz * (famazingsurf_scale / clamp(r2, famazingsurf_min_radius, 1.0)) + 4.0;
	z4.xyz = p;
}
