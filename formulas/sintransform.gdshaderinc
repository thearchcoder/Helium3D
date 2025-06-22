// [ID]
// Sin transform
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[X, Y, Z, W] = X
// vec2 offset[(-4, -4), (4, 4)] = (0, 0)
// vec2 scale[(-4, -4), (4, 4)] = (1, 1)
// template transform_range
// [CODE]

void sintransform_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fsintransform_range)) {
		if (fsintransform_axis == 0) z.x = sin((z.x - fsintransform_offset.x) * fsintransform_scale.x) * fsintransform_scale.y + fsintransform_offset.y;
		if (fsintransform_axis == 1) z.y = sin((z.y - fsintransform_offset.x) * fsintransform_scale.x) * fsintransform_scale.y + fsintransform_offset.y;
		if (fsintransform_axis == 2) z.z = sin((z.z - fsintransform_offset.x) * fsintransform_scale.x) * fsintransform_scale.y + fsintransform_offset.y;
		if (fsintransform_axis == 3) z.w = sin((z.w - fsintransform_offset.x) * fsintransform_scale.x) * fsintransform_scale.y + fsintransform_offset.y;
	}
}