extends HBoxContainer

var chance: float = 20.0
var strength: float = 0.2

var current_generation: int = 0
var current_data: Dictionary = {}
var current_states: Array = []

var generations: Array[Dictionary]

func get_randomization_scenes() -> Array: 
	return $Scenes/VBoxContainer/RandomizedRow1.get_children() + $Scenes/VBoxContainer/RandomizedRow2.get_children()

func update_main() -> void: 
	current_data = get_tree().current_scene.get_app_state()

func use_state(scene: Node) -> void:
	var index: int = get_randomization_scenes().find(scene)
	get_tree().current_scene.update_app_state(current_states[index])

func generate_offspring(data: Dictionary) -> Dictionary:
	var offspring := data.duplicate(true)
	
	if randf() * 100.0 < chance:
		offspring["fmandelbulb_phase"] = _mutate_float(offspring["fmandelbulb_phase"], 0.0, 360.0)
	if randf() * 100.0 < chance:
		offspring["fmandelbulb_power"] = _mutate_float(offspring["fmandelbulb_power"], 1.0, 16.0)
	if randf() * 100.0 < chance:
		offspring["fmandelbulb_z_mul"] = _mutate_float(offspring["fmandelbulb_z_mul"], 0.1, 2.0)
	if randf() * 100.0 < chance:
		offspring["fmandelbulb_conjugate"] = randf() < 0.5
	if randf() * 100.0 < chance:
		offspring["fmandelbulb_abs_x"] = randf() < 0.5
	if randf() * 100.0 < chance:
		offspring["fmandelbulb_abs_y"] = randf() < 0.5
	if randf() * 100.0 < chance:
		offspring["fmandelbulb_abs_z"] = randf() < 0.5
	if randf() * 100.0 < chance:
		offspring["fmandelbulb_is_julia"] = randf() < 0.5
	if randf() * 100.0 < chance:
		offspring["fmandelbulb_julia_c"] = _mutate_vector4(offspring["fmandelbulb_julia_c"], 0.0, 1.0)
	if randf() * 100.0 < chance:
		offspring["fmandelbulb_derivative_bias"] = _mutate_float(offspring["fmandelbulb_derivative_bias"], 0.1, 2.0)
	
	if randf() * 100.0 < chance:
		offspring["rotation"] = _mutate_vector3(offspring["rotation"], -180.0, 180.0)
	if randf() * 100.0 < chance:
		offspring["kalaidoscope"] = _mutate_vector3(offspring["kalaidoscope"], 1.0, 8.0)
	
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

func _mutate_vector4(value: Vector4, min_val: float, max_val: float) -> Vector4:
	return Vector4(
		_mutate_float(value.x, min_val, max_val),
		_mutate_float(value.y, min_val, max_val),
		_mutate_float(value.z, min_val, max_val),
		_mutate_float(value.w, min_val, max_val)
	)

func _mutate_color(value: Color) -> Color:
	return Color(
		_mutate_float(value.r, 0.0, 1.0),
		_mutate_float(value.g, 0.0, 1.0),
		_mutate_float(value.b, 0.0, 1.0),
		value.a
	)

func randomization() -> void:
	current_states.clear()
	
	for i in len(get_randomization_scenes()):
		current_states.append(generate_offspring(current_data))
