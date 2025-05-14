// [ID]
// Koch wire
// [INDEX]
// 20
// [VARS]
// bool fold1[false, true] = true
// bool fold2[false, true] = true
// bool fold3[false, true] = true
// bool abs_x[false, true] = false
// bool abs_y[false, true] = false
// bool abs_z[false, true] = true
// bool abs2_zx[false, true] = true
// vec3 abs_plus[(-2, -2, -2), (2, 2, 2)] = (0.1, 0.1, 0.1)
// vec3 abs_minus[(-2, -2, -2), (2, 2, 2)] = (0.0, 0.0, 0.0)
// float scale[1.0, 4.0] = 3.0
// float symmetry[1.0, 100.0] = 3.0
// vec3 offset[(-2, -2, -2), (2, 2, 2)] = (1, 0, 0)
// [CODE]

uniform vec3 fkochwire_abs_plus;
uniform vec3 fkochwire_abs_minus;
uniform bool fkochwire_fold1;
uniform bool fkochwire_fold2;
uniform bool fkochwire_fold3;
uniform bool fkochwire_abs_x;
uniform bool fkochwire_abs_y;
uniform bool fkochwire_abs_z;
uniform bool fkochwire_abs2_zx;
uniform vec3 fkochwire_offset;
uniform float fkochwire_scale;
uniform float fkochwire_symmetry;

void kochwire_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	if (i == 0) z4 *= 2.0;
	vec3 z = z4.xyz;

	float scale = fkochwire_scale;
	vec3 offset = fkochwire_offset;

	if (fkochwire_fold1 && z.x - z.z < 0.0) z.xz = z.zx;

	float angle = 3.14159265 / fkochwire_symmetry;
	float theta = atan(z.z, z.x);
	float r = length(z.xz);
	theta = mod(theta + angle, 2.0 * angle) - angle;
	z.xz = vec2(cos(theta), sin(theta)) * r;

	if (fkochwire_abs_x) z.x = abs(z.x + fkochwire_abs_minus.x) - fkochwire_abs_plus.x;
	if (fkochwire_abs_y) z.y = abs(z.y + fkochwire_abs_minus.y) - fkochwire_abs_plus.y;
	if (fkochwire_abs_z) z.z = abs(z.z + fkochwire_abs_minus.z) - fkochwire_abs_plus.z;

	// hex fold
	if (fkochwire_abs2_zx) z.xy = abs(z.xy);
	const vec2 pl1 = vec2(-0.5, 0.8657);
	const vec2 pl2 = vec2(-0.8657, 0.4);
	//z.xz -= pl1 * 2.0 * min(0.0, dot(z.xz, pl1));

	//z.yz -= pl2*2.*min(0., dot(z.yz, pl2));
	//z.xz -= pl2*2.*min(0., dot(z.xz, pl2));
	//z.zx -= pl2*2.*min(0., dot(z.zx, pl2));
	//z.yx -= pl2*2.*min(0., dot(z.yx, pl2));

	z = abs(z - 0.1);

	// abs minus fold
	// adds asymmetric detail

	// ???
	//z += min(z, vec3(0.02)) * 2.0;

	vec3 absz = z;
	absz.xz -= vec2(1.0, 0.5);
	absz = abs(absz);

	z = abs(z);
	z = min(absz, z);
	// TODO: option to remove these folds
	if (fkochwire_fold2 && z.x - z.y < 0.0) z.xy = z.yx;
	if (fkochwire_fold3 && z.x - z.z < 0.0) z.xz = z.zx;

	z = z * scale - offset * (scale - 1.0);
	dz = dz * abs(scale) + 8.0;
	z4.xyz = z;
}
