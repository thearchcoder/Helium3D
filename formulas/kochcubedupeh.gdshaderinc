// [ID]
// Koch cube Dupe H
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

void kochcubedupeh_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i, inout float s) {
	vec3 p = z4.xyz;
	s /= 2.0;

	p = rotate3d_point(p, fkochcubedupeh_rotation1);

	if (fkochcubedupeh_reflection) p.xz = vec2(max(p.x, p.z), min(p.x, p.z));

	if (fkochcubedupeh_abs_x) p.x = abs(p.x);
	if (fkochcubedupeh_abs_y) p.y = abs(p.y);
	if (fkochcubedupeh_abs_z) p.z = abs(p.z);

	if (fkochcubedupeh_fold1 == 1) {
		p.yz *= sign(p.y + p.z);
	} else if (fkochcubedupeh_fold2 == 2) {
		p.xz -= s;
	} else if (fkochcubedupeh_fold2 == 3) {
		p.yz *= sign(p.y + p.z);
		p.xz -= s;
	}

	if (fkochcubedupeh_fold2 == 1) p.xz = vec2(max(p.x, p.z), min(p.x, p.z));
	else if (fkochcubedupeh_fold2 == 2) p.xz = vec2(min(p.x, p.z), max(p.x, p.z));

	if (!fkochcubedupeh_pxyzminuss) p.xz -= s;
	else p -= s;

	p = psort(p, fkochcubedupeh_psortsymmetry1);

	if (fkochcubedupeh_variant == 2) {
		if (p.x - p.z > 0.0) p.xz = -p.zx;
		if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcubedupeh_variant == 1) {
		if (p.x - p.z > 0.0) p.xz = p.zx;
	} else if (fkochcubedupeh_variant == 3) {
		if (p.x - p.z > 0.0) p.xz = -p.zx;
	} else if (fkochcubedupeh_variant == 4) {
		if (p.x - p.z > 0.0) p.xz = p.zx;
		if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcubedupeh_variant == 5) {
		if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcubedupeh_variant == 6) {
		if (p.x - p.z > 0.0) p.xz = p.zx;
		if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcubedupeh_variant == 7) {
		if (p.x - p.z > 0.0) p.xz = p.zx;
	} else if (fkochcubedupeh_variant == 8) {
		if (p.x - p.z > 0.0) p.xz = -p.zx;
	}

	if (fkochcubedupeh_foldzbefore && p.x < p.y) p.xy = -p.yx;

	if (p.x + p.z <= -s){
		p.z += s;
		if (fkochcubedupeh_first_zrev) p.xz = -p.zx;
		p.z -= s;
	}

	if (p.y >= p.x + s) {
		if (fkochcubedupeh_fold3) p.x += s;
		if (fkochcubedupeh_fold4) p.xy = p.yx;
		p.x -= s;
	}

	if (!fkochcubedupeh_foldzbefore && p.x < p.y) p.xy = -p.yx;
	p = psort(p, fkochcubedupeh_psortsymmetry2);

	s /= 2.0;
	p.xz = abs(p.xz) - s;

	p *= fkochcubedupeh_scale;
	dz *= abs(fkochcubedupeh_scale);

	p = rotate3d_point(p, fkochcubedupeh_rotation2);

	z4.xyz = p;
}
