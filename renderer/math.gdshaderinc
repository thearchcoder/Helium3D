const float golden_ratio = (1.0 + sqrt(5.0)) * 0.5;
const float PHI = golden_ratio;

#include "utility.gdshaderinc"
#include "kalaidoscope.gdshaderinc"

////////////////
// Orbit trap //
////////////////
float process_orbit_trap4d(vec4 z, vec4 o, int current_iteration) {
	if (current_iteration < color_min_iterations) return 10000000.0; // large number so it gets discarded inside min()
	if (current_iteration > color_max_iterations) return 10000000.0;

	if (coloring_mode == 0) { return length(z); }
	if (coloring_mode == 1) { return dot(z, z); }
	if (coloring_mode == 2) { return sqrt(length(z)); }
	if (coloring_mode == 3) { return sqrt(dot(z, z)); }
	if (coloring_mode == 4) { return log(length(z)); }
	if (coloring_mode == 5) { return log(dot(z, z)); }
	if (coloring_mode == 6) { return exp(length(z)); }
	if (coloring_mode == 7) { return exp(dot(z, z)); }
	if (coloring_mode == 8) { return length(sin(o)); }
	if (coloring_mode == 9) { return length(cos(o)); }

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

///////////////////////
// Hypercomplex Math //
///////////////////////
vec3 triplex_mul(vec3 n1, vec3 n2) {
	float r1 = length(n1);
	float theta1 = atan(n1.y, n1.x);
	float phi1 = asin(n1.z / r1);
	float r2 = length(n2);
	float theta2 = atan(n2.y, n2.x);
	float phi2 = asin(n2.z / r2);

	float r = r1 * r2;
	float theta = theta1 + theta2;
	float phi = phi1 + phi2;

	return vec3(r * cos(theta) * cos(phi), r * sin(theta) * cos(phi), r * sin(phi));
}

vec3 triplex_pow(vec3 v, float n, float phase, float z_mul) {
	// swap cos and sin around
	float r = length(v);  // put negative here
	float theta = n * atan(v.y, v.x);// + TIME;
	float phi = n * asin(v.z / r) + phase;  // v.z > -v.z

	// atan(tan(phi + 0.1) * 0.6) + 0.3
	// sin(abs(phi) + 1.0)
	float cos_phi = cos(phi);  // phi > sin(phi), cos(phi)  !  phi + a * b   !  tan(phi) * 0.1
	// sin(theta) * cos(phi), sin(phi), cos(theta)
	// cos(theta) * cos_phi, sin(theta) * cos_phi, z_mul * sin(phi)

	return pow(r, n) * vec3(cos(theta) * cos_phi, sin(theta) * cos_phi, z_mul * sin(phi));
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
		if (negative_axis == 1) unitVector = vec3(-qNormalized.y, qNormalized.z, qNormalized.w) / vectorMagnitude;
		else unitVector = vec3(qNormalized.y, qNormalized.z, qNormalized.w) / vectorMagnitude;
	}

	float newW = pow(norm, t) * cos(t * theta);
	vec3 newVector = pow(norm, t) * sin(t * theta) * unitVector;

	return vec4(newW, newVector.x, newVector.y, newVector.z);
}

vec4 quaternion_conj(vec4 q) { return vec4(q.x, -q.y, -q.z, -q.w); }
vec3 triplex_conj(vec3 t) { return vec3(t.x, -t.y, -t.z); }

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
/////////////////////////////
// Cartesian and Spherical //
////////////////////////////
vec3 to_spherical(vec3 c) {
	float r = length(c);
	float theta = atan(c.y, c.x);
	float phi = asin(c.z / r);
	return vec3(r, theta, phi);
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
float segment_sdf(in vec3 p, vec3 a, vec3 b) {
	vec3 pa = p - a, ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba,ba), 0.0, 1.0);
	return length(pa - ba*h);
}

float cylinder_sdf3d(vec3 p, float h, float r) {
	vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(r,h);
	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

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

//#define sabs(p) sqrt((p)*(p)+2e-3)
//#define smin(a,b) (a+b-sabs(a-b))*.5
//#define smax(a,b) (a+b+sabs(a-b))*.5

float ssmax(float a, float b, float k) {
	if (k <= 0.1) return max(a, b);
	return 0.1732 * k * log2(exp2(5.771 * a / k) + exp2(5.771 * b / k));
}

float ssmin(float a, float b, float k) {
	return -ssmax(-a, -b, k);
}

float smin(float a, float b, float k) {
	if (exponential_smoothing) return ssmin(a, b, k);
	float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
	return mix(a, b, h) - k*h*(1.0-h);
}

float smax(float a, float b, float k) {
	if (exponential_smoothing) return ssmax(a, b, k);
	return -smin(-a, -b, k);
}

float icosahedron_sdf3d(vec3 p, float r) {
	float h = (1.0 + sqrt(5.0)) / 2.0;
	vec3 n = normalize(vec3(h, 1.0 / h, 0));
	p = abs(p);
	float d = dot(p,n);
	d = max(d, dot(p, n.yzx));
	d = max(d, dot(p, n.zxy));
	d = max(d, dot(p, normalize(vec3(1))));
	return d - r;
}

float line_sdf(vec3 p, vec3 a, vec3 b, float r) {
	vec3 pa = p - a, ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length(pa - ba * h) - r;
}

float bounds_rectangle_sdf(vec3 p, vec3 position, vec3 size) {
	vec3 half_size = size * 0.5;
	vec3 q = abs(p - position) - half_size;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float bounds_sdf(vec3 p, vec3 position, vec3 size, inout vec3 color) {
	vec3 half_size = size * 0.5;
	vec3 min_bounds = position - half_size;
	vec3 max_bounds = position + half_size;
	float r = 0.01;

	// x-axis edges (red)
	float d1 = line_sdf(p, vec3(min_bounds.x, min_bounds.y, min_bounds.z), vec3(max_bounds.x, min_bounds.y, min_bounds.z), r);
	float d2 = line_sdf(p, vec3(min_bounds.x, max_bounds.y, min_bounds.z), vec3(max_bounds.x, max_bounds.y, min_bounds.z), r);
	float d3 = line_sdf(p, vec3(min_bounds.x, min_bounds.y, max_bounds.z), vec3(max_bounds.x, min_bounds.y, max_bounds.z), r);
	float d4 = line_sdf(p, vec3(min_bounds.x, max_bounds.y, max_bounds.z), vec3(max_bounds.x, max_bounds.y, max_bounds.z), r);

	// y-axis edges (green)
	float d5 = line_sdf(p, vec3(min_bounds.x, min_bounds.y, min_bounds.z), vec3(min_bounds.x, max_bounds.y, min_bounds.z), r);
	float d6 = line_sdf(p, vec3(max_bounds.x, min_bounds.y, min_bounds.z), vec3(max_bounds.x, max_bounds.y, min_bounds.z), r);
	float d7 = line_sdf(p, vec3(min_bounds.x, min_bounds.y, max_bounds.z), vec3(min_bounds.x, max_bounds.y, max_bounds.z), r);
	float d8 = line_sdf(p, vec3(max_bounds.x, min_bounds.y, max_bounds.z), vec3(max_bounds.x, max_bounds.y, max_bounds.z), r);

	// z-axis edges (blue)
	float d9 = line_sdf(p, vec3(min_bounds.x, min_bounds.y, min_bounds.z), vec3(min_bounds.x, min_bounds.y, max_bounds.z), r);
	float d10 = line_sdf(p, vec3(max_bounds.x, min_bounds.y, min_bounds.z), vec3(max_bounds.x, min_bounds.y, max_bounds.z), r);
	float d11 = line_sdf(p, vec3(min_bounds.x, max_bounds.y, min_bounds.z), vec3(min_bounds.x, max_bounds.y, max_bounds.z), r);
	float d12 = line_sdf(p, vec3(max_bounds.x, max_bounds.y, min_bounds.z), vec3(max_bounds.x, max_bounds.y, max_bounds.z), r);

	float min_x = min(min(d1, d2), min(d3, d4));
	float min_y = min(min(d5, d6), min(d7, d8));
	float min_z = min(min(d9, d10), min(d11, d12));

	float closest_dist = min(min_x, min(min_y, min_z));

	float eps = r + 0.0001;
	if (distance(closest_dist, min_x) < eps) {
		color = vec3(1.0, 0.0, 0.0);
	} else if (distance(closest_dist, min_y) < eps) {
		color = vec3(0.0, 1.0, 0.0);
	} else {
		color = vec3(0.0, 0.0, 1.0);
	}

	return closest_dist;
}

///////////////////
// UV Projection //
///////////////////
vec2 spherical_uv(vec3 p) {
	vec3 normalized = normalize(p);
	float u = atan(normalized.z, normalized.x) / (2.0 * 3.14159) + 0.5;
	float v = asin(normalized.y) / 3.14159 + 0.5;
	return vec2(u, v);
}

vec2 planar_uv(vec3 p, float scale) {
	return fract(p.xz * scale);
}

vec2 cylindrical_uv(vec3 p, float scale) {
	float u = atan(p.z, p.x) / TAU + 0.5;
	float v = p.y * scale;
	return vec2(u, fract(v));
}

vec3 triplanar_normal(vec3 p, vec3 normal) {
	if (!normal_map_enabled) return normal;

	vec3 blend_weights = abs(normal);
	blend_weights = pow(blend_weights, vec3(normal_map_triplanar_sharpness));
	blend_weights /= dot(blend_weights, vec3(1.0));

	vec3 normal_x = texture(normal_map, p.yz * normal_map_scale).rgb * 2.0 - 1.0;
	vec3 normal_y = texture(normal_map, p.xz * normal_map_scale).rgb * 2.0 - 1.0;
	vec3 normal_z = texture(normal_map, p.xy * normal_map_scale).rgb * 2.0 - 1.0;

	normal_x = vec3(0.0, normal_x.y, normal_x.x) * normal_map_height;
	normal_y = vec3(normal_y.x, 0.0, normal_y.y) * normal_map_height;
	normal_z = vec3(normal_z.x, normal_z.y, 0.0) * normal_map_height;

	return normalize(normal +
		normal_x * blend_weights.x +
		normal_y * blend_weights.y +
		normal_z * blend_weights.z);
}

/////////
// IBL //
/////////
vec3 sample_panorama_ibl(sampler2D panorama_tex, vec3 direction) {
	vec2 uv;
	uv.x = atan(direction.z, direction.x) / (2.0 * PI) + 0.5;
	uv.y = acos(clamp(direction.y, -1.0, 1.0)) / PI;
	return texture(panorama_tex, uv).rgb;
}

/////////////////////////
// Random and Sampling //
/////////////////////////
float hash(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

float hasha(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
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
