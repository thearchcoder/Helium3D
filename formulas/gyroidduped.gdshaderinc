// [ID]
// Gyroid Dupe D
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

vec2 gyroidduped_sdf(vec4 z4) {
	vec3 point = z4.xyz - fgyroidduped_position;
	float s = length(point) - fgyroidduped_sphere_radius;
	float scale = fgyroidduped_scale;
	float bias = fgyroidduped_bias;
	float thickness = fgyroidduped_thickness;
	float time = fgyroidduped_time;
	float a = fgyroidduped_control.x * (cos(time) + fgyroidduped_control.z);
	float b = fgyroidduped_control.y * (sin(time) + fgyroidduped_control.w);
	a += fgyroidduped_offset.x;
	b += fgyroidduped_offset.y;
	point *= scale;

	vec3 point1 = fgyroidduped_oriented ? point.zxy : point;
	vec3 point2 = point.zxy;

	float d = dot(sin(point1 * a), cos(point2 * b));
	if (fgyroidduped_abs) d = abs(d);
	d = (d - bias) / scale - thickness;
	d = max(d * 0.4, s);
	return vec2(d, 0.0);
}
