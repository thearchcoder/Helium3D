//float soft_shadow(vec3 point, vec3 dir, float start, float end) {
 	//float depth = start, dist;
	//float shadow = 1.0;
	//for(int i = 0; i < shadow_steps; i++) {
		//dist = scene_sdf(point + depth * dir).x;
		//if(depth > end || shadow < -1.0) break;
		//
		//shadow = min(shadow, 40.*dist/depth);
		//depth += clamp(dist, 0.005, 10.0);
	//}
	//
	//shadow = max(shadow, -1.0);
	//return smoothstep(-1.0, 0.0, shadow);
//}

float soft_shadow(vec3 point, vec3 dir, float start, float end) {
	float depth = start, dist, prevdist = 10000.0;
	float shadow = 1.0;

	for (int i = 0; i < shadow_steps; i++) {
		dist = scene_sdf(point + depth * dir).y;
		if (depth > end || shadow < epsilon) break;
		shadow = min(shadow, 35.0 * dist / min(depth, 5.0));
		float delta = dist * dist / (2.0 * prevdist);
		float dist2 = sqrt(dist * dist - delta * delta);
		shadow = min(shadow, 35.0 * dist2 / max(0.0, min(depth - delta, 5.0)));
		prevdist = dist;
		depth += dist * shadow_raystep_multiplier;
	}

	return clamp(shadow, 0.0, 1.0);
}

vec3 get_light(vec3 p, vec3 rd, vec3 ro, vec3 light_pos, vec3 light_color, float light_intensity, vec3 normal) {
	vec3 to_light = normalize(light_pos - p);

	// Diffuse
	float light = light_intensity * clamp(dot(to_light, normal) - 0.0, 0.0, 1.0);

	// Soft shadows
	float shadow = soft_shadow(p, to_light, shadow_epsilon, length(light_pos - p));
	light *= shadow;

	// Specular highlights
	float specular = pow(max(dot(reflect(to_light, normal), rd), 0.0), specular_sharpness);
	light *= max(specular * specular_intensity, 1.0) * shadow;

	vec3 grayscale_light_color = vec3(light_color.r + light_color.g + light_color.b) / 3.0;
	return mix(grayscale_light_color, light_color, shadow) * (light + ambient_light);
}
