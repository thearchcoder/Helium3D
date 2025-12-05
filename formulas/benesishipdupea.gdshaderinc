// [ID]
// Benesi Ship Dupe A
// [OFFICIAL]
// [ESCAPE]
// [VARS]
// bool is_julia[false, true] = true
// vec3 julia_c[(0, 0, 0), (3, 3, 3)] = (1, 1, 1)
// [CODE]

void benesishipdupea_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 p = z4.xyz;
	vec3 config_offsets = fbenesishipdupea_is_julia ? fbenesishipdupea_julia_c : original_z.xyz;
	float power = 2.0;
	dz = pow(length(p), power - 1.0) * dz * power + 1.0;

	float x_val = p.x;
	float y_val = p.y;
	float z_val = p.z;

	float radius_squared = z_val * z_val + y_val * y_val;
	float radius = sqrt(radius_squared);
	float scale_factor = (2.0 * radius * x_val) / radius_squared;

	float new_y = abs(config_offsets.x) - abs((y_val * y_val - z_val * z_val) * scale_factor);
	float new_x = (x_val * x_val - radius_squared) + config_offsets.y;
	float new_z = abs(config_offsets.z) - abs(2.0 * y_val * scale_factor * z_val);

	z4.xyz = vec3(new_x, new_y, new_z);
}