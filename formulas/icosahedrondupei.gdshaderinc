// [ID]
// Icosahedron Dupe I
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// [CODE]
vec2 icosahedrondupei_sdf(vec4 z4) {
// [PREVENT-REPLACEMENT]
	return vec2(icosahedron_sdf3d(
		z4.xyz - ficosahedrondupei_position, ficosahedrondupei_size), 0.0
	);
}