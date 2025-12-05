// [ID]
// Wobble Transform Dupe G
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec2 rotation[(-3, -3), (3, 3)] = (3, 2)
// float strength[0, 4] = 1.03
// vec4 step[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.1, 0.1, 0.1, 0.1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void wobbletransformdupeg_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransformdupeg_range)) {
		z.x = z.x - fwobbletransformdupeg_step.x * sin(z.z + sin(fwobbletransformdupeg_rotation.x * (z.z + sin(fwobbletransformdupeg_rotation.y * z.z)))) * fwobbletransformdupeg_strength;
		z.y = z.y - fwobbletransformdupeg_step.y * sin(z.x + sin(fwobbletransformdupeg_rotation.x * (z.x + sin(fwobbletransformdupeg_rotation.y * z.x)))) * fwobbletransformdupeg_strength;
		z.z = z.z - fwobbletransformdupeg_step.z * sin(z.y + sin(fwobbletransformdupeg_rotation.x * (z.y + sin(fwobbletransformdupeg_rotation.y * z.y)))) * fwobbletransformdupeg_strength;
		z.w = z.w - fwobbletransformdupeg_step.w * sin(z.w + sin(fwobbletransformdupeg_rotation.x * (z.w + sin(fwobbletransformdupeg_rotation.y * z.w)))) * fwobbletransformdupeg_strength;
	}
}