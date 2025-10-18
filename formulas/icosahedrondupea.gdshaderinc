// [ID]
// Icosahedron Dupe A
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// [CODE]
vec2 icosahedrondupea_sdf(vec4 z4) {
// [PREVENT-REPLACEMENT]
	return vec2(icosahedron_sdf3d(
		z4.xyz - ficosahedrondupea_position, ficosahedrondupea_size), 0.0
	);
}