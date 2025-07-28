// [ID]
// Octahedron
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// float roundness[0, 1] = 0
// [CODE]
vec2 octahedron_sdf(vec4 z4) {
	vec3 p = z4.xyz - foctahedron_position;
	p = abs(p);
	float outer_dist = (p.x + p.y + p.z - foctahedron_size) * 0.57735027;
	return vec2(outer_dist - foctahedron_roundness, 0.0);
}

