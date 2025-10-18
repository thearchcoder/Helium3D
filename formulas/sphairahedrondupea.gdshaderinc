// [ID]
// Sphairahedron Dupe A
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

void sphairahedrondupea_iter(inout vec4 z4, inout float dr, vec4 original_z, float orbit, int i, vec4 s2, vec4 s4, vec4 s6, vec3 dividePlane_normal, vec3 dividePlane_p1, inout bool escaped) {
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
}

vec2 sphairahedrondupea_sdf(vec4 z4) {
	vec4 z = z4;
	vec4 original_z = z;

	float zb = fsphairahedrondupea_zb;
	float zc = fsphairahedrondupea_zc;
	vec4 s2 = getS2A(zb, zc);
	vec4 s4 = getS4A(zb, zc);
	vec4 s6 = getS6A(zb, zc);
	vec4 inversionSphere = getInversionSphere(zb, zc, fsphairahedrondupea_cube_type);
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
		sphairahedrondupea_iter(z, dz, original_z, orbit, i, s2, s4, s6, dividePlane.normal, dividePlane.p1, escaped);
		if (escaped) break;
	}

	return vec2(distInfSphairahedra(z.xyz, s2, s4, s6, dividePlane.p1, dividePlane.normal) / abs(dz) * 0.25, 0.0);
}