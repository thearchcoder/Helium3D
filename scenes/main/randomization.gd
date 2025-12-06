extends HBoxContainer

var chance: float = 20.0
var strength: float = 0.2

var current_data: Dictionary = {}
var randomized: Dictionary = {}

var decided_randomization: Dictionary = {'is_null': true}
var undecided_randomization: Dictionary = {'is_null': true}

var last_randomized_scene_data: Dictionary = {'is_null': true}
var randomized_history: Array[Dictionary] = []
var randomized_history_at: int = -1

func get_randomization_data() -> Dictionary:
	return {
		'current_data': current_data,
		'randomized': randomized,
		'decided_randomization': decided_randomization,
		'undecided_randomization': undecided_randomization,
		'last_randomized_scene_data': last_randomized_scene_data,
		'randomized_history': randomized_history,
		'randomized_history_at': randomized_history_at
	}

func load_randomization_data(data: Dictionary) -> void:
	current_data = data.get('current_data', {})
	randomized = data.get('randomized', {})
	decided_randomization = data.get('decided_randomization', {'is_null': true})
	undecided_randomization = data.get('undecided_randomization', {'is_null': true})
	last_randomized_scene_data = data.get('last_randomized_scene_data', {'is_null': true})
	randomized_history = data.get('randomized_history', [])
	randomized_history_at = data.get('randomized_history_at', -1)

	if randomized_history_at >= 0 and randomized_history.size() > 0:
		%PageText.text = "Page " + str(randomized_history_at + 1)

func add_to_history(val: Dictionary) -> void:
	randomized_history_at += 1
	randomized_history.insert(randomized_history_at, val)
	randomized_history_at = clamp(randomized_history_at, 0, len(randomized_history) - 1)

	%PageText.text = "Page " + str(randomized_history_at + 1)

func filter_non_randomization_fields(state: Dictionary) -> Dictionary:
	var result: Dictionary = state.duplicate(true)
	if result.has("other"):
		if result["other"].has("player_position"): result["other"].erase("player_position")
		if result["other"].has("head_rotation"): result["other"].erase("head_rotation")
		if result["other"].has("camera_rotation"): result["other"].erase("camera_rotation")
	
	return result

func update_base_scene() -> void: 
	current_data = get_tree().current_scene.get_app_state()
	%BaseScene.texture = ImageTexture.create_from_image(%TextureRect.get_texture().get_image())

func use_state() -> void:
	decided_randomization = randomized
	get_tree().current_scene.update_app_state(filter_non_randomization_fields(randomized))
	last_randomized_scene_data = randomized
	add_to_history(randomized)

func generate_offspring(data: Dictionary) -> Dictionary:
	var offspring := data.duplicate(true)
	var main := get_tree().current_scene
	var current_formulas: Array[int] = %TabContainer.current_formulas
	
	var mutated := false
	var mutations_done := 0
	
	if randf() * 100.0 < chance:
		offspring["rotation"] = _mutate_vector3(offspring["rotation"], -180.0, 180.0)
		mutated = true
		mutations_done += 1
	if randf() * 100.0 < chance:
		offspring["kalaidoscope"] = _mutate_vector3(offspring["kalaidoscope"], 1.0, 8.0)
		mutated = true
		mutations_done += 1
	
	for formula_index in current_formulas:
		if formula_index <= 0:
			continue
		
		var formula_data: Dictionary = main.get_formula_data_from_index(formula_index)
		if formula_data.is_empty():
			continue
		
		var formula_id: String = formula_data['id']
		var variables: Dictionary = formula_data['variables']
		
		for var_name in (variables.keys() as Array[String]):
			var var_data: Dictionary = variables[var_name]
			var uniform_name: String = 'f' + formula_id + '_' + var_name
			
			if not offspring.has(uniform_name):
				continue
			
			if randf() * 100.0 >= chance:
				continue
			
			match var_data['type']:
				'float':
					offspring[uniform_name] = _mutate_float(offspring[uniform_name], var_data['from'], var_data['to'])
				'int':
					offspring[uniform_name] = _mutate_int(offspring[uniform_name], var_data['from'], var_data['to'])
				'vec3':
					offspring[uniform_name] = _mutate_vector3_ranged(offspring[uniform_name], var_data['from'], var_data['to'])
				'vec4':
					offspring[uniform_name] = _mutate_vector4_ranged(offspring[uniform_name], var_data['from'], var_data['to'])
				'vec2':
					offspring[uniform_name] = _mutate_vector2_ranged(offspring[uniform_name], var_data['from'], var_data['to'])
				'bool':
					offspring[uniform_name] = randf() < 0.5
				'selection':
					var values: Array = var_data['values']
					offspring[uniform_name] = values[randi() % values.size()]
			
			mutated = true
			mutations_done += 1
	
	if not mutated:
		offspring["rotation"] = _mutate_vector3(offspring["rotation"], -180.0, 180.0)
	
	return offspring

func _mutate_float(value: float, min_val: float, max_val: float) -> float:
	var delta := (max_val - min_val) * strength * randf_range(-1.0, 1.0)
	return clamp(value + delta, min_val, max_val)

func _mutate_int(value: int, min_val: int, max_val: int) -> int:
	var range_size := max_val - min_val
	var delta := int(range_size * strength * randf_range(-1.0, 1.0))
	return clamp(value + delta, min_val, max_val)

func _mutate_vector3(value: Vector3, min_val: float, max_val: float) -> Vector3:
	return Vector3(
		_mutate_float(value.x, min_val, max_val),
		_mutate_float(value.y, min_val, max_val),
		_mutate_float(value.z, min_val, max_val)
	)

func _mutate_vector3_ranged(value: Vector3, from: Vector3, to: Vector3) -> Vector3:
	return Vector3(
		_mutate_float(value.x, from.x, to.x),
		_mutate_float(value.y, from.y, to.y),
		_mutate_float(value.z, from.z, to.z)
	)

func _mutate_vector4(value: Vector4, min_val: float, max_val: float) -> Vector4:
	return Vector4(
		_mutate_float(value.x, min_val, max_val),
		_mutate_float(value.y, min_val, max_val),
		_mutate_float(value.z, min_val, max_val),
		_mutate_float(value.w, min_val, max_val)
	)

func _mutate_vector4_ranged(value: Vector4, from: Vector4, to: Vector4) -> Vector4:
	return Vector4(
		_mutate_float(value.x, from.x, to.x),
		_mutate_float(value.y, from.y, to.y),
		_mutate_float(value.z, from.z, to.z),
		_mutate_float(value.w, from.w, to.w)
	)

func _mutate_vector2_ranged(value: Vector2, from: Vector2, to: Vector2) -> Vector2:
	return Vector2(
		_mutate_float(value.x, from.x, to.x),
		_mutate_float(value.y, from.y, to.y)
	)

func _mutate_color(value: Color) -> Color:
	return Color(
		_mutate_float(value.r, 0.0, 1.0),
		_mutate_float(value.g, 0.0, 1.0),
		_mutate_float(value.b, 0.0, 1.0),
		value.a
	)

func randomization() -> void:
	randomized = generate_offspring(current_data)
	randomized.erase('chance')
	randomized.erase('strength')
	get_tree().current_scene.update_app_state(filter_non_randomization_fields(randomized))
	last_randomized_scene_data = randomized
	add_to_history(randomized)
	%RandomizedScene.texture = %TextureRect.get_texture()
	%Randomize.release_focus()
	%RandomizeLayered.release_focus()
	decided_randomization = {'is_null': true}

func layered_randomization() -> void:
	randomized = generate_offspring(randomized if randomized else current_data)
	randomized.erase('chance')
	randomized.erase('strength')
	get_tree().current_scene.update_app_state(filter_non_randomization_fields(randomized))
	last_randomized_scene_data = randomized
	add_to_history(randomized)
	%RandomizedScene.texture = %TextureRect.get_texture()
	%Randomize.release_focus()
	%RandomizeLayered.release_focus()
	decided_randomization = {'is_null': true}

func _process(_delta: float) -> void:
	if not get_parent().visible:
		return
	
	if Input.is_action_just_pressed('r'):
		randomization()
	if Input.is_action_just_pressed('l'):
		layered_randomization()

func _on_page_left_pressed() -> void:
	randomized_history_at -= 1
	randomized_history_at = clamp(randomized_history_at, 0, len(randomized_history) - 1)

	get_tree().current_scene.update_app_state(filter_non_randomization_fields(randomized_history[randomized_history_at]))
	randomized = randomized_history[randomized_history_at]
	%PageText.text = "Page " + str(randomized_history_at + 1)

func _on_page_right_pressed() -> void:
	randomized_history_at += 1
	randomized_history_at = clamp(randomized_history_at, 0, len(randomized_history) - 1)
	
	get_tree().current_scene.update_app_state(filter_non_randomization_fields(randomized_history[randomized_history_at]))
	randomized = randomized_history[randomized_history_at]
	%PageText.text = "Page " + str(randomized_history_at + 1)
