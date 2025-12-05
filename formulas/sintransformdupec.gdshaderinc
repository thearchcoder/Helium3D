// [ID]
// Sin transform Dupe C
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// vec2 offset[(-4, -4), (4, 4)] = (0, 0)
// vec2 scale[(-4, -4), (4, 4)] = (1, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void sintransformdupec_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fsintransformdupec_range)) {
		if (fsintransformdupec_axis == 0) z.x = sin((z.x - fsintransformdupec_offset.x) * fsintransformdupec_scale.x) * fsintransformdupec_scale.y + fsintransformdupec_offset.y;
		if (fsintransformdupec_axis == 1) z.y = sin((z.y - fsintransformdupec_offset.x) * fsintransformdupec_scale.x) * fsintransformdupec_scale.y + fsintransformdupec_offset.y;
		if (fsintransformdupec_axis == 2) z.z = sin((z.z - fsintransformdupec_offset.x) * fsintransformdupec_scale.x) * fsintransformdupec_scale.y + fsintransformdupec_offset.y;
		if (fsintransformdupec_axis == 3) z.w = sin((z.w - fsintransformdupec_offset.x) * fsintransformdupec_scale.x) * fsintransformdupec_scale.y + fsintransformdupec_offset.y;
	}
}