extends SubViewport

enum AntiAliasing { FXAA, SMAA, NONE, TAA }

var antialiasing := AntiAliasing.NONE
var low_scaling: float
var high_scaling: float = 1.0
var since_last_dynamic_update := 0.0
var since_last_dynamic_update_frame := 0
var previous_update_mode: int
var upscaling: float = 1.0
var force_disable_low_scaling: bool = false

func _ready() -> void:
	since_last_dynamic_update = 0.0
	since_last_dynamic_update_frame = 0
	set_antialiasing(antialiasing)

func set_antialiasing(target_aa: AntiAliasing) -> void:
	antialiasing = target_aa
	
	if target_aa == AntiAliasing.FXAA:
		scaling_3d_mode = SCALING_3D_MODE_BILINEAR
		screen_space_aa = SCREEN_SPACE_AA_FXAA
	elif target_aa == AntiAliasing.SMAA:
		scaling_3d_mode = SCALING_3D_MODE_BILINEAR
		screen_space_aa = SCREEN_SPACE_AA_SMAA
	elif target_aa == AntiAliasing.NONE:
		scaling_3d_mode = SCALING_3D_MODE_FSR
		screen_space_aa = SCREEN_SPACE_AA_DISABLED

func _process(delta: float) -> void:
	%PostViewport.render_target_update_mode = render_target_update_mode
	var rendered_condition: bool = false
	rendered_condition = since_last_dynamic_update_frame > 0 or previous_update_mode == UPDATE_WHEN_VISIBLE
	
	if rendered_condition:
		render_target_update_mode = UPDATE_DISABLED
	else:
		render_target_update_mode = UPDATE_WHEN_VISIBLE
	
	if since_last_dynamic_update <= 0.0001:
		scaling_3d_scale = low_scaling if not force_disable_low_scaling else high_scaling
		render_target_update_mode = UPDATE_WHEN_VISIBLE
	elif previous_update_mode == UPDATE_WHEN_VISIBLE and render_target_update_mode == UPDATE_DISABLED:
		scaling_3d_scale = high_scaling
		render_target_update_mode = UPDATE_ONCE
	
	var program_state: String = %ProgramStateLabel.text
	if render_target_update_mode == UPDATE_DISABLED:
		program_state = "Rendered"
	elif render_target_update_mode == UPDATE_ONCE and since_last_dynamic_update_frame > 0:
		program_state = "Rendered"
	else:
		program_state = "Rendering"
	
	if %ProgramStateLabel.text != "Saving file":
		%ProgramStateLabel.text = program_state
	
	since_last_dynamic_update += delta
	since_last_dynamic_update_frame += 1
	previous_update_mode = render_target_update_mode

func refresh(from_tiling: bool = false) -> void:
	since_last_dynamic_update = 0.0
	since_last_dynamic_update_frame = 0
	
	if Engine.get_frames_drawn() > 1:
		get_tree().current_scene.made_changes = true
	
	var old_scaling_3d_scale := scaling_3d_scale
	scaling_3d_scale = old_scaling_3d_scale - randf_range(-0.00001, 0.00001) + 0.0000001
	if not %AnimationTrack.is_playing:
		await get_tree().process_frame
		scaling_3d_scale = old_scaling_3d_scale

	if %Fractal.material_override.get_shader_parameter('tiled') and not from_tiling:
		if %Rendering.rendering_tiles and %Rendering.is_computing_tiles_internally:
			%Rendering.restart_tile_loop = true
		elif not %Rendering.rendering_tiles:
			%Rendering.compute_tiled_render()
