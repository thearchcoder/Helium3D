// [ID]
// Sin transform Dupe B
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// vec2 offset[(-4, -4), (4, 4)] = (0, 0)
// vec2 scale[(-4, -4), (4, 4)] = (1, 1)
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void sintransformdupeb_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fsintransformdupeb_range)) {
		if (fsintransformdupeb_axis == 0) z.x = sin((z.x - fsintransformdupeb_offset.x) * fsintransformdupeb_scale.x) * fsintransformdupeb_scale.y + fsintransformdupeb_offset.y;
		if (fsintransformdupeb_axis == 1) z.y = sin((z.y - fsintransformdupeb_offset.x) * fsintransformdupeb_scale.x) * fsintransformdupeb_scale.y + fsintransformdupeb_offset.y;
		if (fsintransformdupeb_axis == 2) z.z = sin((z.z - fsintransformdupeb_offset.x) * fsintransformdupeb_scale.x) * fsintransformdupeb_scale.y + fsintransformdupeb_offset.y;
		if (fsintransformdupeb_axis == 3) z.w = sin((z.w - fsintransformdupeb_offset.x) * fsintransformdupeb_scale.x) * fsintransformdupeb_scale.y + fsintransformdupeb_offset.y;
	}
}