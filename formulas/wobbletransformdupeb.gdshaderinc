// [ID]
// Wobble Transform Dupe B
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// vec2 rotation[(-3, -3), (3, 3)] = (3, 2)
// float strength[0, 4] = 1.03
// vec4 step[(0, 0, 0, 0), (2, 2, 2, 2)] = (0.1, 0.1, 0.1, 0.1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void wobbletransformdupeb_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransformdupeb_range)) {
		z.x = z.x - fwobbletransformdupeb_step.x * sin(z.z + sin(fwobbletransformdupeb_rotation.x * (z.z + sin(fwobbletransformdupeb_rotation.y * z.z)))) * fwobbletransformdupeb_strength;
		z.y = z.y - fwobbletransformdupeb_step.y * sin(z.x + sin(fwobbletransformdupeb_rotation.x * (z.x + sin(fwobbletransformdupeb_rotation.y * z.x)))) * fwobbletransformdupeb_strength;
		z.z = z.z - fwobbletransformdupeb_step.z * sin(z.y + sin(fwobbletransformdupeb_rotation.x * (z.y + sin(fwobbletransformdupeb_rotation.y * z.y)))) * fwobbletransformdupeb_strength;
		z.w = z.w - fwobbletransformdupeb_step.w * sin(z.w + sin(fwobbletransformdupeb_rotation.x * (z.w + sin(fwobbletransformdupeb_rotation.y * z.w)))) * fwobbletransformdupeb_strength;
	}
}