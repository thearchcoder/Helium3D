shader_type spatial;
render_mode unshaded;

// Disabled when possible to reduce shader compilation times.
// Line numbers for these 2 lines must stay the same.
//#define USING_DOF
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
uniform bool fog_enabled = false;
uniform bool fog_volumetric = true;
uniform float fog_density = 0.01;
uniform float fog_falloff = 1.64;
uniform int fog_samples = 12;
uniform sampler2D fog_palette;
uniform float fog_brightness = 3.0;
uniform float fog_dither_scale = 255.0;
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
uniform vec4 tile_bounds;
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
uniform float fbairddelta_angle; // -@12
uniform vec3 fbairddelta_rotation1; // -@12
uniform vec3 fbairddelta_rotation2; // -@12
uniform float fbairddelta_scale; // -@12
//uniform float fbairddeltadupea_angle; // -@13
//uniform vec3 fbairddeltadupea_rotation1; // -@13
//uniform vec3 fbairddeltadupea_rotation2; // -@13
//uniform float fbairddeltadupea_scale; // -@13
//uniform float fbairddeltadupeb_angle; // -@14
//uniform vec3 fbairddeltadupeb_rotation1; // -@14
//uniform vec3 fbairddeltadupeb_rotation2; // -@14
//uniform float fbairddeltadupeb_scale; // -@14
//uniform float fbairddeltadupec_angle; // -@15
//uniform vec3 fbairddeltadupec_rotation1; // -@15
//uniform vec3 fbairddeltadupec_rotation2; // -@15
//uniform float fbairddeltadupec_scale; // -@15
//uniform float fbairddeltaduped_angle; // -@16
//uniform vec3 fbairddeltaduped_rotation1; // -@16
//uniform vec3 fbairddeltaduped_rotation2; // -@16
//uniform float fbairddeltaduped_scale; // -@16
//uniform float fbairddeltadupee_angle; // -@17
//uniform vec3 fbairddeltadupee_rotation1; // -@17
//uniform vec3 fbairddeltadupee_rotation2; // -@17
//uniform float fbairddeltadupee_scale; // -@17
//uniform float fbairddeltadupef_angle; // -@18
//uniform vec3 fbairddeltadupef_rotation1; // -@18
//uniform vec3 fbairddeltadupef_rotation2; // -@18
//uniform float fbairddeltadupef_scale; // -@18
//uniform float fbairddeltadupeg_angle; // -@19
//uniform vec3 fbairddeltadupeg_rotation1; // -@19
//uniform vec3 fbairddeltadupeg_rotation2; // -@19
//uniform float fbairddeltadupeg_scale; // -@19
//uniform float fbairddeltadupeh_angle; // -@20
//uniform vec3 fbairddeltadupeh_rotation1; // -@20
//uniform vec3 fbairddeltadupeh_rotation2; // -@20
//uniform float fbairddeltadupeh_scale; // -@20
//uniform float fbairddeltadupei_angle; // -@21
//uniform vec3 fbairddeltadupei_rotation1; // -@21
//uniform vec3 fbairddeltadupei_rotation2; // -@21
//uniform float fbairddeltadupei_scale; // -@21
//uniform float fbairddeltadupej_angle; // -@22
//uniform vec3 fbairddeltadupej_rotation1; // -@22
//uniform vec3 fbairddeltadupej_rotation2; // -@22
//uniform float fbairddeltadupej_scale; // -@22
//uniform vec4 fbasictransform_offset; // -@23
//uniform vec4 fbasictransform_scale; // -@23
//uniform vec2 fbasictransform_range; // -@23
//uniform vec4 fbasictransformdupea_offset; // -@24
//uniform vec4 fbasictransformdupea_scale; // -@24
//uniform vec2 fbasictransformdupea_range; // -@24
//uniform vec4 fbasictransformdupeb_offset; // -@25
//uniform vec4 fbasictransformdupeb_scale; // -@25
//uniform vec2 fbasictransformdupeb_range; // -@25
//uniform vec4 fbasictransformdupec_offset; // -@26
//uniform vec4 fbasictransformdupec_scale; // -@26
//uniform vec2 fbasictransformdupec_range; // -@26
//uniform vec4 fbasictransformduped_offset; // -@27
//uniform vec4 fbasictransformduped_scale; // -@27
//uniform vec2 fbasictransformduped_range; // -@27
//uniform vec4 fbasictransformdupee_offset; // -@28
//uniform vec4 fbasictransformdupee_scale; // -@28
//uniform vec2 fbasictransformdupee_range; // -@28
//uniform vec4 fbasictransformdupef_offset; // -@29
//uniform vec4 fbasictransformdupef_scale; // -@29
//uniform vec2 fbasictransformdupef_range; // -@29
//uniform vec4 fbasictransformdupeg_offset; // -@30
//uniform vec4 fbasictransformdupeg_scale; // -@30
//uniform vec2 fbasictransformdupeg_range; // -@30
//uniform vec4 fbasictransformdupeh_offset; // -@31
//uniform vec4 fbasictransformdupeh_scale; // -@31
//uniform vec2 fbasictransformdupeh_range; // -@31
//uniform vec4 fbasictransformdupei_offset; // -@32
//uniform vec4 fbasictransformdupei_scale; // -@32
//uniform vec2 fbasictransformdupei_range; // -@32
//uniform vec4 fbasictransformdupej_offset; // -@33
//uniform vec4 fbasictransformdupej_scale; // -@33
//uniform vec2 fbasictransformdupej_range; // -@33
//uniform bool fbenesiship_is_julia; // -@34
//uniform vec3 fbenesiship_julia_c; // -@34
//uniform bool fbenesishipdupea_is_julia; // -@35
//uniform vec3 fbenesishipdupea_julia_c; // -@35
//uniform bool fbenesishipdupeb_is_julia; // -@36
//uniform vec3 fbenesishipdupeb_julia_c; // -@36
//uniform bool fbenesishipdupec_is_julia; // -@37
//uniform vec3 fbenesishipdupec_julia_c; // -@37
//uniform bool fbenesishipduped_is_julia; // -@38
//uniform vec3 fbenesishipduped_julia_c; // -@38
//uniform bool fbenesishipdupee_is_julia; // -@39
//uniform vec3 fbenesishipdupee_julia_c; // -@39
//uniform bool fbenesishipdupef_is_julia; // -@40
//uniform vec3 fbenesishipdupef_julia_c; // -@40
//uniform bool fbenesishipdupeg_is_julia; // -@41
//uniform vec3 fbenesishipdupeg_julia_c; // -@41
//uniform bool fbenesishipdupeh_is_julia; // -@42
//uniform vec3 fbenesishipdupeh_julia_c; // -@42
//uniform bool fbenesishipdupei_is_julia; // -@43
//uniform vec3 fbenesishipdupei_julia_c; // -@43
//uniform bool fbenesishipdupej_is_julia; // -@44
//uniform vec3 fbenesishipdupej_julia_c; // -@44
//uniform bool fbristorbrot_is_julia; // -@45
//uniform vec3 fbristorbrot_julia_c; // -@45
//uniform vec3 fbristorbrot_multiply; // -@45
//uniform bool fbristorbrotdupea_is_julia; // -@46
//uniform vec3 fbristorbrotdupea_julia_c; // -@46
//uniform vec3 fbristorbrotdupea_multiply; // -@46
//uniform bool fbristorbrotdupeb_is_julia; // -@47
//uniform vec3 fbristorbrotdupeb_julia_c; // -@47
//uniform vec3 fbristorbrotdupeb_multiply; // -@47
//uniform bool fbristorbrotdupec_is_julia; // -@48
//uniform vec3 fbristorbrotdupec_julia_c; // -@48
//uniform vec3 fbristorbrotdupec_multiply; // -@48
//uniform bool fbristorbrotduped_is_julia; // -@49
//uniform vec3 fbristorbrotduped_julia_c; // -@49
//uniform vec3 fbristorbrotduped_multiply; // -@49
//uniform bool fbristorbrotdupee_is_julia; // -@50
//uniform vec3 fbristorbrotdupee_julia_c; // -@50
//uniform vec3 fbristorbrotdupee_multiply; // -@50
//uniform bool fbristorbrotdupef_is_julia; // -@51
//uniform vec3 fbristorbrotdupef_julia_c; // -@51
//uniform vec3 fbristorbrotdupef_multiply; // -@51
//uniform bool fbristorbrotdupeg_is_julia; // -@52
//uniform vec3 fbristorbrotdupeg_julia_c; // -@52
//uniform vec3 fbristorbrotdupeg_multiply; // -@52
//uniform bool fbristorbrotdupeh_is_julia; // -@53
//uniform vec3 fbristorbrotdupeh_julia_c; // -@53
//uniform vec3 fbristorbrotdupeh_multiply; // -@53
//uniform bool fbristorbrotdupei_is_julia; // -@54
//uniform vec3 fbristorbrotdupei_julia_c; // -@54
//uniform vec3 fbristorbrotdupei_multiply; // -@54
//uniform bool fbristorbrotdupej_is_julia; // -@55
//uniform vec3 fbristorbrotdupej_julia_c; // -@55
//uniform vec3 fbristorbrotdupej_multiply; // -@55
//uniform float fcircuit_scale; // -@56
//uniform vec4 fcircuit_abs1; // -@56
//uniform vec4 fcircuit_abs2; // -@56
//uniform vec2 fcircuit_box_fold; // -@56
//uniform vec4 fcircuit_box_minus; // -@56
//uniform float fcircuitdupea_scale; // -@57
//uniform vec4 fcircuitdupea_abs1; // -@57
//uniform vec4 fcircuitdupea_abs2; // -@57
//uniform vec2 fcircuitdupea_box_fold; // -@57
//uniform vec4 fcircuitdupea_box_minus; // -@57
//uniform float fcircuitdupeb_scale; // -@58
//uniform vec4 fcircuitdupeb_abs1; // -@58
//uniform vec4 fcircuitdupeb_abs2; // -@58
//uniform vec2 fcircuitdupeb_box_fold; // -@58
//uniform vec4 fcircuitdupeb_box_minus; // -@58
//uniform float fcircuitdupec_scale; // -@59
//uniform vec4 fcircuitdupec_abs1; // -@59
//uniform vec4 fcircuitdupec_abs2; // -@59
//uniform vec2 fcircuitdupec_box_fold; // -@59
//uniform vec4 fcircuitdupec_box_minus; // -@59
//uniform float fcircuitduped_scale; // -@60
//uniform vec4 fcircuitduped_abs1; // -@60
//uniform vec4 fcircuitduped_abs2; // -@60
//uniform vec2 fcircuitduped_box_fold; // -@60
//uniform vec4 fcircuitduped_box_minus; // -@60
//uniform float fcircuitdupee_scale; // -@61
//uniform vec4 fcircuitdupee_abs1; // -@61
//uniform vec4 fcircuitdupee_abs2; // -@61
//uniform vec2 fcircuitdupee_box_fold; // -@61
//uniform vec4 fcircuitdupee_box_minus; // -@61
//uniform float fcircuitdupef_scale; // -@62
//uniform vec4 fcircuitdupef_abs1; // -@62
//uniform vec4 fcircuitdupef_abs2; // -@62
//uniform vec2 fcircuitdupef_box_fold; // -@62
//uniform vec4 fcircuitdupef_box_minus; // -@62
//uniform float fcircuitdupeg_scale; // -@63
//uniform vec4 fcircuitdupeg_abs1; // -@63
//uniform vec4 fcircuitdupeg_abs2; // -@63
//uniform vec2 fcircuitdupeg_box_fold; // -@63
//uniform vec4 fcircuitdupeg_box_minus; // -@63
//uniform float fcircuitdupeh_scale; // -@64
//uniform vec4 fcircuitdupeh_abs1; // -@64
//uniform vec4 fcircuitdupeh_abs2; // -@64
//uniform vec2 fcircuitdupeh_box_fold; // -@64
//uniform vec4 fcircuitdupeh_box_minus; // -@64
//uniform float fcircuitdupei_scale; // -@65
//uniform vec4 fcircuitdupei_abs1; // -@65
//uniform vec4 fcircuitdupei_abs2; // -@65
//uniform vec2 fcircuitdupei_box_fold; // -@65
//uniform vec4 fcircuitdupei_box_minus; // -@65
//uniform float fcircuitdupej_scale; // -@66
//uniform vec4 fcircuitdupej_abs1; // -@66
//uniform vec4 fcircuitdupej_abs2; // -@66
//uniform vec2 fcircuitdupej_box_fold; // -@66
//uniform vec4 fcircuitdupej_box_minus; // -@66
//uniform vec3 fcube_position; // -@67
//uniform vec3 fcube_size; // -@67
//uniform float fcube_roundness; // -@67
//uniform bool fcube_hollow; // -@67
//uniform float fcube_hollow_edge; // -@67
//uniform vec3 fcubedupea_position; // -@68
//uniform vec3 fcubedupea_size; // -@68
//uniform float fcubedupea_roundness; // -@68
//uniform bool fcubedupea_hollow; // -@68
//uniform float fcubedupea_hollow_edge; // -@68
//uniform vec3 fcubedupeb_position; // -@69
//uniform vec3 fcubedupeb_size; // -@69
//uniform float fcubedupeb_roundness; // -@69
//uniform bool fcubedupeb_hollow; // -@69
//uniform float fcubedupeb_hollow_edge; // -@69
//uniform vec3 fcubedupec_position; // -@70
//uniform vec3 fcubedupec_size; // -@70
//uniform float fcubedupec_roundness; // -@70
//uniform bool fcubedupec_hollow; // -@70
//uniform float fcubedupec_hollow_edge; // -@70
//uniform vec3 fcubeduped_position; // -@71
//uniform vec3 fcubeduped_size; // -@71
//uniform float fcubeduped_roundness; // -@71
//uniform bool fcubeduped_hollow; // -@71
//uniform float fcubeduped_hollow_edge; // -@71
//uniform vec3 fcubedupee_position; // -@72
//uniform vec3 fcubedupee_size; // -@72
//uniform float fcubedupee_roundness; // -@72
//uniform bool fcubedupee_hollow; // -@72
//uniform float fcubedupee_hollow_edge; // -@72
//uniform vec3 fcubedupef_position; // -@73
//uniform vec3 fcubedupef_size; // -@73
//uniform float fcubedupef_roundness; // -@73
//uniform bool fcubedupef_hollow; // -@73
//uniform float fcubedupef_hollow_edge; // -@73
//uniform vec3 fcubedupeg_position; // -@74
//uniform vec3 fcubedupeg_size; // -@74
//uniform float fcubedupeg_roundness; // -@74
//uniform bool fcubedupeg_hollow; // -@74
//uniform float fcubedupeg_hollow_edge; // -@74
//uniform vec3 fcubedupeh_position; // -@75
//uniform vec3 fcubedupeh_size; // -@75
//uniform float fcubedupeh_roundness; // -@75
//uniform bool fcubedupeh_hollow; // -@75
//uniform float fcubedupeh_hollow_edge; // -@75
//uniform vec3 fcubedupei_position; // -@76
//uniform vec3 fcubedupei_size; // -@76
//uniform float fcubedupei_roundness; // -@76
//uniform bool fcubedupei_hollow; // -@76
//uniform float fcubedupei_hollow_edge; // -@76
//uniform vec3 fcubedupej_position; // -@77
//uniform vec3 fcubedupej_size; // -@77
//uniform float fcubedupej_roundness; // -@77
//uniform bool fcubedupej_hollow; // -@77
//uniform float fcubedupej_hollow_edge; // -@77
//uniform vec3 fdodecahedron_position; // -@78
//uniform float fdodecahedron_size; // -@78
//uniform float fdodecahedron_roundness; // -@78
//uniform vec3 fdodecahedrondupea_position; // -@79
//uniform float fdodecahedrondupea_size; // -@79
//uniform float fdodecahedrondupea_roundness; // -@79
//uniform vec3 fdodecahedrondupeb_position; // -@80
//uniform float fdodecahedrondupeb_size; // -@80
//uniform float fdodecahedrondupeb_roundness; // -@80
//uniform vec3 fdodecahedrondupec_position; // -@81
//uniform float fdodecahedrondupec_size; // -@81
//uniform float fdodecahedrondupec_roundness; // -@81
//uniform vec3 fdodecahedronduped_position; // -@82
//uniform float fdodecahedronduped_size; // -@82
//uniform float fdodecahedronduped_roundness; // -@82
//uniform vec3 fdodecahedrondupee_position; // -@83
//uniform float fdodecahedrondupee_size; // -@83
//uniform float fdodecahedrondupee_roundness; // -@83
//uniform vec3 fdodecahedrondupef_position; // -@84
//uniform float fdodecahedrondupef_size; // -@84
//uniform float fdodecahedrondupef_roundness; // -@84
//uniform vec3 fdodecahedrondupeg_position; // -@85
//uniform float fdodecahedrondupeg_size; // -@85
//uniform float fdodecahedrondupeg_roundness; // -@85
//uniform vec3 fdodecahedrondupeh_position; // -@86
//uniform float fdodecahedrondupeh_size; // -@86
//uniform float fdodecahedrondupeh_roundness; // -@86
//uniform vec3 fdodecahedrondupei_position; // -@87
//uniform float fdodecahedrondupei_size; // -@87
//uniform float fdodecahedrondupei_roundness; // -@87
//uniform vec3 fdodecahedrondupej_position; // -@88
//uniform float fdodecahedrondupej_size; // -@88
//uniform float fdodecahedrondupej_roundness; // -@88
//uniform float fgemstone_scale; // -@89
//uniform vec3 fgemstone_clamp; // -@89
//uniform vec3 fgemstone_offset; // -@89
//uniform float fgemstonedupea_scale; // -@90
//uniform vec3 fgemstonedupea_clamp; // -@90
//uniform vec3 fgemstonedupea_offset; // -@90
//uniform float fgemstonedupeb_scale; // -@91
//uniform vec3 fgemstonedupeb_clamp; // -@91
//uniform vec3 fgemstonedupeb_offset; // -@91
//uniform float fgemstonedupec_scale; // -@92
//uniform vec3 fgemstonedupec_clamp; // -@92
//uniform vec3 fgemstonedupec_offset; // -@92
//uniform float fgemstoneduped_scale; // -@93
//uniform vec3 fgemstoneduped_clamp; // -@93
//uniform vec3 fgemstoneduped_offset; // -@93
//uniform float fgemstonedupee_scale; // -@94
//uniform vec3 fgemstonedupee_clamp; // -@94
//uniform vec3 fgemstonedupee_offset; // -@94
//uniform float fgemstonedupef_scale; // -@95
//uniform vec3 fgemstonedupef_clamp; // -@95
//uniform vec3 fgemstonedupef_offset; // -@95
//uniform float fgemstonedupeg_scale; // -@96
//uniform vec3 fgemstonedupeg_clamp; // -@96
//uniform vec3 fgemstonedupeg_offset; // -@96
//uniform float fgemstonedupeh_scale; // -@97
//uniform vec3 fgemstonedupeh_clamp; // -@97
//uniform vec3 fgemstonedupeh_offset; // -@97
//uniform float fgemstonedupei_scale; // -@98
//uniform vec3 fgemstonedupei_clamp; // -@98
//uniform vec3 fgemstonedupei_offset; // -@98
//uniform float fgemstonedupej_scale; // -@99
//uniform vec3 fgemstonedupej_clamp; // -@99
//uniform vec3 fgemstonedupej_offset; // -@99
//uniform vec3 fgyroid_position; // -@100
//uniform float fgyroid_scale; // -@100
//uniform float fgyroid_sphere_radius; // -@100
//uniform float fgyroid_time; // -@100
//uniform float fgyroid_thickness; // -@100
//uniform float fgyroid_bias; // -@100
//uniform vec4 fgyroid_control; // -@100
//uniform vec2 fgyroid_offset; // -@100
//uniform bool fgyroid_oriented; // -@100
//uniform bool fgyroid_abs; // -@100
//uniform vec3 fgyroiddupea_position; // -@101
//uniform float fgyroiddupea_scale; // -@101
//uniform float fgyroiddupea_sphere_radius; // -@101
//uniform float fgyroiddupea_time; // -@101
//uniform float fgyroiddupea_thickness; // -@101
//uniform float fgyroiddupea_bias; // -@101
//uniform vec4 fgyroiddupea_control; // -@101
//uniform vec2 fgyroiddupea_offset; // -@101
//uniform bool fgyroiddupea_oriented; // -@101
//uniform bool fgyroiddupea_abs; // -@101
//uniform vec3 fgyroiddupeb_position; // -@102
//uniform float fgyroiddupeb_scale; // -@102
//uniform float fgyroiddupeb_sphere_radius; // -@102
//uniform float fgyroiddupeb_time; // -@102
//uniform float fgyroiddupeb_thickness; // -@102
//uniform float fgyroiddupeb_bias; // -@102
//uniform vec4 fgyroiddupeb_control; // -@102
//uniform vec2 fgyroiddupeb_offset; // -@102
//uniform bool fgyroiddupeb_oriented; // -@102
//uniform bool fgyroiddupeb_abs; // -@102
//uniform vec3 fgyroiddupec_position; // -@103
//uniform float fgyroiddupec_scale; // -@103
//uniform float fgyroiddupec_sphere_radius; // -@103
//uniform float fgyroiddupec_time; // -@103
//uniform float fgyroiddupec_thickness; // -@103
//uniform float fgyroiddupec_bias; // -@103
//uniform vec4 fgyroiddupec_control; // -@103
//uniform vec2 fgyroiddupec_offset; // -@103
//uniform bool fgyroiddupec_oriented; // -@103
//uniform bool fgyroiddupec_abs; // -@103
//uniform vec3 fgyroidduped_position; // -@104
//uniform float fgyroidduped_scale; // -@104
//uniform float fgyroidduped_sphere_radius; // -@104
//uniform float fgyroidduped_time; // -@104
//uniform float fgyroidduped_thickness; // -@104
//uniform float fgyroidduped_bias; // -@104
//uniform vec4 fgyroidduped_control; // -@104
//uniform vec2 fgyroidduped_offset; // -@104
//uniform bool fgyroidduped_oriented; // -@104
//uniform bool fgyroidduped_abs; // -@104
//uniform vec3 fgyroiddupee_position; // -@105
//uniform float fgyroiddupee_scale; // -@105
//uniform float fgyroiddupee_sphere_radius; // -@105
//uniform float fgyroiddupee_time; // -@105
//uniform float fgyroiddupee_thickness; // -@105
//uniform float fgyroiddupee_bias; // -@105
//uniform vec4 fgyroiddupee_control; // -@105
//uniform vec2 fgyroiddupee_offset; // -@105
//uniform bool fgyroiddupee_oriented; // -@105
//uniform bool fgyroiddupee_abs; // -@105
//uniform vec3 fgyroiddupef_position; // -@106
//uniform float fgyroiddupef_scale; // -@106
//uniform float fgyroiddupef_sphere_radius; // -@106
//uniform float fgyroiddupef_time; // -@106
//uniform float fgyroiddupef_thickness; // -@106
//uniform float fgyroiddupef_bias; // -@106
//uniform vec4 fgyroiddupef_control; // -@106
//uniform vec2 fgyroiddupef_offset; // -@106
//uniform bool fgyroiddupef_oriented; // -@106
//uniform bool fgyroiddupef_abs; // -@106
//uniform vec3 fgyroiddupeg_position; // -@107
//uniform float fgyroiddupeg_scale; // -@107
//uniform float fgyroiddupeg_sphere_radius; // -@107
//uniform float fgyroiddupeg_time; // -@107
//uniform float fgyroiddupeg_thickness; // -@107
//uniform float fgyroiddupeg_bias; // -@107
//uniform vec4 fgyroiddupeg_control; // -@107
//uniform vec2 fgyroiddupeg_offset; // -@107
//uniform bool fgyroiddupeg_oriented; // -@107
//uniform bool fgyroiddupeg_abs; // -@107
//uniform vec3 fgyroiddupeh_position; // -@108
//uniform float fgyroiddupeh_scale; // -@108
//uniform float fgyroiddupeh_sphere_radius; // -@108
//uniform float fgyroiddupeh_time; // -@108
//uniform float fgyroiddupeh_thickness; // -@108
//uniform float fgyroiddupeh_bias; // -@108
//uniform vec4 fgyroiddupeh_control; // -@108
//uniform vec2 fgyroiddupeh_offset; // -@108
//uniform bool fgyroiddupeh_oriented; // -@108
//uniform bool fgyroiddupeh_abs; // -@108
//uniform vec3 fgyroiddupei_position; // -@109
//uniform float fgyroiddupei_scale; // -@109
//uniform float fgyroiddupei_sphere_radius; // -@109
//uniform float fgyroiddupei_time; // -@109
//uniform float fgyroiddupei_thickness; // -@109
//uniform float fgyroiddupei_bias; // -@109
//uniform vec4 fgyroiddupei_control; // -@109
//uniform vec2 fgyroiddupei_offset; // -@109
//uniform bool fgyroiddupei_oriented; // -@109
//uniform bool fgyroiddupei_abs; // -@109
//uniform vec3 fgyroiddupej_position; // -@110
//uniform float fgyroiddupej_scale; // -@110
//uniform float fgyroiddupej_sphere_radius; // -@110
//uniform float fgyroiddupej_time; // -@110
//uniform float fgyroiddupej_thickness; // -@110
//uniform float fgyroiddupej_bias; // -@110
//uniform vec4 fgyroiddupej_control; // -@110
//uniform vec2 fgyroiddupej_offset; // -@110
//uniform bool fgyroiddupej_oriented; // -@110
//uniform bool fgyroiddupej_abs; // -@110
//uniform float fhollowtetrahedron_scale; // -@111
//uniform float fhollowtetrahedron_thickness; // -@111
//uniform vec3 fhollowtetrahedron_offset; // -@111
//uniform float fhollowtetrahedrondupea_scale; // -@112
//uniform float fhollowtetrahedrondupea_thickness; // -@112
//uniform vec3 fhollowtetrahedrondupea_offset; // -@112
//uniform float fhollowtetrahedrondupeb_scale; // -@113
//uniform float fhollowtetrahedrondupeb_thickness; // -@113
//uniform vec3 fhollowtetrahedrondupeb_offset; // -@113
//uniform float fhollowtetrahedrondupec_scale; // -@114
//uniform float fhollowtetrahedrondupec_thickness; // -@114
//uniform vec3 fhollowtetrahedrondupec_offset; // -@114
//uniform float fhollowtetrahedronduped_scale; // -@115
//uniform float fhollowtetrahedronduped_thickness; // -@115
//uniform vec3 fhollowtetrahedronduped_offset; // -@115
//uniform float fhollowtetrahedrondupee_scale; // -@116
//uniform float fhollowtetrahedrondupee_thickness; // -@116
//uniform vec3 fhollowtetrahedrondupee_offset; // -@116
//uniform float fhollowtetrahedrondupef_scale; // -@117
//uniform float fhollowtetrahedrondupef_thickness; // -@117
//uniform vec3 fhollowtetrahedrondupef_offset; // -@117
//uniform float fhollowtetrahedrondupeg_scale; // -@118
//uniform float fhollowtetrahedrondupeg_thickness; // -@118
//uniform vec3 fhollowtetrahedrondupeg_offset; // -@118
//uniform float fhollowtetrahedrondupeh_scale; // -@119
//uniform float fhollowtetrahedrondupeh_thickness; // -@119
//uniform vec3 fhollowtetrahedrondupeh_offset; // -@119
//uniform float fhollowtetrahedrondupei_scale; // -@120
//uniform float fhollowtetrahedrondupei_thickness; // -@120
//uniform vec3 fhollowtetrahedrondupei_offset; // -@120
//uniform float fhollowtetrahedrondupej_scale; // -@121
//uniform float fhollowtetrahedrondupej_thickness; // -@121
//uniform vec3 fhollowtetrahedrondupej_offset; // -@121
//uniform vec3 ficosahedron_position; // -@122
//uniform float ficosahedron_size; // -@122
//uniform vec3 ficosahedrondupea_position; // -@123
//uniform float ficosahedrondupea_size; // -@123
//uniform vec3 ficosahedrondupeb_position; // -@124
//uniform float ficosahedrondupeb_size; // -@124
//uniform vec3 ficosahedrondupec_position; // -@125
//uniform float ficosahedrondupec_size; // -@125
//uniform vec3 ficosahedronduped_position; // -@126
//uniform float ficosahedronduped_size; // -@126
//uniform vec3 ficosahedrondupee_position; // -@127
//uniform float ficosahedrondupee_size; // -@127
//uniform vec3 ficosahedrondupef_position; // -@128
//uniform float ficosahedrondupef_size; // -@128
//uniform vec3 ficosahedrondupeg_position; // -@129
//uniform float ficosahedrondupeg_size; // -@129
//uniform vec3 ficosahedrondupeh_position; // -@130
//uniform float ficosahedrondupeh_size; // -@130
//uniform vec3 ficosahedrondupei_position; // -@131
//uniform float ficosahedrondupei_size; // -@131
//uniform vec3 ficosahedrondupej_position; // -@132
//uniform float ficosahedrondupej_size; // -@132
//uniform float finversebox_scale; // -@133
//uniform float finversebox_thickness; // -@133
//uniform vec3 finversebox_offset; // -@133
//uniform float finverseboxdupea_scale; // -@134
//uniform float finverseboxdupea_thickness; // -@134
//uniform vec3 finverseboxdupea_offset; // -@134
//uniform float finverseboxdupeb_scale; // -@135
//uniform float finverseboxdupeb_thickness; // -@135
//uniform vec3 finverseboxdupeb_offset; // -@135
//uniform float finverseboxdupec_scale; // -@136
//uniform float finverseboxdupec_thickness; // -@136
//uniform vec3 finverseboxdupec_offset; // -@136
//uniform float finverseboxduped_scale; // -@137
//uniform float finverseboxduped_thickness; // -@137
//uniform vec3 finverseboxduped_offset; // -@137
//uniform float finverseboxdupee_scale; // -@138
//uniform float finverseboxdupee_thickness; // -@138
//uniform vec3 finverseboxdupee_offset; // -@138
//uniform float finverseboxdupef_scale; // -@139
//uniform float finverseboxdupef_thickness; // -@139
//uniform vec3 finverseboxdupef_offset; // -@139
//uniform float finverseboxdupeg_scale; // -@140
//uniform float finverseboxdupeg_thickness; // -@140
//uniform vec3 finverseboxdupeg_offset; // -@140
//uniform float finverseboxdupeh_scale; // -@141
//uniform float finverseboxdupeh_thickness; // -@141
//uniform vec3 finverseboxdupeh_offset; // -@141
//uniform float finverseboxdupei_scale; // -@142
//uniform float finverseboxdupei_thickness; // -@142
//uniform vec3 finverseboxdupei_offset; // -@142
//uniform float finverseboxdupej_scale; // -@143
//uniform float finverseboxdupej_thickness; // -@143
//uniform vec3 finverseboxdupej_offset; // -@143
//uniform vec4 finversiontransform_sphere; // -@144
//uniform vec2 finversiontransform_range; // -@144
//uniform vec4 finversiontransformdupea_sphere; // -@145
//uniform vec2 finversiontransformdupea_range; // -@145
//uniform vec4 finversiontransformdupeb_sphere; // -@146
//uniform vec2 finversiontransformdupeb_range; // -@146
//uniform vec4 finversiontransformdupec_sphere; // -@147
//uniform vec2 finversiontransformdupec_range; // -@147
//uniform vec4 finversiontransformduped_sphere; // -@148
//uniform vec2 finversiontransformduped_range; // -@148
//uniform vec4 finversiontransformdupee_sphere; // -@149
//uniform vec2 finversiontransformdupee_range; // -@149
//uniform vec4 finversiontransformdupef_sphere; // -@150
//uniform vec2 finversiontransformdupef_range; // -@150
//uniform vec4 finversiontransformdupeg_sphere; // -@151
//uniform vec2 finversiontransformdupeg_range; // -@151
//uniform vec4 finversiontransformdupeh_sphere; // -@152
//uniform vec2 finversiontransformdupeh_range; // -@152
//uniform vec4 finversiontransformdupei_sphere; // -@153
//uniform vec2 finversiontransformdupei_range; // -@153
//uniform vec4 finversiontransformdupej_sphere; // -@154
//uniform vec2 finversiontransformdupej_range; // -@154
//uniform vec2 fjerusalemcube_scale; // -@155
//uniform vec3 fjerusalemcube_offset; // -@155
//uniform vec3 fjerusalemcube_rotation1; // -@155
//uniform vec3 fjerusalemcube_rotation2; // -@155
//uniform vec3 fjerusalemcube_abs_add; // -@155
//uniform vec3 fjerusalemcube_abs_minus; // -@155
//uniform vec2 fjerusalemcubedupea_scale; // -@156
//uniform vec3 fjerusalemcubedupea_offset; // -@156
//uniform vec3 fjerusalemcubedupea_rotation1; // -@156
//uniform vec3 fjerusalemcubedupea_rotation2; // -@156
//uniform vec3 fjerusalemcubedupea_abs_add; // -@156
//uniform vec3 fjerusalemcubedupea_abs_minus; // -@156
//uniform vec2 fjerusalemcubedupeb_scale; // -@157
//uniform vec3 fjerusalemcubedupeb_offset; // -@157
//uniform vec3 fjerusalemcubedupeb_rotation1; // -@157
//uniform vec3 fjerusalemcubedupeb_rotation2; // -@157
//uniform vec3 fjerusalemcubedupeb_abs_add; // -@157
//uniform vec3 fjerusalemcubedupeb_abs_minus; // -@157
//uniform vec2 fjerusalemcubedupec_scale; // -@158
//uniform vec3 fjerusalemcubedupec_offset; // -@158
//uniform vec3 fjerusalemcubedupec_rotation1; // -@158
//uniform vec3 fjerusalemcubedupec_rotation2; // -@158
//uniform vec3 fjerusalemcubedupec_abs_add; // -@158
//uniform vec3 fjerusalemcubedupec_abs_minus; // -@158
//uniform vec2 fjerusalemcubeduped_scale; // -@159
//uniform vec3 fjerusalemcubeduped_offset; // -@159
//uniform vec3 fjerusalemcubeduped_rotation1; // -@159
//uniform vec3 fjerusalemcubeduped_rotation2; // -@159
//uniform vec3 fjerusalemcubeduped_abs_add; // -@159
//uniform vec3 fjerusalemcubeduped_abs_minus; // -@159
//uniform vec2 fjerusalemcubedupee_scale; // -@160
//uniform vec3 fjerusalemcubedupee_offset; // -@160
//uniform vec3 fjerusalemcubedupee_rotation1; // -@160
//uniform vec3 fjerusalemcubedupee_rotation2; // -@160
//uniform vec3 fjerusalemcubedupee_abs_add; // -@160
//uniform vec3 fjerusalemcubedupee_abs_minus; // -@160
//uniform vec2 fjerusalemcubedupef_scale; // -@161
//uniform vec3 fjerusalemcubedupef_offset; // -@161
//uniform vec3 fjerusalemcubedupef_rotation1; // -@161
//uniform vec3 fjerusalemcubedupef_rotation2; // -@161
//uniform vec3 fjerusalemcubedupef_abs_add; // -@161
//uniform vec3 fjerusalemcubedupef_abs_minus; // -@161
//uniform vec2 fjerusalemcubedupeg_scale; // -@162
//uniform vec3 fjerusalemcubedupeg_offset; // -@162
//uniform vec3 fjerusalemcubedupeg_rotation1; // -@162
//uniform vec3 fjerusalemcubedupeg_rotation2; // -@162
//uniform vec3 fjerusalemcubedupeg_abs_add; // -@162
//uniform vec3 fjerusalemcubedupeg_abs_minus; // -@162
//uniform vec2 fjerusalemcubedupeh_scale; // -@163
//uniform vec3 fjerusalemcubedupeh_offset; // -@163
//uniform vec3 fjerusalemcubedupeh_rotation1; // -@163
//uniform vec3 fjerusalemcubedupeh_rotation2; // -@163
//uniform vec3 fjerusalemcubedupeh_abs_add; // -@163
//uniform vec3 fjerusalemcubedupeh_abs_minus; // -@163
//uniform vec2 fjerusalemcubedupei_scale; // -@164
//uniform vec3 fjerusalemcubedupei_offset; // -@164
//uniform vec3 fjerusalemcubedupei_rotation1; // -@164
//uniform vec3 fjerusalemcubedupei_rotation2; // -@164
//uniform vec3 fjerusalemcubedupei_abs_add; // -@164
//uniform vec3 fjerusalemcubedupei_abs_minus; // -@164
//uniform vec2 fjerusalemcubedupej_scale; // -@165
//uniform vec3 fjerusalemcubedupej_offset; // -@165
//uniform vec3 fjerusalemcubedupej_rotation1; // -@165
//uniform vec3 fjerusalemcubedupej_rotation2; // -@165
//uniform vec3 fjerusalemcubedupej_abs_add; // -@165
//uniform vec3 fjerusalemcubedupej_abs_minus; // -@165
//uniform int fkalaidotransform_axis; // -@166
//uniform int fkalaidotransform_mode; // -@166
//uniform float fkalaidotransform_symmetry; // -@166
//uniform vec2 fkalaidotransform_range; // -@166
//uniform int fkalaidotransformdupea_axis; // -@167
//uniform int fkalaidotransformdupea_mode; // -@167
//uniform float fkalaidotransformdupea_symmetry; // -@167
//uniform vec2 fkalaidotransformdupea_range; // -@167
//uniform int fkalaidotransformdupeb_axis; // -@168
//uniform int fkalaidotransformdupeb_mode; // -@168
//uniform float fkalaidotransformdupeb_symmetry; // -@168
//uniform vec2 fkalaidotransformdupeb_range; // -@168
//uniform int fkalaidotransformdupec_axis; // -@169
//uniform int fkalaidotransformdupec_mode; // -@169
//uniform float fkalaidotransformdupec_symmetry; // -@169
//uniform vec2 fkalaidotransformdupec_range; // -@169
//uniform int fkalaidotransformduped_axis; // -@170
//uniform int fkalaidotransformduped_mode; // -@170
//uniform float fkalaidotransformduped_symmetry; // -@170
//uniform vec2 fkalaidotransformduped_range; // -@170
//uniform int fkalaidotransformdupee_axis; // -@171
//uniform int fkalaidotransformdupee_mode; // -@171
//uniform float fkalaidotransformdupee_symmetry; // -@171
//uniform vec2 fkalaidotransformdupee_range; // -@171
//uniform int fkalaidotransformdupef_axis; // -@172
//uniform int fkalaidotransformdupef_mode; // -@172
//uniform float fkalaidotransformdupef_symmetry; // -@172
//uniform vec2 fkalaidotransformdupef_range; // -@172
//uniform int fkalaidotransformdupeg_axis; // -@173
//uniform int fkalaidotransformdupeg_mode; // -@173
//uniform float fkalaidotransformdupeg_symmetry; // -@173
//uniform vec2 fkalaidotransformdupeg_range; // -@173
//uniform int fkalaidotransformdupeh_axis; // -@174
//uniform int fkalaidotransformdupeh_mode; // -@174
//uniform float fkalaidotransformdupeh_symmetry; // -@174
//uniform vec2 fkalaidotransformdupeh_range; // -@174
//uniform int fkalaidotransformdupei_axis; // -@175
//uniform int fkalaidotransformdupei_mode; // -@175
//uniform float fkalaidotransformdupei_symmetry; // -@175
//uniform vec2 fkalaidotransformdupei_range; // -@175
//uniform int fkalaidotransformdupej_axis; // -@176
//uniform int fkalaidotransformdupej_mode; // -@176
//uniform float fkalaidotransformdupej_symmetry; // -@176
//uniform vec2 fkalaidotransformdupej_range; // -@176
//uniform float fkalibox_scale; // -@177
//uniform vec3 fkalibox_offset1; // -@177
//uniform vec3 fkalibox_offset2; // -@177
//uniform float fkaliboxdupea_scale; // -@178
//uniform vec3 fkaliboxdupea_offset1; // -@178
//uniform vec3 fkaliboxdupea_offset2; // -@178
//uniform float fkaliboxdupeb_scale; // -@179
//uniform vec3 fkaliboxdupeb_offset1; // -@179
//uniform vec3 fkaliboxdupeb_offset2; // -@179
//uniform float fkaliboxdupec_scale; // -@180
//uniform vec3 fkaliboxdupec_offset1; // -@180
//uniform vec3 fkaliboxdupec_offset2; // -@180
//uniform float fkaliboxduped_scale; // -@181
//uniform vec3 fkaliboxduped_offset1; // -@181
//uniform vec3 fkaliboxduped_offset2; // -@181
//uniform float fkaliboxdupee_scale; // -@182
//uniform vec3 fkaliboxdupee_offset1; // -@182
//uniform vec3 fkaliboxdupee_offset2; // -@182
//uniform float fkaliboxdupef_scale; // -@183
//uniform vec3 fkaliboxdupef_offset1; // -@183
//uniform vec3 fkaliboxdupef_offset2; // -@183
//uniform float fkaliboxdupeg_scale; // -@184
//uniform vec3 fkaliboxdupeg_offset1; // -@184
//uniform vec3 fkaliboxdupeg_offset2; // -@184
//uniform float fkaliboxdupeh_scale; // -@185
//uniform vec3 fkaliboxdupeh_offset1; // -@185
//uniform vec3 fkaliboxdupeh_offset2; // -@185
//uniform float fkaliboxdupei_scale; // -@186
//uniform vec3 fkaliboxdupei_offset1; // -@186
//uniform vec3 fkaliboxdupei_offset2; // -@186
//uniform float fkaliboxdupej_scale; // -@187
//uniform vec3 fkaliboxdupej_offset1; // -@187
//uniform vec3 fkaliboxdupej_offset2; // -@187
//uniform vec3 fkaliliving_c; // -@188
//uniform vec3 fkaliliving_rotation1; // -@188
//uniform vec3 fkaliliving_rotation2; // -@188
//uniform float fkaliliving_scale; // -@188
//uniform vec3 fkalilivingdupea_c; // -@189
//uniform vec3 fkalilivingdupea_rotation1; // -@189
//uniform vec3 fkalilivingdupea_rotation2; // -@189
//uniform float fkalilivingdupea_scale; // -@189
//uniform vec3 fkalilivingdupeb_c; // -@190
//uniform vec3 fkalilivingdupeb_rotation1; // -@190
//uniform vec3 fkalilivingdupeb_rotation2; // -@190
//uniform float fkalilivingdupeb_scale; // -@190
//uniform vec3 fkalilivingdupec_c; // -@191
//uniform vec3 fkalilivingdupec_rotation1; // -@191
//uniform vec3 fkalilivingdupec_rotation2; // -@191
//uniform float fkalilivingdupec_scale; // -@191
//uniform vec3 fkalilivingduped_c; // -@192
//uniform vec3 fkalilivingduped_rotation1; // -@192
//uniform vec3 fkalilivingduped_rotation2; // -@192
//uniform float fkalilivingduped_scale; // -@192
//uniform vec3 fkalilivingdupee_c; // -@193
//uniform vec3 fkalilivingdupee_rotation1; // -@193
//uniform vec3 fkalilivingdupee_rotation2; // -@193
//uniform float fkalilivingdupee_scale; // -@193
//uniform vec3 fkalilivingdupef_c; // -@194
//uniform vec3 fkalilivingdupef_rotation1; // -@194
//uniform vec3 fkalilivingdupef_rotation2; // -@194
//uniform float fkalilivingdupef_scale; // -@194
//uniform vec3 fkalilivingdupeg_c; // -@195
//uniform vec3 fkalilivingdupeg_rotation1; // -@195
//uniform vec3 fkalilivingdupeg_rotation2; // -@195
//uniform float fkalilivingdupeg_scale; // -@195
//uniform vec3 fkalilivingdupeh_c; // -@196
//uniform vec3 fkalilivingdupeh_rotation1; // -@196
//uniform vec3 fkalilivingdupeh_rotation2; // -@196
//uniform float fkalilivingdupeh_scale; // -@196
//uniform vec3 fkalilivingdupei_c; // -@197
//uniform vec3 fkalilivingdupei_rotation1; // -@197
//uniform vec3 fkalilivingdupei_rotation2; // -@197
//uniform float fkalilivingdupei_scale; // -@197
//uniform vec3 fkalilivingdupej_c; // -@198
//uniform vec3 fkalilivingdupej_rotation1; // -@198
//uniform vec3 fkalilivingdupej_rotation2; // -@198
//uniform float fkalilivingdupej_scale; // -@198
//uniform vec4 fkaliredux_folds; // -@199
//uniform vec3 fkaliredux_minus; // -@199
//uniform float fkaliredux_scale; // -@199
//uniform vec4 fkalireduxdupea_folds; // -@200
//uniform vec3 fkalireduxdupea_minus; // -@200
//uniform float fkalireduxdupea_scale; // -@200
//uniform vec4 fkalireduxdupeb_folds; // -@201
//uniform vec3 fkalireduxdupeb_minus; // -@201
//uniform float fkalireduxdupeb_scale; // -@201
//uniform vec4 fkalireduxdupec_folds; // -@202
//uniform vec3 fkalireduxdupec_minus; // -@202
//uniform float fkalireduxdupec_scale; // -@202
//uniform vec4 fkalireduxduped_folds; // -@203
//uniform vec3 fkalireduxduped_minus; // -@203
//uniform float fkalireduxduped_scale; // -@203
//uniform vec4 fkalireduxdupee_folds; // -@204
//uniform vec3 fkalireduxdupee_minus; // -@204
//uniform float fkalireduxdupee_scale; // -@204
//uniform vec4 fkalireduxdupef_folds; // -@205
//uniform vec3 fkalireduxdupef_minus; // -@205
//uniform float fkalireduxdupef_scale; // -@205
//uniform vec4 fkalireduxdupeg_folds; // -@206
//uniform vec3 fkalireduxdupeg_minus; // -@206
//uniform float fkalireduxdupeg_scale; // -@206
//uniform vec4 fkalireduxdupeh_folds; // -@207
//uniform vec3 fkalireduxdupeh_minus; // -@207
//uniform float fkalireduxdupeh_scale; // -@207
//uniform vec4 fkalireduxdupei_folds; // -@208
//uniform vec3 fkalireduxdupei_minus; // -@208
//uniform float fkalireduxdupei_scale; // -@208
//uniform vec4 fkalireduxdupej_folds; // -@209
//uniform vec3 fkalireduxdupej_minus; // -@209
//uniform float fkalireduxdupej_scale; // -@209
//uniform bool fklenian_show_balls; // -@210
//uniform float fklenian_x; // -@210
//uniform float fklenian_y; // -@210
//uniform float fklenian_box_size_x; // -@210
//uniform float fklenian_box_size_z; // -@210
//uniform bool fkleniandupea_show_balls; // -@211
//uniform float fkleniandupea_x; // -@211
//uniform float fkleniandupea_y; // -@211
//uniform float fkleniandupea_box_size_x; // -@211
//uniform float fkleniandupea_box_size_z; // -@211
//uniform bool fkleniandupeb_show_balls; // -@212
//uniform float fkleniandupeb_x; // -@212
//uniform float fkleniandupeb_y; // -@212
//uniform float fkleniandupeb_box_size_x; // -@212
//uniform float fkleniandupeb_box_size_z; // -@212
//uniform bool fkleniandupec_show_balls; // -@213
//uniform float fkleniandupec_x; // -@213
//uniform float fkleniandupec_y; // -@213
//uniform float fkleniandupec_box_size_x; // -@213
//uniform float fkleniandupec_box_size_z; // -@213
//uniform bool fklenianduped_show_balls; // -@214
//uniform float fklenianduped_x; // -@214
//uniform float fklenianduped_y; // -@214
//uniform float fklenianduped_box_size_x; // -@214
//uniform float fklenianduped_box_size_z; // -@214
//uniform bool fkleniandupee_show_balls; // -@215
//uniform float fkleniandupee_x; // -@215
//uniform float fkleniandupee_y; // -@215
//uniform float fkleniandupee_box_size_x; // -@215
//uniform float fkleniandupee_box_size_z; // -@215
//uniform bool fkleniandupef_show_balls; // -@216
//uniform float fkleniandupef_x; // -@216
//uniform float fkleniandupef_y; // -@216
//uniform float fkleniandupef_box_size_x; // -@216
//uniform float fkleniandupef_box_size_z; // -@216
//uniform bool fkleniandupeg_show_balls; // -@217
//uniform float fkleniandupeg_x; // -@217
//uniform float fkleniandupeg_y; // -@217
//uniform float fkleniandupeg_box_size_x; // -@217
//uniform float fkleniandupeg_box_size_z; // -@217
//uniform bool fkleniandupeh_show_balls; // -@218
//uniform float fkleniandupeh_x; // -@218
//uniform float fkleniandupeh_y; // -@218
//uniform float fkleniandupeh_box_size_x; // -@218
//uniform float fkleniandupeh_box_size_z; // -@218
//uniform bool fkleniandupei_show_balls; // -@219
//uniform float fkleniandupei_x; // -@219
//uniform float fkleniandupei_y; // -@219
//uniform float fkleniandupei_box_size_x; // -@219
//uniform float fkleniandupei_box_size_z; // -@219
//uniform bool fkleniandupej_show_balls; // -@220
//uniform float fkleniandupej_x; // -@220
//uniform float fkleniandupej_y; // -@220
//uniform float fkleniandupej_box_size_x; // -@220
//uniform float fkleniandupej_box_size_z; // -@220
//uniform float fkochcube_scale; // -@221
//uniform int fkochcube_variant; // -@221
//uniform bool fkochcube_first_zrev; // -@221
//uniform bool fkochcube_pxyzminuss; // -@221
//uniform bool fkochcube_psortsymmetry1; // -@221
//uniform bool fkochcube_psortsymmetry2; // -@221
//uniform bool fkochcube_foldzbefore; // -@221
//uniform bool fkochcube_abs_x; // -@221
//uniform bool fkochcube_abs_y; // -@221
//uniform bool fkochcube_abs_z; // -@221
//uniform int fkochcube_fold1; // -@221
//uniform int fkochcube_fold2; // -@221
//uniform bool fkochcube_fold3; // -@221
//uniform bool fkochcube_fold4; // -@221
//uniform bool fkochcube_reflection; // -@221
//uniform vec3 fkochcube_rotation1; // -@221
//uniform vec3 fkochcube_rotation2; // -@221
//uniform float fkochcubedupea_scale; // -@222
//uniform int fkochcubedupea_variant; // -@222
//uniform bool fkochcubedupea_first_zrev; // -@222
//uniform bool fkochcubedupea_pxyzminuss; // -@222
//uniform bool fkochcubedupea_psortsymmetry1; // -@222
//uniform bool fkochcubedupea_psortsymmetry2; // -@222
//uniform bool fkochcubedupea_foldzbefore; // -@222
//uniform bool fkochcubedupea_abs_x; // -@222
//uniform bool fkochcubedupea_abs_y; // -@222
//uniform bool fkochcubedupea_abs_z; // -@222
//uniform int fkochcubedupea_fold1; // -@222
//uniform int fkochcubedupea_fold2; // -@222
//uniform bool fkochcubedupea_fold3; // -@222
//uniform bool fkochcubedupea_fold4; // -@222
//uniform bool fkochcubedupea_reflection; // -@222
//uniform vec3 fkochcubedupea_rotation1; // -@222
//uniform vec3 fkochcubedupea_rotation2; // -@222
//uniform float fkochcubedupeb_scale; // -@223
//uniform int fkochcubedupeb_variant; // -@223
//uniform bool fkochcubedupeb_first_zrev; // -@223
//uniform bool fkochcubedupeb_pxyzminuss; // -@223
//uniform bool fkochcubedupeb_psortsymmetry1; // -@223
//uniform bool fkochcubedupeb_psortsymmetry2; // -@223
//uniform bool fkochcubedupeb_foldzbefore; // -@223
//uniform bool fkochcubedupeb_abs_x; // -@223
//uniform bool fkochcubedupeb_abs_y; // -@223
//uniform bool fkochcubedupeb_abs_z; // -@223
//uniform int fkochcubedupeb_fold1; // -@223
//uniform int fkochcubedupeb_fold2; // -@223
//uniform bool fkochcubedupeb_fold3; // -@223
//uniform bool fkochcubedupeb_fold4; // -@223
//uniform bool fkochcubedupeb_reflection; // -@223
//uniform vec3 fkochcubedupeb_rotation1; // -@223
//uniform vec3 fkochcubedupeb_rotation2; // -@223
//uniform float fkochcubedupec_scale; // -@224
//uniform int fkochcubedupec_variant; // -@224
//uniform bool fkochcubedupec_first_zrev; // -@224
//uniform bool fkochcubedupec_pxyzminuss; // -@224
//uniform bool fkochcubedupec_psortsymmetry1; // -@224
//uniform bool fkochcubedupec_psortsymmetry2; // -@224
//uniform bool fkochcubedupec_foldzbefore; // -@224
//uniform bool fkochcubedupec_abs_x; // -@224
//uniform bool fkochcubedupec_abs_y; // -@224
//uniform bool fkochcubedupec_abs_z; // -@224
//uniform int fkochcubedupec_fold1; // -@224
//uniform int fkochcubedupec_fold2; // -@224
//uniform bool fkochcubedupec_fold3; // -@224
//uniform bool fkochcubedupec_fold4; // -@224
//uniform bool fkochcubedupec_reflection; // -@224
//uniform vec3 fkochcubedupec_rotation1; // -@224
//uniform vec3 fkochcubedupec_rotation2; // -@224
//uniform float fkochcubeduped_scale; // -@225
//uniform int fkochcubeduped_variant; // -@225
//uniform bool fkochcubeduped_first_zrev; // -@225
//uniform bool fkochcubeduped_pxyzminuss; // -@225
//uniform bool fkochcubeduped_psortsymmetry1; // -@225
//uniform bool fkochcubeduped_psortsymmetry2; // -@225
//uniform bool fkochcubeduped_foldzbefore; // -@225
//uniform bool fkochcubeduped_abs_x; // -@225
//uniform bool fkochcubeduped_abs_y; // -@225
//uniform bool fkochcubeduped_abs_z; // -@225
//uniform int fkochcubeduped_fold1; // -@225
//uniform int fkochcubeduped_fold2; // -@225
//uniform bool fkochcubeduped_fold3; // -@225
//uniform bool fkochcubeduped_fold4; // -@225
//uniform bool fkochcubeduped_reflection; // -@225
//uniform vec3 fkochcubeduped_rotation1; // -@225
//uniform vec3 fkochcubeduped_rotation2; // -@225
//uniform float fkochcubedupee_scale; // -@226
//uniform int fkochcubedupee_variant; // -@226
//uniform bool fkochcubedupee_first_zrev; // -@226
//uniform bool fkochcubedupee_pxyzminuss; // -@226
//uniform bool fkochcubedupee_psortsymmetry1; // -@226
//uniform bool fkochcubedupee_psortsymmetry2; // -@226
//uniform bool fkochcubedupee_foldzbefore; // -@226
//uniform bool fkochcubedupee_abs_x; // -@226
//uniform bool fkochcubedupee_abs_y; // -@226
//uniform bool fkochcubedupee_abs_z; // -@226
//uniform int fkochcubedupee_fold1; // -@226
//uniform int fkochcubedupee_fold2; // -@226
//uniform bool fkochcubedupee_fold3; // -@226
//uniform bool fkochcubedupee_fold4; // -@226
//uniform bool fkochcubedupee_reflection; // -@226
//uniform vec3 fkochcubedupee_rotation1; // -@226
//uniform vec3 fkochcubedupee_rotation2; // -@226
//uniform float fkochcubedupef_scale; // -@227
//uniform int fkochcubedupef_variant; // -@227
//uniform bool fkochcubedupef_first_zrev; // -@227
//uniform bool fkochcubedupef_pxyzminuss; // -@227
//uniform bool fkochcubedupef_psortsymmetry1; // -@227
//uniform bool fkochcubedupef_psortsymmetry2; // -@227
//uniform bool fkochcubedupef_foldzbefore; // -@227
//uniform bool fkochcubedupef_abs_x; // -@227
//uniform bool fkochcubedupef_abs_y; // -@227
//uniform bool fkochcubedupef_abs_z; // -@227
//uniform int fkochcubedupef_fold1; // -@227
//uniform int fkochcubedupef_fold2; // -@227
//uniform bool fkochcubedupef_fold3; // -@227
//uniform bool fkochcubedupef_fold4; // -@227
//uniform bool fkochcubedupef_reflection; // -@227
//uniform vec3 fkochcubedupef_rotation1; // -@227
//uniform vec3 fkochcubedupef_rotation2; // -@227
//uniform float fkochcubedupeg_scale; // -@228
//uniform int fkochcubedupeg_variant; // -@228
//uniform bool fkochcubedupeg_first_zrev; // -@228
//uniform bool fkochcubedupeg_pxyzminuss; // -@228
//uniform bool fkochcubedupeg_psortsymmetry1; // -@228
//uniform bool fkochcubedupeg_psortsymmetry2; // -@228
//uniform bool fkochcubedupeg_foldzbefore; // -@228
//uniform bool fkochcubedupeg_abs_x; // -@228
//uniform bool fkochcubedupeg_abs_y; // -@228
//uniform bool fkochcubedupeg_abs_z; // -@228
//uniform int fkochcubedupeg_fold1; // -@228
//uniform int fkochcubedupeg_fold2; // -@228
//uniform bool fkochcubedupeg_fold3; // -@228
//uniform bool fkochcubedupeg_fold4; // -@228
//uniform bool fkochcubedupeg_reflection; // -@228
//uniform vec3 fkochcubedupeg_rotation1; // -@228
//uniform vec3 fkochcubedupeg_rotation2; // -@228
//uniform float fkochcubedupeh_scale; // -@229
//uniform int fkochcubedupeh_variant; // -@229
//uniform bool fkochcubedupeh_first_zrev; // -@229
//uniform bool fkochcubedupeh_pxyzminuss; // -@229
//uniform bool fkochcubedupeh_psortsymmetry1; // -@229
//uniform bool fkochcubedupeh_psortsymmetry2; // -@229
//uniform bool fkochcubedupeh_foldzbefore; // -@229
//uniform bool fkochcubedupeh_abs_x; // -@229
//uniform bool fkochcubedupeh_abs_y; // -@229
//uniform bool fkochcubedupeh_abs_z; // -@229
//uniform int fkochcubedupeh_fold1; // -@229
//uniform int fkochcubedupeh_fold2; // -@229
//uniform bool fkochcubedupeh_fold3; // -@229
//uniform bool fkochcubedupeh_fold4; // -@229
//uniform bool fkochcubedupeh_reflection; // -@229
//uniform vec3 fkochcubedupeh_rotation1; // -@229
//uniform vec3 fkochcubedupeh_rotation2; // -@229
//uniform float fkochcubedupei_scale; // -@230
//uniform int fkochcubedupei_variant; // -@230
//uniform bool fkochcubedupei_first_zrev; // -@230
//uniform bool fkochcubedupei_pxyzminuss; // -@230
//uniform bool fkochcubedupei_psortsymmetry1; // -@230
//uniform bool fkochcubedupei_psortsymmetry2; // -@230
//uniform bool fkochcubedupei_foldzbefore; // -@230
//uniform bool fkochcubedupei_abs_x; // -@230
//uniform bool fkochcubedupei_abs_y; // -@230
//uniform bool fkochcubedupei_abs_z; // -@230
//uniform int fkochcubedupei_fold1; // -@230
//uniform int fkochcubedupei_fold2; // -@230
//uniform bool fkochcubedupei_fold3; // -@230
//uniform bool fkochcubedupei_fold4; // -@230
//uniform bool fkochcubedupei_reflection; // -@230
//uniform vec3 fkochcubedupei_rotation1; // -@230
//uniform vec3 fkochcubedupei_rotation2; // -@230
//uniform float fkochcubedupej_scale; // -@231
//uniform int fkochcubedupej_variant; // -@231
//uniform bool fkochcubedupej_first_zrev; // -@231
//uniform bool fkochcubedupej_pxyzminuss; // -@231
//uniform bool fkochcubedupej_psortsymmetry1; // -@231
//uniform bool fkochcubedupej_psortsymmetry2; // -@231
//uniform bool fkochcubedupej_foldzbefore; // -@231
//uniform bool fkochcubedupej_abs_x; // -@231
//uniform bool fkochcubedupej_abs_y; // -@231
//uniform bool fkochcubedupej_abs_z; // -@231
//uniform int fkochcubedupej_fold1; // -@231
//uniform int fkochcubedupej_fold2; // -@231
//uniform bool fkochcubedupej_fold3; // -@231
//uniform bool fkochcubedupej_fold4; // -@231
//uniform bool fkochcubedupej_reflection; // -@231
//uniform vec3 fkochcubedupej_rotation1; // -@231
//uniform vec3 fkochcubedupej_rotation2; // -@231
//uniform bool fkochwire_fold1; // -@232
//uniform bool fkochwire_fold2; // -@232
//uniform bool fkochwire_fold3; // -@232
//uniform bool fkochwire_abs_x; // -@232
//uniform bool fkochwire_abs_y; // -@232
//uniform bool fkochwire_abs_z; // -@232
//uniform bool fkochwire_abs2_zx; // -@232
//uniform vec3 fkochwire_abs_plus; // -@232
//uniform vec3 fkochwire_abs_minus; // -@232
//uniform float fkochwire_scale; // -@232
//uniform float fkochwire_symmetry; // -@232
//uniform vec3 fkochwire_offset; // -@232
//uniform vec3 fkochwire_rotation1; // -@232
//uniform vec3 fkochwire_rotation2; // -@232
//uniform bool fkochwiredupea_fold1; // -@233
//uniform bool fkochwiredupea_fold2; // -@233
//uniform bool fkochwiredupea_fold3; // -@233
//uniform bool fkochwiredupea_abs_x; // -@233
//uniform bool fkochwiredupea_abs_y; // -@233
//uniform bool fkochwiredupea_abs_z; // -@233
//uniform bool fkochwiredupea_abs2_zx; // -@233
//uniform vec3 fkochwiredupea_abs_plus; // -@233
//uniform vec3 fkochwiredupea_abs_minus; // -@233
//uniform float fkochwiredupea_scale; // -@233
//uniform float fkochwiredupea_symmetry; // -@233
//uniform vec3 fkochwiredupea_offset; // -@233
//uniform vec3 fkochwiredupea_rotation1; // -@233
//uniform vec3 fkochwiredupea_rotation2; // -@233
//uniform bool fkochwiredupeb_fold1; // -@234
//uniform bool fkochwiredupeb_fold2; // -@234
//uniform bool fkochwiredupeb_fold3; // -@234
//uniform bool fkochwiredupeb_abs_x; // -@234
//uniform bool fkochwiredupeb_abs_y; // -@234
//uniform bool fkochwiredupeb_abs_z; // -@234
//uniform bool fkochwiredupeb_abs2_zx; // -@234
//uniform vec3 fkochwiredupeb_abs_plus; // -@234
//uniform vec3 fkochwiredupeb_abs_minus; // -@234
//uniform float fkochwiredupeb_scale; // -@234
//uniform float fkochwiredupeb_symmetry; // -@234
//uniform vec3 fkochwiredupeb_offset; // -@234
//uniform vec3 fkochwiredupeb_rotation1; // -@234
//uniform vec3 fkochwiredupeb_rotation2; // -@234
//uniform bool fkochwiredupec_fold1; // -@235
//uniform bool fkochwiredupec_fold2; // -@235
//uniform bool fkochwiredupec_fold3; // -@235
//uniform bool fkochwiredupec_abs_x; // -@235
//uniform bool fkochwiredupec_abs_y; // -@235
//uniform bool fkochwiredupec_abs_z; // -@235
//uniform bool fkochwiredupec_abs2_zx; // -@235
//uniform vec3 fkochwiredupec_abs_plus; // -@235
//uniform vec3 fkochwiredupec_abs_minus; // -@235
//uniform float fkochwiredupec_scale; // -@235
//uniform float fkochwiredupec_symmetry; // -@235
//uniform vec3 fkochwiredupec_offset; // -@235
//uniform vec3 fkochwiredupec_rotation1; // -@235
//uniform vec3 fkochwiredupec_rotation2; // -@235
//uniform bool fkochwireduped_fold1; // -@236
//uniform bool fkochwireduped_fold2; // -@236
//uniform bool fkochwireduped_fold3; // -@236
//uniform bool fkochwireduped_abs_x; // -@236
//uniform bool fkochwireduped_abs_y; // -@236
//uniform bool fkochwireduped_abs_z; // -@236
//uniform bool fkochwireduped_abs2_zx; // -@236
//uniform vec3 fkochwireduped_abs_plus; // -@236
//uniform vec3 fkochwireduped_abs_minus; // -@236
//uniform float fkochwireduped_scale; // -@236
//uniform float fkochwireduped_symmetry; // -@236
//uniform vec3 fkochwireduped_offset; // -@236
//uniform vec3 fkochwireduped_rotation1; // -@236
//uniform vec3 fkochwireduped_rotation2; // -@236
//uniform bool fkochwiredupee_fold1; // -@237
//uniform bool fkochwiredupee_fold2; // -@237
//uniform bool fkochwiredupee_fold3; // -@237
//uniform bool fkochwiredupee_abs_x; // -@237
//uniform bool fkochwiredupee_abs_y; // -@237
//uniform bool fkochwiredupee_abs_z; // -@237
//uniform bool fkochwiredupee_abs2_zx; // -@237
//uniform vec3 fkochwiredupee_abs_plus; // -@237
//uniform vec3 fkochwiredupee_abs_minus; // -@237
//uniform float fkochwiredupee_scale; // -@237
//uniform float fkochwiredupee_symmetry; // -@237
//uniform vec3 fkochwiredupee_offset; // -@237
//uniform vec3 fkochwiredupee_rotation1; // -@237
//uniform vec3 fkochwiredupee_rotation2; // -@237
//uniform bool fkochwiredupef_fold1; // -@238
//uniform bool fkochwiredupef_fold2; // -@238
//uniform bool fkochwiredupef_fold3; // -@238
//uniform bool fkochwiredupef_abs_x; // -@238
//uniform bool fkochwiredupef_abs_y; // -@238
//uniform bool fkochwiredupef_abs_z; // -@238
//uniform bool fkochwiredupef_abs2_zx; // -@238
//uniform vec3 fkochwiredupef_abs_plus; // -@238
//uniform vec3 fkochwiredupef_abs_minus; // -@238
//uniform float fkochwiredupef_scale; // -@238
//uniform float fkochwiredupef_symmetry; // -@238
//uniform vec3 fkochwiredupef_offset; // -@238
//uniform vec3 fkochwiredupef_rotation1; // -@238
//uniform vec3 fkochwiredupef_rotation2; // -@238
//uniform bool fkochwiredupeg_fold1; // -@239
//uniform bool fkochwiredupeg_fold2; // -@239
//uniform bool fkochwiredupeg_fold3; // -@239
//uniform bool fkochwiredupeg_abs_x; // -@239
//uniform bool fkochwiredupeg_abs_y; // -@239
//uniform bool fkochwiredupeg_abs_z; // -@239
//uniform bool fkochwiredupeg_abs2_zx; // -@239
//uniform vec3 fkochwiredupeg_abs_plus; // -@239
//uniform vec3 fkochwiredupeg_abs_minus; // -@239
//uniform float fkochwiredupeg_scale; // -@239
//uniform float fkochwiredupeg_symmetry; // -@239
//uniform vec3 fkochwiredupeg_offset; // -@239
//uniform vec3 fkochwiredupeg_rotation1; // -@239
//uniform vec3 fkochwiredupeg_rotation2; // -@239
//uniform bool fkochwiredupeh_fold1; // -@240
//uniform bool fkochwiredupeh_fold2; // -@240
//uniform bool fkochwiredupeh_fold3; // -@240
//uniform bool fkochwiredupeh_abs_x; // -@240
//uniform bool fkochwiredupeh_abs_y; // -@240
//uniform bool fkochwiredupeh_abs_z; // -@240
//uniform bool fkochwiredupeh_abs2_zx; // -@240
//uniform vec3 fkochwiredupeh_abs_plus; // -@240
//uniform vec3 fkochwiredupeh_abs_minus; // -@240
//uniform float fkochwiredupeh_scale; // -@240
//uniform float fkochwiredupeh_symmetry; // -@240
//uniform vec3 fkochwiredupeh_offset; // -@240
//uniform vec3 fkochwiredupeh_rotation1; // -@240
//uniform vec3 fkochwiredupeh_rotation2; // -@240
//uniform bool fkochwiredupei_fold1; // -@241
//uniform bool fkochwiredupei_fold2; // -@241
//uniform bool fkochwiredupei_fold3; // -@241
//uniform bool fkochwiredupei_abs_x; // -@241
//uniform bool fkochwiredupei_abs_y; // -@241
//uniform bool fkochwiredupei_abs_z; // -@241
//uniform bool fkochwiredupei_abs2_zx; // -@241
//uniform vec3 fkochwiredupei_abs_plus; // -@241
//uniform vec3 fkochwiredupei_abs_minus; // -@241
//uniform float fkochwiredupei_scale; // -@241
//uniform float fkochwiredupei_symmetry; // -@241
//uniform vec3 fkochwiredupei_offset; // -@241
//uniform vec3 fkochwiredupei_rotation1; // -@241
//uniform vec3 fkochwiredupei_rotation2; // -@241
//uniform bool fkochwiredupej_fold1; // -@242
//uniform bool fkochwiredupej_fold2; // -@242
//uniform bool fkochwiredupej_fold3; // -@242
//uniform bool fkochwiredupej_abs_x; // -@242
//uniform bool fkochwiredupej_abs_y; // -@242
//uniform bool fkochwiredupej_abs_z; // -@242
//uniform bool fkochwiredupej_abs2_zx; // -@242
//uniform vec3 fkochwiredupej_abs_plus; // -@242
//uniform vec3 fkochwiredupej_abs_minus; // -@242
//uniform float fkochwiredupej_scale; // -@242
//uniform float fkochwiredupej_symmetry; // -@242
//uniform vec3 fkochwiredupej_offset; // -@242
//uniform vec3 fkochwiredupej_rotation1; // -@242
//uniform vec3 fkochwiredupej_rotation2; // -@242
//uniform float flionbulb_power; // -@243
//uniform float flionbulb_phase; // -@243
//uniform vec3 flionbulb_c; // -@243
//uniform bool flionbulb_coral; // -@243
//uniform float flionbulbdupea_power; // -@244
//uniform float flionbulbdupea_phase; // -@244
//uniform vec3 flionbulbdupea_c; // -@244
//uniform bool flionbulbdupea_coral; // -@244
//uniform float flionbulbdupeb_power; // -@245
//uniform float flionbulbdupeb_phase; // -@245
//uniform vec3 flionbulbdupeb_c; // -@245
//uniform bool flionbulbdupeb_coral; // -@245
//uniform float flionbulbdupec_power; // -@246
//uniform float flionbulbdupec_phase; // -@246
//uniform vec3 flionbulbdupec_c; // -@246
//uniform bool flionbulbdupec_coral; // -@246
//uniform float flionbulbduped_power; // -@247
//uniform float flionbulbduped_phase; // -@247
//uniform vec3 flionbulbduped_c; // -@247
//uniform bool flionbulbduped_coral; // -@247
//uniform float flionbulbdupee_power; // -@248
//uniform float flionbulbdupee_phase; // -@248
//uniform vec3 flionbulbdupee_c; // -@248
//uniform bool flionbulbdupee_coral; // -@248
//uniform float flionbulbdupef_power; // -@249
//uniform float flionbulbdupef_phase; // -@249
//uniform vec3 flionbulbdupef_c; // -@249
//uniform bool flionbulbdupef_coral; // -@249
//uniform float flionbulbdupeg_power; // -@250
//uniform float flionbulbdupeg_phase; // -@250
//uniform vec3 flionbulbdupeg_c; // -@250
//uniform bool flionbulbdupeg_coral; // -@250
//uniform float flionbulbdupeh_power; // -@251
//uniform float flionbulbdupeh_phase; // -@251
//uniform vec3 flionbulbdupeh_c; // -@251
//uniform bool flionbulbdupeh_coral; // -@251
//uniform float flionbulbdupei_power; // -@252
//uniform float flionbulbdupei_phase; // -@252
//uniform vec3 flionbulbdupei_c; // -@252
//uniform bool flionbulbdupei_coral; // -@252
//uniform float flionbulbdupej_power; // -@253
//uniform float flionbulbdupej_phase; // -@253
//uniform vec3 flionbulbdupej_c; // -@253
//uniform bool flionbulbdupej_coral; // -@253
//uniform int flogtransform_axis; // -@254
//uniform float flogtransform_offset; // -@254
//uniform float flogtransform_scale; // -@254
//uniform vec2 flogtransform_range; // -@254
//uniform int flogtransformdupea_axis; // -@255
//uniform float flogtransformdupea_offset; // -@255
//uniform float flogtransformdupea_scale; // -@255
//uniform vec2 flogtransformdupea_range; // -@255
//uniform int flogtransformdupeb_axis; // -@256
//uniform float flogtransformdupeb_offset; // -@256
//uniform float flogtransformdupeb_scale; // -@256
//uniform vec2 flogtransformdupeb_range; // -@256
//uniform int flogtransformdupec_axis; // -@257
//uniform float flogtransformdupec_offset; // -@257
//uniform float flogtransformdupec_scale; // -@257
//uniform vec2 flogtransformdupec_range; // -@257
//uniform int flogtransformduped_axis; // -@258
//uniform float flogtransformduped_offset; // -@258
//uniform float flogtransformduped_scale; // -@258
//uniform vec2 flogtransformduped_range; // -@258
//uniform int flogtransformdupee_axis; // -@259
//uniform float flogtransformdupee_offset; // -@259
//uniform float flogtransformdupee_scale; // -@259
//uniform vec2 flogtransformdupee_range; // -@259
//uniform int flogtransformdupef_axis; // -@260
//uniform float flogtransformdupef_offset; // -@260
//uniform float flogtransformdupef_scale; // -@260
//uniform vec2 flogtransformdupef_range; // -@260
//uniform int flogtransformdupeg_axis; // -@261
//uniform float flogtransformdupeg_offset; // -@261
//uniform float flogtransformdupeg_scale; // -@261
//uniform vec2 flogtransformdupeg_range; // -@261
//uniform int flogtransformdupeh_axis; // -@262
//uniform float flogtransformdupeh_offset; // -@262
//uniform float flogtransformdupeh_scale; // -@262
//uniform vec2 flogtransformdupeh_range; // -@262
//uniform int flogtransformdupei_axis; // -@263
//uniform float flogtransformdupei_offset; // -@263
//uniform float flogtransformdupei_scale; // -@263
//uniform vec2 flogtransformdupei_range; // -@263
//uniform int flogtransformdupej_axis; // -@264
//uniform float flogtransformdupej_offset; // -@264
//uniform float flogtransformdupej_scale; // -@264
//uniform vec2 flogtransformdupej_range; // -@264
//uniform int fmandelbox_shape; // -@265
//uniform float fmandelbox_scale; // -@265
//uniform float fmandelbox_radius1; // -@265
//uniform float fmandelbox_fold1; // -@265
//uniform float fmandelbox_fold1_strength; // -@265
//uniform float fmandelbox_radius2; // -@265
//uniform vec3 fmandelbox_box_folds; // -@265
//uniform bool fmandelbox_is_julia; // -@265
//uniform vec3 fmandelbox_julia_c; // -@265
//uniform vec3 fmandelbox_rotation1; // -@265
//uniform vec3 fmandelbox_rotation2; // -@265
//uniform int fmandelboxdupea_shape; // -@266
//uniform float fmandelboxdupea_scale; // -@266
//uniform float fmandelboxdupea_radius1; // -@266
//uniform float fmandelboxdupea_fold1; // -@266
//uniform float fmandelboxdupea_fold1_strength; // -@266
//uniform float fmandelboxdupea_radius2; // -@266
//uniform vec3 fmandelboxdupea_box_folds; // -@266
//uniform bool fmandelboxdupea_is_julia; // -@266
//uniform vec3 fmandelboxdupea_julia_c; // -@266
//uniform vec3 fmandelboxdupea_rotation1; // -@266
//uniform vec3 fmandelboxdupea_rotation2; // -@266
//uniform int fmandelboxdupeb_shape; // -@267
//uniform float fmandelboxdupeb_scale; // -@267
//uniform float fmandelboxdupeb_radius1; // -@267
//uniform float fmandelboxdupeb_fold1; // -@267
//uniform float fmandelboxdupeb_fold1_strength; // -@267
//uniform float fmandelboxdupeb_radius2; // -@267
//uniform vec3 fmandelboxdupeb_box_folds; // -@267
//uniform bool fmandelboxdupeb_is_julia; // -@267
//uniform vec3 fmandelboxdupeb_julia_c; // -@267
//uniform vec3 fmandelboxdupeb_rotation1; // -@267
//uniform vec3 fmandelboxdupeb_rotation2; // -@267
//uniform int fmandelboxdupec_shape; // -@268
//uniform float fmandelboxdupec_scale; // -@268
//uniform float fmandelboxdupec_radius1; // -@268
//uniform float fmandelboxdupec_fold1; // -@268
//uniform float fmandelboxdupec_fold1_strength; // -@268
//uniform float fmandelboxdupec_radius2; // -@268
//uniform vec3 fmandelboxdupec_box_folds; // -@268
//uniform bool fmandelboxdupec_is_julia; // -@268
//uniform vec3 fmandelboxdupec_julia_c; // -@268
//uniform vec3 fmandelboxdupec_rotation1; // -@268
//uniform vec3 fmandelboxdupec_rotation2; // -@268
//uniform int fmandelboxduped_shape; // -@269
//uniform float fmandelboxduped_scale; // -@269
//uniform float fmandelboxduped_radius1; // -@269
//uniform float fmandelboxduped_fold1; // -@269
//uniform float fmandelboxduped_fold1_strength; // -@269
//uniform float fmandelboxduped_radius2; // -@269
//uniform vec3 fmandelboxduped_box_folds; // -@269
//uniform bool fmandelboxduped_is_julia; // -@269
//uniform vec3 fmandelboxduped_julia_c; // -@269
//uniform vec3 fmandelboxduped_rotation1; // -@269
//uniform vec3 fmandelboxduped_rotation2; // -@269
//uniform int fmandelboxdupee_shape; // -@270
//uniform float fmandelboxdupee_scale; // -@270
//uniform float fmandelboxdupee_radius1; // -@270
//uniform float fmandelboxdupee_fold1; // -@270
//uniform float fmandelboxdupee_fold1_strength; // -@270
//uniform float fmandelboxdupee_radius2; // -@270
//uniform vec3 fmandelboxdupee_box_folds; // -@270
//uniform bool fmandelboxdupee_is_julia; // -@270
//uniform vec3 fmandelboxdupee_julia_c; // -@270
//uniform vec3 fmandelboxdupee_rotation1; // -@270
//uniform vec3 fmandelboxdupee_rotation2; // -@270
//uniform int fmandelboxdupef_shape; // -@271
//uniform float fmandelboxdupef_scale; // -@271
//uniform float fmandelboxdupef_radius1; // -@271
//uniform float fmandelboxdupef_fold1; // -@271
//uniform float fmandelboxdupef_fold1_strength; // -@271
//uniform float fmandelboxdupef_radius2; // -@271
//uniform vec3 fmandelboxdupef_box_folds; // -@271
//uniform bool fmandelboxdupef_is_julia; // -@271
//uniform vec3 fmandelboxdupef_julia_c; // -@271
//uniform vec3 fmandelboxdupef_rotation1; // -@271
//uniform vec3 fmandelboxdupef_rotation2; // -@271
//uniform int fmandelboxdupeg_shape; // -@272
//uniform float fmandelboxdupeg_scale; // -@272
//uniform float fmandelboxdupeg_radius1; // -@272
//uniform float fmandelboxdupeg_fold1; // -@272
//uniform float fmandelboxdupeg_fold1_strength; // -@272
//uniform float fmandelboxdupeg_radius2; // -@272
//uniform vec3 fmandelboxdupeg_box_folds; // -@272
//uniform bool fmandelboxdupeg_is_julia; // -@272
//uniform vec3 fmandelboxdupeg_julia_c; // -@272
//uniform vec3 fmandelboxdupeg_rotation1; // -@272
//uniform vec3 fmandelboxdupeg_rotation2; // -@272
//uniform int fmandelboxdupeh_shape; // -@273
//uniform float fmandelboxdupeh_scale; // -@273
//uniform float fmandelboxdupeh_radius1; // -@273
//uniform float fmandelboxdupeh_fold1; // -@273
//uniform float fmandelboxdupeh_fold1_strength; // -@273
//uniform float fmandelboxdupeh_radius2; // -@273
//uniform vec3 fmandelboxdupeh_box_folds; // -@273
//uniform bool fmandelboxdupeh_is_julia; // -@273
//uniform vec3 fmandelboxdupeh_julia_c; // -@273
//uniform vec3 fmandelboxdupeh_rotation1; // -@273
//uniform vec3 fmandelboxdupeh_rotation2; // -@273
//uniform int fmandelboxdupei_shape; // -@274
//uniform float fmandelboxdupei_scale; // -@274
//uniform float fmandelboxdupei_radius1; // -@274
//uniform float fmandelboxdupei_fold1; // -@274
//uniform float fmandelboxdupei_fold1_strength; // -@274
//uniform float fmandelboxdupei_radius2; // -@274
//uniform vec3 fmandelboxdupei_box_folds; // -@274
//uniform bool fmandelboxdupei_is_julia; // -@274
//uniform vec3 fmandelboxdupei_julia_c; // -@274
//uniform vec3 fmandelboxdupei_rotation1; // -@274
//uniform vec3 fmandelboxdupei_rotation2; // -@274
//uniform int fmandelboxdupej_shape; // -@275
//uniform float fmandelboxdupej_scale; // -@275
//uniform float fmandelboxdupej_radius1; // -@275
//uniform float fmandelboxdupej_fold1; // -@275
//uniform float fmandelboxdupej_fold1_strength; // -@275
//uniform float fmandelboxdupej_radius2; // -@275
//uniform vec3 fmandelboxdupej_box_folds; // -@275
//uniform bool fmandelboxdupej_is_julia; // -@275
//uniform vec3 fmandelboxdupej_julia_c; // -@275
//uniform vec3 fmandelboxdupej_rotation1; // -@275
//uniform vec3 fmandelboxdupej_rotation2; // -@275
//uniform float fmandelbulb_phase; // -@276
//uniform float fmandelbulb_power; // -@276
//uniform float fmandelbulb_z_mul; // -@276
//uniform bool fmandelbulb_conjugate; // -@276
//uniform bool fmandelbulb_abs_x; // -@276
//uniform bool fmandelbulb_abs_y; // -@276
//uniform bool fmandelbulb_abs_z; // -@276
//uniform bool fmandelbulb_is_julia; // -@276
//uniform vec4 fmandelbulb_julia_c; // -@276
//uniform float fmandelbulb_derivative_bias; // -@276
//uniform int fmandelbulb_number_system; // -@276
//uniform int fmandelbulb_quaternion_mode; // -@276
//uniform float fmandelbulbdupea_phase; // -@277
//uniform float fmandelbulbdupea_power; // -@277
//uniform float fmandelbulbdupea_z_mul; // -@277
//uniform bool fmandelbulbdupea_conjugate; // -@277
//uniform bool fmandelbulbdupea_abs_x; // -@277
//uniform bool fmandelbulbdupea_abs_y; // -@277
//uniform bool fmandelbulbdupea_abs_z; // -@277
//uniform bool fmandelbulbdupea_is_julia; // -@277
//uniform vec4 fmandelbulbdupea_julia_c; // -@277
//uniform float fmandelbulbdupea_derivative_bias; // -@277
//uniform int fmandelbulbdupea_number_system; // -@277
//uniform int fmandelbulbdupea_quaternion_mode; // -@277
//uniform float fmandelbulbdupeb_phase; // -@278
//uniform float fmandelbulbdupeb_power; // -@278
//uniform float fmandelbulbdupeb_z_mul; // -@278
//uniform bool fmandelbulbdupeb_conjugate; // -@278
//uniform bool fmandelbulbdupeb_abs_x; // -@278
//uniform bool fmandelbulbdupeb_abs_y; // -@278
//uniform bool fmandelbulbdupeb_abs_z; // -@278
//uniform bool fmandelbulbdupeb_is_julia; // -@278
//uniform vec4 fmandelbulbdupeb_julia_c; // -@278
//uniform float fmandelbulbdupeb_derivative_bias; // -@278
//uniform int fmandelbulbdupeb_number_system; // -@278
//uniform int fmandelbulbdupeb_quaternion_mode; // -@278
//uniform float fmandelbulbdupec_phase; // -@279
//uniform float fmandelbulbdupec_power; // -@279
//uniform float fmandelbulbdupec_z_mul; // -@279
//uniform bool fmandelbulbdupec_conjugate; // -@279
//uniform bool fmandelbulbdupec_abs_x; // -@279
//uniform bool fmandelbulbdupec_abs_y; // -@279
//uniform bool fmandelbulbdupec_abs_z; // -@279
//uniform bool fmandelbulbdupec_is_julia; // -@279
//uniform vec4 fmandelbulbdupec_julia_c; // -@279
//uniform float fmandelbulbdupec_derivative_bias; // -@279
//uniform int fmandelbulbdupec_number_system; // -@279
//uniform int fmandelbulbdupec_quaternion_mode; // -@279
//uniform float fmandelbulbduped_phase; // -@280
//uniform float fmandelbulbduped_power; // -@280
//uniform float fmandelbulbduped_z_mul; // -@280
//uniform bool fmandelbulbduped_conjugate; // -@280
//uniform bool fmandelbulbduped_abs_x; // -@280
//uniform bool fmandelbulbduped_abs_y; // -@280
//uniform bool fmandelbulbduped_abs_z; // -@280
//uniform bool fmandelbulbduped_is_julia; // -@280
//uniform vec4 fmandelbulbduped_julia_c; // -@280
//uniform float fmandelbulbduped_derivative_bias; // -@280
//uniform int fmandelbulbduped_number_system; // -@280
//uniform int fmandelbulbduped_quaternion_mode; // -@280
//uniform float fmandelbulbdupee_phase; // -@281
//uniform float fmandelbulbdupee_power; // -@281
//uniform float fmandelbulbdupee_z_mul; // -@281
//uniform bool fmandelbulbdupee_conjugate; // -@281
//uniform bool fmandelbulbdupee_abs_x; // -@281
//uniform bool fmandelbulbdupee_abs_y; // -@281
//uniform bool fmandelbulbdupee_abs_z; // -@281
//uniform bool fmandelbulbdupee_is_julia; // -@281
//uniform vec4 fmandelbulbdupee_julia_c; // -@281
//uniform float fmandelbulbdupee_derivative_bias; // -@281
//uniform int fmandelbulbdupee_number_system; // -@281
//uniform int fmandelbulbdupee_quaternion_mode; // -@281
//uniform float fmandelbulbdupef_phase; // -@282
//uniform float fmandelbulbdupef_power; // -@282
//uniform float fmandelbulbdupef_z_mul; // -@282
//uniform bool fmandelbulbdupef_conjugate; // -@282
//uniform bool fmandelbulbdupef_abs_x; // -@282
//uniform bool fmandelbulbdupef_abs_y; // -@282
//uniform bool fmandelbulbdupef_abs_z; // -@282
//uniform bool fmandelbulbdupef_is_julia; // -@282
//uniform vec4 fmandelbulbdupef_julia_c; // -@282
//uniform float fmandelbulbdupef_derivative_bias; // -@282
//uniform int fmandelbulbdupef_number_system; // -@282
//uniform int fmandelbulbdupef_quaternion_mode; // -@282
//uniform float fmandelbulbdupeg_phase; // -@283
//uniform float fmandelbulbdupeg_power; // -@283
//uniform float fmandelbulbdupeg_z_mul; // -@283
//uniform bool fmandelbulbdupeg_conjugate; // -@283
//uniform bool fmandelbulbdupeg_abs_x; // -@283
//uniform bool fmandelbulbdupeg_abs_y; // -@283
//uniform bool fmandelbulbdupeg_abs_z; // -@283
//uniform bool fmandelbulbdupeg_is_julia; // -@283
//uniform vec4 fmandelbulbdupeg_julia_c; // -@283
//uniform float fmandelbulbdupeg_derivative_bias; // -@283
//uniform int fmandelbulbdupeg_number_system; // -@283
//uniform int fmandelbulbdupeg_quaternion_mode; // -@283
//uniform float fmandelbulbdupeh_phase; // -@284
//uniform float fmandelbulbdupeh_power; // -@284
//uniform float fmandelbulbdupeh_z_mul; // -@284
//uniform bool fmandelbulbdupeh_conjugate; // -@284
//uniform bool fmandelbulbdupeh_abs_x; // -@284
//uniform bool fmandelbulbdupeh_abs_y; // -@284
//uniform bool fmandelbulbdupeh_abs_z; // -@284
//uniform bool fmandelbulbdupeh_is_julia; // -@284
//uniform vec4 fmandelbulbdupeh_julia_c; // -@284
//uniform float fmandelbulbdupeh_derivative_bias; // -@284
//uniform int fmandelbulbdupeh_number_system; // -@284
//uniform int fmandelbulbdupeh_quaternion_mode; // -@284
//uniform float fmandelbulbdupei_phase; // -@285
//uniform float fmandelbulbdupei_power; // -@285
//uniform float fmandelbulbdupei_z_mul; // -@285
//uniform bool fmandelbulbdupei_conjugate; // -@285
//uniform bool fmandelbulbdupei_abs_x; // -@285
//uniform bool fmandelbulbdupei_abs_y; // -@285
//uniform bool fmandelbulbdupei_abs_z; // -@285
//uniform bool fmandelbulbdupei_is_julia; // -@285
//uniform vec4 fmandelbulbdupei_julia_c; // -@285
//uniform float fmandelbulbdupei_derivative_bias; // -@285
//uniform int fmandelbulbdupei_number_system; // -@285
//uniform int fmandelbulbdupei_quaternion_mode; // -@285
//uniform float fmandelbulbdupej_phase; // -@286
//uniform float fmandelbulbdupej_power; // -@286
//uniform float fmandelbulbdupej_z_mul; // -@286
//uniform bool fmandelbulbdupej_conjugate; // -@286
//uniform bool fmandelbulbdupej_abs_x; // -@286
//uniform bool fmandelbulbdupej_abs_y; // -@286
//uniform bool fmandelbulbdupej_abs_z; // -@286
//uniform bool fmandelbulbdupej_is_julia; // -@286
//uniform vec4 fmandelbulbdupej_julia_c; // -@286
//uniform float fmandelbulbdupej_derivative_bias; // -@286
//uniform int fmandelbulbdupej_number_system; // -@286
//uniform int fmandelbulbdupej_quaternion_mode; // -@286
//uniform bool fmandelettuce_is_julia; // -@287
//uniform vec3 fmandelettuce_julia_c; // -@287
//uniform int fmandelettuce_power; // -@287
//uniform bool fmandelettucedupea_is_julia; // -@288
//uniform vec3 fmandelettucedupea_julia_c; // -@288
//uniform int fmandelettucedupea_power; // -@288
//uniform bool fmandelettucedupeb_is_julia; // -@289
//uniform vec3 fmandelettucedupeb_julia_c; // -@289
//uniform int fmandelettucedupeb_power; // -@289
//uniform bool fmandelettucedupec_is_julia; // -@290
//uniform vec3 fmandelettucedupec_julia_c; // -@290
//uniform int fmandelettucedupec_power; // -@290
//uniform bool fmandelettuceduped_is_julia; // -@291
//uniform vec3 fmandelettuceduped_julia_c; // -@291
//uniform int fmandelettuceduped_power; // -@291
//uniform bool fmandelettucedupee_is_julia; // -@292
//uniform vec3 fmandelettucedupee_julia_c; // -@292
//uniform int fmandelettucedupee_power; // -@292
//uniform bool fmandelettucedupef_is_julia; // -@293
//uniform vec3 fmandelettucedupef_julia_c; // -@293
//uniform int fmandelettucedupef_power; // -@293
//uniform bool fmandelettucedupeg_is_julia; // -@294
//uniform vec3 fmandelettucedupeg_julia_c; // -@294
//uniform int fmandelettucedupeg_power; // -@294
//uniform bool fmandelettucedupeh_is_julia; // -@295
//uniform vec3 fmandelettucedupeh_julia_c; // -@295
//uniform int fmandelettucedupeh_power; // -@295
//uniform bool fmandelettucedupei_is_julia; // -@296
//uniform vec3 fmandelettucedupei_julia_c; // -@296
//uniform int fmandelettucedupei_power; // -@296
//uniform bool fmandelettucedupej_is_julia; // -@297
//uniform vec3 fmandelettucedupej_julia_c; // -@297
//uniform int fmandelettucedupej_power; // -@297
//uniform vec4 fmelttransform_a; // -@298
//uniform vec4 fmelttransform_b; // -@298
//uniform vec4 fmelttransform_c; // -@298
//uniform vec4 fmelttransform_d; // -@298
//uniform vec2 fmelttransform_range; // -@298
//uniform vec4 fmelttransformdupea_a; // -@299
//uniform vec4 fmelttransformdupea_b; // -@299
//uniform vec4 fmelttransformdupea_c; // -@299
//uniform vec4 fmelttransformdupea_d; // -@299
//uniform vec2 fmelttransformdupea_range; // -@299
//uniform vec4 fmelttransformdupeb_a; // -@300
//uniform vec4 fmelttransformdupeb_b; // -@300
//uniform vec4 fmelttransformdupeb_c; // -@300
//uniform vec4 fmelttransformdupeb_d; // -@300
//uniform vec2 fmelttransformdupeb_range; // -@300
//uniform vec4 fmelttransformdupec_a; // -@301
//uniform vec4 fmelttransformdupec_b; // -@301
//uniform vec4 fmelttransformdupec_c; // -@301
//uniform vec4 fmelttransformdupec_d; // -@301
//uniform vec2 fmelttransformdupec_range; // -@301
//uniform vec4 fmelttransformduped_a; // -@302
//uniform vec4 fmelttransformduped_b; // -@302
//uniform vec4 fmelttransformduped_c; // -@302
//uniform vec4 fmelttransformduped_d; // -@302
//uniform vec2 fmelttransformduped_range; // -@302
//uniform vec4 fmelttransformdupee_a; // -@303
//uniform vec4 fmelttransformdupee_b; // -@303
//uniform vec4 fmelttransformdupee_c; // -@303
//uniform vec4 fmelttransformdupee_d; // -@303
//uniform vec2 fmelttransformdupee_range; // -@303
//uniform vec4 fmelttransformdupef_a; // -@304
//uniform vec4 fmelttransformdupef_b; // -@304
//uniform vec4 fmelttransformdupef_c; // -@304
//uniform vec4 fmelttransformdupef_d; // -@304
//uniform vec2 fmelttransformdupef_range; // -@304
//uniform vec4 fmelttransformdupeg_a; // -@305
//uniform vec4 fmelttransformdupeg_b; // -@305
//uniform vec4 fmelttransformdupeg_c; // -@305
//uniform vec4 fmelttransformdupeg_d; // -@305
//uniform vec2 fmelttransformdupeg_range; // -@305
//uniform vec4 fmelttransformdupeh_a; // -@306
//uniform vec4 fmelttransformdupeh_b; // -@306
//uniform vec4 fmelttransformdupeh_c; // -@306
//uniform vec4 fmelttransformdupeh_d; // -@306
//uniform vec2 fmelttransformdupeh_range; // -@306
//uniform vec4 fmelttransformdupei_a; // -@307
//uniform vec4 fmelttransformdupei_b; // -@307
//uniform vec4 fmelttransformdupei_c; // -@307
//uniform vec4 fmelttransformdupei_d; // -@307
//uniform vec2 fmelttransformdupei_range; // -@307
//uniform vec4 fmelttransformdupej_a; // -@308
//uniform vec4 fmelttransformdupej_b; // -@308
//uniform vec4 fmelttransformdupej_c; // -@308
//uniform vec4 fmelttransformdupej_d; // -@308
//uniform vec2 fmelttransformdupej_range; // -@308
//uniform vec3 fmengersponge_offset; // -@309
//uniform vec3 fmengersponge_rotation1; // -@309
//uniform vec3 fmengersponge_rotation2; // -@309
//uniform float fmengersponge_scale; // -@309
//uniform vec3 fmengerspongedupea_offset; // -@310
//uniform vec3 fmengerspongedupea_rotation1; // -@310
//uniform vec3 fmengerspongedupea_rotation2; // -@310
//uniform float fmengerspongedupea_scale; // -@310
//uniform vec3 fmengerspongedupeb_offset; // -@311
//uniform vec3 fmengerspongedupeb_rotation1; // -@311
//uniform vec3 fmengerspongedupeb_rotation2; // -@311
//uniform float fmengerspongedupeb_scale; // -@311
//uniform vec3 fmengerspongedupec_offset; // -@312
//uniform vec3 fmengerspongedupec_rotation1; // -@312
//uniform vec3 fmengerspongedupec_rotation2; // -@312
//uniform float fmengerspongedupec_scale; // -@312
//uniform vec3 fmengerspongeduped_offset; // -@313
//uniform vec3 fmengerspongeduped_rotation1; // -@313
//uniform vec3 fmengerspongeduped_rotation2; // -@313
//uniform float fmengerspongeduped_scale; // -@313
//uniform vec3 fmengerspongedupee_offset; // -@314
//uniform vec3 fmengerspongedupee_rotation1; // -@314
//uniform vec3 fmengerspongedupee_rotation2; // -@314
//uniform float fmengerspongedupee_scale; // -@314
//uniform vec3 fmengerspongedupef_offset; // -@315
//uniform vec3 fmengerspongedupef_rotation1; // -@315
//uniform vec3 fmengerspongedupef_rotation2; // -@315
//uniform float fmengerspongedupef_scale; // -@315
//uniform vec3 fmengerspongedupeg_offset; // -@316
//uniform vec3 fmengerspongedupeg_rotation1; // -@316
//uniform vec3 fmengerspongedupeg_rotation2; // -@316
//uniform float fmengerspongedupeg_scale; // -@316
//uniform vec3 fmengerspongedupeh_offset; // -@317
//uniform vec3 fmengerspongedupeh_rotation1; // -@317
//uniform vec3 fmengerspongedupeh_rotation2; // -@317
//uniform float fmengerspongedupeh_scale; // -@317
//uniform vec3 fmengerspongedupei_offset; // -@318
//uniform vec3 fmengerspongedupei_rotation1; // -@318
//uniform vec3 fmengerspongedupei_rotation2; // -@318
//uniform float fmengerspongedupei_scale; // -@318
//uniform vec3 fmengerspongedupej_offset; // -@319
//uniform vec3 fmengerspongedupej_rotation1; // -@319
//uniform vec3 fmengerspongedupej_rotation2; // -@319
//uniform float fmengerspongedupej_scale; // -@319
//uniform float fmixpinski4d_scale; // -@320
//uniform float fmixpinski4d_fold1_strength; // -@320
//uniform vec4 fmixpinski4d_offset; // -@320
//uniform vec4 fmixpinski4d_rotation1; // -@320
//uniform vec4 fmixpinski4d_rotation2; // -@320
//uniform float fmixpinski4d_abs_minus; // -@320
//uniform vec4 fmixpinski4d_fold1; // -@320
//uniform vec4 fmixpinski4d_pre_offset; // -@320
//uniform float fmixpinski4ddupea_scale; // -@321
//uniform float fmixpinski4ddupea_fold1_strength; // -@321
//uniform vec4 fmixpinski4ddupea_offset; // -@321
//uniform vec4 fmixpinski4ddupea_rotation1; // -@321
//uniform vec4 fmixpinski4ddupea_rotation2; // -@321
//uniform float fmixpinski4ddupea_abs_minus; // -@321
//uniform vec4 fmixpinski4ddupea_fold1; // -@321
//uniform vec4 fmixpinski4ddupea_pre_offset; // -@321
//uniform float fmixpinski4ddupeb_scale; // -@322
//uniform float fmixpinski4ddupeb_fold1_strength; // -@322
//uniform vec4 fmixpinski4ddupeb_offset; // -@322
//uniform vec4 fmixpinski4ddupeb_rotation1; // -@322
//uniform vec4 fmixpinski4ddupeb_rotation2; // -@322
//uniform float fmixpinski4ddupeb_abs_minus; // -@322
//uniform vec4 fmixpinski4ddupeb_fold1; // -@322
//uniform vec4 fmixpinski4ddupeb_pre_offset; // -@322
//uniform float fmixpinski4ddupec_scale; // -@323
//uniform float fmixpinski4ddupec_fold1_strength; // -@323
//uniform vec4 fmixpinski4ddupec_offset; // -@323
//uniform vec4 fmixpinski4ddupec_rotation1; // -@323
//uniform vec4 fmixpinski4ddupec_rotation2; // -@323
//uniform float fmixpinski4ddupec_abs_minus; // -@323
//uniform vec4 fmixpinski4ddupec_fold1; // -@323
//uniform vec4 fmixpinski4ddupec_pre_offset; // -@323
//uniform float fmixpinski4dduped_scale; // -@324
//uniform float fmixpinski4dduped_fold1_strength; // -@324
//uniform vec4 fmixpinski4dduped_offset; // -@324
//uniform vec4 fmixpinski4dduped_rotation1; // -@324
//uniform vec4 fmixpinski4dduped_rotation2; // -@324
//uniform float fmixpinski4dduped_abs_minus; // -@324
//uniform vec4 fmixpinski4dduped_fold1; // -@324
//uniform vec4 fmixpinski4dduped_pre_offset; // -@324
//uniform float fmixpinski4ddupee_scale; // -@325
//uniform float fmixpinski4ddupee_fold1_strength; // -@325
//uniform vec4 fmixpinski4ddupee_offset; // -@325
//uniform vec4 fmixpinski4ddupee_rotation1; // -@325
//uniform vec4 fmixpinski4ddupee_rotation2; // -@325
//uniform float fmixpinski4ddupee_abs_minus; // -@325
//uniform vec4 fmixpinski4ddupee_fold1; // -@325
//uniform vec4 fmixpinski4ddupee_pre_offset; // -@325
//uniform float fmixpinski4ddupef_scale; // -@326
//uniform float fmixpinski4ddupef_fold1_strength; // -@326
//uniform vec4 fmixpinski4ddupef_offset; // -@326
//uniform vec4 fmixpinski4ddupef_rotation1; // -@326
//uniform vec4 fmixpinski4ddupef_rotation2; // -@326
//uniform float fmixpinski4ddupef_abs_minus; // -@326
//uniform vec4 fmixpinski4ddupef_fold1; // -@326
//uniform vec4 fmixpinski4ddupef_pre_offset; // -@326
//uniform float fmixpinski4ddupeg_scale; // -@327
//uniform float fmixpinski4ddupeg_fold1_strength; // -@327
//uniform vec4 fmixpinski4ddupeg_offset; // -@327
//uniform vec4 fmixpinski4ddupeg_rotation1; // -@327
//uniform vec4 fmixpinski4ddupeg_rotation2; // -@327
//uniform float fmixpinski4ddupeg_abs_minus; // -@327
//uniform vec4 fmixpinski4ddupeg_fold1; // -@327
//uniform vec4 fmixpinski4ddupeg_pre_offset; // -@327
//uniform float fmixpinski4ddupeh_scale; // -@328
//uniform float fmixpinski4ddupeh_fold1_strength; // -@328
//uniform vec4 fmixpinski4ddupeh_offset; // -@328
//uniform vec4 fmixpinski4ddupeh_rotation1; // -@328
//uniform vec4 fmixpinski4ddupeh_rotation2; // -@328
//uniform float fmixpinski4ddupeh_abs_minus; // -@328
//uniform vec4 fmixpinski4ddupeh_fold1; // -@328
//uniform vec4 fmixpinski4ddupeh_pre_offset; // -@328
//uniform float fmixpinski4ddupei_scale; // -@329
//uniform float fmixpinski4ddupei_fold1_strength; // -@329
//uniform vec4 fmixpinski4ddupei_offset; // -@329
//uniform vec4 fmixpinski4ddupei_rotation1; // -@329
//uniform vec4 fmixpinski4ddupei_rotation2; // -@329
//uniform float fmixpinski4ddupei_abs_minus; // -@329
//uniform vec4 fmixpinski4ddupei_fold1; // -@329
//uniform vec4 fmixpinski4ddupei_pre_offset; // -@329
//uniform float fmixpinski4ddupej_scale; // -@330
//uniform float fmixpinski4ddupej_fold1_strength; // -@330
//uniform vec4 fmixpinski4ddupej_offset; // -@330
//uniform vec4 fmixpinski4ddupej_rotation1; // -@330
//uniform vec4 fmixpinski4ddupej_rotation2; // -@330
//uniform float fmixpinski4ddupej_abs_minus; // -@330
//uniform vec4 fmixpinski4ddupej_fold1; // -@330
//uniform vec4 fmixpinski4ddupej_pre_offset; // -@330
//uniform int fnewton_plane; // -@331
//uniform bool fnewton_intersection_mode; // -@331
//uniform int fnewtondupea_plane; // -@332
//uniform bool fnewtondupea_intersection_mode; // -@332
//uniform int fnewtondupeb_plane; // -@333
//uniform bool fnewtondupeb_intersection_mode; // -@333
//uniform int fnewtondupec_plane; // -@334
//uniform bool fnewtondupec_intersection_mode; // -@334
//uniform int fnewtonduped_plane; // -@335
//uniform bool fnewtonduped_intersection_mode; // -@335
//uniform int fnewtondupee_plane; // -@336
//uniform bool fnewtondupee_intersection_mode; // -@336
//uniform int fnewtondupef_plane; // -@337
//uniform bool fnewtondupef_intersection_mode; // -@337
//uniform int fnewtondupeg_plane; // -@338
//uniform bool fnewtondupeg_intersection_mode; // -@338
//uniform int fnewtondupeh_plane; // -@339
//uniform bool fnewtondupeh_intersection_mode; // -@339
//uniform int fnewtondupei_plane; // -@340
//uniform bool fnewtondupei_intersection_mode; // -@340
//uniform int fnewtondupej_plane; // -@341
//uniform bool fnewtondupej_intersection_mode; // -@341
//uniform vec3 foctahedron_position; // -@342
//uniform float foctahedron_size; // -@342
//uniform vec3 foctahedrondupea_position; // -@343
//uniform float foctahedrondupea_size; // -@343
//uniform vec3 foctahedrondupeb_position; // -@344
//uniform float foctahedrondupeb_size; // -@344
//uniform vec3 foctahedrondupec_position; // -@345
//uniform float foctahedrondupec_size; // -@345
//uniform vec3 foctahedronduped_position; // -@346
//uniform float foctahedronduped_size; // -@346
//uniform vec3 foctahedrondupee_position; // -@347
//uniform float foctahedrondupee_size; // -@347
//uniform vec3 foctahedrondupef_position; // -@348
//uniform float foctahedrondupef_size; // -@348
//uniform vec3 foctahedrondupeg_position; // -@349
//uniform float foctahedrondupeg_size; // -@349
//uniform vec3 foctahedrondupeh_position; // -@350
//uniform float foctahedrondupeh_size; // -@350
//uniform vec3 foctahedrondupei_position; // -@351
//uniform float foctahedrondupei_size; // -@351
//uniform vec3 foctahedrondupej_position; // -@352
//uniform float foctahedrondupej_size; // -@352
//uniform float foctkoch_scale; // -@353
//uniform vec3 foctkoch_offset; // -@353
//uniform vec3 foctkoch_fold; // -@353
//uniform bool foctkoch_abs; // -@353
//uniform vec3 foctkoch_rotation1; // -@353
//uniform vec3 foctkoch_rotation2; // -@353
//uniform float foctkochdupea_scale; // -@354
//uniform vec3 foctkochdupea_offset; // -@354
//uniform vec3 foctkochdupea_fold; // -@354
//uniform bool foctkochdupea_abs; // -@354
//uniform vec3 foctkochdupea_rotation1; // -@354
//uniform vec3 foctkochdupea_rotation2; // -@354
//uniform float foctkochdupeb_scale; // -@355
//uniform vec3 foctkochdupeb_offset; // -@355
//uniform vec3 foctkochdupeb_fold; // -@355
//uniform bool foctkochdupeb_abs; // -@355
//uniform vec3 foctkochdupeb_rotation1; // -@355
//uniform vec3 foctkochdupeb_rotation2; // -@355
//uniform float foctkochdupec_scale; // -@356
//uniform vec3 foctkochdupec_offset; // -@356
//uniform vec3 foctkochdupec_fold; // -@356
//uniform bool foctkochdupec_abs; // -@356
//uniform vec3 foctkochdupec_rotation1; // -@356
//uniform vec3 foctkochdupec_rotation2; // -@356
//uniform float foctkochduped_scale; // -@357
//uniform vec3 foctkochduped_offset; // -@357
//uniform vec3 foctkochduped_fold; // -@357
//uniform bool foctkochduped_abs; // -@357
//uniform vec3 foctkochduped_rotation1; // -@357
//uniform vec3 foctkochduped_rotation2; // -@357
//uniform float foctkochdupee_scale; // -@358
//uniform vec3 foctkochdupee_offset; // -@358
//uniform vec3 foctkochdupee_fold; // -@358
//uniform bool foctkochdupee_abs; // -@358
//uniform vec3 foctkochdupee_rotation1; // -@358
//uniform vec3 foctkochdupee_rotation2; // -@358
//uniform float foctkochdupef_scale; // -@359
//uniform vec3 foctkochdupef_offset; // -@359
//uniform vec3 foctkochdupef_fold; // -@359
//uniform bool foctkochdupef_abs; // -@359
//uniform vec3 foctkochdupef_rotation1; // -@359
//uniform vec3 foctkochdupef_rotation2; // -@359
//uniform float foctkochdupeg_scale; // -@360
//uniform vec3 foctkochdupeg_offset; // -@360
//uniform vec3 foctkochdupeg_fold; // -@360
//uniform bool foctkochdupeg_abs; // -@360
//uniform vec3 foctkochdupeg_rotation1; // -@360
//uniform vec3 foctkochdupeg_rotation2; // -@360
//uniform float foctkochdupeh_scale; // -@361
//uniform vec3 foctkochdupeh_offset; // -@361
//uniform vec3 foctkochdupeh_fold; // -@361
//uniform bool foctkochdupeh_abs; // -@361
//uniform vec3 foctkochdupeh_rotation1; // -@361
//uniform vec3 foctkochdupeh_rotation2; // -@361
//uniform float foctkochdupei_scale; // -@362
//uniform vec3 foctkochdupei_offset; // -@362
//uniform vec3 foctkochdupei_fold; // -@362
//uniform bool foctkochdupei_abs; // -@362
//uniform vec3 foctkochdupei_rotation1; // -@362
//uniform vec3 foctkochdupei_rotation2; // -@362
//uniform float foctkochdupej_scale; // -@363
//uniform vec3 foctkochdupej_offset; // -@363
//uniform vec3 foctkochdupej_fold; // -@363
//uniform bool foctkochdupej_abs; // -@363
//uniform vec3 foctkochdupej_rotation1; // -@363
//uniform vec3 foctkochdupej_rotation2; // -@363
//uniform vec3 fplane_position; // -@364
//uniform vec3 fplane_direction; // -@364
//uniform bool fplane_thin; // -@364
//uniform float fplane_thickness; // -@364
//uniform vec3 fplanedupea_position; // -@365
//uniform vec3 fplanedupea_direction; // -@365
//uniform bool fplanedupea_thin; // -@365
//uniform float fplanedupea_thickness; // -@365
//uniform vec3 fplanedupeb_position; // -@366
//uniform vec3 fplanedupeb_direction; // -@366
//uniform bool fplanedupeb_thin; // -@366
//uniform float fplanedupeb_thickness; // -@366
//uniform vec3 fplanedupec_position; // -@367
//uniform vec3 fplanedupec_direction; // -@367
//uniform bool fplanedupec_thin; // -@367
//uniform float fplanedupec_thickness; // -@367
//uniform vec3 fplaneduped_position; // -@368
//uniform vec3 fplaneduped_direction; // -@368
//uniform bool fplaneduped_thin; // -@368
//uniform float fplaneduped_thickness; // -@368
//uniform vec3 fplanedupee_position; // -@369
//uniform vec3 fplanedupee_direction; // -@369
//uniform bool fplanedupee_thin; // -@369
//uniform float fplanedupee_thickness; // -@369
//uniform vec3 fplanedupef_position; // -@370
//uniform vec3 fplanedupef_direction; // -@370
//uniform bool fplanedupef_thin; // -@370
//uniform float fplanedupef_thickness; // -@370
//uniform vec3 fplanedupeg_position; // -@371
//uniform vec3 fplanedupeg_direction; // -@371
//uniform bool fplanedupeg_thin; // -@371
//uniform float fplanedupeg_thickness; // -@371
//uniform vec3 fplanedupeh_position; // -@372
//uniform vec3 fplanedupeh_direction; // -@372
//uniform bool fplanedupeh_thin; // -@372
//uniform float fplanedupeh_thickness; // -@372
//uniform vec3 fplanedupei_position; // -@373
//uniform vec3 fplanedupei_direction; // -@373
//uniform bool fplanedupei_thin; // -@373
//uniform float fplanedupei_thickness; // -@373
//uniform vec3 fplanedupej_position; // -@374
//uniform vec3 fplanedupej_direction; // -@374
//uniform bool fplanedupej_thin; // -@374
//uniform float fplanedupej_thickness; // -@374
//uniform float fplatonickoch_stretch; // -@375
//uniform float fplatonickoch_postscale; // -@375
//uniform float fplatonickoch_zfix; // -@375
//uniform vec3 fplatonickoch_add; // -@375
//uniform float fplatonickochdupea_stretch; // -@376
//uniform float fplatonickochdupea_postscale; // -@376
//uniform float fplatonickochdupea_zfix; // -@376
//uniform vec3 fplatonickochdupea_add; // -@376
//uniform float fplatonickochdupeb_stretch; // -@377
//uniform float fplatonickochdupeb_postscale; // -@377
//uniform float fplatonickochdupeb_zfix; // -@377
//uniform vec3 fplatonickochdupeb_add; // -@377
//uniform float fplatonickochdupec_stretch; // -@378
//uniform float fplatonickochdupec_postscale; // -@378
//uniform float fplatonickochdupec_zfix; // -@378
//uniform vec3 fplatonickochdupec_add; // -@378
//uniform float fplatonickochduped_stretch; // -@379
//uniform float fplatonickochduped_postscale; // -@379
//uniform float fplatonickochduped_zfix; // -@379
//uniform vec3 fplatonickochduped_add; // -@379
//uniform float fplatonickochdupee_stretch; // -@380
//uniform float fplatonickochdupee_postscale; // -@380
//uniform float fplatonickochdupee_zfix; // -@380
//uniform vec3 fplatonickochdupee_add; // -@380
//uniform float fplatonickochdupef_stretch; // -@381
//uniform float fplatonickochdupef_postscale; // -@381
//uniform float fplatonickochdupef_zfix; // -@381
//uniform vec3 fplatonickochdupef_add; // -@381
//uniform float fplatonickochdupeg_stretch; // -@382
//uniform float fplatonickochdupeg_postscale; // -@382
//uniform float fplatonickochdupeg_zfix; // -@382
//uniform vec3 fplatonickochdupeg_add; // -@382
//uniform float fplatonickochdupeh_stretch; // -@383
//uniform float fplatonickochdupeh_postscale; // -@383
//uniform float fplatonickochdupeh_zfix; // -@383
//uniform vec3 fplatonickochdupeh_add; // -@383
//uniform float fplatonickochdupei_stretch; // -@384
//uniform float fplatonickochdupei_postscale; // -@384
//uniform float fplatonickochdupei_zfix; // -@384
//uniform vec3 fplatonickochdupei_add; // -@384
//uniform float fplatonickochdupej_stretch; // -@385
//uniform float fplatonickochdupej_postscale; // -@385
//uniform float fplatonickochdupej_zfix; // -@385
//uniform vec3 fplatonickochdupej_add; // -@385
//uniform vec4 fpseudoklenian_min; // -@386
//uniform vec4 fpseudoklenian_max; // -@386
//uniform float fpseudoklenian_sign; // -@386
//uniform float fpseudoklenian_scale; // -@386
//uniform vec4 fpseudokleniandupea_min; // -@387
//uniform vec4 fpseudokleniandupea_max; // -@387
//uniform float fpseudokleniandupea_sign; // -@387
//uniform float fpseudokleniandupea_scale; // -@387
//uniform vec4 fpseudokleniandupeb_min; // -@388
//uniform vec4 fpseudokleniandupeb_max; // -@388
//uniform float fpseudokleniandupeb_sign; // -@388
//uniform float fpseudokleniandupeb_scale; // -@388
//uniform vec4 fpseudokleniandupec_min; // -@389
//uniform vec4 fpseudokleniandupec_max; // -@389
//uniform float fpseudokleniandupec_sign; // -@389
//uniform float fpseudokleniandupec_scale; // -@389
//uniform vec4 fpseudoklenianduped_min; // -@390
//uniform vec4 fpseudoklenianduped_max; // -@390
//uniform float fpseudoklenianduped_sign; // -@390
//uniform float fpseudoklenianduped_scale; // -@390
//uniform vec4 fpseudokleniandupee_min; // -@391
//uniform vec4 fpseudokleniandupee_max; // -@391
//uniform float fpseudokleniandupee_sign; // -@391
//uniform float fpseudokleniandupee_scale; // -@391
//uniform vec4 fpseudokleniandupef_min; // -@392
//uniform vec4 fpseudokleniandupef_max; // -@392
//uniform float fpseudokleniandupef_sign; // -@392
//uniform float fpseudokleniandupef_scale; // -@392
//uniform vec4 fpseudokleniandupeg_min; // -@393
//uniform vec4 fpseudokleniandupeg_max; // -@393
//uniform float fpseudokleniandupeg_sign; // -@393
//uniform float fpseudokleniandupeg_scale; // -@393
//uniform vec4 fpseudokleniandupeh_min; // -@394
//uniform vec4 fpseudokleniandupeh_max; // -@394
//uniform float fpseudokleniandupeh_sign; // -@394
//uniform float fpseudokleniandupeh_scale; // -@394
//uniform vec4 fpseudokleniandupei_min; // -@395
//uniform vec4 fpseudokleniandupei_max; // -@395
//uniform float fpseudokleniandupei_sign; // -@395
//uniform float fpseudokleniandupei_scale; // -@395
//uniform vec4 fpseudokleniandupej_min; // -@396
//uniform vec4 fpseudokleniandupej_max; // -@396
//uniform float fpseudokleniandupej_sign; // -@396
//uniform float fpseudokleniandupej_scale; // -@396
//uniform vec2 fquadratickoch_octahedron_limit; // -@397
//uniform vec3 fquadratickoch_octahedron_offset; // -@397
//uniform vec3 fquadratickoch_octahedron_offset2; // -@397
//uniform vec3 fquadratickoch_octahedron_; // -@397
//uniform vec3 fquadratickoch_offset; // -@397
//uniform vec2 fquadratickoch_scale; // -@397
//uniform vec3 fquadratickoch_rotation1; // -@397
//uniform vec3 fquadratickoch_rotation2; // -@397
//uniform float fquadratickoch_abs_offset; // -@397
//uniform vec2 fquadratickochdupea_octahedron_limit; // -@398
//uniform vec3 fquadratickochdupea_octahedron_offset; // -@398
//uniform vec3 fquadratickochdupea_octahedron_offset2; // -@398
//uniform vec3 fquadratickochdupea_octahedron_; // -@398
//uniform vec3 fquadratickochdupea_offset; // -@398
//uniform vec2 fquadratickochdupea_scale; // -@398
//uniform vec3 fquadratickochdupea_rotation1; // -@398
//uniform vec3 fquadratickochdupea_rotation2; // -@398
//uniform float fquadratickochdupea_abs_offset; // -@398
//uniform vec2 fquadratickochdupeb_octahedron_limit; // -@399
//uniform vec3 fquadratickochdupeb_octahedron_offset; // -@399
//uniform vec3 fquadratickochdupeb_octahedron_offset2; // -@399
//uniform vec3 fquadratickochdupeb_octahedron_; // -@399
//uniform vec3 fquadratickochdupeb_offset; // -@399
//uniform vec2 fquadratickochdupeb_scale; // -@399
//uniform vec3 fquadratickochdupeb_rotation1; // -@399
//uniform vec3 fquadratickochdupeb_rotation2; // -@399
//uniform float fquadratickochdupeb_abs_offset; // -@399
//uniform vec2 fquadratickochdupec_octahedron_limit; // -@400
//uniform vec3 fquadratickochdupec_octahedron_offset; // -@400
//uniform vec3 fquadratickochdupec_octahedron_offset2; // -@400
//uniform vec3 fquadratickochdupec_octahedron_; // -@400
//uniform vec3 fquadratickochdupec_offset; // -@400
//uniform vec2 fquadratickochdupec_scale; // -@400
//uniform vec3 fquadratickochdupec_rotation1; // -@400
//uniform vec3 fquadratickochdupec_rotation2; // -@400
//uniform float fquadratickochdupec_abs_offset; // -@400
//uniform vec2 fquadratickochduped_octahedron_limit; // -@401
//uniform vec3 fquadratickochduped_octahedron_offset; // -@401
//uniform vec3 fquadratickochduped_octahedron_offset2; // -@401
//uniform vec3 fquadratickochduped_octahedron_; // -@401
//uniform vec3 fquadratickochduped_offset; // -@401
//uniform vec2 fquadratickochduped_scale; // -@401
//uniform vec3 fquadratickochduped_rotation1; // -@401
//uniform vec3 fquadratickochduped_rotation2; // -@401
//uniform float fquadratickochduped_abs_offset; // -@401
//uniform vec2 fquadratickochdupee_octahedron_limit; // -@402
//uniform vec3 fquadratickochdupee_octahedron_offset; // -@402
//uniform vec3 fquadratickochdupee_octahedron_offset2; // -@402
//uniform vec3 fquadratickochdupee_octahedron_; // -@402
//uniform vec3 fquadratickochdupee_offset; // -@402
//uniform vec2 fquadratickochdupee_scale; // -@402
//uniform vec3 fquadratickochdupee_rotation1; // -@402
//uniform vec3 fquadratickochdupee_rotation2; // -@402
//uniform float fquadratickochdupee_abs_offset; // -@402
//uniform vec2 fquadratickochdupef_octahedron_limit; // -@403
//uniform vec3 fquadratickochdupef_octahedron_offset; // -@403
//uniform vec3 fquadratickochdupef_octahedron_offset2; // -@403
//uniform vec3 fquadratickochdupef_octahedron_; // -@403
//uniform vec3 fquadratickochdupef_offset; // -@403
//uniform vec2 fquadratickochdupef_scale; // -@403
//uniform vec3 fquadratickochdupef_rotation1; // -@403
//uniform vec3 fquadratickochdupef_rotation2; // -@403
//uniform float fquadratickochdupef_abs_offset; // -@403
//uniform vec2 fquadratickochdupeg_octahedron_limit; // -@404
//uniform vec3 fquadratickochdupeg_octahedron_offset; // -@404
//uniform vec3 fquadratickochdupeg_octahedron_offset2; // -@404
//uniform vec3 fquadratickochdupeg_octahedron_; // -@404
//uniform vec3 fquadratickochdupeg_offset; // -@404
//uniform vec2 fquadratickochdupeg_scale; // -@404
//uniform vec3 fquadratickochdupeg_rotation1; // -@404
//uniform vec3 fquadratickochdupeg_rotation2; // -@404
//uniform float fquadratickochdupeg_abs_offset; // -@404
//uniform vec2 fquadratickochdupeh_octahedron_limit; // -@405
//uniform vec3 fquadratickochdupeh_octahedron_offset; // -@405
//uniform vec3 fquadratickochdupeh_octahedron_offset2; // -@405
//uniform vec3 fquadratickochdupeh_octahedron_; // -@405
//uniform vec3 fquadratickochdupeh_offset; // -@405
//uniform vec2 fquadratickochdupeh_scale; // -@405
//uniform vec3 fquadratickochdupeh_rotation1; // -@405
//uniform vec3 fquadratickochdupeh_rotation2; // -@405
//uniform float fquadratickochdupeh_abs_offset; // -@405
//uniform vec2 fquadratickochdupei_octahedron_limit; // -@406
//uniform vec3 fquadratickochdupei_octahedron_offset; // -@406
//uniform vec3 fquadratickochdupei_octahedron_offset2; // -@406
//uniform vec3 fquadratickochdupei_octahedron_; // -@406
//uniform vec3 fquadratickochdupei_offset; // -@406
//uniform vec2 fquadratickochdupei_scale; // -@406
//uniform vec3 fquadratickochdupei_rotation1; // -@406
//uniform vec3 fquadratickochdupei_rotation2; // -@406
//uniform float fquadratickochdupei_abs_offset; // -@406
//uniform vec2 fquadratickochdupej_octahedron_limit; // -@407
//uniform vec3 fquadratickochdupej_octahedron_offset; // -@407
//uniform vec3 fquadratickochdupej_octahedron_offset2; // -@407
//uniform vec3 fquadratickochdupej_octahedron_; // -@407
//uniform vec3 fquadratickochdupej_offset; // -@407
//uniform vec2 fquadratickochdupej_scale; // -@407
//uniform vec3 fquadratickochdupej_rotation1; // -@407
//uniform vec3 fquadratickochdupej_rotation2; // -@407
//uniform float fquadratickochdupej_abs_offset; // -@407
//uniform int freciprocaltransform_axis; // -@408
//uniform float freciprocaltransform_offset; // -@408
//uniform vec2 freciprocaltransform_range; // -@408
//uniform int freciprocaltransformdupea_axis; // -@409
//uniform float freciprocaltransformdupea_offset; // -@409
//uniform vec2 freciprocaltransformdupea_range; // -@409
//uniform int freciprocaltransformdupeb_axis; // -@410
//uniform float freciprocaltransformdupeb_offset; // -@410
//uniform vec2 freciprocaltransformdupeb_range; // -@410
//uniform int freciprocaltransformdupec_axis; // -@411
//uniform float freciprocaltransformdupec_offset; // -@411
//uniform vec2 freciprocaltransformdupec_range; // -@411
//uniform int freciprocaltransformduped_axis; // -@412
//uniform float freciprocaltransformduped_offset; // -@412
//uniform vec2 freciprocaltransformduped_range; // -@412
//uniform int freciprocaltransformdupee_axis; // -@413
//uniform float freciprocaltransformdupee_offset; // -@413
//uniform vec2 freciprocaltransformdupee_range; // -@413
//uniform int freciprocaltransformdupef_axis; // -@414
//uniform float freciprocaltransformdupef_offset; // -@414
//uniform vec2 freciprocaltransformdupef_range; // -@414
//uniform int freciprocaltransformdupeg_axis; // -@415
//uniform float freciprocaltransformdupeg_offset; // -@415
//uniform vec2 freciprocaltransformdupeg_range; // -@415
//uniform int freciprocaltransformdupeh_axis; // -@416
//uniform float freciprocaltransformdupeh_offset; // -@416
//uniform vec2 freciprocaltransformdupeh_range; // -@416
//uniform int freciprocaltransformdupei_axis; // -@417
//uniform float freciprocaltransformdupei_offset; // -@417
//uniform vec2 freciprocaltransformdupei_range; // -@417
//uniform int freciprocaltransformdupej_axis; // -@418
//uniform float freciprocaltransformdupej_offset; // -@418
//uniform vec2 freciprocaltransformdupej_range; // -@418
//uniform vec3 fsierpinskidodecahedron_offset; // -@430
//uniform vec3 fsierpinskidodecahedron_rotation1; // -@430
//uniform vec3 fsierpinskidodecahedron_rotation2; // -@430
//uniform float fsierpinskidodecahedron_scale; // -@430
//uniform vec3 fsierpinskidodecahedrondupea_offset; // -@431
//uniform vec3 fsierpinskidodecahedrondupea_rotation1; // -@431
//uniform vec3 fsierpinskidodecahedrondupea_rotation2; // -@431
//uniform float fsierpinskidodecahedrondupea_scale; // -@431
//uniform vec3 fsierpinskidodecahedrondupeb_offset; // -@432
//uniform vec3 fsierpinskidodecahedrondupeb_rotation1; // -@432
//uniform vec3 fsierpinskidodecahedrondupeb_rotation2; // -@432
//uniform float fsierpinskidodecahedrondupeb_scale; // -@432
//uniform vec3 fsierpinskidodecahedrondupec_offset; // -@433
//uniform vec3 fsierpinskidodecahedrondupec_rotation1; // -@433
//uniform vec3 fsierpinskidodecahedrondupec_rotation2; // -@433
//uniform float fsierpinskidodecahedrondupec_scale; // -@433
//uniform vec3 fsierpinskidodecahedronduped_offset; // -@434
//uniform vec3 fsierpinskidodecahedronduped_rotation1; // -@434
//uniform vec3 fsierpinskidodecahedronduped_rotation2; // -@434
//uniform float fsierpinskidodecahedronduped_scale; // -@434
//uniform vec3 fsierpinskidodecahedrondupee_offset; // -@435
//uniform vec3 fsierpinskidodecahedrondupee_rotation1; // -@435
//uniform vec3 fsierpinskidodecahedrondupee_rotation2; // -@435
//uniform float fsierpinskidodecahedrondupee_scale; // -@435
//uniform vec3 fsierpinskidodecahedrondupef_offset; // -@436
//uniform vec3 fsierpinskidodecahedrondupef_rotation1; // -@436
//uniform vec3 fsierpinskidodecahedrondupef_rotation2; // -@436
//uniform float fsierpinskidodecahedrondupef_scale; // -@436
//uniform vec3 fsierpinskidodecahedrondupeg_offset; // -@437
//uniform vec3 fsierpinskidodecahedrondupeg_rotation1; // -@437
//uniform vec3 fsierpinskidodecahedrondupeg_rotation2; // -@437
//uniform float fsierpinskidodecahedrondupeg_scale; // -@437
//uniform vec3 fsierpinskidodecahedrondupeh_offset; // -@438
//uniform vec3 fsierpinskidodecahedrondupeh_rotation1; // -@438
//uniform vec3 fsierpinskidodecahedrondupeh_rotation2; // -@438
//uniform float fsierpinskidodecahedrondupeh_scale; // -@438
//uniform vec3 fsierpinskidodecahedrondupei_offset; // -@439
//uniform vec3 fsierpinskidodecahedrondupei_rotation1; // -@439
//uniform vec3 fsierpinskidodecahedrondupei_rotation2; // -@439
//uniform float fsierpinskidodecahedrondupei_scale; // -@439
//uniform vec3 fsierpinskidodecahedrondupej_offset; // -@440
//uniform vec3 fsierpinskidodecahedrondupej_rotation1; // -@440
//uniform vec3 fsierpinskidodecahedrondupej_rotation2; // -@440
//uniform float fsierpinskidodecahedrondupej_scale; // -@440
//uniform vec3 fsierpinskiicosahedron_offset; // -@441
//uniform vec3 fsierpinskiicosahedron_rotation1; // -@441
//uniform vec3 fsierpinskiicosahedron_rotation2; // -@441
//uniform float fsierpinskiicosahedron_scale; // -@441
//uniform vec3 fsierpinskiicosahedrondupea_offset; // -@442
//uniform vec3 fsierpinskiicosahedrondupea_rotation1; // -@442
//uniform vec3 fsierpinskiicosahedrondupea_rotation2; // -@442
//uniform float fsierpinskiicosahedrondupea_scale; // -@442
//uniform vec3 fsierpinskiicosahedrondupeb_offset; // -@443
//uniform vec3 fsierpinskiicosahedrondupeb_rotation1; // -@443
//uniform vec3 fsierpinskiicosahedrondupeb_rotation2; // -@443
//uniform float fsierpinskiicosahedrondupeb_scale; // -@443
//uniform vec3 fsierpinskiicosahedrondupec_offset; // -@444
//uniform vec3 fsierpinskiicosahedrondupec_rotation1; // -@444
//uniform vec3 fsierpinskiicosahedrondupec_rotation2; // -@444
//uniform float fsierpinskiicosahedrondupec_scale; // -@444
//uniform vec3 fsierpinskiicosahedronduped_offset; // -@445
//uniform vec3 fsierpinskiicosahedronduped_rotation1; // -@445
//uniform vec3 fsierpinskiicosahedronduped_rotation2; // -@445
//uniform float fsierpinskiicosahedronduped_scale; // -@445
//uniform vec3 fsierpinskiicosahedrondupee_offset; // -@446
//uniform vec3 fsierpinskiicosahedrondupee_rotation1; // -@446
//uniform vec3 fsierpinskiicosahedrondupee_rotation2; // -@446
//uniform float fsierpinskiicosahedrondupee_scale; // -@446
//uniform vec3 fsierpinskiicosahedrondupef_offset; // -@447
//uniform vec3 fsierpinskiicosahedrondupef_rotation1; // -@447
//uniform vec3 fsierpinskiicosahedrondupef_rotation2; // -@447
//uniform float fsierpinskiicosahedrondupef_scale; // -@447
//uniform vec3 fsierpinskiicosahedrondupeg_offset; // -@448
//uniform vec3 fsierpinskiicosahedrondupeg_rotation1; // -@448
//uniform vec3 fsierpinskiicosahedrondupeg_rotation2; // -@448
//uniform float fsierpinskiicosahedrondupeg_scale; // -@448
//uniform vec3 fsierpinskiicosahedrondupeh_offset; // -@449
//uniform vec3 fsierpinskiicosahedrondupeh_rotation1; // -@449
//uniform vec3 fsierpinskiicosahedrondupeh_rotation2; // -@449
//uniform float fsierpinskiicosahedrondupeh_scale; // -@449
//uniform vec3 fsierpinskiicosahedrondupei_offset; // -@450
//uniform vec3 fsierpinskiicosahedrondupei_rotation1; // -@450
//uniform vec3 fsierpinskiicosahedrondupei_rotation2; // -@450
//uniform float fsierpinskiicosahedrondupei_scale; // -@450
//uniform vec3 fsierpinskiicosahedrondupej_offset; // -@451
//uniform vec3 fsierpinskiicosahedrondupej_rotation1; // -@451
//uniform vec3 fsierpinskiicosahedrondupej_rotation2; // -@451
//uniform float fsierpinskiicosahedrondupej_scale; // -@451
//uniform vec3 fsierpinskioctahedron_rotation1; // -@452
//uniform vec3 fsierpinskioctahedron_rotation2; // -@452
//uniform vec3 fsierpinskioctahedron_offset; // -@452
//uniform float fsierpinskioctahedron_scale; // -@452
//uniform vec3 fsierpinskioctahedrondupea_rotation1; // -@453
//uniform vec3 fsierpinskioctahedrondupea_rotation2; // -@453
//uniform vec3 fsierpinskioctahedrondupea_offset; // -@453
//uniform float fsierpinskioctahedrondupea_scale; // -@453
//uniform vec3 fsierpinskioctahedrondupeb_rotation1; // -@454
//uniform vec3 fsierpinskioctahedrondupeb_rotation2; // -@454
//uniform vec3 fsierpinskioctahedrondupeb_offset; // -@454
//uniform float fsierpinskioctahedrondupeb_scale; // -@454
//uniform vec3 fsierpinskioctahedrondupec_rotation1; // -@455
//uniform vec3 fsierpinskioctahedrondupec_rotation2; // -@455
//uniform vec3 fsierpinskioctahedrondupec_offset; // -@455
//uniform float fsierpinskioctahedrondupec_scale; // -@455
//uniform vec3 fsierpinskioctahedronduped_rotation1; // -@456
//uniform vec3 fsierpinskioctahedronduped_rotation2; // -@456
//uniform vec3 fsierpinskioctahedronduped_offset; // -@456
//uniform float fsierpinskioctahedronduped_scale; // -@456
//uniform vec3 fsierpinskioctahedrondupee_rotation1; // -@457
//uniform vec3 fsierpinskioctahedrondupee_rotation2; // -@457
//uniform vec3 fsierpinskioctahedrondupee_offset; // -@457
//uniform float fsierpinskioctahedrondupee_scale; // -@457
//uniform vec3 fsierpinskioctahedrondupef_rotation1; // -@458
//uniform vec3 fsierpinskioctahedrondupef_rotation2; // -@458
//uniform vec3 fsierpinskioctahedrondupef_offset; // -@458
//uniform float fsierpinskioctahedrondupef_scale; // -@458
//uniform vec3 fsierpinskioctahedrondupeg_rotation1; // -@459
//uniform vec3 fsierpinskioctahedrondupeg_rotation2; // -@459
//uniform vec3 fsierpinskioctahedrondupeg_offset; // -@459
//uniform float fsierpinskioctahedrondupeg_scale; // -@459
//uniform vec3 fsierpinskioctahedrondupeh_rotation1; // -@460
//uniform vec3 fsierpinskioctahedrondupeh_rotation2; // -@460
//uniform vec3 fsierpinskioctahedrondupeh_offset; // -@460
//uniform float fsierpinskioctahedrondupeh_scale; // -@460
//uniform vec3 fsierpinskioctahedrondupei_rotation1; // -@461
//uniform vec3 fsierpinskioctahedrondupei_rotation2; // -@461
//uniform vec3 fsierpinskioctahedrondupei_offset; // -@461
//uniform float fsierpinskioctahedrondupei_scale; // -@461
//uniform vec3 fsierpinskioctahedrondupej_rotation1; // -@462
//uniform vec3 fsierpinskioctahedrondupej_rotation2; // -@462
//uniform vec3 fsierpinskioctahedrondupej_offset; // -@462
//uniform float fsierpinskioctahedrondupej_scale; // -@462
//uniform vec3 fsierpinskitetrahedron_offset; // -@463
//uniform vec3 fsierpinskitetrahedron_rotation1; // -@463
//uniform vec3 fsierpinskitetrahedron_rotation2; // -@463
//uniform float fsierpinskitetrahedron_scale; // -@463
//uniform vec3 fsierpinskitetrahedrondupea_offset; // -@464
//uniform vec3 fsierpinskitetrahedrondupea_rotation1; // -@464
//uniform vec3 fsierpinskitetrahedrondupea_rotation2; // -@464
//uniform float fsierpinskitetrahedrondupea_scale; // -@464
//uniform vec3 fsierpinskitetrahedrondupeb_offset; // -@465
//uniform vec3 fsierpinskitetrahedrondupeb_rotation1; // -@465
//uniform vec3 fsierpinskitetrahedrondupeb_rotation2; // -@465
//uniform float fsierpinskitetrahedrondupeb_scale; // -@465
//uniform vec3 fsierpinskitetrahedrondupec_offset; // -@466
//uniform vec3 fsierpinskitetrahedrondupec_rotation1; // -@466
//uniform vec3 fsierpinskitetrahedrondupec_rotation2; // -@466
//uniform float fsierpinskitetrahedrondupec_scale; // -@466
//uniform vec3 fsierpinskitetrahedronduped_offset; // -@467
//uniform vec3 fsierpinskitetrahedronduped_rotation1; // -@467
//uniform vec3 fsierpinskitetrahedronduped_rotation2; // -@467
//uniform float fsierpinskitetrahedronduped_scale; // -@467
//uniform vec3 fsierpinskitetrahedrondupee_offset; // -@468
//uniform vec3 fsierpinskitetrahedrondupee_rotation1; // -@468
//uniform vec3 fsierpinskitetrahedrondupee_rotation2; // -@468
//uniform float fsierpinskitetrahedrondupee_scale; // -@468
//uniform vec3 fsierpinskitetrahedrondupef_offset; // -@469
//uniform vec3 fsierpinskitetrahedrondupef_rotation1; // -@469
//uniform vec3 fsierpinskitetrahedrondupef_rotation2; // -@469
//uniform float fsierpinskitetrahedrondupef_scale; // -@469
//uniform vec3 fsierpinskitetrahedrondupeg_offset; // -@470
//uniform vec3 fsierpinskitetrahedrondupeg_rotation1; // -@470
//uniform vec3 fsierpinskitetrahedrondupeg_rotation2; // -@470
//uniform float fsierpinskitetrahedrondupeg_scale; // -@470
//uniform vec3 fsierpinskitetrahedrondupeh_offset; // -@471
//uniform vec3 fsierpinskitetrahedrondupeh_rotation1; // -@471
//uniform vec3 fsierpinskitetrahedrondupeh_rotation2; // -@471
//uniform float fsierpinskitetrahedrondupeh_scale; // -@471
//uniform vec3 fsierpinskitetrahedrondupei_offset; // -@472
//uniform vec3 fsierpinskitetrahedrondupei_rotation1; // -@472
//uniform vec3 fsierpinskitetrahedrondupei_rotation2; // -@472
//uniform float fsierpinskitetrahedrondupei_scale; // -@472
//uniform vec3 fsierpinskitetrahedrondupej_offset; // -@473
//uniform vec3 fsierpinskitetrahedrondupej_rotation1; // -@473
//uniform vec3 fsierpinskitetrahedrondupej_rotation2; // -@473
//uniform float fsierpinskitetrahedrondupej_scale; // -@473
//uniform int fsintransform_axis; // -@474
//uniform vec2 fsintransform_offset; // -@474
//uniform vec2 fsintransform_scale; // -@474
//uniform vec2 fsintransform_range; // -@474
//uniform int fsintransformdupea_axis; // -@475
//uniform vec2 fsintransformdupea_offset; // -@475
//uniform vec2 fsintransformdupea_scale; // -@475
//uniform vec2 fsintransformdupea_range; // -@475
//uniform int fsintransformdupeb_axis; // -@476
//uniform vec2 fsintransformdupeb_offset; // -@476
//uniform vec2 fsintransformdupeb_scale; // -@476
//uniform vec2 fsintransformdupeb_range; // -@476
//uniform int fsintransformdupec_axis; // -@477
//uniform vec2 fsintransformdupec_offset; // -@477
//uniform vec2 fsintransformdupec_scale; // -@477
//uniform vec2 fsintransformdupec_range; // -@477
//uniform int fsintransformduped_axis; // -@478
//uniform vec2 fsintransformduped_offset; // -@478
//uniform vec2 fsintransformduped_scale; // -@478
//uniform vec2 fsintransformduped_range; // -@478
//uniform int fsintransformdupee_axis; // -@479
//uniform vec2 fsintransformdupee_offset; // -@479
//uniform vec2 fsintransformdupee_scale; // -@479
//uniform vec2 fsintransformdupee_range; // -@479
//uniform int fsintransformdupef_axis; // -@480
//uniform vec2 fsintransformdupef_offset; // -@480
//uniform vec2 fsintransformdupef_scale; // -@480
//uniform vec2 fsintransformdupef_range; // -@480
//uniform int fsintransformdupeg_axis; // -@481
//uniform vec2 fsintransformdupeg_offset; // -@481
//uniform vec2 fsintransformdupeg_scale; // -@481
//uniform vec2 fsintransformdupeg_range; // -@481
//uniform int fsintransformdupeh_axis; // -@482
//uniform vec2 fsintransformdupeh_offset; // -@482
//uniform vec2 fsintransformdupeh_scale; // -@482
//uniform vec2 fsintransformdupeh_range; // -@482
//uniform int fsintransformdupei_axis; // -@483
//uniform vec2 fsintransformdupei_offset; // -@483
//uniform vec2 fsintransformdupei_scale; // -@483
//uniform vec2 fsintransformdupei_range; // -@483
//uniform int fsintransformdupej_axis; // -@484
//uniform vec2 fsintransformdupej_offset; // -@484
//uniform vec2 fsintransformdupej_scale; // -@484
//uniform vec2 fsintransformdupej_range; // -@484
//uniform int fsphairahedron_cube_type; // -@485
//uniform float fsphairahedron_zc; // -@485
//uniform float fsphairahedron_zb; // -@485
//uniform int fsphairahedrondupea_cube_type; // -@486
//uniform float fsphairahedrondupea_zc; // -@486
//uniform float fsphairahedrondupea_zb; // -@486
//uniform int fsphairahedrondupeb_cube_type; // -@487
//uniform float fsphairahedrondupeb_zc; // -@487
//uniform float fsphairahedrondupeb_zb; // -@487
//uniform int fsphairahedrondupec_cube_type; // -@488
//uniform float fsphairahedrondupec_zc; // -@488
//uniform float fsphairahedrondupec_zb; // -@488
//uniform int fsphairahedronduped_cube_type; // -@489
//uniform float fsphairahedronduped_zc; // -@489
//uniform float fsphairahedronduped_zb; // -@489
//uniform int fsphairahedrondupee_cube_type; // -@490
//uniform float fsphairahedrondupee_zc; // -@490
//uniform float fsphairahedrondupee_zb; // -@490
//uniform int fsphairahedrondupef_cube_type; // -@491
//uniform float fsphairahedrondupef_zc; // -@491
//uniform float fsphairahedrondupef_zb; // -@491
//uniform int fsphairahedrondupeg_cube_type; // -@492
//uniform float fsphairahedrondupeg_zc; // -@492
//uniform float fsphairahedrondupeg_zb; // -@492
//uniform int fsphairahedrondupeh_cube_type; // -@493
//uniform float fsphairahedrondupeh_zc; // -@493
//uniform float fsphairahedrondupeh_zb; // -@493
//uniform int fsphairahedrondupei_cube_type; // -@494
//uniform float fsphairahedrondupei_zc; // -@494
//uniform float fsphairahedrondupei_zb; // -@494
//uniform int fsphairahedrondupej_cube_type; // -@495
//uniform float fsphairahedrondupej_zc; // -@495
//uniform float fsphairahedrondupej_zb; // -@495
//uniform vec3 fsphere_position; // -@496
//uniform float fsphere_radius; // -@496
//uniform bool fsphere_hollow; // -@496
//uniform float fsphere_hollow_edge; // -@496
//uniform vec3 fspheredupea_position; // -@497
//uniform float fspheredupea_radius; // -@497
//uniform bool fspheredupea_hollow; // -@497
//uniform float fspheredupea_hollow_edge; // -@497
//uniform vec3 fspheredupeb_position; // -@498
//uniform float fspheredupeb_radius; // -@498
//uniform bool fspheredupeb_hollow; // -@498
//uniform float fspheredupeb_hollow_edge; // -@498
//uniform vec3 fspheredupec_position; // -@499
//uniform float fspheredupec_radius; // -@499
//uniform bool fspheredupec_hollow; // -@499
//uniform float fspheredupec_hollow_edge; // -@499
//uniform vec3 fsphereduped_position; // -@500
//uniform float fsphereduped_radius; // -@500
//uniform bool fsphereduped_hollow; // -@500
//uniform float fsphereduped_hollow_edge; // -@500
//uniform vec3 fspheredupee_position; // -@501
//uniform float fspheredupee_radius; // -@501
//uniform bool fspheredupee_hollow; // -@501
//uniform float fspheredupee_hollow_edge; // -@501
//uniform vec3 fspheredupef_position; // -@502
//uniform float fspheredupef_radius; // -@502
//uniform bool fspheredupef_hollow; // -@502
//uniform float fspheredupef_hollow_edge; // -@502
//uniform vec3 fspheredupeg_position; // -@503
//uniform float fspheredupeg_radius; // -@503
//uniform bool fspheredupeg_hollow; // -@503
//uniform float fspheredupeg_hollow_edge; // -@503
//uniform vec3 fspheredupeh_position; // -@504
//uniform float fspheredupeh_radius; // -@504
//uniform bool fspheredupeh_hollow; // -@504
//uniform float fspheredupeh_hollow_edge; // -@504
//uniform vec3 fspheredupei_position; // -@505
//uniform float fspheredupei_radius; // -@505
//uniform bool fspheredupei_hollow; // -@505
//uniform float fspheredupei_hollow_edge; // -@505
//uniform vec3 fspheredupej_position; // -@506
//uniform float fspheredupej_radius; // -@506
//uniform bool fspheredupej_hollow; // -@506
//uniform float fspheredupej_hollow_edge; // -@506
//uniform float fspheretree_symmetry; // -@507
//uniform float fspheretreedupea_symmetry; // -@508
//uniform float fspheretreedupeb_symmetry; // -@509
//uniform float fspheretreedupec_symmetry; // -@510
//uniform float fspheretreeduped_symmetry; // -@511
//uniform float fspheretreedupee_symmetry; // -@512
//uniform float fspheretreedupef_symmetry; // -@513
//uniform float fspheretreedupeg_symmetry; // -@514
//uniform float fspheretreedupeh_symmetry; // -@515
//uniform float fspheretreedupei_symmetry; // -@516
//uniform float fspheretreedupej_symmetry; // -@517
//uniform vec3 ftetrahedron_position; // -@518
//uniform float ftetrahedron_size; // -@518
//uniform vec3 ftetrahedrondupea_position; // -@519
//uniform float ftetrahedrondupea_size; // -@519
//uniform vec3 ftetrahedrondupeb_position; // -@520
//uniform float ftetrahedrondupeb_size; // -@520
//uniform vec3 ftetrahedrondupec_position; // -@521
//uniform float ftetrahedrondupec_size; // -@521
//uniform vec3 ftetrahedronduped_position; // -@522
//uniform float ftetrahedronduped_size; // -@522
//uniform vec3 ftetrahedrondupee_position; // -@523
//uniform float ftetrahedrondupee_size; // -@523
//uniform vec3 ftetrahedrondupef_position; // -@524
//uniform float ftetrahedrondupef_size; // -@524
//uniform vec3 ftetrahedrondupeg_position; // -@525
//uniform float ftetrahedrondupeg_size; // -@525
//uniform vec3 ftetrahedrondupeh_position; // -@526
//uniform float ftetrahedrondupeh_size; // -@526
//uniform vec3 ftetrahedrondupei_position; // -@527
//uniform float ftetrahedrondupei_size; // -@527
//uniform vec3 ftetrahedrondupej_position; // -@528
//uniform float ftetrahedrondupej_size; // -@528
//uniform float ftriescher_scale; // -@529
//uniform vec3 ftriescher_offset; // -@529
//uniform vec3 ftriescher_clamp; // -@529
//uniform vec3 ftriescher_add; // -@529
//uniform vec2 ftriescher_limit; // -@529
//uniform float ftriescher_symmetry; // -@529
//uniform float ftriescherdupea_scale; // -@530
//uniform vec3 ftriescherdupea_offset; // -@530
//uniform vec3 ftriescherdupea_clamp; // -@530
//uniform vec3 ftriescherdupea_add; // -@530
//uniform vec2 ftriescherdupea_limit; // -@530
//uniform float ftriescherdupea_symmetry; // -@530
//uniform float ftriescherdupeb_scale; // -@531
//uniform vec3 ftriescherdupeb_offset; // -@531
//uniform vec3 ftriescherdupeb_clamp; // -@531
//uniform vec3 ftriescherdupeb_add; // -@531
//uniform vec2 ftriescherdupeb_limit; // -@531
//uniform float ftriescherdupeb_symmetry; // -@531
//uniform float ftriescherdupec_scale; // -@532
//uniform vec3 ftriescherdupec_offset; // -@532
//uniform vec3 ftriescherdupec_clamp; // -@532
//uniform vec3 ftriescherdupec_add; // -@532
//uniform vec2 ftriescherdupec_limit; // -@532
//uniform float ftriescherdupec_symmetry; // -@532
//uniform float ftriescherduped_scale; // -@533
//uniform vec3 ftriescherduped_offset; // -@533
//uniform vec3 ftriescherduped_clamp; // -@533
//uniform vec3 ftriescherduped_add; // -@533
//uniform vec2 ftriescherduped_limit; // -@533
//uniform float ftriescherduped_symmetry; // -@533
//uniform float ftriescherdupee_scale; // -@534
//uniform vec3 ftriescherdupee_offset; // -@534
//uniform vec3 ftriescherdupee_clamp; // -@534
//uniform vec3 ftriescherdupee_add; // -@534
//uniform vec2 ftriescherdupee_limit; // -@534
//uniform float ftriescherdupee_symmetry; // -@534
//uniform float ftriescherdupef_scale; // -@535
//uniform vec3 ftriescherdupef_offset; // -@535
//uniform vec3 ftriescherdupef_clamp; // -@535
//uniform vec3 ftriescherdupef_add; // -@535
//uniform vec2 ftriescherdupef_limit; // -@535
//uniform float ftriescherdupef_symmetry; // -@535
//uniform float ftriescherdupeg_scale; // -@536
//uniform vec3 ftriescherdupeg_offset; // -@536
//uniform vec3 ftriescherdupeg_clamp; // -@536
//uniform vec3 ftriescherdupeg_add; // -@536
//uniform vec2 ftriescherdupeg_limit; // -@536
//uniform float ftriescherdupeg_symmetry; // -@536
//uniform float ftriescherdupeh_scale; // -@537
//uniform vec3 ftriescherdupeh_offset; // -@537
//uniform vec3 ftriescherdupeh_clamp; // -@537
//uniform vec3 ftriescherdupeh_add; // -@537
//uniform vec2 ftriescherdupeh_limit; // -@537
//uniform float ftriescherdupeh_symmetry; // -@537
//uniform float ftriescherdupei_scale; // -@538
//uniform vec3 ftriescherdupei_offset; // -@538
//uniform vec3 ftriescherdupei_clamp; // -@538
//uniform vec3 ftriescherdupei_add; // -@538
//uniform vec2 ftriescherdupei_limit; // -@538
//uniform float ftriescherdupei_symmetry; // -@538
//uniform float ftriescherdupej_scale; // -@539
//uniform vec3 ftriescherdupej_offset; // -@539
//uniform vec3 ftriescherdupej_clamp; // -@539
//uniform vec3 ftriescherdupej_add; // -@539
//uniform vec2 ftriescherdupej_limit; // -@539
//uniform float ftriescherdupej_symmetry; // -@539
//uniform bool fvicsek_preserve; // -@540
//uniform bool fvicsek_hex_fold1; // -@540
//uniform int fvicsek_hex_fold2; // -@540
//uniform bool fvicsek_abs1_x; // -@540
//uniform bool fvicsek_abs1_z; // -@540
//uniform vec3 fvicsek_limit; // -@540
//uniform vec3 fvicsek_abs2_minus; // -@540
//uniform vec3 fvicsek_abs2_plus; // -@540
//uniform vec3 fvicsek_offset; // -@540
//uniform vec2 fvicsek_foldt; // -@540
//uniform float fvicsek_scale; // -@540
//uniform vec3 fvicsek_rotation1; // -@540
//uniform vec3 fvicsek_rotation2; // -@540
//uniform bool fvicsekdupea_preserve; // -@541
//uniform bool fvicsekdupea_hex_fold1; // -@541
//uniform int fvicsekdupea_hex_fold2; // -@541
//uniform bool fvicsekdupea_abs1_x; // -@541
//uniform bool fvicsekdupea_abs1_z; // -@541
//uniform vec3 fvicsekdupea_limit; // -@541
//uniform vec3 fvicsekdupea_abs2_minus; // -@541
//uniform vec3 fvicsekdupea_abs2_plus; // -@541
//uniform vec3 fvicsekdupea_offset; // -@541
//uniform vec2 fvicsekdupea_foldt; // -@541
//uniform float fvicsekdupea_scale; // -@541
//uniform vec3 fvicsekdupea_rotation1; // -@541
//uniform vec3 fvicsekdupea_rotation2; // -@541
//uniform bool fvicsekdupeb_preserve; // -@542
//uniform bool fvicsekdupeb_hex_fold1; // -@542
//uniform int fvicsekdupeb_hex_fold2; // -@542
//uniform bool fvicsekdupeb_abs1_x; // -@542
//uniform bool fvicsekdupeb_abs1_z; // -@542
//uniform vec3 fvicsekdupeb_limit; // -@542
//uniform vec3 fvicsekdupeb_abs2_minus; // -@542
//uniform vec3 fvicsekdupeb_abs2_plus; // -@542
//uniform vec3 fvicsekdupeb_offset; // -@542
//uniform vec2 fvicsekdupeb_foldt; // -@542
//uniform float fvicsekdupeb_scale; // -@542
//uniform vec3 fvicsekdupeb_rotation1; // -@542
//uniform vec3 fvicsekdupeb_rotation2; // -@542
//uniform bool fvicsekdupec_preserve; // -@543
//uniform bool fvicsekdupec_hex_fold1; // -@543
//uniform int fvicsekdupec_hex_fold2; // -@543
//uniform bool fvicsekdupec_abs1_x; // -@543
//uniform bool fvicsekdupec_abs1_z; // -@543
//uniform vec3 fvicsekdupec_limit; // -@543
//uniform vec3 fvicsekdupec_abs2_minus; // -@543
//uniform vec3 fvicsekdupec_abs2_plus; // -@543
//uniform vec3 fvicsekdupec_offset; // -@543
//uniform vec2 fvicsekdupec_foldt; // -@543
//uniform float fvicsekdupec_scale; // -@543
//uniform vec3 fvicsekdupec_rotation1; // -@543
//uniform vec3 fvicsekdupec_rotation2; // -@543
//uniform bool fvicsekduped_preserve; // -@544
//uniform bool fvicsekduped_hex_fold1; // -@544
//uniform int fvicsekduped_hex_fold2; // -@544
//uniform bool fvicsekduped_abs1_x; // -@544
//uniform bool fvicsekduped_abs1_z; // -@544
//uniform vec3 fvicsekduped_limit; // -@544
//uniform vec3 fvicsekduped_abs2_minus; // -@544
//uniform vec3 fvicsekduped_abs2_plus; // -@544
//uniform vec3 fvicsekduped_offset; // -@544
//uniform vec2 fvicsekduped_foldt; // -@544
//uniform float fvicsekduped_scale; // -@544
//uniform vec3 fvicsekduped_rotation1; // -@544
//uniform vec3 fvicsekduped_rotation2; // -@544
//uniform bool fvicsekdupee_preserve; // -@545
//uniform bool fvicsekdupee_hex_fold1; // -@545
//uniform int fvicsekdupee_hex_fold2; // -@545
//uniform bool fvicsekdupee_abs1_x; // -@545
//uniform bool fvicsekdupee_abs1_z; // -@545
//uniform vec3 fvicsekdupee_limit; // -@545
//uniform vec3 fvicsekdupee_abs2_minus; // -@545
//uniform vec3 fvicsekdupee_abs2_plus; // -@545
//uniform vec3 fvicsekdupee_offset; // -@545
//uniform vec2 fvicsekdupee_foldt; // -@545
//uniform float fvicsekdupee_scale; // -@545
//uniform vec3 fvicsekdupee_rotation1; // -@545
//uniform vec3 fvicsekdupee_rotation2; // -@545
//uniform bool fvicsekdupef_preserve; // -@546
//uniform bool fvicsekdupef_hex_fold1; // -@546
//uniform int fvicsekdupef_hex_fold2; // -@546
//uniform bool fvicsekdupef_abs1_x; // -@546
//uniform bool fvicsekdupef_abs1_z; // -@546
//uniform vec3 fvicsekdupef_limit; // -@546
//uniform vec3 fvicsekdupef_abs2_minus; // -@546
//uniform vec3 fvicsekdupef_abs2_plus; // -@546
//uniform vec3 fvicsekdupef_offset; // -@546
//uniform vec2 fvicsekdupef_foldt; // -@546
//uniform float fvicsekdupef_scale; // -@546
//uniform vec3 fvicsekdupef_rotation1; // -@546
//uniform vec3 fvicsekdupef_rotation2; // -@546
//uniform bool fvicsekdupeg_preserve; // -@547
//uniform bool fvicsekdupeg_hex_fold1; // -@547
//uniform int fvicsekdupeg_hex_fold2; // -@547
//uniform bool fvicsekdupeg_abs1_x; // -@547
//uniform bool fvicsekdupeg_abs1_z; // -@547
//uniform vec3 fvicsekdupeg_limit; // -@547
//uniform vec3 fvicsekdupeg_abs2_minus; // -@547
//uniform vec3 fvicsekdupeg_abs2_plus; // -@547
//uniform vec3 fvicsekdupeg_offset; // -@547
//uniform vec2 fvicsekdupeg_foldt; // -@547
//uniform float fvicsekdupeg_scale; // -@547
//uniform vec3 fvicsekdupeg_rotation1; // -@547
//uniform vec3 fvicsekdupeg_rotation2; // -@547
//uniform bool fvicsekdupeh_preserve; // -@548
//uniform bool fvicsekdupeh_hex_fold1; // -@548
//uniform int fvicsekdupeh_hex_fold2; // -@548
//uniform bool fvicsekdupeh_abs1_x; // -@548
//uniform bool fvicsekdupeh_abs1_z; // -@548
//uniform vec3 fvicsekdupeh_limit; // -@548
//uniform vec3 fvicsekdupeh_abs2_minus; // -@548
//uniform vec3 fvicsekdupeh_abs2_plus; // -@548
//uniform vec3 fvicsekdupeh_offset; // -@548
//uniform vec2 fvicsekdupeh_foldt; // -@548
//uniform float fvicsekdupeh_scale; // -@548
//uniform vec3 fvicsekdupeh_rotation1; // -@548
//uniform vec3 fvicsekdupeh_rotation2; // -@548
//uniform bool fvicsekdupei_preserve; // -@549
//uniform bool fvicsekdupei_hex_fold1; // -@549
//uniform int fvicsekdupei_hex_fold2; // -@549
//uniform bool fvicsekdupei_abs1_x; // -@549
//uniform bool fvicsekdupei_abs1_z; // -@549
//uniform vec3 fvicsekdupei_limit; // -@549
//uniform vec3 fvicsekdupei_abs2_minus; // -@549
//uniform vec3 fvicsekdupei_abs2_plus; // -@549
//uniform vec3 fvicsekdupei_offset; // -@549
//uniform vec2 fvicsekdupei_foldt; // -@549
//uniform float fvicsekdupei_scale; // -@549
//uniform vec3 fvicsekdupei_rotation1; // -@549
//uniform vec3 fvicsekdupei_rotation2; // -@549
//uniform bool fvicsekdupej_preserve; // -@550
//uniform bool fvicsekdupej_hex_fold1; // -@550
//uniform int fvicsekdupej_hex_fold2; // -@550
//uniform bool fvicsekdupej_abs1_x; // -@550
//uniform bool fvicsekdupej_abs1_z; // -@550
//uniform vec3 fvicsekdupej_limit; // -@550
//uniform vec3 fvicsekdupej_abs2_minus; // -@550
//uniform vec3 fvicsekdupej_abs2_plus; // -@550
//uniform vec3 fvicsekdupej_offset; // -@550
//uniform vec2 fvicsekdupej_foldt; // -@550
//uniform float fvicsekdupej_scale; // -@550
//uniform vec3 fvicsekdupej_rotation1; // -@550
//uniform vec3 fvicsekdupej_rotation2; // -@550
//uniform float fwavysponge_scale; // -@551
//uniform vec3 fwavysponge_clamp; // -@551
//uniform vec3 fwavysponge_offset; // -@551
//uniform float fwavyspongedupea_scale; // -@552
//uniform vec3 fwavyspongedupea_clamp; // -@552
//uniform vec3 fwavyspongedupea_offset; // -@552
//uniform float fwavyspongedupeb_scale; // -@553
//uniform vec3 fwavyspongedupeb_clamp; // -@553
//uniform vec3 fwavyspongedupeb_offset; // -@553
//uniform float fwavyspongedupec_scale; // -@554
//uniform vec3 fwavyspongedupec_clamp; // -@554
//uniform vec3 fwavyspongedupec_offset; // -@554
//uniform float fwavyspongeduped_scale; // -@555
//uniform vec3 fwavyspongeduped_clamp; // -@555
//uniform vec3 fwavyspongeduped_offset; // -@555
//uniform float fwavyspongedupee_scale; // -@556
//uniform vec3 fwavyspongedupee_clamp; // -@556
//uniform vec3 fwavyspongedupee_offset; // -@556
//uniform float fwavyspongedupef_scale; // -@557
//uniform vec3 fwavyspongedupef_clamp; // -@557
//uniform vec3 fwavyspongedupef_offset; // -@557
//uniform float fwavyspongedupeg_scale; // -@558
//uniform vec3 fwavyspongedupeg_clamp; // -@558
//uniform vec3 fwavyspongedupeg_offset; // -@558
//uniform float fwavyspongedupeh_scale; // -@559
//uniform vec3 fwavyspongedupeh_clamp; // -@559
//uniform vec3 fwavyspongedupeh_offset; // -@559
//uniform float fwavyspongedupei_scale; // -@560
//uniform vec3 fwavyspongedupei_clamp; // -@560
//uniform vec3 fwavyspongedupei_offset; // -@560
//uniform float fwavyspongedupej_scale; // -@561
//uniform vec3 fwavyspongedupej_clamp; // -@561
//uniform vec3 fwavyspongedupej_offset; // -@561
//uniform vec2 fwobbletransform_rotation; // -@562
//uniform float fwobbletransform_strength; // -@562
//uniform vec4 fwobbletransform_step; // -@562
//uniform vec2 fwobbletransform_range; // -@562
//uniform vec2 fwobbletransformdupea_rotation; // -@563
//uniform float fwobbletransformdupea_strength; // -@563
//uniform vec4 fwobbletransformdupea_step; // -@563
//uniform vec2 fwobbletransformdupea_range; // -@563
//uniform vec2 fwobbletransformdupeb_rotation; // -@564
//uniform float fwobbletransformdupeb_strength; // -@564
//uniform vec4 fwobbletransformdupeb_step; // -@564
//uniform vec2 fwobbletransformdupeb_range; // -@564
//uniform vec2 fwobbletransformdupec_rotation; // -@565
//uniform float fwobbletransformdupec_strength; // -@565
//uniform vec4 fwobbletransformdupec_step; // -@565
//uniform vec2 fwobbletransformdupec_range; // -@565
//uniform vec2 fwobbletransformduped_rotation; // -@566
//uniform float fwobbletransformduped_strength; // -@566
//uniform vec4 fwobbletransformduped_step; // -@566
//uniform vec2 fwobbletransformduped_range; // -@566
//uniform vec2 fwobbletransformdupee_rotation; // -@567
//uniform float fwobbletransformdupee_strength; // -@567
//uniform vec4 fwobbletransformdupee_step; // -@567
//uniform vec2 fwobbletransformdupee_range; // -@567
//uniform vec2 fwobbletransformdupef_rotation; // -@568
//uniform float fwobbletransformdupef_strength; // -@568
//uniform vec4 fwobbletransformdupef_step; // -@568
//uniform vec2 fwobbletransformdupef_range; // -@568
//uniform vec2 fwobbletransformdupeg_rotation; // -@569
//uniform float fwobbletransformdupeg_strength; // -@569
//uniform vec4 fwobbletransformdupeg_step; // -@569
//uniform vec2 fwobbletransformdupeg_range; // -@569
//uniform vec2 fwobbletransformdupeh_rotation; // -@570
//uniform float fwobbletransformdupeh_strength; // -@570
//uniform vec4 fwobbletransformdupeh_step; // -@570
//uniform vec2 fwobbletransformdupeh_range; // -@570
//uniform vec2 fwobbletransformdupei_rotation; // -@571
//uniform float fwobbletransformdupei_strength; // -@571
//uniform vec4 fwobbletransformdupei_step; // -@571
//uniform vec2 fwobbletransformdupei_range; // -@571
//uniform vec2 fwobbletransformdupej_rotation; // -@572
//uniform float fwobbletransformdupej_strength; // -@572
//uniform vec4 fwobbletransformdupej_step; // -@572
//uniform vec2 fwobbletransformdupej_range; // -@572

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
#include "res://formulas/bairddelta.gdshaderinc" // -@12
//#include "res://formulas/bairddeltadupea.gdshaderinc" // -@13
//#include "res://formulas/bairddeltadupeb.gdshaderinc" // -@14
//#include "res://formulas/bairddeltadupec.gdshaderinc" // -@15
//#include "res://formulas/bairddeltaduped.gdshaderinc" // -@16
//#include "res://formulas/bairddeltadupee.gdshaderinc" // -@17
//#include "res://formulas/bairddeltadupef.gdshaderinc" // -@18
//#include "res://formulas/bairddeltadupeg.gdshaderinc" // -@19
//#include "res://formulas/bairddeltadupeh.gdshaderinc" // -@20
//#include "res://formulas/bairddeltadupei.gdshaderinc" // -@21
//#include "res://formulas/bairddeltadupej.gdshaderinc" // -@22
//#include "res://formulas/basictransform.gdshaderinc" // -@23
//#include "res://formulas/basictransformdupea.gdshaderinc" // -@24
//#include "res://formulas/basictransformdupeb.gdshaderinc" // -@25
//#include "res://formulas/basictransformdupec.gdshaderinc" // -@26
//#include "res://formulas/basictransformduped.gdshaderinc" // -@27
//#include "res://formulas/basictransformdupee.gdshaderinc" // -@28
//#include "res://formulas/basictransformdupef.gdshaderinc" // -@29
//#include "res://formulas/basictransformdupeg.gdshaderinc" // -@30
//#include "res://formulas/basictransformdupeh.gdshaderinc" // -@31
//#include "res://formulas/basictransformdupei.gdshaderinc" // -@32
//#include "res://formulas/basictransformdupej.gdshaderinc" // -@33
//#include "res://formulas/benesiship.gdshaderinc" // -@34
//#include "res://formulas/benesishipdupea.gdshaderinc" // -@35
//#include "res://formulas/benesishipdupeb.gdshaderinc" // -@36
//#include "res://formulas/benesishipdupec.gdshaderinc" // -@37
//#include "res://formulas/benesishipduped.gdshaderinc" // -@38
//#include "res://formulas/benesishipdupee.gdshaderinc" // -@39
//#include "res://formulas/benesishipdupef.gdshaderinc" // -@40
//#include "res://formulas/benesishipdupeg.gdshaderinc" // -@41
//#include "res://formulas/benesishipdupeh.gdshaderinc" // -@42
//#include "res://formulas/benesishipdupei.gdshaderinc" // -@43
//#include "res://formulas/benesishipdupej.gdshaderinc" // -@44
//#include "res://formulas/bristorbrot.gdshaderinc" // -@45
//#include "res://formulas/bristorbrotdupea.gdshaderinc" // -@46
//#include "res://formulas/bristorbrotdupeb.gdshaderinc" // -@47
//#include "res://formulas/bristorbrotdupec.gdshaderinc" // -@48
//#include "res://formulas/bristorbrotduped.gdshaderinc" // -@49
//#include "res://formulas/bristorbrotdupee.gdshaderinc" // -@50
//#include "res://formulas/bristorbrotdupef.gdshaderinc" // -@51
//#include "res://formulas/bristorbrotdupeg.gdshaderinc" // -@52
//#include "res://formulas/bristorbrotdupeh.gdshaderinc" // -@53
//#include "res://formulas/bristorbrotdupei.gdshaderinc" // -@54
//#include "res://formulas/bristorbrotdupej.gdshaderinc" // -@55
//#include "res://formulas/circuit.gdshaderinc" // -@56
//#include "res://formulas/circuitdupea.gdshaderinc" // -@57
//#include "res://formulas/circuitdupeb.gdshaderinc" // -@58
//#include "res://formulas/circuitdupec.gdshaderinc" // -@59
//#include "res://formulas/circuitduped.gdshaderinc" // -@60
//#include "res://formulas/circuitdupee.gdshaderinc" // -@61
//#include "res://formulas/circuitdupef.gdshaderinc" // -@62
//#include "res://formulas/circuitdupeg.gdshaderinc" // -@63
//#include "res://formulas/circuitdupeh.gdshaderinc" // -@64
//#include "res://formulas/circuitdupei.gdshaderinc" // -@65
//#include "res://formulas/circuitdupej.gdshaderinc" // -@66
//#include "res://formulas/cube.gdshaderinc" // -@67
//#include "res://formulas/cubedupea.gdshaderinc" // -@68
//#include "res://formulas/cubedupeb.gdshaderinc" // -@69
//#include "res://formulas/cubedupec.gdshaderinc" // -@70
//#include "res://formulas/cubeduped.gdshaderinc" // -@71
//#include "res://formulas/cubedupee.gdshaderinc" // -@72
//#include "res://formulas/cubedupef.gdshaderinc" // -@73
//#include "res://formulas/cubedupeg.gdshaderinc" // -@74
//#include "res://formulas/cubedupeh.gdshaderinc" // -@75
//#include "res://formulas/cubedupei.gdshaderinc" // -@76
//#include "res://formulas/cubedupej.gdshaderinc" // -@77
//#include "res://formulas/dodecahedron.gdshaderinc" // -@78
//#include "res://formulas/dodecahedrondupea.gdshaderinc" // -@79
//#include "res://formulas/dodecahedrondupeb.gdshaderinc" // -@80
//#include "res://formulas/dodecahedrondupec.gdshaderinc" // -@81
//#include "res://formulas/dodecahedronduped.gdshaderinc" // -@82
//#include "res://formulas/dodecahedrondupee.gdshaderinc" // -@83
//#include "res://formulas/dodecahedrondupef.gdshaderinc" // -@84
//#include "res://formulas/dodecahedrondupeg.gdshaderinc" // -@85
//#include "res://formulas/dodecahedrondupeh.gdshaderinc" // -@86
//#include "res://formulas/dodecahedrondupei.gdshaderinc" // -@87
//#include "res://formulas/dodecahedrondupej.gdshaderinc" // -@88
//#include "res://formulas/gemstone.gdshaderinc" // -@89
//#include "res://formulas/gemstonedupea.gdshaderinc" // -@90
//#include "res://formulas/gemstonedupeb.gdshaderinc" // -@91
//#include "res://formulas/gemstonedupec.gdshaderinc" // -@92
//#include "res://formulas/gemstoneduped.gdshaderinc" // -@93
//#include "res://formulas/gemstonedupee.gdshaderinc" // -@94
//#include "res://formulas/gemstonedupef.gdshaderinc" // -@95
//#include "res://formulas/gemstonedupeg.gdshaderinc" // -@96
//#include "res://formulas/gemstonedupeh.gdshaderinc" // -@97
//#include "res://formulas/gemstonedupei.gdshaderinc" // -@98
//#include "res://formulas/gemstonedupej.gdshaderinc" // -@99
//#include "res://formulas/gyroid.gdshaderinc" // -@100
//#include "res://formulas/gyroiddupea.gdshaderinc" // -@101
//#include "res://formulas/gyroiddupeb.gdshaderinc" // -@102
//#include "res://formulas/gyroiddupec.gdshaderinc" // -@103
//#include "res://formulas/gyroidduped.gdshaderinc" // -@104
//#include "res://formulas/gyroiddupee.gdshaderinc" // -@105
//#include "res://formulas/gyroiddupef.gdshaderinc" // -@106
//#include "res://formulas/gyroiddupeg.gdshaderinc" // -@107
//#include "res://formulas/gyroiddupeh.gdshaderinc" // -@108
//#include "res://formulas/gyroiddupei.gdshaderinc" // -@109
//#include "res://formulas/gyroiddupej.gdshaderinc" // -@110
//#include "res://formulas/hollowtetrahedron.gdshaderinc" // -@111
//#include "res://formulas/hollowtetrahedrondupea.gdshaderinc" // -@112
//#include "res://formulas/hollowtetrahedrondupeb.gdshaderinc" // -@113
//#include "res://formulas/hollowtetrahedrondupec.gdshaderinc" // -@114
//#include "res://formulas/hollowtetrahedronduped.gdshaderinc" // -@115
//#include "res://formulas/hollowtetrahedrondupee.gdshaderinc" // -@116
//#include "res://formulas/hollowtetrahedrondupef.gdshaderinc" // -@117
//#include "res://formulas/hollowtetrahedrondupeg.gdshaderinc" // -@118
//#include "res://formulas/hollowtetrahedrondupeh.gdshaderinc" // -@119
//#include "res://formulas/hollowtetrahedrondupei.gdshaderinc" // -@120
//#include "res://formulas/hollowtetrahedrondupej.gdshaderinc" // -@121
//#include "res://formulas/icosahedron.gdshaderinc" // -@122
//#include "res://formulas/icosahedrondupea.gdshaderinc" // -@123
//#include "res://formulas/icosahedrondupeb.gdshaderinc" // -@124
//#include "res://formulas/icosahedrondupec.gdshaderinc" // -@125
//#include "res://formulas/icosahedronduped.gdshaderinc" // -@126
//#include "res://formulas/icosahedrondupee.gdshaderinc" // -@127
//#include "res://formulas/icosahedrondupef.gdshaderinc" // -@128
//#include "res://formulas/icosahedrondupeg.gdshaderinc" // -@129
//#include "res://formulas/icosahedrondupeh.gdshaderinc" // -@130
//#include "res://formulas/icosahedrondupei.gdshaderinc" // -@131
//#include "res://formulas/icosahedrondupej.gdshaderinc" // -@132
//#include "res://formulas/inversebox.gdshaderinc" // -@133
//#include "res://formulas/inverseboxdupea.gdshaderinc" // -@134
//#include "res://formulas/inverseboxdupeb.gdshaderinc" // -@135
//#include "res://formulas/inverseboxdupec.gdshaderinc" // -@136
//#include "res://formulas/inverseboxduped.gdshaderinc" // -@137
//#include "res://formulas/inverseboxdupee.gdshaderinc" // -@138
//#include "res://formulas/inverseboxdupef.gdshaderinc" // -@139
//#include "res://formulas/inverseboxdupeg.gdshaderinc" // -@140
//#include "res://formulas/inverseboxdupeh.gdshaderinc" // -@141
//#include "res://formulas/inverseboxdupei.gdshaderinc" // -@142
//#include "res://formulas/inverseboxdupej.gdshaderinc" // -@143
//#include "res://formulas/inversiontransform.gdshaderinc" // -@144
//#include "res://formulas/inversiontransformdupea.gdshaderinc" // -@145
//#include "res://formulas/inversiontransformdupeb.gdshaderinc" // -@146
//#include "res://formulas/inversiontransformdupec.gdshaderinc" // -@147
//#include "res://formulas/inversiontransformduped.gdshaderinc" // -@148
//#include "res://formulas/inversiontransformdupee.gdshaderinc" // -@149
//#include "res://formulas/inversiontransformdupef.gdshaderinc" // -@150
//#include "res://formulas/inversiontransformdupeg.gdshaderinc" // -@151
//#include "res://formulas/inversiontransformdupeh.gdshaderinc" // -@152
//#include "res://formulas/inversiontransformdupei.gdshaderinc" // -@153
//#include "res://formulas/inversiontransformdupej.gdshaderinc" // -@154
//#include "res://formulas/jerusalemcube.gdshaderinc" // -@155
//#include "res://formulas/jerusalemcubedupea.gdshaderinc" // -@156
//#include "res://formulas/jerusalemcubedupeb.gdshaderinc" // -@157
//#include "res://formulas/jerusalemcubedupec.gdshaderinc" // -@158
//#include "res://formulas/jerusalemcubeduped.gdshaderinc" // -@159
//#include "res://formulas/jerusalemcubedupee.gdshaderinc" // -@160
//#include "res://formulas/jerusalemcubedupef.gdshaderinc" // -@161
//#include "res://formulas/jerusalemcubedupeg.gdshaderinc" // -@162
//#include "res://formulas/jerusalemcubedupeh.gdshaderinc" // -@163
//#include "res://formulas/jerusalemcubedupei.gdshaderinc" // -@164
//#include "res://formulas/jerusalemcubedupej.gdshaderinc" // -@165
//#include "res://formulas/kalaidotransform.gdshaderinc" // -@166
//#include "res://formulas/kalaidotransformdupea.gdshaderinc" // -@167
//#include "res://formulas/kalaidotransformdupeb.gdshaderinc" // -@168
//#include "res://formulas/kalaidotransformdupec.gdshaderinc" // -@169
//#include "res://formulas/kalaidotransformduped.gdshaderinc" // -@170
//#include "res://formulas/kalaidotransformdupee.gdshaderinc" // -@171
//#include "res://formulas/kalaidotransformdupef.gdshaderinc" // -@172
//#include "res://formulas/kalaidotransformdupeg.gdshaderinc" // -@173
//#include "res://formulas/kalaidotransformdupeh.gdshaderinc" // -@174
//#include "res://formulas/kalaidotransformdupei.gdshaderinc" // -@175
//#include "res://formulas/kalaidotransformdupej.gdshaderinc" // -@176
//#include "res://formulas/kalibox.gdshaderinc" // -@177
//#include "res://formulas/kaliboxdupea.gdshaderinc" // -@178
//#include "res://formulas/kaliboxdupeb.gdshaderinc" // -@179
//#include "res://formulas/kaliboxdupec.gdshaderinc" // -@180
//#include "res://formulas/kaliboxduped.gdshaderinc" // -@181
//#include "res://formulas/kaliboxdupee.gdshaderinc" // -@182
//#include "res://formulas/kaliboxdupef.gdshaderinc" // -@183
//#include "res://formulas/kaliboxdupeg.gdshaderinc" // -@184
//#include "res://formulas/kaliboxdupeh.gdshaderinc" // -@185
//#include "res://formulas/kaliboxdupei.gdshaderinc" // -@186
//#include "res://formulas/kaliboxdupej.gdshaderinc" // -@187
//#include "res://formulas/kaliliving.gdshaderinc" // -@188
//#include "res://formulas/kalilivingdupea.gdshaderinc" // -@189
//#include "res://formulas/kalilivingdupeb.gdshaderinc" // -@190
//#include "res://formulas/kalilivingdupec.gdshaderinc" // -@191
//#include "res://formulas/kalilivingduped.gdshaderinc" // -@192
//#include "res://formulas/kalilivingdupee.gdshaderinc" // -@193
//#include "res://formulas/kalilivingdupef.gdshaderinc" // -@194
//#include "res://formulas/kalilivingdupeg.gdshaderinc" // -@195
//#include "res://formulas/kalilivingdupeh.gdshaderinc" // -@196
//#include "res://formulas/kalilivingdupei.gdshaderinc" // -@197
//#include "res://formulas/kalilivingdupej.gdshaderinc" // -@198
//#include "res://formulas/kaliredux.gdshaderinc" // -@199
//#include "res://formulas/kalireduxdupea.gdshaderinc" // -@200
//#include "res://formulas/kalireduxdupeb.gdshaderinc" // -@201
//#include "res://formulas/kalireduxdupec.gdshaderinc" // -@202
//#include "res://formulas/kalireduxduped.gdshaderinc" // -@203
//#include "res://formulas/kalireduxdupee.gdshaderinc" // -@204
//#include "res://formulas/kalireduxdupef.gdshaderinc" // -@205
//#include "res://formulas/kalireduxdupeg.gdshaderinc" // -@206
//#include "res://formulas/kalireduxdupeh.gdshaderinc" // -@207
//#include "res://formulas/kalireduxdupei.gdshaderinc" // -@208
//#include "res://formulas/kalireduxdupej.gdshaderinc" // -@209
//#include "res://formulas/klenian.gdshaderinc" // -@210
//#include "res://formulas/kleniandupea.gdshaderinc" // -@211
//#include "res://formulas/kleniandupeb.gdshaderinc" // -@212
//#include "res://formulas/kleniandupec.gdshaderinc" // -@213
//#include "res://formulas/klenianduped.gdshaderinc" // -@214
//#include "res://formulas/kleniandupee.gdshaderinc" // -@215
//#include "res://formulas/kleniandupef.gdshaderinc" // -@216
//#include "res://formulas/kleniandupeg.gdshaderinc" // -@217
//#include "res://formulas/kleniandupeh.gdshaderinc" // -@218
//#include "res://formulas/kleniandupei.gdshaderinc" // -@219
//#include "res://formulas/kleniandupej.gdshaderinc" // -@220
//#include "res://formulas/kochcube.gdshaderinc" // -@221
//#include "res://formulas/kochcubedupea.gdshaderinc" // -@222
//#include "res://formulas/kochcubedupeb.gdshaderinc" // -@223
//#include "res://formulas/kochcubedupec.gdshaderinc" // -@224
//#include "res://formulas/kochcubeduped.gdshaderinc" // -@225
//#include "res://formulas/kochcubedupee.gdshaderinc" // -@226
//#include "res://formulas/kochcubedupef.gdshaderinc" // -@227
//#include "res://formulas/kochcubedupeg.gdshaderinc" // -@228
//#include "res://formulas/kochcubedupeh.gdshaderinc" // -@229
//#include "res://formulas/kochcubedupei.gdshaderinc" // -@230
//#include "res://formulas/kochcubedupej.gdshaderinc" // -@231
//#include "res://formulas/kochwire.gdshaderinc" // -@232
//#include "res://formulas/kochwiredupea.gdshaderinc" // -@233
//#include "res://formulas/kochwiredupeb.gdshaderinc" // -@234
//#include "res://formulas/kochwiredupec.gdshaderinc" // -@235
//#include "res://formulas/kochwireduped.gdshaderinc" // -@236
//#include "res://formulas/kochwiredupee.gdshaderinc" // -@237
//#include "res://formulas/kochwiredupef.gdshaderinc" // -@238
//#include "res://formulas/kochwiredupeg.gdshaderinc" // -@239
//#include "res://formulas/kochwiredupeh.gdshaderinc" // -@240
//#include "res://formulas/kochwiredupei.gdshaderinc" // -@241
//#include "res://formulas/kochwiredupej.gdshaderinc" // -@242
//#include "res://formulas/lionbulb.gdshaderinc" // -@243
//#include "res://formulas/lionbulbdupea.gdshaderinc" // -@244
//#include "res://formulas/lionbulbdupeb.gdshaderinc" // -@245
//#include "res://formulas/lionbulbdupec.gdshaderinc" // -@246
//#include "res://formulas/lionbulbduped.gdshaderinc" // -@247
//#include "res://formulas/lionbulbdupee.gdshaderinc" // -@248
//#include "res://formulas/lionbulbdupef.gdshaderinc" // -@249
//#include "res://formulas/lionbulbdupeg.gdshaderinc" // -@250
//#include "res://formulas/lionbulbdupeh.gdshaderinc" // -@251
//#include "res://formulas/lionbulbdupei.gdshaderinc" // -@252
//#include "res://formulas/lionbulbdupej.gdshaderinc" // -@253
//#include "res://formulas/logtransform.gdshaderinc" // -@254
//#include "res://formulas/logtransformdupea.gdshaderinc" // -@255
//#include "res://formulas/logtransformdupeb.gdshaderinc" // -@256
//#include "res://formulas/logtransformdupec.gdshaderinc" // -@257
//#include "res://formulas/logtransformduped.gdshaderinc" // -@258
//#include "res://formulas/logtransformdupee.gdshaderinc" // -@259
//#include "res://formulas/logtransformdupef.gdshaderinc" // -@260
//#include "res://formulas/logtransformdupeg.gdshaderinc" // -@261
//#include "res://formulas/logtransformdupeh.gdshaderinc" // -@262
//#include "res://formulas/logtransformdupei.gdshaderinc" // -@263
//#include "res://formulas/logtransformdupej.gdshaderinc" // -@264
//#include "res://formulas/mandelbox.gdshaderinc" // -@265
//#include "res://formulas/mandelboxdupea.gdshaderinc" // -@266
//#include "res://formulas/mandelboxdupeb.gdshaderinc" // -@267
//#include "res://formulas/mandelboxdupec.gdshaderinc" // -@268
//#include "res://formulas/mandelboxduped.gdshaderinc" // -@269
//#include "res://formulas/mandelboxdupee.gdshaderinc" // -@270
//#include "res://formulas/mandelboxdupef.gdshaderinc" // -@271
//#include "res://formulas/mandelboxdupeg.gdshaderinc" // -@272
//#include "res://formulas/mandelboxdupeh.gdshaderinc" // -@273
//#include "res://formulas/mandelboxdupei.gdshaderinc" // -@274
//#include "res://formulas/mandelboxdupej.gdshaderinc" // -@275
//#include "res://formulas/mandelbulb.gdshaderinc" // -@276
//#include "res://formulas/mandelbulbdupea.gdshaderinc" // -@277
//#include "res://formulas/mandelbulbdupeb.gdshaderinc" // -@278
//#include "res://formulas/mandelbulbdupec.gdshaderinc" // -@279
//#include "res://formulas/mandelbulbduped.gdshaderinc" // -@280
//#include "res://formulas/mandelbulbdupee.gdshaderinc" // -@281
//#include "res://formulas/mandelbulbdupef.gdshaderinc" // -@282
//#include "res://formulas/mandelbulbdupeg.gdshaderinc" // -@283
//#include "res://formulas/mandelbulbdupeh.gdshaderinc" // -@284
//#include "res://formulas/mandelbulbdupei.gdshaderinc" // -@285
//#include "res://formulas/mandelbulbdupej.gdshaderinc" // -@286
//#include "res://formulas/mandelettuce.gdshaderinc" // -@287
//#include "res://formulas/mandelettucedupea.gdshaderinc" // -@288
//#include "res://formulas/mandelettucedupeb.gdshaderinc" // -@289
//#include "res://formulas/mandelettucedupec.gdshaderinc" // -@290
//#include "res://formulas/mandelettuceduped.gdshaderinc" // -@291
//#include "res://formulas/mandelettucedupee.gdshaderinc" // -@292
//#include "res://formulas/mandelettucedupef.gdshaderinc" // -@293
//#include "res://formulas/mandelettucedupeg.gdshaderinc" // -@294
//#include "res://formulas/mandelettucedupeh.gdshaderinc" // -@295
//#include "res://formulas/mandelettucedupei.gdshaderinc" // -@296
//#include "res://formulas/mandelettucedupej.gdshaderinc" // -@297
//#include "res://formulas/melttransform.gdshaderinc" // -@298
//#include "res://formulas/melttransformdupea.gdshaderinc" // -@299
//#include "res://formulas/melttransformdupeb.gdshaderinc" // -@300
//#include "res://formulas/melttransformdupec.gdshaderinc" // -@301
//#include "res://formulas/melttransformduped.gdshaderinc" // -@302
//#include "res://formulas/melttransformdupee.gdshaderinc" // -@303
//#include "res://formulas/melttransformdupef.gdshaderinc" // -@304
//#include "res://formulas/melttransformdupeg.gdshaderinc" // -@305
//#include "res://formulas/melttransformdupeh.gdshaderinc" // -@306
//#include "res://formulas/melttransformdupei.gdshaderinc" // -@307
//#include "res://formulas/melttransformdupej.gdshaderinc" // -@308
//#include "res://formulas/mengersponge.gdshaderinc" // -@309
//#include "res://formulas/mengerspongedupea.gdshaderinc" // -@310
//#include "res://formulas/mengerspongedupeb.gdshaderinc" // -@311
//#include "res://formulas/mengerspongedupec.gdshaderinc" // -@312
//#include "res://formulas/mengerspongeduped.gdshaderinc" // -@313
//#include "res://formulas/mengerspongedupee.gdshaderinc" // -@314
//#include "res://formulas/mengerspongedupef.gdshaderinc" // -@315
//#include "res://formulas/mengerspongedupeg.gdshaderinc" // -@316
//#include "res://formulas/mengerspongedupeh.gdshaderinc" // -@317
//#include "res://formulas/mengerspongedupei.gdshaderinc" // -@318
//#include "res://formulas/mengerspongedupej.gdshaderinc" // -@319
//#include "res://formulas/mixpinski4d.gdshaderinc" // -@320
//#include "res://formulas/mixpinski4ddupea.gdshaderinc" // -@321
//#include "res://formulas/mixpinski4ddupeb.gdshaderinc" // -@322
//#include "res://formulas/mixpinski4ddupec.gdshaderinc" // -@323
//#include "res://formulas/mixpinski4dduped.gdshaderinc" // -@324
//#include "res://formulas/mixpinski4ddupee.gdshaderinc" // -@325
//#include "res://formulas/mixpinski4ddupef.gdshaderinc" // -@326
//#include "res://formulas/mixpinski4ddupeg.gdshaderinc" // -@327
//#include "res://formulas/mixpinski4ddupeh.gdshaderinc" // -@328
//#include "res://formulas/mixpinski4ddupei.gdshaderinc" // -@329
//#include "res://formulas/mixpinski4ddupej.gdshaderinc" // -@330
//#include "res://formulas/newton.gdshaderinc" // -@331
//#include "res://formulas/newtondupea.gdshaderinc" // -@332
//#include "res://formulas/newtondupeb.gdshaderinc" // -@333
//#include "res://formulas/newtondupec.gdshaderinc" // -@334
//#include "res://formulas/newtonduped.gdshaderinc" // -@335
//#include "res://formulas/newtondupee.gdshaderinc" // -@336
//#include "res://formulas/newtondupef.gdshaderinc" // -@337
//#include "res://formulas/newtondupeg.gdshaderinc" // -@338
//#include "res://formulas/newtondupeh.gdshaderinc" // -@339
//#include "res://formulas/newtondupei.gdshaderinc" // -@340
//#include "res://formulas/newtondupej.gdshaderinc" // -@341
//#include "res://formulas/octahedron.gdshaderinc" // -@342
//#include "res://formulas/octahedrondupea.gdshaderinc" // -@343
//#include "res://formulas/octahedrondupeb.gdshaderinc" // -@344
//#include "res://formulas/octahedrondupec.gdshaderinc" // -@345
//#include "res://formulas/octahedronduped.gdshaderinc" // -@346
//#include "res://formulas/octahedrondupee.gdshaderinc" // -@347
//#include "res://formulas/octahedrondupef.gdshaderinc" // -@348
//#include "res://formulas/octahedrondupeg.gdshaderinc" // -@349
//#include "res://formulas/octahedrondupeh.gdshaderinc" // -@350
//#include "res://formulas/octahedrondupei.gdshaderinc" // -@351
//#include "res://formulas/octahedrondupej.gdshaderinc" // -@352
//#include "res://formulas/octkoch.gdshaderinc" // -@353
//#include "res://formulas/octkochdupea.gdshaderinc" // -@354
//#include "res://formulas/octkochdupeb.gdshaderinc" // -@355
//#include "res://formulas/octkochdupec.gdshaderinc" // -@356
//#include "res://formulas/octkochduped.gdshaderinc" // -@357
//#include "res://formulas/octkochdupee.gdshaderinc" // -@358
//#include "res://formulas/octkochdupef.gdshaderinc" // -@359
//#include "res://formulas/octkochdupeg.gdshaderinc" // -@360
//#include "res://formulas/octkochdupeh.gdshaderinc" // -@361
//#include "res://formulas/octkochdupei.gdshaderinc" // -@362
//#include "res://formulas/octkochdupej.gdshaderinc" // -@363
//#include "res://formulas/plane.gdshaderinc" // -@364
//#include "res://formulas/planedupea.gdshaderinc" // -@365
//#include "res://formulas/planedupeb.gdshaderinc" // -@366
//#include "res://formulas/planedupec.gdshaderinc" // -@367
//#include "res://formulas/planeduped.gdshaderinc" // -@368
//#include "res://formulas/planedupee.gdshaderinc" // -@369
//#include "res://formulas/planedupef.gdshaderinc" // -@370
//#include "res://formulas/planedupeg.gdshaderinc" // -@371
//#include "res://formulas/planedupeh.gdshaderinc" // -@372
//#include "res://formulas/planedupei.gdshaderinc" // -@373
//#include "res://formulas/planedupej.gdshaderinc" // -@374
//#include "res://formulas/platonickoch.gdshaderinc" // -@375
//#include "res://formulas/platonickochdupea.gdshaderinc" // -@376
//#include "res://formulas/platonickochdupeb.gdshaderinc" // -@377
//#include "res://formulas/platonickochdupec.gdshaderinc" // -@378
//#include "res://formulas/platonickochduped.gdshaderinc" // -@379
//#include "res://formulas/platonickochdupee.gdshaderinc" // -@380
//#include "res://formulas/platonickochdupef.gdshaderinc" // -@381
//#include "res://formulas/platonickochdupeg.gdshaderinc" // -@382
//#include "res://formulas/platonickochdupeh.gdshaderinc" // -@383
//#include "res://formulas/platonickochdupei.gdshaderinc" // -@384
//#include "res://formulas/platonickochdupej.gdshaderinc" // -@385
//#include "res://formulas/pseudoklenian.gdshaderinc" // -@386
//#include "res://formulas/pseudokleniandupea.gdshaderinc" // -@387
//#include "res://formulas/pseudokleniandupeb.gdshaderinc" // -@388
//#include "res://formulas/pseudokleniandupec.gdshaderinc" // -@389
//#include "res://formulas/pseudoklenianduped.gdshaderinc" // -@390
//#include "res://formulas/pseudokleniandupee.gdshaderinc" // -@391
//#include "res://formulas/pseudokleniandupef.gdshaderinc" // -@392
//#include "res://formulas/pseudokleniandupeg.gdshaderinc" // -@393
//#include "res://formulas/pseudokleniandupeh.gdshaderinc" // -@394
//#include "res://formulas/pseudokleniandupei.gdshaderinc" // -@395
//#include "res://formulas/pseudokleniandupej.gdshaderinc" // -@396
//#include "res://formulas/quadratickoch.gdshaderinc" // -@397
//#include "res://formulas/quadratickochdupea.gdshaderinc" // -@398
//#include "res://formulas/quadratickochdupeb.gdshaderinc" // -@399
//#include "res://formulas/quadratickochdupec.gdshaderinc" // -@400
//#include "res://formulas/quadratickochduped.gdshaderinc" // -@401
//#include "res://formulas/quadratickochdupee.gdshaderinc" // -@402
//#include "res://formulas/quadratickochdupef.gdshaderinc" // -@403
//#include "res://formulas/quadratickochdupeg.gdshaderinc" // -@404
//#include "res://formulas/quadratickochdupeh.gdshaderinc" // -@405
//#include "res://formulas/quadratickochdupei.gdshaderinc" // -@406
//#include "res://formulas/quadratickochdupej.gdshaderinc" // -@407
//#include "res://formulas/reciprocaltransform.gdshaderinc" // -@408
//#include "res://formulas/reciprocaltransformdupea.gdshaderinc" // -@409
//#include "res://formulas/reciprocaltransformdupeb.gdshaderinc" // -@410
//#include "res://formulas/reciprocaltransformdupec.gdshaderinc" // -@411
//#include "res://formulas/reciprocaltransformduped.gdshaderinc" // -@412
//#include "res://formulas/reciprocaltransformdupee.gdshaderinc" // -@413
//#include "res://formulas/reciprocaltransformdupef.gdshaderinc" // -@414
//#include "res://formulas/reciprocaltransformdupeg.gdshaderinc" // -@415
//#include "res://formulas/reciprocaltransformdupeh.gdshaderinc" // -@416
//#include "res://formulas/reciprocaltransformdupei.gdshaderinc" // -@417
//#include "res://formulas/reciprocaltransformdupej.gdshaderinc" // -@418
//#include "res://formulas/romanescobroccoli.gdshaderinc" // -@419
//#include "res://formulas/romanescobroccolidupea.gdshaderinc" // -@420
//#include "res://formulas/romanescobroccolidupeb.gdshaderinc" // -@421
//#include "res://formulas/romanescobroccolidupec.gdshaderinc" // -@422
//#include "res://formulas/romanescobroccoliduped.gdshaderinc" // -@423
//#include "res://formulas/romanescobroccolidupee.gdshaderinc" // -@424
//#include "res://formulas/romanescobroccolidupef.gdshaderinc" // -@425
//#include "res://formulas/romanescobroccolidupeg.gdshaderinc" // -@426
//#include "res://formulas/romanescobroccolidupeh.gdshaderinc" // -@427
//#include "res://formulas/romanescobroccolidupei.gdshaderinc" // -@428
//#include "res://formulas/romanescobroccolidupej.gdshaderinc" // -@429
//#include "res://formulas/sierpinskidodecahedron.gdshaderinc" // -@430
//#include "res://formulas/sierpinskidodecahedrondupea.gdshaderinc" // -@431
//#include "res://formulas/sierpinskidodecahedrondupeb.gdshaderinc" // -@432
//#include "res://formulas/sierpinskidodecahedrondupec.gdshaderinc" // -@433
//#include "res://formulas/sierpinskidodecahedronduped.gdshaderinc" // -@434
//#include "res://formulas/sierpinskidodecahedrondupee.gdshaderinc" // -@435
//#include "res://formulas/sierpinskidodecahedrondupef.gdshaderinc" // -@436
//#include "res://formulas/sierpinskidodecahedrondupeg.gdshaderinc" // -@437
//#include "res://formulas/sierpinskidodecahedrondupeh.gdshaderinc" // -@438
//#include "res://formulas/sierpinskidodecahedrondupei.gdshaderinc" // -@439
//#include "res://formulas/sierpinskidodecahedrondupej.gdshaderinc" // -@440
//#include "res://formulas/sierpinskiicosahedron.gdshaderinc" // -@441
//#include "res://formulas/sierpinskiicosahedrondupea.gdshaderinc" // -@442
//#include "res://formulas/sierpinskiicosahedrondupeb.gdshaderinc" // -@443
//#include "res://formulas/sierpinskiicosahedrondupec.gdshaderinc" // -@444
//#include "res://formulas/sierpinskiicosahedronduped.gdshaderinc" // -@445
//#include "res://formulas/sierpinskiicosahedrondupee.gdshaderinc" // -@446
//#include "res://formulas/sierpinskiicosahedrondupef.gdshaderinc" // -@447
//#include "res://formulas/sierpinskiicosahedrondupeg.gdshaderinc" // -@448
//#include "res://formulas/sierpinskiicosahedrondupeh.gdshaderinc" // -@449
//#include "res://formulas/sierpinskiicosahedrondupei.gdshaderinc" // -@450
//#include "res://formulas/sierpinskiicosahedrondupej.gdshaderinc" // -@451
//#include "res://formulas/sierpinskioctahedron.gdshaderinc" // -@452
//#include "res://formulas/sierpinskioctahedrondupea.gdshaderinc" // -@453
//#include "res://formulas/sierpinskioctahedrondupeb.gdshaderinc" // -@454
//#include "res://formulas/sierpinskioctahedrondupec.gdshaderinc" // -@455
//#include "res://formulas/sierpinskioctahedronduped.gdshaderinc" // -@456
//#include "res://formulas/sierpinskioctahedrondupee.gdshaderinc" // -@457
//#include "res://formulas/sierpinskioctahedrondupef.gdshaderinc" // -@458
//#include "res://formulas/sierpinskioctahedrondupeg.gdshaderinc" // -@459
//#include "res://formulas/sierpinskioctahedrondupeh.gdshaderinc" // -@460
//#include "res://formulas/sierpinskioctahedrondupei.gdshaderinc" // -@461
//#include "res://formulas/sierpinskioctahedrondupej.gdshaderinc" // -@462
//#include "res://formulas/sierpinskitetrahedron.gdshaderinc" // -@463
//#include "res://formulas/sierpinskitetrahedrondupea.gdshaderinc" // -@464
//#include "res://formulas/sierpinskitetrahedrondupeb.gdshaderinc" // -@465
//#include "res://formulas/sierpinskitetrahedrondupec.gdshaderinc" // -@466
//#include "res://formulas/sierpinskitetrahedronduped.gdshaderinc" // -@467
//#include "res://formulas/sierpinskitetrahedrondupee.gdshaderinc" // -@468
//#include "res://formulas/sierpinskitetrahedrondupef.gdshaderinc" // -@469
//#include "res://formulas/sierpinskitetrahedrondupeg.gdshaderinc" // -@470
//#include "res://formulas/sierpinskitetrahedrondupeh.gdshaderinc" // -@471
//#include "res://formulas/sierpinskitetrahedrondupei.gdshaderinc" // -@472
//#include "res://formulas/sierpinskitetrahedrondupej.gdshaderinc" // -@473
//#include "res://formulas/sintransform.gdshaderinc" // -@474
//#include "res://formulas/sintransformdupea.gdshaderinc" // -@475
//#include "res://formulas/sintransformdupeb.gdshaderinc" // -@476
//#include "res://formulas/sintransformdupec.gdshaderinc" // -@477
//#include "res://formulas/sintransformduped.gdshaderinc" // -@478
//#include "res://formulas/sintransformdupee.gdshaderinc" // -@479
//#include "res://formulas/sintransformdupef.gdshaderinc" // -@480
//#include "res://formulas/sintransformdupeg.gdshaderinc" // -@481
//#include "res://formulas/sintransformdupeh.gdshaderinc" // -@482
//#include "res://formulas/sintransformdupei.gdshaderinc" // -@483
//#include "res://formulas/sintransformdupej.gdshaderinc" // -@484
//#include "res://formulas/sphairahedron.gdshaderinc" // -@485
//#include "res://formulas/sphairahedrondupea.gdshaderinc" // -@486
//#include "res://formulas/sphairahedrondupeb.gdshaderinc" // -@487
//#include "res://formulas/sphairahedrondupec.gdshaderinc" // -@488
//#include "res://formulas/sphairahedronduped.gdshaderinc" // -@489
//#include "res://formulas/sphairahedrondupee.gdshaderinc" // -@490
//#include "res://formulas/sphairahedrondupef.gdshaderinc" // -@491
//#include "res://formulas/sphairahedrondupeg.gdshaderinc" // -@492
//#include "res://formulas/sphairahedrondupeh.gdshaderinc" // -@493
//#include "res://formulas/sphairahedrondupei.gdshaderinc" // -@494
//#include "res://formulas/sphairahedrondupej.gdshaderinc" // -@495
//#include "res://formulas/sphere.gdshaderinc" // -@496
//#include "res://formulas/spheredupea.gdshaderinc" // -@497
//#include "res://formulas/spheredupeb.gdshaderinc" // -@498
//#include "res://formulas/spheredupec.gdshaderinc" // -@499
//#include "res://formulas/sphereduped.gdshaderinc" // -@500
//#include "res://formulas/spheredupee.gdshaderinc" // -@501
//#include "res://formulas/spheredupef.gdshaderinc" // -@502
//#include "res://formulas/spheredupeg.gdshaderinc" // -@503
//#include "res://formulas/spheredupeh.gdshaderinc" // -@504
//#include "res://formulas/spheredupei.gdshaderinc" // -@505
//#include "res://formulas/spheredupej.gdshaderinc" // -@506
//#include "res://formulas/spheretree.gdshaderinc" // -@507
//#include "res://formulas/spheretreedupea.gdshaderinc" // -@508
//#include "res://formulas/spheretreedupeb.gdshaderinc" // -@509
//#include "res://formulas/spheretreedupec.gdshaderinc" // -@510
//#include "res://formulas/spheretreeduped.gdshaderinc" // -@511
//#include "res://formulas/spheretreedupee.gdshaderinc" // -@512
//#include "res://formulas/spheretreedupef.gdshaderinc" // -@513
//#include "res://formulas/spheretreedupeg.gdshaderinc" // -@514
//#include "res://formulas/spheretreedupeh.gdshaderinc" // -@515
//#include "res://formulas/spheretreedupei.gdshaderinc" // -@516
//#include "res://formulas/spheretreedupej.gdshaderinc" // -@517
//#include "res://formulas/tetrahedron.gdshaderinc" // -@518
//#include "res://formulas/tetrahedrondupea.gdshaderinc" // -@519
//#include "res://formulas/tetrahedrondupeb.gdshaderinc" // -@520
//#include "res://formulas/tetrahedrondupec.gdshaderinc" // -@521
//#include "res://formulas/tetrahedronduped.gdshaderinc" // -@522
//#include "res://formulas/tetrahedrondupee.gdshaderinc" // -@523
//#include "res://formulas/tetrahedrondupef.gdshaderinc" // -@524
//#include "res://formulas/tetrahedrondupeg.gdshaderinc" // -@525
//#include "res://formulas/tetrahedrondupeh.gdshaderinc" // -@526
//#include "res://formulas/tetrahedrondupei.gdshaderinc" // -@527
//#include "res://formulas/tetrahedrondupej.gdshaderinc" // -@528
//#include "res://formulas/triescher.gdshaderinc" // -@529
//#include "res://formulas/triescherdupea.gdshaderinc" // -@530
//#include "res://formulas/triescherdupeb.gdshaderinc" // -@531
//#include "res://formulas/triescherdupec.gdshaderinc" // -@532
//#include "res://formulas/triescherduped.gdshaderinc" // -@533
//#include "res://formulas/triescherdupee.gdshaderinc" // -@534
//#include "res://formulas/triescherdupef.gdshaderinc" // -@535
//#include "res://formulas/triescherdupeg.gdshaderinc" // -@536
//#include "res://formulas/triescherdupeh.gdshaderinc" // -@537
//#include "res://formulas/triescherdupei.gdshaderinc" // -@538
//#include "res://formulas/triescherdupej.gdshaderinc" // -@539
//#include "res://formulas/vicsek.gdshaderinc" // -@540
//#include "res://formulas/vicsekdupea.gdshaderinc" // -@541
//#include "res://formulas/vicsekdupeb.gdshaderinc" // -@542
//#include "res://formulas/vicsekdupec.gdshaderinc" // -@543
//#include "res://formulas/vicsekduped.gdshaderinc" // -@544
//#include "res://formulas/vicsekdupee.gdshaderinc" // -@545
//#include "res://formulas/vicsekdupef.gdshaderinc" // -@546
//#include "res://formulas/vicsekdupeg.gdshaderinc" // -@547
//#include "res://formulas/vicsekdupeh.gdshaderinc" // -@548
//#include "res://formulas/vicsekdupei.gdshaderinc" // -@549
//#include "res://formulas/vicsekdupej.gdshaderinc" // -@550
//#include "res://formulas/wavysponge.gdshaderinc" // -@551
//#include "res://formulas/wavyspongedupea.gdshaderinc" // -@552
//#include "res://formulas/wavyspongedupeb.gdshaderinc" // -@553
//#include "res://formulas/wavyspongedupec.gdshaderinc" // -@554
//#include "res://formulas/wavyspongeduped.gdshaderinc" // -@555
//#include "res://formulas/wavyspongedupee.gdshaderinc" // -@556
//#include "res://formulas/wavyspongedupef.gdshaderinc" // -@557
//#include "res://formulas/wavyspongedupeg.gdshaderinc" // -@558
//#include "res://formulas/wavyspongedupeh.gdshaderinc" // -@559
//#include "res://formulas/wavyspongedupei.gdshaderinc" // -@560
//#include "res://formulas/wavyspongedupej.gdshaderinc" // -@561
//#include "res://formulas/wobbletransform.gdshaderinc" // -@562
//#include "res://formulas/wobbletransformdupea.gdshaderinc" // -@563
//#include "res://formulas/wobbletransformdupeb.gdshaderinc" // -@564
//#include "res://formulas/wobbletransformdupec.gdshaderinc" // -@565
//#include "res://formulas/wobbletransformduped.gdshaderinc" // -@566
//#include "res://formulas/wobbletransformdupee.gdshaderinc" // -@567
//#include "res://formulas/wobbletransformdupef.gdshaderinc" // -@568
//#include "res://formulas/wobbletransformdupeg.gdshaderinc" // -@569
//#include "res://formulas/wobbletransformdupeh.gdshaderinc" // -@570
//#include "res://formulas/wobbletransformdupei.gdshaderinc" // -@571
//#include "res://formulas/wobbletransformdupej.gdshaderinc" // -@572

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
if (current_formula == 12) bairddelta_iter(z, dz, original_z, orbit, i); //-@12
//if (current_formula == 13) bairddeltadupea_iter(z, dz, original_z, orbit, i); //-@13
//if (current_formula == 14) bairddeltadupeb_iter(z, dz, original_z, orbit, i); //-@14
//if (current_formula == 15) bairddeltadupec_iter(z, dz, original_z, orbit, i); //-@15
//if (current_formula == 16) bairddeltaduped_iter(z, dz, original_z, orbit, i); //-@16
//if (current_formula == 17) bairddeltadupee_iter(z, dz, original_z, orbit, i); //-@17
//if (current_formula == 18) bairddeltadupef_iter(z, dz, original_z, orbit, i); //-@18
//if (current_formula == 19) bairddeltadupeg_iter(z, dz, original_z, orbit, i); //-@19
//if (current_formula == 20) bairddeltadupeh_iter(z, dz, original_z, orbit, i); //-@20
//if (current_formula == 21) bairddeltadupei_iter(z, dz, original_z, orbit, i); //-@21
//if (current_formula == 22) bairddeltadupej_iter(z, dz, original_z, orbit, i); //-@22
//if (current_formula == 23) basictransform_iter(z, dz, original_z, orbit, i); //-@23
//if (current_formula == 24) basictransformdupea_iter(z, dz, original_z, orbit, i); //-@24
//if (current_formula == 25) basictransformdupeb_iter(z, dz, original_z, orbit, i); //-@25
//if (current_formula == 26) basictransformdupec_iter(z, dz, original_z, orbit, i); //-@26
//if (current_formula == 27) basictransformduped_iter(z, dz, original_z, orbit, i); //-@27
//if (current_formula == 28) basictransformdupee_iter(z, dz, original_z, orbit, i); //-@28
//if (current_formula == 29) basictransformdupef_iter(z, dz, original_z, orbit, i); //-@29
//if (current_formula == 30) basictransformdupeg_iter(z, dz, original_z, orbit, i); //-@30
//if (current_formula == 31) basictransformdupeh_iter(z, dz, original_z, orbit, i); //-@31
//if (current_formula == 32) basictransformdupei_iter(z, dz, original_z, orbit, i); //-@32
//if (current_formula == 33) basictransformdupej_iter(z, dz, original_z, orbit, i); //-@33
//if (current_formula == 34) benesiship_iter(z, dz, original_z, orbit, i); //-@34
//if (current_formula == 35) benesishipdupea_iter(z, dz, original_z, orbit, i); //-@35
//if (current_formula == 36) benesishipdupeb_iter(z, dz, original_z, orbit, i); //-@36
//if (current_formula == 37) benesishipdupec_iter(z, dz, original_z, orbit, i); //-@37
//if (current_formula == 38) benesishipduped_iter(z, dz, original_z, orbit, i); //-@38
//if (current_formula == 39) benesishipdupee_iter(z, dz, original_z, orbit, i); //-@39
//if (current_formula == 40) benesishipdupef_iter(z, dz, original_z, orbit, i); //-@40
//if (current_formula == 41) benesishipdupeg_iter(z, dz, original_z, orbit, i); //-@41
//if (current_formula == 42) benesishipdupeh_iter(z, dz, original_z, orbit, i); //-@42
//if (current_formula == 43) benesishipdupei_iter(z, dz, original_z, orbit, i); //-@43
//if (current_formula == 44) benesishipdupej_iter(z, dz, original_z, orbit, i); //-@44
//if (current_formula == 45) bristorbrot_iter(z, dz, original_z, orbit, i); //-@45
//if (current_formula == 46) bristorbrotdupea_iter(z, dz, original_z, orbit, i); //-@46
//if (current_formula == 47) bristorbrotdupeb_iter(z, dz, original_z, orbit, i); //-@47
//if (current_formula == 48) bristorbrotdupec_iter(z, dz, original_z, orbit, i); //-@48
//if (current_formula == 49) bristorbrotduped_iter(z, dz, original_z, orbit, i); //-@49
//if (current_formula == 50) bristorbrotdupee_iter(z, dz, original_z, orbit, i); //-@50
//if (current_formula == 51) bristorbrotdupef_iter(z, dz, original_z, orbit, i); //-@51
//if (current_formula == 52) bristorbrotdupeg_iter(z, dz, original_z, orbit, i); //-@52
//if (current_formula == 53) bristorbrotdupeh_iter(z, dz, original_z, orbit, i); //-@53
//if (current_formula == 54) bristorbrotdupei_iter(z, dz, original_z, orbit, i); //-@54
//if (current_formula == 55) bristorbrotdupej_iter(z, dz, original_z, orbit, i); //-@55
//if (current_formula == 89) gemstone_iter(z, dz, original_z, orbit, i); //-@89
//if (current_formula == 90) gemstonedupea_iter(z, dz, original_z, orbit, i); //-@90
//if (current_formula == 91) gemstonedupeb_iter(z, dz, original_z, orbit, i); //-@91
//if (current_formula == 92) gemstonedupec_iter(z, dz, original_z, orbit, i); //-@92
//if (current_formula == 93) gemstoneduped_iter(z, dz, original_z, orbit, i); //-@93
//if (current_formula == 94) gemstonedupee_iter(z, dz, original_z, orbit, i); //-@94
//if (current_formula == 95) gemstonedupef_iter(z, dz, original_z, orbit, i); //-@95
//if (current_formula == 96) gemstonedupeg_iter(z, dz, original_z, orbit, i); //-@96
//if (current_formula == 97) gemstonedupeh_iter(z, dz, original_z, orbit, i); //-@97
//if (current_formula == 98) gemstonedupei_iter(z, dz, original_z, orbit, i); //-@98
//if (current_formula == 99) gemstonedupej_iter(z, dz, original_z, orbit, i); //-@99
//if (current_formula == 144) inversiontransform_iter(z, dz, original_z, orbit, i); //-@144
//if (current_formula == 145) inversiontransformdupea_iter(z, dz, original_z, orbit, i); //-@145
//if (current_formula == 146) inversiontransformdupeb_iter(z, dz, original_z, orbit, i); //-@146
//if (current_formula == 147) inversiontransformdupec_iter(z, dz, original_z, orbit, i); //-@147
//if (current_formula == 148) inversiontransformduped_iter(z, dz, original_z, orbit, i); //-@148
//if (current_formula == 149) inversiontransformdupee_iter(z, dz, original_z, orbit, i); //-@149
//if (current_formula == 150) inversiontransformdupef_iter(z, dz, original_z, orbit, i); //-@150
//if (current_formula == 151) inversiontransformdupeg_iter(z, dz, original_z, orbit, i); //-@151
//if (current_formula == 152) inversiontransformdupeh_iter(z, dz, original_z, orbit, i); //-@152
//if (current_formula == 153) inversiontransformdupei_iter(z, dz, original_z, orbit, i); //-@153
//if (current_formula == 154) inversiontransformdupej_iter(z, dz, original_z, orbit, i); //-@154
//if (current_formula == 155) jerusalemcube_iter(z, dz, original_z, orbit, i); //-@155
//if (current_formula == 156) jerusalemcubedupea_iter(z, dz, original_z, orbit, i); //-@156
//if (current_formula == 157) jerusalemcubedupeb_iter(z, dz, original_z, orbit, i); //-@157
//if (current_formula == 158) jerusalemcubedupec_iter(z, dz, original_z, orbit, i); //-@158
//if (current_formula == 159) jerusalemcubeduped_iter(z, dz, original_z, orbit, i); //-@159
//if (current_formula == 160) jerusalemcubedupee_iter(z, dz, original_z, orbit, i); //-@160
//if (current_formula == 161) jerusalemcubedupef_iter(z, dz, original_z, orbit, i); //-@161
//if (current_formula == 162) jerusalemcubedupeg_iter(z, dz, original_z, orbit, i); //-@162
//if (current_formula == 163) jerusalemcubedupeh_iter(z, dz, original_z, orbit, i); //-@163
//if (current_formula == 164) jerusalemcubedupei_iter(z, dz, original_z, orbit, i); //-@164
//if (current_formula == 165) jerusalemcubedupej_iter(z, dz, original_z, orbit, i); //-@165
//if (current_formula == 166) kalaidotransform_iter(z, dz, original_z, orbit, i); //-@166
//if (current_formula == 167) kalaidotransformdupea_iter(z, dz, original_z, orbit, i); //-@167
//if (current_formula == 168) kalaidotransformdupeb_iter(z, dz, original_z, orbit, i); //-@168
//if (current_formula == 169) kalaidotransformdupec_iter(z, dz, original_z, orbit, i); //-@169
//if (current_formula == 170) kalaidotransformduped_iter(z, dz, original_z, orbit, i); //-@170
//if (current_formula == 171) kalaidotransformdupee_iter(z, dz, original_z, orbit, i); //-@171
//if (current_formula == 172) kalaidotransformdupef_iter(z, dz, original_z, orbit, i); //-@172
//if (current_formula == 173) kalaidotransformdupeg_iter(z, dz, original_z, orbit, i); //-@173
//if (current_formula == 174) kalaidotransformdupeh_iter(z, dz, original_z, orbit, i); //-@174
//if (current_formula == 175) kalaidotransformdupei_iter(z, dz, original_z, orbit, i); //-@175
//if (current_formula == 176) kalaidotransformdupej_iter(z, dz, original_z, orbit, i); //-@176
//if (current_formula == 177) kalibox_iter(z, dz, original_z, orbit, i); //-@177
//if (current_formula == 178) kaliboxdupea_iter(z, dz, original_z, orbit, i); //-@178
//if (current_formula == 179) kaliboxdupeb_iter(z, dz, original_z, orbit, i); //-@179
//if (current_formula == 180) kaliboxdupec_iter(z, dz, original_z, orbit, i); //-@180
//if (current_formula == 181) kaliboxduped_iter(z, dz, original_z, orbit, i); //-@181
//if (current_formula == 182) kaliboxdupee_iter(z, dz, original_z, orbit, i); //-@182
//if (current_formula == 183) kaliboxdupef_iter(z, dz, original_z, orbit, i); //-@183
//if (current_formula == 184) kaliboxdupeg_iter(z, dz, original_z, orbit, i); //-@184
//if (current_formula == 185) kaliboxdupeh_iter(z, dz, original_z, orbit, i); //-@185
//if (current_formula == 186) kaliboxdupei_iter(z, dz, original_z, orbit, i); //-@186
//if (current_formula == 187) kaliboxdupej_iter(z, dz, original_z, orbit, i); //-@187
//if (current_formula == 188) kaliliving_iter(z, dz, original_z, orbit, i); //-@188
//if (current_formula == 189) kalilivingdupea_iter(z, dz, original_z, orbit, i); //-@189
//if (current_formula == 190) kalilivingdupeb_iter(z, dz, original_z, orbit, i); //-@190
//if (current_formula == 191) kalilivingdupec_iter(z, dz, original_z, orbit, i); //-@191
//if (current_formula == 192) kalilivingduped_iter(z, dz, original_z, orbit, i); //-@192
//if (current_formula == 193) kalilivingdupee_iter(z, dz, original_z, orbit, i); //-@193
//if (current_formula == 194) kalilivingdupef_iter(z, dz, original_z, orbit, i); //-@194
//if (current_formula == 195) kalilivingdupeg_iter(z, dz, original_z, orbit, i); //-@195
//if (current_formula == 196) kalilivingdupeh_iter(z, dz, original_z, orbit, i); //-@196
//if (current_formula == 197) kalilivingdupei_iter(z, dz, original_z, orbit, i); //-@197
//if (current_formula == 198) kalilivingdupej_iter(z, dz, original_z, orbit, i); //-@198
//if (current_formula == 199) kaliredux_iter(z, dz, original_z, orbit, i); //-@199
//if (current_formula == 200) kalireduxdupea_iter(z, dz, original_z, orbit, i); //-@200
//if (current_formula == 201) kalireduxdupeb_iter(z, dz, original_z, orbit, i); //-@201
//if (current_formula == 202) kalireduxdupec_iter(z, dz, original_z, orbit, i); //-@202
//if (current_formula == 203) kalireduxduped_iter(z, dz, original_z, orbit, i); //-@203
//if (current_formula == 204) kalireduxdupee_iter(z, dz, original_z, orbit, i); //-@204
//if (current_formula == 205) kalireduxdupef_iter(z, dz, original_z, orbit, i); //-@205
//if (current_formula == 206) kalireduxdupeg_iter(z, dz, original_z, orbit, i); //-@206
//if (current_formula == 207) kalireduxdupeh_iter(z, dz, original_z, orbit, i); //-@207
//if (current_formula == 208) kalireduxdupei_iter(z, dz, original_z, orbit, i); //-@208
//if (current_formula == 209) kalireduxdupej_iter(z, dz, original_z, orbit, i); //-@209
//if (current_formula == 221) kochcube_iter(z, dz, original_z, orbit, i, s); //-@221
//if (current_formula == 222) kochcubedupea_iter(z, dz, original_z, orbit, i); //-@222
//if (current_formula == 223) kochcubedupeb_iter(z, dz, original_z, orbit, i); //-@223
//if (current_formula == 224) kochcubedupec_iter(z, dz, original_z, orbit, i); //-@224
//if (current_formula == 225) kochcubeduped_iter(z, dz, original_z, orbit, i); //-@225
//if (current_formula == 226) kochcubedupee_iter(z, dz, original_z, orbit, i); //-@226
//if (current_formula == 227) kochcubedupef_iter(z, dz, original_z, orbit, i); //-@227
//if (current_formula == 228) kochcubedupeg_iter(z, dz, original_z, orbit, i); //-@228
//if (current_formula == 229) kochcubedupeh_iter(z, dz, original_z, orbit, i); //-@229
//if (current_formula == 230) kochcubedupei_iter(z, dz, original_z, orbit, i); //-@230
//if (current_formula == 231) kochcubedupej_iter(z, dz, original_z, orbit, i); //-@231
//if (current_formula == 232) kochwire_iter(z, dz, original_z, orbit, i); //-@232
//if (current_formula == 233) kochwiredupea_iter(z, dz, original_z, orbit, i); //-@233
//if (current_formula == 234) kochwiredupeb_iter(z, dz, original_z, orbit, i); //-@234
//if (current_formula == 235) kochwiredupec_iter(z, dz, original_z, orbit, i); //-@235
//if (current_formula == 236) kochwireduped_iter(z, dz, original_z, orbit, i); //-@236
//if (current_formula == 237) kochwiredupee_iter(z, dz, original_z, orbit, i); //-@237
//if (current_formula == 238) kochwiredupef_iter(z, dz, original_z, orbit, i); //-@238
//if (current_formula == 239) kochwiredupeg_iter(z, dz, original_z, orbit, i); //-@239
//if (current_formula == 240) kochwiredupeh_iter(z, dz, original_z, orbit, i); //-@240
//if (current_formula == 241) kochwiredupei_iter(z, dz, original_z, orbit, i); //-@241
//if (current_formula == 242) kochwiredupej_iter(z, dz, original_z, orbit, i); //-@242
//if (current_formula == 243) lionbulb_iter(z, dz, original_z, orbit, i); //-@243
//if (current_formula == 244) lionbulbdupea_iter(z, dz, original_z, orbit, i); //-@244
//if (current_formula == 245) lionbulbdupeb_iter(z, dz, original_z, orbit, i); //-@245
//if (current_formula == 246) lionbulbdupec_iter(z, dz, original_z, orbit, i); //-@246
//if (current_formula == 247) lionbulbduped_iter(z, dz, original_z, orbit, i); //-@247
//if (current_formula == 248) lionbulbdupee_iter(z, dz, original_z, orbit, i); //-@248
//if (current_formula == 249) lionbulbdupef_iter(z, dz, original_z, orbit, i); //-@249
//if (current_formula == 250) lionbulbdupeg_iter(z, dz, original_z, orbit, i); //-@250
//if (current_formula == 251) lionbulbdupeh_iter(z, dz, original_z, orbit, i); //-@251
//if (current_formula == 252) lionbulbdupei_iter(z, dz, original_z, orbit, i); //-@252
//if (current_formula == 253) lionbulbdupej_iter(z, dz, original_z, orbit, i); //-@253
//if (current_formula == 254) logtransform_iter(z, dz, original_z, orbit, i); //-@254
//if (current_formula == 255) logtransformdupea_iter(z, dz, original_z, orbit, i); //-@255
//if (current_formula == 256) logtransformdupeb_iter(z, dz, original_z, orbit, i); //-@256
//if (current_formula == 257) logtransformdupec_iter(z, dz, original_z, orbit, i); //-@257
//if (current_formula == 258) logtransformduped_iter(z, dz, original_z, orbit, i); //-@258
//if (current_formula == 259) logtransformdupee_iter(z, dz, original_z, orbit, i); //-@259
//if (current_formula == 260) logtransformdupef_iter(z, dz, original_z, orbit, i); //-@260
//if (current_formula == 261) logtransformdupeg_iter(z, dz, original_z, orbit, i); //-@261
//if (current_formula == 262) logtransformdupeh_iter(z, dz, original_z, orbit, i); //-@262
//if (current_formula == 263) logtransformdupei_iter(z, dz, original_z, orbit, i); //-@263
//if (current_formula == 264) logtransformdupej_iter(z, dz, original_z, orbit, i); //-@264
//if (current_formula == 265) mandelbox_iter(z, dz, original_z, orbit, i); //-@265
//if (current_formula == 266) mandelboxdupea_iter(z, dz, original_z, orbit, i); //-@266
//if (current_formula == 267) mandelboxdupeb_iter(z, dz, original_z, orbit, i); //-@267
//if (current_formula == 268) mandelboxdupec_iter(z, dz, original_z, orbit, i); //-@268
//if (current_formula == 269) mandelboxduped_iter(z, dz, original_z, orbit, i); //-@269
//if (current_formula == 270) mandelboxdupee_iter(z, dz, original_z, orbit, i); //-@270
//if (current_formula == 271) mandelboxdupef_iter(z, dz, original_z, orbit, i); //-@271
//if (current_formula == 272) mandelboxdupeg_iter(z, dz, original_z, orbit, i); //-@272
//if (current_formula == 273) mandelboxdupeh_iter(z, dz, original_z, orbit, i); //-@273
//if (current_formula == 274) mandelboxdupei_iter(z, dz, original_z, orbit, i); //-@274
//if (current_formula == 275) mandelboxdupej_iter(z, dz, original_z, orbit, i); //-@275
//if (current_formula == 276) mandelbulb_iter(z, dz, original_z, orbit, i); //-@276
//if (current_formula == 277) mandelbulbdupea_iter(z, dz, original_z, orbit, i); //-@277
//if (current_formula == 278) mandelbulbdupeb_iter(z, dz, original_z, orbit, i); //-@278
//if (current_formula == 279) mandelbulbdupec_iter(z, dz, original_z, orbit, i); //-@279
//if (current_formula == 280) mandelbulbduped_iter(z, dz, original_z, orbit, i); //-@280
//if (current_formula == 281) mandelbulbdupee_iter(z, dz, original_z, orbit, i); //-@281
//if (current_formula == 282) mandelbulbdupef_iter(z, dz, original_z, orbit, i); //-@282
//if (current_formula == 283) mandelbulbdupeg_iter(z, dz, original_z, orbit, i); //-@283
//if (current_formula == 284) mandelbulbdupeh_iter(z, dz, original_z, orbit, i); //-@284
//if (current_formula == 285) mandelbulbdupei_iter(z, dz, original_z, orbit, i); //-@285
//if (current_formula == 286) mandelbulbdupej_iter(z, dz, original_z, orbit, i); //-@286
//if (current_formula == 287) mandelettuce_iter(z, dz, original_z, orbit, i); //-@287
//if (current_formula == 288) mandelettucedupea_iter(z, dz, original_z, orbit, i); //-@288
//if (current_formula == 289) mandelettucedupeb_iter(z, dz, original_z, orbit, i); //-@289
//if (current_formula == 290) mandelettucedupec_iter(z, dz, original_z, orbit, i); //-@290
//if (current_formula == 291) mandelettuceduped_iter(z, dz, original_z, orbit, i); //-@291
//if (current_formula == 292) mandelettucedupee_iter(z, dz, original_z, orbit, i); //-@292
//if (current_formula == 293) mandelettucedupef_iter(z, dz, original_z, orbit, i); //-@293
//if (current_formula == 294) mandelettucedupeg_iter(z, dz, original_z, orbit, i); //-@294
//if (current_formula == 295) mandelettucedupeh_iter(z, dz, original_z, orbit, i); //-@295
//if (current_formula == 296) mandelettucedupei_iter(z, dz, original_z, orbit, i); //-@296
//if (current_formula == 297) mandelettucedupej_iter(z, dz, original_z, orbit, i); //-@297
//if (current_formula == 298) melttransform_iter(z, dz, original_z, orbit, i); //-@298
//if (current_formula == 299) melttransformdupea_iter(z, dz, original_z, orbit, i); //-@299
//if (current_formula == 300) melttransformdupeb_iter(z, dz, original_z, orbit, i); //-@300
//if (current_formula == 301) melttransformdupec_iter(z, dz, original_z, orbit, i); //-@301
//if (current_formula == 302) melttransformduped_iter(z, dz, original_z, orbit, i); //-@302
//if (current_formula == 303) melttransformdupee_iter(z, dz, original_z, orbit, i); //-@303
//if (current_formula == 304) melttransformdupef_iter(z, dz, original_z, orbit, i); //-@304
//if (current_formula == 305) melttransformdupeg_iter(z, dz, original_z, orbit, i); //-@305
//if (current_formula == 306) melttransformdupeh_iter(z, dz, original_z, orbit, i); //-@306
//if (current_formula == 307) melttransformdupei_iter(z, dz, original_z, orbit, i); //-@307
//if (current_formula == 308) melttransformdupej_iter(z, dz, original_z, orbit, i); //-@308
//if (current_formula == 309) mengersponge_iter(z, dz, original_z, orbit, i); //-@309
//if (current_formula == 310) mengerspongedupea_iter(z, dz, original_z, orbit, i); //-@310
//if (current_formula == 311) mengerspongedupeb_iter(z, dz, original_z, orbit, i); //-@311
//if (current_formula == 312) mengerspongedupec_iter(z, dz, original_z, orbit, i); //-@312
//if (current_formula == 313) mengerspongeduped_iter(z, dz, original_z, orbit, i); //-@313
//if (current_formula == 314) mengerspongedupee_iter(z, dz, original_z, orbit, i); //-@314
//if (current_formula == 315) mengerspongedupef_iter(z, dz, original_z, orbit, i); //-@315
//if (current_formula == 316) mengerspongedupeg_iter(z, dz, original_z, orbit, i); //-@316
//if (current_formula == 317) mengerspongedupeh_iter(z, dz, original_z, orbit, i); //-@317
//if (current_formula == 318) mengerspongedupei_iter(z, dz, original_z, orbit, i); //-@318
//if (current_formula == 319) mengerspongedupej_iter(z, dz, original_z, orbit, i); //-@319
//if (current_formula == 320) mixpinski4d_iter(z, dz, original_z, orbit, i); //-@320
//if (current_formula == 321) mixpinski4ddupea_iter(z, dz, original_z, orbit, i); //-@321
//if (current_formula == 322) mixpinski4ddupeb_iter(z, dz, original_z, orbit, i); //-@322
//if (current_formula == 323) mixpinski4ddupec_iter(z, dz, original_z, orbit, i); //-@323
//if (current_formula == 324) mixpinski4dduped_iter(z, dz, original_z, orbit, i); //-@324
//if (current_formula == 325) mixpinski4ddupee_iter(z, dz, original_z, orbit, i); //-@325
//if (current_formula == 326) mixpinski4ddupef_iter(z, dz, original_z, orbit, i); //-@326
//if (current_formula == 327) mixpinski4ddupeg_iter(z, dz, original_z, orbit, i); //-@327
//if (current_formula == 328) mixpinski4ddupeh_iter(z, dz, original_z, orbit, i); //-@328
//if (current_formula == 329) mixpinski4ddupei_iter(z, dz, original_z, orbit, i); //-@329
//if (current_formula == 330) mixpinski4ddupej_iter(z, dz, original_z, orbit, i); //-@330
//if (current_formula == 353) octkoch_iter(z, dz, original_z, orbit, i); //-@353
//if (current_formula == 354) octkochdupea_iter(z, dz, original_z, orbit, i); //-@354
//if (current_formula == 355) octkochdupeb_iter(z, dz, original_z, orbit, i); //-@355
//if (current_formula == 356) octkochdupec_iter(z, dz, original_z, orbit, i); //-@356
//if (current_formula == 357) octkochduped_iter(z, dz, original_z, orbit, i); //-@357
//if (current_formula == 358) octkochdupee_iter(z, dz, original_z, orbit, i); //-@358
//if (current_formula == 359) octkochdupef_iter(z, dz, original_z, orbit, i); //-@359
//if (current_formula == 360) octkochdupeg_iter(z, dz, original_z, orbit, i); //-@360
//if (current_formula == 361) octkochdupeh_iter(z, dz, original_z, orbit, i); //-@361
//if (current_formula == 362) octkochdupei_iter(z, dz, original_z, orbit, i); //-@362
//if (current_formula == 363) octkochdupej_iter(z, dz, original_z, orbit, i); //-@363
//if (current_formula == 375) platonickoch_iter(z, dz, original_z, orbit, i); //-@375
//if (current_formula == 376) platonickochdupea_iter(z, dz, original_z, orbit, i); //-@376
//if (current_formula == 377) platonickochdupeb_iter(z, dz, original_z, orbit, i); //-@377
//if (current_formula == 378) platonickochdupec_iter(z, dz, original_z, orbit, i); //-@378
//if (current_formula == 379) platonickochduped_iter(z, dz, original_z, orbit, i); //-@379
//if (current_formula == 380) platonickochdupee_iter(z, dz, original_z, orbit, i); //-@380
//if (current_formula == 381) platonickochdupef_iter(z, dz, original_z, orbit, i); //-@381
//if (current_formula == 382) platonickochdupeg_iter(z, dz, original_z, orbit, i); //-@382
//if (current_formula == 383) platonickochdupeh_iter(z, dz, original_z, orbit, i); //-@383
//if (current_formula == 384) platonickochdupei_iter(z, dz, original_z, orbit, i); //-@384
//if (current_formula == 385) platonickochdupej_iter(z, dz, original_z, orbit, i); //-@385
//if (current_formula == 386) pseudoklenian_iter(z, dz, original_z, orbit, i); //-@386
//if (current_formula == 387) pseudokleniandupea_iter(z, dz, original_z, orbit, i); //-@387
//if (current_formula == 388) pseudokleniandupeb_iter(z, dz, original_z, orbit, i); //-@388
//if (current_formula == 389) pseudokleniandupec_iter(z, dz, original_z, orbit, i); //-@389
//if (current_formula == 390) pseudoklenianduped_iter(z, dz, original_z, orbit, i); //-@390
//if (current_formula == 391) pseudokleniandupee_iter(z, dz, original_z, orbit, i); //-@391
//if (current_formula == 392) pseudokleniandupef_iter(z, dz, original_z, orbit, i); //-@392
//if (current_formula == 393) pseudokleniandupeg_iter(z, dz, original_z, orbit, i); //-@393
//if (current_formula == 394) pseudokleniandupeh_iter(z, dz, original_z, orbit, i); //-@394
//if (current_formula == 395) pseudokleniandupei_iter(z, dz, original_z, orbit, i); //-@395
//if (current_formula == 396) pseudokleniandupej_iter(z, dz, original_z, orbit, i); //-@396
//if (current_formula == 397) quadratickoch_iter(z, dz, original_z, orbit, i); //-@397
//if (current_formula == 398) quadratickochdupea_iter(z, dz, original_z, orbit, i); //-@398
//if (current_formula == 399) quadratickochdupeb_iter(z, dz, original_z, orbit, i); //-@399
//if (current_formula == 400) quadratickochdupec_iter(z, dz, original_z, orbit, i); //-@400
//if (current_formula == 401) quadratickochduped_iter(z, dz, original_z, orbit, i); //-@401
//if (current_formula == 402) quadratickochdupee_iter(z, dz, original_z, orbit, i); //-@402
//if (current_formula == 403) quadratickochdupef_iter(z, dz, original_z, orbit, i); //-@403
//if (current_formula == 404) quadratickochdupeg_iter(z, dz, original_z, orbit, i); //-@404
//if (current_formula == 405) quadratickochdupeh_iter(z, dz, original_z, orbit, i); //-@405
//if (current_formula == 406) quadratickochdupei_iter(z, dz, original_z, orbit, i); //-@406
//if (current_formula == 407) quadratickochdupej_iter(z, dz, original_z, orbit, i); //-@407
//if (current_formula == 408) reciprocaltransform_iter(z, dz, original_z, orbit, i); //-@408
//if (current_formula == 409) reciprocaltransformdupea_iter(z, dz, original_z, orbit, i); //-@409
//if (current_formula == 410) reciprocaltransformdupeb_iter(z, dz, original_z, orbit, i); //-@410
//if (current_formula == 411) reciprocaltransformdupec_iter(z, dz, original_z, orbit, i); //-@411
//if (current_formula == 412) reciprocaltransformduped_iter(z, dz, original_z, orbit, i); //-@412
//if (current_formula == 413) reciprocaltransformdupee_iter(z, dz, original_z, orbit, i); //-@413
//if (current_formula == 414) reciprocaltransformdupef_iter(z, dz, original_z, orbit, i); //-@414
//if (current_formula == 415) reciprocaltransformdupeg_iter(z, dz, original_z, orbit, i); //-@415
//if (current_formula == 416) reciprocaltransformdupeh_iter(z, dz, original_z, orbit, i); //-@416
//if (current_formula == 417) reciprocaltransformdupei_iter(z, dz, original_z, orbit, i); //-@417
//if (current_formula == 418) reciprocaltransformdupej_iter(z, dz, original_z, orbit, i); //-@418
//if (current_formula == 430) sierpinskidodecahedron_iter(z, dz, original_z, orbit, i); //-@430
//if (current_formula == 431) sierpinskidodecahedrondupea_iter(z, dz, original_z, orbit, i); //-@431
//if (current_formula == 432) sierpinskidodecahedrondupeb_iter(z, dz, original_z, orbit, i); //-@432
//if (current_formula == 433) sierpinskidodecahedrondupec_iter(z, dz, original_z, orbit, i); //-@433
//if (current_formula == 434) sierpinskidodecahedronduped_iter(z, dz, original_z, orbit, i); //-@434
//if (current_formula == 435) sierpinskidodecahedrondupee_iter(z, dz, original_z, orbit, i); //-@435
//if (current_formula == 436) sierpinskidodecahedrondupef_iter(z, dz, original_z, orbit, i); //-@436
//if (current_formula == 437) sierpinskidodecahedrondupeg_iter(z, dz, original_z, orbit, i); //-@437
//if (current_formula == 438) sierpinskidodecahedrondupeh_iter(z, dz, original_z, orbit, i); //-@438
//if (current_formula == 439) sierpinskidodecahedrondupei_iter(z, dz, original_z, orbit, i); //-@439
//if (current_formula == 440) sierpinskidodecahedrondupej_iter(z, dz, original_z, orbit, i); //-@440
//if (current_formula == 441) sierpinskiicosahedron_iter(z, dz, original_z, orbit, i); //-@441
//if (current_formula == 442) sierpinskiicosahedrondupea_iter(z, dz, original_z, orbit, i); //-@442
//if (current_formula == 443) sierpinskiicosahedrondupeb_iter(z, dz, original_z, orbit, i); //-@443
//if (current_formula == 444) sierpinskiicosahedrondupec_iter(z, dz, original_z, orbit, i); //-@444
//if (current_formula == 445) sierpinskiicosahedronduped_iter(z, dz, original_z, orbit, i); //-@445
//if (current_formula == 446) sierpinskiicosahedrondupee_iter(z, dz, original_z, orbit, i); //-@446
//if (current_formula == 447) sierpinskiicosahedrondupef_iter(z, dz, original_z, orbit, i); //-@447
//if (current_formula == 448) sierpinskiicosahedrondupeg_iter(z, dz, original_z, orbit, i); //-@448
//if (current_formula == 449) sierpinskiicosahedrondupeh_iter(z, dz, original_z, orbit, i); //-@449
//if (current_formula == 450) sierpinskiicosahedrondupei_iter(z, dz, original_z, orbit, i); //-@450
//if (current_formula == 451) sierpinskiicosahedrondupej_iter(z, dz, original_z, orbit, i); //-@451
//if (current_formula == 452) sierpinskioctahedron_iter(z, dz, original_z, orbit, i); //-@452
//if (current_formula == 453) sierpinskioctahedrondupea_iter(z, dz, original_z, orbit, i); //-@453
//if (current_formula == 454) sierpinskioctahedrondupeb_iter(z, dz, original_z, orbit, i); //-@454
//if (current_formula == 455) sierpinskioctahedrondupec_iter(z, dz, original_z, orbit, i); //-@455
//if (current_formula == 456) sierpinskioctahedronduped_iter(z, dz, original_z, orbit, i); //-@456
//if (current_formula == 457) sierpinskioctahedrondupee_iter(z, dz, original_z, orbit, i); //-@457
//if (current_formula == 458) sierpinskioctahedrondupef_iter(z, dz, original_z, orbit, i); //-@458
//if (current_formula == 459) sierpinskioctahedrondupeg_iter(z, dz, original_z, orbit, i); //-@459
//if (current_formula == 460) sierpinskioctahedrondupeh_iter(z, dz, original_z, orbit, i); //-@460
//if (current_formula == 461) sierpinskioctahedrondupei_iter(z, dz, original_z, orbit, i); //-@461
//if (current_formula == 462) sierpinskioctahedrondupej_iter(z, dz, original_z, orbit, i); //-@462
//if (current_formula == 463) sierpinskitetrahedron_iter(z, dz, original_z, orbit, i); //-@463
//if (current_formula == 464) sierpinskitetrahedrondupea_iter(z, dz, original_z, orbit, i); //-@464
//if (current_formula == 465) sierpinskitetrahedrondupeb_iter(z, dz, original_z, orbit, i); //-@465
//if (current_formula == 466) sierpinskitetrahedrondupec_iter(z, dz, original_z, orbit, i); //-@466
//if (current_formula == 467) sierpinskitetrahedronduped_iter(z, dz, original_z, orbit, i); //-@467
//if (current_formula == 468) sierpinskitetrahedrondupee_iter(z, dz, original_z, orbit, i); //-@468
//if (current_formula == 469) sierpinskitetrahedrondupef_iter(z, dz, original_z, orbit, i); //-@469
//if (current_formula == 470) sierpinskitetrahedrondupeg_iter(z, dz, original_z, orbit, i); //-@470
//if (current_formula == 471) sierpinskitetrahedrondupeh_iter(z, dz, original_z, orbit, i); //-@471
//if (current_formula == 472) sierpinskitetrahedrondupei_iter(z, dz, original_z, orbit, i); //-@472
//if (current_formula == 473) sierpinskitetrahedrondupej_iter(z, dz, original_z, orbit, i); //-@473
//if (current_formula == 474) sintransform_iter(z, dz, original_z, orbit, i); //-@474
//if (current_formula == 475) sintransformdupea_iter(z, dz, original_z, orbit, i); //-@475
//if (current_formula == 476) sintransformdupeb_iter(z, dz, original_z, orbit, i); //-@476
//if (current_formula == 477) sintransformdupec_iter(z, dz, original_z, orbit, i); //-@477
//if (current_formula == 478) sintransformduped_iter(z, dz, original_z, orbit, i); //-@478
//if (current_formula == 479) sintransformdupee_iter(z, dz, original_z, orbit, i); //-@479
//if (current_formula == 480) sintransformdupef_iter(z, dz, original_z, orbit, i); //-@480
//if (current_formula == 481) sintransformdupeg_iter(z, dz, original_z, orbit, i); //-@481
//if (current_formula == 482) sintransformdupeh_iter(z, dz, original_z, orbit, i); //-@482
//if (current_formula == 483) sintransformdupei_iter(z, dz, original_z, orbit, i); //-@483
//if (current_formula == 484) sintransformdupej_iter(z, dz, original_z, orbit, i); //-@484
//if (current_formula == 529) triescher_iter(z, dz, original_z, orbit, i); //-@529
//if (current_formula == 530) triescherdupea_iter(z, dz, original_z, orbit, i); //-@530
//if (current_formula == 531) triescherdupeb_iter(z, dz, original_z, orbit, i); //-@531
//if (current_formula == 532) triescherdupec_iter(z, dz, original_z, orbit, i); //-@532
//if (current_formula == 533) triescherduped_iter(z, dz, original_z, orbit, i); //-@533
//if (current_formula == 534) triescherdupee_iter(z, dz, original_z, orbit, i); //-@534
//if (current_formula == 535) triescherdupef_iter(z, dz, original_z, orbit, i); //-@535
//if (current_formula == 536) triescherdupeg_iter(z, dz, original_z, orbit, i); //-@536
//if (current_formula == 537) triescherdupeh_iter(z, dz, original_z, orbit, i); //-@537
//if (current_formula == 538) triescherdupei_iter(z, dz, original_z, orbit, i); //-@538
//if (current_formula == 539) triescherdupej_iter(z, dz, original_z, orbit, i); //-@539
//if (current_formula == 540) vicsek_iter(z, dz, original_z, orbit, i); //-@540
//if (current_formula == 541) vicsekdupea_iter(z, dz, original_z, orbit, i); //-@541
//if (current_formula == 542) vicsekdupeb_iter(z, dz, original_z, orbit, i); //-@542
//if (current_formula == 543) vicsekdupec_iter(z, dz, original_z, orbit, i); //-@543
//if (current_formula == 544) vicsekduped_iter(z, dz, original_z, orbit, i); //-@544
//if (current_formula == 545) vicsekdupee_iter(z, dz, original_z, orbit, i); //-@545
//if (current_formula == 546) vicsekdupef_iter(z, dz, original_z, orbit, i); //-@546
//if (current_formula == 547) vicsekdupeg_iter(z, dz, original_z, orbit, i); //-@547
//if (current_formula == 548) vicsekdupeh_iter(z, dz, original_z, orbit, i); //-@548
//if (current_formula == 549) vicsekdupei_iter(z, dz, original_z, orbit, i); //-@549
//if (current_formula == 550) vicsekdupej_iter(z, dz, original_z, orbit, i); //-@550
//if (current_formula == 551) wavysponge_iter(z, dz, original_z, orbit, i); //-@551
//if (current_formula == 552) wavyspongedupea_iter(z, dz, original_z, orbit, i); //-@552
//if (current_formula == 553) wavyspongedupeb_iter(z, dz, original_z, orbit, i); //-@553
//if (current_formula == 554) wavyspongedupec_iter(z, dz, original_z, orbit, i); //-@554
//if (current_formula == 555) wavyspongeduped_iter(z, dz, original_z, orbit, i); //-@555
//if (current_formula == 556) wavyspongedupee_iter(z, dz, original_z, orbit, i); //-@556
//if (current_formula == 557) wavyspongedupef_iter(z, dz, original_z, orbit, i); //-@557
//if (current_formula == 558) wavyspongedupeg_iter(z, dz, original_z, orbit, i); //-@558
//if (current_formula == 559) wavyspongedupeh_iter(z, dz, original_z, orbit, i); //-@559
//if (current_formula == 560) wavyspongedupei_iter(z, dz, original_z, orbit, i); //-@560
//if (current_formula == 561) wavyspongedupej_iter(z, dz, original_z, orbit, i); //-@561
//if (current_formula == 562) wobbletransform_iter(z, dz, original_z, orbit, i); //-@562
//if (current_formula == 563) wobbletransformdupea_iter(z, dz, original_z, orbit, i); //-@563
//if (current_formula == 564) wobbletransformdupeb_iter(z, dz, original_z, orbit, i); //-@564
//if (current_formula == 565) wobbletransformdupec_iter(z, dz, original_z, orbit, i); //-@565
//if (current_formula == 566) wobbletransformduped_iter(z, dz, original_z, orbit, i); //-@566
//if (current_formula == 567) wobbletransformdupee_iter(z, dz, original_z, orbit, i); //-@567
//if (current_formula == 568) wobbletransformdupef_iter(z, dz, original_z, orbit, i); //-@568
//if (current_formula == 569) wobbletransformdupeg_iter(z, dz, original_z, orbit, i); //-@569
//if (current_formula == 570) wobbletransformdupeh_iter(z, dz, original_z, orbit, i); //-@570
//if (current_formula == 571) wobbletransformdupei_iter(z, dz, original_z, orbit, i); //-@571
//if (current_formula == 572) wobbletransformdupej_iter(z, dz, original_z, orbit, i); //-@572
		orbit = min(orbit, process_orbit_trap4d(z, original_z, i));

		if (dot(z, z) > escape_radius * escape_radius || escaped) break;
	}

	float r = length(z);
	float de = 0.0;

	if (de_mode == 0) de = r / dz;
	else if (de_mode == 1) de = 0.5 * log(r) * r / dz;
	else if (de_mode == 2) {

			if (single_formula && (formulas[0] == 221 || formulas[0] == 222 || formulas[0] == 223 || formulas[0] == 224 || formulas[0] == 225 || formulas[0] == 226 || formulas[0] == 227 || formulas[0] == 228 || formulas[0] == 229 || formulas[0] == 230 || formulas[0] == 231 || formulas[0] == 309 || formulas[0] == 310 || formulas[0] == 311 || formulas[0] == 312 || formulas[0] == 313 || formulas[0] == 314 || formulas[0] == 315 || formulas[0] == 316 || formulas[0] == 317 || formulas[0] == 318 || formulas[0] == 319 || formulas[0] == 353 || formulas[0] == 354 || formulas[0] == 355 || formulas[0] == 356 || formulas[0] == 357 || formulas[0] == 358 || formulas[0] == 359 || formulas[0] == 360 || formulas[0] == 361 || formulas[0] == 362 || formulas[0] == 363 || formulas[0] == 375 || formulas[0] == 376 || formulas[0] == 377 || formulas[0] == 378 || formulas[0] == 379 || formulas[0] == 380 || formulas[0] == 381 || formulas[0] == 382 || formulas[0] == 383 || formulas[0] == 384 || formulas[0] == 385 || formulas[0] == 397 || formulas[0] == 398 || formulas[0] == 399 || formulas[0] == 400 || formulas[0] == 401 || formulas[0] == 402 || formulas[0] == 403 || formulas[0] == 404 || formulas[0] == 405 || formulas[0] == 406 || formulas[0] == 407 || formulas[0] == 540 || formulas[0] == 541 || formulas[0] == 542 || formulas[0] == 543 || formulas[0] == 544 || formulas[0] == 545 || formulas[0] == 546 || formulas[0] == 547 || formulas[0] == 548 || formulas[0] == 549 || formulas[0] == 550)) de = r / dz;
			else de = 0.5 * log(r) * r / dz;
		
	}

	if (only_primitive_based_formulas) de = 100000.0;
	else if (only_sdf_based_formulas) de = 0.0;

if (single_formula) {
vec2 sdf_result;
//sdf_result = circuit_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@56
//sdf_result = circuitdupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@57
//sdf_result = circuitdupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@58
//sdf_result = circuitdupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@59
//sdf_result = circuitduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@60
//sdf_result = circuitdupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@61
//sdf_result = circuitdupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@62
//sdf_result = circuitdupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@63
//sdf_result = circuitdupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@64
//sdf_result = circuitdupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@65
//sdf_result = circuitdupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@66
//sdf_result = cube_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@67
//sdf_result = cubedupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@68
//sdf_result = cubedupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@69
//sdf_result = cubedupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@70
//sdf_result = cubeduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@71
//sdf_result = cubedupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@72
//sdf_result = cubedupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@73
//sdf_result = cubedupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@74
//sdf_result = cubedupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@75
//sdf_result = cubedupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@76
//sdf_result = cubedupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@77
//sdf_result = dodecahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@78
//sdf_result = dodecahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@79
//sdf_result = dodecahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@80
//sdf_result = dodecahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@81
//sdf_result = dodecahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@82
//sdf_result = dodecahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@83
//sdf_result = dodecahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@84
//sdf_result = dodecahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@85
//sdf_result = dodecahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@86
//sdf_result = dodecahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@87
//sdf_result = dodecahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@88
//sdf_result = gyroid_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@100
//sdf_result = gyroiddupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@101
//sdf_result = gyroiddupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@102
//sdf_result = gyroiddupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@103
//sdf_result = gyroidduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@104
//sdf_result = gyroiddupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@105
//sdf_result = gyroiddupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@106
//sdf_result = gyroiddupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@107
//sdf_result = gyroiddupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@108
//sdf_result = gyroiddupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@109
//sdf_result = gyroiddupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@110
//sdf_result = hollowtetrahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@111
//sdf_result = hollowtetrahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@112
//sdf_result = hollowtetrahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@113
//sdf_result = hollowtetrahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@114
//sdf_result = hollowtetrahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@115
//sdf_result = hollowtetrahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@116
//sdf_result = hollowtetrahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@117
//sdf_result = hollowtetrahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@118
//sdf_result = hollowtetrahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@119
//sdf_result = hollowtetrahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@120
//sdf_result = hollowtetrahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@121
//sdf_result = icosahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@122
//sdf_result = icosahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@123
//sdf_result = icosahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@124
//sdf_result = icosahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@125
//sdf_result = icosahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@126
//sdf_result = icosahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@127
//sdf_result = icosahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@128
//sdf_result = icosahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@129
//sdf_result = icosahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@130
//sdf_result = icosahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@131
//sdf_result = icosahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@132
//sdf_result = inversebox_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@133
//sdf_result = inverseboxdupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@134
//sdf_result = inverseboxdupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@135
//sdf_result = inverseboxdupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@136
//sdf_result = inverseboxduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@137
//sdf_result = inverseboxdupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@138
//sdf_result = inverseboxdupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@139
//sdf_result = inverseboxdupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@140
//sdf_result = inverseboxdupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@141
//sdf_result = inverseboxdupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@142
//sdf_result = inverseboxdupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@143
//sdf_result = klenian_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@210
//sdf_result = kleniandupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@211
//sdf_result = kleniandupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@212
//sdf_result = kleniandupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@213
//sdf_result = klenianduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@214
//sdf_result = kleniandupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@215
//sdf_result = kleniandupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@216
//sdf_result = kleniandupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@217
//sdf_result = kleniandupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@218
//sdf_result = kleniandupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@219
//sdf_result = kleniandupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@220
//sdf_result = newton_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@331
//sdf_result = newtondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@332
//sdf_result = newtondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@333
//sdf_result = newtondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@334
//sdf_result = newtonduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@335
//sdf_result = newtondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@336
//sdf_result = newtondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@337
//sdf_result = newtondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@338
//sdf_result = newtondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@339
//sdf_result = newtondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@340
//sdf_result = newtondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@341
//sdf_result = octahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@342
//sdf_result = octahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@343
//sdf_result = octahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@344
//sdf_result = octahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@345
//sdf_result = octahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@346
//sdf_result = octahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@347
//sdf_result = octahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@348
//sdf_result = octahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@349
//sdf_result = octahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@350
//sdf_result = octahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@351
//sdf_result = octahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@352
//sdf_result = plane_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@364
//sdf_result = planedupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@365
//sdf_result = planedupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@366
//sdf_result = planedupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@367
//sdf_result = planeduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@368
//sdf_result = planedupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@369
//sdf_result = planedupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@370
//sdf_result = planedupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@371
//sdf_result = planedupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@372
//sdf_result = planedupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@373
//sdf_result = planedupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@374
//sdf_result = romanescobroccoli_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@419
//sdf_result = romanescobroccolidupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@420
//sdf_result = romanescobroccolidupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@421
//sdf_result = romanescobroccolidupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@422
//sdf_result = romanescobroccoliduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@423
//sdf_result = romanescobroccolidupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@424
//sdf_result = romanescobroccolidupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@425
//sdf_result = romanescobroccolidupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@426
//sdf_result = romanescobroccolidupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@427
//sdf_result = romanescobroccolidupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@428
//sdf_result = romanescobroccolidupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@429
//sdf_result = sphairahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@485
//sdf_result = sphairahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@486
//sdf_result = sphairahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@487
//sdf_result = sphairahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@488
//sdf_result = sphairahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@489
//sdf_result = sphairahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@490
//sdf_result = sphairahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@491
//sdf_result = sphairahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@492
//sdf_result = sphairahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@493
//sdf_result = sphairahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@494
//sdf_result = sphairahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@495
//sdf_result = sphere_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@496
//sdf_result = spheredupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@497
//sdf_result = spheredupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@498
//sdf_result = spheredupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@499
//sdf_result = sphereduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@500
//sdf_result = spheredupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@501
//sdf_result = spheredupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@502
//sdf_result = spheredupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@503
//sdf_result = spheredupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@504
//sdf_result = spheredupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@505
//sdf_result = spheredupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@506
//sdf_result = spheretree_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@507
//sdf_result = spheretreedupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@508
//sdf_result = spheretreedupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@509
//sdf_result = spheretreedupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@510
//sdf_result = spheretreeduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@511
//sdf_result = spheretreedupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@512
//sdf_result = spheretreedupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@513
//sdf_result = spheretreedupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@514
//sdf_result = spheretreedupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@515
//sdf_result = spheretreedupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@516
//sdf_result = spheretreedupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@517
//sdf_result = tetrahedron_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@518
//sdf_result = tetrahedrondupea_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@519
//sdf_result = tetrahedrondupeb_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@520
//sdf_result = tetrahedrondupec_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@521
//sdf_result = tetrahedronduped_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@522
//sdf_result = tetrahedrondupee_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@523
//sdf_result = tetrahedrondupef_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@524
//sdf_result = tetrahedrondupeg_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@525
//sdf_result = tetrahedrondupeh_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@526
//sdf_result = tetrahedrondupei_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@527
//sdf_result = tetrahedrondupej_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@528

} else {
vec2 sdf_result;
//sdf_result = circuit_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@56
//sdf_result = circuitdupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@57
//sdf_result = circuitdupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@58
//sdf_result = circuitdupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@59
//sdf_result = circuitduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@60
//sdf_result = circuitdupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@61
//sdf_result = circuitdupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@62
//sdf_result = circuitdupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@63
//sdf_result = circuitdupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@64
//sdf_result = circuitdupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@65
//sdf_result = circuitdupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@66
//sdf_result = hollowtetrahedron_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@111
//sdf_result = hollowtetrahedrondupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@112
//sdf_result = hollowtetrahedrondupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@113
//sdf_result = hollowtetrahedrondupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@114
//sdf_result = hollowtetrahedronduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@115
//sdf_result = hollowtetrahedrondupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@116
//sdf_result = hollowtetrahedrondupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@117
//sdf_result = hollowtetrahedrondupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@118
//sdf_result = hollowtetrahedrondupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@119
//sdf_result = hollowtetrahedrondupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@120
//sdf_result = hollowtetrahedrondupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@121
//sdf_result = inversebox_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@133
//sdf_result = inverseboxdupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@134
//sdf_result = inverseboxdupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@135
//sdf_result = inverseboxdupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@136
//sdf_result = inverseboxduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@137
//sdf_result = inverseboxdupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@138
//sdf_result = inverseboxdupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@139
//sdf_result = inverseboxdupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@140
//sdf_result = inverseboxdupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@141
//sdf_result = inverseboxdupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@142
//sdf_result = inverseboxdupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@143
//sdf_result = cube_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@67
//sdf_result = cubedupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@68
//sdf_result = cubedupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@69
//sdf_result = cubedupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@70
//sdf_result = cubeduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@71
//sdf_result = cubedupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@72
//sdf_result = cubedupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@73
//sdf_result = cubedupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@74
//sdf_result = cubedupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@75
//sdf_result = cubedupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@76
//sdf_result = cubedupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@77
//sdf_result = dodecahedron_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@78
//sdf_result = dodecahedrondupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@79
//sdf_result = dodecahedrondupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@80
//sdf_result = dodecahedrondupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@81
//sdf_result = dodecahedronduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@82
//sdf_result = dodecahedrondupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@83
//sdf_result = dodecahedrondupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@84
//sdf_result = dodecahedrondupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@85
//sdf_result = dodecahedrondupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@86
//sdf_result = dodecahedrondupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@87
//sdf_result = dodecahedrondupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@88
//sdf_result = gyroid_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@100
//sdf_result = gyroiddupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@101
//sdf_result = gyroiddupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@102
//sdf_result = gyroiddupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@103
//sdf_result = gyroidduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@104
//sdf_result = gyroiddupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@105
//sdf_result = gyroiddupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@106
//sdf_result = gyroiddupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@107
//sdf_result = gyroiddupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@108
//sdf_result = gyroiddupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@109
//sdf_result = gyroiddupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@110
//sdf_result = icosahedron_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@122
//sdf_result = icosahedrondupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@123
//sdf_result = icosahedrondupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@124
//sdf_result = icosahedrondupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@125
//sdf_result = icosahedronduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@126
//sdf_result = icosahedrondupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@127
//sdf_result = icosahedrondupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@128
//sdf_result = icosahedrondupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@129
//sdf_result = icosahedrondupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@130
//sdf_result = icosahedrondupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@131
//sdf_result = icosahedrondupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@132
//sdf_result = klenian_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@210
//sdf_result = kleniandupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@211
//sdf_result = kleniandupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@212
//sdf_result = kleniandupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@213
//sdf_result = klenianduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@214
//sdf_result = kleniandupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@215
//sdf_result = kleniandupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@216
//sdf_result = kleniandupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@217
//sdf_result = kleniandupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@218
//sdf_result = kleniandupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@219
//sdf_result = kleniandupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@220
//sdf_result = newton_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@331
//sdf_result = newtondupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@332
//sdf_result = newtondupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@333
//sdf_result = newtondupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@334
//sdf_result = newtonduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@335
//sdf_result = newtondupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@336
//sdf_result = newtondupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@337
//sdf_result = newtondupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@338
//sdf_result = newtondupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@339
//sdf_result = newtondupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@340
//sdf_result = newtondupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@341
//sdf_result = octahedron_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@342
//sdf_result = octahedrondupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@343
//sdf_result = octahedrondupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@344
//sdf_result = octahedrondupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@345
//sdf_result = octahedronduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@346
//sdf_result = octahedrondupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@347
//sdf_result = octahedrondupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@348
//sdf_result = octahedrondupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@349
//sdf_result = octahedrondupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@350
//sdf_result = octahedrondupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@351
//sdf_result = octahedrondupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@352
//sdf_result = plane_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@364
//sdf_result = planedupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@365
//sdf_result = planedupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@366
//sdf_result = planedupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@367
//sdf_result = planeduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@368
//sdf_result = planedupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@369
//sdf_result = planedupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@370
//sdf_result = planedupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@371
//sdf_result = planedupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@372
//sdf_result = planedupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@373
//sdf_result = planedupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@374
//sdf_result = romanescobroccoli_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@419
//sdf_result = romanescobroccolidupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@420
//sdf_result = romanescobroccolidupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@421
//sdf_result = romanescobroccolidupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@422
//sdf_result = romanescobroccoliduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@423
//sdf_result = romanescobroccolidupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@424
//sdf_result = romanescobroccolidupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@425
//sdf_result = romanescobroccolidupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@426
//sdf_result = romanescobroccolidupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@427
//sdf_result = romanescobroccolidupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@428
//sdf_result = romanescobroccolidupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@429
//sdf_result = sphairahedron_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@485
//sdf_result = sphairahedrondupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@486
//sdf_result = sphairahedrondupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@487
//sdf_result = sphairahedrondupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@488
//sdf_result = sphairahedronduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@489
//sdf_result = sphairahedrondupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@490
//sdf_result = sphairahedrondupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@491
//sdf_result = sphairahedrondupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@492
//sdf_result = sphairahedrondupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@493
//sdf_result = sphairahedrondupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@494
//sdf_result = sphairahedrondupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@495
//sdf_result = spheretree_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@507
//sdf_result = spheretreedupea_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@508
//sdf_result = spheretreedupeb_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@509
//sdf_result = spheretreedupec_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@510
//sdf_result = spheretreeduped_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@511
//sdf_result = spheretreedupee_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@512
//sdf_result = spheretreedupef_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@513
//sdf_result = spheretreedupeg_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@514
//sdf_result = spheretreedupeh_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@515
//sdf_result = spheretreedupei_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@516
//sdf_result = spheretreedupej_sdf(original_z); de = max(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@517
//sdf_result = sphere_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@496
//sdf_result = spheredupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@497
//sdf_result = spheredupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@498
//sdf_result = spheredupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@499
//sdf_result = sphereduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@500
//sdf_result = spheredupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@501
//sdf_result = spheredupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@502
//sdf_result = spheredupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@503
//sdf_result = spheredupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@504
//sdf_result = spheredupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@505
//sdf_result = spheredupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@506
//sdf_result = tetrahedron_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@518
//sdf_result = tetrahedrondupea_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@519
//sdf_result = tetrahedrondupeb_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@520
//sdf_result = tetrahedrondupec_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@521
//sdf_result = tetrahedronduped_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@522
//sdf_result = tetrahedrondupee_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@523
//sdf_result = tetrahedrondupef_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@524
//sdf_result = tetrahedrondupeg_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@525
//sdf_result = tetrahedrondupeh_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@526
//sdf_result = tetrahedrondupei_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@527
//sdf_result = tetrahedrondupej_sdf(original_z); de = min(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@528

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

		float hit_threshold = calc_epsilon(dfo);
		if (point_distance < hit_threshold) {
			// Refinement step
			for(int j = 0; j < 3; j++) {
				current_pos = ro + rd * dfo;
				data = scene_sdf(current_pos);
				dfo += data.y * 0.5;
			}
			orbit_trap_distance = data.x;
			final_bounds_dist = bounds_dist;
			final_bounds_color = bounds_color;
			break;
		}
		if (dfo > max_distance) {
			orbit_trap_distance = data.x;
			final_bounds_dist = bounds_dist;
			final_bounds_color = bounds_color;
			break;
		}
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

#include "lighting.gdshaderinc"

vec4 render_single_ray(vec3 ray_origin, vec3 ray_dir, vec2 screen_uv, mat4 projection_matrix, mat4 view_matrix, inout bool discard_color, vec2 resolution) {
	vec3 final_color;

	if (building_mesh) {
		vec3 camera_forward = normalize(vec3(view_matrix[0][2], view_matrix[1][2], view_matrix[2][2]));
		vec3 camera_up = normalize(vec3(view_matrix[0][1], view_matrix[1][1], view_matrix[2][1]));
		vec3 camera_right = normalize(vec3(view_matrix[0][0], view_matrix[1][0], view_matrix[2][0]));

		vec2 centered_uv = screen_uv;
		vec2 resolution_scale = voxel_screen_resolution / 450.0;
		vec3 sample_offset = camera_right * centered_uv.x * sample_scale / resolution_scale.x + camera_up * centered_uv.y * sample_scale / resolution_scale.y;
		vec3 sample_pos = ray_origin + sample_offset;

		vec2 uv = screen_uv;
		uv *= max(float(voxel_resolution) / 450.0, 1.0);
		uv -= 0.5;

		vec3 pos = vec3(uv * 2.5, ray_origin.z);
		vec2 sdf_data = scene_sdf(pos);
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
		if (override_color) final_color = overridden_color;
		else final_color = palette_color * compute_direct_lighting(p, ray_dir, ray_origin, normal);
	}

	// Outline
	if (outline && float(total_marches) * raystep_multiplier > outline_threshold) {
		float outline_factor = smoothstep(outline_threshold, 100.0, float(total_marches) * raystep_multiplier);
		final_color = mix(final_color, 3.0 * outline_color, pow(outline_intensity * outline_factor, outline_falloff));
	}

	// Fog
	if (fog_enabled) {
		float fog_distance = dfo < max_distance ? dfo : max_distance;
		if (fog_volumetric) {
			final_color = apply_volumetric_fog(ray_origin, ray_dir, final_color, fog_distance, screen_uv * resolution);
		} else {
			float fog_amount = 1.0 - exp(-fog_density * fog_distance);
			vec3 fog_color_from_palette = texture(fog_palette, vec2(fog_amount, 0.0)).xyz;
			final_color = mix(final_color, fog_color_from_palette, pow(fog_amount, fog_falloff));
		}
	}

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

	// Dithering
	if (dither) {
		int frame = 0;
		float noise = hash_noise(screen_uv * resolution, frame) * 2.0 - 1.0;
		final_color += noise / fog_dither_scale;
	}

	// Debug
	if (display == 1) final_color = dfo <= max_distance ? vec3(calcAO(p, normal)) : vec3(0.0);
	else if (display == 2) final_color = normal;
	else if (display == 3) final_color = vec3(dfo * depth_scale);

	return vec4(final_color, 1.0);
}

vec3 render_ray(vec3 ray_origin, vec3 ray_dir, vec2 screen_uv, mat4 projection_matrix, mat4 view_matrix, inout bool discard_color, vec2 resolution) {
	vec3 current_origin = ray_origin;
	vec3 current_dir = ray_dir;

	// Initial ray
	vec4 result = render_single_ray(current_origin, current_dir, screen_uv, projection_matrix, view_matrix, discard_color, resolution);
	vec3 final_color = result.rgb;
	bool hit_surface = result.a > 0.5;

#ifdef USING_REFLECTIONS
	vec3 data = ray_marcher(current_origin, current_dir);
	float dfo = data.y;
	vec3 hit_point = current_origin + current_dir * dfo;
	vec3 normal = calculate_normal(hit_point, relative_epsilon ? epsilon / 3.4 * dfo : epsilon);

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
	vec3 albedo = calculate_albedo(ro, rd, SCREEN_UV, FRAGCOORD.xy, VIEWPORT_SIZE, PROJECTION_MATRIX, VIEW_MATRIX, discard_color); \
	if (transparent_bg) albedo = max(albedo, vec3(0.0)) + 0.004; \
	ALBEDO = albedo; \
	if (discard_color) ALBEDO = vec3(0);

void fragment() {
	if (texture(pixels_to_render, UV).r < 0.5) discard;

	if (camera_kalaidoscope > 1.0) {
		float aspect_ratio = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
		vec2 centered_uv = SCREEN_UV - 0.5;
		centered_uv.x *= aspect_ratio;

		float angle = 3.14159265 / camera_kalaidoscope;
		float theta = atan(centered_uv.y, centered_uv.x);
		float margin = 0.02;

		if (theta < -angle - margin || theta > angle + margin) {
			discard;
		}
	}

	SET_ALBEDO

	if (tiled) {
		if (SCREEN_UV.x < tile_bounds.x || SCREEN_UV.x >= tile_bounds.z ||
			SCREEN_UV.y < tile_bounds.y || SCREEN_UV.y >= tile_bounds.w) {
			ALBEDO = vec3(0);
		}
	}
}
