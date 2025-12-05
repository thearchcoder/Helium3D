// [ID]
// Wobble Transform Dupe D
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec2 rotation[(-3, -3), (3, 3)] = (3, 2)
// float strength[0, 4] = 1.03
// vec4 step[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.1, 0.1, 0.1, 0.1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void wobbletransformduped_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransformduped_range)) {
		z.x = z.x - fwobbletransformduped_step.x * sin(z.z + sin(fwobbletransformduped_rotation.x * (z.z + sin(fwobbletransformduped_rotation.y * z.z)))) * fwobbletransformduped_strength;
		z.y = z.y - fwobbletransformduped_step.y * sin(z.x + sin(fwobbletransformduped_rotation.x * (z.x + sin(fwobbletransformduped_rotation.y * z.x)))) * fwobbletransformduped_strength;
		z.z = z.z - fwobbletransformduped_step.z * sin(z.y + sin(fwobbletransformduped_rotation.x * (z.y + sin(fwobbletransformduped_rotation.y * z.y)))) * fwobbletransformduped_strength;
		z.w = z.w - fwobbletransformduped_step.w * sin(z.w + sin(fwobbletransformduped_rotation.x * (z.w + sin(fwobbletransformduped_rotation.y * z.w)))) * fwobbletransformduped_strength;
	}
}