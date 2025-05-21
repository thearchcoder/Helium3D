// [ID]
// Bristorbrot
// [INDEX]
// 25
// [VARS]
// bool is_julia[false, true] = false
// vec3 julia_c[(-3, -3, -3), (3, 3, 3)] = (-0.844, -0.031, -0.302)
// float derivative_bias[0.0, 2.0] = 1.0
// [CODE]

uniform bool fbristorbrot_is_julia;
uniform vec3 fbristorbrot_julia_c;
uniform float fbristorbrot_derivative_bias;

vec3 bristor_square(vec3 v) {
	float x2 = v.x * v.x;
	float y2 = v.y * v.y;
	float z2 = v.z * v.z;

	float new_x = x2 - y2 - z2;
	float new_y = v.y * (2.0 * v.x - v.z);
	float new_z = v.z * (2.0 * v.x + v.y);

	return vec3(new_x, new_y, new_z);
}

void bristorbrot_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 c = fbristorbrot_is_julia ? fbristorbrot_julia_c : original_z.xyz;
	dz = max(dz * fbristorbrot_derivative_bias, length(z) * dz * 2.0 + 1.0);

	z.xyz = bristor_square(z.xyz) + c;
}
