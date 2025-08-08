// [ID]
// Bristorbrot
// [OFFICIAL]
// [ESCAPE]
// [VARS]
// bool is_julia[false, true] = false
// vec3 julia_c[(-2, -2, -2), (2, 2, 2)] = (-0.844, -0.031, -0.302)
// vec3 multiply[(-2, -2, -2), (2, 2, 2)] = (2, 1, -1)
// [CODE]

vec3 bristor_square(vec3 v) {
	float new_x = v.x * v.x - v.y * v.y - v.z * v.z;
	float new_y = v.y * (fbristorbrot_multiply.x * v.x + fbristorbrot_multiply.z * v.z);
	float new_z = v.z * (fbristorbrot_multiply.x * v.x + fbristorbrot_multiply.y * v.y);
	return vec3(new_x, new_y, new_z);
}

void bristorbrot_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 c = fbristorbrot_is_julia ? fbristorbrot_julia_c : original_z.xyz;
	dz = length(z) * dz * 2.0 + 1.0;

	z.xyz = bristor_square(z.xyz) + c;
}
