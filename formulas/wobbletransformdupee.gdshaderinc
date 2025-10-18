// [ID]
// Wobble Transform Dupe E
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec2 rotation[(-3, -3), (3, 3)] = (3, 2)
// float strength[0, 4] = 1.03
// vec4 step[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.1, 0.1, 0.1, 0.1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void wobbletransformdupee_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransformdupee_range)) {
		z.x = z.x - fwobbletransformdupee_step.x * sin(z.z + sin(fwobbletransformdupee_rotation.x * (z.z + sin(fwobbletransformdupee_rotation.y * z.z)))) * fwobbletransformdupee_strength;
		z.y = z.y - fwobbletransformdupee_step.y * sin(z.x + sin(fwobbletransformdupee_rotation.x * (z.x + sin(fwobbletransformdupee_rotation.y * z.x)))) * fwobbletransformdupee_strength;
		z.z = z.z - fwobbletransformdupee_step.z * sin(z.y + sin(fwobbletransformdupee_rotation.x * (z.y + sin(fwobbletransformdupee_rotation.y * z.y)))) * fwobbletransformdupee_strength;
		z.w = z.w - fwobbletransformdupee_step.w * sin(z.w + sin(fwobbletransformdupee_rotation.x * (z.w + sin(fwobbletransformdupee_rotation.y * z.w)))) * fwobbletransformdupee_strength;
	}
}