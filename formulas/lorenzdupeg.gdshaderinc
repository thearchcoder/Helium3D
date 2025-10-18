// [ID]
// Lorenz Dupe G
// [DISABLED]
// [OFFICIAL]
// [DIFS]
// [VARS]
// [CODE]
uniform sampler3D florenzdupeg_field;
uniform vec3 florenzdupeg_field_bounds;

vec2 lorenzdupeg_sdf(vec4 z4d) {
	vec3 z = z4d.xyz;
	vec3 uv = (z + florenzdupeg_field_bounds * 0.5) / florenzdupeg_field_bounds;
	uv = clamp(uv, vec3(0.0), vec3(1.0));
	
	vec3 field_size = vec3(textureSize(florenzdupeg_field, 0));
	vec3 texel_pos = uv * field_size - 0.5;
	vec3 base_pos = floor(texel_pos);
	vec3 fract_pos = texel_pos - base_pos;
	vec3 smooth_fract = quintic_interp(fract_pos);
	
	vec3 texel_size = 1.0 / field_size;
	vec3 sample_uv = (base_pos + smooth_fract + 0.5) * texel_size;
	
	float normalized_dist = texture(florenzdupeg_field, sample_uv).r;
	float dist = normalized_dist * 2.0;
	float smoothing_radius = 0.02;
	dist = dist - smoothing_radius + smoothing_radius * exp(-abs(dist) / smoothing_radius);
	return vec2(dist - 0.01, 0.0);
}
