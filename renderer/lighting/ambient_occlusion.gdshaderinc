
float calcAO(vec3 pos, vec3 normal) {
	const float max_dist = 0.07;
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
