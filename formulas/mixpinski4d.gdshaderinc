// [ID]
// mixpinski4d
// [INDEX]
// 18
// [VARS]
// float scale[1.0, 3.0] = 2.0
// float w[-3.0, 3.0] = 0.0
// float fold1_strength[-3.0, 3.0] = 0.0
// vec4 fold1[(-2, -2, -2, -2), (2, 2, 2, 2)] = (1.2, 1.2, 1.2, 1.2)
// vec4 offset[(-2, -2, -2, -2), (2, 2, 2, 2)] = (1, 1, 1, 1)
// vec4 rotation1[(-3.14159, -3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159, -3.14159)] = (0, 0, 0, 0)
// vec4 rotation2[(-3.14159, -3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159, -3.14159)] = (0, 0, 0, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159, -3.14159)] = (0, 0, 0, 0)
// [CODE]
uniform float fmixpinski4d_w;
uniform float fmixpinski4d_scale;
uniform vec4 fmixpinski4d_offset;
uniform vec4 fmixpinski4d_rotation1;
uniform vec4 fmixpinski4d_rotation2;

uniform float fmixpinski4d_fold1_strength;
uniform vec4 fmixpinski4d_fold1;

vec2 mixpinski4d_sdf(vec3 p3d) {
	vec4 p = vec4(p3d, fmixpinski4d_w);
	vec4 offset = fmixpinski4d_offset;
	float scale = fmixpinski4d_scale;
	float orbit_trap = 1000000.0;
	float s = 1.0;

	int i = 0;
    for (; i < iterations; i++) {
		p = rotate4d_point(p, fmixpinski4d_rotation1);
		
		if (p.x + p.y < 0.0) p.xy = -p.yx;
		if (p.x + p.z < 0.0) p.xz = -p.zx;
		if (p.y + p.z < 0.0) { p.yz = -p.zy; orbit_trap *= 2.0; }
		if (p.x + p.w < 0.0) p.xw = -p.wx;
		if (p.y + p.w < 0.0) p.yw = -p.wy;
		if (p.z + p.w < 0.0) p.zw = -p.wz;

		p.x = scale * p.x - offset.x * (scale - 1.0);
		p.y = scale * p.y - offset.y * (scale - 1.0);
		p -= min(p, fmixpinski4d_fold1) * fmixpinski4d_fold1_strength;
		p.w = scale * p.w - offset.w * (scale - 1.0);
		p.z -= 0.5 * offset.z * (scale - 1.0) / scale;
		p.z = -abs(-p.z); // --p.z
		p.z += 0.5 * offset.z * (scale - 1.0) / scale;
		p.z = scale * p.z;
		
		p = rotate4d_point(p, fmixpinski4d_rotation2);
		s /= scale;
		
		if (coloring_mode == 0) orbit_trap = min(orbit_trap, dot(p, p));
		else orbit_trap = min(orbit_trap, process_orbit_trap4d(p));
	}

	float d = cube_sdf4d(p, vec4(1.0)) * s; //0.9 * length(p) * pow(scale, float(-i-1));
	return vec2(d, orbit_trap);
}
