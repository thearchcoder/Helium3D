// [ID]
// Octahedron Dupe C
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// [CODE]

vec2 octahedrondupec_sdf(vec4 z4) {
	vec3 p = z4.xyz - foctahedrondupec_position;
	p = abs(p);
	float outer_dist = (p.x + p.y + p.z - foctahedrondupec_size) * 0.57735027;
	return vec2(outer_dist, 0.0);
}
