// [ID]
// Wobble Transform Dupe F
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec2 rotation[(-3, -3), (3, 3)] = (3, 2)
// float strength[0, 4] = 1.03
// vec4 step[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.1, 0.1, 0.1, 0.1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void wobbletransformdupef_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransformdupef_range)) {
		z.x = z.x - fwobbletransformdupef_step.x * sin(z.z + sin(fwobbletransformdupef_rotation.x * (z.z + sin(fwobbletransformdupef_rotation.y * z.z)))) * fwobbletransformdupef_strength;
		z.y = z.y - fwobbletransformdupef_step.y * sin(z.x + sin(fwobbletransformdupef_rotation.x * (z.x + sin(fwobbletransformdupef_rotation.y * z.x)))) * fwobbletransformdupef_strength;
		z.z = z.z - fwobbletransformdupef_step.z * sin(z.y + sin(fwobbletransformdupef_rotation.x * (z.y + sin(fwobbletransformdupef_rotation.y * z.y)))) * fwobbletransformdupef_strength;
		z.w = z.w - fwobbletransformdupef_step.w * sin(z.w + sin(fwobbletransformdupef_rotation.x * (z.w + sin(fwobbletransformdupef_rotation.y * z.w)))) * fwobbletransformdupef_strength;
	}
}