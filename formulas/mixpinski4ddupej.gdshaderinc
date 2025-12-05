// [ID]
// Mixpinski4D Dupe J
// [OFFICIAL]
// [KIFS]
// [VARS]
// float scale[1.0, 3.0] = 2.0
// float fold1_strength[-3.0, 3.0] = 0.0
// vec4 offset[(-2, -2, -2, -2), (2, 2, 2, 2)] = (1, 1, 1, 1)
// vec4 rotation1[(-3.14159, -3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159, 3.14159)] = (0, 0, 0, 0)
// vec4 rotation2[(-3.14159, -3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159, 3.14159)] = (0, 0, 0, 0)
// advanced float abs_minus[-5, 5] = 0
// advanced vec4 fold1[(-2, -2, -2, -2), (2, 2, 2, 2)] = (1.2, 1.2, 1.2, 1.2)
// advanced vec4 pre_offset[(-3, -3, -3, -3), (3, 3, 3, 3)] = (0, 0, 0, 0)
// [CODE]

void mixpinski4ddupej_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec4 p = z4;
	vec4 offset = fmixpinski4ddupej_offset;
	float scale = fmixpinski4ddupej_scale;

	p = rotate4d_point(p, fmixpinski4ddupej_rotation1);

	p -= fmixpinski4ddupej_pre_offset;

	if (p.x + p.y < 0.0) p.xy = -p.yx;
	if (p.x + p.z < 0.0) p.xz = -p.zx;
	if (p.y + p.z < 0.0) p.yz = -p.zy;
	if (p.x + p.w < 0.0) p.xw = -p.wx;
	if (p.y + p.w < 0.0) p.yw = -p.wy;
	if (p.z + p.w < 0.0) p.zw = -p.wz;

	p.x = scale * p.x - offset.x * (scale - 1.0);
	p.y = scale * p.y - offset.y * (scale - 1.0);
	p -= min(p, fmixpinski4ddupej_fold1) * fmixpinski4ddupej_fold1_strength;
	p.w = scale * p.w - offset.w * (scale - 1.0);
	p.z -= 0.5 * offset.z * (scale - 1.0) / scale;
	p.z = -abs(-p.z + fmixpinski4ddupej_abs_minus);
	p.z += 0.5 * offset.z * (scale - 1.0) / scale;
	p.z = scale * p.z;

	p = rotate4d_point(p, fmixpinski4ddupej_rotation2);
	dz = dz * abs(scale) + 3.0;

	z4 = p;
}
