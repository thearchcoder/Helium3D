// [ID]
// Tetrahedron
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// float roundness[0, 1] = 0
// advanced bool hollow[false, true] = false
// advanced float hollow_edge[0, 10] = 0.1
// [CODE]
vec2 tetrahedron_sdf(vec4 z4) {
	vec3 p = z4.xyz - ftetrahedron_position;
	p /= ftetrahedron_size;
	vec3 a = vec3(1, 1, 1);
	vec3 b = vec3(-1, -1, 1);
	vec3 c = vec3(-1, 1, -1);
	vec3 d = vec3(1, -1, -1);
	float outer_dist = max(max(dot(p, a), dot(p, b)), max(dot(p, c), dot(p, d))) - 1.0;
	outer_dist *= ftetrahedron_size;
	if (ftetrahedron_hollow) {
		float inner_size = ftetrahedron_size - ftetrahedron_hollow_edge;
		vec3 inner_p = z4.xyz - ftetrahedron_position;
		inner_p /= inner_size;
		float inner_dist = max(max(dot(inner_p, a), dot(inner_p, b)), max(dot(inner_p, c), dot(inner_p, d))) - 1.0;
		inner_dist *= inner_size;
		outer_dist = max(outer_dist, -inner_dist);
	}
	return vec2(outer_dist + ftetrahedron_roundness, 0.0);
}

