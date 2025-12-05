// [ID]
// Dodecahedron Dupe A
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// float roundness[0, 1] = 0
// [CODE]
vec2 dodecahedrondupea_sdf(vec4 z4) {
// [PREVENT-REPLACEMENT]
	return vec2(dodecahedron_sdf3d(
		z4.xyz - fdodecahedrondupea_position, fdodecahedrondupea_size) - fdodecahedrondupea_roundness, 0.0
	);
}
