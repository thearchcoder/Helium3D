vec3 fresnel_schlick(vec3 f0, float cosTheta) {
	return f0 + (1.0 - f0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

float ggx_distribution(float rough, float NdotH) {
	float a = max(rough * rough, 0.0001);
	float a2 = a * a;
	float NdotH2 = NdotH * NdotH;
	float denom = (NdotH2 * (a2 - 1.0) + 1.0);
	denom = 3.14159265359 * denom * denom;
	return a2 / max(denom, 0.0000001);
}

float ggx_anisotropic(float rough, float aniso, float NdotH, float TdotH, float BdotH) {
	float rough_x = max(rough * (1.0 + aniso), 0.001);
	float rough_y = max(rough * (1.0 - aniso), 0.001);

	float a_x = rough_x * rough_x;
	float a_y = rough_y * rough_y;

	float denom = (TdotH * TdotH) / (a_x * a_x) +
	              (BdotH * BdotH) / (a_y * a_y) +
	              NdotH * NdotH;

	return 1.0 / max(3.14159265359 * a_x * a_y * denom * denom, 0.0000001);
}

float geometry_schlick_ggx(float NdotV, float rough) {
	float r = rough + 1.0;
	float k = (r * r) / 8.0;
	return NdotV / (NdotV * (1.0 - k) + k);
}

float smith_geometry(float rough, float NdotV, float NdotL) {
	float ggx1 = geometry_schlick_ggx(NdotV, rough);
	float ggx2 = geometry_schlick_ggx(NdotL, rough);
	return ggx1 * ggx2;
}

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

vec3 compute_direct_point_light(vec3 p, vec3 rd, vec3 ro, vec3 normal, vec3 light_pos, vec3 light_color, float light_intensity, float light_radius, float ao) {
	float light_distance = length(light_pos - p);
	vec3 to_light = normalize(light_pos - p);
	vec3 final_normal;

	if (normal_map_projection == 0) final_normal = get_normal_from_map(spherical_uv(p), p, normal);
	else if (normal_map_projection == 1) final_normal = get_normal_from_map(planar_uv(p, 0.1), p, normal);
	else if (normal_map_projection == 2) final_normal = triplanar_normal(p, normal);

	vec3 view_dir = normalize(ro - p);
	vec3 half_vec = normalize(to_light + view_dir);
	float NdotL = max(dot(final_normal, to_light), 0.0);
	float NdotV = max(dot(final_normal, view_dir), 0.0);
	float NdotH = max(dot(final_normal, half_vec), 0.0);
	float HdotV = max(dot(half_vec, view_dir), 0.0);

	vec3 tangent = normalize(cross(final_normal, vec3(0.0, 1.0, 0.0)));
	if (abs(dot(final_normal, vec3(0.0, 1.0, 0.0))) > 0.99) {
		tangent = normalize(cross(final_normal, vec3(1.0, 0.0, 0.0)));
	}
	vec3 bitangent = cross(final_normal, tangent);

	if (abs(anisotropic_rotation) > 0.001) {
		float cos_rot = cos(anisotropic_rotation);
		float sin_rot = sin(anisotropic_rotation);
		vec3 rotated_tangent = tangent * cos_rot + bitangent * sin_rot;
		vec3 rotated_bitangent = -tangent * sin_rot + bitangent * cos_rot;
		tangent = rotated_tangent;
		bitangent = rotated_bitangent;
	}

	float TdotH = dot(tangent, half_vec);
	float BdotH = dot(bitangent, half_vec);

	vec3 f0 = mix(vec3(0.04), vec3(1.0), metallic);
	vec3 fresnel = fresnel_schlick(f0, HdotV);
	vec3 kD = (1.0 - fresnel) * (1.0 - metallic);

	float distance_attenuation = 1.0 / max(light_distance * light_distance, 0.0001);

	float ao_on_diffuse = mix(1.0, ao, ambient_occlusion_light_affect);
	vec3 diffuse = kD * light_color * light_intensity * NdotL * ao_on_diffuse * distance_attenuation;

	if (sss_strength > 0.001) {
		vec3 distorted_light = normalize(to_light + final_normal * sss_distortion);
		float back_scatter = max(dot(view_dir, -distorted_light), 0.0);
		back_scatter = pow(back_scatter, 4.0);
		vec3 sss_contrib = sss_color * back_scatter * sss_strength * light_intensity * distance_attenuation;
		diffuse += sss_contrib * ao_on_diffuse;
	}

	float shadow = !hard_shadows ?
		soft_shadow(p, to_light, shadow_epsilon, light_distance, light_radius) :
		hard_shadow(p, to_light, shadow_epsilon, light_distance);

	float D = abs(anisotropy) > 0.001 ?
		ggx_anisotropic(roughness, anisotropy, NdotH, TdotH, BdotH) :
		ggx_distribution(roughness, NdotH);

	float G = smith_geometry(roughness, NdotV, NdotL);
	vec3 F = fresnel;
	vec3 cook_torrance = (D * G * F) / max(4.0 * NdotV * NdotL, 0.001);
	float ao_on_specular = mix(1.0, ao, ambient_occlusion_light_affect * 0.5);
	vec3 specular_contrib = cook_torrance * specular_intensity * light_color * light_intensity * NdotL * ao_on_specular * distance_attenuation;

	vec3 base_brdf = (diffuse + specular_contrib) * shadow;

	if (clearcoat > 0.001) {
		vec3 clearcoat_f0 = vec3(0.04);
		float coat_D = ggx_distribution(clearcoat_roughness, NdotH);
		float coat_G = smith_geometry(clearcoat_roughness, NdotV, NdotL);
		vec3 coat_F = fresnel_schlick(clearcoat_f0, HdotV);
		vec3 coat_specular = (coat_D * coat_G * coat_F) / max(4.0 * NdotV * NdotL, 0.001);
		coat_specular *= light_color * light_intensity * NdotL * shadow * clearcoat * distance_attenuation;

		base_brdf = base_brdf * (1.0 - clearcoat * 0.5 * coat_F) + coat_specular;
	}

	return base_brdf;
}

vec3 compute_direct_lighting(vec3 p, vec3 rd, vec3 ro, vec3 normal) {
	float ao = calcAO(p, normal);
	vec3 total_light = vec3(0.0);
	vec3 ambient = ambient_light * vec3(1.0);

	if (ambient_light_from_background) {
		if (bg_type == 1) ambient *= sample_panorama_ibl(bg_image, normal);
		if (bg_type == 0) ambient *= pow(texture(bg_color, vec2(acos(normalize(rd).y) / PI, 0.0)).xyz, vec3(2.0));
	}
	else ambient *= ambient_light_color;

	if (light1_enabled && !light2_enabled) total_light = compute_direct_point_light(p, rd, ro, normal, light1_position, light1_color, light1_intensity, light1_radius, ao);
	if (light2_enabled && !light1_enabled) total_light = compute_direct_point_light(p, rd, ro, normal, light2_position, light2_color, light2_intensity, light2_radius, ao);
	if (light2_enabled && light1_enabled) total_light = compute_direct_point_light(p, rd, ro, normal, light2_position, light2_color, light2_intensity, light2_radius, ao) + compute_direct_point_light(p, rd, ro, normal, light1_position, light1_color, light1_intensity, light1_radius, ao);

	total_light += ambient * ao;
	return total_light;
}

vec3 apply_volumetric_fog(vec3 ray_pos, vec3 ray_dir, vec3 pixel_color, float ray_hit_distance, vec2 pixel_pos) {
	int frame = 0;
	float start_ray_offset = interleaved_gradient_noise(pixel_pos, frame);
	float fog_lit_percent = 0.0;

	for (int i = 0; i < fog_samples; i++) {
		float sample_t = (float(i) + start_ray_offset) / float(fog_samples);
		vec3 test_pos = ray_pos + ray_dir * ray_hit_distance * sample_t;

		float shadow1 = 0.0;
		if (light1_enabled) {
			vec3 to_light1 = normalize(light1_position - test_pos);
			float light1_dist = length(light1_position - test_pos);
			shadow1 = hard_shadow(test_pos, to_light1, shadow_epsilon, light1_dist);
		}

		float shadow2 = 0.0;
		if (light2_enabled) {
			vec3 to_light2 = normalize(light2_position - test_pos);
			float light2_dist = length(light2_position - test_pos);
			shadow2 = hard_shadow(test_pos, to_light2, shadow_epsilon, light2_dist);
		}

		float is_lit = 0.0;
		if (light1_enabled && light2_enabled) {
			is_lit = max(shadow1, shadow2);
		} else if (light1_enabled) {
			is_lit = shadow1;
		} else if (light2_enabled) {
			is_lit = shadow2;
		}

		fog_lit_percent = mix(fog_lit_percent, is_lit, 1.0 / float(i + 1));
	}

	vec3 fog_color_from_palette = texture(fog_palette, vec2(fog_lit_percent, 0.0)).xyz;
	float absorb = exp(-ray_hit_distance * fog_density);
	return mix(fog_color_from_palette * fog_brightness, pixel_color, absorb);
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
