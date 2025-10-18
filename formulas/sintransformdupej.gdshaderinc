// [ID]
// Sin transform Dupe J
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// vec2 offset[(-4, -4), (4, 4)] = (0, 0)
// vec2 scale[(-4, -4), (4, 4)] = (1, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void sintransformdupej_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fsintransformdupej_range)) {
		if (fsintransformdupej_axis == 0) z.x = sin((z.x - fsintransformdupej_offset.x) * fsintransformdupej_scale.x) * fsintransformdupej_scale.y + fsintransformdupej_offset.y;
		if (fsintransformdupej_axis == 1) z.y = sin((z.y - fsintransformdupej_offset.x) * fsintransformdupej_scale.x) * fsintransformdupej_scale.y + fsintransformdupej_offset.y;
		if (fsintransformdupej_axis == 2) z.z = sin((z.z - fsintransformdupej_offset.x) * fsintransformdupej_scale.x) * fsintransformdupej_scale.y + fsintransformdupej_offset.y;
		if (fsintransformdupej_axis == 3) z.w = sin((z.w - fsintransformdupej_offset.x) * fsintransformdupej_scale.x) * fsintransformdupej_scale.y + fsintransformdupej_offset.y;
	}
}