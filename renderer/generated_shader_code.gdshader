shader_type spatial;
render_mode unshaded;

// Disabled when possible to reduce shader compilation times.
// Line numbers for these 3 lines must stay the same.
//#define USING_DOF
//#define USING_TILING
//#define USING_REFLECTIONS

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
uniform vec3 fcube_position; // -@6
uniform vec3 fcube_size; // -@6
uniform float fcube_roundness; // -@6
uniform bool fcube_hollow; // -@6
uniform float fcube_hollow_edge; // -@6
//uniform vec3 fdodecahedron_position; // -@7
//uniform float fdodecahedron_size; // -@7
//uniform float fdodecahedron_roundness; // -@7
//uniform bool fdodecahedron_hollow; // -@7
//uniform float fdodecahedron_hollow_edge; // -@7
//uniform vec3 ficosahedron_position; // -@8
//uniform float ficosahedron_size; // -@8
//uniform float ficosahedron_roundness; // -@8
//uniform bool ficosahedron_hollow; // -@8
//uniform float ficosahedron_hollow_edge; // -@8
//uniform vec4 finversiontransform_sphere; // -@9
//uniform vec2 finversiontransform_range; // -@9
//uniform vec2 fjerusalemcube_scale; // -@10
//uniform vec3 fjerusalemcube_offset; // -@10
//uniform vec3 fjerusalemcube_rotation1; // -@10
//uniform vec3 fjerusalemcube_rotation2; // -@10
//uniform vec3 fjerusalemcube_abs_add; // -@10
//uniform vec3 fjerusalemcube_abs_minus; // -@10
//uniform int fkalaidotransform_axis; // -@11
//uniform int fkalaidotransform_mode; // -@11
//uniform float fkalaidotransform_symmetry; // -@11
//uniform vec2 fkalaidotransform_range; // -@11
//uniform float fkalibox_scale; // -@12
//uniform vec3 fkalibox_offset1; // -@12
//uniform vec3 fkalibox_offset2; // -@12
//uniform vec3 fkaliliving_c; // -@13
//uniform vec3 fkaliliving_rotation1; // -@13
//uniform vec3 fkaliliving_rotation2; // -@13
//uniform float fkaliliving_scale; // -@13
//uniform vec4 fkaliredux_folds; // -@14
//uniform vec3 fkaliredux_minus; // -@14
//uniform float fkaliredux_scale; // -@14
//uniform bool fklenian_show_balls; // -@15
//uniform float fklenian_x; // -@15
//uniform float fklenian_y; // -@15
//uniform float fklenian_box_size_x; // -@15
//uniform float fklenian_box_size_z; // -@15
//uniform float fkochcube_scale; // -@16
//uniform int fkochcube_variant; // -@16
//uniform bool fkochcube_first_zrev; // -@16
//uniform bool fkochcube_pxyzminuss; // -@16
//uniform bool fkochcube_psortsymmetry1; // -@16
//uniform bool fkochcube_psortsymmetry2; // -@16
//uniform bool fkochcube_foldzbefore; // -@16
//uniform bool fkochcube_abs_x; // -@16
//uniform bool fkochcube_abs_y; // -@16
//uniform bool fkochcube_abs_z; // -@16
//uniform int fkochcube_fold1; // -@16
//uniform int fkochcube_fold2; // -@16
//uniform bool fkochcube_fold3; // -@16
//uniform bool fkochcube_fold4; // -@16
//uniform bool fkochcube_reflection; // -@16
//uniform vec3 fkochcube_rotation1; // -@16
//uniform vec3 fkochcube_rotation2; // -@16
//uniform bool fkochwire_fold1; // -@17
//uniform bool fkochwire_fold2; // -@17
//uniform bool fkochwire_fold3; // -@17
//uniform bool fkochwire_abs_x; // -@17
//uniform bool fkochwire_abs_y; // -@17
//uniform bool fkochwire_abs_z; // -@17
//uniform bool fkochwire_abs2_zx; // -@17
//uniform vec3 fkochwire_abs_plus; // -@17
//uniform vec3 fkochwire_abs_minus; // -@17
//uniform float fkochwire_scale; // -@17
//uniform float fkochwire_symmetry; // -@17
//uniform vec3 fkochwire_offset; // -@17
//uniform vec3 fkochwire_rotation1; // -@17
//uniform vec3 fkochwire_rotation2; // -@17
//uniform float flionbulb_power; // -@18
//uniform float flionbulb_phase; // -@18
//uniform vec3 flionbulb_c; // -@18
//uniform bool flionbulb_coral; // -@18
//uniform int flogtransform_axis; // -@19
//uniform float flogtransform_offset; // -@19
//uniform float flogtransform_scale; // -@19
//uniform vec2 flogtransform_range; // -@19
//uniform float fmandelbox_scale; // -@20
//uniform float fmandelbox_radius1; // -@20
//uniform float fmandelbox_fold1; // -@20
//uniform float fmandelbox_fold1_strength; // -@20
//uniform float fmandelbox_radius2; // -@20
//uniform vec3 fmandelbox_box_folds; // -@20
//uniform bool fmandelbox_is_julia; // -@20
//uniform vec3 fmandelbox_julia_c; // -@20
//uniform vec3 fmandelbox_rotation1; // -@20
//uniform vec3 fmandelbox_rotation2; // -@20
//uniform float fmandelbulb_phase; // -@21
//uniform float fmandelbulb_power; // -@21
//uniform float fmandelbulb_z_mul; // -@21
//uniform bool fmandelbulb_conjugate; // -@21
//uniform bool fmandelbulb_abs_x; // -@21
//uniform bool fmandelbulb_abs_y; // -@21
//uniform bool fmandelbulb_abs_z; // -@21
//uniform bool fmandelbulb_is_julia; // -@21
//uniform vec4 fmandelbulb_julia_c; // -@21
//uniform float fmandelbulb_derivative_bias; // -@21
//uniform int fmandelbulb_number_system; // -@21
//uniform int fmandelbulb_quaternion_mode; // -@21
uniform vec3 fmengersponge_offset; // -@22
uniform vec3 fmengersponge_rotation1; // -@22
uniform vec3 fmengersponge_rotation2; // -@22
uniform float fmengersponge_scale; // -@22
//uniform float fmixpinski4d_scale; // -@23
//uniform float fmixpinski4d_fold1_strength; // -@23
//uniform vec4 fmixpinski4d_offset; // -@23
//uniform vec4 fmixpinski4d_rotation1; // -@23
//uniform vec4 fmixpinski4d_rotation2; // -@23
//uniform float fmixpinski4d_abs_minus; // -@23
//uniform vec4 fmixpinski4d_fold1; // -@23
//uniform vec4 fmixpinski4d_pre_offset; // -@23
//uniform int fnewton_plane; // -@24
//uniform bool fnewton_intersection_mode; // -@24
//uniform vec3 foctahedron_position; // -@25
//uniform float foctahedron_size; // -@25
//uniform float foctahedron_roundness; // -@25
//uniform bool foctahedron_hollow; // -@25
//uniform float foctahedron_hollow_edge; // -@25
//uniform float foctkoch_scale; // -@26
//uniform vec3 foctkoch_offset; // -@26
//uniform vec3 foctkoch_fold; // -@26
//uniform bool foctkoch_abs; // -@26
//uniform vec3 foctkoch_rotation1; // -@26
//uniform vec3 foctkoch_rotation2; // -@26
//uniform float fplatonickoch_stretch; // -@27
//uniform float fplatonickoch_postscale; // -@27
//uniform float fplatonickoch_zfix; // -@27
//uniform vec3 fplatonickoch_add; // -@27
//uniform vec4 fpseudoklenian_min; // -@28
//uniform vec4 fpseudoklenian_max; // -@28
//uniform float fpseudoklenian_sign; // -@28
//uniform float fpseudoklenian_scale; // -@28
//uniform vec2 fquadratickoch_octahedron_limit; // -@29
//uniform vec3 fquadratickoch_octahedron_offset; // -@29
//uniform vec3 fquadratickoch_octahedron_offset2; // -@29
//uniform vec3 fquadratickoch_octahedron_; // -@29
//uniform vec3 fquadratickoch_offset; // -@29
//uniform vec2 fquadratickoch_scale; // -@29
//uniform vec3 fquadratickoch_rotation1; // -@29
//uniform vec3 fquadratickoch_rotation2; // -@29
//uniform float fquadratickoch_abs_offset; // -@29
//uniform int freciprocaltransform_axis; // -@30
//uniform float freciprocaltransform_offset; // -@30
//uniform vec2 freciprocaltransform_range; // -@30
//uniform vec3 fsierpinskidodecahedron_offset; // -@31
//uniform vec3 fsierpinskidodecahedron_rotation1; // -@31
//uniform vec3 fsierpinskidodecahedron_rotation2; // -@31
//uniform float fsierpinskidodecahedron_scale; // -@31
//uniform vec3 fsierpinskiicosahedron_offset; // -@32
//uniform vec3 fsierpinskiicosahedron_rotation1; // -@32
//uniform vec3 fsierpinskiicosahedron_rotation2; // -@32
//uniform float fsierpinskiicosahedron_scale; // -@32
//uniform vec3 fsierpinskioctahedron_rotation1; // -@33
//uniform vec3 fsierpinskioctahedron_rotation2; // -@33
//uniform vec3 fsierpinskioctahedron_offset; // -@33
//uniform float fsierpinskioctahedron_scale; // -@33
//uniform vec3 fsierpinskitetrahedron_offset; // -@34
//uniform vec3 fsierpinskitetrahedron_rotation1; // -@34
//uniform vec3 fsierpinskitetrahedron_rotation2; // -@34
//uniform float fsierpinskitetrahedron_scale; // -@34
//uniform int fsintransform_axis; // -@35
//uniform vec2 fsintransform_offset; // -@35
//uniform vec2 fsintransform_scale; // -@35
//uniform vec2 fsintransform_range; // -@35
//uniform int fsphairahedron_cube_type; // -@36
//uniform float fsphairahedron_zc; // -@36
//uniform float fsphairahedron_zb; // -@36
//uniform vec3 fsphere_position; // -@37
//uniform float fsphere_radius; // -@37
//uniform bool fsphere_hollow; // -@37
//uniform float fsphere_hollow_edge; // -@37
//uniform float fspheretree_symmetry; // -@38
//uniform vec3 ftetrahedron_position; // -@39
//uniform float ftetrahedron_size; // -@39
//uniform float ftetrahedron_roundness; // -@39
//uniform bool ftetrahedron_hollow; // -@39
//uniform float ftetrahedron_hollow_edge; // -@39
//uniform bool fvicsek_preserve; // -@40
//uniform bool fvicsek_hex_fold1; // -@40
//uniform int fvicsek_hex_fold2; // -@40
//uniform bool fvicsek_abs1_x; // -@40
//uniform bool fvicsek_abs1_z; // -@40
//uniform vec3 fvicsek_limit; // -@40
//uniform vec3 fvicsek_abs2_minus; // -@40
//uniform vec3 fvicsek_abs2_plus; // -@40
//uniform vec3 fvicsek_offset; // -@40
//uniform vec2 fvicsek_foldt; // -@40
//uniform float fvicsek_scale; // -@40
//uniform vec3 fvicsek_rotation1; // -@40
//uniform vec3 fvicsek_rotation2; // -@40
//uniform vec2 fwobbletransform_rotation; // -@41
//uniform float fwobbletransform_strength; // -@41
//uniform vec4 fwobbletransform_step; // -@41
//uniform vec2 fwobbletransform_range; // -@41

//#include "res://formulas/amazingsurf.gdshaderinc" // -@1
//#include "res://formulas/bairddelta.gdshaderinc" // -@2
//#include "res://formulas/basictransform.gdshaderinc" // -@3
//#include "res://formulas/benesiship.gdshaderinc" // -@4
//#include "res://formulas/bristorbrot.gdshaderinc" // -@5
#include "res://formulas/cube.gdshaderinc" // -@6
//#include "res://formulas/dodecahedron.gdshaderinc" // -@7
//#include "res://formulas/icosahedron.gdshaderinc" // -@8
//#include "res://formulas/inversiontransform.gdshaderinc" // -@9
//#include "res://formulas/jerusalemcube.gdshaderinc" // -@10
//#include "res://formulas/kalaidotransform.gdshaderinc" // -@11
//#include "res://formulas/kalibox.gdshaderinc" // -@12
//#include "res://formulas/kaliliving.gdshaderinc" // -@13
//#include "res://formulas/kaliredux.gdshaderinc" // -@14
//#include "res://formulas/klenian.gdshaderinc" // -@15
//#include "res://formulas/kochcube.gdshaderinc" // -@16
//#include "res://formulas/kochwire.gdshaderinc" // -@17
//#include "res://formulas/lionbulb.gdshaderinc" // -@18
//#include "res://formulas/logtransform.gdshaderinc" // -@19
//#include "res://formulas/mandelbox.gdshaderinc" // -@20
//#include "res://formulas/mandelbulb.gdshaderinc" // -@21
#include "res://formulas/mengersponge.gdshaderinc" // -@22
//#include "res://formulas/mixpinski4d.gdshaderinc" // -@23
//#include "res://formulas/newton.gdshaderinc" // -@24
//#include "res://formulas/octahedron.gdshaderinc" // -@25
//#include "res://formulas/octkoch.gdshaderinc" // -@26
//#include "res://formulas/platonickoch.gdshaderinc" // -@27
//#include "res://formulas/pseudoklenian.gdshaderinc" // -@28
//#include "res://formulas/quadratickoch.gdshaderinc" // -@29
//#include "res://formulas/reciprocaltransform.gdshaderinc" // -@30
//#include "res://formulas/sierpinskidodecahedron.gdshaderinc" // -@31
//#include "res://formulas/sierpinskiicosahedron.gdshaderinc" // -@32
//#include "res://formulas/sierpinskioctahedron.gdshaderinc" // -@33
//#include "res://formulas/sierpinskitetrahedron.gdshaderinc" // -@34
//#include "res://formulas/sintransform.gdshaderinc" // -@35
//#include "res://formulas/sphairahedron.gdshaderinc" // -@36
//#include "res://formulas/sphere.gdshaderinc" // -@37
//#include "res://formulas/spheretree.gdshaderinc" // -@38
//#include "res://formulas/tetrahedron.gdshaderinc" // -@39
//#include "res://formulas/vicsek.gdshaderinc" // -@40
//#include "res://formulas/wobbletransform.gdshaderinc" // -@41

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

	bool single_formula = false;
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
//if (current_formula == 9) inversiontransform_iter(z, dz, original_z, orbit, i); //-@9
//if (current_formula == 10) jerusalemcube_iter(z, dz, original_z, orbit, i); //-@10
//if (current_formula == 11) kalaidotransform_iter(z, dz, original_z, orbit, i); //-@11
//if (current_formula == 12) kalibox_iter(z, dz, original_z, orbit, i); //-@12
//if (current_formula == 13) kaliliving_iter(z, dz, original_z, orbit, i); //-@13
//if (current_formula == 14) kaliredux_iter(z, dz, original_z, orbit, i); //-@14
//if (current_formula == 16) kochcube_iter(z, dz, original_z, orbit, i, s); //-@16
//if (current_formula == 17) kochwire_iter(z, dz, original_z, orbit, i); //-@17
//if (current_formula == 18) lionbulb_iter(z, dz, original_z, orbit, i); //-@18
//if (current_formula == 19) logtransform_iter(z, dz, original_z, orbit, i); //-@19
//if (current_formula == 20) mandelbox_iter(z, dz, original_z, orbit, i); //-@20
//if (current_formula == 21) mandelbulb_iter(z, dz, original_z, orbit, i); //-@21
if (current_formula == 22) mengersponge_iter(z, dz, original_z, orbit, i); //-@22
//if (current_formula == 23) mixpinski4d_iter(z, dz, original_z, orbit, i); //-@23
//if (current_formula == 26) octkoch_iter(z, dz, original_z, orbit, i); //-@26
//if (current_formula == 27) platonickoch_iter(z, dz, original_z, orbit, i); //-@27
//if (current_formula == 28) pseudoklenian_iter(z, dz, original_z, orbit, i); //-@28
//if (current_formula == 29) quadratickoch_iter(z, dz, original_z, orbit, i); //-@29
//if (current_formula == 30) reciprocaltransform_iter(z, dz, original_z, orbit, i); //-@30
//if (current_formula == 31) sierpinskidodecahedron_iter(z, dz, original_z, orbit, i); //-@31
//if (current_formula == 32) sierpinskiicosahedron_iter(z, dz, original_z, orbit, i); //-@32
//if (current_formula == 33) sierpinskioctahedron_iter(z, dz, original_z, orbit, i); //-@33
//if (current_formula == 34) sierpinskitetrahedron_iter(z, dz, original_z, orbit, i); //-@34
//if (current_formula == 35) sintransform_iter(z, dz, original_z, orbit, i); //-@35
//if (current_formula == 40) vicsek_iter(z, dz, original_z, orbit, i); //-@40
//if (current_formula == 41) wobbletransform_iter(z, dz, original_z, orbit, i); //-@41
		orbit = min(orbit, process_orbit_trap4d(z, original_z, i));

		if (dot(z, z) > escape_radius * escape_radius || escaped) break;
	}

	float r = length(z);
	float de = 0.0;

	if (formulas[1] <= 0) single_formula = true;

	if (de_mode == 0) de = r / dz;
	else if (de_mode == 1) de = 0.5 * log(r) * r / dz;
	else if (de_mode == 2) {

			if (single_formula && (formulas[0] == 16 || formulas[0] == 22 || formulas[0] == 26 || formulas[0] == 27 || formulas[0] == 29)) de = r / dz;
			else de = 0.5 * log(r) * r / dz;
		
	}

if (single_formula) {
de = cube_sdf(original_z).x; // -@6
//de = dodecahedron_sdf(original_z).x; // -@7
//de = icosahedron_sdf(original_z).x; // -@8
//de = klenian_sdf(original_z).x; // -@15
//de = newton_sdf(original_z).x; // -@24
//de = octahedron_sdf(original_z).x; // -@25
//de = sphairahedron_sdf(original_z).x; // -@36
//de = sphere_sdf(original_z).x; // -@37
//de = spheretree_sdf(original_z).x; // -@38
//de = tetrahedron_sdf(original_z).x; // -@39

} else {
de = min(de, cube_sdf(original_z).x); // -@6
//de = min(de, dodecahedron_sdf(original_z).x); // -@7
//de = min(de, icosahedron_sdf(original_z).x); // -@8
//de = max(de, klenian_sdf(original_z).x); // -@15
//de = max(de, newton_sdf(original_z).x); // -@24
//de = min(de, octahedron_sdf(original_z).x); // -@25
//de = max(de, sphairahedron_sdf(original_z).x); // -@36
//de = min(de, sphere_sdf(original_z).x); // -@37
//de = max(de, spheretree_sdf(original_z).x); // -@38
//de = min(de, tetrahedron_sdf(original_z).x); // -@39

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
	ALBEDO = calculate_albedo(ro, rd, SCREEN_UV, FRAGCOORD.xy, VIEWPORT_SIZE, PROJECTION_MATRIX, VIEW_MATRIX, discard_color); \
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