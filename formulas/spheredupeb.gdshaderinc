// [ID]
// Sphere Dupe B
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float radius[0, 5] = 1
// advanced bool hollow[false, true] = false
// advanced float hollow_edge[0, 10] = 0.1
// [CODE]
vec2 spheredupeb_sdf(vec4 z4) {
	vec3 p = z4.xyz - fspheredupeb_position;
	float outer_dist = length(p) - fspheredupeb_radius;
	if (fspheredupeb_hollow) {
		float inner_radius = fspheredupeb_radius - fspheredupeb_hollow_edge;
		float inner_dist = length(p) - inner_radius;
		outer_dist = max(outer_dist, -inner_dist);
	}
	return vec2(outer_dist, 0.0);
}
