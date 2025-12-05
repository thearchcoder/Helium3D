// [ID]
// Wobble Transform Dupe H
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec2 rotation[(-3, -3), (3, 3)] = (3, 2)
// float strength[0, 4] = 1.03
// vec4 step[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.1, 0.1, 0.1, 0.1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void wobbletransformdupeh_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransformdupeh_range)) {
		z.x = z.x - fwobbletransformdupeh_step.x * sin(z.z + sin(fwobbletransformdupeh_rotation.x * (z.z + sin(fwobbletransformdupeh_rotation.y * z.z)))) * fwobbletransformdupeh_strength;
		z.y = z.y - fwobbletransformdupeh_step.y * sin(z.x + sin(fwobbletransformdupeh_rotation.x * (z.x + sin(fwobbletransformdupeh_rotation.y * z.x)))) * fwobbletransformdupeh_strength;
		z.z = z.z - fwobbletransformdupeh_step.z * sin(z.y + sin(fwobbletransformdupeh_rotation.x * (z.y + sin(fwobbletransformdupeh_rotation.y * z.y)))) * fwobbletransformdupeh_strength;
		z.w = z.w - fwobbletransformdupeh_step.w * sin(z.w + sin(fwobbletransformdupeh_rotation.x * (z.w + sin(fwobbletransformdupeh_rotation.y * z.w)))) * fwobbletransformdupeh_strength;
	}
}