// [ID]
// Tetrahedron Dupe C
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// [CODE]

vec2 tetrahedrondupec_sdf(vec4 z4) {
	vec3 p = z4.xyz - ftetrahedrondupec_position;
	p /= ftetrahedrondupec_size;
	vec3 a = vec3(1, 1, 1);
	vec3 b = vec3(-1, -1, 1);
	vec3 c = vec3(-1, 1, -1);
	vec3 d = vec3(1, -1, -1);
	float outer_dist = max(max(dot(p, a), dot(p, b)), max(dot(p, c), dot(p, d))) - 1.0;
	outer_dist *= ftetrahedrondupec_size;
	outer_dist *= 0.5;
	return vec2(outer_dist, 0.0);
}
