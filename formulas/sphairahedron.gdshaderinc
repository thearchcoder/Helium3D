// [ID]
// Sphairahedron
// [OFFICIAL]
// [DIFS]
// [VARS]
// selection cube_type[Cube A, Cube B, Cube C] = Cube A
// float zc[0.0, 1.5] = 1.0;
// float zb[0.0, 1.5] = 0.3;
// [CODE]
// Credit's to soma arc for the original code.
// I've written the original license text below.

/*
Created by soma_arc - 2021
This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported.
*/

// from Syntopia http://blog.hvidtfeldts.net/index.php/2015/01/path-tracing-3d-fractals/
vec2 rand2n(vec2 co, float sampleIndex) {
	vec2 seed = co * (sampleIndex + 1.0);
	seed += vec2(-1, 1);
	// implementation based on: lumina.sourceforge.net/Tutorials/Noise.html
	return vec2(fract(sin(dot(seed.xy, vec2(12.9898,78.233))) * 43758.5453), fract(cos(dot(seed.xy, vec2(4.898,7.23))) * 23421.631));
}

struct Plane {
	vec3 p1;
	vec3 p2;
	vec3 p3;
	vec3 normal;
};

const float EPSILON = 0.001;
const float RT_3 = sqrt(3.);
const float RT_3_INV = 1.0 / sqrt(3.);
const Plane PL1 = Plane(vec3(0, 5, RT_3_INV), vec3(1, 1, 0), vec3(2, 2, -RT_3_INV), normalize(vec3(RT_3 * 0.5, 0, 1.5)));
const Plane PL2 = Plane(vec3(0, 3, -RT_3_INV), vec3(1, 3, 0), vec3(2, 2, RT_3_INV), normalize(vec3(RT_3 * 0.5, 0, -1.5)));
const Plane PL3 = Plane(vec3(-0.5, 0, 1), vec3(-0.5, 1, 0), vec3(-0.5, 2, 1), vec3(-1, 0, 0));

vec4 getS2A(float zb, float zc) {
	float r2 = 0.5 + (zb * zc) / 3.0;
	return vec4(1. - r2, 0, 0, r2);
}

vec4 getS4A(float zb, float zc) {
	float r4 = 0.5 + (zb * zb - zb * zc) / 3.0;
	return vec4(-(1. - r4) * 0.5, zb, sqrt(3.) * (1. - r4) * 0.5, r4);
}

vec4 getS6A(float zb, float zc) {
	float r6 = 0.5 + (-zb * zc + zc * zc) / 3.0;
	return vec4(-(1. - r6) * 0.5, zc, -sqrt(3.) * (1. - r6) * 0.5, r6);
}

vec4 getInversionSphereA(float zb, float zc) {
	vec4 localS6 = getS6A(zb, zc);
	return vec4(-localS6.x, -localS6.y, localS6.z, localS6.w);
}

vec4 getS2B(float zb, float zc) {
	float r2 = (3. * RT_3 + 2. * RT_3 * zb * zc) / 9.0;
	return vec4((2. - RT_3 * r2) * 0.5, 0, r2 * 0.5, r2);
}

vec4 getS4B(float zb, float zc) {
	float r4 = (3. * zb * zb - 4. * zb * zc + 3.) / 9.0;
	return vec4(-(1. - r4) * 0.5, zb, RT_3 * (1. - r4) * 0.5, r4);
}

vec4 getS6B(float zb, float zc) {
	float r6 = (3. * zc * zc - 2. * zb * zc + 6.) / 9.0;
	return vec4(-(1. - r6) * 0.5, zc, -RT_3 * (1. - r6) * 0.5, r6);
}

vec4 getInversionSphereB(float zb, float zc) {
	vec4 localS6 = getS6B(zb, zc);
	return vec4(-localS6.x, -localS6.y, localS6.z, localS6.w);
}

vec4 getS2C(float zb, float zc) {
	float r2 = (zb * zb + 2. * zb * zc + 6.) / (5. * RT_3);
	return vec4((2. - RT_3 * r2) * 0.5, 0, r2 * 0.5, r2);
}

vec4 getS4C(float zb, float zc) {
	float r4 = (3. * zb * zb - 4. * zb * zc + 3.) / (5. * RT_3);
	return vec4(-0.5, zb, RT_3 / 2. - r4, r4);
}

vec4 getS6C(float zb, float zc) {
	float r6 = (-zb * zb - 2. * zb * zc + 5. * zc * zc + 9.) / 15.0;
	return vec4(-(1. - r6) * 0.5, zc, -RT_3 * (1. - r6) * 0.5, r6);
}

vec4 getInversionSphereC(float zb, float zc) {
	vec4 localS6 = getS6C(zb, zc);
	return vec4(-localS6.x, -localS6.y, localS6.z, localS6.w);
}

const float MAX_FLOAT = 1e20;
const float THRESHOLD = 0.001;

bool intersectBoundingPlane(const vec3 n, const vec3 p,
							const vec3 rayOrigin, const vec3 rayDir,
							inout float t0, inout float t1) {
	float d = -dot(p, n);
	float v = dot(n, rayDir);
	float t = -(dot(n, rayOrigin) + d) / v;
	if(THRESHOLD < t){
		if(v < 0.) {
			t0 = max(t, t0);
			t1 = MAX_FLOAT;
		} else {
			t0 = t0;
			t1 = t;
		}
		return true;
	}
	t0 = t0;
	t1 = MAX_FLOAT;
	return (v < 0.);
}

vec4 sphereFromPoints(vec3 p0, vec3 p1, vec3 p2, vec3 p3){
	float coefficient0, coefficient1, coefficient2, coefficient3, coefficient4;
	float coefficient5, coefficient6, coefficient7, coefficient8, coefficient9;
	float coefficient10, coefficient11;
	coefficient0 = 2. * (p1.x - p0.x);
	coefficient1 = 2. * (p1.y - p0.y);
	coefficient2 = 2. * (p1.z - p0.z);
	coefficient3 = -(pow(p0.x, 2.) + pow(p0.y, 2.) + pow(p0.z, 2.)) +
					 pow(p1.x, 2.) + pow(p1.y, 2.) + pow(p1.z, 2.);
	coefficient4 = 2. * (p2.x - p1.x);
	coefficient5 = 2. * (p2.y - p1.y);
	coefficient6 = 2. * (p2.z - p1.z);
	coefficient7 = -(pow(p1.x, 2.) + pow(p1.y, 2.) + pow(p1.z, 2.)) +
					 pow(p2.x, 2.) + pow(p2.y, 2.) + pow(p2.z, 2.);
	coefficient8 = 2. * (p3.x - p2.x);
	coefficient9 = 2. * (p3.y - p2.y);
	coefficient10 = 2. * (p3.z - p2.z);
	coefficient11 = -(pow(p2.x, 2.) + pow(p2.y, 2.) + pow(p2.z, 2.)) +
					  pow(p3.x, 2.) + pow(p3.y, 2.) + pow(p3.z, 2.);

	int col = 0;
	float maxValue = abs(coefficient0);
	if (abs(coefficient4) > maxValue) {
		col = 1;
		maxValue = abs(coefficient4);
	}
	if (abs(coefficient8) > maxValue) {
		col = 2;
		maxValue = abs(coefficient8);
	}

	if (col == 1) {
		float tmp0 = coefficient4;
		float tmp1 = coefficient5;
		float tmp2 = coefficient6;
		float tmp3 = coefficient7;
		coefficient4 = coefficient0;
		coefficient5 = coefficient1;
		coefficient6 = coefficient2;
		coefficient7 = coefficient3;
		coefficient0 = tmp0;
		coefficient1 = tmp1;
		coefficient2 = tmp2;
		coefficient3 = tmp3;
	}

	if (col == 2) {
		float tmp0 = coefficient8;
		float tmp1 = coefficient9;
		float tmp2 = coefficient10;
		float tmp3 = coefficient11;
		coefficient8 = coefficient0;
		coefficient9 = coefficient1;
		coefficient10 = coefficient2;
		coefficient11 = coefficient3;
		coefficient0 = tmp0;
		coefficient1 = tmp1;
		coefficient2 = tmp2;
		coefficient3 = tmp3;
	}

	float vkk = coefficient0;
	float vik = coefficient4;
	coefficient4 = coefficient4 - vik * (coefficient0 / vkk);
	coefficient5 = coefficient5 - vik * (coefficient1 / vkk);
	coefficient6 = coefficient6 - vik * (coefficient2 / vkk);
	coefficient7 = coefficient7 - vik * (coefficient3 / vkk);

	vik = coefficient8;
	coefficient8 = coefficient8 - vik * (coefficient0 / vkk);
	coefficient9 = coefficient9 - vik * (coefficient1 / vkk);
	coefficient10 = coefficient10 - vik * (coefficient2 / vkk);
	coefficient11 = coefficient11 - vik * (coefficient3 / vkk);

	col = 1;
	maxValue = abs(coefficient5);

	if (abs(coefficient9) > maxValue) {
		col = 2;
		maxValue = abs(coefficient9);
	}

	if (col == 2) {
		float tmp0 = coefficient8;
		float tmp1 = coefficient9;
		float tmp2 = coefficient10;
		float tmp3 = coefficient11;
		coefficient8 = coefficient4;
		coefficient9 = coefficient5;
		coefficient10 = coefficient6;
		coefficient11 = coefficient7;
		coefficient4 = tmp0;
		coefficient5 = tmp1;
		coefficient6 = tmp2;
		coefficient7 = tmp3;
	}

	vkk = coefficient5;
	vik = coefficient9;

	coefficient9 = coefficient9 - vik * (coefficient5 / vkk);
	coefficient10 = coefficient10 - vik * (coefficient6 / vkk);
	coefficient11 = coefficient11 - vik * (coefficient7 / vkk);

	coefficient11 = coefficient11 / coefficient10;

	float acc = 0.0;
	acc += coefficient6 * coefficient11;

	coefficient7 = (coefficient7 - acc) / coefficient5;

	acc = 0.0;
	acc += coefficient1 * coefficient7;
	acc += coefficient2 * coefficient11;

	coefficient3 = (coefficient3 - acc) / coefficient0;

	vec3 center = vec3(coefficient3, coefficient7, coefficient11);
	float r = length(center - p0);
	return vec4(center, r);
}

vec3 invertOnPoint(vec4 sphere, vec3 p) {
	vec3 d = p - sphere.xyz;
	float len = length(d);
	return d * (sphere.r * sphere.r / (len * len)) + sphere.xyz;
}

vec4 invertOnSphere(vec4 invSphere, vec4 s) {
	float r = s.w;
	float coeffR = r * RT_3 / 3.;
	vec3 p1 = invertOnPoint(invSphere, s.xyz + vec3(coeffR, coeffR, coeffR));
	vec3 p2 = invertOnPoint(invSphere, s.xyz + vec3(-coeffR, -coeffR, -coeffR));
	vec3 p3 = invertOnPoint(invSphere, s.xyz + vec3(coeffR, -coeffR, -coeffR));
	vec3 p4 = invertOnPoint(invSphere, s.xyz + vec3(coeffR, coeffR, -coeffR));
	return sphereFromPoints(p1, p2, p3, p4);
}

vec4 invertOnPlane(vec4 invSphere, Plane p) {
	return sphereFromPoints(invertOnPoint(invSphere, p.p1),
							invertOnPoint(invSphere, p.p2),
							invertOnPoint(invSphere, p.p3),
							invSphere.xyz);
}

vec4 computeGSpheres0(vec4 inversionSphere) {
	return invertOnPlane(inversionSphere, PL1);
}

vec4 computeGSpheres1(vec4 inversionSphere, vec4 s2) {
	return invertOnSphere(inversionSphere, s2);
}

vec4 computeGSpheres2(vec4 inversionSphere) {
	return invertOnPlane(inversionSphere, PL2);
}

vec4 computeGSpheres3(vec4 inversionSphere, vec4 s4) {
	return invertOnSphere(inversionSphere, s4);
}

vec4 computeGSpheres4(vec4 inversionSphere) {
	return invertOnPlane(inversionSphere, PL3);
}

vec4 computeGSpheres5(vec4 inversionSphere, vec4 s6) {
	return invertOnSphere(inversionSphere, s6);
}

vec3 computeVertex(vec4 a, vec4 b, vec4 c) {
	float AB = (dot(a.xyz, a.xyz) - dot(b.xyz, b.xyz) - a.w * a.w + b.w * b.w) * 0.5 -
			   dot(a.xyz, a.xyz) + dot(a.xyz, b.xyz);
	float AC = (dot(a.xyz, a.xyz) - dot(c.xyz, c.xyz) - a.w * a.w + c.w * c.w) * 0.5 -
			   dot(a.xyz, a.xyz) + dot(a.xyz, c.xyz);
	float x = -dot(a.xyz, a.xyz) - dot(b.xyz, b.xyz) + 2. * dot(a.xyz, b.xyz);
	float y = -dot(a.xyz, a.xyz) - dot(c.xyz, c.xyz) + 2. * dot(a.xyz, c.xyz);
	float z = -dot(a.xyz, a.xyz) + dot(a.xyz, b.xyz) +
			   dot(a.xyz, c.xyz) - dot(b.xyz, c.xyz);
	float s = (AB * y - AC * z) / (x * y - z * z);
	float t = (AC * x - AB * z) / (x * y - z * z);
	return a.xyz + (b.xyz - a.xyz) * s + (c.xyz - a.xyz) * t;
}

vec3 computeVertexes0(vec4 g0, vec4 g1, vec4 g2) {
	return computeVertex(g0, g1, g2);
}

vec3 computeVertexes1(vec4 g0, vec4 g3, vec4 g4) {
	return computeVertex(g0, g3, g4);
}

vec3 computeVertexes2(vec4 g2, vec4 g4, vec4 g5) {
	return computeVertex(g2, g4, g5);
}

vec3 computeVertexes3(vec4 g0, vec4 g1, vec4 g3) {
	return computeVertex(g0, g1, g3);
}

vec3 computeVertexes4(vec4 g3, vec4 g4, vec4 g5) {
	return computeVertex(g3, g4, g5);
}

vec3 computeVertexes5(vec4 g1, vec4 g2, vec4 g5) {
	return computeVertex(g1, g2, g5);
}

vec3 computeVertexes6(vec4 g1, vec4 g3, vec4 g5) {
	return computeVertex(g1, g3, g5);
}

vec3 computeVertexes7(vec4 g0, vec4 g2, vec4 g4) {
	return computeVertex(g0, g2, g4);
}

Plane computeDividePlane(vec4 inversionSphere, vec3 v0, vec3 v1, vec3 v2) {
	vec3 p1 = invertOnPoint(inversionSphere, v0);
	vec3 p2 = invertOnPoint(inversionSphere, v1);
	vec3 p3 = invertOnPoint(inversionSphere, v2);

	vec3 v1diff = p2 - p1;
	vec3 v2diff = p3 - p1;
	vec3 normal = normalize(cross(v1diff, v2diff));
	if (normal.y < 0.0) {
		normal = -normal;
	}

	return Plane(p1, p2, p3, normal);
}

vec4 computeConvexSphere(vec4 inversionSphere, Plane dividePlane) {
	return invertOnPlane(inversionSphere, dividePlane);
}

bool intersectPlane(vec3 p, vec3 n,
					vec3 rayOrigin, vec3 rayDir,
					 inout float minDist,
					inout vec3 intersection, inout vec3 normal){
	float d = -dot(p, n);
	float v = dot(n, rayDir);
	float t = -(dot(n, rayOrigin) + d) / v;
	if(EPSILON < t && t < minDist){
		intersection = rayOrigin + t * rayDir;
		normal = n;
		minDist = t;
		return true;
	}
	return false;
}

vec2 opUnion(vec2 d1, vec2 d2) {
	return (d1.x < d2.x) ? d1 : d2;
}

float distSphere(vec3 p, vec4 sphere){
	return distance(p, sphere.xyz) - sphere.w;
}

float distPlane(vec3 pos, vec3 p, vec3 n) {
	return dot(pos - p, n);
}

float distPrism(const vec3 pos) {
	float d = -1.;
	d = max(distPlane(pos, PL1.p1,
					  PL1.normal),
			d);
	d = max(distPlane(pos, PL2.p1,
					  PL2.normal),
			d);
	d = max(distPlane(pos, PL3.p1,
					  PL3.normal),
			d);
	return d;
}

float distInfSphairahedra(const vec3 pos, vec4 s2, vec4 s4, vec4 s6, vec3 dividePlaneP1, vec3 dividePlaneNormal) {
	float d = distPrism(pos);
	d = max(distPlane(pos, dividePlaneP1, dividePlaneNormal), d);
	d = max(-distSphere(pos, s2), d);
	d = max(-distSphere(pos, s4), d);
	d = max(-distSphere(pos, s6), d);
	return d;
}

vec4 getInversionSphere(float zb, float zc) {
	if (fsphairahedron_cube_type == 0) return getInversionSphereA(zb, zc);
	if (fsphairahedron_cube_type == 1) return getInversionSphereB(zb, zc);
	if (fsphairahedron_cube_type == 2) return getInversionSphereC(zb, zc);
	return vec4(0.0);
}

void sphairahedron_iter(inout vec4 z4, inout float dr, vec4 original_z, float orbit, int i, vec4 s2, vec4 s4, vec4 s6, vec3 dividePlane_normal, vec3 dividePlane_p1, inout bool escaped) {
	vec3 pos = z4.xyz;
	if (i == 0) pos.y += 2.0;

	bool inFund = true;
	if(distance(pos, s2.xyz) < s2.w) {
		SphereInvert(pos, dr, s2);
		inFund = false;
	}
	if(distance(pos, s4.xyz) < s4.w) {
		SphereInvert(pos, dr, s4);
		inFund = false;
	}
	if(distance(pos, s6.xyz) < s6.w) {
		SphereInvert(pos, dr, s6);
		inFund = false;
	}

	pos -= PL1.p1;
	float d = dot(pos, PL1.normal);
	if(d > 0.0) {
		pos -= 2. * d * PL1.normal;
		inFund = false;
	}
	pos += PL1.p1;

	pos -= PL2.p1;
	d = dot(pos, PL2.normal);
	if(d > 0.0) {
		pos -= 2. * d * PL2.normal;
		inFund = false;
	}
	pos += PL2.p1;

	pos -= PL3.p1;
	d = dot(pos, PL3.normal);
	if(d > 0.0) {
		pos -= 2.0 * d * PL3.normal;
		inFund = false;
	}
	pos += PL3.p1;

	if (inFund) escaped = true;

	z4.xyz = pos;
	//return distInfSphairahedra(pos, s2, s4, s6, dividePlane_p1, dividePlane_normal) / abs(dr) * 0.25;
}

vec2 sphairahedron_sdf(vec4 z4) {
	vec4 z = z4;
	vec4 original_z = z;

	float zb = fsphairahedron_zb;
	float zc = fsphairahedron_zc;
	vec4 s2 = getS2A(zb, zc);
	vec4 s4 = getS4A(zb, zc);
	vec4 s6 = getS6A(zb, zc);
	vec4 inversionSphere = getInversionSphere(zb, zc);
	vec4 g0 = computeGSpheres0(inversionSphere);
	vec4 g1 = computeGSpheres1(inversionSphere, s2);
	vec4 g2 = computeGSpheres2(inversionSphere);
	vec4 g3 = computeGSpheres3(inversionSphere, s4);
	vec4 g4 = computeGSpheres4(inversionSphere);
	vec4 g5 = computeGSpheres5(inversionSphere, s6);
	vec3 v0 = computeVertexes0(g0, g1, g2);
	vec3 v1 = computeVertexes1(g0, g3, g4);
	vec3 v2 = computeVertexes2(g2, g4, g5);
	Plane dividePlane = computeDividePlane(inversionSphere, v0, v1, v2);
	vec4 convexSphere = computeConvexSphere(inversionSphere, dividePlane);

	float dz = 1.0;
	float orbit = 100000.0;

	for (int i = 0; i < iterations; i++) {
		bool escaped = false;
		sphairahedron_iter(z, dz, original_z, orbit, i, s2, s4, s6, dividePlane.normal, dividePlane.p1, escaped);
		if (escaped) break;
	}

	return vec2(distInfSphairahedra(z.xyz, s2, s4, s6, dividePlane.p1, dividePlane.normal) / abs(dz) * 0.25, 0.0);
}