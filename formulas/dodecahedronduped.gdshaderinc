// [ID]
// Dodecahedron Dupe D
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// float roundness[0, 1] = 0
// [CODE]
vec2 dodecahedronduped_sdf(vec4 z4) {
// [PREVENT-REPLACEMENT]
	return vec2(dodecahedron_sdf3d(
		z4.xyz - fdodecahedronduped_position, fdodecahedronduped_size) - fdodecahedronduped_roundness, 0.0
	);
}
