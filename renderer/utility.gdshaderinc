bool check_range(int i, vec2 range) {
	return float(i) > range.x && float(i) < range.y;
}
vec3 decreaseLength(vec3 v, float amount) {
	return normalize(v) * (length(v) - amount);
}

float continuousMod(float x, float y) {
	float modValue = mod(x, y * 2.0);
	return modValue <= y ? modValue : y * 2.0 - modValue;
}

void SphereInvert(inout vec3 pos, inout float dr, vec4 s) {
	vec3 diff = pos - s.xyz;
	float lenSq = dot(diff, diff);
	float k = (s.w * s.w) / lenSq;
	dr *= k;
	pos = (diff * k) + s.xyz;
}