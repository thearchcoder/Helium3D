// [ID]
// Gyroid
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// vec3 position[(-5, -5, -5), (5, 5, 5)] = (0, 0, 0)
// float scale[0.1, 10] = 6
// float sphere_radius[0, 10] = 1
// float time[0, 6.28318] = 0
// float thickness[0, 0.5] = 0.025
// advanced float bias[0, 0.5] = 0.015
// advanced vec4 control[(0, 0, 0, 0), (3, 3, 3, 3)] = (0.5, 0.7, 2, 2)
// advanced vec2 offset[(0, 0), (1.570795, 1.570795)] = (0, 0)
// advanced bool oriented[false, true] = false
// advanced bool abs[false, true] = true
// [CODE]

vec2 gyroid_sdf(vec4 z4) {
	vec3 point = z4.xyz - fgyroid_position;
	float s = length(point) - fgyroid_sphere_radius;
	float scale = fgyroid_scale;
	float bias = fgyroid_bias;
	float thickness = fgyroid_thickness;
	float time = fgyroid_time;
	float a = fgyroid_control.x * (cos(time) + fgyroid_control.z);
	float b = fgyroid_control.y * (sin(time) + fgyroid_control.w);
	a += fgyroid_offset.x;
	b += fgyroid_offset.y;
	point *= scale;

	vec3 point1 = fgyroid_oriented ? point.zxy : point;
	vec3 point2 = point.zxy;

	float d = dot(sin(point1 * a), cos(point2 * b));
	if (fgyroid_abs) d = abs(d);
	d = (d - bias) / scale - thickness;
	d = max(d * 0.4, s);
	return vec2(d, 0.0);
}
