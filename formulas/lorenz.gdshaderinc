// [ID]
// Lorenz
// [OFFICIAL]
// [DIFS]
// [VARS]
// vec3 initial_position[(-2, -2, -2), (2, 2, 2)] = (0.2, 0, 0)
// float dt[0, 0.2] = 0.01
// float sigma[9, 11] = 10
// float ro[27, 29] = 28
// float beta[2, 3] = 2.66666
// [CODE]

//uniform sampler3D lorenz_distance_field;
//uniform vec3 field_bounds;
//
//vec2 lorenz_sdf(vec4 z4d) {
	//vec3 z = z4d.xyz;
	//
	//vec3 uv = (z / field_bounds) + 0.5;
	//
	//if (any(lessThan(uv, vec3(0.0))) || any(greaterThan(uv, vec3(1.0)))) {
		//return vec2(length(z) - 10.0, 0.0);
	//}
	//
	//float dist = texture(lorenz_distance_field, uv).r;
	//
	//return vec2(dist - 0.05, 0.0);
//}
