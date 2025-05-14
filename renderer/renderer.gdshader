shader_type spatial;
render_mode unshaded;

// Disabled when possible to reduce shader compilation times.
// Line numbers for these 2 lines must stay the same.
//#define USING_DOF
//#define USING_TILING
//#define USING_REFLECTIONS

// Effects / DOF
uniform bool dof_enabled = false;
uniform int dof_samples = 3;
uniform float dof_focal_distance = 7.0;
uniform float dof_lens_distance = 10.3;
uniform float dof_aperture = 0.0;

// Lighting
uniform float light1_intensity = 0.6;
uniform float light2_intensity = 0.6;
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
uniform int coloring_mode;
uniform float color_offset;
uniform int color_min_iterations;
uniform int color_max_iterations;

// Rendering
uniform int iterations = 8;
uniform int max_steps = 120;
uniform float max_distance = 30.0;
uniform float raystep_multiplier = 1.0;
uniform float epsilon = 0.000003;
uniform bool relative_epsilon = false;
uniform float escape_radius;
uniform int de_mode = 1;
// Formula
uniform int formulas[10];
// Lighting / Ambient Occlusion
uniform int ambient_occlusion_steps = 6;
uniform float ambient_occlusion_radius = 0.5;
uniform vec3 ambient_occlusion_color = vec3(1.0);
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
uniform bool sphere_inversion = false;
uniform vec4 inversion_sphere = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec3 translation = vec3(0.0);
uniform vec3 rotation = vec3(0.0);
uniform vec3 kalaidoscope = vec3(1.0);
// Performance
uniform bool tiled = false;
uniform int tiles_x = 4;
uniform int tiles_y = 4;
uniform int current_tile = 0; // first tile by default
// Settings
uniform bool transparent_bg = true;

// Lighting / Background
uniform int bg_type;
uniform sampler2D bg_image;
uniform sampler2D bg_color;

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
#include "res://formulas/lionbulb.gdshaderinc"
#include "res://formulas/jerusalemcube.gdshaderinc"

vec2 scene_sdf(vec3 p) {
	float d, d2;

	if (length(kalaidoscope) - 1.0 > 0.00001) {
		p.xy = kalaido(p.xy, kalaidoscope.x);
		p.yz = kalaido(p.yz, kalaidoscope.y);
		p.xz = kalaido(p.xz, kalaidoscope.z);
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

	// Edited at runtime.
	vec4 z = vec4(p, 0.000001);
	vec4 original_z = z;
	float orbit = 100000.0;
	float dz = 1.0;
	float s = 1.2;

	// sphairahedron precompute
//float zb = fsphairahedron_zb;                                          //-@22
//float zc = fsphairahedron_zc;                                          //-@22
//vec4 s2 = getS2A(zb, zc);                                              //-@22
//vec4 s4 = getS4A(zb, zc);                                              //-@22
//vec4 s6 = getS6A(zb, zc);                                              //-@22
//vec4 inversionSphere = getInversionSphere(zb, zc);                     //-@22
//vec4 g0 = computeGSpheres0(inversionSphere);                           //-@22
//vec4 g1 = computeGSpheres1(inversionSphere, s2);                       //-@22
//vec4 g2 = computeGSpheres2(inversionSphere);                           //-@22
//vec4 g3 = computeGSpheres3(inversionSphere, s4);                       //-@22
//vec4 g4 = computeGSpheres4(inversionSphere);                           //-@22
//vec4 g5 = computeGSpheres5(inversionSphere, s6);                       //-@22
//vec3 v0 = computeVertexes0(g0, g1, g2);                                //-@22
//vec3 v1 = computeVertexes1(g0, g3, g4);                                //-@22
//vec3 v2 = computeVertexes2(g2, g4, g5);                                //-@22
//Plane dividePlane = computeDividePlane(inversionSphere, v0, v1, v2);   //-@22
//vec4 convexSphere = computeConvexSphere(inversionSphere, dividePlane); //-@22

	// kleinian precompute
	vec3 lz = z.xyz + vec3(1.0);
	vec3 llz = z.xyz + vec3(-1.0);
	float DF = 1.0;
	float a = fklenian_x;
	float b = fklenian_y;
	float f = sign(b);

	for (int i = 0; i < iterations; i++) {
		bool escaped = false;
//mandelbulb_iter(z, dz, original_z, orbit, i);             //-@1
//mandelbox_iter(z, dz, original_z, orbit, i);              //-@2
//amazingsurf_iter(z, dz, original_z, orbit, i);            //-@3
//bairddelta_iter(z, dz, original_z, orbit, i);             //-@4
//sierpinskiicosahedron_iter(z, dz, original_z, orbit, i);  //-@5
//sierpinskitetrahedron_iter(z, dz, original_z, orbit, i);  //-@6
//mengersponge_iter(z, dz, original_z, orbit, i);           //-@7
//sierpinskioctahedron_iter(z, dz, original_z, orbit, i);   //-@8
//sierpinskidodecahedron_iter(z, dz, original_z, orbit, i); //-@9
//pseudoklenian_iter(z, dz, original_z, orbit, i);          //-@10
//klenian_iter(z, dz, original_z, orbit, i, DF, a, b, f, llz, lz, escaped); //-@11
//spheretree_iter(z, dz, original_z, orbit, i, escaped);    //-@12
//kochcube_iter(z, dz, original_z, orbit, i, s);            //-@14
//quadratickoch_iter(z, dz, original_z, orbit, i);          //-@16
//kaliliving_iter(z, dz, original_z, orbit, i);             //-@17
//mixpinski4d_iter(z, dz, original_z, orbit, i);            //-@18
//vicsek_iter(z, dz, original_z, orbit, i);                 //-@19
//kochwire_iter(z, dz, original_z, orbit, i);               //-@20
//kalibox_iter(z, dz, original_z, orbit, i);                //-@21
//sphairahedron_iter(z, dz, original_z, orbit, i, s2, s4, s6, dividePlane.normal, dividePlane.p1, escaped); //-@22
//lionbulb_iter(z, dz, original_z, orbit, i);               //-@23
//jerusalemcube_iter(z, dz, original_z, orbit, i);          //-@24
		orbit = min(orbit, process_orbit_trap4d(z, original_z, i));
		if (length(z) > escape_radius || escaped) break;
	}

	float r = length(z);
	float de;

if (de_mode == 0) de = length(z) / dz;
else if (de_mode == 1) de = 0.5 * log(r) * r / dz;
//else if (de_mode == 2) de = distInfSphairahedra(z.xyz, s2, s4, s6, dividePlane.p1, dividePlane.normal) / abs(dz) * 0.25; //-@22
//else if (de_mode == 3) de = min(fklenian_show_balls ? min(z.y, a - z.y) : z.y, 0.3) / max(DF, 2.0); //-@11

	if (sphere_inversion) de = de * d2 / (inversion_sphere.w + d * de);
	if (cut) de = max(de, dot(p + cut_position, normalize(cut_normal)));

	//de = max(de, 0.0);

	return vec2(de, orbit).yx;
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
	return normalize(vec3(
		scene_sdf(p + vec3(h, 0.0, 0.0)).y - scene_sdf(p - vec3(h, 0.0, 0.0)).y,
		scene_sdf(p + vec3(0.0, h, 0.0)).y - scene_sdf(p - vec3(0.0, h, 0.0)).y,
		scene_sdf(p + vec3(0.0, 0.0, h)).y - scene_sdf(p - vec3(0.0, 0.0, h)).y
	));
}


#include "lighting/lighting.gdshaderinc"

varying vec3 vertex_ls;
void vertex() { vertex_ls = VERTEX; }

uniform float reflection_intensity = 1.0;
uniform int reflection_bounces = 1;

vec4 render_single_ray(vec3 ray_origin, vec3 ray_dir, vec2 screen_uv, mat4 projection_matrix, mat4 view_matrix, inout bool discard_color) {
	vec3 data = ray_marcher(ray_origin, ray_dir);
	float orbit_trap = data.x;
	float dfo = data.y;
	float total_marches = data.z;
	vec3 palette_color = pow(texture(palette, vec2(orbit_trap + color_offset, 0.0)).xyz, vec3(2.0));
	vec3 final_color;
	vec3 p = ray_origin + ray_dir * dfo;
	vec3 normal = calculate_normal(p, relative_epsilon ? epsilon / 3.4 * dfo : epsilon);

	if (dfo >= max_distance) {
		if (transparent_bg) discard_color = true;

		vec3 sph_dir = normalize(ray_dir);
		vec2 uv;

		float theta = atan(sph_dir.z, sph_dir.x);
		float phi = acos(sph_dir.y);

		uv.x = (theta / (2.0 * PI)) + 0.5;
		uv.y = phi / PI;

		// uv = ray_dir.xy * 0.5 + 0.5;

		if (bg_type == 0) final_color = pow(texture(bg_color, vec2(screen_uv.y, 0.0)).xyz, vec3(2.0));
		if (bg_type == 1) final_color = texture(bg_image, uv).xyz;
	} else {
		vec3 ao = ambient_occlusion_color * (calcAO(p, normal) + ambient_light);
		vec3 light1 = get_light(p, ray_dir, ray_origin, light1_position, light1_color, light1_intensity, normal);
		vec3 light2 = get_light(p, ray_dir, ray_origin, light2_position, light2_color, light2_intensity, normal);

		final_color = 3.0 * palette_color * ao * (light1 + light2);
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
		final_color = pow(final_color, vec3(1.0 / 0.5));
	}

	return vec4(final_color, dfo < max_distance ? 1.0 : 0.0);
}

vec3 render_ray(vec3 ray_origin, vec3 ray_dir, vec2 screen_uv, mat4 projection_matrix, mat4 view_matrix, inout bool discard_color) {
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

	for (int i = 0; i < reflection_bounces && reflections_enabled && hit_surface; i++) {
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

// Update calculate_albedo to use render_ray instead of render_single_ray
vec3 calculate_albedo(vec3 ray_origin, vec3 ray_dir, vec2 screen_uv, vec2 fragCoord, vec2 resolution, mat4 projection_matrix, mat4 view_matrix, inout bool discard_color) {
	float time = float(TIME);
	float baseSeed = hash(screen_uv + time * 0.01);

	if (!dof_enabled) return render_ray(ray_origin, ray_dir, screen_uv, projection_matrix, view_matrix, discard_color);

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

		colorTotal += render_ray(lensPos, rd, jitteredUV, projection_matrix, view_matrix, discard_color);
	}

	vec3 finalColor = colorTotal / float(dof_samples);
	return finalColor;
#else
	return vec3(0.0);
#endif
}

#define SET_ALBEDO bool discard_color = false; \
	ALBEDO = calculate_albedo(ro, rd, SCREEN_UV, FRAGCOORD.xy, VIEWPORT_SIZE, PROJECTION_MATRIX, VIEW_MATRIX, discard_color); \
	if (discard_color) discard;

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