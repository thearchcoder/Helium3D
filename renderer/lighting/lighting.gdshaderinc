
float calcAO(vec3 pos, vec3 normal) {
	float max_dist = ambient_occlusion_distance;
	float diff = 0.0;

	for (int i = 0; i < ambient_occlusion_steps; i++) {
		float dist = max_dist * hash(vec2(float(i), float(i+1)));
		float s_dist = max(0.0, scene_sdf(pos + dist * normal).y);
		diff += (dist - s_dist) / max_dist;
	}

	float diff_norm = diff / float(ambient_occlusion_steps);
	float ao = 1.0 - diff_norm/ambient_occlusion_radius;

	return clamp(ao, 0.0, 1.0);
}

vec3 get_normal_from_map(vec2 uv, vec3 world_pos, vec3 surface_normal) {
	if (!normal_map_enabled) return surface_normal;

	vec3 normal_sample = texture(normal_map, uv).rgb * 2.0 - 1.0;

	vec3 dp_dx = dFdx(world_pos);
	vec3 dp_dy = dFdy(world_pos);
	vec2 duv_dx = dFdx(uv);
	vec2 duv_dy = dFdy(uv);

	vec3 dp_dy_perp = cross(surface_normal, dp_dy);
	vec3 dp_dx_perp = cross(dp_dx, surface_normal);
	vec3 tangent = dp_dy_perp * duv_dx.x + dp_dx_perp * duv_dy.x;
	vec3 bitangent = dp_dy_perp * duv_dx.y + dp_dx_perp * duv_dy.y;

	float inv_max = inversesqrt(max(dot(tangent, tangent), dot(bitangent, bitangent)));
	mat3 tbn = mat3(tangent * inv_max, bitangent * inv_max, surface_normal);

	return normalize(tbn * normal_sample);
}

float soft_shadow(vec3 point, vec3 dir, float start, float end, float light_radius) {
	float depth = start, dist, prevdist = 10000.0;
	float shadow = 1.0;
	for (int i = 0; i < shadow_steps; i++) {
		dist = scene_sdf(point + depth * dir).y;
		if (depth > end || shadow < epsilon) break;

		float effective_sharpness = 1.0 / max(light_radius, 0.001);
		shadow = min(shadow, effective_sharpness * dist / depth);

		float delta = dist * dist / (2.0 * prevdist);
		float dist2 = sqrt(dist * dist - delta * delta);
		shadow = min(shadow, effective_sharpness * dist2 / max(0.0, depth - delta));

		prevdist = dist;
		depth += dist * shadow_raystep_multiplier * raystep_multiplier;
	}
	return clamp(shadow, 0.0, 1.0);
}

float hard_shadow(vec3 point, vec3 dir, float start, float end) {
	float depth = start;
	for (int i = 0; i < shadow_steps; i++) {
		float dist = scene_sdf(point + depth * dir).y;
		if (depth > end) break;
		if (dist < epsilon) return 0.0;
		depth += dist * shadow_raystep_multiplier * raystep_multiplier;
	}
	return 1.0;
}

vec3 compute_direct_point_light(vec3 p, vec3 rd, vec3 ro, vec3 normal, vec3 light_pos, vec3 light_color, float light_intensity, float light_radius) {
	float light_distance = length(light_pos - p);
	vec3 to_light = normalize(light_pos - p);
	vec3 final_normal;

	if (normal_map_projection == 0) final_normal = get_normal_from_map(spherical_uv(p), p, normal);
	else if (normal_map_projection == 1) final_normal = get_normal_from_map(planar_uv(p, 0.1), p, normal);
	else if (normal_map_projection == 2) final_normal = triplanar_normal(p, normal);

	vec3 diffuse = light_color * light_intensity * clamp(dot(to_light, final_normal), 0.0, 1.0);
	vec3 light = diffuse;
	
	float shadow = !hard_shadows ? 
		soft_shadow(p, to_light, shadow_epsilon, light_distance, light_radius) : 
		hard_shadow(p, to_light, shadow_epsilon, light_distance);
	
	light *= shadow;

	float specular = pow(max(dot(reflect(to_light, final_normal), rd), 0.0), specular_sharpness);
	light *= max(specular * specular_intensity, 1.0) * shadow;

	return light;
}

vec3 compute_direct_lighting(vec3 p, vec3 rd, vec3 ro, vec3 normal) {
	float ao = calcAO(p, normal);
	vec3 total_light;
	vec3 ambient = ambient_light * vec3(1.0);

	if (ambient_light_from_background) {
		if (bg_type == 1) ambient *= sample_panorama_ibl(bg_image, normal);
		if (bg_type == 0) ambient *= pow(texture(bg_color, vec2(acos(normalize(rd).y) / PI, 0.0)).xyz, vec3(2.0));
	}
	else ambient *= ambient_light_color;

	if (light1_enabled && !light2_enabled) total_light = compute_direct_point_light(p, rd, ro, normal, light1_position, light1_color, light1_intensity, light1_radius);
	if (light2_enabled && !light1_enabled) total_light = compute_direct_point_light(p, rd, ro, normal, light2_position, light2_color, light2_intensity, light2_radius);
	if (light2_enabled && light1_enabled) total_light = compute_direct_point_light(p, rd, ro, normal, light2_position, light2_color, light2_intensity, light2_radius) + compute_direct_point_light(p, rd, ro, normal, light1_position, light1_color, light1_intensity, light2_radius);
	total_light += mix(ambient * ao, ambient, ambient_occlusion_light_affect);
	total_light *= mix(1.0, ao, ambient_occlusion_light_affect);
	return total_light;
}

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

//float calcAO(vec3 pos, vec3 normal ) {
	//float occ = 0.0;
	//float sca = 1.0;
	//for( int i=0; i<ambient_occlusion_steps; i++ )
	//{
		//float h = 0.01 + 0.12 * float(i) / 4.0;
		//float d = scene_sdf(pos + h * normal).y;
		//occ += (h - d) * sca;
		//sca *= 0.95;
		//if(occ > 0.35) break;
	//}
	//return clamp( 1.0 - 2.0 * occ, 0.0, 1.0 ) * (0.5 + 0.5 * normal.y);
//}

//float calcAO(vec3 p, vec3 n) {
	//float dist = ambient_occlusion_radius;
	//float occ = 1.0;
	//for (int i = 0; i < ambient_occlusion_steps; ++i) {
		//occ = min(occ, scene_sdf(p + dist * n).y / dist);
		//dist *= ambient_occlusion_brightness;
	//}
	//return max(occ, 0.0);
//}

//float calcAO(vec3 p, vec3 nor) {
	//float k = ambient_occlusion_brightness;
	//float sum = 0.0;
	//for (float i = 0.0; i < float(ambient_occlusion_steps); i++)  {
		//sum += 1.0 / pow(ambient_occlusion_radius, i) * (i * 0.15 - scene_sdf(p + nor * i * 0.15).y);
	//}
	//
	//return 1.0 - k * sum;
//}
