// [ID]
// Wobble Transform Dupe A
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec2 rotation[(-3, -3), (3, 3)] = (3, 2)
// float strength[0, 4] = 1.03
// vec4 step[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.1, 0.1, 0.1, 0.1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void wobbletransformdupea_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransformdupea_range)) {
		z.x = z.x - fwobbletransformdupea_step.x * sin(z.z + sin(fwobbletransformdupea_rotation.x * (z.z + sin(fwobbletransformdupea_rotation.y * z.z)))) * fwobbletransformdupea_strength;
		z.y = z.y - fwobbletransformdupea_step.y * sin(z.x + sin(fwobbletransformdupea_rotation.x * (z.x + sin(fwobbletransformdupea_rotation.y * z.x)))) * fwobbletransformdupea_strength;
		z.z = z.z - fwobbletransformdupea_step.z * sin(z.y + sin(fwobbletransformdupea_rotation.x * (z.y + sin(fwobbletransformdupea_rotation.y * z.y)))) * fwobbletransformdupea_strength;
		z.w = z.w - fwobbletransformdupea_step.w * sin(z.w + sin(fwobbletransformdupea_rotation.x * (z.w + sin(fwobbletransformdupea_rotation.y * z.w)))) * fwobbletransformdupea_strength;
	}
}