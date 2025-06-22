// [ID]
// Icosahedron
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// float roundness[0, 1] = 0
// advanced bool hollow[false, true] = false
// advanced float hollow_edge[0, 10] = 0.1
// [CODE]
vec2 icosahedron_sdf(vec4 z4) {
	vec3 p = z4.xyz - ficosahedron_position;
	p = abs(p);
	float phi = 1.618033988749895;
	vec3 n1 = normalize(vec3(phi, 1.0, 0.0));
	vec3 n2 = normalize(vec3(0.0, phi, 1.0));
	vec3 n3 = normalize(vec3(1.0, 0.0, phi));
	float outer_dist = max(max(dot(p, n1), dot(p, n2)), dot(p, n3)) - ficosahedron_size;
	if (ficosahedron_hollow) {
		float inner_size = ficosahedron_size - ficosahedron_hollow_edge;
		float inner_dist = max(max(dot(p, n1), dot(p, n2)), dot(p, n3)) - inner_size;
		outer_dist = max(outer_dist, -inner_dist);
	}
	return vec2(outer_dist + ficosahedron_roundness, 0.0);
}
