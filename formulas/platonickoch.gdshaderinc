// [ID]
// Platonic Koch
// [OFFICIAL]
// [IFS]
// [LINEAR-DE]
// [VARS]
// float stretch[-3, 3] = 1
// float postscale[-3, 3] = 1
// float zfix[-3, 3] = 1
// vec3 add[(-3, -3, -3), (3, 3, 3)] = (0, 0, 0)
// [CODE]

void platonickoch_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = z4.xyz;

	p = abs(p) * 3.0;
	dz *= 3.0;

	if (p.y > p.x) p.xy = p.yx;
	if (p.z > p.x) p.xz = p.zx;
	if (p.z > p.y) p.yz = p.zy;

	p += fplatonickoch_add;

	float stretch = fplatonickoch_stretch;
	float postscale = fplatonickoch_postscale;
	float zfix = fplatonickoch_zfix;

	float a = 3.0 - stretch;
	float b = 3.0 + stretch;
	float c = p.x - a;
	float d = p.x - b;

	p.z = zfix - abs(zfix - p.z);

	if (c < p.y) {
		p.x = c;
		p.y = p.y - a;
	} else if (d > p.y) {
		p.x = d;
	} else {
		p.xy = p.yx;
		p.y = d;
	}

	p.xy /= stretch;
	p *= postscale;
	dz *= abs(postscale);
	dz += 6.0;
	z4.xyz = p;
}