extends SubViewport

enum AntiAliasing { TAA, FXAA, SMAA, NONE }

var antialiasing := AntiAliasing.NONE
var low_scaling: float
var high_scaling: float = 1.0
var since_last_dynamic_update := 0.0
var since_last_dynamic_update_frame := 0
var previous_update_mode: int
var upscaling: float = 1.0
var force_disable_low_scaling: bool = false

func set_upscaling_factor(factor: float) -> void:
	upscaling = factor
	if upscaling <= 0.9999:
		# Make sure TAA is enabled.
		set_antialiasing(AntiAliasing.TAA)
	
	var iupscaling: float = 1.0 - upscaling
	var val: float = low_scaling
	val -= iupscaling
	val = clamp(val, 0.25, 1.0)
	low_scaling = val
	high_scaling = clamp(1.0 - iupscaling, 0.25, 1.0)
	
	refresh_taa()

func _ready() -> void:
	since_last_dynamic_update = 0.0
	since_last_dynamic_update_frame = 0
	set_antialiasing(antialiasing)

func set_antialiasing(target_aa: AntiAliasing) -> void:
	antialiasing = target_aa
	
	if target_aa == AntiAliasing.TAA:
		scaling_3d_mode = SCALING_3D_MODE_FSR2
		screen_space_aa = SCREEN_SPACE_AA_DISABLED
	elif target_aa == AntiAliasing.FXAA:
		scaling_3d_mode = SCALING_3D_MODE_BILINEAR
		screen_space_aa = SCREEN_SPACE_AA_FXAA
	elif target_aa == AntiAliasing.SMAA:
		scaling_3d_mode = SCALING_3D_MODE_BILINEAR
		screen_space_aa = SCREEN_SPACE_AA_SMAA
	elif target_aa == AntiAliasing.NONE:
		scaling_3d_mode = SCALING_3D_MODE_FSR
		screen_space_aa = SCREEN_SPACE_AA_DISABLED

func _process(delta: float) -> void:
	var low_scaling_time: float = 0.0
	var taa_samples: int = get_tree().current_scene.taa_samples
	
	var rendered_condition: bool = false
	if antialiasing == AntiAliasing.TAA:
		rendered_condition = since_last_dynamic_update_frame > taa_samples
	else:
		rendered_condition = since_last_dynamic_update_frame > 0 or previous_update_mode == UPDATE_WHEN_VISIBLE
	
	if rendered_condition:
		render_target_update_mode = UPDATE_DISABLED
	else:
		render_target_update_mode = UPDATE_WHEN_VISIBLE
	
	if since_last_dynamic_update <= low_scaling_time:
		if antialiasing != AntiAliasing.TAA:
			scaling_3d_scale = low_scaling if not force_disable_low_scaling else high_scaling
		else:
			scaling_3d_scale = (low_scaling if not force_disable_low_scaling else high_scaling) if since_last_dynamic_update <= low_scaling_time else high_scaling
		render_target_update_mode = UPDATE_WHEN_VISIBLE
	elif previous_update_mode == UPDATE_WHEN_VISIBLE and (render_target_update_mode == UPDATE_DISABLED or antialiasing == AntiAliasing.TAA):
		scaling_3d_scale = high_scaling
		render_target_update_mode = UPDATE_ONCE
	
	since_last_dynamic_update += delta
	since_last_dynamic_update_frame += 1
	previous_update_mode = render_target_update_mode

func refresh_taa() -> void:
	since_last_dynamic_update = 0.0
	since_last_dynamic_update_frame = 0
	
	%ProgressionWhiteNoiseViewport.reset()
	
	var old_scaling_3d_scale := scaling_3d_scale
	scaling_3d_scale = old_scaling_3d_scale - randf_range(-0.00001, 0.00001) + 0.0000001
	if not %AnimationTrack.is_playing:
		await get_tree().process_frame
		scaling_3d_scale = old_scaling_3d_scale
	
	#if get_tree().current_scene.using_tiling:
		#if get_tree().current_scene.busy_rendering_tiles:
			#%Rendering.stop_tiled_render()
			#%Rendering.compute_tiled_render()
		#if not get_tree().current_scene.busy_rendering_tiles:
			#%Rendering.compute_tiled_render()

func refresh_no_taa() -> void:
	since_last_dynamic_update = 0.0
	since_last_dynamic_update_frame = 0
	%ProgressionWhiteNoiseViewport.reset()
	
	#if get_tree().current_scene.using_tiling and not get_tree().current_scene.busy_rendering_tiles:
		#%Rendering.compute_tiled_render()
