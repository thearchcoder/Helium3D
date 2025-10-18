// [ID]
// Wobble Transform Dupe C
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec2 rotation[(-3, -3), (3, 3)] = (3, 2)
// float strength[0, 4] = 1.03
// vec4 step[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.1, 0.1, 0.1, 0.1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void wobbletransformdupec_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransformdupec_range)) {
		z.x = z.x - fwobbletransformdupec_step.x * sin(z.z + sin(fwobbletransformdupec_rotation.x * (z.z + sin(fwobbletransformdupec_rotation.y * z.z)))) * fwobbletransformdupec_strength;
		z.y = z.y - fwobbletransformdupec_step.y * sin(z.x + sin(fwobbletransformdupec_rotation.x * (z.x + sin(fwobbletransformdupec_rotation.y * z.x)))) * fwobbletransformdupec_strength;
		z.z = z.z - fwobbletransformdupec_step.z * sin(z.y + sin(fwobbletransformdupec_rotation.x * (z.y + sin(fwobbletransformdupec_rotation.y * z.y)))) * fwobbletransformdupec_strength;
		z.w = z.w - fwobbletransformdupec_step.w * sin(z.w + sin(fwobbletransformdupec_rotation.x * (z.w + sin(fwobbletransformdupec_rotation.y * z.w)))) * fwobbletransformdupec_strength;
	}
}