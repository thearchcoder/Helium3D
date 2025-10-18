// [ID]
// Cube Dupe B
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-8, -8, -8), (8, 8, 8)] = (0, 0, 0)
// vec3 size[(0, 0, 0), (5, 5, 5)] = (0.5, 0.5, 0.5)
// float roundness[0, 1] = 0
// advanced bool hollow[false, true] = false
// advanced float hollow_edge[0, 0.5] = 0.1
// [CODE]

vec2 cubedupeb_sdf(vec4 z4) {
// [PREVENT-REPLACEMENT]
	return vec2(hollow_cube_sdf3d(z4.xyz - fcube_position, fcube_size, fcube_hollow ? fcube_hollow_edge : length(fcube_size * 2.0)) - fcube_roundness, 0.0);
}