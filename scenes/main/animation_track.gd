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
		%Time.position.x = (value / 60 * 133.0) + 60.0

func _ready() -> void:
	_on_set_time_start_button_pressed()

func _on_playing_toggle_button_pressed() -> void:
	is_playing = not is_playing
	
	if is_playing:
		update_animation_frames_data()
		%PlayingToggleButton.icon = preload('res://resources/icons/pause-solid.svg')
	else:
		%PlayingToggleButton.icon = preload('res://resources/icons/play-solid.svg')
		currently_at_frame = 0

func update_animation_frames_data() -> void:
	animation_frames_data.clear()
	
	var sorted_keyframes: Array = keyframes.keys()
	sorted_keyframes.sort()
	
	if sorted_keyframes.size() < 2:
		for key in (sorted_keyframes as Array[String]):
			animation_frames_data.append(keyframes[key].duplicate(true))
		return
	
	var fps: int = 60
	
	# Define required fields that must always be included
	var required_fields: Array[String] = ["keyframes", "total_visible_formula_pages", "player_position", "head_rotation", "camera_rotation"]
	
	# Collect all field names from all keyframes
	var all_field_names: Array[String] = []
	for time in (sorted_keyframes as Array[float]):
		for field_name in (keyframes[time].keys() as Array[String]):
			if not field_name in all_field_names:
				all_field_names.append(field_name)
	
	# Create interpolation data for each field across all keyframes
	var field_interpolation_data: Dictionary = {}
	
	for field_name in all_field_names:
		# Collect all values for this field across all keyframes
		var field_values: Array[Variant] = []
		var field_times: Array[float] = []
		
		for time in (sorted_keyframes as Array[float]):
			if field_name in keyframes[time]:
				field_values.append(keyframes[time][field_name])
				field_times.append(time)
		
		# Check if all values are the same
		var all_same := true
		if field_values.size() >= 2:
			var first_value: Variant = field_values[0]
			for i in range(1, field_values.size()):
				if field_values[i] != first_value:
					all_same = false
					break
			
			# Add to interpolation data if values change OR it's a required field
			if not all_same or field_name in required_fields:
				field_interpolation_data[field_name] = {
					"values": field_values,
					"times": field_times
				}
	
	# Generate frame data
	var total_frames := int((sorted_keyframes[-1] - sorted_keyframes[0]) * fps)
	for frame in range(total_frames + 1):
		var current_time: float = sorted_keyframes[0] + (frame / float(fps))
		var frame_data: Dictionary = {}
		
		# Get last keyframe data as base
		var base_keyframe_time := 0.0
		for time in (sorted_keyframes as Array[float]):
			if time <= current_time:
				base_keyframe_time = time
		
		frame_data = keyframes[base_keyframe_time].duplicate(true)
		
		# Remove fields that don't change from frame_data, except required ones
		for field_name in (frame_data.keys() as Array[String]):
			if not field_name in field_interpolation_data and not field_name in required_fields:
				frame_data.erase(field_name)
		
		# Interpolate each field
		for field_name in (field_interpolation_data.keys() as Array[String]):
			var field_info: Dictionary = field_interpolation_data[field_name]
			var values: Array[Variant] = field_info["values"]
			var times: Array[float] = field_info["times"]
			
			# Find segment for current time
			var start_idx := 0
			for i in range(times.size()):
				if times[i] <= current_time:
					start_idx = i
			
			# Skip if we're at the last keyframe for this field
			if start_idx >= times.size() - 1:
				continue
			
			# Calculate normalized time within segment
			var segment_start_time: float = times[start_idx]
			var segment_end_time: float = times[start_idx + 1]
			var segment_length: float = segment_end_time - segment_start_time
			var segment_t: float = (current_time - segment_start_time) / segment_length
			
			# Get values for this field from all keyframes
			var keyframe_values: Array[Variant] = []
			for t in (times as Array[float]):
				var idx := sorted_keyframes.find(t)
				if idx != -1 and field_name in keyframes[t]:
					keyframe_values.append(keyframes[t][field_name])
			
			# Use global Interpolation with all values for this field
			var interpolation_mode := Interpolation.InterpolationModes.CATMULLROM
			var interpolated_values := Interpolation.interpolate(keyframe_values, interpolation_mode)
			
			# If we got empty array, Interpolation doesn't support this type
			if interpolated_values.size() == 0:
				# For unsupported types, just use the value from the previous keyframe
				# Find the appropriate keyframe based on the current time
				var closest_keyframe_time := times[0]
				for t in (times as Array[float]):
					if t <= current_time and t > closest_keyframe_time:
						closest_keyframe_time = t
				
				# Get the value from the closest keyframe
				if field_name in keyframes[closest_keyframe_time]:
					frame_data[field_name] = keyframes[closest_keyframe_time][field_name]
			else:
				# Find the right position in the interpolated array
				var total_t: float = (current_time - times[0]) / (times[-1] - times[0])
				var interpolated_idx := int(total_t * (interpolated_values.size() - 1))
				interpolated_idx = clamp(interpolated_idx, 0, interpolated_values.size() - 1)
				
				# Update frame data with interpolated value
				frame_data[field_name] = interpolated_values[interpolated_idx]
		
		animation_frames_data.append(frame_data)
	
	if animation_frames_data.size() == 0 and sorted_keyframes.size() > 0:
		animation_frames_data.append(keyframes[sorted_keyframes[-1]].duplicate(true))

func insert_keyframe(at_second: float) -> void:
	var data: Dictionary = get_tree().current_scene.fields
	data.merge({'total_visible_formula_pages': %TabContainer.total_visible_formulas, 'player_position': %Player.global_position, 'head_rotation': %Player.get_node('Head').global_rotation_degrees, 'camera_rotation': %Player.get_node('Head/Camera').global_rotation_degrees}, true)
	data['keyframe_texture'] = ImageTexture.create_from_image(%SubViewport.get_texture().get_image())
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
	
	reload_keyframes()

func reload_keyframes() -> void:
	for child in %Keyframes.get_children():
		%Keyframes.remove_child(child)
	
	for at_second in (keyframes.keys() as Array[float]):
		var keyframe_data: Dictionary = keyframes[at_second]
		var keyframe: Control = ANIMATION_TRACK_KEYFRAME_SCENE.instantiate()
		if not keyframe_data['keyframe_texture'] is EncodedObjectAsID:
			keyframe.image = keyframe_data['keyframe_texture']
		
		keyframe.data = keyframe_data
		#keyframe.position.x = at_pixel
		%Keyframes.add_child(keyframe)

func update_timeline() -> void:
	for child in %Timeline.get_children():
		%Timeline.remove_child(child)
	
	for i in 100 + 1:
		var label: Label = Label.new()
		label.add_theme_font_override('font', preload('res://resources/font/Rubik-SemiBold.ttf'))
		label.add_theme_font_size_override('font_side', 15)
		label.text = str(float(i))
		%Timeline.add_child(label)

func _process(delta: float) -> void:
	if is_mouse_hovering and Input.is_action_just_pressed('mouse click') and has_focus():
		insert_keyframe(get_global_mouse_position().x / 50.0)
	
	if is_playing and currently_at_frame >= len(animation_frames_data):
		is_playing = false
		
		if not %Time.get_parent().dragging:
			currently_at_frame = 0
		
		%PlayingToggleButton.icon = preload('res://resources/icons/play-solid.svg')

	if is_playing:
		get_tree().current_scene.update_app_state(animation_frames_data[round(currently_at_frame)], true, false, false, 0.51, true if currently_at_frame != 0 else false)
		
		# Save keyframe
		var image: Image = %SubViewport.get_texture().get_image()
		if image and is_rendering and currently_at_frame >= 2:
			var home_dir := OS.get_environment("HOME")
			var path := home_dir + "/renders/frame_" + str(currently_at_frame - 2) + ".png"
			image.save_png(path)
			#%Logs.print_console(path)
		
		if not is_rendering:
			currently_at_frame += 1.0 / delta
		else:
			currently_at_frame += 1.0
		%SubViewport.refresh_no_taa()

func _on_mouse_entered() -> void: is_mouse_hovering = true
func _on_mouse_exited() -> void: is_mouse_hovering = false

func _on_add_keyframe_button_pressed() -> void:
	var seconds: Array = keyframes.keys()
	seconds.append(0)
	insert_keyframe(seconds.max() + 1.0)
	stop()

func _on_set_time_start_button_pressed() -> void: currently_at_frame = 0
func _on_set_time_end_button_pressed() -> void: currently_at_frame = (len(keyframes) - 1) * 60.0

func _on_render_button_pressed() -> void:
	if is_playing:
		_on_playing_toggle_button_pressed()
		is_rendering = true
		_on_playing_toggle_button_pressed()
	else:
		is_rendering = true
		_on_playing_toggle_button_pressed()
