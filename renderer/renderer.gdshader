shader_type spatial;
render_mode unshaded;

// Disabled when possible to reduce shader compilation times.
// Line numbers for these 3 lines must stay the same.
//#define USING_DOF
//#define USING_TILING
//#define USING_REFLECTIONS

// Camera
uniform int camera_type = 0;
// Effects / DOF
uniform bool dof_enabled;
uniform int dof_samples;
uniform float dof_focal_distance;
uniform float dof_lens_distance;
uniform float dof_aperture;

// Lighting
uniform float light1_intensity;
uniform float light2_intensity;
uniform bool light1_enabled;
uniform bool light2_enabled;
uniform vec3 light1_position;
uniform vec3 light2_position;
uniform vec3 light1_color;
uniform vec3 light2_color;
uniform float light1_radius;
uniform float light2_radius;
// Material / Ambient
uniform bool ambient_light_from_background;
uniform float ambient_light;
uniform vec3 ambient_light_color;
// Material / Diffuse
uniform sampler2D palette;
uniform float color_exponent;
uniform float specular_intensity;
uniform float specular_sharpness;
uniform float reflection_intensity;
uniform int reflection_bounces;
uniform sampler2D normal_map;
uniform bool normal_map_enabled;
uniform int normal_map_projection;
uniform float normal_map_triplanar_sharpness;
uniform float normal_map_scale;
uniform float normal_map_height;
uniform float normal_epsilon;

uniform int shadow_steps = 32;
uniform float shadow_raystep_multiplier = 1.0;
uniform float shadow_epsilon = 0.01;

uniform int coloring_mode;
uniform float color_offset;
uniform int color_wrapping;
uniform int color_min_iterations;
uniform int color_max_iterations;

// Rendering
uniform int iterations = 8;
uniform int max_steps = 120;
uniform float max_distance = 30.0;
uniform float raystep_multiplier = 1.0;
uniform float epsilon = 0.000003;
uniform bool relative_epsilon = false;
uniform bool interior_mode = false;
uniform float escape_radius;
uniform int de_mode = 1;
uniform float camera_kalaidoscope = 1.0;
// Formula
uniform int formulas[10];
// Lighting / Ambient Occlusion
uniform int ambient_occlusion_steps;
uniform float ambient_occlusion_distance;
uniform float ambient_occlusion_light_affect;
uniform float ambient_occlusion_radius;
// Effects / Vignette
uniform float vignette_strength;
uniform float vignette_radius;
uniform bool is_exponential;
// Effects / Fog
uniform vec3 fog_color: source_color = vec3(0.5, 0.6, 0.7);
uniform float fog_density = 0.01;
uniform float fog_falloff = 1.64;
// Effects / Fresnel
uniform vec3 fresnel_color = vec3(0.0, 0.7, 1.0);
uniform float fresnel_falloff = 5.0;
uniform float fresnel_intensity = 0.0045;
// Effects / Tone mapping
uniform int tone_mapping = 0;
uniform float exposure = 1.0;
uniform float gamma = 2.2;
// Effects / Outline
uniform vec3 outline_color: source_color = vec3(1.0, 0.5, 0.2);
uniform float outline_intensity;
uniform float outline_threshold;
uniform float outline_falloff;
uniform bool outline = false;
uniform bool dither = false;
// Effects / Modifiers
uniform vec3 repeat_gap;
uniform bool repeat;
uniform bool cut;
uniform vec3 cut_normal;
uniform vec3 cut_position;
uniform bool sphere_inversion;
uniform vec4 inversion_sphere;
uniform float inversion_angle;
uniform vec3 translation;
uniform vec3 rotation;
uniform vec3 kalaidoscope;
uniform int kalaidoscope_mode;
// Tooling / Tiling
uniform bool tiled;
uniform int tiles_x;
uniform int tiles_y;
uniform int current_tile;
// Settings / General
uniform bool transparent_bg;
// Settings / Debug
uniform int display;
uniform float depth_scale;
// Lighting / Background
uniform int bg_type;
uniform sampler2D bg_image;
uniform sampler2D bg_color;
// Other
uniform float number_of_active_formulas;
uniform float progression_strength;
// Voxelization
uniform bool voxelization;
uniform vec3 bounds_position;
uniform vec3 bounds_size;
uniform bool building_mesh = false;

#include "math.gdshaderinc"
#include "tonemapping.gdshaderinc"
// -@Uniforms
// -@Imports

vec2 scene_sdf(vec3 p) {
	float d, d2;
	vec3 original_p = p;

	if (length(kalaidoscope) - 1.0 > 0.00001) {
		p.xy = kalaido(p.xy, kalaidoscope.x, kalaidoscope_mode);
		p.yz = kalaido(p.yz, kalaidoscope.y, kalaidoscope_mode);
		p.xz = kalaido(p.xz, kalaidoscope.z, kalaidoscope_mode);
	}

	p -= translation;
	p = rotate3d_point(p, rotation);

	if (sphere_inversion) {
		p -= inversion_sphere.xyz;
		d = length(p);
		d2 = d * d;
		p = (inversion_sphere.w * inversion_sphere.w / d2) * p;
		p += inversion_sphere.xyz;
	}

	if (repeat && repeat_gap.x >= 0.000001) p.x = continuousMod(p.x + 0.5 * repeat_gap.x, repeat_gap.x) - 0.5 * repeat_gap.x;
	if (repeat && repeat_gap.y >= 0.000001) p.y = continuousMod(p.y + 0.5 * repeat_gap.y, repeat_gap.y) - 0.5 * repeat_gap.y;
	if (repeat && repeat_gap.z >= 0.000001) p.z = continuousMod(p.z + 0.5 * repeat_gap.z, repeat_gap.z) - 0.5 * repeat_gap.z;

	// A lot of the code below is edited at runtime.
	vec4 z = vec4(p, 0.000001);
	vec4 original_z = z;
	float orbit = 100000.0;
	float dz = 1.0;
	float s = 1.2;

	vec3 previous_z = z.xyz;

	// Edited at runtime
	for (int i = 0; i < iterations * int(number_of_active_formulas); i++) {
		bool escaped = false;
		int current_formula = formulas[int(mod(float(i), number_of_active_formulas))];
// -@Formulas
		orbit = min(orbit, process_orbit_trap4d(z, original_z, i));

		if (dot(z, z) > escape_radius * escape_radius || escaped) break;
	}

	float r = length(z);
	float de = 0.0;
	
	bool single_formula = false;
	if (formulas[1] <= 0) single_formula = true;

	//bool only_difs_formulas = false;
	// -@CheckOnlyDIFS

	if (de_mode == 0) de = r / dz;
	else if (de_mode == 1) de = 0.5 * log(r) * r / dz;
	else if (de_mode == 2) {
// -@AutomaticDE
	}

if (single_formula) {
// -@SingleDIFS
} else {
// -@MultiDIFS
}

	if (interior_mode) de = abs(de);
	if (cut) de = max(de, dot(original_p + cut_position, normalize(cut_normal)));
	if (sphere_inversion) de = de * d2 / (inversion_sphere.w + d * de);

	if (voxelization) {
		float rect_bound = bounds_rectangle_sdf(original_p, bounds_position, bounds_size);
		de = max(de, rect_bound);
	}

	return vec2(de, orbit).yx;
}

#include "lighting/ambient_occlusion.gdshaderinc"

vec3 ray_marcher(vec3 ro, vec3 rd, inout vec3 palette_color_override, inout bool override_palette_color) {
	float dfo = 0.0;
	float orbit_trap_distance;
	float total_marches = 0.0;
	float final_bounds_dist = 1000000.0;
	vec3 final_bounds_color = vec3(0.0);

	for (int i = 0; i < max_steps; i++) {
		vec3 current_pos = ro + rd * dfo;
		vec2 data = scene_sdf(current_pos);
		
		float bounds_dist = 1000000.0;
		vec3 bounds_color = vec3(0.0);
		if (voxelization && !building_mesh) {
			bounds_dist = bounds_sdf(current_pos, bounds_position, bounds_size, bounds_color);
		}
		
		float point_distance = min(data.y, bounds_dist);
		
		float calc_epsilon = relative_epsilon ? epsilon / 3.4 * dfo : epsilon;
		dfo += max(point_distance * raystep_multiplier, calc_epsilon);
		total_marches += 1.0;

		if (point_distance < calc_epsilon || dfo > max_distance) {
			orbit_trap_distance = data.x;
			final_bounds_dist = bounds_dist;
			final_bounds_color = bounds_color;
			break;
		};
	}
	
	if (voxelization && final_bounds_dist < epsilon) {
		palette_color_override = final_bounds_color;
		override_palette_color = true;
	}

	return vec3(dfo > max_distance ? 0.0 : orbit_trap_distance, dfo, total_marches);
}

vec3 calculate_normal(vec3 p, float h) {
	return normalize(vec3(
		scene_sdf(p + vec3(h, 0.0, 0.0)).y - scene_sdf(p - vec3(h, 0.0, 0.0)).y,
		scene_sdf(p + vec3(0.0, h, 0.0)).y - scene_sdf(p - vec3(0.0, h, 0.0)).y,
		scene_sdf(p + vec3(0.0, 0.0, h)).y - scene_sdf(p - vec3(0.0, 0.0, h)).y
	));
}

vec3 equirectangular_ray_direction(vec2 uv) {
	float theta = (uv.x - 0.5) * 2.0 * PI;
	float phi = (uv.y - 0.5) * PI;
	
	return normalize(vec3(
		cos(phi) * sin(theta),
		sin(phi),
		cos(phi) * cos(theta)
	));
}

varying vec3 vertex_ls;
void vertex() { vertex_ls = VERTEX; }

vec3 get_ray_direction(vec2 screen_uv, mat4 view_matrix, vec3 ro) {
	if (camera_type == 1) {
		vec3 base_dir = equirectangular_ray_direction(screen_uv);
		vec3 camera_forward = normalize(vec3(view_matrix[0][2], view_matrix[1][2], view_matrix[2][2]));
		vec3 camera_up = normalize(vec3(view_matrix[0][1], view_matrix[1][1], view_matrix[2][1]));
		vec3 camera_right = normalize(vec3(view_matrix[0][0], view_matrix[1][0], view_matrix[2][0]));
		mat3 camera_matrix = mat3(camera_right, camera_up, -camera_forward);
		return normalize(camera_matrix * base_dir);
	}
	else return normalize(vertex_ls - ro);
}

#include "lighting/lighting.gdshaderinc"

vec4 render_single_ray(vec3 ray_origin, vec3 ray_dir, vec2 screen_uv, mat4 projection_matrix, mat4 view_matrix, inout bool discard_color) {
	vec3 final_color;
	
	if (building_mesh) {
		vec3 camera_forward = normalize(vec3(view_matrix[0][2], view_matrix[1][2], view_matrix[2][2]));
		vec3 camera_up = normalize(vec3(view_matrix[0][1], view_matrix[1][1], view_matrix[2][1]));
		vec3 camera_right = normalize(vec3(view_matrix[0][0], view_matrix[1][0], view_matrix[2][0]));
		
		float sample_scale = 4.0;
		vec3 sample_offset = camera_right * (screen_uv.x - 0.5) * sample_scale + 
		                    camera_up * (screen_uv.y - 0.5) * sample_scale;
		vec3 sample_pos = ray_origin + sample_offset;
		
		vec2 sdf_data = scene_sdf(sample_pos);
		float distance_to_surface = sdf_data.y;
		
		if (distance_to_surface < 0.0) {
			final_color = vec3(1.0);
		} else {
			final_color = vec3(0.0);
		}
		
		return vec4(final_color, 1.0);
	}

	vec3 color;
	bool override_color = false;
	vec3 data = ray_marcher(ray_origin, ray_dir, color, override_color);
	
	float orbit_trap = data.x;
	float dfo = data.y;
	float total_marches = data.z;
	float orbit_x = orbit_trap + color_offset;
	if (color_wrapping == 1) orbit_x = sin(orbit_x);
	else if (color_wrapping == 2) orbit_x = sinh(orbit_x);
	else if (color_wrapping == 3) orbit_x = asin(orbit_x);
	else if (color_wrapping == 4) orbit_x = tanh(orbit_x);
	else if (color_wrapping == 5) orbit_x = atan(orbit_x);
	else if (color_wrapping == 6) orbit_x = tan(orbit_x);

	vec3 palette_color = 3.0 * pow(texture(palette, vec2(orbit_x, 0.0)).xyz, vec3(color_exponent));
	if (override_color) palette_color = color;
	
	vec3 p = ray_origin + ray_dir * dfo;
	vec3 normal = calculate_normal(p, normal_epsilon);
	if (dfo >= max_distance) {
		if (transparent_bg) discard_color = true;

		vec3 sph_dir = normalize(ray_dir);

		float theta = atan(sph_dir.z, sph_dir.x);
		float phi = acos(sph_dir.y);

		vec2 uv;
		uv.x = (theta / (2.0 * PI)) + 0.5;
		uv.y = phi / PI;

		if (bg_type == 0) final_color = pow(texture(bg_color, vec2(acos(sph_dir.y) / PI, 0.0)).xyz, vec3(2.0));
		if (bg_type == 1) final_color = texture(bg_image, uv).xyz;
	} else {
		if (display == 1) final_color = vec3(calcAO(p, normal));
		else final_color = palette_color * compute_direct_lighting(p, ray_dir, ray_origin, normal);
	}

	// Outline
	if (outline && float(total_marches) * raystep_multiplier > outline_threshold) {
		float outline_factor = smoothstep(outline_threshold, 100.0, float(total_marches) * raystep_multiplier);
		final_color = mix(final_color, 3.0 * outline_color, pow(outline_intensity * outline_factor, outline_falloff));
	}

	// Fog
	float fog_distance = dfo < max_distance ? dfo : max_distance;
	float fog_amount = 1.0 - exp(-fog_density * fog_distance);
	final_color = mix(final_color, fog_color, pow(fog_amount, fog_falloff));

	// Fresnel
	if (dfo < max_distance) {
		float cosTheta = clamp(dot(normal, -ray_dir), 0.0, 2.0);
		float fresnelFactor = fresnel_intensity * pow(1.0 - cosTheta, fresnel_falloff);
		final_color = mix(final_color, fresnel_color, fresnelFactor);
	}

	// Tone mapping and Gamma correction
	if (dfo < max_distance || bg_type != 1) {
		final_color = tonemap_color(final_color);
		final_color = gamma_correct(final_color);
	} else if (bg_type == 1) {
		float image_exposure = 1.5;
		final_color *= (image_exposure + 0.5) / (1.0 + final_color / image_exposure);
		final_color = final_color * final_color;
	}

	// Debug
	if (display == 2) return vec4(normal, 1.0);
	else if (display == 3) return vec4(vec3(dfo * depth_scale), 1.0);

	return vec4(final_color, 1.0);
}

vec3 render_ray(vec3 ray_origin, vec3 ray_dir, vec2 screen_uv, mat4 projection_matrix, mat4 view_matrix, inout bool discard_color, vec2 resolution) {
	vec3 current_origin = ray_origin;
	vec3 current_dir = ray_dir;

	// Initial ray
	vec4 result = render_single_ray(current_origin, current_dir, screen_uv, projection_matrix, view_matrix, discard_color);
	vec3 final_color = result.rgb;
	bool hit_surface = result.a > 0.5;

#ifdef USING_REFLECTIONS
	// Ray hit data for initial ray
	vec3 data = ray_marcher(current_origin, current_dir);
	float dfo = data.y;
	vec3 hit_point = current_origin + current_dir * dfo;
	vec3 normal = calculate_normal(hit_point, relative_epsilon ? epsilon / 3.4 * dfo : epsilon);

	// Calculate reflections
	float reflection_strength = reflection_intensity;
	bool reflections_enabled = reflection_intensity >= 0.0001;

	for (int i = 0; i < reflection_bounces && reflections_enabled && hit_surface && display == 0; i++) {
		current_dir = reflect(current_dir, normal);
		current_origin = hit_point + normal * epsilon * 2.0;

		result = render_single_ray(current_origin, current_dir, screen_uv, projection_matrix, view_matrix, discard_color);
		hit_surface = result.a > 0.5;

		final_color = mix(final_color, result.rgb, reflection_strength);

		data = ray_marcher(current_origin, current_dir);
		dfo = data.y;
		hit_point = current_origin + current_dir * dfo;
		normal = calculate_normal(hit_point, relative_epsilon ? epsilon / 3.4 * dfo : epsilon);

		if (!hit_surface) break;
	}
#endif

	// Vignette (disabled for equirectangular)
	if (camera_type != 1 && !building_mesh) {
		if (is_exponential) {
			vec2 vignette_uv = screen_uv * (1.0 - screen_uv.yx);
			float vignette = pow(vignette_uv.x * vignette_uv.y * (vignette_radius * 17.0), vignette_strength * 0.5 * 0.75);
			final_color *= vignette;
		} else {
			float vignette = smoothstep(vignette_radius, vignette_radius - vignette_strength, length(screen_uv - vec2(0.5)));
			final_color *= vignette;
		}
	}

	return final_color;
}

vec3 calculate_albedo(vec3 ray_origin, vec3 ray_dir, vec2 screen_uv, vec2 fragCoord, vec2 resolution, mat4 projection_matrix, mat4 view_matrix, inout bool discard_color) {
	float time = float(TIME);
	float baseSeed = hash(screen_uv + time * 0.01);

	if (!dof_enabled || display != 0 || building_mesh) return render_ray(ray_origin, ray_dir, screen_uv, projection_matrix, view_matrix, discard_color, resolution);

#ifdef USING_DOF
	vec3 camera_forward = normalize(vec3(view_matrix[0][2], view_matrix[1][2], view_matrix[2][2]));
	vec3 camera_up = normalize(vec3(view_matrix[0][1], view_matrix[1][1], view_matrix[2][1]));
	vec3 camera_right = normalize(vec3(view_matrix[0][0], view_matrix[1][0], view_matrix[2][0]));

	vec3 colorTotal = vec3(0.0);

	for (int i = 0; i < dof_samples; i++) {
		float sampleSeed = baseSeed + float(i) / float(dof_samples);
		vec2 pixelOffset = hash2(sampleSeed * 42.0) - 0.5;
		pixelOffset *= float(dof_samples) / resolution;

		vec2 jitteredUV = screen_uv + pixelOffset;
		
		vec3 baseRd = get_ray_direction(jitteredUV, view_matrix, ray_origin);
		float ft = dof_focal_distance;
		vec3 focusPoint = ray_origin + baseRd * ft;

		vec2 lensOffset = fibonacci_circle(float(i) + sampleSeed * 7.1, float(dof_samples)) * dof_aperture;
		vec3 lensPos = ray_origin + camera_right * lensOffset.x + camera_up * lensOffset.y;
		vec3 rd = normalize(focusPoint - lensPos);

		colorTotal += render_ray(lensPos, rd, jitteredUV, projection_matrix, view_matrix, discard_color);
	}

	vec3 finalColor = colorTotal / float(dof_samples);
	return finalColor;
#else
	return vec3(0.0);
#endif
}

#define SET_ALBEDO bool discard_color = false; \
	vec3 ro = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz; \
	vec3 rd = get_ray_direction(SCREEN_UV, VIEW_MATRIX, ro); \
	ALBEDO = calculate_albedo(ro, rd, SCREEN_UV, FRAGCOORD.xy, VIEWPORT_SIZE, PROJECTION_MATRIX, VIEW_MATRIX, discard_color); \
	if (discard_color) discard;

void fragment() {
	if (hash(FRAGCOORD.xy + TIME) > progression_strength / 100.0) discard;

	float error_margin = 2.0;

	#ifdef USING_TILING
	if (tiled) {
		int tile_idx = int(current_tile);
		int t_x = int(tiles_x);
		int t_y = int(tiles_y);

		int tile_x_pos = tile_idx % t_x;
		int tile_y_pos = tile_idx / t_x;

		vec2 tile_size = 1.0 / vec2(float(t_x), float(t_y));
		vec2 padding = error_margin / VIEWPORT_SIZE;

		vec2 tile_start = vec2(float(tile_x_pos), float(tile_y_pos)) * tile_size;
		vec2 tile_end = tile_start + tile_size;

		vec2 tile_min = max(tile_start - padding, vec2(0.0));
		vec2 tile_max = min(tile_end + padding, vec2(1.0));

		if (SCREEN_UV.x >= tile_min.x && SCREEN_UV.x < tile_max.x &&
		    SCREEN_UV.y >= tile_min.y && SCREEN_UV.y < tile_max.y) {
			SET_ALBEDO
		} else {
			discard;
		}
	} else {
		SET_ALBEDO
	}
	#else
	SET_ALBEDO
	#endif
}