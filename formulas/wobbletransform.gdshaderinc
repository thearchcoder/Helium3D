// [ID]
// Wobble Transform
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec2 rotation[(-3, -3), (3, 3)] = (3, 2)
// float strength[0, 4] = 1.03
// vec4 step[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.1, 0.1, 0.1, 0.1)
// template transform_range
// [CODE]

void wobbletransform_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransform_range)) {
		z.x = z.x - fwobbletransform_step.x * sin(z.z + sin(fwobbletransform_rotation.x * (z.z + sin(fwobbletransform_rotation.y * z.z)))) * fwobbletransform_strength;
		z.y = z.y - fwobbletransform_step.y * sin(z.x + sin(fwobbletransform_rotation.x * (z.x + sin(fwobbletransform_rotation.y * z.x)))) * fwobbletransform_strength;
		z.z = z.z - fwobbletransform_step.z * sin(z.y + sin(fwobbletransform_rotation.x * (z.y + sin(fwobbletransform_rotation.y * z.y)))) * fwobbletransform_strength;
		z.w = z.w - fwobbletransform_step.w * sin(z.w + sin(fwobbletransform_rotation.x * (z.w + sin(fwobbletransform_rotation.y * z.w)))) * fwobbletransform_strength;
	}
}