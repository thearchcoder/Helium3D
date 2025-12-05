// [ID]
// Wobble Transform Dupe I
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec2 rotation[(-3, -3), (3, 3)] = (3, 2)
// float strength[0, 4] = 1.03
// vec4 step[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.1, 0.1, 0.1, 0.1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void wobbletransformdupei_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransformdupei_range)) {
		z.x = z.x - fwobbletransformdupei_step.x * sin(z.z + sin(fwobbletransformdupei_rotation.x * (z.z + sin(fwobbletransformdupei_rotation.y * z.z)))) * fwobbletransformdupei_strength;
		z.y = z.y - fwobbletransformdupei_step.y * sin(z.x + sin(fwobbletransformdupei_rotation.x * (z.x + sin(fwobbletransformdupei_rotation.y * z.x)))) * fwobbletransformdupei_strength;
		z.z = z.z - fwobbletransformdupei_step.z * sin(z.y + sin(fwobbletransformdupei_rotation.x * (z.y + sin(fwobbletransformdupei_rotation.y * z.y)))) * fwobbletransformdupei_strength;
		z.w = z.w - fwobbletransformdupei_step.w * sin(z.w + sin(fwobbletransformdupei_rotation.x * (z.w + sin(fwobbletransformdupei_rotation.y * z.w)))) * fwobbletransformdupei_strength;
	}
}