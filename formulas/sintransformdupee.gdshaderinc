// [ID]
// Sin transform Dupe E
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// vec2 offset[(-4, -4), (4, 4)] = (0, 0)
// vec2 scale[(-4, -4), (4, 4)] = (1, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void sintransformdupee_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fsintransformdupee_range)) {
		if (fsintransformdupee_axis == 0) z.x = sin((z.x - fsintransformdupee_offset.x) * fsintransformdupee_scale.x) * fsintransformdupee_scale.y + fsintransformdupee_offset.y;
		if (fsintransformdupee_axis == 1) z.y = sin((z.y - fsintransformdupee_offset.x) * fsintransformdupee_scale.x) * fsintransformdupee_scale.y + fsintransformdupee_offset.y;
		if (fsintransformdupee_axis == 2) z.z = sin((z.z - fsintransformdupee_offset.x) * fsintransformdupee_scale.x) * fsintransformdupee_scale.y + fsintransformdupee_offset.y;
		if (fsintransformdupee_axis == 3) z.w = sin((z.w - fsintransformdupee_offset.x) * fsintransformdupee_scale.x) * fsintransformdupee_scale.y + fsintransformdupee_offset.y;
	}
}