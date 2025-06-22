// [ID]
// Dodecahedron
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// float roundness[0, 1] = 0
// advanced bool hollow[false, true] = false
// advanced float hollow_edge[0, 10] = 0.1
// [CODE]
vec2 dodecahedron_sdf(vec4 z4) {
	vec3 p = z4.xyz - fdodecahedron_position;
	vec3 n = normalize(vec3(1.618033988749895, 1.0, 0.572061));
	p = abs(p);
	float a = dot(p, n.xyz);
	float b = dot(p, n.zxy);
	float c = dot(p, n.yzx);
	float outer_dist = max(max(a, b), c) - fdodecahedron_size;
	if (fdodecahedron_hollow) {
		float inner_size = fdodecahedron_size - fdodecahedron_hollow_edge;
		float inner_dist = max(max(a, b), c) - inner_size;
		outer_dist = max(outer_dist, -inner_dist);
	}
	return vec2(outer_dist + fdodecahedron_roundness, 0.0);
}