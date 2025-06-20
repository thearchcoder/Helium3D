shader_type spatial;
//render_mode unshaded;

// Disabled when possible to reduce shader compilation times.
// Line numbers for these 3 lines must stay the same.
//////////////////////////#define USING_DOF
//////////////////////////#define USING_TILING
//////////////////////////#define USING_REFLECTIONS

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
uniform float progression_strength = 100.0;

#include "math.gdshaderinc"
#include "tonemapping.gdshaderinc"
uniform float fmandelbulb_phase;
uniform float fmandelbulb_power;
uniform float fmandelbulb_z_mul;
uniform bool fmandelbulb_conjugate;
uniform bool fmandelbulb_abs_x;
uniform bool fmandelbulb_abs_y;
uniform bool fmandelbulb_abs_z;
uniform bool fmandelbulb_is_julia;
uniform vec4 fmandelbulb_julia_c;
uniform float fmandelbulb_derivative_bias;
uniform int fmandelbulb_number_system;
uniform int fmandelbulb_quaternion_mode;
uniform float fmandelbox_scale;
uniform float fmandelbox_radius1;
uniform float fmandelbox_fold1;
uniform float fmandelbox_fold1_strength;
uniform float fmandelbox_radius2;
uniform vec3 fmandelbox_box_folds;
uniform bool fmandelbox_is_julia;
uniform vec3 fmandelbox_julia_c;
uniform vec3 fmandelbox_rotation1;
uniform vec3 fmandelbox_rotation2;
uniform bool famazingsurf_is_julia;
uniform vec3 famazingsurf_julia_c;
uniform vec3 famazingsurf_rotation;
uniform vec3 famazingsurf_fold;
uniform bool famazingsurf_fold_z;
uniform float famazingsurf_min_radius;
uniform vec3 famazingsurf_offset;
uniform float famazingsurf_scale;
uniform vec2 famazingsurf_fold2;
uniform float fbairddelta_angle;
uniform vec3 fbairddelta_rotation1;
uniform vec3 fbairddelta_rotation2;
uniform float fbairddelta_scale;
uniform vec3 fsierpinskiicosahedron_offset;
uniform vec3 fsierpinskiicosahedron_rotation1;
uniform vec3 fsierpinskiicosahedron_rotation2;
uniform float fsierpinskiicosahedron_scale;
uniform vec3 fsierpinskitetrahedron_offset;
uniform vec3 fsierpinskitetrahedron_rotation1;
uniform vec3 fsierpinskitetrahedron_rotation2;
uniform float fsierpinskitetrahedron_scale;
uniform vec3 fmengersponge_offset;
uniform vec3 fmengersponge_rotation1;
uniform vec3 fmengersponge_rotation2;
uniform float fmengersponge_scale;
uniform vec3 fsierpinskioctahedron_rotation1;
uniform vec3 fsierpinskioctahedron_rotation2;
uniform vec3 fsierpinskioctahedron_offset;
uniform float fsierpinskioctahedron_scale;
uniform vec3 fsierpinskidodecahedron_offset;
uniform vec3 fsierpinskidodecahedron_rotation1;
uniform vec3 fsierpinskidodecahedron_rotation2;
uniform float fsierpinskidodecahedron_scale;
uniform vec4 fpseudoklenian_min;
uniform vec4 fpseudoklenian_max;
uniform float fpseudoklenian_sign;
uniform float fpseudoklenian_scale;
uniform bool fklenian_show_balls;
uniform float fklenian_x;
uniform float fklenian_y;
uniform float fklenian_box_size_x;
uniform float fklenian_box_size_z;
uniform float fspheretree_symmetry;
uniform vec4 fkaliredux_folds;
uniform vec3 fkaliredux_minus;
uniform float fkaliredux_scale;
uniform float fkochcube_scale;
uniform int fkochcube_variant;
uniform bool fkochcube_first_zrev;
uniform bool fkochcube_pxyzminuss;
uniform bool fkochcube_psortsymmetry1;
uniform bool fkochcube_psortsymmetry2;
uniform bool fkochcube_foldzbefore;
uniform bool fkochcube_abs_x;
uniform bool fkochcube_abs_y;
uniform bool fkochcube_abs_z;
uniform int fkochcube_fold1;
uniform int fkochcube_fold2;
uniform bool fkochcube_fold3;
uniform bool fkochcube_fold4;
uniform bool fkochcube_reflection;
uniform vec3 fkochcube_rotation1;
uniform vec3 fkochcube_rotation2;
uniform int fnewton_plane;
uniform bool fnewton_intersection_mode;
uniform int fnewton_power;
uniform vec2 fquadratickoch_octahedron_limit;
uniform vec3 fquadratickoch_octahedron_offset;
uniform vec3 fquadratickoch_octahedron_offset2;
uniform vec3 fquadratickoch_octahedron_;
uniform vec3 fquadratickoch_offset;
uniform vec2 fquadratickoch_scale;
uniform vec3 fquadratickoch_rotation1;
uniform vec3 fquadratickoch_rotation2;
uniform float fquadratickoch_abs_offset;
uniform vec3 fkaliliving_c;
uniform vec3 fkaliliving_rotation1;
uniform vec3 fkaliliving_rotation2;
uniform float fkaliliving_scale;
uniform float fmixpinski4d_scale;
uniform float fmixpinski4d_fold1_strength;
uniform vec4 fmixpinski4d_offset;
uniform vec4 fmixpinski4d_rotation1;
uniform vec4 fmixpinski4d_rotation2;
uniform float fmixpinski4d_abs_minus;
uniform vec4 fmixpinski4d_fold1;
uniform vec4 fmixpinski4d_pre_offset;
uniform bool fvicsek_preserve;
uniform bool fvicsek_hex_fold1;
uniform int fvicsek_hex_fold2;
uniform bool fvicsek_abs1_x;
uniform bool fvicsek_abs1_z;
uniform vec3 fvicsek_limit;
uniform vec3 fvicsek_abs2_minus;
uniform vec3 fvicsek_abs2_plus;
uniform vec3 fvicsek_offset;
uniform vec2 fvicsek_foldt;
uniform float fvicsek_scale;
uniform vec3 fvicsek_rotation1;
uniform vec3 fvicsek_rotation2;
uniform bool fkochwire_fold1;
uniform bool fkochwire_fold2;
uniform bool fkochwire_fold3;
uniform bool fkochwire_abs_x;
uniform bool fkochwire_abs_y;
uniform bool fkochwire_abs_z;
uniform bool fkochwire_abs2_zx;
uniform vec3 fkochwire_abs_plus;
uniform vec3 fkochwire_abs_minus;
uniform float fkochwire_scale;
uniform float fkochwire_symmetry;
uniform vec3 fkochwire_offset;
uniform vec3 fkochwire_rotation1;
uniform vec3 fkochwire_rotation2;
uniform float fkalibox_scale;
uniform vec3 fkalibox_offset1;
uniform vec3 fkalibox_offset2;
uniform int fsphairahedron_cube_type;
uniform float fsphairahedron_zc;
uniform float fsphairahedron_zb;
uniform float flionbulb_power;
uniform float flionbulb_phase;
uniform vec3 flionbulb_c;
uniform bool flionbulb_coral;
uniform vec2 fjerusalemcube_scale;
uniform vec3 fjerusalemcube_offset;
uniform vec3 fjerusalemcube_rotation1;
uniform vec3 fjerusalemcube_rotation2;
uniform vec3 fjerusalemcube_abs_add;
uniform vec3 fjerusalemcube_abs_minus;
uniform bool fbristorbrot_is_julia;
uniform vec3 fbristorbrot_julia_c;
uniform vec3 fbristorbrot_multiply;
uniform int fsintransform_axis;
uniform vec2 fsintransform_offset;
uniform vec2 fsintransform_scale;
uniform vec2 fsintransform_range;
uniform int flogtransform_axis;
uniform float flogtransform_offset;
uniform float flogtransform_scale;
uniform vec2 flogtransform_range;
uniform vec4 fbasictransform_offset;
uniform vec4 fbasictransform_scale;
uniform vec2 fbasictransform_range;
uniform vec4 finversiontransform_sphere;
uniform vec2 finversiontransform_range;
uniform int freciprocaltransform_axis;
uniform float freciprocaltransform_offset;
uniform vec2 freciprocaltransform_range;
uniform int fkalaidotransform_axis;
uniform int fkalaidotransform_mode;
uniform float fkalaidotransform_symmetry;
uniform vec2 fkalaidotransform_range;
uniform float foctkoch_scale;
uniform vec3 foctkoch_offset;
uniform vec3 foctkoch_fold;
uniform bool foctkoch_abs;
uniform vec3 foctkoch_rotation1;
uniform vec3 foctkoch_rotation2;
uniform float fplatonickoch_stretch;
uniform float fplatonickoch_postscale;
uniform float fplatonickoch_zfix;
uniform vec3 fplatonickoch_add;
uniform bool fbenesiship_is_julia;
uniform vec3 fbenesiship_julia_c;

#include "res://formulas/mandelbulb.gdshaderinc"
#include "res://formulas/mandelbox.gdshaderinc"
#include "res://formulas/amazingsurf.gdshaderinc"
#include "res://formulas/bairddelta.gdshaderinc"
#include "res://formulas/sierpinskiicosahedron.gdshaderinc"
#include "res://formulas/sierpinskitetrahedron.gdshaderinc"
#include "res://formulas/mengersponge.gdshaderinc"
#include "res://formulas/sierpinskioctahedron.gdshaderinc"
#include "res://formulas/sierpinskidodecahedron.gdshaderinc"
#include "res://formulas/pseudoklenian.gdshaderinc"
#include "res://formulas/klenian.gdshaderinc"
#include "res://formulas/spheretree.gdshaderinc"
#include "res://formulas/kaliredux.gdshaderinc"
#include "res://formulas/kochcube.gdshaderinc"
#include "res://formulas/newton.gdshaderinc"
#include "res://formulas/quadratickoch.gdshaderinc"
#include "res://formulas/kaliliving.gdshaderinc"
#include "res://formulas/mixpinski4d.gdshaderinc"
#include "res://formulas/vicsek.gdshaderinc"
#include "res://formulas/kochwire.gdshaderinc"
#include "res://formulas/kalibox.gdshaderinc"
#include "res://formulas/sphairahedron.gdshaderinc"
#include "res://formulas/lionbulb.gdshaderinc"
#include "res://formulas/jerusalemcube.gdshaderinc"
#include "res://formulas/bristorbrot.gdshaderinc"
#include "res://formulas/sintransform.gdshaderinc"
#include "res://formulas/logtransform.gdshaderinc"
#include "res://formulas/basictransform.gdshaderinc"
#include "res://formulas/inversiontransform.gdshaderinc"
#include "res://formulas/reciprocaltransform.gdshaderinc"
#include "res://formulas/kalaidotransform.gdshaderinc"
#include "res://formulas/octkoch.gdshaderinc"
#include "res://formulas/platonickoch.gdshaderinc"
#include "res://formulas/benesiship.gdshaderinc"

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

	// Edited at runtime.
	vec4 z = vec4(p, 0.000001);
	vec4 original_z = z;
	float orbit = 100000.0;
	float dz = 1.0;
	float s = 1.2;

	bool using_klenian = false;
	bool using_sphairahedron = false;
	bool using_spheretree = false;
	bool using_newton = false;
	bool single_formula = false;

	vec3 previous_z = z.xyz;

	// Edited at runtime
	for (int i = 0; i < iterations * int(number_of_active_formulas); i++) {
		bool escaped = false;
		int current_formula = formulas[int(mod(float(i), number_of_active_formulas))];
//if (current_formula == 1) mandelbulb_iter(z, dz, original_z, orbit, i); //-@1
//if (current_formula == 2) mandelbox_iter(z, dz, original_z, orbit, i); //-@2
//if (current_formula == 3) amazingsurf_iter(z, dz, original_z, orbit, i); //-@3
//if (current_formula == 4) bairddelta_iter(z, dz, original_z, orbit, i); //-@4
//if (current_formula == 5) sierpinskiicosahedron_iter(z, dz, original_z, orbit, i); //-@5
//if (current_formula == 6) sierpinskitetrahedron_iter(z, dz, original_z, orbit, i); //-@6
//if (current_formula == 7) mengersponge_iter(z, dz, original_z, orbit, i); //-@7
//if (current_formula == 8) sierpinskioctahedron_iter(z, dz, original_z, orbit, i); //-@8
//if (current_formula == 9) sierpinskidodecahedron_iter(z, dz, original_z, orbit, i); //-@9
//if (current_formula == 10) pseudoklenian_iter(z, dz, original_z, orbit, i); //-@10
//if (current_formula == 11) using_klenian = true; //-@11
//if (current_formula == 12) using_spheretree = true; //-@12
//if (current_formula == 13) kaliredux_iter(z, dz, original_z, orbit, i); //-@13
//if (current_formula == 14) kochcube_iter(z, dz, original_z, orbit, i, s); //-@14
//if (current_formula == 15) using_newton = true; //-@15
//if (current_formula == 16) quadratickoch_iter(z, dz, original_z, orbit, i); //-@16
//if (current_formula == 17) kaliliving_iter(z, dz, original_z, orbit, i); //-@17
//if (current_formula == 18) mixpinski4d_iter(z, dz, original_z, orbit, i); //-@18
//if (current_formula == 19) vicsek_iter(z, dz, original_z, orbit, i); //-@19
//if (current_formula == 20) kochwire_iter(z, dz, original_z, orbit, i); //-@20
//if (current_formula == 21) kalibox_iter(z, dz, original_z, orbit, i); //-@21
//if (current_formula == 22) using_sphairahedron = true; //-@22
//if (current_formula == 23) lionbulb_iter(z, dz, original_z, orbit, i); //-@23
//if (current_formula == 24) jerusalemcube_iter(z, dz, original_z, orbit, i); //-@24
//if (current_formula == 25) bristorbrot_iter(z, dz, original_z, orbit, i); //-@25
//if (current_formula == 26) sintransform_iter(z, dz, original_z, orbit, i); //-@26
//if (current_formula == 27) logtransform_iter(z, dz, original_z, orbit, i); //-@27
//if (current_formula == 28) basictransform_iter(z, dz, original_z, orbit, i); //-@28
//if (current_formula == 29) inversiontransform_iter(z, dz, original_z, orbit, i); //-@29
//if (current_formula == 30) reciprocaltransform_iter(z, dz, original_z, orbit, i); //-@30
//if (current_formula == 31) kalaidotransform_iter(z, dz, original_z, orbit, i); //-@31
if (current_formula == 32) octkoch_iter(z, dz, original_z, orbit, i); //-@32
//if (current_formula == 33) platonickoch_iter(z, dz, original_z, orbit, i); //-@33
//if (current_formula == 34) benesiship_iter(z, dz, original_z, orbit, i); //-@34
		orbit = min(orbit, process_orbit_trap4d(z, original_z, i));

		if (dot(z, z) > escape_radius * escape_radius || escaped) break;
	}

	float r = length(z);
	float de = 0.0;

	if (formulas[1] <= 0) single_formula = true;

	if (de_mode == 0) de = r / dz;
	else if (de_mode == 1) de = 0.5 * log(r) * r / dz;
	else if (de_mode == 2) {
		if (single_formula && formulas[0] == 14) de = r / dz;
		else de = 0.5 * log(r) * r / dz;
	}

if (single_formula) {
//if (using_sphairahedron) de = sphairahedron_sdf(original_z).x; //-@22
//if (using_spheretree) de = spheretree_sdf(original_z).x; //-@12
//if (using_klenian) de = klenian_sdf(original_z).x; //-@11
//if (using_newton) de = newton_sdf(original_z).x; //-@15
} else {
//if (using_sphairahedron) de = max(de, sphairahedron_sdf(original_z).x); //-@22
//if (using_spheretree) de = max(de, spheretree_sdf(original_z).x); //-@12
//if (using_klenian) de = max(de, klenian_sdf(original_z).x); //-@11
//if (using_newton) de = max(de, newton_sdf(original_z).x); //-@15
}

	if (interior_mode) de = abs(de);
	if (cut) de = max(de, dot(original_p + cut_position, normalize(cut_normal)));
	if (sphere_inversion) de = de * d2 / (inversion_sphere.w + d * de);

	return vec2(de, orbit).yx;
}

#include "lighting/ambient_occlusion.gdshaderinc"

vec3 ray_marcher(vec3 ro, vec3 rd) {
	float dfo = 0.0;
	float orbit_trap_distance;
	float total_marches = 0.0;

	for (int i = 0; i < max_steps; i++) {
		vec2 data = scene_sdf(ro + rd * dfo);
		float calc_epsilon = relative_epsilon ? epsilon / 3.4 * dfo : epsilon;
		float point_distance = data.y;
		dfo += max(point_distance * raystep_multiplier, calc_epsilon);
		total_marches += 1.0;

		if (point_distance < calc_epsilon || dfo > max_distance) {
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

vec4 render_single_ray(vec3 ray_origin, vec3 ray_dir, vec2 screen_uv, mat4 projection_matrix, mat4 view_matrix, inout bool discard_color) {
	vec3 data = ray_marcher(ray_origin, ray_dir);
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
	vec3 final_color;
	vec3 p = ray_origin + ray_dir * dfo;
	vec3 normal = calculate_normal(p, relative_epsilon ? epsilon / 3.4 * dfo : epsilon);

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
		final_color = palette_color * compute_direct_lighting(p, ray_dir, ray_origin, normal);

		if (display == 1) final_color = vec3(calcAO(p, normal));
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

	if (!dof_enabled || display != 0) return render_ray(ray_origin, ray_dir, screen_uv, projection_matrix, view_matrix, discard_color);

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
	EMISSION = calculate_albedo(ro, rd, SCREEN_UV, FRAGCOORD.xy, VIEWPORT_SIZE, PROJECTION_MATRIX, VIEW_MATRIX, discard_color); \
	if (discard_color) discard;

void fragment() {
	if (hash(FRAGCOORD.xy + TIME) > progression_strength / 100.0) discard;

	float error_margin = 2.0;
	vec3 ro = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz;
	vec3 rd = normalize(vertex_ls - ro);

	#ifdef USING_TILING
	if (tiled) {
		// Use integer operations for more precise tile calculations
		int tile_idx = int(current_tile);
		int t_x = int(tiles_x);
		int t_y = int(tiles_y);

		// Calculate tile position using integer math
		int tile_x_pos = tile_idx % t_x;
		int tile_y_pos = tile_idx / t_x;

		// Convert to float for UV calculations
		vec2 tile_size = 1.0 / vec2(float(t_x), float(t_y));
		vec2 padding = error_margin / VIEWPORT_SIZE;

		vec2 tile_start = vec2(float(tile_x_pos), float(tile_y_pos)) * tile_size;
		vec2 tile_end = tile_start + tile_size;

		// Add padding to prevent edge artifacts
		vec2 tile_min = max(tile_start - padding, vec2(0.0));
		vec2 tile_max = min(tile_end + padding, vec2(1.0));

		// Check if current fragment is within this tile's bounds
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