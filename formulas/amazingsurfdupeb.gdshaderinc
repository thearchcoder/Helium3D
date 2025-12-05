// [ID]
// Amazing surf Dupe B
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

void amazingsurfdupeb_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = z4.xyz;

	p.xyz -= min(p.xyz, famazingsurfdupeb_fold2.x) * famazingsurfdupeb_fold2.y;

	// fold
	p.xy = famazingsurfdupeb_fold.xy - abs(abs(p.xy) - famazingsurfdupeb_fold.xy);
	if (famazingsurfdupeb_fold_z) p.z = famazingsurfdupeb_fold.z - abs(abs(p.z) - famazingsurfdupeb_fold.z);

	// offset
	p.xyz += famazingsurfdupeb_offset;

	// fold
	float r2 = dot(p.xyz, p.xyz);
	p *= famazingsurfdupeb_scale / clamp(r2, famazingsurfdupeb_min_radius, 1.0);

	// offset
	p.xyz += famazingsurfdupeb_is_julia ? famazingsurfdupeb_julia_c : original_z.xyz;

	p.xyz = rotate3d_point(p.xyz, famazingsurfdupeb_rotation);
	dz = dz * (famazingsurfdupeb_scale / clamp(r2, famazingsurfdupeb_min_radius, 1.0)) + 4.0;
	z4.xyz = p;
}
