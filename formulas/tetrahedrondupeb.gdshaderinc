// [ID]
// Tetrahedron Dupe B
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// float size[0, 5] = 1
// [CODE]

vec2 tetrahedrondupeb_sdf(vec4 z4) {
	vec3 p = z4.xyz - ftetrahedrondupeb_position;
	p /= ftetrahedrondupeb_size;
	vec3 a = vec3(1, 1, 1);
	vec3 b = vec3(-1, -1, 1);
	vec3 c = vec3(-1, 1, -1);
	vec3 d = vec3(1, -1, -1);
	float outer_dist = max(max(dot(p, a), dot(p, b)), max(dot(p, c), dot(p, d))) - 1.0;
	outer_dist *= ftetrahedrondupeb_size;
	outer_dist *= 0.5;
	return vec2(outer_dist, 0.0);
}
