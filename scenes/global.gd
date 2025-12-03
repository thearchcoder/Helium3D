extends Node

var value_nodes: Array[Control] = []

func add_spaces(text: String) -> String:
	var result := ""
	for i in range(text.length()):
		var character := text[i]
		if i > 0 and character == character.to_upper():
			result += " "
		result += character
	return result

func get_shader_field(field_name: String) -> Variant:
	return %Fractal.material_override.get_shader_parameter(field_name)

func action_occurred() -> void:
	if Engine.get_frames_drawn() > 0 and get_tree():
		get_tree().current_scene.action_occurred()

func path(linux_path: String) -> String:
	if OS.get_name() == "Windows":
		return linux_path.replace('/', '\\')
	return linux_path
