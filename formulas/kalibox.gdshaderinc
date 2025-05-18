// [ID]
// Kali box
// [INDEX]
// 21
// [VARS]
// float scale[1.0, 2.0] = 1.5
// vec3 offset1[(-2, -2, -2), (2, 2, 2)] = (1, 1, 1)
// vec3 offset2[(-2, -2, -2), (2, 2, 2)] = (1, 1, 1)
// [CODE]

uniform float fkalibox_scale;
uniform vec3 fkalibox_offset1;
uniform vec3 fkalibox_offset2;

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

//vec2 kalibox_sdf(vec3 z) {
	//float scale = fkalibox_scale;
	//float r;
	//float de = 1.0;
	//float orbit_trap = 10000.0;
	//float MinR = 0.0;
//
	//int i = 0;
	//for (; i < iterations; i++) {
		//z = fkalibox_offset1 - abs(z);
		//float rr = dot(z, z);
		//float dividend = rr < MinR ? MinR : min(rr, 1.0);
		//float m = -scale / dividend;
		//z = z * m;
		//z += fkalibox_offset2;
//
		//r = dot(z, z);
		//de = de * abs(m) + 1.0;
//
		//if (coloring_mode == 0 && i > color_min_iterations && i < color_max_iterations) orbit_trap = min(orbit_trap, length(z));
		//else orbit_trap = min(orbit_trap, process_orbit_trap(z, i));
//
		//if (r > escape_radius) break;
	//}
//
	//return vec2(length(z) / abs(de), orbit_trap);
//}