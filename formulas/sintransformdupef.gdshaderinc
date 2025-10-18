// [ID]
// Sin transform Dupe F
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// vec2 offset[(-4, -4), (4, 4)] = (0, 0)
// vec2 scale[(-4, -4), (4, 4)] = (1, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void sintransformdupef_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fsintransformdupef_range)) {
		if (fsintransformdupef_axis == 0) z.x = sin((z.x - fsintransformdupef_offset.x) * fsintransformdupef_scale.x) * fsintransformdupef_scale.y + fsintransformdupef_offset.y;
		if (fsintransformdupef_axis == 1) z.y = sin((z.y - fsintransformdupef_offset.x) * fsintransformdupef_scale.x) * fsintransformdupef_scale.y + fsintransformdupef_offset.y;
		if (fsintransformdupef_axis == 2) z.z = sin((z.z - fsintransformdupef_offset.x) * fsintransformdupef_scale.x) * fsintransformdupef_scale.y + fsintransformdupef_offset.y;
		if (fsintransformdupef_axis == 3) z.w = sin((z.w - fsintransformdupef_offset.x) * fsintransformdupef_scale.x) * fsintransformdupef_scale.y + fsintransformdupef_offset.y;
	}
}