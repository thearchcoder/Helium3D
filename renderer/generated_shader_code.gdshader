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
// Lighting / General
uniform bool hard_shadows;
// Other
uniform bool single_formula = false;
uniform sampler2D previous_frame : filter_nearest, hint_default_black;
uniform sampler2D pixels_to_render : filter_nearest, hint_default_white;
uniform float number_of_active_formulas;
uniform bool only_primitive_based_formulas;
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
//uniform bool famazingsurfdupea_is_julia; // -@2
//uniform vec3 famazingsurfdupea_julia_c; // -@2
//uniform vec3 famazingsurfdupea_rotation; // -@2
//uniform vec3 famazingsurfdupea_fold; // -@2
//uniform bool famazingsurfdupea_fold_z; // -@2
//uniform float famazingsurfdupea_min_radius; // -@2
//uniform vec3 famazingsurfdupea_offset; // -@2
//uniform float famazingsurfdupea_scale; // -@2
//uniform vec2 famazingsurfdupea_fold2; // -@2
//uniform bool famazingsurfdupeb_is_julia; // -@3
//uniform vec3 famazingsurfdupeb_julia_c; // -@3
//uniform vec3 famazingsurfdupeb_rotation; // -@3
//uniform vec3 famazingsurfdupeb_fold; // -@3
//uniform bool famazingsurfdupeb_fold_z; // -@3
//uniform float famazingsurfdupeb_min_radius; // -@3
//uniform vec3 famazingsurfdupeb_offset; // -@3
//uniform float famazingsurfdupeb_scale; // -@3
//uniform vec2 famazingsurfdupeb_fold2; // -@3
//uniform bool famazingsurfdupec_is_julia; // -@4
//uniform vec3 famazingsurfdupec_julia_c; // -@4
//uniform vec3 famazingsurfdupec_rotation; // -@4
//uniform vec3 famazingsurfdupec_fold; // -@4
//uniform bool famazingsurfdupec_fold_z; // -@4
//uniform float famazingsurfdupec_min_radius; // -@4
//uniform vec3 famazingsurfdupec_offset; // -@4
//uniform float famazingsurfdupec_scale; // -@4
//uniform vec2 famazingsurfdupec_fold2; // -@4
//uniform bool famazingsurfduped_is_julia; // -@5
//uniform vec3 famazingsurfduped_julia_c; // -@5
//uniform vec3 famazingsurfduped_rotation; // -@5
//uniform vec3 famazingsurfduped_fold; // -@5
//uniform bool famazingsurfduped_fold_z; // -@5
//uniform float famazingsurfduped_min_radius; // -@5
//uniform vec3 famazingsurfduped_offset; // -@5
//uniform float famazingsurfduped_scale; // -@5
//uniform vec2 famazingsurfduped_fold2; // -@5
//uniform bool famazingsurfdupee_is_julia; // -@6
//uniform vec3 famazingsurfdupee_julia_c; // -@6
//uniform vec3 famazingsurfdupee_rotation; // -@6
//uniform vec3 famazingsurfdupee_fold; // -@6
//uniform bool famazingsurfdupee_fold_z; // -@6
//uniform float famazingsurfdupee_min_radius; // -@6
//uniform vec3 famazingsurfdupee_offset; // -@6
//uniform float famazingsurfdupee_scale; // -@6
//uniform vec2 famazingsurfdupee_fold2; // -@6
//uniform bool famazingsurfdupef_is_julia; // -@7
//uniform vec3 famazingsurfdupef_julia_c; // -@7
//uniform vec3 famazingsurfdupef_rotation; // -@7
//uniform vec3 famazingsurfdupef_fold; // -@7
//uniform bool famazingsurfdupef_fold_z; // -@7
//uniform float famazingsurfdupef_min_radius; // -@7
//uniform vec3 famazingsurfdupef_offset; // -@7
//uniform float famazingsurfdupef_scale; // -@7
//uniform vec2 famazingsurfdupef_fold2; // -@7
//uniform bool famazingsurfdupeg_is_julia; // -@8
//uniform vec3 famazingsurfdupeg_julia_c; // -@8
//uniform vec3 famazingsurfdupeg_rotation; // -@8
//uniform vec3 famazingsurfdupeg_fold; // -@8
//uniform bool famazingsurfdupeg_fold_z; // -@8
//uniform float famazingsurfdupeg_min_radius; // -@8
//uniform vec3 famazingsurfdupeg_offset; // -@8
//uniform float famazingsurfdupeg_scale; // -@8
//uniform vec2 famazingsurfdupeg_fold2; // -@8
//uniform bool famazingsurfdupeh_is_julia; // -@9
//uniform vec3 famazingsurfdupeh_julia_c; // -@9
//uniform vec3 famazingsurfdupeh_rotation; // -@9
//uniform vec3 famazingsurfdupeh_fold; // -@9
//uniform bool famazingsurfdupeh_fold_z; // -@9
//uniform float famazingsurfdupeh_min_radius; // -@9
//uniform vec3 famazingsurfdupeh_offset; // -@9
//uniform float famazingsurfdupeh_scale; // -@9
//uniform vec2 famazingsurfdupeh_fold2; // -@9
//uniform bool famazingsurfdupei_is_julia; // -@10
//uniform vec3 famazingsurfdupei_julia_c; // -@10
//uniform vec3 famazingsurfdupei_rotation; // -@10
//uniform vec3 famazingsurfdupei_fold; // -@10
//uniform bool famazingsurfdupei_fold_z; // -@10
//uniform float famazingsurfdupei_min_radius; // -@10
//uniform vec3 famazingsurfdupei_offset; // -@10
//uniform float famazingsurfdupei_scale; // -@10
//uniform vec2 famazingsurfdupei_fold2; // -@10
//uniform bool famazingsurfdupej_is_julia; // -@11
//uniform vec3 famazingsurfdupej_julia_c; // -@11
//uniform vec3 famazingsurfdupej_rotation; // -@11
//uniform vec3 famazingsurfdupej_fold; // -@11
//uniform bool famazingsurfdupej_fold_z; // -@11
//uniform float famazingsurfdupej_min_radius; // -@11
//uniform vec3 famazingsurfdupej_offset; // -@11
//uniform float famazingsurfdupej_scale; // -@11
//uniform vec2 famazingsurfdupej_fold2; // -@11
//uniform float fattractortransform_dt; // -@12
//uniform float fattractortransform_sigma; // -@12
//uniform float fattractortransform_ro; // -@12
//uniform float fattractortransform_beta; // -@12
//uniform vec2 fattractortransform_range; // -@12
//uniform float fattractortransformdupea_dt; // -@13
//uniform float fattractortransformdupea_sigma; // -@13
//uniform float fattractortransformdupea_ro; // -@13
//uniform float fattractortransformdupea_beta; // -@13
//uniform vec2 fattractortransformdupea_range; // -@13
//uniform float fattractortransformdupeb_dt; // -@14
//uniform float fattractortransformdupeb_sigma; // -@14
//uniform float fattractortransformdupeb_ro; // -@14
//uniform float fattractortransformdupeb_beta; // -@14
//uniform vec2 fattractortransformdupeb_range; // -@14
//uniform float fattractortransformdupec_dt; // -@15
//uniform float fattractortransformdupec_sigma; // -@15
//uniform float fattractortransformdupec_ro; // -@15
//uniform float fattractortransformdupec_beta; // -@15
//uniform vec2 fattractortransformdupec_range; // -@15
//uniform float fattractortransformduped_dt; // -@16
//uniform float fattractortransformduped_sigma; // -@16
//uniform float fattractortransformduped_ro; // -@16
//uniform float fattractortransformduped_beta; // -@16
//uniform vec2 fattractortransformduped_range; // -@16
//uniform float fattractortransformdupee_dt; // -@17
//uniform float fattractortransformdupee_sigma; // -@17
//uniform float fattractortransformdupee_ro; // -@17
//uniform float fattractortransformdupee_beta; // -@17
//uniform vec2 fattractortransformdupee_range; // -@17
//uniform float fattractortransformdupef_dt; // -@18
//uniform float fattractortransformdupef_sigma; // -@18
//uniform float fattractortransformdupef_ro; // -@18
//uniform float fattractortransformdupef_beta; // -@18
//uniform vec2 fattractortransformdupef_range; // -@18
//uniform float fattractortransformdupeg_dt; // -@19
//uniform float fattractortransformdupeg_sigma; // -@19
//uniform float fattractortransformdupeg_ro; // -@19
//uniform float fattractortransformdupeg_beta; // -@19
//uniform vec2 fattractortransformdupeg_range; // -@19
//uniform float fattractortransformdupeh_dt; // -@20
//uniform float fattractortransformdupeh_sigma; // -@20
//uniform float fattractortransformdupeh_ro; // -@20
//uniform float fattractortransformdupeh_beta; // -@20
//uniform vec2 fattractortransformdupeh_range; // -@20
//uniform float fattractortransformdupei_dt; // -@21
//uniform float fattractortransformdupei_sigma; // -@21
//uniform float fattractortransformdupei_ro; // -@21
//uniform float fattractortransformdupei_beta; // -@21
//uniform vec2 fattractortransformdupei_range; // -@21
//uniform float fattractortransformdupej_dt; // -@22
//uniform float fattractortransformdupej_sigma; // -@22
//uniform float fattractortransformdupej_ro; // -@22
//uniform float fattractortransformdupej_beta; // -@22
//uniform vec2 fattractortransformdupej_range; // -@22
//uniform float fbairddelta_angle; // -@23
//uniform vec3 fbairddelta_rotation1; // -@23
//uniform vec3 fbairddelta_rotation2; // -@23
//uniform float fbairddelta_scale; // -@23
//uniform float fbairddeltadupea_angle; // -@24
//uniform vec3 fbairddeltadupea_rotation1; // -@24
//uniform vec3 fbairddeltadupea_rotation2; // -@24
//uniform float fbairddeltadupea_scale; // -@24
//uniform float fbairddeltadupeb_angle; // -@25
//uniform vec3 fbairddeltadupeb_rotation1; // -@25
//uniform vec3 fbairddeltadupeb_rotation2; // -@25
//uniform float fbairddeltadupeb_scale; // -@25
//uniform float fbairddeltadupec_angle; // -@26
//uniform vec3 fbairddeltadupec_rotation1; // -@26
//uniform vec3 fbairddeltadupec_rotation2; // -@26
//uniform float fbairddeltadupec_scale; // -@26
//uniform float fbairddeltaduped_angle; // -@27
//uniform vec3 fbairddeltaduped_rotation1; // -@27
//uniform vec3 fbairddeltaduped_rotation2; // -@27
//uniform float fbairddeltaduped_scale; // -@27
//uniform float fbairddeltadupee_angle; // -@28
//uniform vec3 fbairddeltadupee_rotation1; // -@28
//uniform vec3 fbairddeltadupee_rotation2; // -@28
//uniform float fbairddeltadupee_scale; // -@28
//uniform float fbairddeltadupef_angle; // -@29
//uniform vec3 fbairddeltadupef_rotation1; // -@29
//uniform vec3 fbairddeltadupef_rotation2; // -@29
//uniform float fbairddeltadupef_scale; // -@29
//uniform float fbairddeltadupeg_angle; // -@30
//uniform vec3 fbairddeltadupeg_rotation1; // -@30
//uniform vec3 fbairddeltadupeg_rotation2; // -@30
//uniform float fbairddeltadupeg_scale; // -@30
//uniform float fbairddeltadupeh_angle; // -@31
//uniform vec3 fbairddeltadupeh_rotation1; // -@31
//uniform vec3 fbairddeltadupeh_rotation2; // -@31
//uniform float fbairddeltadupeh_scale; // -@31
//uniform float fbairddeltadupei_angle; // -@32
//uniform vec3 fbairddeltadupei_rotation1; // -@32
//uniform vec3 fbairddeltadupei_rotation2; // -@32
//uniform float fbairddeltadupei_scale; // -@32
//uniform float fbairddeltadupej_angle; // -@33
//uniform vec3 fbairddeltadupej_rotation1; // -@33
//uniform vec3 fbairddeltadupej_rotation2; // -@33
//uniform float fbairddeltadupej_scale; // -@33
//uniform vec4 fbasictransform_offset; // -@34
//uniform vec4 fbasictransform_scale; // -@34
//uniform vec2 fbasictransform_range; // -@34
//uniform vec4 fbasictransformdupea_offset; // -@35
//uniform vec4 fbasictransformdupea_scale; // -@35
//uniform vec2 fbasictransformdupea_range; // -@35
//uniform vec4 fbasictransformdupeb_offset; // -@36
//uniform vec4 fbasictransformdupeb_scale; // -@36
//uniform vec2 fbasictransformdupeb_range; // -@36
//uniform vec4 fbasictransformdupec_offset; // -@37
//uniform vec4 fbasictransformdupec_scale; // -@37
//uniform vec2 fbasictransformdupec_range; // -@37
//uniform vec4 fbasictransformduped_offset; // -@38
//uniform vec4 fbasictransformduped_scale; // -@38
//uniform vec2 fbasictransformduped_range; // -@38
//uniform vec4 fbasictransformdupee_offset; // -@39
//uniform vec4 fbasictransformdupee_scale; // -@39
//uniform vec2 fbasictransformdupee_range; // -@39
//uniform vec4 fbasictransformdupef_offset; // -@40
//uniform vec4 fbasictransformdupef_scale; // -@40
//uniform vec2 fbasictransformdupef_range; // -@40
//uniform vec4 fbasictransformdupeg_offset; // -@41
//uniform vec4 fbasictransformdupeg_scale; // -@41
//uniform vec2 fbasictransformdupeg_range; // -@41
//uniform vec4 fbasictransformdupeh_offset; // -@42
//uniform vec4 fbasictransformdupeh_scale; // -@42
//uniform vec2 fbasictransformdupeh_range; // -@42
//uniform vec4 fbasictransformdupei_offset; // -@43
//uniform vec4 fbasictransformdupei_scale; // -@43
//uniform vec2 fbasictransformdupei_range; // -@43
//uniform vec4 fbasictransformdupej_offset; // -@44
//uniform vec4 fbasictransformdupej_scale; // -@44
//uniform vec2 fbasictransformdupej_range; // -@44
//uniform bool fbenesiship_is_julia; // -@45
//uniform vec3 fbenesiship_julia_c; // -@45
//uniform bool fbenesishipdupea_is_julia; // -@46
//uniform vec3 fbenesishipdupea_julia_c; // -@46
//uniform bool fbenesishipdupeb_is_julia; // -@47
//uniform vec3 fbenesishipdupeb_julia_c; // -@47
//uniform bool fbenesishipdupec_is_julia; // -@48
//uniform vec3 fbenesishipdupec_julia_c; // -@48
//uniform bool fbenesishipduped_is_julia; // -@49
//uniform vec3 fbenesishipduped_julia_c; // -@49
//uniform bool fbenesishipdupee_is_julia; // -@50
//uniform vec3 fbenesishipdupee_julia_c; // -@50
//uniform bool fbenesishipdupef_is_julia; // -@51
//uniform vec3 fbenesishipdupef_julia_c; // -@51
//uniform bool fbenesishipdupeg_is_julia; // -@52
//uniform vec3 fbenesishipdupeg_julia_c; // -@52
//uniform bool fbenesishipdupeh_is_julia; // -@53
//uniform vec3 fbenesishipdupeh_julia_c; // -@53
//uniform bool fbenesishipdupei_is_julia; // -@54
//uniform vec3 fbenesishipdupei_julia_c; // -@54
//uniform bool fbenesishipdupej_is_julia; // -@55
//uniform vec3 fbenesishipdupej_julia_c; // -@55
//uniform bool fbristorbrot_is_julia; // -@56
//uniform vec3 fbristorbrot_julia_c; // -@56
//uniform vec3 fbristorbrot_multiply; // -@56
//uniform bool fbristorbrotdupea_is_julia; // -@57
//uniform vec3 fbristorbrotdupea_julia_c; // -@57
//uniform vec3 fbristorbrotdupea_multiply; // -@57
//uniform bool fbristorbrotdupeb_is_julia; // -@58
//uniform vec3 fbristorbrotdupeb_julia_c; // -@58
//uniform vec3 fbristorbrotdupeb_multiply; // -@58
//uniform bool fbristorbrotdupec_is_julia; // -@59
//uniform vec3 fbristorbrotdupec_julia_c; // -@59
//uniform vec3 fbristorbrotdupec_multiply; // -@59
//uniform bool fbristorbrotduped_is_julia; // -@60
//uniform vec3 fbristorbrotduped_julia_c; // -@60
//uniform vec3 fbristorbrotduped_multiply; // -@60
//uniform bool fbristorbrotdupee_is_julia; // -@61
//uniform vec3 fbristorbrotdupee_julia_c; // -@61
//uniform vec3 fbristorbrotdupee_multiply; // -@61
//uniform bool fbristorbrotdupef_is_julia; // -@62
//uniform vec3 fbristorbrotdupef_julia_c; // -@62
//uniform vec3 fbristorbrotdupef_multiply; // -@62
//uniform bool fbristorbrotdupeg_is_julia; // -@63
//uniform vec3 fbristorbrotdupeg_julia_c; // -@63
//uniform vec3 fbristorbrotdupeg_multiply; // -@63
//uniform bool fbristorbrotdupeh_is_julia; // -@64
//uniform vec3 fbristorbrotdupeh_julia_c; // -@64
//uniform vec3 fbristorbrotdupeh_multiply; // -@64
//uniform bool fbristorbrotdupei_is_julia; // -@65
//uniform vec3 fbristorbrotdupei_julia_c; // -@65
//uniform vec3 fbristorbrotdupei_multiply; // -@65
//uniform bool fbristorbrotdupej_is_julia; // -@66
//uniform vec3 fbristorbrotdupej_julia_c; // -@66
//uniform vec3 fbristorbrotdupej_multiply; // -@66
//uniform int fcellular_initial_pattern; // -@67
//uniform int fcellular_size; // -@67
//uniform int fcellular_radius; // -@67
//uniform bool fcellular_forward; // -@67
//uniform bool fcellular_reset; // -@67
//uniform int fcellulardupea_initial_pattern; // -@68
//uniform int fcellulardupea_size; // -@68
//uniform int fcellulardupea_radius; // -@68
//uniform bool fcellulardupea_forward; // -@68
//uniform bool fcellulardupea_reset; // -@68
//uniform int fcellulardupeb_initial_pattern; // -@69
//uniform int fcellulardupeb_size; // -@69
//uniform int fcellulardupeb_radius; // -@69
//uniform bool fcellulardupeb_forward; // -@69
//uniform bool fcellulardupeb_reset; // -@69
//uniform int fcellulardupec_initial_pattern; // -@70
//uniform int fcellulardupec_size; // -@70
//uniform int fcellulardupec_radius; // -@70
//uniform bool fcellulardupec_forward; // -@70
//uniform bool fcellulardupec_reset; // -@70
//uniform int fcellularduped_initial_pattern; // -@71
//uniform int fcellularduped_size; // -@71
//uniform int fcellularduped_radius; // -@71
//uniform bool fcellularduped_forward; // -@71
//uniform bool fcellularduped_reset; // -@71
//uniform int fcellulardupee_initial_pattern; // -@72
//uniform int fcellulardupee_size; // -@72
//uniform int fcellulardupee_radius; // -@72
//uniform bool fcellulardupee_forward; // -@72
//uniform bool fcellulardupee_reset; // -@72
//uniform int fcellulardupef_initial_pattern; // -@73
//uniform int fcellulardupef_size; // -@73
//uniform int fcellulardupef_radius; // -@73
//uniform bool fcellulardupef_forward; // -@73
//uniform bool fcellulardupef_reset; // -@73
//uniform int fcellulardupeg_initial_pattern; // -@74
//uniform int fcellulardupeg_size; // -@74
//uniform int fcellulardupeg_radius; // -@74
//uniform bool fcellulardupeg_forward; // -@74
//uniform bool fcellulardupeg_reset; // -@74
//uniform int fcellulardupeh_initial_pattern; // -@75
//uniform int fcellulardupeh_size; // -@75
//uniform int fcellulardupeh_radius; // -@75
//uniform bool fcellulardupeh_forward; // -@75
//uniform bool fcellulardupeh_reset; // -@75
//uniform int fcellulardupei_initial_pattern; // -@76
//uniform int fcellulardupei_size; // -@76
//uniform int fcellulardupei_radius; // -@76
//uniform bool fcellulardupei_forward; // -@76
//uniform bool fcellulardupei_reset; // -@76
//uniform int fcellulardupej_initial_pattern; // -@77
//uniform int fcellulardupej_size; // -@77
//uniform int fcellulardupej_radius; // -@77
//uniform bool fcellulardupej_forward; // -@77
//uniform bool fcellulardupej_reset; // -@77
//uniform float fcircuit_scale; // -@78
//uniform vec4 fcircuit_abs1; // -@78
//uniform vec4 fcircuit_abs2; // -@78
//uniform vec2 fcircuit_box_fold; // -@78
//uniform vec4 fcircuit_box_minus; // -@78
//uniform float fcircuitdupea_scale; // -@79
//uniform vec4 fcircuitdupea_abs1; // -@79
//uniform vec4 fcircuitdupea_abs2; // -@79
//uniform vec2 fcircuitdupea_box_fold; // -@79
//uniform vec4 fcircuitdupea_box_minus; // -@79
//uniform float fcircuitdupeb_scale; // -@80
//uniform vec4 fcircuitdupeb_abs1; // -@80
//uniform vec4 fcircuitdupeb_abs2; // -@80
//uniform vec2 fcircuitdupeb_box_fold; // -@80
//uniform vec4 fcircuitdupeb_box_minus; // -@80
//uniform float fcircuitdupec_scale; // -@81
//uniform vec4 fcircuitdupec_abs1; // -@81
//uniform vec4 fcircuitdupec_abs2; // -@81
//uniform vec2 fcircuitdupec_box_fold; // -@81
//uniform vec4 fcircuitdupec_box_minus; // -@81
//uniform float fcircuitduped_scale; // -@82
//uniform vec4 fcircuitduped_abs1; // -@82
//uniform vec4 fcircuitduped_abs2; // -@82
//uniform vec2 fcircuitduped_box_fold; // -@82
//uniform vec4 fcircuitduped_box_minus; // -@82
//uniform float fcircuitdupee_scale; // -@83
//uniform vec4 fcircuitdupee_abs1; // -@83
//uniform vec4 fcircuitdupee_abs2; // -@83
//uniform vec2 fcircuitdupee_box_fold; // -@83
//uniform vec4 fcircuitdupee_box_minus; // -@83
//uniform float fcircuitdupef_scale; // -@84
//uniform vec4 fcircuitdupef_abs1; // -@84
//uniform vec4 fcircuitdupef_abs2; // -@84
//uniform vec2 fcircuitdupef_box_fold; // -@84
//uniform vec4 fcircuitdupef_box_minus; // -@84
//uniform float fcircuitdupeg_scale; // -@85
//uniform vec4 fcircuitdupeg_abs1; // -@85
//uniform vec4 fcircuitdupeg_abs2; // -@85
//uniform vec2 fcircuitdupeg_box_fold; // -@85
//uniform vec4 fcircuitdupeg_box_minus; // -@85
//uniform float fcircuitdupeh_scale; // -@86
//uniform vec4 fcircuitdupeh_abs1; // -@86
//uniform vec4 fcircuitdupeh_abs2; // -@86
//uniform vec2 fcircuitdupeh_box_fold; // -@86
//uniform vec4 fcircuitdupeh_box_minus; // -@86
//uniform float fcircuitdupei_scale; // -@87
//uniform vec4 fcircuitdupei_abs1; // -@87
//uniform vec4 fcircuitdupei_abs2; // -@87
//uniform vec2 fcircuitdupei_box_fold; // -@87
//uniform vec4 fcircuitdupei_box_minus; // -@87
//uniform float fcircuitdupej_scale; // -@88
//uniform vec4 fcircuitdupej_abs1; // -@88
//uniform vec4 fcircuitdupej_abs2; // -@88
//uniform vec2 fcircuitdupej_box_fold; // -@88
//uniform vec4 fcircuitdupej_box_minus; // -@88
//uniform vec3 fcube_position; // -@89
//uniform vec3 fcube_size; // -@89
//uniform float fcube_roundness; // -@89
//uniform bool fcube_hollow; // -@89
//uniform float fcube_hollow_edge; // -@89
//uniform vec3 fcubedupea_position; // -@90
//uniform vec3 fcubedupea_size; // -@90
//uniform float fcubedupea_roundness; // -@90
//uniform bool fcubedupea_hollow; // -@90
//uniform float fcubedupea_hollow_edge; // -@90
//uniform vec3 fcubedupeb_position; // -@91
//uniform vec3 fcubedupeb_size; // -@91
//uniform float fcubedupeb_roundness; // -@91
//uniform bool fcubedupeb_hollow; // -@91
//uniform float fcubedupeb_hollow_edge; // -@91
//uniform vec3 fcubedupec_position; // -@92
//uniform vec3 fcubedupec_size; // -@92
//uniform float fcubedupec_roundness; // -@92
//uniform bool fcubedupec_hollow; // -@92
//uniform float fcubedupec_hollow_edge; // -@92
//uniform vec3 fcubeduped_position; // -@93
//uniform vec3 fcubeduped_size; // -@93
//uniform float fcubeduped_roundness; // -@93
//uniform bool fcubeduped_hollow; // -@93
//uniform float fcubeduped_hollow_edge; // -@93
//uniform vec3 fcubedupee_position; // -@94
//uniform vec3 fcubedupee_size; // -@94
//uniform float fcubedupee_roundness; // -@94
//uniform bool fcubedupee_hollow; // -@94
//uniform float fcubedupee_hollow_edge; // -@94
//uniform vec3 fcubedupef_position; // -@95
//uniform vec3 fcubedupef_size; // -@95
//uniform float fcubedupef_roundness; // -@95
//uniform bool fcubedupef_hollow; // -@95
//uniform float fcubedupef_hollow_edge; // -@95
//uniform vec3 fcubedupeg_position; // -@96
//uniform vec3 fcubedupeg_size; // -@96
//uniform float fcubedupeg_roundness; // -@96
//uniform bool fcubedupeg_hollow; // -@96
//uniform float fcubedupeg_hollow_edge; // -@96
//uniform vec3 fcubedupeh_position; // -@97
//uniform vec3 fcubedupeh_size; // -@97
//uniform float fcubedupeh_roundness; // -@97
//uniform bool fcubedupeh_hollow; // -@97
//uniform float fcubedupeh_hollow_edge; // -@97
//uniform vec3 fcubedupei_position; // -@98
//uniform vec3 fcubedupei_size; // -@98
//uniform float fcubedupei_roundness; // -@98
//uniform bool fcubedupei_hollow; // -@98
//uniform float fcubedupei_hollow_edge; // -@98
//uniform vec3 fcubedupej_position; // -@99
//uniform vec3 fcubedupej_size; // -@99
//uniform float fcubedupej_roundness; // -@99
//uniform bool fcubedupej_hollow; // -@99
//uniform float fcubedupej_hollow_edge; // -@99
//uniform vec3 fdodecahedron_position; // -@100
//uniform float fdodecahedron_size; // -@100
//uniform float fdodecahedron_roundness; // -@100
//uniform vec3 fdodecahedrondupea_position; // -@101
//uniform float fdodecahedrondupea_size; // -@101
//uniform float fdodecahedrondupea_roundness; // -@101
//uniform vec3 fdodecahedrondupeb_position; // -@102
//uniform float fdodecahedrondupeb_size; // -@102
//uniform float fdodecahedrondupeb_roundness; // -@102
//uniform vec3 fdodecahedrondupec_position; // -@103
//uniform float fdodecahedrondupec_size; // -@103
//uniform float fdodecahedrondupec_roundness; // -@103
//uniform vec3 fdodecahedronduped_position; // -@104
//uniform float fdodecahedronduped_size; // -@104
//uniform float fdodecahedronduped_roundness; // -@104
//uniform vec3 fdodecahedrondupee_position; // -@105
//uniform float fdodecahedrondupee_size; // -@105
//uniform float fdodecahedrondupee_roundness; // -@105
//uniform vec3 fdodecahedrondupef_position; // -@106
//uniform float fdodecahedrondupef_size; // -@106
//uniform float fdodecahedrondupef_roundness; // -@106
//uniform vec3 fdodecahedrondupeg_position; // -@107
//uniform float fdodecahedrondupeg_size; // -@107
//uniform float fdodecahedrondupeg_roundness; // -@107
//uniform vec3 fdodecahedrondupeh_position; // -@108
//uniform float fdodecahedrondupeh_size; // -@108
//uniform float fdodecahedrondupeh_roundness; // -@108
//uniform vec3 fdodecahedrondupei_position; // -@109
//uniform float fdodecahedrondupei_size; // -@109
//uniform float fdodecahedrondupei_roundness; // -@109
//uniform vec3 fdodecahedrondupej_position; // -@110
//uniform float fdodecahedrondupej_size; // -@110
//uniform float fdodecahedrondupej_roundness; // -@110
//uniform float fgemstone_scale; // -@111
//uniform vec3 fgemstone_clamp; // -@111
//uniform vec3 fgemstone_offset; // -@111
//uniform float fgemstonedupea_scale; // -@112
//uniform vec3 fgemstonedupea_clamp; // -@112
//uniform vec3 fgemstonedupea_offset; // -@112
//uniform float fgemstonedupeb_scale; // -@113
//uniform vec3 fgemstonedupeb_clamp; // -@113
//uniform vec3 fgemstonedupeb_offset; // -@113
//uniform float fgemstonedupec_scale; // -@114
//uniform vec3 fgemstonedupec_clamp; // -@114
//uniform vec3 fgemstonedupec_offset; // -@114
//uniform float fgemstoneduped_scale; // -@115
//uniform vec3 fgemstoneduped_clamp; // -@115
//uniform vec3 fgemstoneduped_offset; // -@115
//uniform float fgemstonedupee_scale; // -@116
//uniform vec3 fgemstonedupee_clamp; // -@116
//uniform vec3 fgemstonedupee_offset; // -@116
//uniform float fgemstonedupef_scale; // -@117
//uniform vec3 fgemstonedupef_clamp; // -@117
//uniform vec3 fgemstonedupef_offset; // -@117
//uniform float fgemstonedupeg_scale; // -@118
//uniform vec3 fgemstonedupeg_clamp; // -@118
//uniform vec3 fgemstonedupeg_offset; // -@118
//uniform float fgemstonedupeh_scale; // -@119
//uniform vec3 fgemstonedupeh_clamp; // -@119
//uniform vec3 fgemstonedupeh_offset; // -@119
//uniform float fgemstonedupei_scale; // -@120
//uniform vec3 fgemstonedupei_clamp; // -@120
//uniform vec3 fgemstonedupei_offset; // -@120
//uniform float fgemstonedupej_scale; // -@121
//uniform vec3 fgemstonedupej_clamp; // -@121
//uniform vec3 fgemstonedupej_offset; // -@121
//uniform vec3 fgyroid_position; // -@122
//uniform float fgyroid_scale; // -@122
//uniform float fgyroid_sphere_radius; // -@122
//uniform float fgyroid_time; // -@122
//uniform float fgyroid_thickness; // -@122
//uniform float fgyroid_bias; // -@122
//uniform vec4 fgyroid_control; // -@122
//uniform vec2 fgyroid_offset; // -@122
//uniform bool fgyroid_oriented; // -@122
//uniform bool fgyroid_abs; // -@122
//uniform vec3 fgyroiddupea_position; // -@123
//uniform float fgyroiddupea_scale; // -@123
//uniform float fgyroiddupea_sphere_radius; // -@123
//uniform float fgyroiddupea_time; // -@123
//uniform float fgyroiddupea_thickness; // -@123
//uniform float fgyroiddupea_bias; // -@123
//uniform vec4 fgyroiddupea_control; // -@123
//uniform vec2 fgyroiddupea_offset; // -@123
//uniform bool fgyroiddupea_oriented; // -@123
//uniform bool fgyroiddupea_abs; // -@123
//uniform vec3 fgyroiddupeb_position; // -@124
//uniform float fgyroiddupeb_scale; // -@124
//uniform float fgyroiddupeb_sphere_radius; // -@124
//uniform float fgyroiddupeb_time; // -@124
//uniform float fgyroiddupeb_thickness; // -@124
//uniform float fgyroiddupeb_bias; // -@124
//uniform vec4 fgyroiddupeb_control; // -@124
//uniform vec2 fgyroiddupeb_offset; // -@124
//uniform bool fgyroiddupeb_oriented; // -@124
//uniform bool fgyroiddupeb_abs; // -@124
//uniform vec3 fgyroiddupec_position; // -@125
//uniform float fgyroiddupec_scale; // -@125
//uniform float fgyroiddupec_sphere_radius; // -@125
//uniform float fgyroiddupec_time; // -@125
//uniform float fgyroiddupec_thickness; // -@125
//uniform float fgyroiddupec_bias; // -@125
//uniform vec4 fgyroiddupec_control; // -@125
//uniform vec2 fgyroiddupec_offset; // -@125
//uniform bool fgyroiddupec_oriented; // -@125
//uniform bool fgyroiddupec_abs; // -@125
//uniform vec3 fgyroidduped_position; // -@126
//uniform float fgyroidduped_scale; // -@126
//uniform float fgyroidduped_sphere_radius; // -@126
//uniform float fgyroidduped_time; // -@126
//uniform float fgyroidduped_thickness; // -@126
//uniform float fgyroidduped_bias; // -@126
//uniform vec4 fgyroidduped_control; // -@126
//uniform vec2 fgyroidduped_offset; // -@126
//uniform bool fgyroidduped_oriented; // -@126
//uniform bool fgyroidduped_abs; // -@126
//uniform vec3 fgyroiddupee_position; // -@127
//uniform float fgyroiddupee_scale; // -@127
//uniform float fgyroiddupee_sphere_radius; // -@127
//uniform float fgyroiddupee_time; // -@127
//uniform float fgyroiddupee_thickness; // -@127
//uniform float fgyroiddupee_bias; // -@127
//uniform vec4 fgyroiddupee_control; // -@127
//uniform vec2 fgyroiddupee_offset; // -@127
//uniform bool fgyroiddupee_oriented; // -@127
//uniform bool fgyroiddupee_abs; // -@127
//uniform vec3 fgyroiddupef_position; // -@128
//uniform float fgyroiddupef_scale; // -@128
//uniform float fgyroiddupef_sphere_radius; // -@128
//uniform float fgyroiddupef_time; // -@128
//uniform float fgyroiddupef_thickness; // -@128
//uniform float fgyroiddupef_bias; // -@128
//uniform vec4 fgyroiddupef_control; // -@128
//uniform vec2 fgyroiddupef_offset; // -@128
//uniform bool fgyroiddupef_oriented; // -@128
//uniform bool fgyroiddupef_abs; // -@128
//uniform vec3 fgyroiddupeg_position; // -@129
//uniform float fgyroiddupeg_scale; // -@129
//uniform float fgyroiddupeg_sphere_radius; // -@129
//uniform float fgyroiddupeg_time; // -@129
//uniform float fgyroiddupeg_thickness; // -@129
//uniform float fgyroiddupeg_bias; // -@129
//uniform vec4 fgyroiddupeg_control; // -@129
//uniform vec2 fgyroiddupeg_offset; // -@129
//uniform bool fgyroiddupeg_oriented; // -@129
//uniform bool fgyroiddupeg_abs; // -@129
//uniform vec3 fgyroiddupeh_position; // -@130
//uniform float fgyroiddupeh_scale; // -@130
//uniform float fgyroiddupeh_sphere_radius; // -@130
//uniform float fgyroiddupeh_time; // -@130
//uniform float fgyroiddupeh_thickness; // -@130
//uniform float fgyroiddupeh_bias; // -@130
//uniform vec4 fgyroiddupeh_control; // -@130
//uniform vec2 fgyroiddupeh_offset; // -@130
//uniform bool fgyroiddupeh_oriented; // -@130
//uniform bool fgyroiddupeh_abs; // -@130
//uniform vec3 fgyroiddupei_position; // -@131
//uniform float fgyroiddupei_scale; // -@131
//uniform float fgyroiddupei_sphere_radius; // -@131
//uniform float fgyroiddupei_time; // -@131
//uniform float fgyroiddupei_thickness; // -@131
//uniform float fgyroiddupei_bias; // -@131
//uniform vec4 fgyroiddupei_control; // -@131
//uniform vec2 fgyroiddupei_offset; // -@131
//uniform bool fgyroiddupei_oriented; // -@131
//uniform bool fgyroiddupei_abs; // -@131
//uniform vec3 fgyroiddupej_position; // -@132
//uniform float fgyroiddupej_scale; // -@132
//uniform float fgyroiddupej_sphere_radius; // -@132
//uniform float fgyroiddupej_time; // -@132
//uniform float fgyroiddupej_thickness; // -@132
//uniform float fgyroiddupej_bias; // -@132
//uniform vec4 fgyroiddupej_control; // -@132
//uniform vec2 fgyroiddupej_offset; // -@132
//uniform bool fgyroiddupej_oriented; // -@132
//uniform bool fgyroiddupej_abs; // -@132
//uniform float fhollowtetrahedron_scale; // -@133
//uniform float fhollowtetrahedron_thickness; // -@133
//uniform vec3 fhollowtetrahedron_offset; // -@133
//uniform float fhollowtetrahedrondupea_scale; // -@134
//uniform float fhollowtetrahedrondupea_thickness; // -@134
//uniform vec3 fhollowtetrahedrondupea_offset; // -@134
//uniform float fhollowtetrahedrondupeb_scale; // -@135
//uniform float fhollowtetrahedrondupeb_thickness; // -@135
//uniform vec3 fhollowtetrahedrondupeb_offset; // -@135
//uniform float fhollowtetrahedrondupec_scale; // -@136
//uniform float fhollowtetrahedrondupec_thickness; // -@136
//uniform vec3 fhollowtetrahedrondupec_offset; // -@136
//uniform float fhollowtetrahedronduped_scale; // -@137
//uniform float fhollowtetrahedronduped_thickness; // -@137
//uniform vec3 fhollowtetrahedronduped_offset; // -@137
//uniform float fhollowtetrahedrondupee_scale; // -@138
//uniform float fhollowtetrahedrondupee_thickness; // -@138
//uniform vec3 fhollowtetrahedrondupee_offset; // -@138
//uniform float fhollowtetrahedrondupef_scale; // -@139
//uniform float fhollowtetrahedrondupef_thickness; // -@139
//uniform vec3 fhollowtetrahedrondupef_offset; // -@139
//uniform float fhollowtetrahedrondupeg_scale; // -@140
//uniform float fhollowtetrahedrondupeg_thickness; // -@140
//uniform vec3 fhollowtetrahedrondupeg_offset; // -@140
//uniform float fhollowtetrahedrondupeh_scale; // -@141
//uniform float fhollowtetrahedrondupeh_thickness; // -@141
//uniform vec3 fhollowtetrahedrondupeh_offset; // -@141
//uniform float fhollowtetrahedrondupei_scale; // -@142
//uniform float fhollowtetrahedrondupei_thickness; // -@142
//uniform vec3 fhollowtetrahedrondupei_offset; // -@142
//uniform float fhollowtetrahedrondupej_scale; // -@143
//uniform float fhollowtetrahedrondupej_thickness; // -@143
//uniform vec3 fhollowtetrahedrondupej_offset; // -@143
//uniform vec3 ficosahedron_position; // -@144
//uniform float ficosahedron_size; // -@144
//uniform vec3 ficosahedrondupea_position; // -@145
//uniform float ficosahedrondupea_size; // -@145
//uniform vec3 ficosahedrondupeb_position; // -@146
//uniform float ficosahedrondupeb_size; // -@146
//uniform vec3 ficosahedrondupec_position; // -@147
//uniform float ficosahedrondupec_size; // -@147
//uniform vec3 ficosahedronduped_position; // -@148
//uniform float ficosahedronduped_size; // -@148
//uniform vec3 ficosahedrondupee_position; // -@149
//uniform float ficosahedrondupee_size; // -@149
//uniform vec3 ficosahedrondupef_position; // -@150
//uniform float ficosahedrondupef_size; // -@150
//uniform vec3 ficosahedrondupeg_position; // -@151
//uniform float ficosahedrondupeg_size; // -@151
//uniform vec3 ficosahedrondupeh_position; // -@152
//uniform float ficosahedrondupeh_size; // -@152
//uniform vec3 ficosahedrondupei_position; // -@153
//uniform float ficosahedrondupei_size; // -@153
//uniform vec3 ficosahedrondupej_position; // -@154
//uniform float ficosahedrondupej_size; // -@154
//uniform float finversebox_scale; // -@155
//uniform float finversebox_thickness; // -@155
//uniform vec3 finversebox_offset; // -@155
//uniform float finverseboxdupea_scale; // -@156
//uniform float finverseboxdupea_thickness; // -@156
//uniform vec3 finverseboxdupea_offset; // -@156
//uniform float finverseboxdupeb_scale; // -@157
//uniform float finverseboxdupeb_thickness; // -@157
//uniform vec3 finverseboxdupeb_offset; // -@157
//uniform float finverseboxdupec_scale; // -@158
//uniform float finverseboxdupec_thickness; // -@158
//uniform vec3 finverseboxdupec_offset; // -@158
//uniform float finverseboxduped_scale; // -@159
//uniform float finverseboxduped_thickness; // -@159
//uniform vec3 finverseboxduped_offset; // -@159
//uniform float finverseboxdupee_scale; // -@160
//uniform float finverseboxdupee_thickness; // -@160
//uniform vec3 finverseboxdupee_offset; // -@160
//uniform float finverseboxdupef_scale; // -@161
//uniform float finverseboxdupef_thickness; // -@161
//uniform vec3 finverseboxdupef_offset; // -@161
//uniform float finverseboxdupeg_scale; // -@162
//uniform float finverseboxdupeg_thickness; // -@162
//uniform vec3 finverseboxdupeg_offset; // -@162
//uniform float finverseboxdupeh_scale; // -@163
//uniform float finverseboxdupeh_thickness; // -@163
//uniform vec3 finverseboxdupeh_offset; // -@163
//uniform float finverseboxdupei_scale; // -@164
//uniform float finverseboxdupei_thickness; // -@164
//uniform vec3 finverseboxdupei_offset; // -@164
//uniform float finverseboxdupej_scale; // -@165
//uniform float finverseboxdupej_thickness; // -@165
//uniform vec3 finverseboxdupej_offset; // -@165
//uniform vec4 finversiontransform_sphere; // -@166
//uniform vec2 finversiontransform_range; // -@166
//uniform vec4 finversiontransformdupea_sphere; // -@167
//uniform vec2 finversiontransformdupea_range; // -@167
//uniform vec4 finversiontransformdupeb_sphere; // -@168
//uniform vec2 finversiontransformdupeb_range; // -@168
//uniform vec4 finversiontransformdupec_sphere; // -@169
//uniform vec2 finversiontransformdupec_range; // -@169
//uniform vec4 finversiontransformduped_sphere; // -@170
//uniform vec2 finversiontransformduped_range; // -@170
//uniform vec4 finversiontransformdupee_sphere; // -@171
//uniform vec2 finversiontransformdupee_range; // -@171
//uniform vec4 finversiontransformdupef_sphere; // -@172
//uniform vec2 finversiontransformdupef_range; // -@172
//uniform vec4 finversiontransformdupeg_sphere; // -@173
//uniform vec2 finversiontransformdupeg_range; // -@173
//uniform vec4 finversiontransformdupeh_sphere; // -@174
//uniform vec2 finversiontransformdupeh_range; // -@174
//uniform vec4 finversiontransformdupei_sphere; // -@175
//uniform vec2 finversiontransformdupei_range; // -@175
//uniform vec4 finversiontransformdupej_sphere; // -@176
//uniform vec2 finversiontransformdupej_range; // -@176
//uniform vec2 fjerusalemcube_scale; // -@177
//uniform vec3 fjerusalemcube_offset; // -@177
//uniform vec3 fjerusalemcube_rotation1; // -@177
//uniform vec3 fjerusalemcube_rotation2; // -@177
//uniform vec3 fjerusalemcube_abs_add; // -@177
//uniform vec3 fjerusalemcube_abs_minus; // -@177
//uniform vec2 fjerusalemcubedupea_scale; // -@178
//uniform vec3 fjerusalemcubedupea_offset; // -@178
//uniform vec3 fjerusalemcubedupea_rotation1; // -@178
//uniform vec3 fjerusalemcubedupea_rotation2; // -@178
//uniform vec3 fjerusalemcubedupea_abs_add; // -@178
//uniform vec3 fjerusalemcubedupea_abs_minus; // -@178
//uniform vec2 fjerusalemcubedupeb_scale; // -@179
//uniform vec3 fjerusalemcubedupeb_offset; // -@179
//uniform vec3 fjerusalemcubedupeb_rotation1; // -@179
//uniform vec3 fjerusalemcubedupeb_rotation2; // -@179
//uniform vec3 fjerusalemcubedupeb_abs_add; // -@179
//uniform vec3 fjerusalemcubedupeb_abs_minus; // -@179
//uniform vec2 fjerusalemcubedupec_scale; // -@180
//uniform vec3 fjerusalemcubedupec_offset; // -@180
//uniform vec3 fjerusalemcubedupec_rotation1; // -@180
//uniform vec3 fjerusalemcubedupec_rotation2; // -@180
//uniform vec3 fjerusalemcubedupec_abs_add; // -@180
//uniform vec3 fjerusalemcubedupec_abs_minus; // -@180
//uniform vec2 fjerusalemcubeduped_scale; // -@181
//uniform vec3 fjerusalemcubeduped_offset; // -@181
//uniform vec3 fjerusalemcubeduped_rotation1; // -@181
//uniform vec3 fjerusalemcubeduped_rotation2; // -@181
//uniform vec3 fjerusalemcubeduped_abs_add; // -@181
//uniform vec3 fjerusalemcubeduped_abs_minus; // -@181
//uniform vec2 fjerusalemcubedupee_scale; // -@182
//uniform vec3 fjerusalemcubedupee_offset; // -@182
//uniform vec3 fjerusalemcubedupee_rotation1; // -@182
//uniform vec3 fjerusalemcubedupee_rotation2; // -@182
//uniform vec3 fjerusalemcubedupee_abs_add; // -@182
//uniform vec3 fjerusalemcubedupee_abs_minus; // -@182
//uniform vec2 fjerusalemcubedupef_scale; // -@183
//uniform vec3 fjerusalemcubedupef_offset; // -@183
//uniform vec3 fjerusalemcubedupef_rotation1; // -@183
//uniform vec3 fjerusalemcubedupef_rotation2; // -@183
//uniform vec3 fjerusalemcubedupef_abs_add; // -@183
//uniform vec3 fjerusalemcubedupef_abs_minus; // -@183
//uniform vec2 fjerusalemcubedupeg_scale; // -@184
//uniform vec3 fjerusalemcubedupeg_offset; // -@184
//uniform vec3 fjerusalemcubedupeg_rotation1; // -@184
//uniform vec3 fjerusalemcubedupeg_rotation2; // -@184
//uniform vec3 fjerusalemcubedupeg_abs_add; // -@184
//uniform vec3 fjerusalemcubedupeg_abs_minus; // -@184
//uniform vec2 fjerusalemcubedupeh_scale; // -@185
//uniform vec3 fjerusalemcubedupeh_offset; // -@185
//uniform vec3 fjerusalemcubedupeh_rotation1; // -@185
//uniform vec3 fjerusalemcubedupeh_rotation2; // -@185
//uniform vec3 fjerusalemcubedupeh_abs_add; // -@185
//uniform vec3 fjerusalemcubedupeh_abs_minus; // -@185
//uniform vec2 fjerusalemcubedupei_scale; // -@186
//uniform vec3 fjerusalemcubedupei_offset; // -@186
//uniform vec3 fjerusalemcubedupei_rotation1; // -@186
//uniform vec3 fjerusalemcubedupei_rotation2; // -@186
//uniform vec3 fjerusalemcubedupei_abs_add; // -@186
//uniform vec3 fjerusalemcubedupei_abs_minus; // -@186
//uniform vec2 fjerusalemcubedupej_scale; // -@187
//uniform vec3 fjerusalemcubedupej_offset; // -@187
//uniform vec3 fjerusalemcubedupej_rotation1; // -@187
//uniform vec3 fjerusalemcubedupej_rotation2; // -@187
//uniform vec3 fjerusalemcubedupej_abs_add; // -@187
//uniform vec3 fjerusalemcubedupej_abs_minus; // -@187
//uniform int fkalaidotransform_axis; // -@188
//uniform int fkalaidotransform_mode; // -@188
//uniform float fkalaidotransform_symmetry; // -@188
//uniform vec2 fkalaidotransform_range; // -@188
//uniform int fkalaidotransformdupea_axis; // -@189
//uniform int fkalaidotransformdupea_mode; // -@189
//uniform float fkalaidotransformdupea_symmetry; // -@189
//uniform vec2 fkalaidotransformdupea_range; // -@189
//uniform int fkalaidotransformdupeb_axis; // -@190
//uniform int fkalaidotransformdupeb_mode; // -@190
//uniform float fkalaidotransformdupeb_symmetry; // -@190
//uniform vec2 fkalaidotransformdupeb_range; // -@190
//uniform int fkalaidotransformdupec_axis; // -@191
//uniform int fkalaidotransformdupec_mode; // -@191
//uniform float fkalaidotransformdupec_symmetry; // -@191
//uniform vec2 fkalaidotransformdupec_range; // -@191
//uniform int fkalaidotransformduped_axis; // -@192
//uniform int fkalaidotransformduped_mode; // -@192
//uniform float fkalaidotransformduped_symmetry; // -@192
//uniform vec2 fkalaidotransformduped_range; // -@192
//uniform int fkalaidotransformdupee_axis; // -@193
//uniform int fkalaidotransformdupee_mode; // -@193
//uniform float fkalaidotransformdupee_symmetry; // -@193
//uniform vec2 fkalaidotransformdupee_range; // -@193
//uniform int fkalaidotransformdupef_axis; // -@194
//uniform int fkalaidotransformdupef_mode; // -@194
//uniform float fkalaidotransformdupef_symmetry; // -@194
//uniform vec2 fkalaidotransformdupef_range; // -@194
//uniform int fkalaidotransformdupeg_axis; // -@195
//uniform int fkalaidotransformdupeg_mode; // -@195
//uniform float fkalaidotransformdupeg_symmetry; // -@195
//uniform vec2 fkalaidotransformdupeg_range; // -@195
//uniform int fkalaidotransformdupeh_axis; // -@196
//uniform int fkalaidotransformdupeh_mode; // -@196
//uniform float fkalaidotransformdupeh_symmetry; // -@196
//uniform vec2 fkalaidotransformdupeh_range; // -@196
//uniform int fkalaidotransformdupei_axis; // -@197
//uniform int fkalaidotransformdupei_mode; // -@197
//uniform float fkalaidotransformdupei_symmetry; // -@197
//uniform vec2 fkalaidotransformdupei_range; // -@197
//uniform int fkalaidotransformdupej_axis; // -@198
//uniform int fkalaidotransformdupej_mode; // -@198
//uniform float fkalaidotransformdupej_symmetry; // -@198
//uniform vec2 fkalaidotransformdupej_range; // -@198
//uniform float fkalibox_scale; // -@199
//uniform vec3 fkalibox_offset1; // -@199
//uniform vec3 fkalibox_offset2; // -@199
//uniform float fkaliboxdupea_scale; // -@200
//uniform vec3 fkaliboxdupea_offset1; // -@200
//uniform vec3 fkaliboxdupea_offset2; // -@200
//uniform float fkaliboxdupeb_scale; // -@201
//uniform vec3 fkaliboxdupeb_offset1; // -@201
//uniform vec3 fkaliboxdupeb_offset2; // -@201
//uniform float fkaliboxdupec_scale; // -@202
//uniform vec3 fkaliboxdupec_offset1; // -@202
//uniform vec3 fkaliboxdupec_offset2; // -@202
//uniform float fkaliboxduped_scale; // -@203
//uniform vec3 fkaliboxduped_offset1; // -@203
//uniform vec3 fkaliboxduped_offset2; // -@203
//uniform float fkaliboxdupee_scale; // -@204
//uniform vec3 fkaliboxdupee_offset1; // -@204
//uniform vec3 fkaliboxdupee_offset2; // -@204
//uniform float fkaliboxdupef_scale; // -@205
//uniform vec3 fkaliboxdupef_offset1; // -@205
//uniform vec3 fkaliboxdupef_offset2; // -@205
//uniform float fkaliboxdupeg_scale; // -@206
//uniform vec3 fkaliboxdupeg_offset1; // -@206
//uniform vec3 fkaliboxdupeg_offset2; // -@206
//uniform float fkaliboxdupeh_scale; // -@207
//uniform vec3 fkaliboxdupeh_offset1; // -@207
//uniform vec3 fkaliboxdupeh_offset2; // -@207
//uniform float fkaliboxdupei_scale; // -@208
//uniform vec3 fkaliboxdupei_offset1; // -@208
//uniform vec3 fkaliboxdupei_offset2; // -@208
//uniform float fkaliboxdupej_scale; // -@209
//uniform vec3 fkaliboxdupej_offset1; // -@209
//uniform vec3 fkaliboxdupej_offset2; // -@209
//uniform vec3 fkaliliving_c; // -@210
//uniform vec3 fkaliliving_rotation1; // -@210
//uniform vec3 fkaliliving_rotation2; // -@210
//uniform float fkaliliving_scale; // -@210
//uniform vec3 fkalilivingdupea_c; // -@211
//uniform vec3 fkalilivingdupea_rotation1; // -@211
//uniform vec3 fkalilivingdupea_rotation2; // -@211
//uniform float fkalilivingdupea_scale; // -@211
//uniform vec3 fkalilivingdupeb_c; // -@212
//uniform vec3 fkalilivingdupeb_rotation1; // -@212
//uniform vec3 fkalilivingdupeb_rotation2; // -@212
//uniform float fkalilivingdupeb_scale; // -@212
//uniform vec3 fkalilivingdupec_c; // -@213
//uniform vec3 fkalilivingdupec_rotation1; // -@213
//uniform vec3 fkalilivingdupec_rotation2; // -@213
//uniform float fkalilivingdupec_scale; // -@213
//uniform vec3 fkalilivingduped_c; // -@214
//uniform vec3 fkalilivingduped_rotation1; // -@214
//uniform vec3 fkalilivingduped_rotation2; // -@214
//uniform float fkalilivingduped_scale; // -@214
//uniform vec3 fkalilivingdupee_c; // -@215
//uniform vec3 fkalilivingdupee_rotation1; // -@215
//uniform vec3 fkalilivingdupee_rotation2; // -@215
//uniform float fkalilivingdupee_scale; // -@215
//uniform vec3 fkalilivingdupef_c; // -@216
//uniform vec3 fkalilivingdupef_rotation1; // -@216
//uniform vec3 fkalilivingdupef_rotation2; // -@216
//uniform float fkalilivingdupef_scale; // -@216
//uniform vec3 fkalilivingdupeg_c; // -@217
//uniform vec3 fkalilivingdupeg_rotation1; // -@217
//uniform vec3 fkalilivingdupeg_rotation2; // -@217
//uniform float fkalilivingdupeg_scale; // -@217
//uniform vec3 fkalilivingdupeh_c; // -@218
//uniform vec3 fkalilivingdupeh_rotation1; // -@218
//uniform vec3 fkalilivingdupeh_rotation2; // -@218
//uniform float fkalilivingdupeh_scale; // -@218
//uniform vec3 fkalilivingdupei_c; // -@219
//uniform vec3 fkalilivingdupei_rotation1; // -@219
//uniform vec3 fkalilivingdupei_rotation2; // -@219
//uniform float fkalilivingdupei_scale; // -@219
//uniform vec3 fkalilivingdupej_c; // -@220
//uniform vec3 fkalilivingdupej_rotation1; // -@220
//uniform vec3 fkalilivingdupej_rotation2; // -@220
//uniform float fkalilivingdupej_scale; // -@220
//uniform vec4 fkaliredux_folds; // -@221
//uniform vec3 fkaliredux_minus; // -@221
//uniform float fkaliredux_scale; // -@221
//uniform vec4 fkalireduxdupea_folds; // -@222
//uniform vec3 fkalireduxdupea_minus; // -@222
//uniform float fkalireduxdupea_scale; // -@222
//uniform vec4 fkalireduxdupeb_folds; // -@223
//uniform vec3 fkalireduxdupeb_minus; // -@223
//uniform float fkalireduxdupeb_scale; // -@223
//uniform vec4 fkalireduxdupec_folds; // -@224
//uniform vec3 fkalireduxdupec_minus; // -@224
//uniform float fkalireduxdupec_scale; // -@224
//uniform vec4 fkalireduxduped_folds; // -@225
//uniform vec3 fkalireduxduped_minus; // -@225
//uniform float fkalireduxduped_scale; // -@225
//uniform vec4 fkalireduxdupee_folds; // -@226
//uniform vec3 fkalireduxdupee_minus; // -@226
//uniform float fkalireduxdupee_scale; // -@226
//uniform vec4 fkalireduxdupef_folds; // -@227
//uniform vec3 fkalireduxdupef_minus; // -@227
//uniform float fkalireduxdupef_scale; // -@227
//uniform vec4 fkalireduxdupeg_folds; // -@228
//uniform vec3 fkalireduxdupeg_minus; // -@228
//uniform float fkalireduxdupeg_scale; // -@228
//uniform vec4 fkalireduxdupeh_folds; // -@229
//uniform vec3 fkalireduxdupeh_minus; // -@229
//uniform float fkalireduxdupeh_scale; // -@229
//uniform vec4 fkalireduxdupei_folds; // -@230
//uniform vec3 fkalireduxdupei_minus; // -@230
//uniform float fkalireduxdupei_scale; // -@230
//uniform vec4 fkalireduxdupej_folds; // -@231
//uniform vec3 fkalireduxdupej_minus; // -@231
//uniform float fkalireduxdupej_scale; // -@231
//uniform bool fklenian_show_balls; // -@232
//uniform float fklenian_x; // -@232
//uniform float fklenian_y; // -@232
//uniform float fklenian_box_size_x; // -@232
//uniform float fklenian_box_size_z; // -@232
//uniform bool fkleniandupea_show_balls; // -@233
//uniform float fkleniandupea_x; // -@233
//uniform float fkleniandupea_y; // -@233
//uniform float fkleniandupea_box_size_x; // -@233
//uniform float fkleniandupea_box_size_z; // -@233
//uniform bool fkleniandupeb_show_balls; // -@234
//uniform float fkleniandupeb_x; // -@234
//uniform float fkleniandupeb_y; // -@234
//uniform float fkleniandupeb_box_size_x; // -@234
//uniform float fkleniandupeb_box_size_z; // -@234
//uniform bool fkleniandupec_show_balls; // -@235
//uniform float fkleniandupec_x; // -@235
//uniform float fkleniandupec_y; // -@235
//uniform float fkleniandupec_box_size_x; // -@235
//uniform float fkleniandupec_box_size_z; // -@235
//uniform bool fklenianduped_show_balls; // -@236
//uniform float fklenianduped_x; // -@236
//uniform float fklenianduped_y; // -@236
//uniform float fklenianduped_box_size_x; // -@236
//uniform float fklenianduped_box_size_z; // -@236
//uniform bool fkleniandupee_show_balls; // -@237
//uniform float fkleniandupee_x; // -@237
//uniform float fkleniandupee_y; // -@237
//uniform float fkleniandupee_box_size_x; // -@237
//uniform float fkleniandupee_box_size_z; // -@237
//uniform bool fkleniandupef_show_balls; // -@238
//uniform float fkleniandupef_x; // -@238
//uniform float fkleniandupef_y; // -@238
//uniform float fkleniandupef_box_size_x; // -@238
//uniform float fkleniandupef_box_size_z; // -@238
//uniform bool fkleniandupeg_show_balls; // -@239
//uniform float fkleniandupeg_x; // -@239
//uniform float fkleniandupeg_y; // -@239
//uniform float fkleniandupeg_box_size_x; // -@239
//uniform float fkleniandupeg_box_size_z; // -@239
//uniform bool fkleniandupeh_show_balls; // -@240
//uniform float fkleniandupeh_x; // -@240
//uniform float fkleniandupeh_y; // -@240
//uniform float fkleniandupeh_box_size_x; // -@240
//uniform float fkleniandupeh_box_size_z; // -@240
//uniform bool fkleniandupei_show_balls; // -@241
//uniform float fkleniandupei_x; // -@241
//uniform float fkleniandupei_y; // -@241
//uniform float fkleniandupei_box_size_x; // -@241
//uniform float fkleniandupei_box_size_z; // -@241
//uniform bool fkleniandupej_show_balls; // -@242
//uniform float fkleniandupej_x; // -@242
//uniform float fkleniandupej_y; // -@242
//uniform float fkleniandupej_box_size_x; // -@242
//uniform float fkleniandupej_box_size_z; // -@242
//uniform float fkochcube_scale; // -@243
//uniform int fkochcube_variant; // -@243
//uniform bool fkochcube_first_zrev; // -@243
//uniform bool fkochcube_pxyzminuss; // -@243
//uniform bool fkochcube_psortsymmetry1; // -@243
//uniform bool fkochcube_psortsymmetry2; // -@243
//uniform bool fkochcube_foldzbefore; // -@243
//uniform bool fkochcube_abs_x; // -@243
//uniform bool fkochcube_abs_y; // -@243
//uniform bool fkochcube_abs_z; // -@243
//uniform int fkochcube_fold1; // -@243
//uniform int fkochcube_fold2; // -@243
//uniform bool fkochcube_fold3; // -@243
//uniform bool fkochcube_fold4; // -@243
//uniform bool fkochcube_reflection; // -@243
//uniform vec3 fkochcube_rotation1; // -@243
//uniform vec3 fkochcube_rotation2; // -@243
//uniform float fkochcubedupea_scale; // -@244
//uniform int fkochcubedupea_variant; // -@244
//uniform bool fkochcubedupea_first_zrev; // -@244
//uniform bool fkochcubedupea_pxyzminuss; // -@244
//uniform bool fkochcubedupea_psortsymmetry1; // -@244
//uniform bool fkochcubedupea_psortsymmetry2; // -@244
//uniform bool fkochcubedupea_foldzbefore; // -@244
//uniform bool fkochcubedupea_abs_x; // -@244
//uniform bool fkochcubedupea_abs_y; // -@244
//uniform bool fkochcubedupea_abs_z; // -@244
//uniform int fkochcubedupea_fold1; // -@244
//uniform int fkochcubedupea_fold2; // -@244
//uniform bool fkochcubedupea_fold3; // -@244
//uniform bool fkochcubedupea_fold4; // -@244
//uniform bool fkochcubedupea_reflection; // -@244
//uniform vec3 fkochcubedupea_rotation1; // -@244
//uniform vec3 fkochcubedupea_rotation2; // -@244
//uniform float fkochcubedupeb_scale; // -@245
//uniform int fkochcubedupeb_variant; // -@245
//uniform bool fkochcubedupeb_first_zrev; // -@245
//uniform bool fkochcubedupeb_pxyzminuss; // -@245
//uniform bool fkochcubedupeb_psortsymmetry1; // -@245
//uniform bool fkochcubedupeb_psortsymmetry2; // -@245
//uniform bool fkochcubedupeb_foldzbefore; // -@245
//uniform bool fkochcubedupeb_abs_x; // -@245
//uniform bool fkochcubedupeb_abs_y; // -@245
//uniform bool fkochcubedupeb_abs_z; // -@245
//uniform int fkochcubedupeb_fold1; // -@245
//uniform int fkochcubedupeb_fold2; // -@245
//uniform bool fkochcubedupeb_fold3; // -@245
//uniform bool fkochcubedupeb_fold4; // -@245
//uniform bool fkochcubedupeb_reflection; // -@245
//uniform vec3 fkochcubedupeb_rotation1; // -@245
//uniform vec3 fkochcubedupeb_rotation2; // -@245
//uniform float fkochcubedupec_scale; // -@246
//uniform int fkochcubedupec_variant; // -@246
//uniform bool fkochcubedupec_first_zrev; // -@246
//uniform bool fkochcubedupec_pxyzminuss; // -@246
//uniform bool fkochcubedupec_psortsymmetry1; // -@246
//uniform bool fkochcubedupec_psortsymmetry2; // -@246
//uniform bool fkochcubedupec_foldzbefore; // -@246
//uniform bool fkochcubedupec_abs_x; // -@246
//uniform bool fkochcubedupec_abs_y; // -@246
//uniform bool fkochcubedupec_abs_z; // -@246
//uniform int fkochcubedupec_fold1; // -@246
//uniform int fkochcubedupec_fold2; // -@246
//uniform bool fkochcubedupec_fold3; // -@246
//uniform bool fkochcubedupec_fold4; // -@246
//uniform bool fkochcubedupec_reflection; // -@246
//uniform vec3 fkochcubedupec_rotation1; // -@246
//uniform vec3 fkochcubedupec_rotation2; // -@246
//uniform float fkochcubeduped_scale; // -@247
//uniform int fkochcubeduped_variant; // -@247
//uniform bool fkochcubeduped_first_zrev; // -@247
//uniform bool fkochcubeduped_pxyzminuss; // -@247
//uniform bool fkochcubeduped_psortsymmetry1; // -@247
//uniform bool fkochcubeduped_psortsymmetry2; // -@247
//uniform bool fkochcubeduped_foldzbefore; // -@247
//uniform bool fkochcubeduped_abs_x; // -@247
//uniform bool fkochcubeduped_abs_y; // -@247
//uniform bool fkochcubeduped_abs_z; // -@247
//uniform int fkochcubeduped_fold1; // -@247
//uniform int fkochcubeduped_fold2; // -@247
//uniform bool fkochcubeduped_fold3; // -@247
//uniform bool fkochcubeduped_fold4; // -@247
//uniform bool fkochcubeduped_reflection; // -@247
//uniform vec3 fkochcubeduped_rotation1; // -@247
//uniform vec3 fkochcubeduped_rotation2; // -@247
//uniform float fkochcubedupee_scale; // -@248
//uniform int fkochcubedupee_variant; // -@248
//uniform bool fkochcubedupee_first_zrev; // -@248
//uniform bool fkochcubedupee_pxyzminuss; // -@248
//uniform bool fkochcubedupee_psortsymmetry1; // -@248
//uniform bool fkochcubedupee_psortsymmetry2; // -@248
//uniform bool fkochcubedupee_foldzbefore; // -@248
//uniform bool fkochcubedupee_abs_x; // -@248
//uniform bool fkochcubedupee_abs_y; // -@248
//uniform bool fkochcubedupee_abs_z; // -@248
//uniform int fkochcubedupee_fold1; // -@248
//uniform int fkochcubedupee_fold2; // -@248
//uniform bool fkochcubedupee_fold3; // -@248
//uniform bool fkochcubedupee_fold4; // -@248
//uniform bool fkochcubedupee_reflection; // -@248
//uniform vec3 fkochcubedupee_rotation1; // -@248
//uniform vec3 fkochcubedupee_rotation2; // -@248
//uniform float fkochcubedupef_scale; // -@249
//uniform int fkochcubedupef_variant; // -@249
//uniform bool fkochcubedupef_first_zrev; // -@249
//uniform bool fkochcubedupef_pxyzminuss; // -@249
//uniform bool fkochcubedupef_psortsymmetry1; // -@249
//uniform bool fkochcubedupef_psortsymmetry2; // -@249
//uniform bool fkochcubedupef_foldzbefore; // -@249
//uniform bool fkochcubedupef_abs_x; // -@249
//uniform bool fkochcubedupef_abs_y; // -@249
//uniform bool fkochcubedupef_abs_z; // -@249
//uniform int fkochcubedupef_fold1; // -@249
//uniform int fkochcubedupef_fold2; // -@249
//uniform bool fkochcubedupef_fold3; // -@249
//uniform bool fkochcubedupef_fold4; // -@249
//uniform bool fkochcubedupef_reflection; // -@249
//uniform vec3 fkochcubedupef_rotation1; // -@249
//uniform vec3 fkochcubedupef_rotation2; // -@249
//uniform float fkochcubedupeg_scale; // -@250
//uniform int fkochcubedupeg_variant; // -@250
//uniform bool fkochcubedupeg_first_zrev; // -@250
//uniform bool fkochcubedupeg_pxyzminuss; // -@250
//uniform bool fkochcubedupeg_psortsymmetry1; // -@250
//uniform bool fkochcubedupeg_psortsymmetry2; // -@250
//uniform bool fkochcubedupeg_foldzbefore; // -@250
//uniform bool fkochcubedupeg_abs_x; // -@250
//uniform bool fkochcubedupeg_abs_y; // -@250
//uniform bool fkochcubedupeg_abs_z; // -@250
//uniform int fkochcubedupeg_fold1; // -@250
//uniform int fkochcubedupeg_fold2; // -@250
//uniform bool fkochcubedupeg_fold3; // -@250
//uniform bool fkochcubedupeg_fold4; // -@250
//uniform bool fkochcubedupeg_reflection; // -@250
//uniform vec3 fkochcubedupeg_rotation1; // -@250
//uniform vec3 fkochcubedupeg_rotation2; // -@250
//uniform float fkochcubedupeh_scale; // -@251
//uniform int fkochcubedupeh_variant; // -@251
//uniform bool fkochcubedupeh_first_zrev; // -@251
//uniform bool fkochcubedupeh_pxyzminuss; // -@251
//uniform bool fkochcubedupeh_psortsymmetry1; // -@251
//uniform bool fkochcubedupeh_psortsymmetry2; // -@251
//uniform bool fkochcubedupeh_foldzbefore; // -@251
//uniform bool fkochcubedupeh_abs_x; // -@251
//uniform bool fkochcubedupeh_abs_y; // -@251
//uniform bool fkochcubedupeh_abs_z; // -@251
//uniform int fkochcubedupeh_fold1; // -@251
//uniform int fkochcubedupeh_fold2; // -@251
//uniform bool fkochcubedupeh_fold3; // -@251
//uniform bool fkochcubedupeh_fold4; // -@251
//uniform bool fkochcubedupeh_reflection; // -@251
//uniform vec3 fkochcubedupeh_rotation1; // -@251
//uniform vec3 fkochcubedupeh_rotation2; // -@251
//uniform float fkochcubedupei_scale; // -@252
//uniform int fkochcubedupei_variant; // -@252
//uniform bool fkochcubedupei_first_zrev; // -@252
//uniform bool fkochcubedupei_pxyzminuss; // -@252
//uniform bool fkochcubedupei_psortsymmetry1; // -@252
//uniform bool fkochcubedupei_psortsymmetry2; // -@252
//uniform bool fkochcubedupei_foldzbefore; // -@252
//uniform bool fkochcubedupei_abs_x; // -@252
//uniform bool fkochcubedupei_abs_y; // -@252
//uniform bool fkochcubedupei_abs_z; // -@252
//uniform int fkochcubedupei_fold1; // -@252
//uniform int fkochcubedupei_fold2; // -@252
//uniform bool fkochcubedupei_fold3; // -@252
//uniform bool fkochcubedupei_fold4; // -@252
//uniform bool fkochcubedupei_reflection; // -@252
//uniform vec3 fkochcubedupei_rotation1; // -@252
//uniform vec3 fkochcubedupei_rotation2; // -@252
//uniform float fkochcubedupej_scale; // -@253
//uniform int fkochcubedupej_variant; // -@253
//uniform bool fkochcubedupej_first_zrev; // -@253
//uniform bool fkochcubedupej_pxyzminuss; // -@253
//uniform bool fkochcubedupej_psortsymmetry1; // -@253
//uniform bool fkochcubedupej_psortsymmetry2; // -@253
//uniform bool fkochcubedupej_foldzbefore; // -@253
//uniform bool fkochcubedupej_abs_x; // -@253
//uniform bool fkochcubedupej_abs_y; // -@253
//uniform bool fkochcubedupej_abs_z; // -@253
//uniform int fkochcubedupej_fold1; // -@253
//uniform int fkochcubedupej_fold2; // -@253
//uniform bool fkochcubedupej_fold3; // -@253
//uniform bool fkochcubedupej_fold4; // -@253
//uniform bool fkochcubedupej_reflection; // -@253
//uniform vec3 fkochcubedupej_rotation1; // -@253
//uniform vec3 fkochcubedupej_rotation2; // -@253
//uniform bool fkochwire_fold1; // -@254
//uniform bool fkochwire_fold2; // -@254
//uniform bool fkochwire_fold3; // -@254
//uniform bool fkochwire_abs_x; // -@254
//uniform bool fkochwire_abs_y; // -@254
//uniform bool fkochwire_abs_z; // -@254
//uniform bool fkochwire_abs2_zx; // -@254
//uniform vec3 fkochwire_abs_plus; // -@254
//uniform vec3 fkochwire_abs_minus; // -@254
//uniform float fkochwire_scale; // -@254
//uniform float fkochwire_symmetry; // -@254
//uniform vec3 fkochwire_offset; // -@254
//uniform vec3 fkochwire_rotation1; // -@254
//uniform vec3 fkochwire_rotation2; // -@254
//uniform bool fkochwiredupea_fold1; // -@255
//uniform bool fkochwiredupea_fold2; // -@255
//uniform bool fkochwiredupea_fold3; // -@255
//uniform bool fkochwiredupea_abs_x; // -@255
//uniform bool fkochwiredupea_abs_y; // -@255
//uniform bool fkochwiredupea_abs_z; // -@255
//uniform bool fkochwiredupea_abs2_zx; // -@255
//uniform vec3 fkochwiredupea_abs_plus; // -@255
//uniform vec3 fkochwiredupea_abs_minus; // -@255
//uniform float fkochwiredupea_scale; // -@255
//uniform float fkochwiredupea_symmetry; // -@255
//uniform vec3 fkochwiredupea_offset; // -@255
//uniform vec3 fkochwiredupea_rotation1; // -@255
//uniform vec3 fkochwiredupea_rotation2; // -@255
//uniform bool fkochwiredupeb_fold1; // -@256
//uniform bool fkochwiredupeb_fold2; // -@256
//uniform bool fkochwiredupeb_fold3; // -@256
//uniform bool fkochwiredupeb_abs_x; // -@256
//uniform bool fkochwiredupeb_abs_y; // -@256
//uniform bool fkochwiredupeb_abs_z; // -@256
//uniform bool fkochwiredupeb_abs2_zx; // -@256
//uniform vec3 fkochwiredupeb_abs_plus; // -@256
//uniform vec3 fkochwiredupeb_abs_minus; // -@256
//uniform float fkochwiredupeb_scale; // -@256
//uniform float fkochwiredupeb_symmetry; // -@256
//uniform vec3 fkochwiredupeb_offset; // -@256
//uniform vec3 fkochwiredupeb_rotation1; // -@256
//uniform vec3 fkochwiredupeb_rotation2; // -@256
//uniform bool fkochwiredupec_fold1; // -@257
//uniform bool fkochwiredupec_fold2; // -@257
//uniform bool fkochwiredupec_fold3; // -@257
//uniform bool fkochwiredupec_abs_x; // -@257
//uniform bool fkochwiredupec_abs_y; // -@257
//uniform bool fkochwiredupec_abs_z; // -@257
//uniform bool fkochwiredupec_abs2_zx; // -@257
//uniform vec3 fkochwiredupec_abs_plus; // -@257
//uniform vec3 fkochwiredupec_abs_minus; // -@257
//uniform float fkochwiredupec_scale; // -@257
//uniform float fkochwiredupec_symmetry; // -@257
//uniform vec3 fkochwiredupec_offset; // -@257
//uniform vec3 fkochwiredupec_rotation1; // -@257
//uniform vec3 fkochwiredupec_rotation2; // -@257
//uniform bool fkochwireduped_fold1; // -@258
//uniform bool fkochwireduped_fold2; // -@258
//uniform bool fkochwireduped_fold3; // -@258
//uniform bool fkochwireduped_abs_x; // -@258
//uniform bool fkochwireduped_abs_y; // -@258
//uniform bool fkochwireduped_abs_z; // -@258
//uniform bool fkochwireduped_abs2_zx; // -@258
//uniform vec3 fkochwireduped_abs_plus; // -@258
//uniform vec3 fkochwireduped_abs_minus; // -@258
//uniform float fkochwireduped_scale; // -@258
//uniform float fkochwireduped_symmetry; // -@258
//uniform vec3 fkochwireduped_offset; // -@258
//uniform vec3 fkochwireduped_rotation1; // -@258
//uniform vec3 fkochwireduped_rotation2; // -@258
//uniform bool fkochwiredupee_fold1; // -@259
//uniform bool fkochwiredupee_fold2; // -@259
//uniform bool fkochwiredupee_fold3; // -@259
//uniform bool fkochwiredupee_abs_x; // -@259
//uniform bool fkochwiredupee_abs_y; // -@259
//uniform bool fkochwiredupee_abs_z; // -@259
//uniform bool fkochwiredupee_abs2_zx; // -@259
//uniform vec3 fkochwiredupee_abs_plus; // -@259
//uniform vec3 fkochwiredupee_abs_minus; // -@259
//uniform float fkochwiredupee_scale; // -@259
//uniform float fkochwiredupee_symmetry; // -@259
//uniform vec3 fkochwiredupee_offset; // -@259
//uniform vec3 fkochwiredupee_rotation1; // -@259
//uniform vec3 fkochwiredupee_rotation2; // -@259
//uniform bool fkochwiredupef_fold1; // -@260
//uniform bool fkochwiredupef_fold2; // -@260
//uniform bool fkochwiredupef_fold3; // -@260
//uniform bool fkochwiredupef_abs_x; // -@260
//uniform bool fkochwiredupef_abs_y; // -@260
//uniform bool fkochwiredupef_abs_z; // -@260
//uniform bool fkochwiredupef_abs2_zx; // -@260
//uniform vec3 fkochwiredupef_abs_plus; // -@260
//uniform vec3 fkochwiredupef_abs_minus; // -@260
//uniform float fkochwiredupef_scale; // -@260
//uniform float fkochwiredupef_symmetry; // -@260
//uniform vec3 fkochwiredupef_offset; // -@260
//uniform vec3 fkochwiredupef_rotation1; // -@260
//uniform vec3 fkochwiredupef_rotation2; // -@260
//uniform bool fkochwiredupeg_fold1; // -@261
//uniform bool fkochwiredupeg_fold2; // -@261
//uniform bool fkochwiredupeg_fold3; // -@261
//uniform bool fkochwiredupeg_abs_x; // -@261
//uniform bool fkochwiredupeg_abs_y; // -@261
//uniform bool fkochwiredupeg_abs_z; // -@261
//uniform bool fkochwiredupeg_abs2_zx; // -@261
//uniform vec3 fkochwiredupeg_abs_plus; // -@261
//uniform vec3 fkochwiredupeg_abs_minus; // -@261
//uniform float fkochwiredupeg_scale; // -@261
//uniform float fkochwiredupeg_symmetry; // -@261
//uniform vec3 fkochwiredupeg_offset; // -@261
//uniform vec3 fkochwiredupeg_rotation1; // -@261
//uniform vec3 fkochwiredupeg_rotation2; // -@261
//uniform bool fkochwiredupeh_fold1; // -@262
//uniform bool fkochwiredupeh_fold2; // -@262
//uniform bool fkochwiredupeh_fold3; // -@262
//uniform bool fkochwiredupeh_abs_x; // -@262
//uniform bool fkochwiredupeh_abs_y; // -@262
//uniform bool fkochwiredupeh_abs_z; // -@262
//uniform bool fkochwiredupeh_abs2_zx; // -@262
//uniform vec3 fkochwiredupeh_abs_plus; // -@262
//uniform vec3 fkochwiredupeh_abs_minus; // -@262
//uniform float fkochwiredupeh_scale; // -@262
//uniform float fkochwiredupeh_symmetry; // -@262
//uniform vec3 fkochwiredupeh_offset; // -@262
//uniform vec3 fkochwiredupeh_rotation1; // -@262
//uniform vec3 fkochwiredupeh_rotation2; // -@262
//uniform bool fkochwiredupei_fold1; // -@263
//uniform bool fkochwiredupei_fold2; // -@263
//uniform bool fkochwiredupei_fold3; // -@263
//uniform bool fkochwiredupei_abs_x; // -@263
//uniform bool fkochwiredupei_abs_y; // -@263
//uniform bool fkochwiredupei_abs_z; // -@263
//uniform bool fkochwiredupei_abs2_zx; // -@263
//uniform vec3 fkochwiredupei_abs_plus; // -@263
//uniform vec3 fkochwiredupei_abs_minus; // -@263
//uniform float fkochwiredupei_scale; // -@263
//uniform float fkochwiredupei_symmetry; // -@263
//uniform vec3 fkochwiredupei_offset; // -@263
//uniform vec3 fkochwiredupei_rotation1; // -@263
//uniform vec3 fkochwiredupei_rotation2; // -@263
//uniform bool fkochwiredupej_fold1; // -@264
//uniform bool fkochwiredupej_fold2; // -@264
//uniform bool fkochwiredupej_fold3; // -@264
//uniform bool fkochwiredupej_abs_x; // -@264
//uniform bool fkochwiredupej_abs_y; // -@264
//uniform bool fkochwiredupej_abs_z; // -@264
//uniform bool fkochwiredupej_abs2_zx; // -@264
//uniform vec3 fkochwiredupej_abs_plus; // -@264
//uniform vec3 fkochwiredupej_abs_minus; // -@264
//uniform float fkochwiredupej_scale; // -@264
//uniform float fkochwiredupej_symmetry; // -@264
//uniform vec3 fkochwiredupej_offset; // -@264
//uniform vec3 fkochwiredupej_rotation1; // -@264
//uniform vec3 fkochwiredupej_rotation2; // -@264
//uniform float flionbulb_power; // -@265
//uniform float flionbulb_phase; // -@265
//uniform vec3 flionbulb_c; // -@265
//uniform bool flionbulb_coral; // -@265
//uniform float flionbulbdupea_power; // -@266
//uniform float flionbulbdupea_phase; // -@266
//uniform vec3 flionbulbdupea_c; // -@266
//uniform bool flionbulbdupea_coral; // -@266
//uniform float flionbulbdupeb_power; // -@267
//uniform float flionbulbdupeb_phase; // -@267
//uniform vec3 flionbulbdupeb_c; // -@267
//uniform bool flionbulbdupeb_coral; // -@267
//uniform float flionbulbdupec_power; // -@268
//uniform float flionbulbdupec_phase; // -@268
//uniform vec3 flionbulbdupec_c; // -@268
//uniform bool flionbulbdupec_coral; // -@268
//uniform float flionbulbduped_power; // -@269
//uniform float flionbulbduped_phase; // -@269
//uniform vec3 flionbulbduped_c; // -@269
//uniform bool flionbulbduped_coral; // -@269
//uniform float flionbulbdupee_power; // -@270
//uniform float flionbulbdupee_phase; // -@270
//uniform vec3 flionbulbdupee_c; // -@270
//uniform bool flionbulbdupee_coral; // -@270
//uniform float flionbulbdupef_power; // -@271
//uniform float flionbulbdupef_phase; // -@271
//uniform vec3 flionbulbdupef_c; // -@271
//uniform bool flionbulbdupef_coral; // -@271
//uniform float flionbulbdupeg_power; // -@272
//uniform float flionbulbdupeg_phase; // -@272
//uniform vec3 flionbulbdupeg_c; // -@272
//uniform bool flionbulbdupeg_coral; // -@272
//uniform float flionbulbdupeh_power; // -@273
//uniform float flionbulbdupeh_phase; // -@273
//uniform vec3 flionbulbdupeh_c; // -@273
//uniform bool flionbulbdupeh_coral; // -@273
//uniform float flionbulbdupei_power; // -@274
//uniform float flionbulbdupei_phase; // -@274
//uniform vec3 flionbulbdupei_c; // -@274
//uniform bool flionbulbdupei_coral; // -@274
//uniform float flionbulbdupej_power; // -@275
//uniform float flionbulbdupej_phase; // -@275
//uniform vec3 flionbulbdupej_c; // -@275
//uniform bool flionbulbdupej_coral; // -@275
//uniform int flogtransform_axis; // -@276
//uniform float flogtransform_offset; // -@276
//uniform float flogtransform_scale; // -@276
//uniform vec2 flogtransform_range; // -@276
//uniform int flogtransformdupea_axis; // -@277
//uniform float flogtransformdupea_offset; // -@277
//uniform float flogtransformdupea_scale; // -@277
//uniform vec2 flogtransformdupea_range; // -@277
//uniform int flogtransformdupeb_axis; // -@278
//uniform float flogtransformdupeb_offset; // -@278
//uniform float flogtransformdupeb_scale; // -@278
//uniform vec2 flogtransformdupeb_range; // -@278
//uniform int flogtransformdupec_axis; // -@279
//uniform float flogtransformdupec_offset; // -@279
//uniform float flogtransformdupec_scale; // -@279
//uniform vec2 flogtransformdupec_range; // -@279
//uniform int flogtransformduped_axis; // -@280
//uniform float flogtransformduped_offset; // -@280
//uniform float flogtransformduped_scale; // -@280
//uniform vec2 flogtransformduped_range; // -@280
//uniform int flogtransformdupee_axis; // -@281
//uniform float flogtransformdupee_offset; // -@281
//uniform float flogtransformdupee_scale; // -@281
//uniform vec2 flogtransformdupee_range; // -@281
//uniform int flogtransformdupef_axis; // -@282
//uniform float flogtransformdupef_offset; // -@282
//uniform float flogtransformdupef_scale; // -@282
//uniform vec2 flogtransformdupef_range; // -@282
//uniform int flogtransformdupeg_axis; // -@283
//uniform float flogtransformdupeg_offset; // -@283
//uniform float flogtransformdupeg_scale; // -@283
//uniform vec2 flogtransformdupeg_range; // -@283
//uniform int flogtransformdupeh_axis; // -@284
//uniform float flogtransformdupeh_offset; // -@284
//uniform float flogtransformdupeh_scale; // -@284
//uniform vec2 flogtransformdupeh_range; // -@284
//uniform int flogtransformdupei_axis; // -@285
//uniform float flogtransformdupei_offset; // -@285
//uniform float flogtransformdupei_scale; // -@285
//uniform vec2 flogtransformdupei_range; // -@285
//uniform int flogtransformdupej_axis; // -@286
//uniform float flogtransformdupej_offset; // -@286
//uniform float flogtransformdupej_scale; // -@286
//uniform vec2 flogtransformdupej_range; // -@286
//uniform int fmandelbox_shape; // -@298
//uniform float fmandelbox_scale; // -@298
//uniform float fmandelbox_radius1; // -@298
//uniform float fmandelbox_fold1; // -@298
//uniform float fmandelbox_fold1_strength; // -@298
//uniform float fmandelbox_radius2; // -@298
//uniform vec3 fmandelbox_box_folds; // -@298
//uniform bool fmandelbox_is_julia; // -@298
//uniform vec3 fmandelbox_julia_c; // -@298
//uniform vec3 fmandelbox_rotation1; // -@298
//uniform vec3 fmandelbox_rotation2; // -@298
//uniform int fmandelboxdupea_shape; // -@299
//uniform float fmandelboxdupea_scale; // -@299
//uniform float fmandelboxdupea_radius1; // -@299
//uniform float fmandelboxdupea_fold1; // -@299
//uniform float fmandelboxdupea_fold1_strength; // -@299
//uniform float fmandelboxdupea_radius2; // -@299
//uniform vec3 fmandelboxdupea_box_folds; // -@299
//uniform bool fmandelboxdupea_is_julia; // -@299
//uniform vec3 fmandelboxdupea_julia_c; // -@299
//uniform vec3 fmandelboxdupea_rotation1; // -@299
//uniform vec3 fmandelboxdupea_rotation2; // -@299
//uniform int fmandelboxdupeb_shape; // -@300
//uniform float fmandelboxdupeb_scale; // -@300
//uniform float fmandelboxdupeb_radius1; // -@300
//uniform float fmandelboxdupeb_fold1; // -@300
//uniform float fmandelboxdupeb_fold1_strength; // -@300
//uniform float fmandelboxdupeb_radius2; // -@300
//uniform vec3 fmandelboxdupeb_box_folds; // -@300
//uniform bool fmandelboxdupeb_is_julia; // -@300
//uniform vec3 fmandelboxdupeb_julia_c; // -@300
//uniform vec3 fmandelboxdupeb_rotation1; // -@300
//uniform vec3 fmandelboxdupeb_rotation2; // -@300
//uniform int fmandelboxdupec_shape; // -@301
//uniform float fmandelboxdupec_scale; // -@301
//uniform float fmandelboxdupec_radius1; // -@301
//uniform float fmandelboxdupec_fold1; // -@301
//uniform float fmandelboxdupec_fold1_strength; // -@301
//uniform float fmandelboxdupec_radius2; // -@301
//uniform vec3 fmandelboxdupec_box_folds; // -@301
//uniform bool fmandelboxdupec_is_julia; // -@301
//uniform vec3 fmandelboxdupec_julia_c; // -@301
//uniform vec3 fmandelboxdupec_rotation1; // -@301
//uniform vec3 fmandelboxdupec_rotation2; // -@301
//uniform int fmandelboxduped_shape; // -@302
//uniform float fmandelboxduped_scale; // -@302
//uniform float fmandelboxduped_radius1; // -@302
//uniform float fmandelboxduped_fold1; // -@302
//uniform float fmandelboxduped_fold1_strength; // -@302
//uniform float fmandelboxduped_radius2; // -@302
//uniform vec3 fmandelboxduped_box_folds; // -@302
//uniform bool fmandelboxduped_is_julia; // -@302
//uniform vec3 fmandelboxduped_julia_c; // -@302
//uniform vec3 fmandelboxduped_rotation1; // -@302
//uniform vec3 fmandelboxduped_rotation2; // -@302
//uniform int fmandelboxdupee_shape; // -@303
//uniform float fmandelboxdupee_scale; // -@303
//uniform float fmandelboxdupee_radius1; // -@303
//uniform float fmandelboxdupee_fold1; // -@303
//uniform float fmandelboxdupee_fold1_strength; // -@303
//uniform float fmandelboxdupee_radius2; // -@303
//uniform vec3 fmandelboxdupee_box_folds; // -@303
//uniform bool fmandelboxdupee_is_julia; // -@303
//uniform vec3 fmandelboxdupee_julia_c; // -@303
//uniform vec3 fmandelboxdupee_rotation1; // -@303
//uniform vec3 fmandelboxdupee_rotation2; // -@303
//uniform int fmandelboxdupef_shape; // -@304
//uniform float fmandelboxdupef_scale; // -@304
//uniform float fmandelboxdupef_radius1; // -@304
//uniform float fmandelboxdupef_fold1; // -@304
//uniform float fmandelboxdupef_fold1_strength; // -@304
//uniform float fmandelboxdupef_radius2; // -@304
//uniform vec3 fmandelboxdupef_box_folds; // -@304
//uniform bool fmandelboxdupef_is_julia; // -@304
//uniform vec3 fmandelboxdupef_julia_c; // -@304
//uniform vec3 fmandelboxdupef_rotation1; // -@304
//uniform vec3 fmandelboxdupef_rotation2; // -@304
//uniform int fmandelboxdupeg_shape; // -@305
//uniform float fmandelboxdupeg_scale; // -@305
//uniform float fmandelboxdupeg_radius1; // -@305
//uniform float fmandelboxdupeg_fold1; // -@305
//uniform float fmandelboxdupeg_fold1_strength; // -@305
//uniform float fmandelboxdupeg_radius2; // -@305
//uniform vec3 fmandelboxdupeg_box_folds; // -@305
//uniform bool fmandelboxdupeg_is_julia; // -@305
//uniform vec3 fmandelboxdupeg_julia_c; // -@305
//uniform vec3 fmandelboxdupeg_rotation1; // -@305
//uniform vec3 fmandelboxdupeg_rotation2; // -@305
//uniform int fmandelboxdupeh_shape; // -@306
//uniform float fmandelboxdupeh_scale; // -@306
//uniform float fmandelboxdupeh_radius1; // -@306
//uniform float fmandelboxdupeh_fold1; // -@306
//uniform float fmandelboxdupeh_fold1_strength; // -@306
//uniform float fmandelboxdupeh_radius2; // -@306
//uniform vec3 fmandelboxdupeh_box_folds; // -@306
//uniform bool fmandelboxdupeh_is_julia; // -@306
//uniform vec3 fmandelboxdupeh_julia_c; // -@306
//uniform vec3 fmandelboxdupeh_rotation1; // -@306
//uniform vec3 fmandelboxdupeh_rotation2; // -@306
//uniform int fmandelboxdupei_shape; // -@307
//uniform float fmandelboxdupei_scale; // -@307
//uniform float fmandelboxdupei_radius1; // -@307
//uniform float fmandelboxdupei_fold1; // -@307
//uniform float fmandelboxdupei_fold1_strength; // -@307
//uniform float fmandelboxdupei_radius2; // -@307
//uniform vec3 fmandelboxdupei_box_folds; // -@307
//uniform bool fmandelboxdupei_is_julia; // -@307
//uniform vec3 fmandelboxdupei_julia_c; // -@307
//uniform vec3 fmandelboxdupei_rotation1; // -@307
//uniform vec3 fmandelboxdupei_rotation2; // -@307
//uniform int fmandelboxdupej_shape; // -@308
//uniform float fmandelboxdupej_scale; // -@308
//uniform float fmandelboxdupej_radius1; // -@308
//uniform float fmandelboxdupej_fold1; // -@308
//uniform float fmandelboxdupej_fold1_strength; // -@308
//uniform float fmandelboxdupej_radius2; // -@308
//uniform vec3 fmandelboxdupej_box_folds; // -@308
//uniform bool fmandelboxdupej_is_julia; // -@308
//uniform vec3 fmandelboxdupej_julia_c; // -@308
//uniform vec3 fmandelboxdupej_rotation1; // -@308
//uniform vec3 fmandelboxdupej_rotation2; // -@308
uniform float fmandelbulb_phase; // -@309
uniform float fmandelbulb_power; // -@309
uniform float fmandelbulb_z_mul; // -@309
uniform bool fmandelbulb_conjugate; // -@309
uniform bool fmandelbulb_abs_x; // -@309
uniform bool fmandelbulb_abs_y; // -@309
uniform bool fmandelbulb_abs_z; // -@309
uniform bool fmandelbulb_is_julia; // -@309
uniform vec4 fmandelbulb_julia_c; // -@309
uniform float fmandelbulb_derivative_bias; // -@309
uniform int fmandelbulb_number_system; // -@309
uniform int fmandelbulb_quaternion_mode; // -@309
//uniform float fmandelbulbdupea_phase; // -@310
//uniform float fmandelbulbdupea_power; // -@310
//uniform float fmandelbulbdupea_z_mul; // -@310
//uniform bool fmandelbulbdupea_conjugate; // -@310
//uniform bool fmandelbulbdupea_abs_x; // -@310
//uniform bool fmandelbulbdupea_abs_y; // -@310
//uniform bool fmandelbulbdupea_abs_z; // -@310
//uniform bool fmandelbulbdupea_is_julia; // -@310
//uniform vec4 fmandelbulbdupea_julia_c; // -@310
//uniform float fmandelbulbdupea_derivative_bias; // -@310
//uniform int fmandelbulbdupea_number_system; // -@310
//uniform int fmandelbulbdupea_quaternion_mode; // -@310
//uniform float fmandelbulbdupeb_phase; // -@311
//uniform float fmandelbulbdupeb_power; // -@311
//uniform float fmandelbulbdupeb_z_mul; // -@311
//uniform bool fmandelbulbdupeb_conjugate; // -@311
//uniform bool fmandelbulbdupeb_abs_x; // -@311
//uniform bool fmandelbulbdupeb_abs_y; // -@311
//uniform bool fmandelbulbdupeb_abs_z; // -@311
//uniform bool fmandelbulbdupeb_is_julia; // -@311
//uniform vec4 fmandelbulbdupeb_julia_c; // -@311
//uniform float fmandelbulbdupeb_derivative_bias; // -@311
//uniform int fmandelbulbdupeb_number_system; // -@311
//uniform int fmandelbulbdupeb_quaternion_mode; // -@311
//uniform float fmandelbulbdupec_phase; // -@312
//uniform float fmandelbulbdupec_power; // -@312
//uniform float fmandelbulbdupec_z_mul; // -@312
//uniform bool fmandelbulbdupec_conjugate; // -@312
//uniform bool fmandelbulbdupec_abs_x; // -@312
//uniform bool fmandelbulbdupec_abs_y; // -@312
//uniform bool fmandelbulbdupec_abs_z; // -@312
//uniform bool fmandelbulbdupec_is_julia; // -@312
//uniform vec4 fmandelbulbdupec_julia_c; // -@312
//uniform float fmandelbulbdupec_derivative_bias; // -@312
//uniform int fmandelbulbdupec_number_system; // -@312
//uniform int fmandelbulbdupec_quaternion_mode; // -@312
//uniform float fmandelbulbduped_phase; // -@313
//uniform float fmandelbulbduped_power; // -@313
//uniform float fmandelbulbduped_z_mul; // -@313
//uniform bool fmandelbulbduped_conjugate; // -@313
//uniform bool fmandelbulbduped_abs_x; // -@313
//uniform bool fmandelbulbduped_abs_y; // -@313
//uniform bool fmandelbulbduped_abs_z; // -@313
//uniform bool fmandelbulbduped_is_julia; // -@313
//uniform vec4 fmandelbulbduped_julia_c; // -@313
//uniform float fmandelbulbduped_derivative_bias; // -@313
//uniform int fmandelbulbduped_number_system; // -@313
//uniform int fmandelbulbduped_quaternion_mode; // -@313
//uniform float fmandelbulbdupee_phase; // -@314
//uniform float fmandelbulbdupee_power; // -@314
//uniform float fmandelbulbdupee_z_mul; // -@314
//uniform bool fmandelbulbdupee_conjugate; // -@314
//uniform bool fmandelbulbdupee_abs_x; // -@314
//uniform bool fmandelbulbdupee_abs_y; // -@314
//uniform bool fmandelbulbdupee_abs_z; // -@314
//uniform bool fmandelbulbdupee_is_julia; // -@314
//uniform vec4 fmandelbulbdupee_julia_c; // -@314
//uniform float fmandelbulbdupee_derivative_bias; // -@314
//uniform int fmandelbulbdupee_number_system; // -@314
//uniform int fmandelbulbdupee_quaternion_mode; // -@314
//uniform float fmandelbulbdupef_phase; // -@315
//uniform float fmandelbulbdupef_power; // -@315
//uniform float fmandelbulbdupef_z_mul; // -@315
//uniform bool fmandelbulbdupef_conjugate; // -@315
//uniform bool fmandelbulbdupef_abs_x; // -@315
//uniform bool fmandelbulbdupef_abs_y; // -@315
//uniform bool fmandelbulbdupef_abs_z; // -@315
//uniform bool fmandelbulbdupef_is_julia; // -@315
//uniform vec4 fmandelbulbdupef_julia_c; // -@315
//uniform float fmandelbulbdupef_derivative_bias; // -@315
//uniform int fmandelbulbdupef_number_system; // -@315
//uniform int fmandelbulbdupef_quaternion_mode; // -@315
//uniform float fmandelbulbdupeg_phase; // -@316
//uniform float fmandelbulbdupeg_power; // -@316
//uniform float fmandelbulbdupeg_z_mul; // -@316
//uniform bool fmandelbulbdupeg_conjugate; // -@316
//uniform bool fmandelbulbdupeg_abs_x; // -@316
//uniform bool fmandelbulbdupeg_abs_y; // -@316
//uniform bool fmandelbulbdupeg_abs_z; // -@316
//uniform bool fmandelbulbdupeg_is_julia; // -@316
//uniform vec4 fmandelbulbdupeg_julia_c; // -@316
//uniform float fmandelbulbdupeg_derivative_bias; // -@316
//uniform int fmandelbulbdupeg_number_system; // -@316
//uniform int fmandelbulbdupeg_quaternion_mode; // -@316
//uniform float fmandelbulbdupeh_phase; // -@317
//uniform float fmandelbulbdupeh_power; // -@317
//uniform float fmandelbulbdupeh_z_mul; // -@317
//uniform bool fmandelbulbdupeh_conjugate; // -@317
//uniform bool fmandelbulbdupeh_abs_x; // -@317
//uniform bool fmandelbulbdupeh_abs_y; // -@317
//uniform bool fmandelbulbdupeh_abs_z; // -@317
//uniform bool fmandelbulbdupeh_is_julia; // -@317
//uniform vec4 fmandelbulbdupeh_julia_c; // -@317
//uniform float fmandelbulbdupeh_derivative_bias; // -@317
//uniform int fmandelbulbdupeh_number_system; // -@317
//uniform int fmandelbulbdupeh_quaternion_mode; // -@317
//uniform float fmandelbulbdupei_phase; // -@318
//uniform float fmandelbulbdupei_power; // -@318
//uniform float fmandelbulbdupei_z_mul; // -@318
//uniform bool fmandelbulbdupei_conjugate; // -@318
//uniform bool fmandelbulbdupei_abs_x; // -@318
//uniform bool fmandelbulbdupei_abs_y; // -@318
//uniform bool fmandelbulbdupei_abs_z; // -@318
//uniform bool fmandelbulbdupei_is_julia; // -@318
//uniform vec4 fmandelbulbdupei_julia_c; // -@318
//uniform float fmandelbulbdupei_derivative_bias; // -@318
//uniform int fmandelbulbdupei_number_system; // -@318
//uniform int fmandelbulbdupei_quaternion_mode; // -@318
//uniform float fmandelbulbdupej_phase; // -@319
//uniform float fmandelbulbdupej_power; // -@319
//uniform float fmandelbulbdupej_z_mul; // -@319
//uniform bool fmandelbulbdupej_conjugate; // -@319
//uniform bool fmandelbulbdupej_abs_x; // -@319
//uniform bool fmandelbulbdupej_abs_y; // -@319
//uniform bool fmandelbulbdupej_abs_z; // -@319
//uniform bool fmandelbulbdupej_is_julia; // -@319
//uniform vec4 fmandelbulbdupej_julia_c; // -@319
//uniform float fmandelbulbdupej_derivative_bias; // -@319
//uniform int fmandelbulbdupej_number_system; // -@319
//uniform int fmandelbulbdupej_quaternion_mode; // -@319
//uniform bool fmandelettuce_is_julia; // -@320
//uniform vec3 fmandelettuce_julia_c; // -@320
//uniform int fmandelettuce_power; // -@320
//uniform bool fmandelettucedupea_is_julia; // -@321
//uniform vec3 fmandelettucedupea_julia_c; // -@321
//uniform int fmandelettucedupea_power; // -@321
//uniform bool fmandelettucedupeb_is_julia; // -@322
//uniform vec3 fmandelettucedupeb_julia_c; // -@322
//uniform int fmandelettucedupeb_power; // -@322
//uniform bool fmandelettucedupec_is_julia; // -@323
//uniform vec3 fmandelettucedupec_julia_c; // -@323
//uniform int fmandelettucedupec_power; // -@323
//uniform bool fmandelettuceduped_is_julia; // -@324
//uniform vec3 fmandelettuceduped_julia_c; // -@324
//uniform int fmandelettuceduped_power; // -@324
//uniform bool fmandelettucedupee_is_julia; // -@325
//uniform vec3 fmandelettucedupee_julia_c; // -@325
//uniform int fmandelettucedupee_power; // -@325
//uniform bool fmandelettucedupef_is_julia; // -@326
//uniform vec3 fmandelettucedupef_julia_c; // -@326
//uniform int fmandelettucedupef_power; // -@326
//uniform bool fmandelettucedupeg_is_julia; // -@327
//uniform vec3 fmandelettucedupeg_julia_c; // -@327
//uniform int fmandelettucedupeg_power; // -@327
//uniform bool fmandelettucedupeh_is_julia; // -@328
//uniform vec3 fmandelettucedupeh_julia_c; // -@328
//uniform int fmandelettucedupeh_power; // -@328
//uniform bool fmandelettucedupei_is_julia; // -@329
//uniform vec3 fmandelettucedupei_julia_c; // -@329
//uniform int fmandelettucedupei_power; // -@329
//uniform bool fmandelettucedupej_is_julia; // -@330
//uniform vec3 fmandelettucedupej_julia_c; // -@330
//uniform int fmandelettucedupej_power; // -@330
//uniform vec4 fmelttransform_a; // -@331
//uniform vec4 fmelttransform_b; // -@331
//uniform vec4 fmelttransform_c; // -@331
//uniform vec4 fmelttransform_d; // -@331
//uniform vec2 fmelttransform_range; // -@331
//uniform vec4 fmelttransformdupea_a; // -@332
//uniform vec4 fmelttransformdupea_b; // -@332
//uniform vec4 fmelttransformdupea_c; // -@332
//uniform vec4 fmelttransformdupea_d; // -@332
//uniform vec2 fmelttransformdupea_range; // -@332
//uniform vec4 fmelttransformdupeb_a; // -@333
//uniform vec4 fmelttransformdupeb_b; // -@333
//uniform vec4 fmelttransformdupeb_c; // -@333
//uniform vec4 fmelttransformdupeb_d; // -@333
//uniform vec2 fmelttransformdupeb_range; // -@333
//uniform vec4 fmelttransformdupec_a; // -@334
//uniform vec4 fmelttransformdupec_b; // -@334
//uniform vec4 fmelttransformdupec_c; // -@334
//uniform vec4 fmelttransformdupec_d; // -@334
//uniform vec2 fmelttransformdupec_range; // -@334
//uniform vec4 fmelttransformduped_a; // -@335
//uniform vec4 fmelttransformduped_b; // -@335
//uniform vec4 fmelttransformduped_c; // -@335
//uniform vec4 fmelttransformduped_d; // -@335
//uniform vec2 fmelttransformduped_range; // -@335
//uniform vec4 fmelttransformdupee_a; // -@336
//uniform vec4 fmelttransformdupee_b; // -@336
//uniform vec4 fmelttransformdupee_c; // -@336
//uniform vec4 fmelttransformdupee_d; // -@336
//uniform vec2 fmelttransformdupee_range; // -@336
//uniform vec4 fmelttransformdupef_a; // -@337
//uniform vec4 fmelttransformdupef_b; // -@337
//uniform vec4 fmelttransformdupef_c; // -@337
//uniform vec4 fmelttransformdupef_d; // -@337
//uniform vec2 fmelttransformdupef_range; // -@337
//uniform vec4 fmelttransformdupeg_a; // -@338
//uniform vec4 fmelttransformdupeg_b; // -@338
//uniform vec4 fmelttransformdupeg_c; // -@338
//uniform vec4 fmelttransformdupeg_d; // -@338
//uniform vec2 fmelttransformdupeg_range; // -@338
//uniform vec4 fmelttransformdupeh_a; // -@339
//uniform vec4 fmelttransformdupeh_b; // -@339
//uniform vec4 fmelttransformdupeh_c; // -@339
//uniform vec4 fmelttransformdupeh_d; // -@339
//uniform vec2 fmelttransformdupeh_range; // -@339
//uniform vec4 fmelttransformdupei_a; // -@340
//uniform vec4 fmelttransformdupei_b; // -@340
//uniform vec4 fmelttransformdupei_c; // -@340
//uniform vec4 fmelttransformdupei_d; // -@340
//uniform vec2 fmelttransformdupei_range; // -@340
//uniform vec4 fmelttransformdupej_a; // -@341
//uniform vec4 fmelttransformdupej_b; // -@341
//uniform vec4 fmelttransformdupej_c; // -@341
//uniform vec4 fmelttransformdupej_d; // -@341
//uniform vec2 fmelttransformdupej_range; // -@341
//uniform vec3 fmengersponge_offset; // -@342
//uniform vec3 fmengersponge_rotation1; // -@342
//uniform vec3 fmengersponge_rotation2; // -@342
//uniform float fmengersponge_scale; // -@342
//uniform vec3 fmengerspongedupea_offset; // -@343
//uniform vec3 fmengerspongedupea_rotation1; // -@343
//uniform vec3 fmengerspongedupea_rotation2; // -@343
//uniform float fmengerspongedupea_scale; // -@343
//uniform vec3 fmengerspongedupeb_offset; // -@344
//uniform vec3 fmengerspongedupeb_rotation1; // -@344
//uniform vec3 fmengerspongedupeb_rotation2; // -@344
//uniform float fmengerspongedupeb_scale; // -@344
//uniform vec3 fmengerspongedupec_offset; // -@345
//uniform vec3 fmengerspongedupec_rotation1; // -@345
//uniform vec3 fmengerspongedupec_rotation2; // -@345
//uniform float fmengerspongedupec_scale; // -@345
//uniform vec3 fmengerspongeduped_offset; // -@346
//uniform vec3 fmengerspongeduped_rotation1; // -@346
//uniform vec3 fmengerspongeduped_rotation2; // -@346
//uniform float fmengerspongeduped_scale; // -@346
//uniform vec3 fmengerspongedupee_offset; // -@347
//uniform vec3 fmengerspongedupee_rotation1; // -@347
//uniform vec3 fmengerspongedupee_rotation2; // -@347
//uniform float fmengerspongedupee_scale; // -@347
//uniform vec3 fmengerspongedupef_offset; // -@348
//uniform vec3 fmengerspongedupef_rotation1; // -@348
//uniform vec3 fmengerspongedupef_rotation2; // -@348
//uniform float fmengerspongedupef_scale; // -@348
//uniform vec3 fmengerspongedupeg_offset; // -@349
//uniform vec3 fmengerspongedupeg_rotation1; // -@349
//uniform vec3 fmengerspongedupeg_rotation2; // -@349
//uniform float fmengerspongedupeg_scale; // -@349
//uniform vec3 fmengerspongedupeh_offset; // -@350
//uniform vec3 fmengerspongedupeh_rotation1; // -@350
//uniform vec3 fmengerspongedupeh_rotation2; // -@350
//uniform float fmengerspongedupeh_scale; // -@350
//uniform vec3 fmengerspongedupei_offset; // -@351
//uniform vec3 fmengerspongedupei_rotation1; // -@351
//uniform vec3 fmengerspongedupei_rotation2; // -@351
//uniform float fmengerspongedupei_scale; // -@351
//uniform vec3 fmengerspongedupej_offset; // -@352
//uniform vec3 fmengerspongedupej_rotation1; // -@352
//uniform vec3 fmengerspongedupej_rotation2; // -@352
//uniform float fmengerspongedupej_scale; // -@352
//uniform float fmixpinski4d_scale; // -@353
//uniform float fmixpinski4d_fold1_strength; // -@353
//uniform vec4 fmixpinski4d_offset; // -@353
//uniform vec4 fmixpinski4d_rotation1; // -@353
//uniform vec4 fmixpinski4d_rotation2; // -@353
//uniform float fmixpinski4d_abs_minus; // -@353
//uniform vec4 fmixpinski4d_fold1; // -@353
//uniform vec4 fmixpinski4d_pre_offset; // -@353
//uniform float fmixpinski4ddupea_scale; // -@354
//uniform float fmixpinski4ddupea_fold1_strength; // -@354
//uniform vec4 fmixpinski4ddupea_offset; // -@354
//uniform vec4 fmixpinski4ddupea_rotation1; // -@354
//uniform vec4 fmixpinski4ddupea_rotation2; // -@354
//uniform float fmixpinski4ddupea_abs_minus; // -@354
//uniform vec4 fmixpinski4ddupea_fold1; // -@354
//uniform vec4 fmixpinski4ddupea_pre_offset; // -@354
//uniform float fmixpinski4ddupeb_scale; // -@355
//uniform float fmixpinski4ddupeb_fold1_strength; // -@355
//uniform vec4 fmixpinski4ddupeb_offset; // -@355
//uniform vec4 fmixpinski4ddupeb_rotation1; // -@355
//uniform vec4 fmixpinski4ddupeb_rotation2; // -@355
//uniform float fmixpinski4ddupeb_abs_minus; // -@355
//uniform vec4 fmixpinski4ddupeb_fold1; // -@355
//uniform vec4 fmixpinski4ddupeb_pre_offset; // -@355
//uniform float fmixpinski4ddupec_scale; // -@356
//uniform float fmixpinski4ddupec_fold1_strength; // -@356
//uniform vec4 fmixpinski4ddupec_offset; // -@356
//uniform vec4 fmixpinski4ddupec_rotation1; // -@356
//uniform vec4 fmixpinski4ddupec_rotation2; // -@356
//uniform float fmixpinski4ddupec_abs_minus; // -@356
//uniform vec4 fmixpinski4ddupec_fold1; // -@356
//uniform vec4 fmixpinski4ddupec_pre_offset; // -@356
//uniform float fmixpinski4dduped_scale; // -@357
//uniform float fmixpinski4dduped_fold1_strength; // -@357
//uniform vec4 fmixpinski4dduped_offset; // -@357
//uniform vec4 fmixpinski4dduped_rotation1; // -@357
//uniform vec4 fmixpinski4dduped_rotation2; // -@357
//uniform float fmixpinski4dduped_abs_minus; // -@357
//uniform vec4 fmixpinski4dduped_fold1; // -@357
//uniform vec4 fmixpinski4dduped_pre_offset; // -@357
//uniform float fmixpinski4ddupee_scale; // -@358
//uniform float fmixpinski4ddupee_fold1_strength; // -@358
//uniform vec4 fmixpinski4ddupee_offset; // -@358
//uniform vec4 fmixpinski4ddupee_rotation1; // -@358
//uniform vec4 fmixpinski4ddupee_rotation2; // -@358
//uniform float fmixpinski4ddupee_abs_minus; // -@358
//uniform vec4 fmixpinski4ddupee_fold1; // -@358
//uniform vec4 fmixpinski4ddupee_pre_offset; // -@358
//uniform float fmixpinski4ddupef_scale; // -@359
//uniform float fmixpinski4ddupef_fold1_strength; // -@359
//uniform vec4 fmixpinski4ddupef_offset; // -@359
//uniform vec4 fmixpinski4ddupef_rotation1; // -@359
//uniform vec4 fmixpinski4ddupef_rotation2; // -@359
//uniform float fmixpinski4ddupef_abs_minus; // -@359
//uniform vec4 fmixpinski4ddupef_fold1; // -@359
//uniform vec4 fmixpinski4ddupef_pre_offset; // -@359
//uniform float fmixpinski4ddupeg_scale; // -@360
//uniform float fmixpinski4ddupeg_fold1_strength; // -@360
//uniform vec4 fmixpinski4ddupeg_offset; // -@360
//uniform vec4 fmixpinski4ddupeg_rotation1; // -@360
//uniform vec4 fmixpinski4ddupeg_rotation2; // -@360
//uniform float fmixpinski4ddupeg_abs_minus; // -@360
//uniform vec4 fmixpinski4ddupeg_fold1; // -@360
//uniform vec4 fmixpinski4ddupeg_pre_offset; // -@360
//uniform float fmixpinski4ddupeh_scale; // -@361
//uniform float fmixpinski4ddupeh_fold1_strength; // -@361
//uniform vec4 fmixpinski4ddupeh_offset; // -@361
//uniform vec4 fmixpinski4ddupeh_rotation1; // -@361
//uniform vec4 fmixpinski4ddupeh_rotation2; // -@361
//uniform float fmixpinski4ddupeh_abs_minus; // -@361
//uniform vec4 fmixpinski4ddupeh_fold1; // -@361
//uniform vec4 fmixpinski4ddupeh_pre_offset; // -@361
//uniform float fmixpinski4ddupei_scale; // -@362
//uniform float fmixpinski4ddupei_fold1_strength; // -@362
//uniform vec4 fmixpinski4ddupei_offset; // -@362
//uniform vec4 fmixpinski4ddupei_rotation1; // -@362
//uniform vec4 fmixpinski4ddupei_rotation2; // -@362
//uniform float fmixpinski4ddupei_abs_minus; // -@362
//uniform vec4 fmixpinski4ddupei_fold1; // -@362
//uniform vec4 fmixpinski4ddupei_pre_offset; // -@362
//uniform float fmixpinski4ddupej_scale; // -@363
//uniform float fmixpinski4ddupej_fold1_strength; // -@363
//uniform vec4 fmixpinski4ddupej_offset; // -@363
//uniform vec4 fmixpinski4ddupej_rotation1; // -@363
//uniform vec4 fmixpinski4ddupej_rotation2; // -@363
//uniform float fmixpinski4ddupej_abs_minus; // -@363
//uniform vec4 fmixpinski4ddupej_fold1; // -@363
//uniform vec4 fmixpinski4ddupej_pre_offset; // -@363
//uniform int fnewton_plane; // -@364
//uniform bool fnewton_intersection_mode; // -@364
//uniform int fnewtondupea_plane; // -@365
//uniform bool fnewtondupea_intersection_mode; // -@365
//uniform int fnewtondupeb_plane; // -@366
//uniform bool fnewtondupeb_intersection_mode; // -@366
//uniform int fnewtondupec_plane; // -@367
//uniform bool fnewtondupec_intersection_mode; // -@367
//uniform int fnewtonduped_plane; // -@368
//uniform bool fnewtonduped_intersection_mode; // -@368
//uniform int fnewtondupee_plane; // -@369
//uniform bool fnewtondupee_intersection_mode; // -@369
//uniform int fnewtondupef_plane; // -@370
//uniform bool fnewtondupef_intersection_mode; // -@370
//uniform int fnewtondupeg_plane; // -@371
//uniform bool fnewtondupeg_intersection_mode; // -@371
//uniform int fnewtondupeh_plane; // -@372
//uniform bool fnewtondupeh_intersection_mode; // -@372
//uniform int fnewtondupei_plane; // -@373
//uniform bool fnewtondupei_intersection_mode; // -@373
//uniform int fnewtondupej_plane; // -@374
//uniform bool fnewtondupej_intersection_mode; // -@374
//uniform vec3 foctahedron_position; // -@375
//uniform float foctahedron_size; // -@375
//uniform vec3 foctahedrondupea_position; // -@376
//uniform float foctahedrondupea_size; // -@376
//uniform vec3 foctahedrondupeb_position; // -@377
//uniform float foctahedrondupeb_size; // -@377
//uniform vec3 foctahedrondupec_position; // -@378
//uniform float foctahedrondupec_size; // -@378
//uniform vec3 foctahedronduped_position; // -@379
//uniform float foctahedronduped_size; // -@379
//uniform vec3 foctahedrondupee_position; // -@380
//uniform float foctahedrondupee_size; // -@380
//uniform vec3 foctahedrondupef_position; // -@381
//uniform float foctahedrondupef_size; // -@381
//uniform vec3 foctahedrondupeg_position; // -@382
//uniform float foctahedrondupeg_size; // -@382
//uniform vec3 foctahedrondupeh_position; // -@383
//uniform float foctahedrondupeh_size; // -@383
//uniform vec3 foctahedrondupei_position; // -@384
//uniform float foctahedrondupei_size; // -@384
//uniform vec3 foctahedrondupej_position; // -@385
//uniform float foctahedrondupej_size; // -@385
//uniform float foctkoch_scale; // -@386
//uniform vec3 foctkoch_offset; // -@386
//uniform vec3 foctkoch_fold; // -@386
//uniform bool foctkoch_abs; // -@386
//uniform vec3 foctkoch_rotation1; // -@386
//uniform vec3 foctkoch_rotation2; // -@386
//uniform float foctkochdupea_scale; // -@387
//uniform vec3 foctkochdupea_offset; // -@387
//uniform vec3 foctkochdupea_fold; // -@387
//uniform bool foctkochdupea_abs; // -@387
//uniform vec3 foctkochdupea_rotation1; // -@387
//uniform vec3 foctkochdupea_rotation2; // -@387
//uniform float foctkochdupeb_scale; // -@388
//uniform vec3 foctkochdupeb_offset; // -@388
//uniform vec3 foctkochdupeb_fold; // -@388
//uniform bool foctkochdupeb_abs; // -@388
//uniform vec3 foctkochdupeb_rotation1; // -@388
//uniform vec3 foctkochdupeb_rotation2; // -@388
//uniform float foctkochdupec_scale; // -@389
//uniform vec3 foctkochdupec_offset; // -@389
//uniform vec3 foctkochdupec_fold; // -@389
//uniform bool foctkochdupec_abs; // -@389
//uniform vec3 foctkochdupec_rotation1; // -@389
//uniform vec3 foctkochdupec_rotation2; // -@389
//uniform float foctkochduped_scale; // -@390
//uniform vec3 foctkochduped_offset; // -@390
//uniform vec3 foctkochduped_fold; // -@390
//uniform bool foctkochduped_abs; // -@390
//uniform vec3 foctkochduped_rotation1; // -@390
//uniform vec3 foctkochduped_rotation2; // -@390
//uniform float foctkochdupee_scale; // -@391
//uniform vec3 foctkochdupee_offset; // -@391
//uniform vec3 foctkochdupee_fold; // -@391
//uniform bool foctkochdupee_abs; // -@391
//uniform vec3 foctkochdupee_rotation1; // -@391
//uniform vec3 foctkochdupee_rotation2; // -@391
//uniform float foctkochdupef_scale; // -@392
//uniform vec3 foctkochdupef_offset; // -@392
//uniform vec3 foctkochdupef_fold; // -@392
//uniform bool foctkochdupef_abs; // -@392
//uniform vec3 foctkochdupef_rotation1; // -@392
//uniform vec3 foctkochdupef_rotation2; // -@392
//uniform float foctkochdupeg_scale; // -@393
//uniform vec3 foctkochdupeg_offset; // -@393
//uniform vec3 foctkochdupeg_fold; // -@393
//uniform bool foctkochdupeg_abs; // -@393
//uniform vec3 foctkochdupeg_rotation1; // -@393
//uniform vec3 foctkochdupeg_rotation2; // -@393
//uniform float foctkochdupeh_scale; // -@394
//uniform vec3 foctkochdupeh_offset; // -@394
//uniform vec3 foctkochdupeh_fold; // -@394
//uniform bool foctkochdupeh_abs; // -@394
//uniform vec3 foctkochdupeh_rotation1; // -@394
//uniform vec3 foctkochdupeh_rotation2; // -@394
//uniform float foctkochdupei_scale; // -@395
//uniform vec3 foctkochdupei_offset; // -@395
//uniform vec3 foctkochdupei_fold; // -@395
//uniform bool foctkochdupei_abs; // -@395
//uniform vec3 foctkochdupei_rotation1; // -@395
//uniform vec3 foctkochdupei_rotation2; // -@395
//uniform float foctkochdupej_scale; // -@396
//uniform vec3 foctkochdupej_offset; // -@396
//uniform vec3 foctkochdupej_fold; // -@396
//uniform bool foctkochdupej_abs; // -@396
//uniform vec3 foctkochdupej_rotation1; // -@396
//uniform vec3 foctkochdupej_rotation2; // -@396
//uniform vec3 fplane_position; // -@397
//uniform vec3 fplane_direction; // -@397
//uniform bool fplane_thin; // -@397
//uniform float fplane_thickness; // -@397
//uniform vec3 fplanedupea_position; // -@398
//uniform vec3 fplanedupea_direction; // -@398
//uniform bool fplanedupea_thin; // -@398
//uniform float fplanedupea_thickness; // -@398
//uniform vec3 fplanedupeb_position; // -@399
//uniform vec3 fplanedupeb_direction; // -@399
//uniform bool fplanedupeb_thin; // -@399
//uniform float fplanedupeb_thickness; // -@399
//uniform vec3 fplanedupec_position; // -@400
//uniform vec3 fplanedupec_direction; // -@400
//uniform bool fplanedupec_thin; // -@400
//uniform float fplanedupec_thickness; // -@400
//uniform vec3 fplaneduped_position; // -@401
//uniform vec3 fplaneduped_direction; // -@401
//uniform bool fplaneduped_thin; // -@401
//uniform float fplaneduped_thickness; // -@401
//uniform vec3 fplanedupee_position; // -@402
//uniform vec3 fplanedupee_direction; // -@402
//uniform bool fplanedupee_thin; // -@402
//uniform float fplanedupee_thickness; // -@402
//uniform vec3 fplanedupef_position; // -@403
//uniform vec3 fplanedupef_direction; // -@403
//uniform bool fplanedupef_thin; // -@403
//uniform float fplanedupef_thickness; // -@403
//uniform vec3 fplanedupeg_position; // -@404
//uniform vec3 fplanedupeg_direction; // -@404
//uniform bool fplanedupeg_thin; // -@404
//uniform float fplanedupeg_thickness; // -@404
//uniform vec3 fplanedupeh_position; // -@405
//uniform vec3 fplanedupeh_direction; // -@405
//uniform bool fplanedupeh_thin; // -@405
//uniform float fplanedupeh_thickness; // -@405
//uniform vec3 fplanedupei_position; // -@406
//uniform vec3 fplanedupei_direction; // -@406
//uniform bool fplanedupei_thin; // -@406
//uniform float fplanedupei_thickness; // -@406
//uniform vec3 fplanedupej_position; // -@407
//uniform vec3 fplanedupej_direction; // -@407
//uniform bool fplanedupej_thin; // -@407
//uniform float fplanedupej_thickness; // -@407
//uniform float fplatonickoch_stretch; // -@408
//uniform float fplatonickoch_postscale; // -@408
//uniform float fplatonickoch_zfix; // -@408
//uniform vec3 fplatonickoch_add; // -@408
//uniform float fplatonickochdupea_stretch; // -@409
//uniform float fplatonickochdupea_postscale; // -@409
//uniform float fplatonickochdupea_zfix; // -@409
//uniform vec3 fplatonickochdupea_add; // -@409
//uniform float fplatonickochdupeb_stretch; // -@410
//uniform float fplatonickochdupeb_postscale; // -@410
//uniform float fplatonickochdupeb_zfix; // -@410
//uniform vec3 fplatonickochdupeb_add; // -@410
//uniform float fplatonickochdupec_stretch; // -@411
//uniform float fplatonickochdupec_postscale; // -@411
//uniform float fplatonickochdupec_zfix; // -@411
//uniform vec3 fplatonickochdupec_add; // -@411
//uniform float fplatonickochduped_stretch; // -@412
//uniform float fplatonickochduped_postscale; // -@412
//uniform float fplatonickochduped_zfix; // -@412
//uniform vec3 fplatonickochduped_add; // -@412
//uniform float fplatonickochdupee_stretch; // -@413
//uniform float fplatonickochdupee_postscale; // -@413
//uniform float fplatonickochdupee_zfix; // -@413
//uniform vec3 fplatonickochdupee_add; // -@413
//uniform float fplatonickochdupef_stretch; // -@414
//uniform float fplatonickochdupef_postscale; // -@414
//uniform float fplatonickochdupef_zfix; // -@414
//uniform vec3 fplatonickochdupef_add; // -@414
//uniform float fplatonickochdupeg_stretch; // -@415
//uniform float fplatonickochdupeg_postscale; // -@415
//uniform float fplatonickochdupeg_zfix; // -@415
//uniform vec3 fplatonickochdupeg_add; // -@415
//uniform float fplatonickochdupeh_stretch; // -@416
//uniform float fplatonickochdupeh_postscale; // -@416
//uniform float fplatonickochdupeh_zfix; // -@416
//uniform vec3 fplatonickochdupeh_add; // -@416
//uniform float fplatonickochdupei_stretch; // -@417
//uniform float fplatonickochdupei_postscale; // -@417
//uniform float fplatonickochdupei_zfix; // -@417
//uniform vec3 fplatonickochdupei_add; // -@417
//uniform float fplatonickochdupej_stretch; // -@418
//uniform float fplatonickochdupej_postscale; // -@418
//uniform float fplatonickochdupej_zfix; // -@418
//uniform vec3 fplatonickochdupej_add; // -@418
//uniform vec4 fpseudoklenian_min; // -@419
//uniform vec4 fpseudoklenian_max; // -@419
//uniform float fpseudoklenian_sign; // -@419
//uniform float fpseudoklenian_scale; // -@419
//uniform vec4 fpseudokleniandupea_min; // -@420
//uniform vec4 fpseudokleniandupea_max; // -@420
//uniform float fpseudokleniandupea_sign; // -@420
//uniform float fpseudokleniandupea_scale; // -@420
//uniform vec4 fpseudokleniandupeb_min; // -@421
//uniform vec4 fpseudokleniandupeb_max; // -@421
//uniform float fpseudokleniandupeb_sign; // -@421
//uniform float fpseudokleniandupeb_scale; // -@421
//uniform vec4 fpseudokleniandupec_min; // -@422
//uniform vec4 fpseudokleniandupec_max; // -@422
//uniform float fpseudokleniandupec_sign; // -@422
//uniform float fpseudokleniandupec_scale; // -@422
//uniform vec4 fpseudoklenianduped_min; // -@423
//uniform vec4 fpseudoklenianduped_max; // -@423
//uniform float fpseudoklenianduped_sign; // -@423
//uniform float fpseudoklenianduped_scale; // -@423
//uniform vec4 fpseudokleniandupee_min; // -@424
//uniform vec4 fpseudokleniandupee_max; // -@424
//uniform float fpseudokleniandupee_sign; // -@424
//uniform float fpseudokleniandupee_scale; // -@424
//uniform vec4 fpseudokleniandupef_min; // -@425
//uniform vec4 fpseudokleniandupef_max; // -@425
//uniform float fpseudokleniandupef_sign; // -@425
//uniform float fpseudokleniandupef_scale; // -@425
//uniform vec4 fpseudokleniandupeg_min; // -@426
//uniform vec4 fpseudokleniandupeg_max; // -@426
//uniform float fpseudokleniandupeg_sign; // -@426
//uniform float fpseudokleniandupeg_scale; // -@426
//uniform vec4 fpseudokleniandupeh_min; // -@427
//uniform vec4 fpseudokleniandupeh_max; // -@427
//uniform float fpseudokleniandupeh_sign; // -@427
//uniform float fpseudokleniandupeh_scale; // -@427
//uniform vec4 fpseudokleniandupei_min; // -@428
//uniform vec4 fpseudokleniandupei_max; // -@428
//uniform float fpseudokleniandupei_sign; // -@428
//uniform float fpseudokleniandupei_scale; // -@428
//uniform vec4 fpseudokleniandupej_min; // -@429
//uniform vec4 fpseudokleniandupej_max; // -@429
//uniform float fpseudokleniandupej_sign; // -@429
//uniform float fpseudokleniandupej_scale; // -@429
//uniform vec2 fquadratickoch_octahedron_limit; // -@430
//uniform vec3 fquadratickoch_octahedron_offset; // -@430
//uniform vec3 fquadratickoch_octahedron_offset2; // -@430
//uniform vec3 fquadratickoch_octahedron_; // -@430
//uniform vec3 fquadratickoch_offset; // -@430
//uniform vec2 fquadratickoch_scale; // -@430
//uniform vec3 fquadratickoch_rotation1; // -@430
//uniform vec3 fquadratickoch_rotation2; // -@430
//uniform float fquadratickoch_abs_offset; // -@430
//uniform vec2 fquadratickochdupea_octahedron_limit; // -@431
//uniform vec3 fquadratickochdupea_octahedron_offset; // -@431
//uniform vec3 fquadratickochdupea_octahedron_offset2; // -@431
//uniform vec3 fquadratickochdupea_octahedron_; // -@431
//uniform vec3 fquadratickochdupea_offset; // -@431
//uniform vec2 fquadratickochdupea_scale; // -@431
//uniform vec3 fquadratickochdupea_rotation1; // -@431
//uniform vec3 fquadratickochdupea_rotation2; // -@431
//uniform float fquadratickochdupea_abs_offset; // -@431
//uniform vec2 fquadratickochdupeb_octahedron_limit; // -@432
//uniform vec3 fquadratickochdupeb_octahedron_offset; // -@432
//uniform vec3 fquadratickochdupeb_octahedron_offset2; // -@432
//uniform vec3 fquadratickochdupeb_octahedron_; // -@432
//uniform vec3 fquadratickochdupeb_offset; // -@432
//uniform vec2 fquadratickochdupeb_scale; // -@432
//uniform vec3 fquadratickochdupeb_rotation1; // -@432
//uniform vec3 fquadratickochdupeb_rotation2; // -@432
//uniform float fquadratickochdupeb_abs_offset; // -@432
//uniform vec2 fquadratickochdupec_octahedron_limit; // -@433
//uniform vec3 fquadratickochdupec_octahedron_offset; // -@433
//uniform vec3 fquadratickochdupec_octahedron_offset2; // -@433
//uniform vec3 fquadratickochdupec_octahedron_; // -@433
//uniform vec3 fquadratickochdupec_offset; // -@433
//uniform vec2 fquadratickochdupec_scale; // -@433
//uniform vec3 fquadratickochdupec_rotation1; // -@433
//uniform vec3 fquadratickochdupec_rotation2; // -@433
//uniform float fquadratickochdupec_abs_offset; // -@433
//uniform vec2 fquadratickochduped_octahedron_limit; // -@434
//uniform vec3 fquadratickochduped_octahedron_offset; // -@434
//uniform vec3 fquadratickochduped_octahedron_offset2; // -@434
//uniform vec3 fquadratickochduped_octahedron_; // -@434
//uniform vec3 fquadratickochduped_offset; // -@434
//uniform vec2 fquadratickochduped_scale; // -@434
//uniform vec3 fquadratickochduped_rotation1; // -@434
//uniform vec3 fquadratickochduped_rotation2; // -@434
//uniform float fquadratickochduped_abs_offset; // -@434
//uniform vec2 fquadratickochdupee_octahedron_limit; // -@435
//uniform vec3 fquadratickochdupee_octahedron_offset; // -@435
//uniform vec3 fquadratickochdupee_octahedron_offset2; // -@435
//uniform vec3 fquadratickochdupee_octahedron_; // -@435
//uniform vec3 fquadratickochdupee_offset; // -@435
//uniform vec2 fquadratickochdupee_scale; // -@435
//uniform vec3 fquadratickochdupee_rotation1; // -@435
//uniform vec3 fquadratickochdupee_rotation2; // -@435
//uniform float fquadratickochdupee_abs_offset; // -@435
//uniform vec2 fquadratickochdupef_octahedron_limit; // -@436
//uniform vec3 fquadratickochdupef_octahedron_offset; // -@436
//uniform vec3 fquadratickochdupef_octahedron_offset2; // -@436
//uniform vec3 fquadratickochdupef_octahedron_; // -@436
//uniform vec3 fquadratickochdupef_offset; // -@436
//uniform vec2 fquadratickochdupef_scale; // -@436
//uniform vec3 fquadratickochdupef_rotation1; // -@436
//uniform vec3 fquadratickochdupef_rotation2; // -@436
//uniform float fquadratickochdupef_abs_offset; // -@436
//uniform vec2 fquadratickochdupeg_octahedron_limit; // -@437
//uniform vec3 fquadratickochdupeg_octahedron_offset; // -@437
//uniform vec3 fquadratickochdupeg_octahedron_offset2; // -@437
//uniform vec3 fquadratickochdupeg_octahedron_; // -@437
//uniform vec3 fquadratickochdupeg_offset; // -@437
//uniform vec2 fquadratickochdupeg_scale; // -@437
//uniform vec3 fquadratickochdupeg_rotation1; // -@437
//uniform vec3 fquadratickochdupeg_rotation2; // -@437
//uniform float fquadratickochdupeg_abs_offset; // -@437
//uniform vec2 fquadratickochdupeh_octahedron_limit; // -@438
//uniform vec3 fquadratickochdupeh_octahedron_offset; // -@438
//uniform vec3 fquadratickochdupeh_octahedron_offset2; // -@438
//uniform vec3 fquadratickochdupeh_octahedron_; // -@438
//uniform vec3 fquadratickochdupeh_offset; // -@438
//uniform vec2 fquadratickochdupeh_scale; // -@438
//uniform vec3 fquadratickochdupeh_rotation1; // -@438
//uniform vec3 fquadratickochdupeh_rotation2; // -@438
//uniform float fquadratickochdupeh_abs_offset; // -@438
//uniform vec2 fquadratickochdupei_octahedron_limit; // -@439
//uniform vec3 fquadratickochdupei_octahedron_offset; // -@439
//uniform vec3 fquadratickochdupei_octahedron_offset2; // -@439
//uniform vec3 fquadratickochdupei_octahedron_; // -@439
//uniform vec3 fquadratickochdupei_offset; // -@439
//uniform vec2 fquadratickochdupei_scale; // -@439
//uniform vec3 fquadratickochdupei_rotation1; // -@439
//uniform vec3 fquadratickochdupei_rotation2; // -@439
//uniform float fquadratickochdupei_abs_offset; // -@439
//uniform vec2 fquadratickochdupej_octahedron_limit; // -@440
//uniform vec3 fquadratickochdupej_octahedron_offset; // -@440
//uniform vec3 fquadratickochdupej_octahedron_offset2; // -@440
//uniform vec3 fquadratickochdupej_octahedron_; // -@440
//uniform vec3 fquadratickochdupej_offset; // -@440
//uniform vec2 fquadratickochdupej_scale; // -@440
//uniform vec3 fquadratickochdupej_rotation1; // -@440
//uniform vec3 fquadratickochdupej_rotation2; // -@440
//uniform float fquadratickochdupej_abs_offset; // -@440
//uniform int freciprocaltransform_axis; // -@441
//uniform float freciprocaltransform_offset; // -@441
//uniform vec2 freciprocaltransform_range; // -@441
//uniform int freciprocaltransformdupea_axis; // -@442
//uniform float freciprocaltransformdupea_offset; // -@442
//uniform vec2 freciprocaltransformdupea_range; // -@442
//uniform int freciprocaltransformdupeb_axis; // -@443
//uniform float freciprocaltransformdupeb_offset; // -@443
//uniform vec2 freciprocaltransformdupeb_range; // -@443
//uniform int freciprocaltransformdupec_axis; // -@444
//uniform float freciprocaltransformdupec_offset; // -@444
//uniform vec2 freciprocaltransformdupec_range; // -@444
//uniform int freciprocaltransformduped_axis; // -@445
//uniform float freciprocaltransformduped_offset; // -@445
//uniform vec2 freciprocaltransformduped_range; // -@445
//uniform int freciprocaltransformdupee_axis; // -@446
//uniform float freciprocaltransformdupee_offset; // -@446
//uniform vec2 freciprocaltransformdupee_range; // -@446
//uniform int freciprocaltransformdupef_axis; // -@447
//uniform float freciprocaltransformdupef_offset; // -@447
//uniform vec2 freciprocaltransformdupef_range; // -@447
//uniform int freciprocaltransformdupeg_axis; // -@448
//uniform float freciprocaltransformdupeg_offset; // -@448
//uniform vec2 freciprocaltransformdupeg_range; // -@448
//uniform int freciprocaltransformdupeh_axis; // -@449
//uniform float freciprocaltransformdupeh_offset; // -@449
//uniform vec2 freciprocaltransformdupeh_range; // -@449
//uniform int freciprocaltransformdupei_axis; // -@450
//uniform float freciprocaltransformdupei_offset; // -@450
//uniform vec2 freciprocaltransformdupei_range; // -@450
//uniform int freciprocaltransformdupej_axis; // -@451
//uniform float freciprocaltransformdupej_offset; // -@451
//uniform vec2 freciprocaltransformdupej_range; // -@451
//uniform vec3 fsierpinskidodecahedron_offset; // -@463
//uniform vec3 fsierpinskidodecahedron_rotation1; // -@463
//uniform vec3 fsierpinskidodecahedron_rotation2; // -@463
//uniform float fsierpinskidodecahedron_scale; // -@463
//uniform vec3 fsierpinskidodecahedrondupea_offset; // -@464
//uniform vec3 fsierpinskidodecahedrondupea_rotation1; // -@464
//uniform vec3 fsierpinskidodecahedrondupea_rotation2; // -@464
//uniform float fsierpinskidodecahedrondupea_scale; // -@464
//uniform vec3 fsierpinskidodecahedrondupeb_offset; // -@465
//uniform vec3 fsierpinskidodecahedrondupeb_rotation1; // -@465
//uniform vec3 fsierpinskidodecahedrondupeb_rotation2; // -@465
//uniform float fsierpinskidodecahedrondupeb_scale; // -@465
//uniform vec3 fsierpinskidodecahedrondupec_offset; // -@466
//uniform vec3 fsierpinskidodecahedrondupec_rotation1; // -@466
//uniform vec3 fsierpinskidodecahedrondupec_rotation2; // -@466
//uniform float fsierpinskidodecahedrondupec_scale; // -@466
//uniform vec3 fsierpinskidodecahedronduped_offset; // -@467
//uniform vec3 fsierpinskidodecahedronduped_rotation1; // -@467
//uniform vec3 fsierpinskidodecahedronduped_rotation2; // -@467
//uniform float fsierpinskidodecahedronduped_scale; // -@467
//uniform vec3 fsierpinskidodecahedrondupee_offset; // -@468
//uniform vec3 fsierpinskidodecahedrondupee_rotation1; // -@468
//uniform vec3 fsierpinskidodecahedrondupee_rotation2; // -@468
//uniform float fsierpinskidodecahedrondupee_scale; // -@468
//uniform vec3 fsierpinskidodecahedrondupef_offset; // -@469
//uniform vec3 fsierpinskidodecahedrondupef_rotation1; // -@469
//uniform vec3 fsierpinskidodecahedrondupef_rotation2; // -@469
//uniform float fsierpinskidodecahedrondupef_scale; // -@469
//uniform vec3 fsierpinskidodecahedrondupeg_offset; // -@470
//uniform vec3 fsierpinskidodecahedrondupeg_rotation1; // -@470
//uniform vec3 fsierpinskidodecahedrondupeg_rotation2; // -@470
//uniform float fsierpinskidodecahedrondupeg_scale; // -@470
//uniform vec3 fsierpinskidodecahedrondupeh_offset; // -@471
//uniform vec3 fsierpinskidodecahedrondupeh_rotation1; // -@471
//uniform vec3 fsierpinskidodecahedrondupeh_rotation2; // -@471
//uniform float fsierpinskidodecahedrondupeh_scale; // -@471
//uniform vec3 fsierpinskidodecahedrondupei_offset; // -@472
//uniform vec3 fsierpinskidodecahedrondupei_rotation1; // -@472
//uniform vec3 fsierpinskidodecahedrondupei_rotation2; // -@472
//uniform float fsierpinskidodecahedrondupei_scale; // -@472
//uniform vec3 fsierpinskidodecahedrondupej_offset; // -@473
//uniform vec3 fsierpinskidodecahedrondupej_rotation1; // -@473
//uniform vec3 fsierpinskidodecahedrondupej_rotation2; // -@473
//uniform float fsierpinskidodecahedrondupej_scale; // -@473
//uniform vec3 fsierpinskiicosahedron_offset; // -@474
//uniform vec3 fsierpinskiicosahedron_rotation1; // -@474
//uniform vec3 fsierpinskiicosahedron_rotation2; // -@474
//uniform float fsierpinskiicosahedron_scale; // -@474
//uniform vec3 fsierpinskiicosahedrondupea_offset; // -@475
//uniform vec3 fsierpinskiicosahedrondupea_rotation1; // -@475
//uniform vec3 fsierpinskiicosahedrondupea_rotation2; // -@475
//uniform float fsierpinskiicosahedrondupea_scale; // -@475
//uniform vec3 fsierpinskiicosahedrondupeb_offset; // -@476
//uniform vec3 fsierpinskiicosahedrondupeb_rotation1; // -@476
//uniform vec3 fsierpinskiicosahedrondupeb_rotation2; // -@476
//uniform float fsierpinskiicosahedrondupeb_scale; // -@476
//uniform vec3 fsierpinskiicosahedrondupec_offset; // -@477
//uniform vec3 fsierpinskiicosahedrondupec_rotation1; // -@477
//uniform vec3 fsierpinskiicosahedrondupec_rotation2; // -@477
//uniform float fsierpinskiicosahedrondupec_scale; // -@477
//uniform vec3 fsierpinskiicosahedronduped_offset; // -@478
//uniform vec3 fsierpinskiicosahedronduped_rotation1; // -@478
//uniform vec3 fsierpinskiicosahedronduped_rotation2; // -@478
//uniform float fsierpinskiicosahedronduped_scale; // -@478
//uniform vec3 fsierpinskiicosahedrondupee_offset; // -@479
//uniform vec3 fsierpinskiicosahedrondupee_rotation1; // -@479
//uniform vec3 fsierpinskiicosahedrondupee_rotation2; // -@479
//uniform float fsierpinskiicosahedrondupee_scale; // -@479
//uniform vec3 fsierpinskiicosahedrondupef_offset; // -@480
//uniform vec3 fsierpinskiicosahedrondupef_rotation1; // -@480
//uniform vec3 fsierpinskiicosahedrondupef_rotation2; // -@480
//uniform float fsierpinskiicosahedrondupef_scale; // -@480
//uniform vec3 fsierpinskiicosahedrondupeg_offset; // -@481
//uniform vec3 fsierpinskiicosahedrondupeg_rotation1; // -@481
//uniform vec3 fsierpinskiicosahedrondupeg_rotation2; // -@481
//uniform float fsierpinskiicosahedrondupeg_scale; // -@481
//uniform vec3 fsierpinskiicosahedrondupeh_offset; // -@482
//uniform vec3 fsierpinskiicosahedrondupeh_rotation1; // -@482
//uniform vec3 fsierpinskiicosahedrondupeh_rotation2; // -@482
//uniform float fsierpinskiicosahedrondupeh_scale; // -@482
//uniform vec3 fsierpinskiicosahedrondupei_offset; // -@483
//uniform vec3 fsierpinskiicosahedrondupei_rotation1; // -@483
//uniform vec3 fsierpinskiicosahedrondupei_rotation2; // -@483
//uniform float fsierpinskiicosahedrondupei_scale; // -@483
//uniform vec3 fsierpinskiicosahedrondupej_offset; // -@484
//uniform vec3 fsierpinskiicosahedrondupej_rotation1; // -@484
//uniform vec3 fsierpinskiicosahedrondupej_rotation2; // -@484
//uniform float fsierpinskiicosahedrondupej_scale; // -@484
//uniform vec3 fsierpinskioctahedron_rotation1; // -@485
//uniform vec3 fsierpinskioctahedron_rotation2; // -@485
//uniform vec3 fsierpinskioctahedron_offset; // -@485
//uniform float fsierpinskioctahedron_scale; // -@485
//uniform vec3 fsierpinskioctahedrondupea_rotation1; // -@486
//uniform vec3 fsierpinskioctahedrondupea_rotation2; // -@486
//uniform vec3 fsierpinskioctahedrondupea_offset; // -@486
//uniform float fsierpinskioctahedrondupea_scale; // -@486
//uniform vec3 fsierpinskioctahedrondupeb_rotation1; // -@487
//uniform vec3 fsierpinskioctahedrondupeb_rotation2; // -@487
//uniform vec3 fsierpinskioctahedrondupeb_offset; // -@487
//uniform float fsierpinskioctahedrondupeb_scale; // -@487
//uniform vec3 fsierpinskioctahedrondupec_rotation1; // -@488
//uniform vec3 fsierpinskioctahedrondupec_rotation2; // -@488
//uniform vec3 fsierpinskioctahedrondupec_offset; // -@488
//uniform float fsierpinskioctahedrondupec_scale; // -@488
//uniform vec3 fsierpinskioctahedronduped_rotation1; // -@489
//uniform vec3 fsierpinskioctahedronduped_rotation2; // -@489
//uniform vec3 fsierpinskioctahedronduped_offset; // -@489
//uniform float fsierpinskioctahedronduped_scale; // -@489
//uniform vec3 fsierpinskioctahedrondupee_rotation1; // -@490
//uniform vec3 fsierpinskioctahedrondupee_rotation2; // -@490
//uniform vec3 fsierpinskioctahedrondupee_offset; // -@490
//uniform float fsierpinskioctahedrondupee_scale; // -@490
//uniform vec3 fsierpinskioctahedrondupef_rotation1; // -@491
//uniform vec3 fsierpinskioctahedrondupef_rotation2; // -@491
//uniform vec3 fsierpinskioctahedrondupef_offset; // -@491
//uniform float fsierpinskioctahedrondupef_scale; // -@491
//uniform vec3 fsierpinskioctahedrondupeg_rotation1; // -@492
//uniform vec3 fsierpinskioctahedrondupeg_rotation2; // -@492
//uniform vec3 fsierpinskioctahedrondupeg_offset; // -@492
//uniform float fsierpinskioctahedrondupeg_scale; // -@492
//uniform vec3 fsierpinskioctahedrondupeh_rotation1; // -@493
//uniform vec3 fsierpinskioctahedrondupeh_rotation2; // -@493
//uniform vec3 fsierpinskioctahedrondupeh_offset; // -@493
//uniform float fsierpinskioctahedrondupeh_scale; // -@493
//uniform vec3 fsierpinskioctahedrondupei_rotation1; // -@494
//uniform vec3 fsierpinskioctahedrondupei_rotation2; // -@494
//uniform vec3 fsierpinskioctahedrondupei_offset; // -@494
//uniform float fsierpinskioctahedrondupei_scale; // -@494
//uniform vec3 fsierpinskioctahedrondupej_rotation1; // -@495
//uniform vec3 fsierpinskioctahedrondupej_rotation2; // -@495
//uniform vec3 fsierpinskioctahedrondupej_offset; // -@495
//uniform float fsierpinskioctahedrondupej_scale; // -@495
//uniform vec3 fsierpinskitetrahedron_offset; // -@496
//uniform vec3 fsierpinskitetrahedron_rotation1; // -@496
//uniform vec3 fsierpinskitetrahedron_rotation2; // -@496
//uniform float fsierpinskitetrahedron_scale; // -@496
//uniform vec3 fsierpinskitetrahedrondupea_offset; // -@497
//uniform vec3 fsierpinskitetrahedrondupea_rotation1; // -@497
//uniform vec3 fsierpinskitetrahedrondupea_rotation2; // -@497
//uniform float fsierpinskitetrahedrondupea_scale; // -@497
//uniform vec3 fsierpinskitetrahedrondupeb_offset; // -@498
//uniform vec3 fsierpinskitetrahedrondupeb_rotation1; // -@498
//uniform vec3 fsierpinskitetrahedrondupeb_rotation2; // -@498
//uniform float fsierpinskitetrahedrondupeb_scale; // -@498
//uniform vec3 fsierpinskitetrahedrondupec_offset; // -@499
//uniform vec3 fsierpinskitetrahedrondupec_rotation1; // -@499
//uniform vec3 fsierpinskitetrahedrondupec_rotation2; // -@499
//uniform float fsierpinskitetrahedrondupec_scale; // -@499
//uniform vec3 fsierpinskitetrahedronduped_offset; // -@500
//uniform vec3 fsierpinskitetrahedronduped_rotation1; // -@500
//uniform vec3 fsierpinskitetrahedronduped_rotation2; // -@500
//uniform float fsierpinskitetrahedronduped_scale; // -@500
//uniform vec3 fsierpinskitetrahedrondupee_offset; // -@501
//uniform vec3 fsierpinskitetrahedrondupee_rotation1; // -@501
//uniform vec3 fsierpinskitetrahedrondupee_rotation2; // -@501
//uniform float fsierpinskitetrahedrondupee_scale; // -@501
//uniform vec3 fsierpinskitetrahedrondupef_offset; // -@502
//uniform vec3 fsierpinskitetrahedrondupef_rotation1; // -@502
//uniform vec3 fsierpinskitetrahedrondupef_rotation2; // -@502
//uniform float fsierpinskitetrahedrondupef_scale; // -@502
//uniform vec3 fsierpinskitetrahedrondupeg_offset; // -@503
//uniform vec3 fsierpinskitetrahedrondupeg_rotation1; // -@503
//uniform vec3 fsierpinskitetrahedrondupeg_rotation2; // -@503
//uniform float fsierpinskitetrahedrondupeg_scale; // -@503
//uniform vec3 fsierpinskitetrahedrondupeh_offset; // -@504
//uniform vec3 fsierpinskitetrahedrondupeh_rotation1; // -@504
//uniform vec3 fsierpinskitetrahedrondupeh_rotation2; // -@504
//uniform float fsierpinskitetrahedrondupeh_scale; // -@504
//uniform vec3 fsierpinskitetrahedrondupei_offset; // -@505
//uniform vec3 fsierpinskitetrahedrondupei_rotation1; // -@505
//uniform vec3 fsierpinskitetrahedrondupei_rotation2; // -@505
//uniform float fsierpinskitetrahedrondupei_scale; // -@505
//uniform vec3 fsierpinskitetrahedrondupej_offset; // -@506
//uniform vec3 fsierpinskitetrahedrondupej_rotation1; // -@506
//uniform vec3 fsierpinskitetrahedrondupej_rotation2; // -@506
//uniform float fsierpinskitetrahedrondupej_scale; // -@506
//uniform int fsintransform_axis; // -@507
//uniform vec2 fsintransform_offset; // -@507
//uniform vec2 fsintransform_scale; // -@507
//uniform vec2 fsintransform_range; // -@507
//uniform int fsintransformdupea_axis; // -@508
//uniform vec2 fsintransformdupea_offset; // -@508
//uniform vec2 fsintransformdupea_scale; // -@508
//uniform vec2 fsintransformdupea_range; // -@508
//uniform int fsintransformdupeb_axis; // -@509
//uniform vec2 fsintransformdupeb_offset; // -@509
//uniform vec2 fsintransformdupeb_scale; // -@509
//uniform vec2 fsintransformdupeb_range; // -@509
//uniform int fsintransformdupec_axis; // -@510
//uniform vec2 fsintransformdupec_offset; // -@510
//uniform vec2 fsintransformdupec_scale; // -@510
//uniform vec2 fsintransformdupec_range; // -@510
//uniform int fsintransformduped_axis; // -@511
//uniform vec2 fsintransformduped_offset; // -@511
//uniform vec2 fsintransformduped_scale; // -@511
//uniform vec2 fsintransformduped_range; // -@511
//uniform int fsintransformdupee_axis; // -@512
//uniform vec2 fsintransformdupee_offset; // -@512
//uniform vec2 fsintransformdupee_scale; // -@512
//uniform vec2 fsintransformdupee_range; // -@512
//uniform int fsintransformdupef_axis; // -@513
//uniform vec2 fsintransformdupef_offset; // -@513
//uniform vec2 fsintransformdupef_scale; // -@513
//uniform vec2 fsintransformdupef_range; // -@513
//uniform int fsintransformdupeg_axis; // -@514
//uniform vec2 fsintransformdupeg_offset; // -@514
//uniform vec2 fsintransformdupeg_scale; // -@514
//uniform vec2 fsintransformdupeg_range; // -@514
//uniform int fsintransformdupeh_axis; // -@515
//uniform vec2 fsintransformdupeh_offset; // -@515
//uniform vec2 fsintransformdupeh_scale; // -@515
//uniform vec2 fsintransformdupeh_range; // -@515
//uniform int fsintransformdupei_axis; // -@516
//uniform vec2 fsintransformdupei_offset; // -@516
//uniform vec2 fsintransformdupei_scale; // -@516
//uniform vec2 fsintransformdupei_range; // -@516
//uniform int fsintransformdupej_axis; // -@517
//uniform vec2 fsintransformdupej_offset; // -@517
//uniform vec2 fsintransformdupej_scale; // -@517
//uniform vec2 fsintransformdupej_range; // -@517
//uniform int fsphairahedron_cube_type; // -@518
//uniform float fsphairahedron_zc; // -@518
//uniform float fsphairahedron_zb; // -@518
//uniform int fsphairahedrondupea_cube_type; // -@519
//uniform float fsphairahedrondupea_zc; // -@519
//uniform float fsphairahedrondupea_zb; // -@519
//uniform int fsphairahedrondupeb_cube_type; // -@520
//uniform float fsphairahedrondupeb_zc; // -@520
//uniform float fsphairahedrondupeb_zb; // -@520
//uniform int fsphairahedrondupec_cube_type; // -@521
//uniform float fsphairahedrondupec_zc; // -@521
//uniform float fsphairahedrondupec_zb; // -@521
//uniform int fsphairahedronduped_cube_type; // -@522
//uniform float fsphairahedronduped_zc; // -@522
//uniform float fsphairahedronduped_zb; // -@522
//uniform int fsphairahedrondupee_cube_type; // -@523
//uniform float fsphairahedrondupee_zc; // -@523
//uniform float fsphairahedrondupee_zb; // -@523
//uniform int fsphairahedrondupef_cube_type; // -@524
//uniform float fsphairahedrondupef_zc; // -@524
//uniform float fsphairahedrondupef_zb; // -@524
//uniform int fsphairahedrondupeg_cube_type; // -@525
//uniform float fsphairahedrondupeg_zc; // -@525
//uniform float fsphairahedrondupeg_zb; // -@525
//uniform int fsphairahedrondupeh_cube_type; // -@526
//uniform float fsphairahedrondupeh_zc; // -@526
//uniform float fsphairahedrondupeh_zb; // -@526
//uniform int fsphairahedrondupei_cube_type; // -@527
//uniform float fsphairahedrondupei_zc; // -@527
//uniform float fsphairahedrondupei_zb; // -@527
//uniform int fsphairahedrondupej_cube_type; // -@528
//uniform float fsphairahedrondupej_zc; // -@528
//uniform float fsphairahedrondupej_zb; // -@528
//uniform vec3 fsphere_position; // -@529
//uniform float fsphere_radius; // -@529
//uniform bool fsphere_hollow; // -@529
//uniform float fsphere_hollow_edge; // -@529
//uniform vec3 fspheredupea_position; // -@530
//uniform float fspheredupea_radius; // -@530
//uniform bool fspheredupea_hollow; // -@530
//uniform float fspheredupea_hollow_edge; // -@530
//uniform vec3 fspheredupeb_position; // -@531
//uniform float fspheredupeb_radius; // -@531
//uniform bool fspheredupeb_hollow; // -@531
//uniform float fspheredupeb_hollow_edge; // -@531
//uniform vec3 fspheredupec_position; // -@532
//uniform float fspheredupec_radius; // -@532
//uniform bool fspheredupec_hollow; // -@532
//uniform float fspheredupec_hollow_edge; // -@532
//uniform vec3 fsphereduped_position; // -@533
//uniform float fsphereduped_radius; // -@533
//uniform bool fsphereduped_hollow; // -@533
//uniform float fsphereduped_hollow_edge; // -@533
//uniform vec3 fspheredupee_position; // -@534
//uniform float fspheredupee_radius; // -@534
//uniform bool fspheredupee_hollow; // -@534
//uniform float fspheredupee_hollow_edge; // -@534
//uniform vec3 fspheredupef_position; // -@535
//uniform float fspheredupef_radius; // -@535
//uniform bool fspheredupef_hollow; // -@535
//uniform float fspheredupef_hollow_edge; // -@535
//uniform vec3 fspheredupeg_position; // -@536
//uniform float fspheredupeg_radius; // -@536
//uniform bool fspheredupeg_hollow; // -@536
//uniform float fspheredupeg_hollow_edge; // -@536
//uniform vec3 fspheredupeh_position; // -@537
//uniform float fspheredupeh_radius; // -@537
//uniform bool fspheredupeh_hollow; // -@537
//uniform float fspheredupeh_hollow_edge; // -@537
//uniform vec3 fspheredupei_position; // -@538
//uniform float fspheredupei_radius; // -@538
//uniform bool fspheredupei_hollow; // -@538
//uniform float fspheredupei_hollow_edge; // -@538
//uniform vec3 fspheredupej_position; // -@539
//uniform float fspheredupej_radius; // -@539
//uniform bool fspheredupej_hollow; // -@539
//uniform float fspheredupej_hollow_edge; // -@539
//uniform float fspheretree_symmetry; // -@540
//uniform float fspheretreedupea_symmetry; // -@541
//uniform float fspheretreedupeb_symmetry; // -@542
//uniform float fspheretreedupec_symmetry; // -@543
//uniform float fspheretreeduped_symmetry; // -@544
//uniform float fspheretreedupee_symmetry; // -@545
//uniform float fspheretreedupef_symmetry; // -@546
//uniform float fspheretreedupeg_symmetry; // -@547
//uniform float fspheretreedupeh_symmetry; // -@548
//uniform float fspheretreedupei_symmetry; // -@549
//uniform float fspheretreedupej_symmetry; // -@550
//uniform vec3 ftetrahedron_position; // -@551
//uniform float ftetrahedron_size; // -@551
//uniform vec3 ftetrahedrondupea_position; // -@552
//uniform float ftetrahedrondupea_size; // -@552
//uniform vec3 ftetrahedrondupeb_position; // -@553
//uniform float ftetrahedrondupeb_size; // -@553
//uniform vec3 ftetrahedrondupec_position; // -@554
//uniform float ftetrahedrondupec_size; // -@554
//uniform vec3 ftetrahedronduped_position; // -@555
//uniform float ftetrahedronduped_size; // -@555
//uniform vec3 ftetrahedrondupee_position; // -@556
//uniform float ftetrahedrondupee_size; // -@556
//uniform vec3 ftetrahedrondupef_position; // -@557
//uniform float ftetrahedrondupef_size; // -@557
//uniform vec3 ftetrahedrondupeg_position; // -@558
//uniform float ftetrahedrondupeg_size; // -@558
//uniform vec3 ftetrahedrondupeh_position; // -@559
//uniform float ftetrahedrondupeh_size; // -@559
//uniform vec3 ftetrahedrondupei_position; // -@560
//uniform float ftetrahedrondupei_size; // -@560
//uniform vec3 ftetrahedrondupej_position; // -@561
//uniform float ftetrahedrondupej_size; // -@561
//uniform float ftriescher_scale; // -@562
//uniform vec3 ftriescher_offset; // -@562
//uniform vec3 ftriescher_clamp; // -@562
//uniform vec3 ftriescher_add; // -@562
//uniform vec2 ftriescher_limit; // -@562
//uniform float ftriescher_symmetry; // -@562
//uniform float ftriescherdupea_scale; // -@563
//uniform vec3 ftriescherdupea_offset; // -@563
//uniform vec3 ftriescherdupea_clamp; // -@563
//uniform vec3 ftriescherdupea_add; // -@563
//uniform vec2 ftriescherdupea_limit; // -@563
//uniform float ftriescherdupea_symmetry; // -@563
//uniform float ftriescherdupeb_scale; // -@564
//uniform vec3 ftriescherdupeb_offset; // -@564
//uniform vec3 ftriescherdupeb_clamp; // -@564
//uniform vec3 ftriescherdupeb_add; // -@564
//uniform vec2 ftriescherdupeb_limit; // -@564
//uniform float ftriescherdupeb_symmetry; // -@564
//uniform float ftriescherdupec_scale; // -@565
//uniform vec3 ftriescherdupec_offset; // -@565
//uniform vec3 ftriescherdupec_clamp; // -@565
//uniform vec3 ftriescherdupec_add; // -@565
//uniform vec2 ftriescherdupec_limit; // -@565
//uniform float ftriescherdupec_symmetry; // -@565
//uniform float ftriescherduped_scale; // -@566
//uniform vec3 ftriescherduped_offset; // -@566
//uniform vec3 ftriescherduped_clamp; // -@566
//uniform vec3 ftriescherduped_add; // -@566
//uniform vec2 ftriescherduped_limit; // -@566
//uniform float ftriescherduped_symmetry; // -@566
//uniform float ftriescherdupee_scale; // -@567
//uniform vec3 ftriescherdupee_offset; // -@567
//uniform vec3 ftriescherdupee_clamp; // -@567
//uniform vec3 ftriescherdupee_add; // -@567
//uniform vec2 ftriescherdupee_limit; // -@567
//uniform float ftriescherdupee_symmetry; // -@567
//uniform float ftriescherdupef_scale; // -@568
//uniform vec3 ftriescherdupef_offset; // -@568
//uniform vec3 ftriescherdupef_clamp; // -@568
//uniform vec3 ftriescherdupef_add; // -@568
//uniform vec2 ftriescherdupef_limit; // -@568
//uniform float ftriescherdupef_symmetry; // -@568
//uniform float ftriescherdupeg_scale; // -@569
//uniform vec3 ftriescherdupeg_offset; // -@569
//uniform vec3 ftriescherdupeg_clamp; // -@569
//uniform vec3 ftriescherdupeg_add; // -@569
//uniform vec2 ftriescherdupeg_limit; // -@569
//uniform float ftriescherdupeg_symmetry; // -@569
//uniform float ftriescherdupeh_scale; // -@570
//uniform vec3 ftriescherdupeh_offset; // -@570
//uniform vec3 ftriescherdupeh_clamp; // -@570
//uniform vec3 ftriescherdupeh_add; // -@570
//uniform vec2 ftriescherdupeh_limit; // -@570
//uniform float ftriescherdupeh_symmetry; // -@570
//uniform float ftriescherdupei_scale; // -@571
//uniform vec3 ftriescherdupei_offset; // -@571
//uniform vec3 ftriescherdupei_clamp; // -@571
//uniform vec3 ftriescherdupei_add; // -@571
//uniform vec2 ftriescherdupei_limit; // -@571
//uniform float ftriescherdupei_symmetry; // -@571
//uniform float ftriescherdupej_scale; // -@572
//uniform vec3 ftriescherdupej_offset; // -@572
//uniform vec3 ftriescherdupej_clamp; // -@572
//uniform vec3 ftriescherdupej_add; // -@572
//uniform vec2 ftriescherdupej_limit; // -@572
//uniform float ftriescherdupej_symmetry; // -@572
//uniform bool fvicsek_preserve; // -@573
//uniform bool fvicsek_hex_fold1; // -@573
//uniform int fvicsek_hex_fold2; // -@573
//uniform bool fvicsek_abs1_x; // -@573
//uniform bool fvicsek_abs1_z; // -@573
//uniform vec3 fvicsek_limit; // -@573
//uniform vec3 fvicsek_abs2_minus; // -@573
//uniform vec3 fvicsek_abs2_plus; // -@573
//uniform vec3 fvicsek_offset; // -@573
//uniform vec2 fvicsek_foldt; // -@573
//uniform float fvicsek_scale; // -@573
//uniform vec3 fvicsek_rotation1; // -@573
//uniform vec3 fvicsek_rotation2; // -@573
//uniform bool fvicsekdupea_preserve; // -@574
//uniform bool fvicsekdupea_hex_fold1; // -@574
//uniform int fvicsekdupea_hex_fold2; // -@574
//uniform bool fvicsekdupea_abs1_x; // -@574
//uniform bool fvicsekdupea_abs1_z; // -@574
//uniform vec3 fvicsekdupea_limit; // -@574
//uniform vec3 fvicsekdupea_abs2_minus; // -@574
//uniform vec3 fvicsekdupea_abs2_plus; // -@574
//uniform vec3 fvicsekdupea_offset; // -@574
//uniform vec2 fvicsekdupea_foldt; // -@574
//uniform float fvicsekdupea_scale; // -@574
//uniform vec3 fvicsekdupea_rotation1; // -@574
//uniform vec3 fvicsekdupea_rotation2; // -@574
//uniform bool fvicsekdupeb_preserve; // -@575
//uniform bool fvicsekdupeb_hex_fold1; // -@575
//uniform int fvicsekdupeb_hex_fold2; // -@575
//uniform bool fvicsekdupeb_abs1_x; // -@575
//uniform bool fvicsekdupeb_abs1_z; // -@575
//uniform vec3 fvicsekdupeb_limit; // -@575
//uniform vec3 fvicsekdupeb_abs2_minus; // -@575
//uniform vec3 fvicsekdupeb_abs2_plus; // -@575
//uniform vec3 fvicsekdupeb_offset; // -@575
//uniform vec2 fvicsekdupeb_foldt; // -@575
//uniform float fvicsekdupeb_scale; // -@575
//uniform vec3 fvicsekdupeb_rotation1; // -@575
//uniform vec3 fvicsekdupeb_rotation2; // -@575
//uniform bool fvicsekdupec_preserve; // -@576
//uniform bool fvicsekdupec_hex_fold1; // -@576
//uniform int fvicsekdupec_hex_fold2; // -@576
//uniform bool fvicsekdupec_abs1_x; // -@576
//uniform bool fvicsekdupec_abs1_z; // -@576
//uniform vec3 fvicsekdupec_limit; // -@576
//uniform vec3 fvicsekdupec_abs2_minus; // -@576
//uniform vec3 fvicsekdupec_abs2_plus; // -@576
//uniform vec3 fvicsekdupec_offset; // -@576
//uniform vec2 fvicsekdupec_foldt; // -@576
//uniform float fvicsekdupec_scale; // -@576
//uniform vec3 fvicsekdupec_rotation1; // -@576
//uniform vec3 fvicsekdupec_rotation2; // -@576
//uniform bool fvicsekduped_preserve; // -@577
//uniform bool fvicsekduped_hex_fold1; // -@577
//uniform int fvicsekduped_hex_fold2; // -@577
//uniform bool fvicsekduped_abs1_x; // -@577
//uniform bool fvicsekduped_abs1_z; // -@577
//uniform vec3 fvicsekduped_limit; // -@577
//uniform vec3 fvicsekduped_abs2_minus; // -@577
//uniform vec3 fvicsekduped_abs2_plus; // -@577
//uniform vec3 fvicsekduped_offset; // -@577
//uniform vec2 fvicsekduped_foldt; // -@577
//uniform float fvicsekduped_scale; // -@577
//uniform vec3 fvicsekduped_rotation1; // -@577
//uniform vec3 fvicsekduped_rotation2; // -@577
//uniform bool fvicsekdupee_preserve; // -@578
//uniform bool fvicsekdupee_hex_fold1; // -@578
//uniform int fvicsekdupee_hex_fold2; // -@578
//uniform bool fvicsekdupee_abs1_x; // -@578
//uniform bool fvicsekdupee_abs1_z; // -@578
//uniform vec3 fvicsekdupee_limit; // -@578
//uniform vec3 fvicsekdupee_abs2_minus; // -@578
//uniform vec3 fvicsekdupee_abs2_plus; // -@578
//uniform vec3 fvicsekdupee_offset; // -@578
//uniform vec2 fvicsekdupee_foldt; // -@578
//uniform float fvicsekdupee_scale; // -@578
//uniform vec3 fvicsekdupee_rotation1; // -@578
//uniform vec3 fvicsekdupee_rotation2; // -@578
//uniform bool fvicsekdupef_preserve; // -@579
//uniform bool fvicsekdupef_hex_fold1; // -@579
//uniform int fvicsekdupef_hex_fold2; // -@579
//uniform bool fvicsekdupef_abs1_x; // -@579
//uniform bool fvicsekdupef_abs1_z; // -@579
//uniform vec3 fvicsekdupef_limit; // -@579
//uniform vec3 fvicsekdupef_abs2_minus; // -@579
//uniform vec3 fvicsekdupef_abs2_plus; // -@579
//uniform vec3 fvicsekdupef_offset; // -@579
//uniform vec2 fvicsekdupef_foldt; // -@579
//uniform float fvicsekdupef_scale; // -@579
//uniform vec3 fvicsekdupef_rotation1; // -@579
//uniform vec3 fvicsekdupef_rotation2; // -@579
//uniform bool fvicsekdupeg_preserve; // -@580
//uniform bool fvicsekdupeg_hex_fold1; // -@580
//uniform int fvicsekdupeg_hex_fold2; // -@580
//uniform bool fvicsekdupeg_abs1_x; // -@580
//uniform bool fvicsekdupeg_abs1_z; // -@580
//uniform vec3 fvicsekdupeg_limit; // -@580
//uniform vec3 fvicsekdupeg_abs2_minus; // -@580
//uniform vec3 fvicsekdupeg_abs2_plus; // -@580
//uniform vec3 fvicsekdupeg_offset; // -@580
//uniform vec2 fvicsekdupeg_foldt; // -@580
//uniform float fvicsekdupeg_scale; // -@580
//uniform vec3 fvicsekdupeg_rotation1; // -@580
//uniform vec3 fvicsekdupeg_rotation2; // -@580
//uniform bool fvicsekdupeh_preserve; // -@581
//uniform bool fvicsekdupeh_hex_fold1; // -@581
//uniform int fvicsekdupeh_hex_fold2; // -@581
//uniform bool fvicsekdupeh_abs1_x; // -@581
//uniform bool fvicsekdupeh_abs1_z; // -@581
//uniform vec3 fvicsekdupeh_limit; // -@581
//uniform vec3 fvicsekdupeh_abs2_minus; // -@581
//uniform vec3 fvicsekdupeh_abs2_plus; // -@581
//uniform vec3 fvicsekdupeh_offset; // -@581
//uniform vec2 fvicsekdupeh_foldt; // -@581
//uniform float fvicsekdupeh_scale; // -@581
//uniform vec3 fvicsekdupeh_rotation1; // -@581
//uniform vec3 fvicsekdupeh_rotation2; // -@581
//uniform bool fvicsekdupei_preserve; // -@582
//uniform bool fvicsekdupei_hex_fold1; // -@582
//uniform int fvicsekdupei_hex_fold2; // -@582
//uniform bool fvicsekdupei_abs1_x; // -@582
//uniform bool fvicsekdupei_abs1_z; // -@582
//uniform vec3 fvicsekdupei_limit; // -@582
//uniform vec3 fvicsekdupei_abs2_minus; // -@582
//uniform vec3 fvicsekdupei_abs2_plus; // -@582
//uniform vec3 fvicsekdupei_offset; // -@582
//uniform vec2 fvicsekdupei_foldt; // -@582
//uniform float fvicsekdupei_scale; // -@582
//uniform vec3 fvicsekdupei_rotation1; // -@582
//uniform vec3 fvicsekdupei_rotation2; // -@582
//uniform bool fvicsekdupej_preserve; // -@583
//uniform bool fvicsekdupej_hex_fold1; // -@583
//uniform int fvicsekdupej_hex_fold2; // -@583
//uniform bool fvicsekdupej_abs1_x; // -@583
//uniform bool fvicsekdupej_abs1_z; // -@583
//uniform vec3 fvicsekdupej_limit; // -@583
//uniform vec3 fvicsekdupej_abs2_minus; // -@583
//uniform vec3 fvicsekdupej_abs2_plus; // -@583
//uniform vec3 fvicsekdupej_offset; // -@583
//uniform vec2 fvicsekdupej_foldt; // -@583
//uniform float fvicsekdupej_scale; // -@583
//uniform vec3 fvicsekdupej_rotation1; // -@583
//uniform vec3 fvicsekdupej_rotation2; // -@583
//uniform float fwavysponge_scale; // -@584
//uniform vec3 fwavysponge_clamp; // -@584
//uniform vec3 fwavysponge_offset; // -@584
//uniform float fwavyspongedupea_scale; // -@585
//uniform vec3 fwavyspongedupea_clamp; // -@585
//uniform vec3 fwavyspongedupea_offset; // -@585
//uniform float fwavyspongedupeb_scale; // -@586
//uniform vec3 fwavyspongedupeb_clamp; // -@586
//uniform vec3 fwavyspongedupeb_offset; // -@586
//uniform float fwavyspongedupec_scale; // -@587
//uniform vec3 fwavyspongedupec_clamp; // -@587
//uniform vec3 fwavyspongedupec_offset; // -@587
//uniform float fwavyspongeduped_scale; // -@588
//uniform vec3 fwavyspongeduped_clamp; // -@588
//uniform vec3 fwavyspongeduped_offset; // -@588
//uniform float fwavyspongedupee_scale; // -@589
//uniform vec3 fwavyspongedupee_clamp; // -@589
//uniform vec3 fwavyspongedupee_offset; // -@589
//uniform float fwavyspongedupef_scale; // -@590
//uniform vec3 fwavyspongedupef_clamp; // -@590
//uniform vec3 fwavyspongedupef_offset; // -@590
//uniform float fwavyspongedupeg_scale; // -@591
//uniform vec3 fwavyspongedupeg_clamp; // -@591
//uniform vec3 fwavyspongedupeg_offset; // -@591
//uniform float fwavyspongedupeh_scale; // -@592
//uniform vec3 fwavyspongedupeh_clamp; // -@592
//uniform vec3 fwavyspongedupeh_offset; // -@592
//uniform float fwavyspongedupei_scale; // -@593
//uniform vec3 fwavyspongedupei_clamp; // -@593
//uniform vec3 fwavyspongedupei_offset; // -@593
//uniform float fwavyspongedupej_scale; // -@594
//uniform vec3 fwavyspongedupej_clamp; // -@594
//uniform vec3 fwavyspongedupej_offset; // -@594
//uniform vec2 fwobbletransform_rotation; // -@595
//uniform float fwobbletransform_strength; // -@595
//uniform vec4 fwobbletransform_step; // -@595
//uniform vec2 fwobbletransform_range; // -@595
//uniform vec2 fwobbletransformdupea_rotation; // -@596
//uniform float fwobbletransformdupea_strength; // -@596
//uniform vec4 fwobbletransformdupea_step; // -@596
//uniform vec2 fwobbletransformdupea_range; // -@596
//uniform vec2 fwobbletransformdupeb_rotation; // -@597
//uniform float fwobbletransformdupeb_strength; // -@597
//uniform vec4 fwobbletransformdupeb_step; // -@597
//uniform vec2 fwobbletransformdupeb_range; // -@597
//uniform vec2 fwobbletransformdupec_rotation; // -@598
//uniform float fwobbletransformdupec_strength; // -@598
//uniform vec4 fwobbletransformdupec_step; // -@598
//uniform vec2 fwobbletransformdupec_range; // -@598
//uniform vec2 fwobbletransformduped_rotation; // -@599
//uniform float fwobbletransformduped_strength; // -@599
//uniform vec4 fwobbletransformduped_step; // -@599
//uniform vec2 fwobbletransformduped_range; // -@599
//uniform vec2 fwobbletransformdupee_rotation; // -@600
//uniform float fwobbletransformdupee_strength; // -@600
//uniform vec4 fwobbletransformdupee_step; // -@600
//uniform vec2 fwobbletransformdupee_range; // -@600
//uniform vec2 fwobbletransformdupef_rotation; // -@601
//uniform float fwobbletransformdupef_strength; // -@601
//uniform vec4 fwobbletransformdupef_step; // -@601
//uniform vec2 fwobbletransformdupef_range; // -@601
//uniform vec2 fwobbletransformdupeg_rotation; // -@602
//uniform float fwobbletransformdupeg_strength; // -@602
//uniform vec4 fwobbletransformdupeg_step; // -@602
//uniform vec2 fwobbletransformdupeg_range; // -@602
//uniform vec2 fwobbletransformdupeh_rotation; // -@603
//uniform float fwobbletransformdupeh_strength; // -@603
//uniform vec4 fwobbletransformdupeh_step; // -@603
//uniform vec2 fwobbletransformdupeh_range; // -@603
//uniform vec2 fwobbletransformdupei_rotation; // -@604
//uniform float fwobbletransformdupei_strength; // -@604
//uniform vec4 fwobbletransformdupei_step; // -@604
//uniform vec2 fwobbletransformdupei_range; // -@604
//uniform vec2 fwobbletransformdupej_rotation; // -@605
//uniform float fwobbletransformdupej_strength; // -@605
//uniform vec4 fwobbletransformdupej_step; // -@605
//uniform vec2 fwobbletransformdupej_range; // -@605

//#include "res://formulas/amazingsurf.gdshaderinc" // -@1
//#include "res://formulas/amazingsurfdupea.gdshaderinc" // -@2
//#include "res://formulas/amazingsurfdupeb.gdshaderinc" // -@3
//#include "res://formulas/amazingsurfdupec.gdshaderinc" // -@4
//#include "res://formulas/amazingsurfduped.gdshaderinc" // -@5
//#include "res://formulas/amazingsurfdupee.gdshaderinc" // -@6
//#include "res://formulas/amazingsurfdupef.gdshaderinc" // -@7
//#include "res://formulas/amazingsurfdupeg.gdshaderinc" // -@8
//#include "res://formulas/amazingsurfdupeh.gdshaderinc" // -@9
//#include "res://formulas/amazingsurfdupei.gdshaderinc" // -@10
//#include "res://formulas/amazingsurfdupej.gdshaderinc" // -@11
//#include "res://formulas/attractortransform.gdshaderinc" // -@12
//#include "res://formulas/attractortransformdupea.gdshaderinc" // -@13
//#include "res://formulas/attractortransformdupeb.gdshaderinc" // -@14
//#include "res://formulas/attractortransformdupec.gdshaderinc" // -@15
//#include "res://formulas/attractortransformduped.gdshaderinc" // -@16
//#include "res://formulas/attractortransformdupee.gdshaderinc" // -@17
//#include "res://formulas/attractortransformdupef.gdshaderinc" // -@18
//#include "res://formulas/attractortransformdupeg.gdshaderinc" // -@19
//#include "res://formulas/attractortransformdupeh.gdshaderinc" // -@20
//#include "res://formulas/attractortransformdupei.gdshaderinc" // -@21
//#include "res://formulas/attractortransformdupej.gdshaderinc" // -@22
//#include "res://formulas/bairddelta.gdshaderinc" // -@23
//#include "res://formulas/bairddeltadupea.gdshaderinc" // -@24
//#include "res://formulas/bairddeltadupeb.gdshaderinc" // -@25
//#include "res://formulas/bairddeltadupec.gdshaderinc" // -@26
//#include "res://formulas/bairddeltaduped.gdshaderinc" // -@27
//#include "res://formulas/bairddeltadupee.gdshaderinc" // -@28
//#include "res://formulas/bairddeltadupef.gdshaderinc" // -@29
//#include "res://formulas/bairddeltadupeg.gdshaderinc" // -@30
//#include "res://formulas/bairddeltadupeh.gdshaderinc" // -@31
//#include "res://formulas/bairddeltadupei.gdshaderinc" // -@32
//#include "res://formulas/bairddeltadupej.gdshaderinc" // -@33
//#include "res://formulas/basictransform.gdshaderinc" // -@34
//#include "res://formulas/basictransformdupea.gdshaderinc" // -@35
//#include "res://formulas/basictransformdupeb.gdshaderinc" // -@36
//#include "res://formulas/basictransformdupec.gdshaderinc" // -@37
//#include "res://formulas/basictransformduped.gdshaderinc" // -@38
//#include "res://formulas/basictransformdupee.gdshaderinc" // -@39
//#include "res://formulas/basictransformdupef.gdshaderinc" // -@40
//#include "res://formulas/basictransformdupeg.gdshaderinc" // -@41
//#include "res://formulas/basictransformdupeh.gdshaderinc" // -@42
//#include "res://formulas/basictransformdupei.gdshaderinc" // -@43
//#include "res://formulas/basictransformdupej.gdshaderinc" // -@44
//#include "res://formulas/benesiship.gdshaderinc" // -@45
//#include "res://formulas/benesishipdupea.gdshaderinc" // -@46
//#include "res://formulas/benesishipdupeb.gdshaderinc" // -@47
//#include "res://formulas/benesishipdupec.gdshaderinc" // -@48
//#include "res://formulas/benesishipduped.gdshaderinc" // -@49
//#include "res://formulas/benesishipdupee.gdshaderinc" // -@50
//#include "res://formulas/benesishipdupef.gdshaderinc" // -@51
//#include "res://formulas/benesishipdupeg.gdshaderinc" // -@52
//#include "res://formulas/benesishipdupeh.gdshaderinc" // -@53
//#include "res://formulas/benesishipdupei.gdshaderinc" // -@54
//#include "res://formulas/benesishipdupej.gdshaderinc" // -@55
//#include "res://formulas/bristorbrot.gdshaderinc" // -@56
//#include "res://formulas/bristorbrotdupea.gdshaderinc" // -@57
//#include "res://formulas/bristorbrotdupeb.gdshaderinc" // -@58
//#include "res://formulas/bristorbrotdupec.gdshaderinc" // -@59
//#include "res://formulas/bristorbrotduped.gdshaderinc" // -@60
//#include "res://formulas/bristorbrotdupee.gdshaderinc" // -@61
//#include "res://formulas/bristorbrotdupef.gdshaderinc" // -@62
//#include "res://formulas/bristorbrotdupeg.gdshaderinc" // -@63
//#include "res://formulas/bristorbrotdupeh.gdshaderinc" // -@64
//#include "res://formulas/bristorbrotdupei.gdshaderinc" // -@65
//#include "res://formulas/bristorbrotdupej.gdshaderinc" // -@66
//#include "res://formulas/cellular.gdshaderinc" // -@67
//#include "res://formulas/cellulardupea.gdshaderinc" // -@68
//#include "res://formulas/cellulardupeb.gdshaderinc" // -@69
//#include "res://formulas/cellulardupec.gdshaderinc" // -@70
//#include "res://formulas/cellularduped.gdshaderinc" // -@71
//#include "res://formulas/cellulardupee.gdshaderinc" // -@72
//#include "res://formulas/cellulardupef.gdshaderinc" // -@73
//#include "res://formulas/cellulardupeg.gdshaderinc" // -@74
//#include "res://formulas/cellulardupeh.gdshaderinc" // -@75
//#include "res://formulas/cellulardupei.gdshaderinc" // -@76
//#include "res://formulas/cellulardupej.gdshaderinc" // -@77
//#include "res://formulas/circuit.gdshaderinc" // -@78
//#include "res://formulas/circuitdupea.gdshaderinc" // -@79
//#include "res://formulas/circuitdupeb.gdshaderinc" // -@80
//#include "res://formulas/circuitdupec.gdshaderinc" // -@81
//#include "res://formulas/circuitduped.gdshaderinc" // -@82
//#include "res://formulas/circuitdupee.gdshaderinc" // -@83
//#include "res://formulas/circuitdupef.gdshaderinc" // -@84
//#include "res://formulas/circuitdupeg.gdshaderinc" // -@85
//#include "res://formulas/circuitdupeh.gdshaderinc" // -@86
//#include "res://formulas/circuitdupei.gdshaderinc" // -@87
//#include "res://formulas/circuitdupej.gdshaderinc" // -@88
//#include "res://formulas/cube.gdshaderinc" // -@89
//#include "res://formulas/cubedupea.gdshaderinc" // -@90
//#include "res://formulas/cubedupeb.gdshaderinc" // -@91
//#include "res://formulas/cubedupec.gdshaderinc" // -@92
//#include "res://formulas/cubeduped.gdshaderinc" // -@93
//#include "res://formulas/cubedupee.gdshaderinc" // -@94
//#include "res://formulas/cubedupef.gdshaderinc" // -@95
//#include "res://formulas/cubedupeg.gdshaderinc" // -@96
//#include "res://formulas/cubedupeh.gdshaderinc" // -@97
//#include "res://formulas/cubedupei.gdshaderinc" // -@98
//#include "res://formulas/cubedupej.gdshaderinc" // -@99
//#include "res://formulas/dodecahedron.gdshaderinc" // -@100
//#include "res://formulas/dodecahedrondupea.gdshaderinc" // -@101
//#include "res://formulas/dodecahedrondupeb.gdshaderinc" // -@102
//#include "res://formulas/dodecahedrondupec.gdshaderinc" // -@103
//#include "res://formulas/dodecahedronduped.gdshaderinc" // -@104
//#include "res://formulas/dodecahedrondupee.gdshaderinc" // -@105
//#include "res://formulas/dodecahedrondupef.gdshaderinc" // -@106
//#include "res://formulas/dodecahedrondupeg.gdshaderinc" // -@107
//#include "res://formulas/dodecahedrondupeh.gdshaderinc" // -@108
//#include "res://formulas/dodecahedrondupei.gdshaderinc" // -@109
//#include "res://formulas/dodecahedrondupej.gdshaderinc" // -@110
//#include "res://formulas/gemstone.gdshaderinc" // -@111
//#include "res://formulas/gemstonedupea.gdshaderinc" // -@112
//#include "res://formulas/gemstonedupeb.gdshaderinc" // -@113
//#include "res://formulas/gemstonedupec.gdshaderinc" // -@114
//#include "res://formulas/gemstoneduped.gdshaderinc" // -@115
//#include "res://formulas/gemstonedupee.gdshaderinc" // -@116
//#include "res://formulas/gemstonedupef.gdshaderinc" // -@117
//#include "res://formulas/gemstonedupeg.gdshaderinc" // -@118
//#include "res://formulas/gemstonedupeh.gdshaderinc" // -@119
//#include "res://formulas/gemstonedupei.gdshaderinc" // -@120
//#include "res://formulas/gemstonedupej.gdshaderinc" // -@121
//#include "res://formulas/gyroid.gdshaderinc" // -@122
//#include "res://formulas/gyroiddupea.gdshaderinc" // -@123
//#include "res://formulas/gyroiddupeb.gdshaderinc" // -@124
//#include "res://formulas/gyroiddupec.gdshaderinc" // -@125
//#include "res://formulas/gyroidduped.gdshaderinc" // -@126
//#include "res://formulas/gyroiddupee.gdshaderinc" // -@127
//#include "res://formulas/gyroiddupef.gdshaderinc" // -@128
//#include "res://formulas/gyroiddupeg.gdshaderinc" // -@129
//#include "res://formulas/gyroiddupeh.gdshaderinc" // -@130
//#include "res://formulas/gyroiddupei.gdshaderinc" // -@131
//#include "res://formulas/gyroiddupej.gdshaderinc" // -@132
//#include "res://formulas/hollowtetrahedron.gdshaderinc" // -@133
//#include "res://formulas/hollowtetrahedrondupea.gdshaderinc" // -@134
//#include "res://formulas/hollowtetrahedrondupeb.gdshaderinc" // -@135
//#include "res://formulas/hollowtetrahedrondupec.gdshaderinc" // -@136
//#include "res://formulas/hollowtetrahedronduped.gdshaderinc" // -@137
//#include "res://formulas/hollowtetrahedrondupee.gdshaderinc" // -@138
//#include "res://formulas/hollowtetrahedrondupef.gdshaderinc" // -@139
//#include "res://formulas/hollowtetrahedrondupeg.gdshaderinc" // -@140
//#include "res://formulas/hollowtetrahedrondupeh.gdshaderinc" // -@141
//#include "res://formulas/hollowtetrahedrondupei.gdshaderinc" // -@142
//#include "res://formulas/hollowtetrahedrondupej.gdshaderinc" // -@143
//#include "res://formulas/icosahedron.gdshaderinc" // -@144
//#include "res://formulas/icosahedrondupea.gdshaderinc" // -@145
//#include "res://formulas/icosahedrondupeb.gdshaderinc" // -@146
//#include "res://formulas/icosahedrondupec.gdshaderinc" // -@147
//#include "res://formulas/icosahedronduped.gdshaderinc" // -@148
//#include "res://formulas/icosahedrondupee.gdshaderinc" // -@149
//#include "res://formulas/icosahedrondupef.gdshaderinc" // -@150
//#include "res://formulas/icosahedrondupeg.gdshaderinc" // -@151
//#include "res://formulas/icosahedrondupeh.gdshaderinc" // -@152
//#include "res://formulas/icosahedrondupei.gdshaderinc" // -@153
//#include "res://formulas/icosahedrondupej.gdshaderinc" // -@154
//#include "res://formulas/inversebox.gdshaderinc" // -@155
//#include "res://formulas/inverseboxdupea.gdshaderinc" // -@156
//#include "res://formulas/inverseboxdupeb.gdshaderinc" // -@157
//#include "res://formulas/inverseboxdupec.gdshaderinc" // -@158
//#include "res://formulas/inverseboxduped.gdshaderinc" // -@159
//#include "res://formulas/inverseboxdupee.gdshaderinc" // -@160
//#include "res://formulas/inverseboxdupef.gdshaderinc" // -@161
//#include "res://formulas/inverseboxdupeg.gdshaderinc" // -@162
//#include "res://formulas/inverseboxdupeh.gdshaderinc" // -@163
//#include "res://formulas/inverseboxdupei.gdshaderinc" // -@164
//#include "res://formulas/inverseboxdupej.gdshaderinc" // -@165
//#include "res://formulas/inversiontransform.gdshaderinc" // -@166
//#include "res://formulas/inversiontransformdupea.gdshaderinc" // -@167
//#include "res://formulas/inversiontransformdupeb.gdshaderinc" // -@168
//#include "res://formulas/inversiontransformdupec.gdshaderinc" // -@169
//#include "res://formulas/inversiontransformduped.gdshaderinc" // -@170
//#include "res://formulas/inversiontransformdupee.gdshaderinc" // -@171
//#include "res://formulas/inversiontransformdupef.gdshaderinc" // -@172
//#include "res://formulas/inversiontransformdupeg.gdshaderinc" // -@173
//#include "res://formulas/inversiontransformdupeh.gdshaderinc" // -@174
//#include "res://formulas/inversiontransformdupei.gdshaderinc" // -@175
//#include "res://formulas/inversiontransformdupej.gdshaderinc" // -@176
//#include "res://formulas/jerusalemcube.gdshaderinc" // -@177
//#include "res://formulas/jerusalemcubedupea.gdshaderinc" // -@178
//#include "res://formulas/jerusalemcubedupeb.gdshaderinc" // -@179
//#include "res://formulas/jerusalemcubedupec.gdshaderinc" // -@180
//#include "res://formulas/jerusalemcubeduped.gdshaderinc" // -@181
//#include "res://formulas/jerusalemcubedupee.gdshaderinc" // -@182
//#include "res://formulas/jerusalemcubedupef.gdshaderinc" // -@183
//#include "res://formulas/jerusalemcubedupeg.gdshaderinc" // -@184
//#include "res://formulas/jerusalemcubedupeh.gdshaderinc" // -@185
//#include "res://formulas/jerusalemcubedupei.gdshaderinc" // -@186
//#include "res://formulas/jerusalemcubedupej.gdshaderinc" // -@187
//#include "res://formulas/kalaidotransform.gdshaderinc" // -@188
//#include "res://formulas/kalaidotransformdupea.gdshaderinc" // -@189
//#include "res://formulas/kalaidotransformdupeb.gdshaderinc" // -@190
//#include "res://formulas/kalaidotransformdupec.gdshaderinc" // -@191
//#include "res://formulas/kalaidotransformduped.gdshaderinc" // -@192
//#include "res://formulas/kalaidotransformdupee.gdshaderinc" // -@193
//#include "res://formulas/kalaidotransformdupef.gdshaderinc" // -@194
//#include "res://formulas/kalaidotransformdupeg.gdshaderinc" // -@195
//#include "res://formulas/kalaidotransformdupeh.gdshaderinc" // -@196
//#include "res://formulas/kalaidotransformdupei.gdshaderinc" // -@197
//#include "res://formulas/kalaidotransformdupej.gdshaderinc" // -@198
//#include "res://formulas/kalibox.gdshaderinc" // -@199
//#include "res://formulas/kaliboxdupea.gdshaderinc" // -@200
//#include "res://formulas/kaliboxdupeb.gdshaderinc" // -@201
//#include "res://formulas/kaliboxdupec.gdshaderinc" // -@202
//#include "res://formulas/kaliboxduped.gdshaderinc" // -@203
//#include "res://formulas/kaliboxdupee.gdshaderinc" // -@204
//#include "res://formulas/kaliboxdupef.gdshaderinc" // -@205
//#include "res://formulas/kaliboxdupeg.gdshaderinc" // -@206
//#include "res://formulas/kaliboxdupeh.gdshaderinc" // -@207
//#include "res://formulas/kaliboxdupei.gdshaderinc" // -@208
//#include "res://formulas/kaliboxdupej.gdshaderinc" // -@209
//#include "res://formulas/kaliliving.gdshaderinc" // -@210
//#include "res://formulas/kalilivingdupea.gdshaderinc" // -@211
//#include "res://formulas/kalilivingdupeb.gdshaderinc" // -@212
//#include "res://formulas/kalilivingdupec.gdshaderinc" // -@213
//#include "res://formulas/kalilivingduped.gdshaderinc" // -@214
//#include "res://formulas/kalilivingdupee.gdshaderinc" // -@215
//#include "res://formulas/kalilivingdupef.gdshaderinc" // -@216
//#include "res://formulas/kalilivingdupeg.gdshaderinc" // -@217
//#include "res://formulas/kalilivingdupeh.gdshaderinc" // -@218
//#include "res://formulas/kalilivingdupei.gdshaderinc" // -@219
//#include "res://formulas/kalilivingdupej.gdshaderinc" // -@220
//#include "res://formulas/kaliredux.gdshaderinc" // -@221
//#include "res://formulas/kalireduxdupea.gdshaderinc" // -@222
//#include "res://formulas/kalireduxdupeb.gdshaderinc" // -@223
//#include "res://formulas/kalireduxdupec.gdshaderinc" // -@224
//#include "res://formulas/kalireduxduped.gdshaderinc" // -@225
//#include "res://formulas/kalireduxdupee.gdshaderinc" // -@226
//#include "res://formulas/kalireduxdupef.gdshaderinc" // -@227
//#include "res://formulas/kalireduxdupeg.gdshaderinc" // -@228
//#include "res://formulas/kalireduxdupeh.gdshaderinc" // -@229
//#include "res://formulas/kalireduxdupei.gdshaderinc" // -@230
//#include "res://formulas/kalireduxdupej.gdshaderinc" // -@231
//#include "res://formulas/klenian.gdshaderinc" // -@232
//#include "res://formulas/kleniandupea.gdshaderinc" // -@233
//#include "res://formulas/kleniandupeb.gdshaderinc" // -@234
//#include "res://formulas/kleniandupec.gdshaderinc" // -@235
//#include "res://formulas/klenianduped.gdshaderinc" // -@236
//#include "res://formulas/kleniandupee.gdshaderinc" // -@237
//#include "res://formulas/kleniandupef.gdshaderinc" // -@238
//#include "res://formulas/kleniandupeg.gdshaderinc" // -@239
//#include "res://formulas/kleniandupeh.gdshaderinc" // -@240
//#include "res://formulas/kleniandupei.gdshaderinc" // -@241
//#include "res://formulas/kleniandupej.gdshaderinc" // -@242
//#include "res://formulas/kochcube.gdshaderinc" // -@243
//#include "res://formulas/kochcubedupea.gdshaderinc" // -@244
//#include "res://formulas/kochcubedupeb.gdshaderinc" // -@245
//#include "res://formulas/kochcubedupec.gdshaderinc" // -@246
//#include "res://formulas/kochcubeduped.gdshaderinc" // -@247
//#include "res://formulas/kochcubedupee.gdshaderinc" // -@248
//#include "res://formulas/kochcubedupef.gdshaderinc" // -@249
//#include "res://formulas/kochcubedupeg.gdshaderinc" // -@250
//#include "res://formulas/kochcubedupeh.gdshaderinc" // -@251
//#include "res://formulas/kochcubedupei.gdshaderinc" // -@252
//#include "res://formulas/kochcubedupej.gdshaderinc" // -@253
//#include "res://formulas/kochwire.gdshaderinc" // -@254
//#include "res://formulas/kochwiredupea.gdshaderinc" // -@255
//#include "res://formulas/kochwiredupeb.gdshaderinc" // -@256
//#include "res://formulas/kochwiredupec.gdshaderinc" // -@257
//#include "res://formulas/kochwireduped.gdshaderinc" // -@258
//#include "res://formulas/kochwiredupee.gdshaderinc" // -@259
//#include "res://formulas/kochwiredupef.gdshaderinc" // -@260
//#include "res://formulas/kochwiredupeg.gdshaderinc" // -@261
//#include "res://formulas/kochwiredupeh.gdshaderinc" // -@262
//#include "res://formulas/kochwiredupei.gdshaderinc" // -@263
//#include "res://formulas/kochwiredupej.gdshaderinc" // -@264
//#include "res://formulas/lionbulb.gdshaderinc" // -@265
//#include "res://formulas/lionbulbdupea.gdshaderinc" // -@266
//#include "res://formulas/lionbulbdupeb.gdshaderinc" // -@267
//#include "res://formulas/lionbulbdupec.gdshaderinc" // -@268
//#include "res://formulas/lionbulbduped.gdshaderinc" // -@269
//#include "res://formulas/lionbulbdupee.gdshaderinc" // -@270
//#include "res://formulas/lionbulbdupef.gdshaderinc" // -@271
//#include "res://formulas/lionbulbdupeg.gdshaderinc" // -@272
//#include "res://formulas/lionbulbdupeh.gdshaderinc" // -@273
//#include "res://formulas/lionbulbdupei.gdshaderinc" // -@274
//#include "res://formulas/lionbulbdupej.gdshaderinc" // -@275
//#include "res://formulas/logtransform.gdshaderinc" // -@276
//#include "res://formulas/logtransformdupea.gdshaderinc" // -@277
//#include "res://formulas/logtransformdupeb.gdshaderinc" // -@278
//#include "res://formulas/logtransformdupec.gdshaderinc" // -@279
//#include "res://formulas/logtransformduped.gdshaderinc" // -@280
//#include "res://formulas/logtransformdupee.gdshaderinc" // -@281
//#include "res://formulas/logtransformdupef.gdshaderinc" // -@282
//#include "res://formulas/logtransformdupeg.gdshaderinc" // -@283
//#include "res://formulas/logtransformdupeh.gdshaderinc" // -@284
//#include "res://formulas/logtransformdupei.gdshaderinc" // -@285
//#include "res://formulas/logtransformdupej.gdshaderinc" // -@286
//#include "res://formulas/lorenz.gdshaderinc" // -@287
//#include "res://formulas/lorenzdupea.gdshaderinc" // -@288
//#include "res://formulas/lorenzdupeb.gdshaderinc" // -@289
//#include "res://formulas/lorenzdupec.gdshaderinc" // -@290
//#include "res://formulas/lorenzduped.gdshaderinc" // -@291
//#include "res://formulas/lorenzdupee.gdshaderinc" // -@292
//#include "res://formulas/lorenzdupef.gdshaderinc" // -@293
//#include "res://formulas/lorenzdupeg.gdshaderinc" // -@294
//#include "res://formulas/lorenzdupeh.gdshaderinc" // -@295
//#include "res://formulas/lorenzdupei.gdshaderinc" // -@296
//#include "res://formulas/lorenzdupej.gdshaderinc" // -@297
//#include "res://formulas/mandelbox.gdshaderinc" // -@298
//#include "res://formulas/mandelboxdupea.gdshaderinc" // -@299
//#include "res://formulas/mandelboxdupeb.gdshaderinc" // -@300
//#include "res://formulas/mandelboxdupec.gdshaderinc" // -@301
//#include "res://formulas/mandelboxduped.gdshaderinc" // -@302
//#include "res://formulas/mandelboxdupee.gdshaderinc" // -@303
//#include "res://formulas/mandelboxdupef.gdshaderinc" // -@304
//#include "res://formulas/mandelboxdupeg.gdshaderinc" // -@305
//#include "res://formulas/mandelboxdupeh.gdshaderinc" // -@306
//#include "res://formulas/mandelboxdupei.gdshaderinc" // -@307
//#include "res://formulas/mandelboxdupej.gdshaderinc" // -@308
#include "res://formulas/mandelbulb.gdshaderinc" // -@309
//#include "res://formulas/mandelbulbdupea.gdshaderinc" // -@310
//#include "res://formulas/mandelbulbdupeb.gdshaderinc" // -@311
//#include "res://formulas/mandelbulbdupec.gdshaderinc" // -@312
//#include "res://formulas/mandelbulbduped.gdshaderinc" // -@313
//#include "res://formulas/mandelbulbdupee.gdshaderinc" // -@314
//#include "res://formulas/mandelbulbdupef.gdshaderinc" // -@315
//#include "res://formulas/mandelbulbdupeg.gdshaderinc" // -@316
//#include "res://formulas/mandelbulbdupeh.gdshaderinc" // -@317
//#include "res://formulas/mandelbulbdupei.gdshaderinc" // -@318
//#include "res://formulas/mandelbulbdupej.gdshaderinc" // -@319
//#include "res://formulas/mandelettuce.gdshaderinc" // -@320
//#include "res://formulas/mandelettucedupea.gdshaderinc" // -@321
//#include "res://formulas/mandelettucedupeb.gdshaderinc" // -@322
//#include "res://formulas/mandelettucedupec.gdshaderinc" // -@323
//#include "res://formulas/mandelettuceduped.gdshaderinc" // -@324
//#include "res://formulas/mandelettucedupee.gdshaderinc" // -@325
//#include "res://formulas/mandelettucedupef.gdshaderinc" // -@326
//#include "res://formulas/mandelettucedupeg.gdshaderinc" // -@327
//#include "res://formulas/mandelettucedupeh.gdshaderinc" // -@328
//#include "res://formulas/mandelettucedupei.gdshaderinc" // -@329
//#include "res://formulas/mandelettucedupej.gdshaderinc" // -@330
//#include "res://formulas/melttransform.gdshaderinc" // -@331
//#include "res://formulas/melttransformdupea.gdshaderinc" // -@332
//#include "res://formulas/melttransformdupeb.gdshaderinc" // -@333
//#include "res://formulas/melttransformdupec.gdshaderinc" // -@334
//#include "res://formulas/melttransformduped.gdshaderinc" // -@335
//#include "res://formulas/melttransformdupee.gdshaderinc" // -@336
//#include "res://formulas/melttransformdupef.gdshaderinc" // -@337
//#include "res://formulas/melttransformdupeg.gdshaderinc" // -@338
//#include "res://formulas/melttransformdupeh.gdshaderinc" // -@339
//#include "res://formulas/melttransformdupei.gdshaderinc" // -@340
//#include "res://formulas/melttransformdupej.gdshaderinc" // -@341
//#include "res://formulas/mengersponge.gdshaderinc" // -@342
//#include "res://formulas/mengerspongedupea.gdshaderinc" // -@343
//#include "res://formulas/mengerspongedupeb.gdshaderinc" // -@344
//#include "res://formulas/mengerspongedupec.gdshaderinc" // -@345
//#include "res://formulas/mengerspongeduped.gdshaderinc" // -@346
//#include "res://formulas/mengerspongedupee.gdshaderinc" // -@347
//#include "res://formulas/mengerspongedupef.gdshaderinc" // -@348
//#include "res://formulas/mengerspongedupeg.gdshaderinc" // -@349
//#include "res://formulas/mengerspongedupeh.gdshaderinc" // -@350
//#include "res://formulas/mengerspongedupei.gdshaderinc" // -@351
//#include "res://formulas/mengerspongedupej.gdshaderinc" // -@352
//#include "res://formulas/mixpinski4d.gdshaderinc" // -@353
//#include "res://formulas/mixpinski4ddupea.gdshaderinc" // -@354
//#include "res://formulas/mixpinski4ddupeb.gdshaderinc" // -@355
//#include "res://formulas/mixpinski4ddupec.gdshaderinc" // -@356
//#include "res://formulas/mixpinski4dduped.gdshaderinc" // -@357
//#include "res://formulas/mixpinski4ddupee.gdshaderinc" // -@358
//#include "res://formulas/mixpinski4ddupef.gdshaderinc" // -@359
//#include "res://formulas/mixpinski4ddupeg.gdshaderinc" // -@360
//#include "res://formulas/mixpinski4ddupeh.gdshaderinc" // -@361
//#include "res://formulas/mixpinski4ddupei.gdshaderinc" // -@362
//#include "res://formulas/mixpinski4ddupej.gdshaderinc" // -@363
//#include "res://formulas/newton.gdshaderinc" // -@364
//#include "res://formulas/newtondupea.gdshaderinc" // -@365
//#include "res://formulas/newtondupeb.gdshaderinc" // -@366
//#include "res://formulas/newtondupec.gdshaderinc" // -@367
//#include "res://formulas/newtonduped.gdshaderinc" // -@368
//#include "res://formulas/newtondupee.gdshaderinc" // -@369
//#include "res://formulas/newtondupef.gdshaderinc" // -@370
//#include "res://formulas/newtondupeg.gdshaderinc" // -@371
//#include "res://formulas/newtondupeh.gdshaderinc" // -@372
//#include "res://formulas/newtondupei.gdshaderinc" // -@373
//#include "res://formulas/newtondupej.gdshaderinc" // -@374
//#include "res://formulas/octahedron.gdshaderinc" // -@375
//#include "res://formulas/octahedrondupea.gdshaderinc" // -@376
//#include "res://formulas/octahedrondupeb.gdshaderinc" // -@377
//#include "res://formulas/octahedrondupec.gdshaderinc" // -@378
//#include "res://formulas/octahedronduped.gdshaderinc" // -@379
//#include "res://formulas/octahedrondupee.gdshaderinc" // -@380
//#include "res://formulas/octahedrondupef.gdshaderinc" // -@381
//#include "res://formulas/octahedrondupeg.gdshaderinc" // -@382
//#include "res://formulas/octahedrondupeh.gdshaderinc" // -@383
//#include "res://formulas/octahedrondupei.gdshaderinc" // -@384
//#include "res://formulas/octahedrondupej.gdshaderinc" // -@385
//#include "res://formulas/octkoch.gdshaderinc" // -@386
//#include "res://formulas/octkochdupea.gdshaderinc" // -@387
//#include "res://formulas/octkochdupeb.gdshaderinc" // -@388
//#include "res://formulas/octkochdupec.gdshaderinc" // -@389
//#include "res://formulas/octkochduped.gdshaderinc" // -@390
//#include "res://formulas/octkochdupee.gdshaderinc" // -@391
//#include "res://formulas/octkochdupef.gdshaderinc" // -@392
//#include "res://formulas/octkochdupeg.gdshaderinc" // -@393
//#include "res://formulas/octkochdupeh.gdshaderinc" // -@394
//#include "res://formulas/octkochdupei.gdshaderinc" // -@395
//#include "res://formulas/octkochdupej.gdshaderinc" // -@396
//#include "res://formulas/plane.gdshaderinc" // -@397
//#include "res://formulas/planedupea.gdshaderinc" // -@398
//#include "res://formulas/planedupeb.gdshaderinc" // -@399
//#include "res://formulas/planedupec.gdshaderinc" // -@400
//#include "res://formulas/planeduped.gdshaderinc" // -@401
//#include "res://formulas/planedupee.gdshaderinc" // -@402
//#include "res://formulas/planedupef.gdshaderinc" // -@403
//#include "res://formulas/planedupeg.gdshaderinc" // -@404
//#include "res://formulas/planedupeh.gdshaderinc" // -@405
//#include "res://formulas/planedupei.gdshaderinc" // -@406
//#include "res://formulas/planedupej.gdshaderinc" // -@407
//#include "res://formulas/platonickoch.gdshaderinc" // -@408
//#include "res://formulas/platonickochdupea.gdshaderinc" // -@409
//#include "res://formulas/platonickochdupeb.gdshaderinc" // -@410
//#include "res://formulas/platonickochdupec.gdshaderinc" // -@411
//#include "res://formulas/platonickochduped.gdshaderinc" // -@412
//#include "res://formulas/platonickochdupee.gdshaderinc" // -@413
//#include "res://formulas/platonickochdupef.gdshaderinc" // -@414
//#include "res://formulas/platonickochdupeg.gdshaderinc" // -@415
//#include "res://formulas/platonickochdupeh.gdshaderinc" // -@416
//#include "res://formulas/platonickochdupei.gdshaderinc" // -@417
//#include "res://formulas/platonickochdupej.gdshaderinc" // -@418
//#include "res://formulas/pseudoklenian.gdshaderinc" // -@419
//#include "res://formulas/pseudokleniandupea.gdshaderinc" // -@420
//#include "res://formulas/pseudokleniandupeb.gdshaderinc" // -@421
//#include "res://formulas/pseudokleniandupec.gdshaderinc" // -@422
//#include "res://formulas/pseudoklenianduped.gdshaderinc" // -@423
//#include "res://formulas/pseudokleniandupee.gdshaderinc" // -@424
//#include "res://formulas/pseudokleniandupef.gdshaderinc" // -@425
//#include "res://formulas/pseudokleniandupeg.gdshaderinc" // -@426
//#include "res://formulas/pseudokleniandupeh.gdshaderinc" // -@427
//#include "res://formulas/pseudokleniandupei.gdshaderinc" // -@428
//#include "res://formulas/pseudokleniandupej.gdshaderinc" // -@429
//#include "res://formulas/quadratickoch.gdshaderinc" // -@430
//#include "res://formulas/quadratickochdupea.gdshaderinc" // -@431
//#include "res://formulas/quadratickochdupeb.gdshaderinc" // -@432
//#include "res://formulas/quadratickochdupec.gdshaderinc" // -@433
//#include "res://formulas/quadratickochduped.gdshaderinc" // -@434
//#include "res://formulas/quadratickochdupee.gdshaderinc" // -@435
//#include "res://formulas/quadratickochdupef.gdshaderinc" // -@436
//#include "res://formulas/quadratickochdupeg.gdshaderinc" // -@437
//#include "res://formulas/quadratickochdupeh.gdshaderinc" // -@438
//#include "res://formulas/quadratickochdupei.gdshaderinc" // -@439
//#include "res://formulas/quadratickochdupej.gdshaderinc" // -@440
//#include "res://formulas/reciprocaltransform.gdshaderinc" // -@441
//#include "res://formulas/reciprocaltransformdupea.gdshaderinc" // -@442
//#include "res://formulas/reciprocaltransformdupeb.gdshaderinc" // -@443
//#include "res://formulas/reciprocaltransformdupec.gdshaderinc" // -@444
//#include "res://formulas/reciprocaltransformduped.gdshaderinc" // -@445
//#include "res://formulas/reciprocaltransformdupee.gdshaderinc" // -@446
//#include "res://formulas/reciprocaltransformdupef.gdshaderinc" // -@447
//#include "res://formulas/reciprocaltransformdupeg.gdshaderinc" // -@448
//#include "res://formulas/reciprocaltransformdupeh.gdshaderinc" // -@449
//#include "res://formulas/reciprocaltransformdupei.gdshaderinc" // -@450
//#include "res://formulas/reciprocaltransformdupej.gdshaderinc" // -@451
//#include "res://formulas/romanescobroccoli.gdshaderinc" // -@452
//#include "res://formulas/romanescobroccolidupea.gdshaderinc" // -@453
//#include "res://formulas/romanescobroccolidupeb.gdshaderinc" // -@454
//#include "res://formulas/romanescobroccolidupec.gdshaderinc" // -@455
//#include "res://formulas/romanescobroccoliduped.gdshaderinc" // -@456
//#include "res://formulas/romanescobroccolidupee.gdshaderinc" // -@457
//#include "res://formulas/romanescobroccolidupef.gdshaderinc" // -@458
//#include "res://formulas/romanescobroccolidupeg.gdshaderinc" // -@459
//#include "res://formulas/romanescobroccolidupeh.gdshaderinc" // -@460
//#include "res://formulas/romanescobroccolidupei.gdshaderinc" // -@461
//#include "res://formulas/romanescobroccolidupej.gdshaderinc" // -@462
//#include "res://formulas/sierpinskidodecahedron.gdshaderinc" // -@463
//#include "res://formulas/sierpinskidodecahedrondupea.gdshaderinc" // -@464
//#include "res://formulas/sierpinskidodecahedrondupeb.gdshaderinc" // -@465
//#include "res://formulas/sierpinskidodecahedrondupec.gdshaderinc" // -@466
//#include "res://formulas/sierpinskidodecahedronduped.gdshaderinc" // -@467
//#include "res://formulas/sierpinskidodecahedrondupee.gdshaderinc" // -@468
//#include "res://formulas/sierpinskidodecahedrondupef.gdshaderinc" // -@469
//#include "res://formulas/sierpinskidodecahedrondupeg.gdshaderinc" // -@470
//#include "res://formulas/sierpinskidodecahedrondupeh.gdshaderinc" // -@471
//#include "res://formulas/sierpinskidodecahedrondupei.gdshaderinc" // -@472
//#include "res://formulas/sierpinskidodecahedrondupej.gdshaderinc" // -@473
//#include "res://formulas/sierpinskiicosahedron.gdshaderinc" // -@474
//#include "res://formulas/sierpinskiicosahedrondupea.gdshaderinc" // -@475
//#include "res://formulas/sierpinskiicosahedrondupeb.gdshaderinc" // -@476
//#include "res://formulas/sierpinskiicosahedrondupec.gdshaderinc" // -@477
//#include "res://formulas/sierpinskiicosahedronduped.gdshaderinc" // -@478
//#include "res://formulas/sierpinskiicosahedrondupee.gdshaderinc" // -@479
//#include "res://formulas/sierpinskiicosahedrondupef.gdshaderinc" // -@480
//#include "res://formulas/sierpinskiicosahedrondupeg.gdshaderinc" // -@481
//#include "res://formulas/sierpinskiicosahedrondupeh.gdshaderinc" // -@482
//#include "res://formulas/sierpinskiicosahedrondupei.gdshaderinc" // -@483
//#include "res://formulas/sierpinskiicosahedrondupej.gdshaderinc" // -@484
//#include "res://formulas/sierpinskioctahedron.gdshaderinc" // -@485
//#include "res://formulas/sierpinskioctahedrondupea.gdshaderinc" // -@486
//#include "res://formulas/sierpinskioctahedrondupeb.gdshaderinc" // -@487
//#include "res://formulas/sierpinskioctahedrondupec.gdshaderinc" // -@488
//#include "res://formulas/sierpinskioctahedronduped.gdshaderinc" // -@489
//#include "res://formulas/sierpinskioctahedrondupee.gdshaderinc" // -@490
//#include "res://formulas/sierpinskioctahedrondupef.gdshaderinc" // -@491
//#include "res://formulas/sierpinskioctahedrondupeg.gdshaderinc" // -@492
//#include "res://formulas/sierpinskioctahedrondupeh.gdshaderinc" // -@493
//#include "res://formulas/sierpinskioctahedrondupei.gdshaderinc" // -@494
//#include "res://formulas/sierpinskioctahedrondupej.gdshaderinc" // -@495
//#include "res://formulas/sierpinskitetrahedron.gdshaderinc" // -@496
//#include "res://formulas/sierpinskitetrahedrondupea.gdshaderinc" // -@497
//#include "res://formulas/sierpinskitetrahedrondupeb.gdshaderinc" // -@498
//#include "res://formulas/sierpinskitetrahedrondupec.gdshaderinc" // -@499
//#include "res://formulas/sierpinskitetrahedronduped.gdshaderinc" // -@500
//#include "res://formulas/sierpinskitetrahedrondupee.gdshaderinc" // -@501
//#include "res://formulas/sierpinskitetrahedrondupef.gdshaderinc" // -@502
//#include "res://formulas/sierpinskitetrahedrondupeg.gdshaderinc" // -@503
//#include "res://formulas/sierpinskitetrahedrondupeh.gdshaderinc" // -@504
//#include "res://formulas/sierpinskitetrahedrondupei.gdshaderinc" // -@505
//#include "res://formulas/sierpinskitetrahedrondupej.gdshaderinc" // -@506
//#include "res://formulas/sintransform.gdshaderinc" // -@507
//#include "res://formulas/sintransformdupea.gdshaderinc" // -@508
//#include "res://formulas/sintransformdupeb.gdshaderinc" // -@509
//#include "res://formulas/sintransformdupec.gdshaderinc" // -@510
//#include "res://formulas/sintransformduped.gdshaderinc" // -@511
//#include "res://formulas/sintransformdupee.gdshaderinc" // -@512
//#include "res://formulas/sintransformdupef.gdshaderinc" // -@513
//#include "res://formulas/sintransformdupeg.gdshaderinc" // -@514
//#include "res://formulas/sintransformdupeh.gdshaderinc" // -@515
//#include "res://formulas/sintransformdupei.gdshaderinc" // -@516
//#include "res://formulas/sintransformdupej.gdshaderinc" // -@517
//#include "res://formulas/sphairahedron.gdshaderinc" // -@518
//#include "res://formulas/sphairahedrondupea.gdshaderinc" // -@519
//#include "res://formulas/sphairahedrondupeb.gdshaderinc" // -@520
//#include "res://formulas/sphairahedrondupec.gdshaderinc" // -@521
//#include "res://formulas/sphairahedronduped.gdshaderinc" // -@522
//#include "res://formulas/sphairahedrondupee.gdshaderinc" // -@523
//#include "res://formulas/sphairahedrondupef.gdshaderinc" // -@524
//#include "res://formulas/sphairahedrondupeg.gdshaderinc" // -@525
//#include "res://formulas/sphairahedrondupeh.gdshaderinc" // -@526
//#include "res://formulas/sphairahedrondupei.gdshaderinc" // -@527
//#include "res://formulas/sphairahedrondupej.gdshaderinc" // -@528
//#include "res://formulas/sphere.gdshaderinc" // -@529
//#include "res://formulas/spheredupea.gdshaderinc" // -@530
//#include "res://formulas/spheredupeb.gdshaderinc" // -@531
//#include "res://formulas/spheredupec.gdshaderinc" // -@532
//#include "res://formulas/sphereduped.gdshaderinc" // -@533
//#include "res://formulas/spheredupee.gdshaderinc" // -@534
//#include "res://formulas/spheredupef.gdshaderinc" // -@535
//#include "res://formulas/spheredupeg.gdshaderinc" // -@536
//#include "res://formulas/spheredupeh.gdshaderinc" // -@537
//#include "res://formulas/spheredupei.gdshaderinc" // -@538
//#include "res://formulas/spheredupej.gdshaderinc" // -@539
//#include "res://formulas/spheretree.gdshaderinc" // -@540
//#include "res://formulas/spheretreedupea.gdshaderinc" // -@541
//#include "res://formulas/spheretreedupeb.gdshaderinc" // -@542
//#include "res://formulas/spheretreedupec.gdshaderinc" // -@543
//#include "res://formulas/spheretreeduped.gdshaderinc" // -@544
//#include "res://formulas/spheretreedupee.gdshaderinc" // -@545
//#include "res://formulas/spheretreedupef.gdshaderinc" // -@546
//#include "res://formulas/spheretreedupeg.gdshaderinc" // -@547
//#include "res://formulas/spheretreedupeh.gdshaderinc" // -@548
//#include "res://formulas/spheretreedupei.gdshaderinc" // -@549
//#include "res://formulas/spheretreedupej.gdshaderinc" // -@550
//#include "res://formulas/tetrahedron.gdshaderinc" // -@551
//#include "res://formulas/tetrahedrondupea.gdshaderinc" // -@552
//#include "res://formulas/tetrahedrondupeb.gdshaderinc" // -@553
//#include "res://formulas/tetrahedrondupec.gdshaderinc" // -@554
//#include "res://formulas/tetrahedronduped.gdshaderinc" // -@555
//#include "res://formulas/tetrahedrondupee.gdshaderinc" // -@556
//#include "res://formulas/tetrahedrondupef.gdshaderinc" // -@557
//#include "res://formulas/tetrahedrondupeg.gdshaderinc" // -@558
//#include "res://formulas/tetrahedrondupeh.gdshaderinc" // -@559
//#include "res://formulas/tetrahedrondupei.gdshaderinc" // -@560
//#include "res://formulas/tetrahedrondupej.gdshaderinc" // -@561
//#include "res://formulas/triescher.gdshaderinc" // -@562
//#include "res://formulas/triescherdupea.gdshaderinc" // -@563
//#include "res://formulas/triescherdupeb.gdshaderinc" // -@564
//#include "res://formulas/triescherdupec.gdshaderinc" // -@565
//#include "res://formulas/triescherduped.gdshaderinc" // -@566
//#include "res://formulas/triescherdupee.gdshaderinc" // -@567
//#include "res://formulas/triescherdupef.gdshaderinc" // -@568
//#include "res://formulas/triescherdupeg.gdshaderinc" // -@569
//#include "res://formulas/triescherdupeh.gdshaderinc" // -@570
//#include "res://formulas/triescherdupei.gdshaderinc" // -@571
//#include "res://formulas/triescherdupej.gdshaderinc" // -@572
//#include "res://formulas/vicsek.gdshaderinc" // -@573
//#include "res://formulas/vicsekdupea.gdshaderinc" // -@574
//#include "res://formulas/vicsekdupeb.gdshaderinc" // -@575
//#include "res://formulas/vicsekdupec.gdshaderinc" // -@576
//#include "res://formulas/vicsekduped.gdshaderinc" // -@577
//#include "res://formulas/vicsekdupee.gdshaderinc" // -@578
//#include "res://formulas/vicsekdupef.gdshaderinc" // -@579
//#include "res://formulas/vicsekdupeg.gdshaderinc" // -@580
//#include "res://formulas/vicsekdupeh.gdshaderinc" // -@581
//#include "res://formulas/vicsekdupei.gdshaderinc" // -@582
//#include "res://formulas/vicsekdupej.gdshaderinc" // -@583
//#include "res://formulas/wavysponge.gdshaderinc" // -@584
//#include "res://formulas/wavyspongedupea.gdshaderinc" // -@585
//#include "res://formulas/wavyspongedupeb.gdshaderinc" // -@586
//#include "res://formulas/wavyspongedupec.gdshaderinc" // -@587
//#include "res://formulas/wavyspongeduped.gdshaderinc" // -@588
//#include "res://formulas/wavyspongedupee.gdshaderinc" // -@589
//#include "res://formulas/wavyspongedupef.gdshaderinc" // -@590
//#include "res://formulas/wavyspongedupeg.gdshaderinc" // -@591
//#include "res://formulas/wavyspongedupeh.gdshaderinc" // -@592
//#include "res://formulas/wavyspongedupei.gdshaderinc" // -@593
//#include "res://formulas/wavyspongedupej.gdshaderinc" // -@594
//#include "res://formulas/wobbletransform.gdshaderinc" // -@595
//#include "res://formulas/wobbletransformdupea.gdshaderinc" // -@596
//#include "res://formulas/wobbletransformdupeb.gdshaderinc" // -@597
//#include "res://formulas/wobbletransformdupec.gdshaderinc" // -@598
//#include "res://formulas/wobbletransformduped.gdshaderinc" // -@599
//#include "res://formulas/wobbletransformdupee.gdshaderinc" // -@600
//#include "res://formulas/wobbletransformdupef.gdshaderinc" // -@601
//#include "res://formulas/wobbletransformdupeg.gdshaderinc" // -@602
//#include "res://formulas/wobbletransformdupeh.gdshaderinc" // -@603
//#include "res://formulas/wobbletransformdupei.gdshaderinc" // -@604
//#include "res://formulas/wobbletransformdupej.gdshaderinc" // -@605

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
//if (current_formula == 2) amazingsurfdupea_iter(z, dz, original_z, orbit, i); //-@2
//if (current_formula == 3) amazingsurfdupeb_iter(z, dz, original_z, orbit, i); //-@3
//if (current_formula == 4) amazingsurfdupec_iter(z, dz, original_z, orbit, i); //-@4
//if (current_formula == 5) amazingsurfduped_iter(z, dz, original_z, orbit, i); //-@5
//if (current_formula == 6) amazingsurfdupee_iter(z, dz, original_z, orbit, i); //-@6
//if (current_formula == 7) amazingsurfdupef_iter(z, dz, original_z, orbit, i); //-@7
//if (current_formula == 8) amazingsurfdupeg_iter(z, dz, original_z, orbit, i); //-@8
//if (current_formula == 9) amazingsurfdupeh_iter(z, dz, original_z, orbit, i); //-@9
//if (current_formula == 10) amazingsurfdupei_iter(z, dz, original_z, orbit, i); //-@10
//if (current_formula == 11) amazingsurfdupej_iter(z, dz, original_z, orbit, i); //-@11
//if (current_formula == 12) attractortransform_iter(z, dz, original_z, orbit, i); //-@12
//if (current_formula == 13) attractortransformdupea_iter(z, dz, original_z, orbit, i); //-@13
//if (current_formula == 14) attractortransformdupeb_iter(z, dz, original_z, orbit, i); //-@14
//if (current_formula == 15) attractortransformdupec_iter(z, dz, original_z, orbit, i); //-@15
//if (current_formula == 16) attractortransformduped_iter(z, dz, original_z, orbit, i); //-@16
//if (current_formula == 17) attractortransformdupee_iter(z, dz, original_z, orbit, i); //-@17
//if (current_formula == 18) attractortransformdupef_iter(z, dz, original_z, orbit, i); //-@18
//if (current_formula == 19) attractortransformdupeg_iter(z, dz, original_z, orbit, i); //-@19
//if (current_formula == 20) attractortransformdupeh_iter(z, dz, original_z, orbit, i); //-@20
//if (current_formula == 21) attractortransformdupei_iter(z, dz, original_z, orbit, i); //-@21
//if (current_formula == 22) attractortransformdupej_iter(z, dz, original_z, orbit, i); //-@22
//if (current_formula == 23) bairddelta_iter(z, dz, original_z, orbit, i); //-@23
//if (current_formula == 24) bairddeltadupea_iter(z, dz, original_z, orbit, i); //-@24
//if (current_formula == 25) bairddeltadupeb_iter(z, dz, original_z, orbit, i); //-@25
//if (current_formula == 26) bairddeltadupec_iter(z, dz, original_z, orbit, i); //-@26
//if (current_formula == 27) bairddeltaduped_iter(z, dz, original_z, orbit, i); //-@27
//if (current_formula == 28) bairddeltadupee_iter(z, dz, original_z, orbit, i); //-@28
//if (current_formula == 29) bairddeltadupef_iter(z, dz, original_z, orbit, i); //-@29
//if (current_formula == 30) bairddeltadupeg_iter(z, dz, original_z, orbit, i); //-@30
//if (current_formula == 31) bairddeltadupeh_iter(z, dz, original_z, orbit, i); //-@31
//if (current_formula == 32) bairddeltadupei_iter(z, dz, original_z, orbit, i); //-@32
//if (current_formula == 33) bairddeltadupej_iter(z, dz, original_z, orbit, i); //-@33
//if (current_formula == 34) basictransform_iter(z, dz, original_z, orbit, i); //-@34
//if (current_formula == 35) basictransformdupea_iter(z, dz, original_z, orbit, i); //-@35
//if (current_formula == 36) basictransformdupeb_iter(z, dz, original_z, orbit, i); //-@36
//if (current_formula == 37) basictransformdupec_iter(z, dz, original_z, orbit, i); //-@37
//if (current_formula == 38) basictransformduped_iter(z, dz, original_z, orbit, i); //-@38
//if (current_formula == 39) basictransformdupee_iter(z, dz, original_z, orbit, i); //-@39
//if (current_formula == 40) basictransformdupef_iter(z, dz, original_z, orbit, i); //-@40
//if (current_formula == 41) basictransformdupeg_iter(z, dz, original_z, orbit, i); //-@41
//if (current_formula == 42) basictransformdupeh_iter(z, dz, original_z, orbit, i); //-@42
//if (current_formula == 43) basictransformdupei_iter(z, dz, original_z, orbit, i); //-@43
//if (current_formula == 44) basictransformdupej_iter(z, dz, original_z, orbit, i); //-@44
//if (current_formula == 45) benesiship_iter(z, dz, original_z, orbit, i); //-@45
//if (current_formula == 46) benesishipdupea_iter(z, dz, original_z, orbit, i); //-@46
//if (current_formula == 47) benesishipdupeb_iter(z, dz, original_z, orbit, i); //-@47
//if (current_formula == 48) benesishipdupec_iter(z, dz, original_z, orbit, i); //-@48
//if (current_formula == 49) benesishipduped_iter(z, dz, original_z, orbit, i); //-@49
//if (current_formula == 50) benesishipdupee_iter(z, dz, original_z, orbit, i); //-@50
//if (current_formula == 51) benesishipdupef_iter(z, dz, original_z, orbit, i); //-@51
//if (current_formula == 52) benesishipdupeg_iter(z, dz, original_z, orbit, i); //-@52
//if (current_formula == 53) benesishipdupeh_iter(z, dz, original_z, orbit, i); //-@53
//if (current_formula == 54) benesishipdupei_iter(z, dz, original_z, orbit, i); //-@54
//if (current_formula == 55) benesishipdupej_iter(z, dz, original_z, orbit, i); //-@55
//if (current_formula == 56) bristorbrot_iter(z, dz, original_z, orbit, i); //-@56
//if (current_formula == 57) bristorbrotdupea_iter(z, dz, original_z, orbit, i); //-@57
//if (current_formula == 58) bristorbrotdupeb_iter(z, dz, original_z, orbit, i); //-@58
//if (current_formula == 59) bristorbrotdupec_iter(z, dz, original_z, orbit, i); //-@59
//if (current_formula == 60) bristorbrotduped_iter(z, dz, original_z, orbit, i); //-@60
//if (current_formula == 61) bristorbrotdupee_iter(z, dz, original_z, orbit, i); //-@61
//if (current_formula == 62) bristorbrotdupef_iter(z, dz, original_z, orbit, i); //-@62
//if (current_formula == 63) bristorbrotdupeg_iter(z, dz, original_z, orbit, i); //-@63
//if (current_formula == 64) bristorbrotdupeh_iter(z, dz, original_z, orbit, i); //-@64
//if (current_formula == 65) bristorbrotdupei_iter(z, dz, original_z, orbit, i); //-@65
//if (current_formula == 66) bristorbrotdupej_iter(z, dz, original_z, orbit, i); //-@66
//if (current_formula == 111) gemstone_iter(z, dz, original_z, orbit, i); //-@111
//if (current_formula == 112) gemstonedupea_iter(z, dz, original_z, orbit, i); //-@112
//if (current_formula == 113) gemstonedupeb_iter(z, dz, original_z, orbit, i); //-@113
//if (current_formula == 114) gemstonedupec_iter(z, dz, original_z, orbit, i); //-@114
//if (current_formula == 115) gemstoneduped_iter(z, dz, original_z, orbit, i); //-@115
//if (current_formula == 116) gemstonedupee_iter(z, dz, original_z, orbit, i); //-@116
//if (current_formula == 117) gemstonedupef_iter(z, dz, original_z, orbit, i); //-@117
//if (current_formula == 118) gemstonedupeg_iter(z, dz, original_z, orbit, i); //-@118
//if (current_formula == 119) gemstonedupeh_iter(z, dz, original_z, orbit, i); //-@119
//if (current_formula == 120) gemstonedupei_iter(z, dz, original_z, orbit, i); //-@120
//if (current_formula == 121) gemstonedupej_iter(z, dz, original_z, orbit, i); //-@121
//if (current_formula == 166) inversiontransform_iter(z, dz, original_z, orbit, i); //-@166
//if (current_formula == 167) inversiontransformdupea_iter(z, dz, original_z, orbit, i); //-@167
//if (current_formula == 168) inversiontransformdupeb_iter(z, dz, original_z, orbit, i); //-@168
//if (current_formula == 169) inversiontransformdupec_iter(z, dz, original_z, orbit, i); //-@169
//if (current_formula == 170) inversiontransformduped_iter(z, dz, original_z, orbit, i); //-@170
//if (current_formula == 171) inversiontransformdupee_iter(z, dz, original_z, orbit, i); //-@171
//if (current_formula == 172) inversiontransformdupef_iter(z, dz, original_z, orbit, i); //-@172
//if (current_formula == 173) inversiontransformdupeg_iter(z, dz, original_z, orbit, i); //-@173
//if (current_formula == 174) inversiontransformdupeh_iter(z, dz, original_z, orbit, i); //-@174
//if (current_formula == 175) inversiontransformdupei_iter(z, dz, original_z, orbit, i); //-@175
//if (current_formula == 176) inversiontransformdupej_iter(z, dz, original_z, orbit, i); //-@176
//if (current_formula == 177) jerusalemcube_iter(z, dz, original_z, orbit, i); //-@177
//if (current_formula == 178) jerusalemcubedupea_iter(z, dz, original_z, orbit, i); //-@178
//if (current_formula == 179) jerusalemcubedupeb_iter(z, dz, original_z, orbit, i); //-@179
//if (current_formula == 180) jerusalemcubedupec_iter(z, dz, original_z, orbit, i); //-@180
//if (current_formula == 181) jerusalemcubeduped_iter(z, dz, original_z, orbit, i); //-@181
//if (current_formula == 182) jerusalemcubedupee_iter(z, dz, original_z, orbit, i); //-@182
//if (current_formula == 183) jerusalemcubedupef_iter(z, dz, original_z, orbit, i); //-@183
//if (current_formula == 184) jerusalemcubedupeg_iter(z, dz, original_z, orbit, i); //-@184
//if (current_formula == 185) jerusalemcubedupeh_iter(z, dz, original_z, orbit, i); //-@185
//if (current_formula == 186) jerusalemcubedupei_iter(z, dz, original_z, orbit, i); //-@186
//if (current_formula == 187) jerusalemcubedupej_iter(z, dz, original_z, orbit, i); //-@187
//if (current_formula == 188) kalaidotransform_iter(z, dz, original_z, orbit, i); //-@188
//if (current_formula == 189) kalaidotransformdupea_iter(z, dz, original_z, orbit, i); //-@189
//if (current_formula == 190) kalaidotransformdupeb_iter(z, dz, original_z, orbit, i); //-@190
//if (current_formula == 191) kalaidotransformdupec_iter(z, dz, original_z, orbit, i); //-@191
//if (current_formula == 192) kalaidotransformduped_iter(z, dz, original_z, orbit, i); //-@192
//if (current_formula == 193) kalaidotransformdupee_iter(z, dz, original_z, orbit, i); //-@193
//if (current_formula == 194) kalaidotransformdupef_iter(z, dz, original_z, orbit, i); //-@194
//if (current_formula == 195) kalaidotransformdupeg_iter(z, dz, original_z, orbit, i); //-@195
//if (current_formula == 196) kalaidotransformdupeh_iter(z, dz, original_z, orbit, i); //-@196
//if (current_formula == 197) kalaidotransformdupei_iter(z, dz, original_z, orbit, i); //-@197
//if (current_formula == 198) kalaidotransformdupej_iter(z, dz, original_z, orbit, i); //-@198
//if (current_formula == 199) kalibox_iter(z, dz, original_z, orbit, i); //-@199
//if (current_formula == 200) kaliboxdupea_iter(z, dz, original_z, orbit, i); //-@200
//if (current_formula == 201) kaliboxdupeb_iter(z, dz, original_z, orbit, i); //-@201
//if (current_formula == 202) kaliboxdupec_iter(z, dz, original_z, orbit, i); //-@202
//if (current_formula == 203) kaliboxduped_iter(z, dz, original_z, orbit, i); //-@203
//if (current_formula == 204) kaliboxdupee_iter(z, dz, original_z, orbit, i); //-@204
//if (current_formula == 205) kaliboxdupef_iter(z, dz, original_z, orbit, i); //-@205
//if (current_formula == 206) kaliboxdupeg_iter(z, dz, original_z, orbit, i); //-@206
//if (current_formula == 207) kaliboxdupeh_iter(z, dz, original_z, orbit, i); //-@207
//if (current_formula == 208) kaliboxdupei_iter(z, dz, original_z, orbit, i); //-@208
//if (current_formula == 209) kaliboxdupej_iter(z, dz, original_z, orbit, i); //-@209
//if (current_formula == 210) kaliliving_iter(z, dz, original_z, orbit, i); //-@210
//if (current_formula == 211) kalilivingdupea_iter(z, dz, original_z, orbit, i); //-@211
//if (current_formula == 212) kalilivingdupeb_iter(z, dz, original_z, orbit, i); //-@212
//if (current_formula == 213) kalilivingdupec_iter(z, dz, original_z, orbit, i); //-@213
//if (current_formula == 214) kalilivingduped_iter(z, dz, original_z, orbit, i); //-@214
//if (current_formula == 215) kalilivingdupee_iter(z, dz, original_z, orbit, i); //-@215
//if (current_formula == 216) kalilivingdupef_iter(z, dz, original_z, orbit, i); //-@216
//if (current_formula == 217) kalilivingdupeg_iter(z, dz, original_z, orbit, i); //-@217
//if (current_formula == 218) kalilivingdupeh_iter(z, dz, original_z, orbit, i); //-@218
//if (current_formula == 219) kalilivingdupei_iter(z, dz, original_z, orbit, i); //-@219
//if (current_formula == 220) kalilivingdupej_iter(z, dz, original_z, orbit, i); //-@220
//if (current_formula == 221) kaliredux_iter(z, dz, original_z, orbit, i); //-@221
//if (current_formula == 222) kalireduxdupea_iter(z, dz, original_z, orbit, i); //-@222
//if (current_formula == 223) kalireduxdupeb_iter(z, dz, original_z, orbit, i); //-@223
//if (current_formula == 224) kalireduxdupec_iter(z, dz, original_z, orbit, i); //-@224
//if (current_formula == 225) kalireduxduped_iter(z, dz, original_z, orbit, i); //-@225
//if (current_formula == 226) kalireduxdupee_iter(z, dz, original_z, orbit, i); //-@226
//if (current_formula == 227) kalireduxdupef_iter(z, dz, original_z, orbit, i); //-@227
//if (current_formula == 228) kalireduxdupeg_iter(z, dz, original_z, orbit, i); //-@228
//if (current_formula == 229) kalireduxdupeh_iter(z, dz, original_z, orbit, i); //-@229
//if (current_formula == 230) kalireduxdupei_iter(z, dz, original_z, orbit, i); //-@230
//if (current_formula == 231) kalireduxdupej_iter(z, dz, original_z, orbit, i); //-@231
//if (current_formula == 243) kochcube_iter(z, dz, original_z, orbit, i, s); //-@243
//if (current_formula == 244) kochcubedupea_iter(z, dz, original_z, orbit, i); //-@244
//if (current_formula == 245) kochcubedupeb_iter(z, dz, original_z, orbit, i); //-@245
//if (current_formula == 246) kochcubedupec_iter(z, dz, original_z, orbit, i); //-@246
//if (current_formula == 247) kochcubeduped_iter(z, dz, original_z, orbit, i); //-@247
//if (current_formula == 248) kochcubedupee_iter(z, dz, original_z, orbit, i); //-@248
//if (current_formula == 249) kochcubedupef_iter(z, dz, original_z, orbit, i); //-@249
//if (current_formula == 250) kochcubedupeg_iter(z, dz, original_z, orbit, i); //-@250
//if (current_formula == 251) kochcubedupeh_iter(z, dz, original_z, orbit, i); //-@251
//if (current_formula == 252) kochcubedupei_iter(z, dz, original_z, orbit, i); //-@252
//if (current_formula == 253) kochcubedupej_iter(z, dz, original_z, orbit, i); //-@253
//if (current_formula == 254) kochwire_iter(z, dz, original_z, orbit, i); //-@254
//if (current_formula == 255) kochwiredupea_iter(z, dz, original_z, orbit, i); //-@255
//if (current_formula == 256) kochwiredupeb_iter(z, dz, original_z, orbit, i); //-@256
//if (current_formula == 257) kochwiredupec_iter(z, dz, original_z, orbit, i); //-@257
//if (current_formula == 258) kochwireduped_iter(z, dz, original_z, orbit, i); //-@258
//if (current_formula == 259) kochwiredupee_iter(z, dz, original_z, orbit, i); //-@259
//if (current_formula == 260) kochwiredupef_iter(z, dz, original_z, orbit, i); //-@260
//if (current_formula == 261) kochwiredupeg_iter(z, dz, original_z, orbit, i); //-@261
//if (current_formula == 262) kochwiredupeh_iter(z, dz, original_z, orbit, i); //-@262
//if (current_formula == 263) kochwiredupei_iter(z, dz, original_z, orbit, i); //-@263
//if (current_formula == 264) kochwiredupej_iter(z, dz, original_z, orbit, i); //-@264
//if (current_formula == 265) lionbulb_iter(z, dz, original_z, orbit, i); //-@265
//if (current_formula == 266) lionbulbdupea_iter(z, dz, original_z, orbit, i); //-@266
//if (current_formula == 267) lionbulbdupeb_iter(z, dz, original_z, orbit, i); //-@267
//if (current_formula == 268) lionbulbdupec_iter(z, dz, original_z, orbit, i); //-@268
//if (current_formula == 269) lionbulbduped_iter(z, dz, original_z, orbit, i); //-@269
//if (current_formula == 270) lionbulbdupee_iter(z, dz, original_z, orbit, i); //-@270
//if (current_formula == 271) lionbulbdupef_iter(z, dz, original_z, orbit, i); //-@271
//if (current_formula == 272) lionbulbdupeg_iter(z, dz, original_z, orbit, i); //-@272
//if (current_formula == 273) lionbulbdupeh_iter(z, dz, original_z, orbit, i); //-@273
//if (current_formula == 274) lionbulbdupei_iter(z, dz, original_z, orbit, i); //-@274
//if (current_formula == 275) lionbulbdupej_iter(z, dz, original_z, orbit, i); //-@275
//if (current_formula == 276) logtransform_iter(z, dz, original_z, orbit, i); //-@276
//if (current_formula == 277) logtransformdupea_iter(z, dz, original_z, orbit, i); //-@277
//if (current_formula == 278) logtransformdupeb_iter(z, dz, original_z, orbit, i); //-@278
//if (current_formula == 279) logtransformdupec_iter(z, dz, original_z, orbit, i); //-@279
//if (current_formula == 280) logtransformduped_iter(z, dz, original_z, orbit, i); //-@280
//if (current_formula == 281) logtransformdupee_iter(z, dz, original_z, orbit, i); //-@281
//if (current_formula == 282) logtransformdupef_iter(z, dz, original_z, orbit, i); //-@282
//if (current_formula == 283) logtransformdupeg_iter(z, dz, original_z, orbit, i); //-@283
//if (current_formula == 284) logtransformdupeh_iter(z, dz, original_z, orbit, i); //-@284
//if (current_formula == 285) logtransformdupei_iter(z, dz, original_z, orbit, i); //-@285
//if (current_formula == 286) logtransformdupej_iter(z, dz, original_z, orbit, i); //-@286
//if (current_formula == 298) mandelbox_iter(z, dz, original_z, orbit, i); //-@298
//if (current_formula == 299) mandelboxdupea_iter(z, dz, original_z, orbit, i); //-@299
//if (current_formula == 300) mandelboxdupeb_iter(z, dz, original_z, orbit, i); //-@300
//if (current_formula == 301) mandelboxdupec_iter(z, dz, original_z, orbit, i); //-@301
//if (current_formula == 302) mandelboxduped_iter(z, dz, original_z, orbit, i); //-@302
//if (current_formula == 303) mandelboxdupee_iter(z, dz, original_z, orbit, i); //-@303
//if (current_formula == 304) mandelboxdupef_iter(z, dz, original_z, orbit, i); //-@304
//if (current_formula == 305) mandelboxdupeg_iter(z, dz, original_z, orbit, i); //-@305
//if (current_formula == 306) mandelboxdupeh_iter(z, dz, original_z, orbit, i); //-@306
//if (current_formula == 307) mandelboxdupei_iter(z, dz, original_z, orbit, i); //-@307
//if (current_formula == 308) mandelboxdupej_iter(z, dz, original_z, orbit, i); //-@308
if (current_formula == 309) mandelbulb_iter(z, dz, original_z, orbit, i); //-@309
//if (current_formula == 310) mandelbulbdupea_iter(z, dz, original_z, orbit, i); //-@310
//if (current_formula == 311) mandelbulbdupeb_iter(z, dz, original_z, orbit, i); //-@311
//if (current_formula == 312) mandelbulbdupec_iter(z, dz, original_z, orbit, i); //-@312
//if (current_formula == 313) mandelbulbduped_iter(z, dz, original_z, orbit, i); //-@313
//if (current_formula == 314) mandelbulbdupee_iter(z, dz, original_z, orbit, i); //-@314
//if (current_formula == 315) mandelbulbdupef_iter(z, dz, original_z, orbit, i); //-@315
//if (current_formula == 316) mandelbulbdupeg_iter(z, dz, original_z, orbit, i); //-@316
//if (current_formula == 317) mandelbulbdupeh_iter(z, dz, original_z, orbit, i); //-@317
//if (current_formula == 318) mandelbulbdupei_iter(z, dz, original_z, orbit, i); //-@318
//if (current_formula == 319) mandelbulbdupej_iter(z, dz, original_z, orbit, i); //-@319
//if (current_formula == 320) mandelettuce_iter(z, dz, original_z, orbit, i); //-@320
//if (current_formula == 321) mandelettucedupea_iter(z, dz, original_z, orbit, i); //-@321
//if (current_formula == 322) mandelettucedupeb_iter(z, dz, original_z, orbit, i); //-@322
//if (current_formula == 323) mandelettucedupec_iter(z, dz, original_z, orbit, i); //-@323
//if (current_formula == 324) mandelettuceduped_iter(z, dz, original_z, orbit, i); //-@324
//if (current_formula == 325) mandelettucedupee_iter(z, dz, original_z, orbit, i); //-@325
//if (current_formula == 326) mandelettucedupef_iter(z, dz, original_z, orbit, i); //-@326
//if (current_formula == 327) mandelettucedupeg_iter(z, dz, original_z, orbit, i); //-@327
//if (current_formula == 328) mandelettucedupeh_iter(z, dz, original_z, orbit, i); //-@328
//if (current_formula == 329) mandelettucedupei_iter(z, dz, original_z, orbit, i); //-@329
//if (current_formula == 330) mandelettucedupej_iter(z, dz, original_z, orbit, i); //-@330
//if (current_formula == 331) melttransform_iter(z, dz, original_z, orbit, i); //-@331
//if (current_formula == 332) melttransformdupea_iter(z, dz, original_z, orbit, i); //-@332
//if (current_formula == 333) melttransformdupeb_iter(z, dz, original_z, orbit, i); //-@333
//if (current_formula == 334) melttransformdupec_iter(z, dz, original_z, orbit, i); //-@334
//if (current_formula == 335) melttransformduped_iter(z, dz, original_z, orbit, i); //-@335
//if (current_formula == 336) melttransformdupee_iter(z, dz, original_z, orbit, i); //-@336
//if (current_formula == 337) melttransformdupef_iter(z, dz, original_z, orbit, i); //-@337
//if (current_formula == 338) melttransformdupeg_iter(z, dz, original_z, orbit, i); //-@338
//if (current_formula == 339) melttransformdupeh_iter(z, dz, original_z, orbit, i); //-@339
//if (current_formula == 340) melttransformdupei_iter(z, dz, original_z, orbit, i); //-@340
//if (current_formula == 341) melttransformdupej_iter(z, dz, original_z, orbit, i); //-@341
//if (current_formula == 342) mengersponge_iter(z, dz, original_z, orbit, i); //-@342
//if (current_formula == 343) mengerspongedupea_iter(z, dz, original_z, orbit, i); //-@343
//if (current_formula == 344) mengerspongedupeb_iter(z, dz, original_z, orbit, i); //-@344
//if (current_formula == 345) mengerspongedupec_iter(z, dz, original_z, orbit, i); //-@345
//if (current_formula == 346) mengerspongeduped_iter(z, dz, original_z, orbit, i); //-@346
//if (current_formula == 347) mengerspongedupee_iter(z, dz, original_z, orbit, i); //-@347
//if (current_formula == 348) mengerspongedupef_iter(z, dz, original_z, orbit, i); //-@348
//if (current_formula == 349) mengerspongedupeg_iter(z, dz, original_z, orbit, i); //-@349
//if (current_formula == 350) mengerspongedupeh_iter(z, dz, original_z, orbit, i); //-@350
//if (current_formula == 351) mengerspongedupei_iter(z, dz, original_z, orbit, i); //-@351
//if (current_formula == 352) mengerspongedupej_iter(z, dz, original_z, orbit, i); //-@352
//if (current_formula == 353) mixpinski4d_iter(z, dz, original_z, orbit, i); //-@353
//if (current_formula == 354) mixpinski4ddupea_iter(z, dz, original_z, orbit, i); //-@354
//if (current_formula == 355) mixpinski4ddupeb_iter(z, dz, original_z, orbit, i); //-@355
//if (current_formula == 356) mixpinski4ddupec_iter(z, dz, original_z, orbit, i); //-@356
//if (current_formula == 357) mixpinski4dduped_iter(z, dz, original_z, orbit, i); //-@357
//if (current_formula == 358) mixpinski4ddupee_iter(z, dz, original_z, orbit, i); //-@358
//if (current_formula == 359) mixpinski4ddupef_iter(z, dz, original_z, orbit, i); //-@359
//if (current_formula == 360) mixpinski4ddupeg_iter(z, dz, original_z, orbit, i); //-@360
//if (current_formula == 361) mixpinski4ddupeh_iter(z, dz, original_z, orbit, i); //-@361
//if (current_formula == 362) mixpinski4ddupei_iter(z, dz, original_z, orbit, i); //-@362
//if (current_formula == 363) mixpinski4ddupej_iter(z, dz, original_z, orbit, i); //-@363
//if (current_formula == 386) octkoch_iter(z, dz, original_z, orbit, i); //-@386
//if (current_formula == 387) octkochdupea_iter(z, dz, original_z, orbit, i); //-@387
//if (current_formula == 388) octkochdupeb_iter(z, dz, original_z, orbit, i); //-@388
//if (current_formula == 389) octkochdupec_iter(z, dz, original_z, orbit, i); //-@389
//if (current_formula == 390) octkochduped_iter(z, dz, original_z, orbit, i); //-@390
//if (current_formula == 391) octkochdupee_iter(z, dz, original_z, orbit, i); //-@391
//if (current_formula == 392) octkochdupef_iter(z, dz, original_z, orbit, i); //-@392
//if (current_formula == 393) octkochdupeg_iter(z, dz, original_z, orbit, i); //-@393
//if (current_formula == 394) octkochdupeh_iter(z, dz, original_z, orbit, i); //-@394
//if (current_formula == 395) octkochdupei_iter(z, dz, original_z, orbit, i); //-@395
//if (current_formula == 396) octkochdupej_iter(z, dz, original_z, orbit, i); //-@396
//if (current_formula == 408) platonickoch_iter(z, dz, original_z, orbit, i); //-@408
//if (current_formula == 409) platonickochdupea_iter(z, dz, original_z, orbit, i); //-@409
//if (current_formula == 410) platonickochdupeb_iter(z, dz, original_z, orbit, i); //-@410
//if (current_formula == 411) platonickochdupec_iter(z, dz, original_z, orbit, i); //-@411
//if (current_formula == 412) platonickochduped_iter(z, dz, original_z, orbit, i); //-@412
//if (current_formula == 413) platonickochdupee_iter(z, dz, original_z, orbit, i); //-@413
//if (current_formula == 414) platonickochdupef_iter(z, dz, original_z, orbit, i); //-@414
//if (current_formula == 415) platonickochdupeg_iter(z, dz, original_z, orbit, i); //-@415
//if (current_formula == 416) platonickochdupeh_iter(z, dz, original_z, orbit, i); //-@416
//if (current_formula == 417) platonickochdupei_iter(z, dz, original_z, orbit, i); //-@417
//if (current_formula == 418) platonickochdupej_iter(z, dz, original_z, orbit, i); //-@418
//if (current_formula == 419) pseudoklenian_iter(z, dz, original_z, orbit, i); //-@419
//if (current_formula == 420) pseudokleniandupea_iter(z, dz, original_z, orbit, i); //-@420
//if (current_formula == 421) pseudokleniandupeb_iter(z, dz, original_z, orbit, i); //-@421
//if (current_formula == 422) pseudokleniandupec_iter(z, dz, original_z, orbit, i); //-@422
//if (current_formula == 423) pseudoklenianduped_iter(z, dz, original_z, orbit, i); //-@423
//if (current_formula == 424) pseudokleniandupee_iter(z, dz, original_z, orbit, i); //-@424
//if (current_formula == 425) pseudokleniandupef_iter(z, dz, original_z, orbit, i); //-@425
//if (current_formula == 426) pseudokleniandupeg_iter(z, dz, original_z, orbit, i); //-@426
//if (current_formula == 427) pseudokleniandupeh_iter(z, dz, original_z, orbit, i); //-@427
//if (current_formula == 428) pseudokleniandupei_iter(z, dz, original_z, orbit, i); //-@428
//if (current_formula == 429) pseudokleniandupej_iter(z, dz, original_z, orbit, i); //-@429
//if (current_formula == 430) quadratickoch_iter(z, dz, original_z, orbit, i); //-@430
//if (current_formula == 431) quadratickochdupea_iter(z, dz, original_z, orbit, i); //-@431
//if (current_formula == 432) quadratickochdupeb_iter(z, dz, original_z, orbit, i); //-@432
//if (current_formula == 433) quadratickochdupec_iter(z, dz, original_z, orbit, i); //-@433
//if (current_formula == 434) quadratickochduped_iter(z, dz, original_z, orbit, i); //-@434
//if (current_formula == 435) quadratickochdupee_iter(z, dz, original_z, orbit, i); //-@435
//if (current_formula == 436) quadratickochdupef_iter(z, dz, original_z, orbit, i); //-@436
//if (current_formula == 437) quadratickochdupeg_iter(z, dz, original_z, orbit, i); //-@437
//if (current_formula == 438) quadratickochdupeh_iter(z, dz, original_z, orbit, i); //-@438
//if (current_formula == 439) quadratickochdupei_iter(z, dz, original_z, orbit, i); //-@439
//if (current_formula == 440) quadratickochdupej_iter(z, dz, original_z, orbit, i); //-@440
//if (current_formula == 441) reciprocaltransform_iter(z, dz, original_z, orbit, i); //-@441
//if (current_formula == 442) reciprocaltransformdupea_iter(z, dz, original_z, orbit, i); //-@442
//if (current_formula == 443) reciprocaltransformdupeb_iter(z, dz, original_z, orbit, i); //-@443
//if (current_formula == 444) reciprocaltransformdupec_iter(z, dz, original_z, orbit, i); //-@444
//if (current_formula == 445) reciprocaltransformduped_iter(z, dz, original_z, orbit, i); //-@445
//if (current_formula == 446) reciprocaltransformdupee_iter(z, dz, original_z, orbit, i); //-@446
//if (current_formula == 447) reciprocaltransformdupef_iter(z, dz, original_z, orbit, i); //-@447
//if (current_formula == 448) reciprocaltransformdupeg_iter(z, dz, original_z, orbit, i); //-@448
//if (current_formula == 449) reciprocaltransformdupeh_iter(z, dz, original_z, orbit, i); //-@449
//if (current_formula == 450) reciprocaltransformdupei_iter(z, dz, original_z, orbit, i); //-@450
//if (current_formula == 451) reciprocaltransformdupej_iter(z, dz, original_z, orbit, i); //-@451
//if (current_formula == 463) sierpinskidodecahedron_iter(z, dz, original_z, orbit, i); //-@463
//if (current_formula == 464) sierpinskidodecahedrondupea_iter(z, dz, original_z, orbit, i); //-@464
//if (current_formula == 465) sierpinskidodecahedrondupeb_iter(z, dz, original_z, orbit, i); //-@465
//if (current_formula == 466) sierpinskidodecahedrondupec_iter(z, dz, original_z, orbit, i); //-@466
//if (current_formula == 467) sierpinskidodecahedronduped_iter(z, dz, original_z, orbit, i); //-@467
//if (current_formula == 468) sierpinskidodecahedrondupee_iter(z, dz, original_z, orbit, i); //-@468
//if (current_formula == 469) sierpinskidodecahedrondupef_iter(z, dz, original_z, orbit, i); //-@469
//if (current_formula == 470) sierpinskidodecahedrondupeg_iter(z, dz, original_z, orbit, i); //-@470
//if (current_formula == 471) sierpinskidodecahedrondupeh_iter(z, dz, original_z, orbit, i); //-@471
//if (current_formula == 472) sierpinskidodecahedrondupei_iter(z, dz, original_z, orbit, i); //-@472
//if (current_formula == 473) sierpinskidodecahedrondupej_iter(z, dz, original_z, orbit, i); //-@473
//if (current_formula == 474) sierpinskiicosahedron_iter(z, dz, original_z, orbit, i); //-@474
//if (current_formula == 475) sierpinskiicosahedrondupea_iter(z, dz, original_z, orbit, i); //-@475
//if (current_formula == 476) sierpinskiicosahedrondupeb_iter(z, dz, original_z, orbit, i); //-@476
//if (current_formula == 477) sierpinskiicosahedrondupec_iter(z, dz, original_z, orbit, i); //-@477
//if (current_formula == 478) sierpinskiicosahedronduped_iter(z, dz, original_z, orbit, i); //-@478
//if (current_formula == 479) sierpinskiicosahedrondupee_iter(z, dz, original_z, orbit, i); //-@479
//if (current_formula == 480) sierpinskiicosahedrondupef_iter(z, dz, original_z, orbit, i); //-@480
//if (current_formula == 481) sierpinskiicosahedrondupeg_iter(z, dz, original_z, orbit, i); //-@481
//if (current_formula == 482) sierpinskiicosahedrondupeh_iter(z, dz, original_z, orbit, i); //-@482
//if (current_formula == 483) sierpinskiicosahedrondupei_iter(z, dz, original_z, orbit, i); //-@483
//if (current_formula == 484) sierpinskiicosahedrondupej_iter(z, dz, original_z, orbit, i); //-@484
//if (current_formula == 485) sierpinskioctahedron_iter(z, dz, original_z, orbit, i); //-@485
//if (current_formula == 486) sierpinskioctahedrondupea_iter(z, dz, original_z, orbit, i); //-@486
//if (current_formula == 487) sierpinskioctahedrondupeb_iter(z, dz, original_z, orbit, i); //-@487
//if (current_formula == 488) sierpinskioctahedrondupec_iter(z, dz, original_z, orbit, i); //-@488
//if (current_formula == 489) sierpinskioctahedronduped_iter(z, dz, original_z, orbit, i); //-@489
//if (current_formula == 490) sierpinskioctahedrondupee_iter(z, dz, original_z, orbit, i); //-@490
//if (current_formula == 491) sierpinskioctahedrondupef_iter(z, dz, original_z, orbit, i); //-@491
//if (current_formula == 492) sierpinskioctahedrondupeg_iter(z, dz, original_z, orbit, i); //-@492
//if (current_formula == 493) sierpinskioctahedrondupeh_iter(z, dz, original_z, orbit, i); //-@493
//if (current_formula == 494) sierpinskioctahedrondupei_iter(z, dz, original_z, orbit, i); //-@494
//if (current_formula == 495) sierpinskioctahedrondupej_iter(z, dz, original_z, orbit, i); //-@495
//if (current_formula == 496) sierpinskitetrahedron_iter(z, dz, original_z, orbit, i); //-@496
//if (current_formula == 497) sierpinskitetrahedrondupea_iter(z, dz, original_z, orbit, i); //-@497
//if (current_formula == 498) sierpinskitetrahedrondupeb_iter(z, dz, original_z, orbit, i); //-@498
//if (current_formula == 499) sierpinskitetrahedrondupec_iter(z, dz, original_z, orbit, i); //-@499
//if (current_formula == 500) sierpinskitetrahedronduped_iter(z, dz, original_z, orbit, i); //-@500
//if (current_formula == 501) sierpinskitetrahedrondupee_iter(z, dz, original_z, orbit, i); //-@501
//if (current_formula == 502) sierpinskitetrahedrondupef_iter(z, dz, original_z, orbit, i); //-@502
//if (current_formula == 503) sierpinskitetrahedrondupeg_iter(z, dz, original_z, orbit, i); //-@503
//if (current_formula == 504) sierpinskitetrahedrondupeh_iter(z, dz, original_z, orbit, i); //-@504
//if (current_formula == 505) sierpinskitetrahedrondupei_iter(z, dz, original_z, orbit, i); //-@505
//if (current_formula == 506) sierpinskitetrahedrondupej_iter(z, dz, original_z, orbit, i); //-@506
//if (current_formula == 507) sintransform_iter(z, dz, original_z, orbit, i); //-@507
//if (current_formula == 508) sintransformdupea_iter(z, dz, original_z, orbit, i); //-@508
//if (current_formula == 509) sintransformdupeb_iter(z, dz, original_z, orbit, i); //-@509
//if (current_formula == 510) sintransformdupec_iter(z, dz, original_z, orbit, i); //-@510
//if (current_formula == 511) sintransformduped_iter(z, dz, original_z, orbit, i); //-@511
//if (current_formula == 512) sintransformdupee_iter(z, dz, original_z, orbit, i); //-@512
//if (current_formula == 513) sintransformdupef_iter(z, dz, original_z, orbit, i); //-@513
//if (current_formula == 514) sintransformdupeg_iter(z, dz, original_z, orbit, i); //-@514
//if (current_formula == 515) sintransformdupeh_iter(z, dz, original_z, orbit, i); //-@515
//if (current_formula == 516) sintransformdupei_iter(z, dz, original_z, orbit, i); //-@516
//if (current_formula == 517) sintransformdupej_iter(z, dz, original_z, orbit, i); //-@517
//if (current_formula == 562) triescher_iter(z, dz, original_z, orbit, i); //-@562
//if (current_formula == 563) triescherdupea_iter(z, dz, original_z, orbit, i); //-@563
//if (current_formula == 564) triescherdupeb_iter(z, dz, original_z, orbit, i); //-@564
//if (current_formula == 565) triescherdupec_iter(z, dz, original_z, orbit, i); //-@565
//if (current_formula == 566) triescherduped_iter(z, dz, original_z, orbit, i); //-@566
//if (current_formula == 567) triescherdupee_iter(z, dz, original_z, orbit, i); //-@567
//if (current_formula == 568) triescherdupef_iter(z, dz, original_z, orbit, i); //-@568
//if (current_formula == 569) triescherdupeg_iter(z, dz, original_z, orbit, i); //-@569
//if (current_formula == 570) triescherdupeh_iter(z, dz, original_z, orbit, i); //-@570
//if (current_formula == 571) triescherdupei_iter(z, dz, original_z, orbit, i); //-@571
//if (current_formula == 572) triescherdupej_iter(z, dz, original_z, orbit, i); //-@572
//if (current_formula == 573) vicsek_iter(z, dz, original_z, orbit, i); //-@573
//if (current_formula == 574) vicsekdupea_iter(z, dz, original_z, orbit, i); //-@574
//if (current_formula == 575) vicsekdupeb_iter(z, dz, original_z, orbit, i); //-@575
//if (current_formula == 576) vicsekdupec_iter(z, dz, original_z, orbit, i); //-@576
//if (current_formula == 577) vicsekduped_iter(z, dz, original_z, orbit, i); //-@577
//if (current_formula == 578) vicsekdupee_iter(z, dz, original_z, orbit, i); //-@578
//if (current_formula == 579) vicsekdupef_iter(z, dz, original_z, orbit, i); //-@579
//if (current_formula == 580) vicsekdupeg_iter(z, dz, original_z, orbit, i); //-@580
//if (current_formula == 581) vicsekdupeh_iter(z, dz, original_z, orbit, i); //-@581
//if (current_formula == 582) vicsekdupei_iter(z, dz, original_z, orbit, i); //-@582
//if (current_formula == 583) vicsekdupej_iter(z, dz, original_z, orbit, i); //-@583
//if (current_formula == 584) wavysponge_iter(z, dz, original_z, orbit, i); //-@584
//if (current_formula == 585) wavyspongedupea_iter(z, dz, original_z, orbit, i); //-@585
//if (current_formula == 586) wavyspongedupeb_iter(z, dz, original_z, orbit, i); //-@586
//if (current_formula == 587) wavyspongedupec_iter(z, dz, original_z, orbit, i); //-@587
//if (current_formula == 588) wavyspongeduped_iter(z, dz, original_z, orbit, i); //-@588
//if (current_formula == 589) wavyspongedupee_iter(z, dz, original_z, orbit, i); //-@589
//if (current_formula == 590) wavyspongedupef_iter(z, dz, original_z, orbit, i); //-@590
//if (current_formula == 591) wavyspongedupeg_iter(z, dz, original_z, orbit, i); //-@591
//if (current_formula == 592) wavyspongedupeh_iter(z, dz, original_z, orbit, i); //-@592
//if (current_formula == 593) wavyspongedupei_iter(z, dz, original_z, orbit, i); //-@593
//if (current_formula == 594) wavyspongedupej_iter(z, dz, original_z, orbit, i); //-@594
//if (current_formula == 595) wobbletransform_iter(z, dz, original_z, orbit, i); //-@595
//if (current_formula == 596) wobbletransformdupea_iter(z, dz, original_z, orbit, i); //-@596
//if (current_formula == 597) wobbletransformdupeb_iter(z, dz, original_z, orbit, i); //-@597
//if (current_formula == 598) wobbletransformdupec_iter(z, dz, original_z, orbit, i); //-@598
//if (current_formula == 599) wobbletransformduped_iter(z, dz, original_z, orbit, i); //-@599
//if (current_formula == 600) wobbletransformdupee_iter(z, dz, original_z, orbit, i); //-@600
//if (current_formula == 601) wobbletransformdupef_iter(z, dz, original_z, orbit, i); //-@601
//if (current_formula == 602) wobbletransformdupeg_iter(z, dz, original_z, orbit, i); //-@602
//if (current_formula == 603) wobbletransformdupeh_iter(z, dz, original_z, orbit, i); //-@603
//if (current_formula == 604) wobbletransformdupei_iter(z, dz, original_z, orbit, i); //-@604
//if (current_formula == 605) wobbletransformdupej_iter(z, dz, original_z, orbit, i); //-@605
		orbit = min(orbit, process_orbit_trap4d(z, original_z, i));

		if (dot(z, z) > escape_radius * escape_radius || escaped) break;
	}

	float r = length(z);
	float de = 0.0;

	if (de_mode == 0) de = r / dz;
	else if (de_mode == 1) de = 0.5 * log(r) * r / dz;
	else if (de_mode == 2) {

			if (single_formula && (formulas[0] == 243 || formulas[0] == 244 || formulas[0] == 245 || formulas[0] == 246 || formulas[0] == 247 || formulas[0] == 248 || formulas[0] == 249 || formulas[0] == 250 || formulas[0] == 251 || formulas[0] == 252 || formulas[0] == 253 || formulas[0] == 342 || formulas[0] == 343 || formulas[0] == 344 || formulas[0] == 345 || formulas[0] == 346 || formulas[0] == 347 || formulas[0] == 348 || formulas[0] == 349 || formulas[0] == 350 || formulas[0] == 351 || formulas[0] == 352 || formulas[0] == 386 || formulas[0] == 387 || formulas[0] == 388 || formulas[0] == 389 || formulas[0] == 390 || formulas[0] == 391 || formulas[0] == 392 || formulas[0] == 393 || formulas[0] == 394 || formulas[0] == 395 || formulas[0] == 396 || formulas[0] == 408 || formulas[0] == 409 || formulas[0] == 410 || formulas[0] == 411 || formulas[0] == 412 || formulas[0] == 413 || formulas[0] == 414 || formulas[0] == 415 || formulas[0] == 416 || formulas[0] == 417 || formulas[0] == 418 || formulas[0] == 430 || formulas[0] == 431 || formulas[0] == 432 || formulas[0] == 433 || formulas[0] == 434 || formulas[0] == 435 || formulas[0] == 436 || formulas[0] == 437 || formulas[0] == 438 || formulas[0] == 439 || formulas[0] == 440 || formulas[0] == 573 || formulas[0] == 574 || formulas[0] == 575 || formulas[0] == 576 || formulas[0] == 577 || formulas[0] == 578 || formulas[0] == 579 || formulas[0] == 580 || formulas[0] == 581 || formulas[0] == 582 || formulas[0] == 583)) de = r / dz;
			else de = 0.5 * log(r) * r / dz;
		
	}

	if (only_primitive_based_formulas) de = 100000.0;
	else if (only_sdf_based_formulas) de = 0.0;

if (single_formula) {
vec2 sdf_result;
//sdf_result = cellular_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@67
//sdf_result = cellulardupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@68
//sdf_result = cellulardupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@69
//sdf_result = cellulardupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@70
//sdf_result = cellularduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@71
//sdf_result = cellulardupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@72
//sdf_result = cellulardupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@73
//sdf_result = cellulardupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@74
//sdf_result = cellulardupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@75
//sdf_result = cellulardupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@76
//sdf_result = cellulardupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@77
//sdf_result = circuit_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@78
//sdf_result = circuitdupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@79
//sdf_result = circuitdupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@80
//sdf_result = circuitdupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@81
//sdf_result = circuitduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@82
//sdf_result = circuitdupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@83
//sdf_result = circuitdupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@84
//sdf_result = circuitdupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@85
//sdf_result = circuitdupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@86
//sdf_result = circuitdupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@87
//sdf_result = circuitdupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@88
//sdf_result = cube_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@89
//sdf_result = cubedupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@90
//sdf_result = cubedupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@91
//sdf_result = cubedupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@92
//sdf_result = cubeduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@93
//sdf_result = cubedupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@94
//sdf_result = cubedupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@95
//sdf_result = cubedupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@96
//sdf_result = cubedupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@97
//sdf_result = cubedupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@98
//sdf_result = cubedupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@99
//sdf_result = dodecahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@100
//sdf_result = dodecahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@101
//sdf_result = dodecahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@102
//sdf_result = dodecahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@103
//sdf_result = dodecahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@104
//sdf_result = dodecahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@105
//sdf_result = dodecahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@106
//sdf_result = dodecahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@107
//sdf_result = dodecahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@108
//sdf_result = dodecahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@109
//sdf_result = dodecahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@110
//sdf_result = gyroid_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@122
//sdf_result = gyroiddupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@123
//sdf_result = gyroiddupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@124
//sdf_result = gyroiddupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@125
//sdf_result = gyroidduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@126
//sdf_result = gyroiddupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@127
//sdf_result = gyroiddupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@128
//sdf_result = gyroiddupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@129
//sdf_result = gyroiddupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@130
//sdf_result = gyroiddupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@131
//sdf_result = gyroiddupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@132
//sdf_result = hollowtetrahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@133
//sdf_result = hollowtetrahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@134
//sdf_result = hollowtetrahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@135
//sdf_result = hollowtetrahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@136
//sdf_result = hollowtetrahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@137
//sdf_result = hollowtetrahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@138
//sdf_result = hollowtetrahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@139
//sdf_result = hollowtetrahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@140
//sdf_result = hollowtetrahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@141
//sdf_result = hollowtetrahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@142
//sdf_result = hollowtetrahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@143
//sdf_result = icosahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@144
//sdf_result = icosahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@145
//sdf_result = icosahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@146
//sdf_result = icosahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@147
//sdf_result = icosahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@148
//sdf_result = icosahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@149
//sdf_result = icosahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@150
//sdf_result = icosahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@151
//sdf_result = icosahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@152
//sdf_result = icosahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@153
//sdf_result = icosahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@154
//sdf_result = inversebox_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@155
//sdf_result = inverseboxdupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@156
//sdf_result = inverseboxdupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@157
//sdf_result = inverseboxdupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@158
//sdf_result = inverseboxduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@159
//sdf_result = inverseboxdupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@160
//sdf_result = inverseboxdupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@161
//sdf_result = inverseboxdupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@162
//sdf_result = inverseboxdupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@163
//sdf_result = inverseboxdupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@164
//sdf_result = inverseboxdupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@165
//sdf_result = klenian_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@232
//sdf_result = kleniandupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@233
//sdf_result = kleniandupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@234
//sdf_result = kleniandupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@235
//sdf_result = klenianduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@236
//sdf_result = kleniandupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@237
//sdf_result = kleniandupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@238
//sdf_result = kleniandupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@239
//sdf_result = kleniandupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@240
//sdf_result = kleniandupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@241
//sdf_result = kleniandupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@242
//sdf_result = lorenz_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@287
//sdf_result = lorenzdupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@288
//sdf_result = lorenzdupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@289
//sdf_result = lorenzdupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@290
//sdf_result = lorenzduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@291
//sdf_result = lorenzdupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@292
//sdf_result = lorenzdupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@293
//sdf_result = lorenzdupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@294
//sdf_result = lorenzdupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@295
//sdf_result = lorenzdupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@296
//sdf_result = lorenzdupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@297
//sdf_result = newton_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@364
//sdf_result = newtondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@365
//sdf_result = newtondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@366
//sdf_result = newtondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@367
//sdf_result = newtonduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@368
//sdf_result = newtondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@369
//sdf_result = newtondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@370
//sdf_result = newtondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@371
//sdf_result = newtondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@372
//sdf_result = newtondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@373
//sdf_result = newtondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@374
//sdf_result = octahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@375
//sdf_result = octahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@376
//sdf_result = octahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@377
//sdf_result = octahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@378
//sdf_result = octahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@379
//sdf_result = octahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@380
//sdf_result = octahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@381
//sdf_result = octahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@382
//sdf_result = octahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@383
//sdf_result = octahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@384
//sdf_result = octahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@385
//sdf_result = plane_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@397
//sdf_result = planedupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@398
//sdf_result = planedupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@399
//sdf_result = planedupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@400
//sdf_result = planeduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@401
//sdf_result = planedupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@402
//sdf_result = planedupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@403
//sdf_result = planedupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@404
//sdf_result = planedupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@405
//sdf_result = planedupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@406
//sdf_result = planedupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@407
//sdf_result = romanescobroccoli_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@452
//sdf_result = romanescobroccolidupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@453
//sdf_result = romanescobroccolidupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@454
//sdf_result = romanescobroccolidupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@455
//sdf_result = romanescobroccoliduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@456
//sdf_result = romanescobroccolidupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@457
//sdf_result = romanescobroccolidupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@458
//sdf_result = romanescobroccolidupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@459
//sdf_result = romanescobroccolidupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@460
//sdf_result = romanescobroccolidupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@461
//sdf_result = romanescobroccolidupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@462
//sdf_result = sphairahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@518
//sdf_result = sphairahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@519
//sdf_result = sphairahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@520
//sdf_result = sphairahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@521
//sdf_result = sphairahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@522
//sdf_result = sphairahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@523
//sdf_result = sphairahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@524
//sdf_result = sphairahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@525
//sdf_result = sphairahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@526
//sdf_result = sphairahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@527
//sdf_result = sphairahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@528
//sdf_result = sphere_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@529
//sdf_result = spheredupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@530
//sdf_result = spheredupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@531
//sdf_result = spheredupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@532
//sdf_result = sphereduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@533
//sdf_result = spheredupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@534
//sdf_result = spheredupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@535
//sdf_result = spheredupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@536
//sdf_result = spheredupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@537
//sdf_result = spheredupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@538
//sdf_result = spheredupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@539
//sdf_result = spheretree_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@540
//sdf_result = spheretreedupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@541
//sdf_result = spheretreedupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@542
//sdf_result = spheretreedupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@543
//sdf_result = spheretreeduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@544
//sdf_result = spheretreedupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@545
//sdf_result = spheretreedupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@546
//sdf_result = spheretreedupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@547
//sdf_result = spheretreedupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@548
//sdf_result = spheretreedupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@549
//sdf_result = spheretreedupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@550
//sdf_result = tetrahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@551
//sdf_result = tetrahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@552
//sdf_result = tetrahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@553
//sdf_result = tetrahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@554
//sdf_result = tetrahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@555
//sdf_result = tetrahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@556
//sdf_result = tetrahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@557
//sdf_result = tetrahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@558
//sdf_result = tetrahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@559
//sdf_result = tetrahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@560
//sdf_result = tetrahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@561

} else {
vec2 sdf_result;
//sdf_result = cellular_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@67
//sdf_result = cellulardupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@68
//sdf_result = cellulardupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@69
//sdf_result = cellulardupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@70
//sdf_result = cellularduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@71
//sdf_result = cellulardupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@72
//sdf_result = cellulardupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@73
//sdf_result = cellulardupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@74
//sdf_result = cellulardupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@75
//sdf_result = cellulardupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@76
//sdf_result = cellulardupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@77
//sdf_result = circuit_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@78
//sdf_result = circuitdupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@79
//sdf_result = circuitdupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@80
//sdf_result = circuitdupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@81
//sdf_result = circuitduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@82
//sdf_result = circuitdupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@83
//sdf_result = circuitdupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@84
//sdf_result = circuitdupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@85
//sdf_result = circuitdupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@86
//sdf_result = circuitdupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@87
//sdf_result = circuitdupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@88
//sdf_result = hollowtetrahedron_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@133
//sdf_result = hollowtetrahedrondupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@134
//sdf_result = hollowtetrahedrondupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@135
//sdf_result = hollowtetrahedrondupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@136
//sdf_result = hollowtetrahedronduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@137
//sdf_result = hollowtetrahedrondupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@138
//sdf_result = hollowtetrahedrondupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@139
//sdf_result = hollowtetrahedrondupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@140
//sdf_result = hollowtetrahedrondupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@141
//sdf_result = hollowtetrahedrondupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@142
//sdf_result = hollowtetrahedrondupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@143
//sdf_result = inversebox_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@155
//sdf_result = inverseboxdupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@156
//sdf_result = inverseboxdupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@157
//sdf_result = inverseboxdupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@158
//sdf_result = inverseboxduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@159
//sdf_result = inverseboxdupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@160
//sdf_result = inverseboxdupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@161
//sdf_result = inverseboxdupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@162
//sdf_result = inverseboxdupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@163
//sdf_result = inverseboxdupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@164
//sdf_result = inverseboxdupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@165
//sdf_result = klenian_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@232
//sdf_result = kleniandupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@233
//sdf_result = kleniandupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@234
//sdf_result = kleniandupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@235
//sdf_result = klenianduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@236
//sdf_result = kleniandupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@237
//sdf_result = kleniandupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@238
//sdf_result = kleniandupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@239
//sdf_result = kleniandupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@240
//sdf_result = kleniandupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@241
//sdf_result = kleniandupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@242
//sdf_result = lorenz_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@287
//sdf_result = lorenzdupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@288
//sdf_result = lorenzdupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@289
//sdf_result = lorenzdupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@290
//sdf_result = lorenzduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@291
//sdf_result = lorenzdupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@292
//sdf_result = lorenzdupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@293
//sdf_result = lorenzdupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@294
//sdf_result = lorenzdupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@295
//sdf_result = lorenzdupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@296
//sdf_result = lorenzdupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@297
//sdf_result = cube_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@89
//sdf_result = cubedupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@90
//sdf_result = cubedupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@91
//sdf_result = cubedupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@92
//sdf_result = cubeduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@93
//sdf_result = cubedupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@94
//sdf_result = cubedupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@95
//sdf_result = cubedupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@96
//sdf_result = cubedupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@97
//sdf_result = cubedupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@98
//sdf_result = cubedupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@99
//sdf_result = dodecahedron_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@100
//sdf_result = dodecahedrondupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@101
//sdf_result = dodecahedrondupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@102
//sdf_result = dodecahedrondupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@103
//sdf_result = dodecahedronduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@104
//sdf_result = dodecahedrondupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@105
//sdf_result = dodecahedrondupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@106
//sdf_result = dodecahedrondupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@107
//sdf_result = dodecahedrondupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@108
//sdf_result = dodecahedrondupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@109
//sdf_result = dodecahedrondupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@110
//sdf_result = gyroid_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@122
//sdf_result = gyroiddupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@123
//sdf_result = gyroiddupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@124
//sdf_result = gyroiddupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@125
//sdf_result = gyroidduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@126
//sdf_result = gyroiddupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@127
//sdf_result = gyroiddupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@128
//sdf_result = gyroiddupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@129
//sdf_result = gyroiddupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@130
//sdf_result = gyroiddupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@131
//sdf_result = gyroiddupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@132
//sdf_result = icosahedron_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@144
//sdf_result = icosahedrondupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@145
//sdf_result = icosahedrondupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@146
//sdf_result = icosahedrondupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@147
//sdf_result = icosahedronduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@148
//sdf_result = icosahedrondupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@149
//sdf_result = icosahedrondupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@150
//sdf_result = icosahedrondupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@151
//sdf_result = icosahedrondupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@152
//sdf_result = icosahedrondupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@153
//sdf_result = icosahedrondupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@154
//sdf_result = newton_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@364
//sdf_result = newtondupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@365
//sdf_result = newtondupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@366
//sdf_result = newtondupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@367
//sdf_result = newtonduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@368
//sdf_result = newtondupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@369
//sdf_result = newtondupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@370
//sdf_result = newtondupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@371
//sdf_result = newtondupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@372
//sdf_result = newtondupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@373
//sdf_result = newtondupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@374
//sdf_result = octahedron_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@375
//sdf_result = octahedrondupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@376
//sdf_result = octahedrondupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@377
//sdf_result = octahedrondupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@378
//sdf_result = octahedronduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@379
//sdf_result = octahedrondupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@380
//sdf_result = octahedrondupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@381
//sdf_result = octahedrondupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@382
//sdf_result = octahedrondupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@383
//sdf_result = octahedrondupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@384
//sdf_result = octahedrondupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@385
//sdf_result = plane_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@397
//sdf_result = planedupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@398
//sdf_result = planedupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@399
//sdf_result = planedupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@400
//sdf_result = planeduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@401
//sdf_result = planedupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@402
//sdf_result = planedupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@403
//sdf_result = planedupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@404
//sdf_result = planedupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@405
//sdf_result = planedupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@406
//sdf_result = planedupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@407
//sdf_result = sphairahedron_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@518
//sdf_result = sphairahedrondupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@519
//sdf_result = sphairahedrondupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@520
//sdf_result = sphairahedrondupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@521
//sdf_result = sphairahedronduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@522
//sdf_result = sphairahedrondupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@523
//sdf_result = sphairahedrondupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@524
//sdf_result = sphairahedrondupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@525
//sdf_result = sphairahedrondupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@526
//sdf_result = sphairahedrondupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@527
//sdf_result = sphairahedrondupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@528
//sdf_result = spheretree_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@540
//sdf_result = spheretreedupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@541
//sdf_result = spheretreedupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@542
//sdf_result = spheretreedupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@543
//sdf_result = spheretreeduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@544
//sdf_result = spheretreedupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@545
//sdf_result = spheretreedupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@546
//sdf_result = spheretreedupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@547
//sdf_result = spheretreedupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@548
//sdf_result = spheretreedupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@549
//sdf_result = spheretreedupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@550
//sdf_result = romanescobroccoli_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@452
//sdf_result = romanescobroccolidupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@453
//sdf_result = romanescobroccolidupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@454
//sdf_result = romanescobroccolidupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@455
//sdf_result = romanescobroccoliduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@456
//sdf_result = romanescobroccolidupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@457
//sdf_result = romanescobroccolidupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@458
//sdf_result = romanescobroccolidupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@459
//sdf_result = romanescobroccolidupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@460
//sdf_result = romanescobroccolidupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@461
//sdf_result = romanescobroccolidupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@462
//sdf_result = sphere_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@529
//sdf_result = spheredupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@530
//sdf_result = spheredupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@531
//sdf_result = spheredupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@532
//sdf_result = sphereduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@533
//sdf_result = spheredupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@534
//sdf_result = spheredupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@535
//sdf_result = spheredupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@536
//sdf_result = spheredupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@537
//sdf_result = spheredupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@538
//sdf_result = spheredupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@539
//sdf_result = tetrahedron_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@551
//sdf_result = tetrahedrondupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@552
//sdf_result = tetrahedrondupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@553
//sdf_result = tetrahedrondupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@554
//sdf_result = tetrahedronduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@555
//sdf_result = tetrahedrondupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@556
//sdf_result = tetrahedrondupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@557
//sdf_result = tetrahedrondupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@558
//sdf_result = tetrahedrondupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@559
//sdf_result = tetrahedrondupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@560
//sdf_result = tetrahedrondupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@561

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

	vec3 overridden_color;
	bool override_color = false;
	vec3 data = ray_marcher(ray_origin, ray_dir, overridden_color, override_color);

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
		else if (override_color) final_color = overridden_color;
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
	ALBEDO = calculate_albedo(ro, rd, SCREEN_UV, FRAGCOORD.xy, VIEWPORT_SIZE, PROJECTION_MATRIX, VIEW_MATRIX, discard_color) + 0.004; \
	if (discard_color) discard;

void fragment() {
	if (texture(pixels_to_render, UV).r < 0.5) discard;

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