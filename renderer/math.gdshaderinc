const float golden_ratio = (1.0 + sqrt(5.0)) * 0.5;

float process_orbit_trap(vec3 z) {
	if (coloring_mode == 1) { return length(z); }
	if (coloring_mode == 2) { return dot(z, z); }
	if (coloring_mode == 3) { return sqrt(length(z)); }
	if (coloring_mode == 4) { return sqrt(dot(z, z)); }
	if (coloring_mode == 5) { return abs(length(z)); }
	if (coloring_mode == 6) { return abs(dot(z, z)); }
	if (coloring_mode == 7) { return log(length(z)); }
	if (coloring_mode == 8) { return log(dot(z, z)); }
	if (coloring_mode == 9) { return exp(length(z)); }
	if (coloring_mode == 10) { return exp(dot(z, z)); }

	// Component-based coloring
	if (coloring_mode == 11) { return abs(z.x); }
	if (coloring_mode == 12) { return abs(z.y); }
	if (coloring_mode == 13) { return abs(z.z); }
	if (coloring_mode == 14) { return max(max(abs(z.x), abs(z.y)), abs(z.z)); }
	if (coloring_mode == 15) { return min(min(abs(z.x), abs(z.y)), abs(z.z)); }

	// Blended component coloring
	if (coloring_mode == 16) { return (abs(z.x) + abs(z.y) + abs(z.z)) / 3.0; }
	if (coloring_mode == 17) { return abs(z.x) * abs(z.y) * abs(z.z); }

	// Angular/spherical components
	if (coloring_mode == 18) { return atan(length(z.xy), z.z) / 3.14159; } // Polar angle (normalized)
	if (coloring_mode == 19) { return atan(z.y, z.x) / 6.28318 + 0.5; }    // Azimuthal angle (normalized)

	// Distance to geometric shapes
	if (coloring_mode == 20) { return abs(length(z) - 1.0); }              // Distance to unit sphere
	if (coloring_mode == 21) { return abs(max(max(abs(z.x), abs(z.y)), abs(z.z)) - 1.0); } // Distance to unit cube
	if (coloring_mode == 22) { return abs(z.x) + abs(z.y) + abs(z.z) - 1.0; } // Distance to octahedron

	// Smooth blending functions
	if (coloring_mode == 23) { return 0.5 * (1.0 + sin(length(z) * 5.0)); }
	if (coloring_mode == 24) { return 0.5 * (1.0 + sin(dot(z, z) * 3.0)); }

	// Periodic functions
	if (coloring_mode == 25) { return fract(length(z) * 2.0); }
	if (coloring_mode == 26) { return fract(dot(z, z) * 1.5); }
	if (coloring_mode == 27) { return cos(length(z) * 4.0) * 0.5 + 0.5; }
	if (coloring_mode == 28) { return sin(dot(z, z) * 3.0) * 0.5 + 0.5; }

	// Hybrid functions
	if (coloring_mode == 29) { return length(z) / (1.0 + dot(z, z)); }
	if (coloring_mode == 30) { return sqrt(abs(z.x * z.y * z.z)); }

	return 0.0;
}

float process_orbit_trap4d(vec4 z) {
	if (coloring_mode == 1) { return length(z); }
	if (coloring_mode == 2) { return dot(z, z); }
	if (coloring_mode == 3) { return sqrt(length(z)); }
	if (coloring_mode == 4) { return sqrt(dot(z, z)); }
	if (coloring_mode == 5) { return abs(length(z)); }
	if (coloring_mode == 6) { return abs(dot(z, z)); }
	if (coloring_mode == 7) { return log(length(z)); }
	if (coloring_mode == 8) { return log(dot(z, z)); }
	if (coloring_mode == 9) { return exp(length(z)); }
	if (coloring_mode == 10) { return exp(dot(z, z)); }
	return 0.0;
}

//////////////
// Rotation //
//////////////

vec3 rotate3d_point(vec3 p, vec3 rot) {
	if (length(rot) <= 0.00001) return p;

	p.xz = vec2(cos(rot.x) * p.x - sin(rot.x) * p.z, sin(rot.x) * p.x + cos(rot.x) * p.z);
	p.yz = vec2(cos(rot.y) * p.y - sin(rot.y) * p.z, sin(rot.y) * p.y + cos(rot.y) * p.z);
	p.xy = vec2(cos(rot.z) * p.x - sin(rot.z) * p.y, sin(rot.z) * p.x + cos(rot.z) * p.y);

	return p;
}

vec4 rotate4d_point(vec4 p, vec4 rot) {
	if (length(rot) <= 0.00001) return p;

	p.xw = vec2(cos(rot.x) * p.x - sin(rot.x) * p.w, sin(rot.x) * p.x + cos(rot.x) * p.w);
	p.yw = vec2(cos(rot.y) * p.y - sin(rot.y) * p.w, sin(rot.y) * p.y + cos(rot.y) * p.w);
	p.zw = vec2(cos(rot.z) * p.z - sin(rot.z) * p.w, sin(rot.z) * p.z + cos(rot.z) * p.w);
	p.xy = vec2(cos(rot.w) * p.x - sin(rot.w) * p.y, sin(rot.w) * p.x + cos(rot.w) * p.y);

	return p;
}

mat3 rotateX(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, c, -s),
        vec3(0.0, s, c)
    );
}

mat3 rotateY(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(
        vec3(c, 0.0, s),
        vec3(0.0, 1.0, 0.0),
        vec3(-s, 0.0, c)
    );
}

mat3 rotateZ(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(
        vec3(c, -s, 0.0),
        vec3(s, c, 0.0),
        vec3(0.0, 0.0, 1.0)
    );
}

/////////
// Pow //
/////////
vec3 triplex_pow(vec3 v, float n, float phase, float zmul) {
	// swap cos and sin around
	float r = length(v);  // put negative here
	float theta = n * atan(v.y, v.x);
	float phi = n * asin(v.z / r) + phase;  // v.z > -v.z

	// atan(tan(phi + 0.1) * 0.6) + 0.3
	float cos_phi = cos(phi);  // phi > sin(phi), cos(phi)  !  phi + a * b   !  tan(phi) * 0.1

	return pow(r, n) * vec3(cos(theta) * cos_phi, sin(theta) * cos_phi, sin(phi) * zmul);
}

vec4 quaternion_pow(vec4 q, float t, float phase, int negative_axis) {
    float qw = q.x;
    float qx = q.y;
    float qy = q.z;
    float qz = q.w;

    float norm = sqrt(qw*qw + qx*qx + qy*qy + qz*qz);

    if (norm < 1e-6) return vec4(0.0, 0.0, 0.0, 0.0);
    if (abs(qw - norm) < 1e-6 && abs(qx) < 1e-6 && abs(qy) < 1e-6 && abs(qz) < 1e-6) return vec4(pow(norm, t), 0.0, 0.0, 0.0);

    vec4 qNormalized = q / norm;
    float wNormalized = qNormalized.x;

    float theta = acos(wNormalized) + phase;
    float vectorMagnitude = sqrt(1.0 - wNormalized*wNormalized);
    const float EPSILON = 1e-6;

    vec3 unitVector;
    if (vectorMagnitude < EPSILON) {
        unitVector = vec3(1.0, 0.0, 0.0);
    } else {
		if (negative_axis == 3) unitVector = vec3(qNormalized.y, -qNormalized.z, qNormalized.w) / vectorMagnitude;
		if (negative_axis == 2) unitVector = vec3(-qNormalized.y, qNormalized.z, qNormalized.w) / vectorMagnitude;
		else unitVector = vec3(qNormalized.y, qNormalized.z, qNormalized.w) / vectorMagnitude;
    }

    float newW = pow(norm, t) * cos(t * theta);
	if (negative_axis == 0) newW = -newW;
    vec3 newVector = pow(norm, t) * sin(t * theta) * unitVector;

    return vec4(newW, newVector.x, newVector.y, newVector.z);
}

vec4 bicomplex_mult(vec4 a, vec4 b) {
	return vec4(
		a.x * b.x - a.y * b.y - a.z * b.z + a.w * b.w,
		a.x * b.y + a.y * b.x - a.z * b.w - a.w * b.z,
		a.x * b.z + a.z * b.x - a.y * b.w - a.w * b.y,
		a.x * b.w + a.w * b.x + a.y * b.z + a.z * b.y
	);
}

vec4 bicomplex_pow(vec4 z, float p) {
	vec4 res = z;
	int int_power = int(p) - 1;

	for (int i = 0; i < int_power; i++) res = bicomplex_mult(res, z);

	return res;
}

////////////////
// Primitives //
////////////////

float sphere_sdf2d(vec2 p, vec2 sphere_position, float radius) { return length(p - sphere_position) - radius; }
float sphere_sdf3d(vec3 p, vec3 sphere_position, float radius) { return length(p - sphere_position) - radius; }
float sphere_sdf4d(vec4 p, vec4 sphere_position, float radius) { return length(p - sphere_position) - radius; }
float cube_sdf3d(vec3 p, vec3 s) { vec3 q = abs(p) - s; return length(max(q, 0.0)); }
float cube_sdf4d(vec4 p, vec4 s) { vec4 q = abs(p) - s; return length(max(q, 0.0)); }
float triangle_sdf3d(vec3 point) { return (max(abs(point.x + point.y) - point.z, abs(point.x - point.y) + point.z) - 1.0) / sqrt(3.0); }
float octahedron_sdf3d(vec3 p, float s) { vec3 k = abs(p); return (k.x + k.y + k.z - s) * 0.57735027; }
float dodecahedron_sdf3d(vec3 position, float radius) {
	position = abs(position);
	float phi = (1.0 + sqrt(5.0)) * 0.5;
	float a = 1.0 / sqrt(3.0) * radius;
	float b = 1.0 / sqrt(3.0) * radius * (phi - 1.0);
	vec3 n1 = vec3(0.0, phi, 1.0) / sqrt(phi + 2.0);
	vec3 n2 = vec3(phi + 2.0, phi - 1.0, -1.0) / sqrt(4.0 * phi + 8.0);
	vec3 n3 = vec3(phi, 1.0, 0.0) / sqrt(phi + 2.0);
	vec3 n4 = vec3(-1.0, phi, 3.0 - phi) / sqrt(12.0 - 4.0 * phi);
	vec3 p1 = position - vec3(0.0, a, 0.0);
	float h1 = dot(p1 - vec3(a, 0.0, a), n1);
	float m1 = dot(p1 - vec3(a, 0.0, a), n2);
	vec3 d1 = p1 - clamp(p1 - n1 * h1 - n2 * max(m1, 0.0), vec3(0.0), vec3(a, b, a));
	float h2 = dot(p1 - vec3(a, 0.0, a), n3);
	float m2 = dot(p1 - vec3(a, 0.0, a), n4);
	vec3 d2 = p1 - clamp(p1 - n3 * h2 - n4 * max(m2, 0.0), vec3(b, 0.0, 0.0), vec3(a, b, a));
	vec3 p2 = (position - vec3(a, 0.0, 0.0)).zxy;
	float h3 = dot(p2 - vec3(a, 0.0, a), n1);
	float m3 = dot(p2 - vec3(a, 0.0, a), n2);
	vec3 d3 = p2 - clamp(p2 - n1 * h3 - n2 * max(m3, 0.0), vec3(0.0), vec3(a, b, a));
	float h4 = dot(p2 - vec3(a, 0.0, a), n3);
	float m4 = dot(p2 - vec3(a, 0.0, a), n4);
	vec3 d4 = p2 - clamp(p2 - n3 * h4 - n4 * max(m4, 0.0), vec3(b, 0.0, 0.0), vec3(a, b, a));
	vec3 p3 = (position - vec3(0.0, 0.0, a)).yzx;
	float h5 = dot(p3 - vec3(a, 0.0, a), n1);
	float m5 = dot(p3 - vec3(a, 0.0, a), n2);
	vec3 d5 = p3 - clamp(p3 - n1 * h5 - n2 * max(m5, 0.0), vec3(0.0), vec3(a, b, a));
	float h6 = dot(p3 - vec3(a, 0.0, a), n3);
	float m6 = dot(p3 - vec3(a, 0.0, a), n4);
	vec3 d6 = p3 - clamp(p3 - n3 * h6 - n4 * max(m6, 0.0), vec3(b, 0.0, 0.0), vec3(a, b, a));
	float d = sqrt(min(min(min(min(min(dot(d1, d1), dot(d2, d2)), dot(d3, d3)), dot(d4, d4)), dot(d5, d5)), dot(d6, d6)));
	float s = max(max(max(max(max(h1, h2), h3), h4), h5), h6);
	return (s < 0.0 ? -d : d);
}

float hollow_cube_sdf3d(vec3 p, vec3 b, float e) {
	p = abs(p) - b;
	vec3 q = abs(p + e) - e;

	return min(min(
		length(max(vec3(p.x, q.y, q.z), 0.0)) + min(max(p.x, max(q.y, q.z)), 0.0),
		length(max(vec3(q.x, p.y, q.z), 0.0)) + min(max(q.x, max(p.y, q.z)), 0.0)),
		length(max(vec3(q.x, q.y, p.z), 0.0)) + min(max(q.x, max(q.y, p.z)), 0.0));
}

#define sabs(p) sqrt((p)*(p)+2e-3)
#define smin(a,b) (a+b-sabs(a-b))*.5
#define smax(a,b) (a+b+sabs(a-b))*.5

float icosahedron_sdf3d(vec3 p, float r){
	float G = sqrt(5.0) * 0.5 + 0.5;
	vec3 n = normalize(vec3(G, 1.0 / G, 0.0));
	float d = 0.0;
	p = sabs(p);
	d = smax(d, dot(p, n));
	d = smax(d, dot(p, n.yzx));
	d = smax(d, dot(p, n.zxy));
	d = smax(d, dot(p, normalize(vec3(1.0, 1.0, 1.0))));
	return d - r;
}

/////////////////////////
// Random and Sampling //
/////////////////////////

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

vec2 hash2(float n) {
	return fract(sin(vec2(n, n+1.0)) * vec2(43758.5453123, 22578.1459123));
}

vec2 fibonacci_circle(float i, float n) {
	const float phi = 1.61803398875;
	float theta = 2.0 * 3.14159265359 * fract(i * phi);
	float r = sqrt(i / n);
	return vec2(cos(theta), sin(theta)) * r;
}
