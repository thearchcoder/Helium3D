// [ID]
// Amazing surf Dupe D
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

void amazingsurfduped_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = z4.xyz;

	p.xyz -= min(p.xyz, famazingsurfduped_fold2.x) * famazingsurfduped_fold2.y;

	// fold
	p.xy = famazingsurfduped_fold.xy - abs(abs(p.xy) - famazingsurfduped_fold.xy);
	if (famazingsurfduped_fold_z) p.z = famazingsurfduped_fold.z - abs(abs(p.z) - famazingsurfduped_fold.z);

	// offset
	p.xyz += famazingsurfduped_offset;

	// fold
	float r2 = dot(p.xyz, p.xyz);
	p *= famazingsurfduped_scale / clamp(r2, famazingsurfduped_min_radius, 1.0);

	// offset
	p.xyz += famazingsurfduped_is_julia ? famazingsurfduped_julia_c : original_z.xyz;

	p.xyz = rotate3d_point(p.xyz, famazingsurfduped_rotation);
	dz = dz * (famazingsurfduped_scale / clamp(r2, famazingsurfduped_min_radius, 1.0)) + 4.0;
	z4.xyz = p;
}
