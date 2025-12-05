// [ID]
// Gyroid Dupe A
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

vec2 gyroiddupea_sdf(vec4 z4) {
	vec3 point = z4.xyz - fgyroiddupea_position;
	float s = length(point) - fgyroiddupea_sphere_radius;
	float scale = fgyroiddupea_scale;
	float bias = fgyroiddupea_bias;
	float thickness = fgyroiddupea_thickness;
	float time = fgyroiddupea_time;
	float a = fgyroiddupea_control.x * (cos(time) + fgyroiddupea_control.z);
	float b = fgyroiddupea_control.y * (sin(time) + fgyroiddupea_control.w);
	a += fgyroiddupea_offset.x;
	b += fgyroiddupea_offset.y;
	point *= scale;

	vec3 point1 = fgyroiddupea_oriented ? point.zxy : point;
	vec3 point2 = point.zxy;

	float d = dot(sin(point1 * a), cos(point2 * b));
	if (fgyroiddupea_abs) d = abs(d);
	d = (d - bias) / scale - thickness;
	d = max(d * 0.4, s);
	return vec2(d, 0.0);
}
