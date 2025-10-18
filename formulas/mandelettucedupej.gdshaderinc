// [ID]
// Mandelettuce Dupe J
// [DESCRIPTION]
// Found this in a old shadertoy i made, not sure what this is since i completely forgot about this.
// Power goes from 2 to 8.
// [OFFICIAL]
// [ESCAPE]
// [VARS]
// bool is_julia[false, true] = true
// vec3 julia_c[(-1, -1, -1), (1, 1, 1)] = (-0.5, -0.1, -0.1)
// int power[2, 8] = 2
// [CODE]

vec3 mandelettucedupej_square(vec3 p, inout float dz) {
	dz = dz * 2.0 * length(p);
	float psi = abs(mod(atan(p.z, p.y) + PI / 8.0, PI / 4.0) - PI / 8.0);
	p.yz = vec2(cos(psi), sin(psi)) * length(p.yz);
	vec3 p2 = p * p;
	p = vec3(vec2(p2.x-p2.y,2.0*p.x*p.y)*(1.0-p2.z/(p2.x+p2.y+p2.z)), 2.0*p.z*sqrt(p2.x+p2.y));
	return p;
}

vec3 mandelettucedupej_cube(vec3 p, inout float dz) {
	dz = dz * 3.0 * length(p) * length(p);
	float psi = abs(mod(atan(p.z, p.y) + PI / 8.0, PI / 4.0) - PI / 8.0);
	p.yz = vec2(cos(psi), sin(psi)) * length(p.yz);
	vec3 p2 = p * p;
	vec3 p3 = p * p2;
	p = vec3(vec2(p3.x-3.0*p.x*p2.y,3.0*p2.x*p.y-p3.y)*(1.0-p2.z/(p2.x+p2.y+p2.z)), p.z*(3.0*(p2.x+p2.y)-p2.z));
	return p;
}

vec3 mandelettucedupej_power_transform(vec3 p, inout float dz, int n) {
	if (n == 2) {
		return mandelettucedupej_square(p, dz);
	} else if (n == 3) {
		return mandelettucedupej_cube(p, dz);
	} else if (n == 4) {
		return mandelettucedupej_square(mandelettucedupej_square(p, dz), dz);
	} else if (n == 5) {
		return mandelettucedupej_square(mandelettucedupej_cube(p, dz), dz);
	} else if (n == 6) {
		return mandelettucedupej_cube(mandelettucedupej_square(p, dz), dz);
	} else if (n == 7) {
		return mandelettucedupej_cube(mandelettucedupej_cube(p, dz), dz);
	} else if (n == 8) {
		return mandelettucedupej_square(mandelettucedupej_square(mandelettucedupej_square(p, dz), dz), dz);
	}
	return mandelettucedupej_square(p, dz);
}
void mandelettucedupej_iter(inout vec4 z, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 c = fmandelettucedupej_is_julia ? fmandelettucedupej_julia_c : original_z.xyz;
	vec3 p = z.xyz;
	p = mandelettucedupej_power_transform(p, dz, fmandelettucedupej_power) + c;
	z.xyz = p;
}