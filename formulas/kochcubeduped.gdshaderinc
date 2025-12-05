// [ID]
// Koch cube Dupe D
// [OFFICIAL]
// [KIFS]
// [LINEAR-DE]
// [VARS]
// float scale[0, 3] = 1
// int variant[0, 10] = 0
// bool first_zrev[false, true] = true
// bool pxyzminuss[false, true] = true
// advanced bool psortsymmetry1[false, true] = false
// bool psortsymmetry2[false, true] = false
// bool foldzbefore[false, true] = true
// advanced bool abs_x[false, true] = true
// advanced bool abs_y[false, true] = true
// bool abs_z[false, true] = true
// advanced selection fold1[Disabled, Sign, Minus, Both] = Disabled
// advanced selection fold2[Disabled, Max, Min] = Disabled
// bool fold3[false, true] = true
// bool fold4[false, true] = true
// advanced bool reflection[false, true] = false
// advanced vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// advanced vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// [CODE]

void kochcubeduped_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i, inout float s) {
	vec3 p = z4.xyz;
	s /= 2.0;

	p = rotate3d_point(p, fkochcubeduped_rotation1);

	if (fkochcubeduped_reflection) p.xz = vec2(max(p.x, p.z), min(p.x, p.z));

	if (fkochcubeduped_abs_x) p.x = abs(p.x);
	if (fkochcubeduped_abs_y) p.y = abs(p.y);
	if (fkochcubeduped_abs_z) p.z = abs(p.z);

	if (fkochcubeduped_fold1 == 1) {
		p.yz *= sign(p.y + p.z);
	} else if (fkochcubeduped_fold2 == 2) {
		p.xz -= s;
	} else if (fkochcubeduped_fold2 == 3) {
		p.yz *= sign(p.y + p.z);
		p.xz -= s;
	}

	if (fkochcubeduped_fold2 == 1) p.xz = vec2(max(p.x, p.z), min(p.x, p.z));
	else if (fkochcubeduped_fold2 == 2) p.xz = vec2(min(p.x, p.z), max(p.x, p.z));

	if (!fkochcubeduped_pxyzminuss) p.xz -= s;
	else p -= s;

	p = psort(p, fkochcubeduped_psortsymmetry1);

	if (fkochcubeduped_variant == 2) {
		if (p.x - p.z > 0.0) p.xz = -p.zx;
		if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcubeduped_variant == 1) {
		if (p.x - p.z > 0.0) p.xz = p.zx;
	} else if (fkochcubeduped_variant == 3) {
		if (p.x - p.z > 0.0) p.xz = -p.zx;
	} else if (fkochcubeduped_variant == 4) {
		if (p.x - p.z > 0.0) p.xz = p.zx;
		if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcubeduped_variant == 5) {
		if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcubeduped_variant == 6) {
		if (p.x - p.z > 0.0) p.xz = p.zx;
		if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcubeduped_variant == 7) {
		if (p.x - p.z > 0.0) p.xz = p.zx;
	} else if (fkochcubeduped_variant == 8) {
		if (p.x - p.z > 0.0) p.xz = -p.zx;
	}

	if (fkochcubeduped_foldzbefore && p.x < p.y) p.xy = -p.yx;

	if (p.x + p.z <= -s){
		p.z += s;
		if (fkochcubeduped_first_zrev) p.xz = -p.zx;
		p.z -= s;
	}

	if (p.y >= p.x + s) {
		if (fkochcubeduped_fold3) p.x += s;
		if (fkochcubeduped_fold4) p.xy = p.yx;
		p.x -= s;
	}

	if (!fkochcubeduped_foldzbefore && p.x < p.y) p.xy = -p.yx;
	p = psort(p, fkochcubeduped_psortsymmetry2);

	s /= 2.0;
	p.xz = abs(p.xz) - s;

	p *= fkochcubeduped_scale;
	dz *= abs(fkochcubeduped_scale);

	p = rotate3d_point(p, fkochcubeduped_rotation2);

	z4.xyz = p;
}
