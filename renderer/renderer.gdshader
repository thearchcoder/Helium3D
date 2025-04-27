shader_type spatial;
render_mode unshaded;

// Disabled when possible to reduce shader compilation times.
// Line numbers for these 2 lines must stay the same.
//#define USING_DOF
//#define USING_TILING

// Effects / DOF
uniform bool dof_enabled = false;
uniform int dof_samples = 3;
uniform float dof_focal_distance = 7.0;
uniform float dof_lens_distance = 10.3;
uniform float dof_aperture = 0.0;

// Lighting
uniform float light_intensity = 0.6;
uniform vec3 light1_position = vec3(10.0, 10.0, -10.0);
uniform vec3 light2_position = vec3(-10.0, -10.0, 10.0);
uniform vec3 light1_color: source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 light2_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float ambient_light = 0.08;
uniform float specular_intensity = 2.611;
uniform float specular_sharpness = 8.0;

uniform int shadow_steps = 32;
uniform float shadow_raystep_multiplier = 1.0;
uniform float shadow_epsilon = 0.01;

uniform sampler2D palette;
uniform sampler2D bg_color;
uniform int coloring_mode = 0;

// Rendering
uniform int iterations = 8;
uniform int max_steps = 120;
uniform float max_distance = 30.0;
uniform float raystep_multiplier = 1.0;
uniform float epsilon = 0.000003;
uniform bool relative_epsilon = false;
uniform float escape_radius;
// Formula
uniform int formulas[10];
// Effects / Ambient Occlusion
uniform int ambient_occlusion_steps = 6;
uniform float ambient_occlusion_radius = 0.5;
uniform float ambient_occlusion_brightness = 0.0;
// Effects / Vignette
uniform float vignette_strength = 0.7;
uniform float vignette_radius = 0.8;
uniform bool is_exponential = true;
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
uniform float outline_intensity: hint_range(0.0, 5.0) = 1.0;
uniform float outline_threshold: hint_range(0.0, 100.0) = 30.0;
uniform float outline_falloff: hint_range(1.0, 10.0) = 2.0;
uniform bool outline = false;
// Effects / Modifiers
uniform vec3 repeat_gap = vec3(2.0);
uniform bool repeat = false;
uniform bool cut = false;
uniform vec3 cut_normal = vec3(0.0, 1.0, 0.0);
uniform vec3 cut_position = vec3(0.0, 0.0, 0.0);
// Performance
uniform bool tiled = false;
uniform int tiles_x = 4;
uniform int tiles_y = 4;
uniform int current_tile = 0; // first tile by default

#include "math.gdshaderinc"
#include "tonemapping.gdshaderinc"
#include "res://formulas/mandelbulb.gdshaderinc"
#include "res://formulas/kochcube.gdshaderinc"
#include "res://formulas/kochwire.gdshaderinc"
#include "res://formulas/mandelbox.gdshaderinc"
#include "res://formulas/sierpinskitetrahedron.gdshaderinc"
#include "res://formulas/mengersponge.gdshaderinc"
#include "res://formulas/pseudoklenian.gdshaderinc"
#include "res://formulas/amazingsurf.gdshaderinc"
#include "res://formulas/sierpinskidodecahedron.gdshaderinc"
#include "res://formulas/sierpinskiicosahedron.gdshaderinc"
#include "res://formulas/sierpinskioctahedron.gdshaderinc"
#include "res://formulas/bairddelta.gdshaderinc"
#include "res://formulas/klenian.gdshaderinc"
#include "res://formulas/spheretree.gdshaderinc"
#include "res://formulas/kaliredux.gdshaderinc"
#include "res://formulas/quadratickoch.gdshaderinc"
#include "res://formulas/kaliliving.gdshaderinc"
#include "res://formulas/newton.gdshaderinc"
#include "res://formulas/mixpinski4d.gdshaderinc"
#include "res://formulas/vicsek.gdshaderinc"
#include "res://formulas/kalibox.gdshaderinc"
#include "res://formulas/sphairahedron.gdshaderinc"

vec2 single_fractal_sdf(int formula, vec3 p) {
	if (repeat && repeat_gap.x >= 0.000001) p.x = mod(p.x + 0.5 * repeat_gap.x, repeat_gap.x) - 0.5 * repeat_gap.x;
	if (repeat && repeat_gap.y >= 0.000001) p.y = mod(p.y + 0.5 * repeat_gap.y, repeat_gap.y) - 0.5 * repeat_gap.y;
	if (repeat && repeat_gap.z >= 0.000001) p.z = mod(p.z + 0.5 * repeat_gap.z, repeat_gap.z) - 0.5 * repeat_gap.z;

	// Edited at runtime.
//if (formula == 22) return sphairahedron_sdf(p); //-@22
//if (formula == 21) return kalibox_sdf(p); //-@21
//if (formula == 20) return kochwire_sdf(p); //-@20
//if (formula == 19) return vicsek_sdf(p); //-@19
//if (formula == 18) return mixpinski4d_sdf(p); //-@18
//if (formula == 17) return kaliliving_sdf(p); //-@17
//if (formula == 16) return quadratickoch_sdf(p); //-@16
//if (formula == 15) return newton_sdf(p); //-@15
//if (formula == 14) return kochcube_sdf(p); //-@14
//if (formula == 13) return kaliredux_sdf(p); //-@13
//if (formula == 12) return spheretree_sdf(p); //-@12
//if (formula == 11) return klenian_sdf(p); //-@11
//if (formula == 10) return pseudoklenian_sdf(p); //-@10
//if (formula == 9)  return sierpinskidodecahedron_sdf(p); //-@9
//if (formula == 8)  return sierpinskioctahedron_sdf(p); //-@8
//if (formula == 7)  return mengersponge_sdf(p); //-@7
//if (formula == 6)  return sierpinskitetrahedron_sdf(p); //-@6
//if (formula == 5)  return sierpinskiicosahedron_sdf(p); //-@5
//if (formula == 4)  return bairddelta_sdf(p); //-@4
//if (formula == 3)  return amazingsurf_sdf(p); //-@3
//if (formula == 2)  return mandelbox_sdf(p); //-@2
//if (formula == 1)  return mandelbulb_sdf(p); //-@1

	return vec2(0.0);
}

vec2 scene_sdf(vec3 p) {
	vec2 data = single_fractal_sdf(formulas[0], p);
	if (formulas[1] > 0) data = data.x < 0.1 ? (data + single_fractal_sdf(formulas[1], p)) * 0.5 : data;

	// Slice the fractal if needed.
	if (cut) data.x = max(data.x, dot(p + cut_position, normalize(cut_normal)));

	return data.yx;
}

#include "lighting/ambient_occlusion.gdshaderinc"

vec3 ray_marcher(vec3 ro, vec3 rd) {
	float dfo = 0.0;
	float orbit_trap_distance;
	float total_marches = 0.0;

	for (int i = 0; i < max_steps; i++) {
		vec2 data = scene_sdf(ro + rd * dfo);
		float point_distance = data.y;
		dfo += point_distance * raystep_multiplier;
		total_marches += 1.0;

		float calc_epsilon = relative_epsilon ? epsilon / 3.4 * dfo : epsilon;
		if (point_distance < 0.0) {
			dfo += point_distance;
			break;
		} else if (point_distance < calc_epsilon || dfo > max_distance) {
			orbit_trap_distance = data.x;
			break;
		};
	}

	return vec3(dfo > max_distance ? 0.0 : orbit_trap_distance, dfo, total_marches);
}

vec3 calculate_normal(vec3 p, float h) {
	float dist = scene_sdf(p).y;

	// Sample multiple points and average
	vec3 n = vec3(0.0);
	for (int i = 0; i < 1; i++) {
		float angle = float(i) * PI / 2.0;
		vec2 e = vec2(sin(angle), cos(angle)) * h;

		n.x += scene_sdf(p + vec3(h, e.x, e.y)).y - dist;
		n.y += scene_sdf(p + vec3(e.y, h, e.x)).y - dist;
		n.z += scene_sdf(p + vec3(e.x, e.y, h)).y - dist;
	}

	return normalize(n);
}

#include "lighting/lighting.gdshaderinc"

varying vec3 vertex_ls;

void vertex() {
	vertex_ls = VERTEX;
}

vec3 render_single_ray(vec3 ray_origin, vec3 ray_dir, vec2 screen_uv, mat4 projection_matrix, mat4 view_matrix) {
	vec3 data = ray_marcher(ray_origin, ray_dir);
	float orbit_trap_distance = data.x;
	float dfo = data.y;
	float total_marches = data.z;
	vec3 palette_color = texture(palette, vec2(orbit_trap_distance, 0.0)).xyz;
	vec3 final_color;
	vec3 p = ray_origin + ray_dir * dfo;
	vec3 normal = calculate_normal(p, relative_epsilon ? epsilon / 3.4 * dfo : epsilon);

	if (dfo >= max_distance) {
		final_color = pow(texture(bg_color, vec2(screen_uv.y, 0.0)).xyz, vec3(2.0));
	} else {
		float ao = calcAO(p, normal) + ambient_light;
		vec3 light1 = get_light(p, ray_dir, ray_origin, light1_position, light1_color, normal);
		vec3 light2 = get_light(p, ray_dir, ray_origin, light2_position, light2_color, normal);

		final_color = 3.0 * palette_color * ao * (light1 + light2);
	}

	// Outline
	if (outline && float(total_marches) * raystep_multiplier > outline_threshold) {
		float outline_factor = smoothstep(outline_threshold, 100.0, float(total_marches) * raystep_multiplier);
		final_color += 3.0 * outline_color * pow(outline_intensity * outline_factor, outline_falloff);
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
	final_color = tonemap_color(final_color);
	final_color = gamma_correct(final_color);

	// Vignette
	if (is_exponential) {
		vec2 vignette_uv = screen_uv * (1.0 - screen_uv.yx);
		float vignette = pow(vignette_uv.x * vignette_uv.y * (vignette_radius * 17.0), vignette_strength * 0.5 * 0.75);
		final_color *= vignette;
	} else {
		float vignette = smoothstep(vignette_radius, vignette_radius - vignette_strength, length(screen_uv - vec2(0.5)));
		final_color *= vignette;
	}

	return final_color;
}

vec3 calculate_albedo(vec3 ray_origin, vec3 ray_dir, vec2 screen_uv, vec2 fragCoord, vec2 resolution, mat4 projection_matrix, mat4 view_matrix) {
	float time = float(TIME);
	float baseSeed = hash(screen_uv + time * 0.01);

	if (!dof_enabled) return render_single_ray(ray_origin, ray_dir, screen_uv, projection_matrix, view_matrix);

#ifdef USING_DOF
	vec3 cameraDir = ray_dir;
	vec3 cameraX = normalize(cross(vec3(0.0, 1.0, 0.0), cameraDir));
	vec3 cameraY = normalize(cross(cameraDir, cameraX));

	vec3 colorTotal = vec3(0.0);

	for (int i = 0; i < dof_samples; i++) {
		float sampleSeed = baseSeed + float(i) / float(dof_samples);
		vec2 pixelOffset = hash2(sampleSeed * 42.0) - 0.5;
		pixelOffset *= float(dof_samples) / resolution;

		vec2 jitteredUV = screen_uv + pixelOffset;
		vec3 baseRd = ray_dir;
		float ft = dof_focal_distance / dot(baseRd, cameraDir);
		vec3 focusPoint = ray_origin + baseRd * ft;

		vec2 lensOffset = fibonacci_circle(float(i) + sampleSeed * 7.1, float(dof_samples)) * dof_aperture;
		vec3 lensPos = ray_origin + cameraX * lensOffset.x + cameraY * lensOffset.y;
		vec3 rd = normalize(focusPoint - lensPos);

		colorTotal += render_single_ray(lensPos, rd, jitteredUV, projection_matrix, view_matrix);
	}

	vec3 finalColor = colorTotal / float(dof_samples);
	return finalColor;
#else
	return vec3(0.0);
#endif
}

void fragment() {
	float error_margin = 1.0; // Controls the border thickness
	vec3 ro = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz;
	vec3 rd = normalize(vertex_ls - ro);
	#ifdef USING_TILING
	if (tiled) {
		float total_tiles = float(tiles_x * tiles_y);
		vec2 tile_size = 1.0 / vec2(float(tiles_x), float(tiles_y));

		vec2 padding = error_margin / VIEWPORT_SIZE; // Configurable padding
		vec2 padded_uv = SCREEN_UV;
		vec2 fragment_tile = floor(padded_uv / tile_size);

		float tile_index = fragment_tile.y * float(tiles_x) + fragment_tile.x;

		bool is_current = false;
		if (tile_index == float(current_tile)) {
			is_current = true;
		} else {
			vec2 tile_pos = vec2(mod(float(current_tile), float(tiles_x)), floor(float(current_tile) / float(tiles_x)));
			vec2 tile_min = tile_pos * tile_size - padding;
			vec2 tile_max = (tile_pos + 1.0) * tile_size + padding;

			if (padded_uv.x >= tile_min.x && padded_uv.x <= tile_max.x &&
				padded_uv.y >= tile_min.y && padded_uv.y <= tile_max.y) {
				is_current = true;
			}
		}

		if (is_current) {
			ALBEDO = calculate_albedo(ro, rd, SCREEN_UV, FRAGCOORD.xy, VIEWPORT_SIZE, PROJECTION_MATRIX, VIEW_MATRIX);
		} else {
			discard;
		}
	} else {
		ALBEDO = calculate_albedo(ro, rd, SCREEN_UV, FRAGCOORD.xy, VIEWPORT_SIZE, PROJECTION_MATRIX, VIEW_MATRIX);
	}
	#else
	ALBEDO = calculate_albedo(ro, rd, SCREEN_UV, FRAGCOORD.xy, VIEWPORT_SIZE, PROJECTION_MATRIX, VIEW_MATRIX);
	#endif
}