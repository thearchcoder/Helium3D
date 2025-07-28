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
uniform bool connect_normal_to_epsilon;

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
// Tools / General
uniform bool transparent_bg;
// Tools / Debug
uniform int display;
uniform float depth_scale;
// Lighting / Background
uniform int bg_type;
uniform sampler2D bg_image;
uniform sampler2D bg_color;
// Other
uniform float number_of_active_formulas;
uniform bool only_sdf_based_formulas;
uniform float difs_smoothing;
uniform bool exponential_smoothing;
uniform float progression_strength;
// Voxelization
uniform bool voxelization;
uniform vec3 bounds_position;
uniform vec3 bounds_size;
uniform float voxel_epsilon;
uniform vec2 voxel_screen_resolution;
uniform float sample_scale = 4.0;
uniform bool building_mesh = false;
uniform int voxel_resolution;
// Modifiers / Base
uniform int base_shape;

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
//uniform float fattractortransform_dt; // -@2
//uniform float fattractortransform_sigma; // -@2
//uniform float fattractortransform_ro; // -@2
//uniform float fattractortransform_beta; // -@2
//uniform vec2 fattractortransform_range; // -@2
//uniform float fbairddelta_angle; // -@3
//uniform vec3 fbairddelta_rotation1; // -@3
//uniform vec3 fbairddelta_rotation2; // -@3
//uniform float fbairddelta_scale; // -@3
//uniform vec4 fbasictransform_offset; // -@4
//uniform vec4 fbasictransform_scale; // -@4
//uniform vec2 fbasictransform_range; // -@4
//uniform bool fbenesiship_is_julia; // -@5
//uniform vec3 fbenesiship_julia_c; // -@5
//uniform bool fbristorbrot_is_julia; // -@6
//uniform vec3 fbristorbrot_julia_c; // -@6
//uniform vec3 fbristorbrot_multiply; // -@6
//uniform float fcircuit_scale; // -@7
//uniform vec4 fcircuit_abs1; // -@7
//uniform vec4 fcircuit_abs2; // -@7
//uniform vec2 fcircuit_box_fold; // -@7
//uniform vec4 fcircuit_box_minus; // -@7
//uniform vec3 fcube_position; // -@8
//uniform vec3 fcube_size; // -@8
//uniform float fcube_roundness; // -@8
//uniform bool fcube_hollow; // -@8
//uniform float fcube_hollow_edge; // -@8
//uniform vec3 fdodecahedron_position; // -@9
//uniform float fdodecahedron_size; // -@9
//uniform float fdodecahedron_roundness; // -@9
//uniform float fgemstone_scale; // -@10
//uniform vec3 fgemstone_clamp; // -@10
//uniform vec3 fgemstone_offset; // -@10
//uniform vec3 fgyroid_position; // -@11
//uniform float fgyroid_scale; // -@11
//uniform float fgyroid_sphere_radius; // -@11
//uniform float fgyroid_time; // -@11
//uniform float fgyroid_thickness; // -@11
//uniform float fgyroid_bias; // -@11
//uniform vec4 fgyroid_control; // -@11
//uniform vec2 fgyroid_offset; // -@11
//uniform bool fgyroid_oriented; // -@11
//uniform bool fgyroid_abs; // -@11
//uniform float fhollowtetrahedron_scale; // -@12
//uniform float fhollowtetrahedron_thickness; // -@12
//uniform vec3 fhollowtetrahedron_offset; // -@12
//uniform vec3 ficosahedron_position; // -@13
//uniform float ficosahedron_size; // -@13
//uniform float finversebox_scale; // -@14
//uniform float finversebox_thickness; // -@14
//uniform vec3 finversebox_offset; // -@14
//uniform vec4 finversiontransform_sphere; // -@15
//uniform vec2 finversiontransform_range; // -@15
//uniform vec2 fjerusalemcube_scale; // -@16
//uniform vec3 fjerusalemcube_offset; // -@16
//uniform vec3 fjerusalemcube_rotation1; // -@16
//uniform vec3 fjerusalemcube_rotation2; // -@16
//uniform vec3 fjerusalemcube_abs_add; // -@16
//uniform vec3 fjerusalemcube_abs_minus; // -@16
//uniform int fkalaidotransform_axis; // -@17
//uniform int fkalaidotransform_mode; // -@17
//uniform float fkalaidotransform_symmetry; // -@17
//uniform vec2 fkalaidotransform_range; // -@17
//uniform float fkalibox_scale; // -@18
//uniform vec3 fkalibox_offset1; // -@18
//uniform vec3 fkalibox_offset2; // -@18
//uniform vec3 fkaliliving_c; // -@19
//uniform vec3 fkaliliving_rotation1; // -@19
//uniform vec3 fkaliliving_rotation2; // -@19
//uniform float fkaliliving_scale; // -@19
//uniform vec4 fkaliredux_folds; // -@20
//uniform vec3 fkaliredux_minus; // -@20
//uniform float fkaliredux_scale; // -@20
//uniform bool fklenian_show_balls; // -@21
//uniform float fklenian_x; // -@21
//uniform float fklenian_y; // -@21
//uniform float fklenian_box_size_x; // -@21
//uniform float fklenian_box_size_z; // -@21
//uniform float fkochcube_scale; // -@22
//uniform int fkochcube_variant; // -@22
//uniform bool fkochcube_first_zrev; // -@22
//uniform bool fkochcube_pxyzminuss; // -@22
//uniform bool fkochcube_psortsymmetry1; // -@22
//uniform bool fkochcube_psortsymmetry2; // -@22
//uniform bool fkochcube_foldzbefore; // -@22
//uniform bool fkochcube_abs_x; // -@22
//uniform bool fkochcube_abs_y; // -@22
//uniform bool fkochcube_abs_z; // -@22
//uniform int fkochcube_fold1; // -@22
//uniform int fkochcube_fold2; // -@22
//uniform bool fkochcube_fold3; // -@22
//uniform bool fkochcube_fold4; // -@22
//uniform bool fkochcube_reflection; // -@22
//uniform vec3 fkochcube_rotation1; // -@22
//uniform vec3 fkochcube_rotation2; // -@22
//uniform bool fkochwire_fold1; // -@23
//uniform bool fkochwire_fold2; // -@23
//uniform bool fkochwire_fold3; // -@23
//uniform bool fkochwire_abs_x; // -@23
//uniform bool fkochwire_abs_y; // -@23
//uniform bool fkochwire_abs_z; // -@23
//uniform bool fkochwire_abs2_zx; // -@23
//uniform vec3 fkochwire_abs_plus; // -@23
//uniform vec3 fkochwire_abs_minus; // -@23
//uniform float fkochwire_scale; // -@23
//uniform float fkochwire_symmetry; // -@23
//uniform vec3 fkochwire_offset; // -@23
//uniform vec3 fkochwire_rotation1; // -@23
//uniform vec3 fkochwire_rotation2; // -@23
//uniform float flionbulb_power; // -@24
//uniform float flionbulb_phase; // -@24
//uniform vec3 flionbulb_c; // -@24
//uniform bool flionbulb_coral; // -@24
//uniform int flogtransform_axis; // -@25
//uniform float flogtransform_offset; // -@25
//uniform float flogtransform_scale; // -@25
//uniform vec2 flogtransform_range; // -@25
//uniform vec3 florenz_initial_position; // -@26
//uniform float florenz_dt; // -@26
//uniform float florenz_sigma; // -@26
//uniform float florenz_ro; // -@26
//uniform float florenz_beta; // -@26
//uniform int fmandelbox_shape; // -@27
//uniform float fmandelbox_scale; // -@27
//uniform float fmandelbox_radius1; // -@27
//uniform float fmandelbox_fold1; // -@27
//uniform float fmandelbox_fold1_strength; // -@27
//uniform float fmandelbox_radius2; // -@27
//uniform vec3 fmandelbox_box_folds; // -@27
//uniform bool fmandelbox_is_julia; // -@27
//uniform vec3 fmandelbox_julia_c; // -@27
//uniform vec3 fmandelbox_rotation1; // -@27
//uniform vec3 fmandelbox_rotation2; // -@27
uniform float fmandelbulb_phase; // -@28
uniform float fmandelbulb_power; // -@28
uniform float fmandelbulb_z_mul; // -@28
uniform bool fmandelbulb_conjugate; // -@28
uniform bool fmandelbulb_abs_x; // -@28
uniform bool fmandelbulb_abs_y; // -@28
uniform bool fmandelbulb_abs_z; // -@28
uniform bool fmandelbulb_is_julia; // -@28
uniform vec4 fmandelbulb_julia_c; // -@28
uniform float fmandelbulb_derivative_bias; // -@28
uniform int fmandelbulb_number_system; // -@28
uniform int fmandelbulb_quaternion_mode; // -@28
//uniform bool fmandelettuce_is_julia; // -@29
//uniform vec3 fmandelettuce_julia_c; // -@29
//uniform int fmandelettuce_power; // -@29
//uniform vec4 fmelttransform_a; // -@30
//uniform vec4 fmelttransform_b; // -@30
//uniform vec4 fmelttransform_c; // -@30
//uniform vec4 fmelttransform_d; // -@30
//uniform vec2 fmelttransform_range; // -@30
//uniform vec3 fmengersponge_offset; // -@31
//uniform vec3 fmengersponge_rotation1; // -@31
//uniform vec3 fmengersponge_rotation2; // -@31
//uniform float fmengersponge_scale; // -@31
//uniform float fmixpinski4d_scale; // -@32
//uniform float fmixpinski4d_fold1_strength; // -@32
//uniform vec4 fmixpinski4d_offset; // -@32
//uniform vec4 fmixpinski4d_rotation1; // -@32
//uniform vec4 fmixpinski4d_rotation2; // -@32
//uniform float fmixpinski4d_abs_minus; // -@32
//uniform vec4 fmixpinski4d_fold1; // -@32
//uniform vec4 fmixpinski4d_pre_offset; // -@32
//uniform int fnewton_plane; // -@33
//uniform bool fnewton_intersection_mode; // -@33
//uniform vec3 foctahedron_position; // -@34
//uniform float foctahedron_size; // -@34
//uniform float foctahedron_roundness; // -@34
//uniform float foctkoch_scale; // -@35
//uniform vec3 foctkoch_offset; // -@35
//uniform vec3 foctkoch_fold; // -@35
//uniform bool foctkoch_abs; // -@35
//uniform vec3 foctkoch_rotation1; // -@35
//uniform vec3 foctkoch_rotation2; // -@35
//uniform vec3 fplane_position; // -@36
//uniform vec3 fplane_direction; // -@36
//uniform bool fplane_thin; // -@36
//uniform float fplane_thickness; // -@36
//uniform float fplatonickoch_stretch; // -@37
//uniform float fplatonickoch_postscale; // -@37
//uniform float fplatonickoch_zfix; // -@37
//uniform vec3 fplatonickoch_add; // -@37
//uniform vec4 fpseudoklenian_min; // -@38
//uniform vec4 fpseudoklenian_max; // -@38
//uniform float fpseudoklenian_sign; // -@38
//uniform float fpseudoklenian_scale; // -@38
//uniform vec2 fquadratickoch_octahedron_limit; // -@39
//uniform vec3 fquadratickoch_octahedron_offset; // -@39
//uniform vec3 fquadratickoch_octahedron_offset2; // -@39
//uniform vec3 fquadratickoch_octahedron_; // -@39
//uniform vec3 fquadratickoch_offset; // -@39
//uniform vec2 fquadratickoch_scale; // -@39
//uniform vec3 fquadratickoch_rotation1; // -@39
//uniform vec3 fquadratickoch_rotation2; // -@39
//uniform float fquadratickoch_abs_offset; // -@39
//uniform int freciprocaltransform_axis; // -@40
//uniform float freciprocaltransform_offset; // -@40
//uniform vec2 freciprocaltransform_range; // -@40
//uniform vec3 fsierpinskidodecahedron_offset; // -@41
//uniform vec3 fsierpinskidodecahedron_rotation1; // -@41
//uniform vec3 fsierpinskidodecahedron_rotation2; // -@41
//uniform float fsierpinskidodecahedron_scale; // -@41
//uniform vec3 fsierpinskiicosahedron_offset; // -@42
//uniform vec3 fsierpinskiicosahedron_rotation1; // -@42
//uniform vec3 fsierpinskiicosahedron_rotation2; // -@42
//uniform float fsierpinskiicosahedron_scale; // -@42
//uniform vec3 fsierpinskioctahedron_rotation1; // -@43
//uniform vec3 fsierpinskioctahedron_rotation2; // -@43
//uniform vec3 fsierpinskioctahedron_offset; // -@43
//uniform float fsierpinskioctahedron_scale; // -@43
//uniform vec3 fsierpinskitetrahedron_offset; // -@44
//uniform vec3 fsierpinskitetrahedron_rotation1; // -@44
//uniform vec3 fsierpinskitetrahedron_rotation2; // -@44
//uniform float fsierpinskitetrahedron_scale; // -@44
//uniform int fsintransform_axis; // -@45
//uniform vec2 fsintransform_offset; // -@45
//uniform vec2 fsintransform_scale; // -@45
//uniform vec2 fsintransform_range; // -@45
//uniform int fsphairahedron_cube_type; // -@46
//uniform float fsphairahedron_zc; // -@46
//uniform float fsphairahedron_zb; // -@46
//uniform vec3 fsphere_position; // -@47
//uniform float fsphere_radius; // -@47
//uniform bool fsphere_hollow; // -@47
//uniform float fsphere_hollow_edge; // -@47
//uniform float fspheretree_symmetry; // -@48
//uniform vec3 ftetrahedron_position; // -@49
//uniform float ftetrahedron_size; // -@49
//uniform float ftriescher_scale; // -@50
//uniform vec3 ftriescher_offset; // -@50
//uniform vec3 ftriescher_clamp; // -@50
//uniform vec3 ftriescher_add; // -@50
//uniform vec2 ftriescher_limit; // -@50
//uniform float ftriescher_symmetry; // -@50
//uniform bool fvicsek_preserve; // -@51
//uniform bool fvicsek_hex_fold1; // -@51
//uniform int fvicsek_hex_fold2; // -@51
//uniform bool fvicsek_abs1_x; // -@51
//uniform bool fvicsek_abs1_z; // -@51
//uniform vec3 fvicsek_limit; // -@51
//uniform vec3 fvicsek_abs2_minus; // -@51
//uniform vec3 fvicsek_abs2_plus; // -@51
//uniform vec3 fvicsek_offset; // -@51
//uniform vec2 fvicsek_foldt; // -@51
//uniform float fvicsek_scale; // -@51
//uniform vec3 fvicsek_rotation1; // -@51
//uniform vec3 fvicsek_rotation2; // -@51
//uniform float fwavysponge_scale; // -@52
//uniform vec3 fwavysponge_clamp; // -@52
//uniform vec3 fwavysponge_offset; // -@52
//uniform vec2 fwobbletransform_rotation; // -@53
//uniform float fwobbletransform_strength; // -@53
//uniform vec4 fwobbletransform_step; // -@53
//uniform vec2 fwobbletransform_range; // -@53

//#include "res://formulas/amazingsurf.gdshaderinc" // -@1
//#include "res://formulas/attractortransform.gdshaderinc" // -@2
//#include "res://formulas/bairddelta.gdshaderinc" // -@3
//#include "res://formulas/basictransform.gdshaderinc" // -@4
//#include "res://formulas/benesiship.gdshaderinc" // -@5
//#include "res://formulas/bristorbrot.gdshaderinc" // -@6
//#include "res://formulas/circuit.gdshaderinc" // -@7
//#include "res://formulas/cube.gdshaderinc" // -@8
//#include "res://formulas/dodecahedron.gdshaderinc" // -@9
//#include "res://formulas/gemstone.gdshaderinc" // -@10
//#include "res://formulas/gyroid.gdshaderinc" // -@11
//#include "res://formulas/hollowtetrahedron.gdshaderinc" // -@12
//#include "res://formulas/icosahedron.gdshaderinc" // -@13
//#include "res://formulas/inversebox.gdshaderinc" // -@14
//#include "res://formulas/inversiontransform.gdshaderinc" // -@15
//#include "res://formulas/jerusalemcube.gdshaderinc" // -@16
//#include "res://formulas/kalaidotransform.gdshaderinc" // -@17
//#include "res://formulas/kalibox.gdshaderinc" // -@18
//#include "res://formulas/kaliliving.gdshaderinc" // -@19
//#include "res://formulas/kaliredux.gdshaderinc" // -@20
//#include "res://formulas/klenian.gdshaderinc" // -@21
//#include "res://formulas/kochcube.gdshaderinc" // -@22
//#include "res://formulas/kochwire.gdshaderinc" // -@23
//#include "res://formulas/lionbulb.gdshaderinc" // -@24
//#include "res://formulas/logtransform.gdshaderinc" // -@25
//#include "res://formulas/lorenz.gdshaderinc" // -@26
//#include "res://formulas/mandelbox.gdshaderinc" // -@27
#include "res://formulas/mandelbulb.gdshaderinc" // -@28
//#include "res://formulas/mandelettuce.gdshaderinc" // -@29
//#include "res://formulas/melttransform.gdshaderinc" // -@30
//#include "res://formulas/mengersponge.gdshaderinc" // -@31
//#include "res://formulas/mixpinski4d.gdshaderinc" // -@32
//#include "res://formulas/newton.gdshaderinc" // -@33
//#include "res://formulas/octahedron.gdshaderinc" // -@34
//#include "res://formulas/octkoch.gdshaderinc" // -@35
//#include "res://formulas/plane.gdshaderinc" // -@36
//#include "res://formulas/platonickoch.gdshaderinc" // -@37
//#include "res://formulas/pseudoklenian.gdshaderinc" // -@38
//#include "res://formulas/quadratickoch.gdshaderinc" // -@39
//#include "res://formulas/reciprocaltransform.gdshaderinc" // -@40
//#include "res://formulas/sierpinskidodecahedron.gdshaderinc" // -@41
//#include "res://formulas/sierpinskiicosahedron.gdshaderinc" // -@42
//#include "res://formulas/sierpinskioctahedron.gdshaderinc" // -@43
//#include "res://formulas/sierpinskitetrahedron.gdshaderinc" // -@44
//#include "res://formulas/sintransform.gdshaderinc" // -@45
//#include "res://formulas/sphairahedron.gdshaderinc" // -@46
//#include "res://formulas/sphere.gdshaderinc" // -@47
//#include "res://formulas/spheretree.gdshaderinc" // -@48
//#include "res://formulas/tetrahedron.gdshaderinc" // -@49
//#include "res://formulas/triescher.gdshaderinc" // -@50
//#include "res://formulas/vicsek.gdshaderinc" // -@51
//#include "res://formulas/wavysponge.gdshaderinc" // -@52
//#include "res://formulas/wobbletransform.gdshaderinc" // -@53

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
//if (current_formula == 2) attractortransform_iter(z, dz, original_z, orbit, i); //-@2
//if (current_formula == 3) bairddelta_iter(z, dz, original_z, orbit, i); //-@3
//if (current_formula == 4) basictransform_iter(z, dz, original_z, orbit, i); //-@4
//if (current_formula == 5) benesiship_iter(z, dz, original_z, orbit, i); //-@5
//if (current_formula == 6) bristorbrot_iter(z, dz, original_z, orbit, i); //-@6
//if (current_formula == 10) gemstone_iter(z, dz, original_z, orbit, i); //-@10
//if (current_formula == 15) inversiontransform_iter(z, dz, original_z, orbit, i); //-@15
//if (current_formula == 16) jerusalemcube_iter(z, dz, original_z, orbit, i); //-@16
//if (current_formula == 17) kalaidotransform_iter(z, dz, original_z, orbit, i); //-@17
//if (current_formula == 18) kalibox_iter(z, dz, original_z, orbit, i); //-@18
//if (current_formula == 19) kaliliving_iter(z, dz, original_z, orbit, i); //-@19
//if (current_formula == 20) kaliredux_iter(z, dz, original_z, orbit, i); //-@20
//if (current_formula == 22) kochcube_iter(z, dz, original_z, orbit, i, s); //-@22
//if (current_formula == 23) kochwire_iter(z, dz, original_z, orbit, i); //-@23
//if (current_formula == 24) lionbulb_iter(z, dz, original_z, orbit, i); //-@24
//if (current_formula == 25) logtransform_iter(z, dz, original_z, orbit, i); //-@25
//if (current_formula == 27) mandelbox_iter(z, dz, original_z, orbit, i); //-@27
if (current_formula == 28) mandelbulb_iter(z, dz, original_z, orbit, i); //-@28
//if (current_formula == 29) mandelettuce_iter(z, dz, original_z, orbit, i); //-@29
//if (current_formula == 30) melttransform_iter(z, dz, original_z, orbit, i); //-@30
//if (current_formula == 31) mengersponge_iter(z, dz, original_z, orbit, i); //-@31
//if (current_formula == 32) mixpinski4d_iter(z, dz, original_z, orbit, i); //-@32
//if (current_formula == 35) octkoch_iter(z, dz, original_z, orbit, i); //-@35
//if (current_formula == 37) platonickoch_iter(z, dz, original_z, orbit, i); //-@37
//if (current_formula == 38) pseudoklenian_iter(z, dz, original_z, orbit, i); //-@38
//if (current_formula == 39) quadratickoch_iter(z, dz, original_z, orbit, i); //-@39
//if (current_formula == 40) reciprocaltransform_iter(z, dz, original_z, orbit, i); //-@40
//if (current_formula == 41) sierpinskidodecahedron_iter(z, dz, original_z, orbit, i); //-@41
//if (current_formula == 42) sierpinskiicosahedron_iter(z, dz, original_z, orbit, i); //-@42
//if (current_formula == 43) sierpinskioctahedron_iter(z, dz, original_z, orbit, i); //-@43
//if (current_formula == 44) sierpinskitetrahedron_iter(z, dz, original_z, orbit, i); //-@44
//if (current_formula == 45) sintransform_iter(z, dz, original_z, orbit, i); //-@45
//if (current_formula == 50) triescher_iter(z, dz, original_z, orbit, i); //-@50
//if (current_formula == 51) vicsek_iter(z, dz, original_z, orbit, i); //-@51
//if (current_formula == 52) wavysponge_iter(z, dz, original_z, orbit, i); //-@52
//if (current_formula == 53) wobbletransform_iter(z, dz, original_z, orbit, i); //-@53
		orbit = min(orbit, process_orbit_trap4d(z, original_z, i));

		if (dot(z, z) > escape_radius * escape_radius || escaped) break;
	}

	float r = length(z);
	float de = 0.0;
	
	bool single_formula = false;
if (formulas[0] == 7 || formulas[0] == 8 || formulas[0] == 9 || formulas[0] == 11 || formulas[0] == 12 || formulas[0] == 13 || formulas[0] == 14 || formulas[0] == 21 || formulas[0] == 26 || formulas[0] == 33 || formulas[0] == 34 || formulas[0] == 36 || formulas[0] == 46 || formulas[0] == 47 || formulas[0] == 48 || formulas[0] == 49|| formulas[0] <= 0 || formulas[1] == 7 || formulas[1] == 8 || formulas[1] == 9 || formulas[1] == 11 || formulas[1] == 12 || formulas[1] == 13 || formulas[1] == 14 || formulas[1] == 21 || formulas[1] == 26 || formulas[1] == 33 || formulas[1] == 34 || formulas[1] == 36 || formulas[1] == 46 || formulas[1] == 47 || formulas[1] == 48 || formulas[1] == 49|| formulas[1] <= 0 || formulas[2] == 7 || formulas[2] == 8 || formulas[2] == 9 || formulas[2] == 11 || formulas[2] == 12 || formulas[2] == 13 || formulas[2] == 14 || formulas[2] == 21 || formulas[2] == 26 || formulas[2] == 33 || formulas[2] == 34 || formulas[2] == 36 || formulas[2] == 46 || formulas[2] == 47 || formulas[2] == 48 || formulas[2] == 49|| formulas[2] <= 0)
	
	if (de_mode == 0) de = r / dz;
	else if (de_mode == 1) de = 0.5 * log(r) * r / dz;
	else if (de_mode == 2) {

			if (single_formula && (formulas[0] == 22 || formulas[0] == 31 || formulas[0] == 35 || formulas[0] == 37 || formulas[0] == 39)) de = r / dz;
			else de = 0.5 * log(r) * r / dz;
		
	}
	
	if (only_sdf_based_formulas) de = 0.0;

if (single_formula) {
//de = circuit_sdf(original_z).x; // -@7
//de = cube_sdf(original_z).x; // -@8
//de = dodecahedron_sdf(original_z).x; // -@9
//de = gyroid_sdf(original_z).x; // -@11
//de = hollowtetrahedron_sdf(original_z).x; // -@12
//de = icosahedron_sdf(original_z).x; // -@13
//de = inversebox_sdf(original_z).x; // -@14
//de = klenian_sdf(original_z).x; // -@21
//de = lorenz_sdf(original_z).x; // -@26
//de = newton_sdf(original_z).x; // -@33
//de = octahedron_sdf(original_z).x; // -@34
//de = plane_sdf(original_z).x; // -@36
//de = sphairahedron_sdf(original_z).x; // -@46
//de = sphere_sdf(original_z).x; // -@47
//de = spheretree_sdf(original_z).x; // -@48
//de = tetrahedron_sdf(original_z).x; // -@49

} else {
//de = smax(de, circuit_sdf(original_z).x, difs_smoothing); // -@7
//de = smax(de, hollowtetrahedron_sdf(original_z).x, difs_smoothing); // -@12
//de = smax(de, inversebox_sdf(original_z).x, difs_smoothing); // -@14
//de = smin(de, cube_sdf(original_z).x, difs_smoothing); // -@8
//de = smin(de, dodecahedron_sdf(original_z).x, difs_smoothing); // -@9
//de = smin(de, gyroid_sdf(original_z).x, difs_smoothing); // -@11
//de = smin(de, icosahedron_sdf(original_z).x, difs_smoothing); // -@13
//de = smax(de, klenian_sdf(original_z).x, difs_smoothing); // -@21
//de = smax(de, lorenz_sdf(original_z).x, difs_smoothing); // -@26
//de = smax(de, newton_sdf(original_z).x, difs_smoothing); // -@33
//de = smin(de, octahedron_sdf(original_z).x, difs_smoothing); // -@34
//de = smin(de, plane_sdf(original_z).x, difs_smoothing); // -@36
//de = smax(de, sphairahedron_sdf(original_z).x, difs_smoothing); // -@46
//de = smax(de, spheretree_sdf(original_z).x, difs_smoothing); // -@48
//de = smin(de, sphere_sdf(original_z).x, difs_smoothing); // -@47
//de = smin(de, tetrahedron_sdf(original_z).x, difs_smoothing); // -@49

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

float calc_epsilon(float dfo) {
	return relative_epsilon ? epsilon / 3.4 * dfo : epsilon;
}

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
		dfo += max(point_distance * raystep_multiplier, calc_epsilon(dfo));
		total_marches += 1.0;

		if (point_distance < calc_epsilon(dfo) || dfo > max_distance) {
			orbit_trap_distance = data.x;
			final_bounds_dist = bounds_dist;
			final_bounds_color = bounds_color;
			break;
		};
	}
	
	if (voxelization && final_bounds_dist < calc_epsilon(dfo)) {
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
		
		vec2 centered_uv = screen_uv - 0.5;
		vec2 resolution_scale = voxel_screen_resolution / 450.0;
		vec3 sample_offset = camera_right * centered_uv.x * sample_scale / resolution_scale.x + 
		                    camera_up * centered_uv.y * sample_scale / resolution_scale.y;
		vec3 sample_pos = ray_origin + sample_offset;
		
		vec2 sdf_data = scene_sdf(sample_pos);
		float distance_to_surface = sdf_data.y;
		
		if (distance_to_surface < voxel_epsilon) {
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
	vec3 normal = calculate_normal(p, connect_normal_to_epsilon ? calc_epsilon(dfo) * normal_epsilon * 1000.0 : normal_epsilon);
	
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