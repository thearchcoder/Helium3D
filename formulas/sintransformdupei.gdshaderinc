// [ID]
// Sin transform Dupe I
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// vec2 offset[(-4, -4), (4, 4)] = (0, 0)
// vec2 scale[(-4, -4), (4, 4)] = (1, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void sintransformdupei_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fsintransformdupei_range)) {
		if (fsintransformdupei_axis == 0) z.x = sin((z.x - fsintransformdupei_offset.x) * fsintransformdupei_scale.x) * fsintransformdupei_scale.y + fsintransformdupei_offset.y;
		if (fsintransformdupei_axis == 1) z.y = sin((z.y - fsintransformdupei_offset.x) * fsintransformdupei_scale.x) * fsintransformdupei_scale.y + fsintransformdupei_offset.y;
		if (fsintransformdupei_axis == 2) z.z = sin((z.z - fsintransformdupei_offset.x) * fsintransformdupei_scale.x) * fsintransformdupei_scale.y + fsintransformdupei_offset.y;
		if (fsintransformdupei_axis == 3) z.w = sin((z.w - fsintransformdupei_offset.x) * fsintransformdupei_scale.x) * fsintransformdupei_scale.y + fsintransformdupei_offset.y;
	}
}