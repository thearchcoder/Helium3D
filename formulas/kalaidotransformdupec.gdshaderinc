// [ID]
// Kalaido Transform Dupe C
// [OFFICIAL]
// [TRANSFORM]
// [VARS]
// selection axis[XY, XZ, YZ, XW, YW, ZW] = XY
// selection mode[Kite 1, Kite 2, Effie] = Kite 1
// float symmetry[1, 50] = 1
// vec2 range[(0, 0), (100, 100)] = (0, 100)
// [CODE]

void kalaidotransformdupec_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i) {
	if (check_range(i, fkalaidotransformdupec_range)) {
		if (fkalaidotransformdupec_axis == 0) z4.xy = kalaido(z4.xy, fkalaidotransformdupec_symmetry, fkalaidotransformdupec_mode);
		if (fkalaidotransformdupec_axis == 1) z4.xz = kalaido(z4.xz, fkalaidotransformdupec_symmetry, fkalaidotransformdupec_mode);
		if (fkalaidotransformdupec_axis == 2) z4.yz = kalaido(z4.yz, fkalaidotransformdupec_symmetry, fkalaidotransformdupec_mode);
		if (fkalaidotransformdupec_axis == 3) z4.xw = kalaido(z4.xw, fkalaidotransformdupec_symmetry, fkalaidotransformdupec_mode);
		if (fkalaidotransformdupec_axis == 4) z4.yw = kalaido(z4.yw, fkalaidotransformdupec_symmetry, fkalaidotransformdupec_mode);
		if (fkalaidotransformdupec_axis == 5) z4.zw = kalaido(z4.zw, fkalaidotransformdupec_symmetry, fkalaidotransformdupec_mode);
	}
}
