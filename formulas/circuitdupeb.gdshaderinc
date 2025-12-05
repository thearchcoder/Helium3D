// [ID]
// Circuit Dupe B
// [OFFICIAL]
// [DIFS]
// [VARS]
// float scale[1.0, 2.0] = 1.88
// vec4 abs1[(0, 0, 0, 0), (1, 1, 1, 1)] = (0.3, 0.3, 0.3, 0.3)
// vec4 abs2[(0, 0, 0, 0), (1, 1, 1, 1)] = (0.0, 0.5, 0.0, 0.0)
// vec2 box_fold[(0, 0), (2, 2)] = (0.3, 1.0)
// vec4 box_minus[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.5, 1.5, 0.5, 0.0)
// [CODE]

vec2 circuitdupeb_sdf(vec4 pos) {
	vec4 p = vec4(pos.xyz, 1.0);
	float orbit_trap = 100000.0;
	
	for (int i = 0; i < iterations; i++) {
		p.yx = abs(p.yx + fcircuitdupeb_abs1.x) - abs(p.yx + fcircuitdupeb_abs1.z) - p.yx;
		p.xz = abs(p.xz + fcircuitdupeb_abs1.y) - abs(p.xz + fcircuitdupeb_abs1.w) + p.xz;
		if (p.y - p.z < 0.0) p.yz = p.zy;
		if (p.x - p.z < 0.0) p.xz = p.zx;

		p = abs(p) - fcircuitdupeb_abs2;
		p = p * fcircuitdupeb_scale / clamp(dot(p.xyz, p.xyz), fcircuitdupeb_box_fold.x, fcircuitdupeb_box_fold.y) - fcircuitdupeb_box_minus;

		orbit_trap = min(orbit_trap, length(p));
	}
	
	float d = max(abs(p.z / p.w) - 0.01, length(p.zx) / p.w - 0.002);
	return vec2(d, orbit_trap);
}