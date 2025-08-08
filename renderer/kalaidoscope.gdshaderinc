// Effie's kalaidoscope method
#define TAO 6.283
vec2 effie_kalaido(vec2 v, float power) {
	float angle = floor(0.5 + atan(v.x, -v.y) * power / TAO) * TAO / power;
	return v * mat2(vec2(cos(angle), sin(angle)), vec2(-sin(angle), cos(angle)));
}

vec2 kalaido(vec2 p, float symmetry, int mode) {
	if (mode == 2) return effie_kalaido(p, symmetry);

	float angle = 3.14159265 / symmetry;
	float theta = atan(p.y, p.x);
	if (mode == 0) theta = continuousMod(theta + angle, 2.0 * angle) - angle;
	if (mode == 1) theta = mod(theta + angle, 2.0 * angle) - angle;
	p = vec2(cos(theta), sin(theta)) * length(p);

	return p;
}