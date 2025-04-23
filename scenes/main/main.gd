extends Node3D

# Pseudo-constant variables
var VERSION := '0.8.0-beta'
var PHASE := VERSION.split('-')[-1]
var MAJOR := VERSION.split('.')[0]
var MINOR := VERSION.split('.')[1]
var PATCH := VERSION.split('.')[2].split('-')[0]

var fields: Dictionary = {}
var other_fields: Array = ['total_visible_formula_pages', 'player_position', 'head_rotation', 'camera_rotation']
var formulas: Array[Dictionary] = []
var using_dof: bool = false
var using_tiling: bool = false

func _ready() -> void:
	%Logs.print_console('Helium3D ' + VERSION)

func initialize_formulas(path_to_formulas: String) -> void:
	if formulas != []:
		return
	
	for formula_file_path in DirAccess.get_files_at(path_to_formulas):
		var formula_file: FileAccess = FileAccess.open(path_to_formulas + formula_file_path, FileAccess.READ)
		var formula_file_contents: String = formula_file.get_as_text()
		var data: Dictionary = parse_data(formula_file_contents)
		formulas.append(data)
	
	formulas.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["index"] < b["index"])

func parse_data(data: String) -> Dictionary:
	var result := {}

	# Extract index using regex
	var index_regex := RegEx.new()
	index_regex.compile(r"\/\/\s+\[INDEX\]\n\/\/\s+(\d+)")
	var index_match := index_regex.search(data)
	if index_match:
		result["index"] = int(index_match.get_string(1))

	# Extract formula ID using regex
	var id_regex := RegEx.new()
	id_regex.compile("// \\[ID\\]\\s*(.+)")
	var id_match := id_regex.search(data)
	if id_match:
		result["id"] = id_match.get_string(1).strip_edges().lstrip('/ ').to_lower().replace(' ', '')
		result["formatted_id"] = id_match.get_string(1).strip_edges().lstrip('/ ')

	# Extract code
	var code_match := data.find("// [CODE]")
	if code_match != -1:
		result["code"] = data.substr(code_match + 9).strip_edges()

	# Extract variables
	var var_regex := RegEx.new()
	var_regex.compile(r"(\w+) (\w+)\[([^\]]*)\] = (.+)")
	var variables := {}

	for m in var_regex.search_all(data):
		var var_type := m.get_string(1)
		var var_name := m.get_string(2)
		var values := m.get_string(3)
		var default_value := m.get_string(4).strip_edges()

		if var_type == "selection":
			var values_list := values.split(", ")
			variables[var_name] = {
				"type": "selection",
				"values": values_list,
				"default_value": default_value
			}
		elif var_type == "float" or var_type == "int":
			var range_vals := values.split(", ")
			var from_val: float = float(range_vals[0]) if "." in range_vals[0] else int(range_vals[0])
			var to_val: float = float(range_vals[1]) if "." in range_vals[1] else int(range_vals[1])
			variables[var_name] = {
				"type": var_type,
				"from": from_val,
				"to": to_val,
				"default_value": float(default_value) if "." in default_value else int(default_value)
			}
		elif var_type == "vec3" or var_type == "vec4":
			var vec_parts: Array = values.trim_prefix("(").trim_suffix(")").split("), (")
			var from_vec: Array = vec_parts[0].split(", ")
			var to_vec: Array = vec_parts[1].split(", ")
			var default_vec: Array = default_value.trim_prefix("(").trim_suffix(")").split(", ")

			if var_type == "vec3":
				variables[var_name] = {
					"type": "vec3",
					"from": Vector3(float(from_vec[0]), float(from_vec[1]), float(from_vec[2])),
					"to": Vector3(float(to_vec[0]), float(to_vec[1]), float(to_vec[2])),
					"default_value": Vector3(float(default_vec[0]), float(default_vec[1]), float(default_vec[2]))
				}
			elif var_type == 'vec4': # vec4
				variables[var_name] = {
					"type": "vec4",
					"from": Vector4(float(from_vec[0]), float(from_vec[1]), float(from_vec[2]), float(from_vec[3])),
					"to": Vector4(float(to_vec[0]), float(to_vec[1]), float(to_vec[2]), float(to_vec[3])),
					"default_value": Vector4(float(default_vec[0]), float(default_vec[1]), float(default_vec[2]), float(default_vec[3]))
				}
		elif var_type == "bool": # bool
			variables[var_name] = {
				"type": "bool",
				"default_value": default_value.to_lower() == "true"
			}

	result["variables"] = variables
	return result

func update_fields(new_fields: Dictionary) -> void:
	fields = new_fields
	for field_name in (new_fields.keys() as Array[String]):
		var field_val: Variant = new_fields[field_name]
		
		if field_val is Gradient:
			var gradient_texture: GradientTexture1D = GradientTexture1D.new()
			gradient_texture.gradient = field_val
			field_val = gradient_texture
		
		if field_val is Color:
			field_val = Vector3(field_val.r, field_val.g, field_val.b)
		
		%Fractal.material_override.set_shader_parameter(field_name, field_val)
	
	%TabContainer.update_field_values(fields)

func update_app_state(data: Dictionary, update_app_fields: bool = true, use_lerp: bool = false, update_keyframes: bool = true, delta_multiplier: float = 1.0, use_fast_diff: bool = false) -> void:
	var old_data: Dictionary = data.duplicate(true)
	data = data.duplicate(true)
	
	if 'other' not in data:
		data['other'] = {"keyframes": data.get("keyframes", {}), 'total_visible_formula_pages': data['total_visible_formula_pages'], 'player_position': data['player_position'], 'head_rotation': data['head_rotation'], 'camera_rotation': data['camera_rotation']}
		for other_field_name in (data['other'].keys() as Array[String]):
			data.erase(other_field_name)
	
	var other_data: Dictionary = data['other']
	var delta: float = get_process_delta_time() * delta_multiplier
	var player: Node = %Player
	var head: Node = %Player.get_node('Head')
	var camera: Node = %Player.get_node('Head').get_node('Camera')
	data.erase('other')
	
	if update_app_fields:
		update_fields(data)
	
	player.global_position = other_data['player_position']
	head.global_rotation_degrees = other_data['head_rotation']
	camera.global_rotation_degrees = other_data['camera_rotation']

	%TabContainer.total_visible_formulas = other_data.get('total_visible_formulas', count_non_zero(data.get('formulas', [1])))
	%SubViewport.refresh_taa()
	
	if update_keyframes:
		%AnimationTrack.keyframes = other_data.get('keyframes', {})
		%AnimationTrack.reload_keyframes()

func count_non_zero(numbers: Array) -> int:
	var count := 0
	
	for number in (numbers as Array[int]):
		if number != 0:
			count += 1
	
	return count

func _on_viewport_width_text_changed(new_text: String) -> void:
	if new_text.is_valid_float() or new_text.is_valid_int():
		var value: float = float(new_text)
		%SubViewport.size.x = value
		%SubViewport.refresh_taa()

func _on_viewport_height_text_changed(new_text: String) -> void:
	if new_text.is_valid_float() or new_text.is_valid_int():
		var value: float = float(new_text)
		%SubViewport.size.y = value
		%SubViewport.refresh_taa()

func update_fractal_code(current_formulas: Array[int]) -> void:
	var shader := %Fractal.material_override.shader as Shader
	var shader_code := shader.code
	
	var lines := shader_code.split("\n")
	var modified_lines := []
	
	for i in range(lines.size()):
		var line: String = lines[i]
		var is_formula_line := false
		var is_active_formula := false
		
		for formula in current_formulas:
			if line.ends_with("-@" + str(formula)):
				is_formula_line = true
				is_active_formula = true
				break
		
		if not is_active_formula:
			var regex := RegEx.new()
			regex.compile("-@\\d+$")
			if regex.search(line):
				is_formula_line = true
		
		if is_formula_line:
			if is_active_formula:
				if line.begins_with("//"):
					modified_lines.append(line.substr(2))
				else:
					modified_lines.append(line)
			else:
				if not line.begins_with("//"):
					modified_lines.append("//" + line)
				else:
					modified_lines.append(line)
		else:
			modified_lines.append(line)
	
	if using_dof:
		modified_lines[5] = (modified_lines[5] as String).lstrip('/')
	else:
		modified_lines[5] = '//' + (modified_lines[5] as String)
	
	if using_tiling:
		modified_lines[6] = (modified_lines[6] as String).lstrip('/')
	else:
		modified_lines[6] = '//' + (modified_lines[6] as String)
	
	shader.code = "\n".join(modified_lines)
	%Fractal.material_override.shader = shader

func get_usable_formulas() -> Array[int]:
	var list := []
	var shader_code: String = %Fractal.material_override.shader.code
	var lines: Array = shader_code.split("\n")
	
	for line in (lines as Array[String]):
		# Regular expression to check if line ends with -@ followed by one or more digits
		var regex := RegEx.new()
		regex.compile("-@(\\d+)$")
		var result := regex.search(line)
		
		if result:
			var formula_id := result.get_string(1)  # Extract the digits after -@
			list.append(int(formula_id))  # Convert to integer and add to list
	
	return list

# Shortcuts.
func _input(event: InputEvent) -> void:
	# Animation button shortcuts
	if %TextureRect.is_holding:
		return
	
	if Input.is_key_pressed(KEY_TAB) and Input.is_key_pressed(KEY_Q):
		%PlayingToggleButton.emit_signal("pressed")
	elif Input.is_key_pressed(KEY_TAB) and Input.is_key_pressed(KEY_W):
		%AddKeyframeButton.emit_signal("pressed")

	if Input.is_action_just_pressed('shortcut save all'):
		%SaveAll.pressed.emit()
	elif Input.is_action_just_pressed('shortcut save image'):
		%SavePicture.pressed.emit()
	elif Input.is_action_just_pressed('shortcut save project'):
		%Save.pressed.emit()
	
	if Input.is_action_just_pressed('shortcut load'):
		%Load.pressed.emit()
