// [ID]
// Kali box
// [OFFICIAL]
// [IFS]
// [VARS]
// float scale[1.0, 2.0] = 1.5
// vec3 offset1[(-2, -2, -2), (2, 2, 2)] = (1, 1, 1)
// vec3 offset2[(-2, -2, -2), (2, 2, 2)] = (1, 1, 1)
// [CODE]

void kalibox_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = z4.xyz;
	float scale = fkalibox_scale;
	float MinR = 0.0;

	z = fkalibox_offset1 - abs(z);
	float rr = dot(z, z);
	float dividend = rr < MinR ? MinR : min(rr, 1.0);
	float m = -scale / dividend;
	z = z * m;
	z += fkalibox_offset2;
	z4.xyz = z;

	dz = dz * abs(m) + 1.0;
}
