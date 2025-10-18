// [ID]
// Wobble Transform Dupe J
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec2 rotation[(-3, -3), (3, 3)] = (3, 2)
// float strength[0, 4] = 1.03
// vec4 step[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.1, 0.1, 0.1, 0.1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void wobbletransformdupej_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransformdupej_range)) {
		z.x = z.x - fwobbletransformdupej_step.x * sin(z.z + sin(fwobbletransformdupej_rotation.x * (z.z + sin(fwobbletransformdupej_rotation.y * z.z)))) * fwobbletransformdupej_strength;
		z.y = z.y - fwobbletransformdupej_step.y * sin(z.x + sin(fwobbletransformdupej_rotation.x * (z.x + sin(fwobbletransformdupej_rotation.y * z.x)))) * fwobbletransformdupej_strength;
		z.z = z.z - fwobbletransformdupej_step.z * sin(z.y + sin(fwobbletransformdupej_rotation.x * (z.y + sin(fwobbletransformdupej_rotation.y * z.y)))) * fwobbletransformdupej_strength;
		z.w = z.w - fwobbletransformdupej_step.w * sin(z.w + sin(fwobbletransformdupej_rotation.x * (z.w + sin(fwobbletransformdupej_rotation.y * z.w)))) * fwobbletransformdupej_strength;
	}
}