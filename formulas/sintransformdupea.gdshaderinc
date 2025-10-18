// [ID]
// Sin transform Dupe A
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// vec2 offset[(-4, -4), (4, 4)] = (0, 0)
// vec2 scale[(-4, -4), (4, 4)] = (1, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void sintransformdupea_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fsintransformdupea_range)) {
		if (fsintransformdupea_axis == 0) z.x = sin((z.x - fsintransformdupea_offset.x) * fsintransformdupea_scale.x) * fsintransformdupea_scale.y + fsintransformdupea_offset.y;
		if (fsintransformdupea_axis == 1) z.y = sin((z.y - fsintransformdupea_offset.x) * fsintransformdupea_scale.x) * fsintransformdupea_scale.y + fsintransformdupea_offset.y;
		if (fsintransformdupea_axis == 2) z.z = sin((z.z - fsintransformdupea_offset.x) * fsintransformdupea_scale.x) * fsintransformdupea_scale.y + fsintransformdupea_offset.y;
		if (fsintransformdupea_axis == 3) z.w = sin((z.w - fsintransformdupea_offset.x) * fsintransformdupea_scale.x) * fsintransformdupea_scale.y + fsintransformdupea_offset.y;
	}
}