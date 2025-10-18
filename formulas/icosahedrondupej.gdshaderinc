// [ID]
// Icosahedron Dupe J
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// [CODE]
vec2 icosahedrondupej_sdf(vec4 z4) {
// [PREVENT-REPLACEMENT]
	return vec2(icosahedron_sdf3d(
		z4.xyz - ficosahedrondupej_position, ficosahedrondupej_size), 0.0
	);
}