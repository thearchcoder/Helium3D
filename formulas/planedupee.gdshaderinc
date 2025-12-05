// [ID]
// Plane Dupe E
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-5, -5, -5), (5, 5, 5)] = (0, -0.75, 0)
// vec3 direction[(0, 0, 0), (1, 1, 1)] = (0, 1, 0)
// advanced bool thin[false, true] = false
// advanced float thickness[0, 2] = 0.2
// [CODE]

vec2 planedupee_sdf(vec4 z4) {
	vec3 p = z4.xyz - fplanedupee_position;
	float de = dot(p, normalize(fplanedupee_direction));
	if (fplanedupee_thin) de = abs(de) - fplanedupee_thickness;
	return vec2(de, 0.0);
}
