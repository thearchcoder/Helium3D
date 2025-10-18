// [ID]
// Sin transform Dupe G
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// vec2 offset[(-4, -4), (4, 4)] = (0, 0)
// vec2 scale[(-4, -4), (4, 4)] = (1, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void sintransformdupeg_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fsintransformdupeg_range)) {
		if (fsintransformdupeg_axis == 0) z.x = sin((z.x - fsintransformdupeg_offset.x) * fsintransformdupeg_scale.x) * fsintransformdupeg_scale.y + fsintransformdupeg_offset.y;
		if (fsintransformdupeg_axis == 1) z.y = sin((z.y - fsintransformdupeg_offset.x) * fsintransformdupeg_scale.x) * fsintransformdupeg_scale.y + fsintransformdupeg_offset.y;
		if (fsintransformdupeg_axis == 2) z.z = sin((z.z - fsintransformdupeg_offset.x) * fsintransformdupeg_scale.x) * fsintransformdupeg_scale.y + fsintransformdupeg_offset.y;
		if (fsintransformdupeg_axis == 3) z.w = sin((z.w - fsintransformdupeg_offset.x) * fsintransformdupeg_scale.x) * fsintransformdupeg_scale.y + fsintransformdupeg_offset.y;
	}
}