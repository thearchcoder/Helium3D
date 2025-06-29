// [ID]
// Dodecahedron
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// float roundness[0, 1] = 0
// [CODE]
vec2 dodecahedron_sdf(vec4 z4) {
	return vec2(dodecahedron_sdf3d(z4.xyz - fdodecahedron_position, fdodecahedron_size) - fdodecahedron_roundness, 0.0);
}
