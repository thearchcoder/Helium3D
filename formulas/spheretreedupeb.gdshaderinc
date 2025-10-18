// [ID]
// Spheretree Dupe B
// [OFFICIAL]
// [DIFS]
// [VARS]
// float symmetry[1, 100] = 1
// [CODE]

void spheretreedupeb_iter(inout vec4 z4, inout float scale, vec4 original_z, float orbit, int i, inout bool escaped) {
	vec3 p = z4.xyz;
	if (i == 0) {
		p /= 3.0;
		p.z += 0.5;
		scale = 1.0 / 0.45;
	}

	const float rad = 0.2;
	const vec3 s0 = vec3(0.0,1.0,rad);
	const vec3 s1 = vec3(sqrt(3.0)/2.0, -0.5,rad);
	const vec3 s2 = vec3(-sqrt(3.0)/2.0, -0.5,rad);
	const vec3 t0 = vec3(0.0,1.0,0.0);
	const vec3 t1 = vec3(sqrt(3.0)/2.0, -0.5,0.0);
	const vec3 t2 = vec3(-sqrt(3.0)/2.0, -0.5,0.0);
	const vec3 n0 = vec3(1.0,0.0,0.0);
	const vec3 n1 = vec3(-0.5, -sqrt(3.0)/2.0,0.0);
	const vec3 n2 = vec3(-0.5, sqrt(3.0)/2.0,0.0);
	const float innerScale = sqrt(3.0)/(1.0 + sqrt(3.0));

	float angle = 3.14159265 / fspheretreedupeb_symmetry;
	float theta = atan(p.y, p.x);
	float r = length(p.xy);
	theta = mod(theta + angle, 2.0 * angle) - angle;
	p.xy = vec2(cos(theta), sin(theta)) * r;

	if (length(p-vec3(0,0,innerScale*0.5)) < innerScale*0.5) {
		escaped = true; // definitely inside
		return;
	}

	float maxH = i == 0 ? -100.0 : 0.4;

	if (p.z > maxH && length(p-vec3(0,0,0.5*1.1)) > 0.5*1.1) {
		escaped = true; // definitely outside
		return;
	}

	if (p.z < maxH && length(p -vec3(0,0,0.5)) > 0.5) {
		// needs a sphere inverse
		float sc =  dot(p, p);
		scale /= sc;
		p /= sc;
	} else {
		// stretch onto a plane at zero
		scale /= dot(p, p);
		p /= dot(p, p);
		p.z -= 1.0;
		p.z *= -1.0;
		p *= sqrt(3.0);
		scale *= sqrt(3.0);
		p.z += 1.0;

		// and rotate it a twelfth of a revolution
		float a = 3.1415/6.0;
		float xx = p.x*cos(a) + p.y*sin(a);
		float yy = -p.x*sin(a) + p.y*cos(a);
		p.x = xx;
		p.y = yy;
	}
	// now modolu the space so we move to being in just the central hexagon, inner radius 0.5
	float h = p.z;
	float x = dot(p, -n2) * 2.0/sqrt(3.0);
	float y = dot(p, -n1) * 2.0/sqrt(3.0);
	x = mod(x, 1.0);
	y = mod(y, 1.0);
	if (x + y > 1.0) {
		x = 1.0 - x;
		y = 1.0 - y;
	}
	p = x*t1 - y*t2;

	// fold the space to be in a kite
	float l0 = dot(p,p);
	float l1 = dot(p-t1, p-t1);
	float l2 = dot(p+t2,p+t2);
	if (l1 < l0 && l1 < l2) p -= t1 * (2.0*dot(t1, p) - 1.0);
	else if (l2 < l0 && l2 < l1) p -= t2 * (2.0 * dot(p, t2) + 1.0);
	p.z = h;

	z4.xyz = p;
}

vec2 spheretreedupeb_sdf(vec4 z4) {
	vec4 z = z4;
	vec4 original_z = z;
	float dz = 1.0;
	float orbit = 100000.0;

	for (int i = 0; i < iterations; i++) {
		bool escaped = false;
		spheretreedupeb_iter(z, dz, original_z, orbit, i, escaped);
		if (escaped) break;
	}

	return vec2((length(z.xyz - vec3(0.0, 0.0, 0.4)) - 0.4) / dz, 0.0);
}