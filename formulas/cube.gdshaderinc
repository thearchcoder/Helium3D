// [ID]
// Cube
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// vec3 size[(0, 0, 0), (5, 5, 5)] = (0.5, 0.5, 0.5)
// float roundness[0, 1] = 0
// advanced bool hollow[false, true] = false
// advanced float hollow_edge[0, 10] = 10
// [CODE]

vec2 cube_sdf(vec4 z4) {
	vec3 p = z4.xyz - fcube_position;

	vec3 q = abs(p) - fcube_size;
	float outer_dist = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);

	if (fcube_hollow) {
		vec3 inner_size = fcube_size - vec3(fcube_hollow_edge);
		vec3 inner_q = abs(p) - inner_size;
		float inner_dist = length(max(inner_q, 0.0)) + min(max(inner_q.x, max(inner_q.y, inner_q.z)), 0.0);
		outer_dist = max(outer_dist, -inner_dist);
	}

	return vec2(outer_dist + fcube_roundness, 0.0);
}