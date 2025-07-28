extends MarginContainer

const ANIMATION_TRACK_KEYFRAME_SCENE = preload('res://ui/animation/track keyframe/animation_track_keyframe.tscn')
var is_mouse_hovering: bool = false
var keyframes: Dictionary = {}
var is_playing: bool = false
var is_rendering: bool = false
var animation_frames_data: Array[Dictionary] = []
var currently_at_frame: float = 0:
	set(value):
		currently_at_frame = value
		%Time.position.x = (value / fps * 133.0) + 60

var fps: int = 60:
	set(value):
		fps = value

var interpolation := Interpolation.InterpolationModes.CATMULLROM:
	set(value):
		interpolation = value

var keyframe_length: float = 1.0:
	set(value):
		keyframe_length = value

var taa_frame_counter: int = 0
var waiting_for_taa: bool = false
var rendering_tiles: bool = false
var using_tiling: bool = false
var render_start_time: float
var time_estimate: float = 0.0

func update_tiling_variables() -> void:
	rendering_tiles = get_tree().current_scene.busy_rendering_tiles
	using_tiling = get_tree().current_scene.using_tiling

func _ready() -> void:
	_on_set_time_start_button_pressed()
	update_tiling_variables()

func _on_playing_toggle_button_pressed() -> void:
	is_playing = not is_playing
	
	if is_playing:
		update_animation_frames_data()
		%PlayingToggleButton.icon = preload('res://resources/icons/pause-solid.svg')
	else:
		%PlayingToggleButton.icon = preload('res://resources/icons/play-solid.svg')
		currently_at_frame = 0
	
	render_start_time = Time.get_unix_time_from_system()

func update_animation_frames_data() -> void:
	animation_frames_data.clear()
	
	if len(keyframes.keys()) <= 0:
		return
	
	var sorted_keyframes: Array = keyframes.keys()
	sorted_keyframes.sort()
	
	var required_fields: Array[String] = ["formulas", "keyframes", "total_visible_formula_pages", "player_position", "head_rotation", "camera_rotation"]
	
	var all_field_names: Array[String] = []
	for time in (sorted_keyframes as Array[float]):
		for field_name in (keyframes[time].keys() as Array[String]):
			if not field_name in all_field_names:
				all_field_names.append(field_name)
	
	var field_interpolation_data: Dictionary = {}
	
	for field_name in all_field_names:
		var field_values: Array[Variant] = []
		var field_times: Array[float] = []
		
		for time in (sorted_keyframes as Array[float]):
			if field_name in keyframes[time]:
				field_values.append(keyframes[time][field_name])
				field_times.append(time)
		
		var all_same := true
		if field_values.size() >= 2:
			var first_value: Variant = field_values[0]
			for i in range(1, field_values.size()):
				if field_values[i] != first_value:
					all_same = false
					break
			
			if not all_same or field_name in required_fields:
				field_interpolation_data[field_name] = {
					"values": field_values,
					"times": field_times
				}
	
	var total_frames := int((sorted_keyframes[-1] - sorted_keyframes[0]) * fps)
	for frame in range(total_frames + 1):
		var current_time: float = sorted_keyframes[0] + (frame / float(fps))
		var frame_data: Dictionary = {}
		
		var base_keyframe_time := 0.0
		for time in (sorted_keyframes as Array[float]):
			if time <= current_time:
				base_keyframe_time = time
		
		frame_data = keyframes[base_keyframe_time].duplicate(true)
		
		for field_name in (frame_data.keys() as Array[String]):
			if not field_name in field_interpolation_data and not field_name in required_fields and not frame == 0:
				frame_data.erase(field_name)
		
		for field_name in (field_interpolation_data.keys() as Array[String]):
			var field_info: Dictionary = field_interpolation_data[field_name]
			var times: Array[float] = field_info["times"]
			
			var start_idx := 0
			for i in range(times.size()):
				if times[i] <= current_time:
					start_idx = i
			
			if start_idx >= times.size() - 1:
				continue
			
			var keyframe_values: Array[Variant] = []
			for t in (times as Array[float]):
				var idx := sorted_keyframes.find(t)
				if idx != -1 and field_name in keyframes[t]:
					keyframe_values.append(keyframes[t][field_name])
			
			var interpolated_values := Interpolation.interpolate(keyframe_values, interpolation, fps)
			
			if interpolated_values.size() == 0:
				var closest_keyframe_time := times[0]
				for t in (times as Array[float]):
					if t <= current_time and t > closest_keyframe_time:
						closest_keyframe_time = t
				
				if field_name in keyframes[closest_keyframe_time]:
					frame_data[field_name] = keyframes[closest_keyframe_time][field_name]
			else:
				var total_t: float = (current_time - times[0]) / (times[-1] - times[0])
				var interpolated_idx := int(total_t * (interpolated_values.size() - 1))
				interpolated_idx = clamp(interpolated_idx, 0, interpolated_values.size() - 1)
				
				frame_data[field_name] = interpolated_values[interpolated_idx]
		
		animation_frames_data.append(frame_data)
	
	animation_frames_data.append(keyframes[sorted_keyframes[-1]].duplicate(true))

func insert_keyframe(at_second: float) -> void:
	var data: Dictionary = get_tree().current_scene.fields
	data.merge({'total_visible_formula_pages': %TabContainer.total_visible_formulas, 'player_position': %Player.global_position, 'head_rotation': %Player.get_node('Head').global_rotation_degrees, 'camera_rotation': %Player.get_node('Head/Camera').global_rotation_degrees}, true)
	var viewport_image: Image = %SubViewport.get_texture().get_image()
	viewport_image.resize(100, 100, Image.INTERPOLATE_NEAREST)
	var keyframe_texture: ImageTexture = ImageTexture.create_from_image(viewport_image)
	data['keyframe_texture'] = Marshalls.raw_to_base64(keyframe_texture.get_image().get_data())
	
	data.erase('animation_fps')
	data.erase('tiles_x')
	data.erase('tiles_y')
	data.erase('taa_samples')
	data.erase('fps')
	data.erase('interpolation')
	data.erase('keyframe_length')
	data.erase('camera_type')
	data.erase('resolution')
	data.erase('anti_aliasing')
	
	keyframes[at_second] = data.duplicate(true)
	reload_keyframes()

func stop() -> void:
	if is_playing:
		_on_playing_toggle_button_pressed()

func start() -> void:
	if not is_playing:
		_on_playing_toggle_button_pressed()

func remove_keyframe(target_keyframe_data: Dictionary) -> void:
	stop()
	
	for at_second in (keyframes.keys() as Array[float]):
		var keyframe_data: Dictionary = keyframes[at_second]
		if target_keyframe_data == keyframe_data:
			keyframes.erase(at_second)
			break
	
	var sorted_times: Array = keyframes.keys()
	sorted_times.sort()
	
	var temp_keyframes: Dictionary = {}
	for i in range(sorted_times.size()):
		temp_keyframes[float(i + 1)] = keyframes[sorted_times[i]]
	
	keyframes = temp_keyframes
	reload_keyframes()

func reload_keyframes() -> void:
	for child in %Keyframes.get_children():
		%Keyframes.remove_child(child)
	
	for at_second in (keyframes.keys() as Array[float]):
		var keyframe_data: Dictionary = keyframes[at_second]
		var keyframe: Control = ANIMATION_TRACK_KEYFRAME_SCENE.instantiate()
		if not keyframe_data['keyframe_texture'] is EncodedObjectAsID:
			keyframe.image = ImageTexture.create_from_image(Image.create_from_data(100, 100, false, Image.FORMAT_RGB8, Marshalls.base64_to_raw(keyframe_data['keyframe_texture'])))
		
		keyframe.data = keyframe_data
		%Keyframes.add_child(keyframe)

func calculate_time_estimate() -> float:
	if not is_playing or len(animation_frames_data) == 0:
		return 0.0
	
	var elapsed_time: float = Time.get_unix_time_from_system() - render_start_time
	var frames_completed: int = int(currently_at_frame)
	var total_frames: int = len(animation_frames_data)
	
	if frames_completed <= 0:
		return 0.0
	
	var time_per_frame: float = elapsed_time / frames_completed
	var remaining_frames: int = total_frames - frames_completed
	
	return remaining_frames * time_per_frame

func process_frame() -> void:
	%SubViewport.refresh_taa()
	
	var image: Image = %SubViewport.get_texture().get_image()
	
	if get_tree().current_scene.using_tiling and FileAccess.file_exists(get_tree().current_scene.HELIUM3D_PATH + '/tilerender/combined.png'):
		image = Image.load_from_file(get_tree().current_scene.HELIUM3D_PATH + '/tilerender/combined.png')
	
	if image and is_rendering and currently_at_frame >= 2:
		var path: String = get_tree().current_scene.HELIUM3D_PATH + "/renders/frame_" + str(int(currently_at_frame - 2) + 1).trim_suffix('.0') + ".png"
		image.save_png(path)
	
	if not is_rendering:
		currently_at_frame += (fps * get_process_delta_time()) / keyframe_length
	else:
		currently_at_frame += 1
	
	waiting_for_taa = false
	
	if using_tiling:
		await get_tree().process_frame
		%Rendering.compute_tiled_render()

func _process(_delta: float) -> void:
	update_tiling_variables()
	
	time_estimate = calculate_time_estimate()
	
	var text: String = 'Render animation and save to disk.'
	if is_playing:
		text += '\n\n'
		text += 'Frame: ' + str(int(currently_at_frame)) + ' / ' + str(len(animation_frames_data))
		text += '\n\n'
		text += 'Time: ' + str(int((Time.get_unix_time_from_system() - render_start_time) * 100) / 100) + 's' + ' / ' + str(int(time_estimate * 100) / 100) + 's'
	
	%RenderButton.tooltip_text = text
	
	if not using_tiling:
		if waiting_for_taa and is_playing:
			taa_frame_counter += 1
			if taa_frame_counter >= get_tree().current_scene.taa_samples:
				process_frame()
	
	if is_mouse_hovering and Input.is_action_just_pressed('mouse click') and has_focus():
		insert_keyframe(get_global_mouse_position().x / 50.0)
	
	if is_playing and currently_at_frame >= len(animation_frames_data):
		is_playing = false
		
		if not %Time.get_parent().dragging:
			currently_at_frame = 0
		
		%PlayingToggleButton.icon = preload('res://resources/icons/play-solid.svg')
	
	var wait := true
	
	if using_tiling:
		wait = rendering_tiles
	else:
		wait = waiting_for_taa
	
	if is_playing and not wait:
		if round(currently_at_frame) >= len(animation_frames_data):
			stop()
			return
		
		get_tree().current_scene.update_app_state(animation_frames_data[round(currently_at_frame)], false)
		
		if %SubViewport.antialiasing == %SubViewport.AntiAliasing.TAA and is_rendering and not using_tiling:
			waiting_for_taa = true
			taa_frame_counter = 0
		else:
			if not rendering_tiles:
				process_frame()

func _on_mouse_entered() -> void: is_mouse_hovering = true
func _on_mouse_exited() -> void: is_mouse_hovering = false

func _on_add_keyframe_button_pressed() -> void:
	var seconds: Array = keyframes.keys()
	seconds.append(0)
	insert_keyframe(seconds.max() + 1.0)
	stop()

func _on_set_time_start_button_pressed() -> void: currently_at_frame = 0
func _on_set_time_end_button_pressed() -> void: 
	if len(keyframes) > 0:
		currently_at_frame = (len(keyframes) - 1) * fps
	else:
		currently_at_frame = 0

func _on_render_button_pressed() -> void:
	if is_playing:
		_on_playing_toggle_button_pressed()
		is_rendering = true
		_on_playing_toggle_button_pressed()
	else:
		is_rendering = true
		_on_playing_toggle_button_pressed()

func set_interpolation(index: int) -> void:
	interpolation = index

func update_fps(value: int) -> void:
	fps = int(value * keyframe_length)

func set_fps(new_text: String) -> void:
	if new_text.is_valid_float() or new_text.is_valid_int():
		update_fps(int(float(new_text)))

func set_keyframe_length(new_text: String) -> void:
	if new_text.is_valid_float() or new_text.is_valid_int():
		keyframe_length = float(new_text)
		
		if %FPSLineEdit.text.is_valid_float() or %FPSLineEdit.text.is_valid_int():
			update_fps(int(float(%FPSLineEdit.text)))
		# TODO: Handle else statement, is fps text is invalid.
