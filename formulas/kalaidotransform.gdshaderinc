// [ID]
// Kalaido Transform
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[XY, XZ, YZ, XW, YW, ZW] = XY
// selection mode[Kite 1, Kite 2, Effie] = Kite 1
// float symmetry[1, 50] = 1
// template transform_range
// [CODE]

void kalaidotransform_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fkalaidotransform_range)) {
		if (fkalaidotransform_axis == 0) z4.xy = kalaido(z4.xy, fkalaidotransform_symmetry, fkalaidotransform_mode);
		if (fkalaidotransform_axis == 1) z4.xz = kalaido(z4.xz, fkalaidotransform_symmetry, fkalaidotransform_mode);
		if (fkalaidotransform_axis == 2) z4.yz = kalaido(z4.yz, fkalaidotransform_symmetry, fkalaidotransform_mode);
		if (fkalaidotransform_axis == 3) z4.xw = kalaido(z4.xw, fkalaidotransform_symmetry, fkalaidotransform_mode);
		if (fkalaidotransform_axis == 4) z4.yw = kalaido(z4.yw, fkalaidotransform_symmetry, fkalaidotransform_mode);
		if (fkalaidotransform_axis == 5) z4.zw = kalaido(z4.zw, fkalaidotransform_symmetry, fkalaidotransform_mode);
	}
}
