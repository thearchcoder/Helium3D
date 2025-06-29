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
uniform float progression_strength = 100.0;

#include "math.gdshaderinc"
#include "tonemapping.gdshaderinc"
//uniform bool famazingsurf_is_julia; // -@1
//uniform vec3 famazingsurf_julia_c; // -@1
//uniform vec3 famazingsurf_rotation; // -@1
//uniform vec3 famazingsurf_fold; // -@1
//uniform bool famazingsurf_fold_z; // -@1
//uniform float famazingsurf_min_radius; // -@1
//uniform vec3 famazingsurf_offset; // -@1
//uniform float famazingsurf_scale; // -@1
//uniform vec2 famazingsurf_fold2; // -@1
//uniform float fbairddelta_angle; // -@2
//uniform vec3 fbairddelta_rotation1; // -@2
//uniform vec3 fbairddelta_rotation2; // -@2
//uniform float fbairddelta_scale; // -@2
//uniform vec4 fbasictransform_offset; // -@3
//uniform vec4 fbasictransform_scale; // -@3
//uniform vec2 fbasictransform_range; // -@3
//uniform bool fbenesiship_is_julia; // -@4
//uniform vec3 fbenesiship_julia_c; // -@4
//uniform bool fbristorbrot_is_julia; // -@5
//uniform vec3 fbristorbrot_julia_c; // -@5
//uniform vec3 fbristorbrot_multiply; // -@5
//uniform vec3 fcube_position; // -@6
//uniform vec3 fcube_size; // -@6
//uniform float fcube_roundness; // -@6
//uniform bool fcube_hollow; // -@6
//uniform float fcube_hollow_edge; // -@6
//uniform vec3 fdodecahedron_position; // -@7
//uniform float fdodecahedron_size; // -@7
//uniform float fdodecahedron_roundness; // -@7
//uniform vec3 fgyroid_position; // -@8
//uniform float fgyroid_scale; // -@8
//uniform float fgyroid_sphere_radius; // -@8
//uniform float fgyroid_time; // -@8
//uniform float fgyroid_thickness; // -@8
//uniform float fgyroid_bias; // -@8
//uniform vec4 fgyroid_control; // -@8
//uniform vec2 fgyroid_offset; // -@8
//uniform bool fgyroid_oriented; // -@8
//uniform bool fgyroid_abs; // -@8
//uniform vec3 ficosahedron_position; // -@9
//uniform float ficosahedron_size; // -@9
//uniform vec4 finversiontransform_sphere; // -@10
//uniform vec2 finversiontransform_range; // -@10
//uniform vec2 fjerusalemcube_scale; // -@11
//uniform vec3 fjerusalemcube_offset; // -@11
//uniform vec3 fjerusalemcube_rotation1; // -@11
//uniform vec3 fjerusalemcube_rotation2; // -@11
//uniform vec3 fjerusalemcube_abs_add; // -@11
//uniform vec3 fjerusalemcube_abs_minus; // -@11
//uniform int fkalaidotransform_axis; // -@12
//uniform int fkalaidotransform_mode; // -@12
//uniform float fkalaidotransform_symmetry; // -@12
//uniform vec2 fkalaidotransform_range; // -@12
//uniform float fkalibox_scale; // -@13
//uniform vec3 fkalibox_offset1; // -@13
//uniform vec3 fkalibox_offset2; // -@13
//uniform vec3 fkaliliving_c; // -@14
//uniform vec3 fkaliliving_rotation1; // -@14
//uniform vec3 fkaliliving_rotation2; // -@14
//uniform float fkaliliving_scale; // -@14
//uniform vec4 fkaliredux_folds; // -@15
//uniform vec3 fkaliredux_minus; // -@15
//uniform float fkaliredux_scale; // -@15
//uniform bool fklenian_show_balls; // -@16
//uniform float fklenian_x; // -@16
//uniform float fklenian_y; // -@16
//uniform float fklenian_box_size_x; // -@16
//uniform float fklenian_box_size_z; // -@16
//uniform float fkochcube_scale; // -@17
//uniform int fkochcube_variant; // -@17
//uniform bool fkochcube_first_zrev; // -@17
//uniform bool fkochcube_pxyzminuss; // -@17
//uniform bool fkochcube_psortsymmetry1; // -@17
//uniform bool fkochcube_psortsymmetry2; // -@17
//uniform bool fkochcube_foldzbefore; // -@17
//uniform bool fkochcube_abs_x; // -@17
//uniform bool fkochcube_abs_y; // -@17
//uniform bool fkochcube_abs_z; // -@17
//uniform int fkochcube_fold1; // -@17
//uniform int fkochcube_fold2; // -@17
//uniform bool fkochcube_fold3; // -@17
//uniform bool fkochcube_fold4; // -@17
//uniform bool fkochcube_reflection; // -@17
//uniform vec3 fkochcube_rotation1; // -@17
//uniform vec3 fkochcube_rotation2; // -@17
//uniform bool fkochwire_fold1; // -@18
//uniform bool fkochwire_fold2; // -@18
//uniform bool fkochwire_fold3; // -@18
//uniform bool fkochwire_abs_x; // -@18
//uniform bool fkochwire_abs_y; // -@18
//uniform bool fkochwire_abs_z; // -@18
//uniform bool fkochwire_abs2_zx; // -@18
//uniform vec3 fkochwire_abs_plus; // -@18
//uniform vec3 fkochwire_abs_minus; // -@18
//uniform float fkochwire_scale; // -@18
//uniform float fkochwire_symmetry; // -@18
//uniform vec3 fkochwire_offset; // -@18
//uniform vec3 fkochwire_rotation1; // -@18
//uniform vec3 fkochwire_rotation2; // -@18
//uniform float flionbulb_power; // -@19
//uniform float flionbulb_phase; // -@19
//uniform vec3 flionbulb_c; // -@19
//uniform bool flionbulb_coral; // -@19
//uniform int flogtransform_axis; // -@20
//uniform float flogtransform_offset; // -@20
//uniform float flogtransform_scale; // -@20
//uniform vec2 flogtransform_range; // -@20
//uniform int fmandelbox_shape; // -@21
//uniform float fmandelbox_scale; // -@21
//uniform float fmandelbox_radius1; // -@21
//uniform float fmandelbox_fold1; // -@21
//uniform float fmandelbox_fold1_strength; // -@21
//uniform float fmandelbox_radius2; // -@21
//uniform vec3 fmandelbox_box_folds; // -@21
//uniform bool fmandelbox_is_julia; // -@21
//uniform vec3 fmandelbox_julia_c; // -@21
//uniform vec3 fmandelbox_rotation1; // -@21
//uniform vec3 fmandelbox_rotation2; // -@21
uniform float fmandelbulb_phase; // -@22
uniform float fmandelbulb_power; // -@22
uniform float fmandelbulb_z_mul; // -@22
uniform bool fmandelbulb_conjugate; // -@22
uniform bool fmandelbulb_abs_x; // -@22
uniform bool fmandelbulb_abs_y; // -@22
uniform bool fmandelbulb_abs_z; // -@22
uniform bool fmandelbulb_is_julia; // -@22
uniform vec4 fmandelbulb_julia_c; // -@22
uniform float fmandelbulb_derivative_bias; // -@22
uniform int fmandelbulb_number_system; // -@22
uniform int fmandelbulb_quaternion_mode; // -@22
//uniform vec3 fmengersponge_offset; // -@23
//uniform vec3 fmengersponge_rotation1; // -@23
//uniform vec3 fmengersponge_rotation2; // -@23
//uniform float fmengersponge_scale; // -@23
//uniform float fmixpinski4d_scale; // -@24
//uniform float fmixpinski4d_fold1_strength; // -@24
//uniform vec4 fmixpinski4d_offset; // -@24
//uniform vec4 fmixpinski4d_rotation1; // -@24
//uniform vec4 fmixpinski4d_rotation2; // -@24
//uniform float fmixpinski4d_abs_minus; // -@24
//uniform vec4 fmixpinski4d_fold1; // -@24
//uniform vec4 fmixpinski4d_pre_offset; // -@24
//uniform int fnewton_plane; // -@25
//uniform bool fnewton_intersection_mode; // -@25
//uniform vec3 foctahedron_position; // -@26
//uniform float foctahedron_size; // -@26
//uniform float foctahedron_roundness; // -@26
//uniform float foctkoch_scale; // -@27
//uniform vec3 foctkoch_offset; // -@27
//uniform vec3 foctkoch_fold; // -@27
//uniform bool foctkoch_abs; // -@27
//uniform vec3 foctkoch_rotation1; // -@27
//uniform vec3 foctkoch_rotation2; // -@27
//uniform vec3 fplane_position; // -@28
//uniform vec3 fplane_direction; // -@28
//uniform bool fplane_thin; // -@28
//uniform float fplane_thickness; // -@28
//uniform float fplatonickoch_stretch; // -@29
//uniform float fplatonickoch_postscale; // -@29
//uniform float fplatonickoch_zfix; // -@29
//uniform vec3 fplatonickoch_add; // -@29
//uniform vec4 fpseudoklenian_min; // -@30
//uniform vec4 fpseudoklenian_max; // -@30
//uniform float fpseudoklenian_sign; // -@30
//uniform float fpseudoklenian_scale; // -@30
//uniform vec2 fquadratickoch_octahedron_limit; // -@31
//uniform vec3 fquadratickoch_octahedron_offset; // -@31
//uniform vec3 fquadratickoch_octahedron_offset2; // -@31
//uniform vec3 fquadratickoch_octahedron_; // -@31
//uniform vec3 fquadratickoch_offset; // -@31
//uniform vec2 fquadratickoch_scale; // -@31
//uniform vec3 fquadratickoch_rotation1; // -@31
//uniform vec3 fquadratickoch_rotation2; // -@31
//uniform float fquadratickoch_abs_offset; // -@31
//uniform int freciprocaltransform_axis; // -@32
//uniform float freciprocaltransform_offset; // -@32
//uniform vec2 freciprocaltransform_range; // -@32
//uniform vec3 fsierpinskidodecahedron_offset; // -@33
//uniform vec3 fsierpinskidodecahedron_rotation1; // -@33
//uniform vec3 fsierpinskidodecahedron_rotation2; // -@33
//uniform float fsierpinskidodecahedron_scale; // -@33
//uniform vec3 fsierpinskiicosahedron_offset; // -@34
//uniform vec3 fsierpinskiicosahedron_rotation1; // -@34
//uniform vec3 fsierpinskiicosahedron_rotation2; // -@34
//uniform float fsierpinskiicosahedron_scale; // -@34
//uniform vec3 fsierpinskioctahedron_rotation1; // -@35
//uniform vec3 fsierpinskioctahedron_rotation2; // -@35
//uniform vec3 fsierpinskioctahedron_offset; // -@35
//uniform float fsierpinskioctahedron_scale; // -@35
//uniform vec3 fsierpinskitetrahedron_offset; // -@36
//uniform vec3 fsierpinskitetrahedron_rotation1; // -@36
//uniform vec3 fsierpinskitetrahedron_rotation2; // -@36
//uniform float fsierpinskitetrahedron_scale; // -@36
//uniform int fsintransform_axis; // -@37
//uniform vec2 fsintransform_offset; // -@37
//uniform vec2 fsintransform_scale; // -@37
//uniform vec2 fsintransform_range; // -@37
//uniform int fsphairahedron_cube_type; // -@38
//uniform float fsphairahedron_zc; // -@38
//uniform float fsphairahedron_zb; // -@38
//uniform vec3 fsphere_position; // -@39
//uniform float fsphere_radius; // -@39
//uniform bool fsphere_hollow; // -@39
//uniform float fsphere_hollow_edge; // -@39
//uniform float fspheretree_symmetry; // -@40
//uniform vec3 ftetrahedron_position; // -@41
//uniform float ftetrahedron_size; // -@41
//uniform float ftetrahedron_roundness; // -@41
//uniform bool fvicsek_preserve; // -@42
//uniform bool fvicsek_hex_fold1; // -@42
//uniform int fvicsek_hex_fold2; // -@42
//uniform bool fvicsek_abs1_x; // -@42
//uniform bool fvicsek_abs1_z; // -@42
//uniform vec3 fvicsek_limit; // -@42
//uniform vec3 fvicsek_abs2_minus; // -@42
//uniform vec3 fvicsek_abs2_plus; // -@42
//uniform vec3 fvicsek_offset; // -@42
//uniform vec2 fvicsek_foldt; // -@42
//uniform float fvicsek_scale; // -@42
//uniform vec3 fvicsek_rotation1; // -@42
//uniform vec3 fvicsek_rotation2; // -@42
//uniform vec2 fwobbletransform_rotation; // -@43
//uniform float fwobbletransform_strength; // -@43
//uniform vec4 fwobbletransform_step; // -@43
//uniform vec2 fwobbletransform_range; // -@43

//#include "res://formulas/amazingsurf.gdshaderinc" // -@1
//#include "res://formulas/bairddelta.gdshaderinc" // -@2
//#include "res://formulas/basictransform.gdshaderinc" // -@3
//#include "res://formulas/benesiship.gdshaderinc" // -@4
//#include "res://formulas/bristorbrot.gdshaderinc" // -@5
//#include "res://formulas/cube.gdshaderinc" // -@6
//#include "res://formulas/dodecahedron.gdshaderinc" // -@7
//#include "res://formulas/gyroid.gdshaderinc" // -@8
//#include "res://formulas/icosahedron.gdshaderinc" // -@9
//#include "res://formulas/inversiontransform.gdshaderinc" // -@10
//#include "res://formulas/jerusalemcube.gdshaderinc" // -@11
//#include "res://formulas/kalaidotransform.gdshaderinc" // -@12
//#include "res://formulas/kalibox.gdshaderinc" // -@13
//#include "res://formulas/kaliliving.gdshaderinc" // -@14
//#include "res://formulas/kaliredux.gdshaderinc" // -@15
//#include "res://formulas/klenian.gdshaderinc" // -@16
//#include "res://formulas/kochcube.gdshaderinc" // -@17
//#include "res://formulas/kochwire.gdshaderinc" // -@18
//#include "res://formulas/lionbulb.gdshaderinc" // -@19
//#include "res://formulas/logtransform.gdshaderinc" // -@20
//#include "res://formulas/mandelbox.gdshaderinc" // -@21
#include "res://formulas/mandelbulb.gdshaderinc" // -@22
//#include "res://formulas/mengersponge.gdshaderinc" // -@23
//#include "res://formulas/mixpinski4d.gdshaderinc" // -@24
//#include "res://formulas/newton.gdshaderinc" // -@25
//#include "res://formulas/octahedron.gdshaderinc" // -@26
//#include "res://formulas/octkoch.gdshaderinc" // -@27
//#include "res://formulas/plane.gdshaderinc" // -@28
//#include "res://formulas/platonickoch.gdshaderinc" // -@29
//#include "res://formulas/pseudoklenian.gdshaderinc" // -@30
//#include "res://formulas/quadratickoch.gdshaderinc" // -@31
//#include "res://formulas/reciprocaltransform.gdshaderinc" // -@32
//#include "res://formulas/sierpinskidodecahedron.gdshaderinc" // -@33
//#include "res://formulas/sierpinskiicosahedron.gdshaderinc" // -@34
//#include "res://formulas/sierpinskioctahedron.gdshaderinc" // -@35
//#include "res://formulas/sierpinskitetrahedron.gdshaderinc" // -@36
//#include "res://formulas/sintransform.gdshaderinc" // -@37
//#include "res://formulas/sphairahedron.gdshaderinc" // -@38
//#include "res://formulas/sphere.gdshaderinc" // -@39
//#include "res://formulas/spheretree.gdshaderinc" // -@40
//#include "res://formulas/tetrahedron.gdshaderinc" // -@41
//#include "res://formulas/vicsek.gdshaderinc" // -@42
//#include "res://formulas/wobbletransform.gdshaderinc" // -@43

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
//if (current_formula == 1) amazingsurf_iter(z, dz, original_z, orbit, i); //-@1
//if (current_formula == 2) bairddelta_iter(z, dz, original_z, orbit, i); //-@2
//if (current_formula == 3) basictransform_iter(z, dz, original_z, orbit, i); //-@3
//if (current_formula == 4) benesiship_iter(z, dz, original_z, orbit, i); //-@4
//if (current_formula == 5) bristorbrot_iter(z, dz, original_z, orbit, i); //-@5
//if (current_formula == 10) inversiontransform_iter(z, dz, original_z, orbit, i); //-@10
//if (current_formula == 11) jerusalemcube_iter(z, dz, original_z, orbit, i); //-@11
//if (current_formula == 12) kalaidotransform_iter(z, dz, original_z, orbit, i); //-@12
//if (current_formula == 13) kalibox_iter(z, dz, original_z, orbit, i); //-@13
//if (current_formula == 14) kaliliving_iter(z, dz, original_z, orbit, i); //-@14
//if (current_formula == 15) kaliredux_iter(z, dz, original_z, orbit, i); //-@15
//if (current_formula == 17) kochcube_iter(z, dz, original_z, orbit, i, s); //-@17
//if (current_formula == 18) kochwire_iter(z, dz, original_z, orbit, i); //-@18
//if (current_formula == 19) lionbulb_iter(z, dz, original_z, orbit, i); //-@19
//if (current_formula == 20) logtransform_iter(z, dz, original_z, orbit, i); //-@20
//if (current_formula == 21) mandelbox_iter(z, dz, original_z, orbit, i); //-@21
if (current_formula == 22) mandelbulb_iter(z, dz, original_z, orbit, i); //-@22
//if (current_formula == 23) mengersponge_iter(z, dz, original_z, orbit, i); //-@23
//if (current_formula == 24) mixpinski4d_iter(z, dz, original_z, orbit, i); //-@24
//if (current_formula == 27) octkoch_iter(z, dz, original_z, orbit, i); //-@27
//if (current_formula == 29) platonickoch_iter(z, dz, original_z, orbit, i); //-@29
//if (current_formula == 30) pseudoklenian_iter(z, dz, original_z, orbit, i); //-@30
//if (current_formula == 31) quadratickoch_iter(z, dz, original_z, orbit, i); //-@31
//if (current_formula == 32) reciprocaltransform_iter(z, dz, original_z, orbit, i); //-@32
//if (current_formula == 33) sierpinskidodecahedron_iter(z, dz, original_z, orbit, i); //-@33
//if (current_formula == 34) sierpinskiicosahedron_iter(z, dz, original_z, orbit, i); //-@34
//if (current_formula == 35) sierpinskioctahedron_iter(z, dz, original_z, orbit, i); //-@35
//if (current_formula == 36) sierpinskitetrahedron_iter(z, dz, original_z, orbit, i); //-@36
//if (current_formula == 37) sintransform_iter(z, dz, original_z, orbit, i); //-@37
//if (current_formula == 42) vicsek_iter(z, dz, original_z, orbit, i); //-@42
//if (current_formula == 43) wobbletransform_iter(z, dz, original_z, orbit, i); //-@43
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

			if (single_formula && (formulas[0] == 17 || formulas[0] == 23 || formulas[0] == 27 || formulas[0] == 29 || formulas[0] == 31)) de = r / dz;
			else de = 0.5 * log(r) * r / dz;
		
	}

if (single_formula) {
//de = cube_sdf(original_z).x; // -@6
//de = dodecahedron_sdf(original_z).x; // -@7
//de = gyroid_sdf(original_z).x; // -@8
//de = icosahedron_sdf(original_z).x; // -@9
//de = klenian_sdf(original_z).x; // -@16
//de = newton_sdf(original_z).x; // -@25
//de = octahedron_sdf(original_z).x; // -@26
//de = plane_sdf(original_z).x; // -@28
//de = sphairahedron_sdf(original_z).x; // -@38
//de = sphere_sdf(original_z).x; // -@39
//de = spheretree_sdf(original_z).x; // -@40
//de = tetrahedron_sdf(original_z).x; // -@41

} else {
//de = min(de, cube_sdf(original_z).x); // -@6
//de = min(de, dodecahedron_sdf(original_z).x); // -@7
//de = min(de, gyroid_sdf(original_z).x); // -@8
//de = min(de, icosahedron_sdf(original_z).x); // -@9
//de = max(de, klenian_sdf(original_z).x); // -@16
//de = max(de, newton_sdf(original_z).x); // -@25
//de = min(de, octahedron_sdf(original_z).x); // -@26
//de = min(de, plane_sdf(original_z).x); // -@28
//de = max(de, sphairahedron_sdf(original_z).x); // -@38
//de = min(de, sphere_sdf(original_z).x); // -@39
//de = max(de, spheretree_sdf(original_z).x); // -@40
//de = min(de, tetrahedron_sdf(original_z).x); // -@41

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

	return vec4(final_color, dfo < max_distance ? 1.0 : 0.0);
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
	if (camera_type != 1) {
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

	if (!dof_enabled || display != 0) return render_ray(ray_origin, ray_dir, screen_uv, projection_matrix, view_matrix, discard_color, resolution);

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