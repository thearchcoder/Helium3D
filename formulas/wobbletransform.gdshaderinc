// [ID]
// Wobble transform
// [INDEX]
// 26
// [VARS]
// selection axis[X, Y, Z, W] = X
// float offset[-4, 4] = 0
// float scale[0, 5] = 0.5
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]
uniform int fwobbletransform_axis;
uniform vec2 fwobbletransform_offset;
uniform vec2 fwobbletransform_scale;
uniform vec2 fwobbletransform_range;

void wobbletransform_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fwobbletransform_range)) {

	}
}