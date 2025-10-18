// [ID]
// Sin transform Dupe H
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// vec2 offset[(-4, -4), (4, 4)] = (0, 0)
// vec2 scale[(-4, -4), (4, 4)] = (1, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void sintransformdupeh_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fsintransformdupeh_range)) {
		if (fsintransformdupeh_axis == 0) z.x = sin((z.x - fsintransformdupeh_offset.x) * fsintransformdupeh_scale.x) * fsintransformdupeh_scale.y + fsintransformdupeh_offset.y;
		if (fsintransformdupeh_axis == 1) z.y = sin((z.y - fsintransformdupeh_offset.x) * fsintransformdupeh_scale.x) * fsintransformdupeh_scale.y + fsintransformdupeh_offset.y;
		if (fsintransformdupeh_axis == 2) z.z = sin((z.z - fsintransformdupeh_offset.x) * fsintransformdupeh_scale.x) * fsintransformdupeh_scale.y + fsintransformdupeh_offset.y;
		if (fsintransformdupeh_axis == 3) z.w = sin((z.w - fsintransformdupeh_offset.x) * fsintransformdupeh_scale.x) * fsintransformdupeh_scale.y + fsintransformdupeh_offset.y;
	}
}