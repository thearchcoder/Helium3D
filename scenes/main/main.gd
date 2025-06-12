extends Node3D

# Pseudo-constant variables
var VERSION := '0.9.0-beta'
var PHASE := VERSION.split('-')[-1]
var MAJOR := VERSION.split('.')[0]
var MINOR := VERSION.split('.')[1]
var PATCH := VERSION.split('.')[2].split('-')[0]

@onready var HELIUM3D_PATH: String = OS.get_environment("HOME") + "/.hlm"
var taa_samples: int = 2
var fields: Dictionary = {}
var other_fields: Array = ['total_visible_formula_pages', 'player_position', 'head_rotation', 'camera_rotation']
var formulas: Array[Dictionary] = []
var using_dof: bool = false
var using_tiling: bool = false
var using_reflections: bool = false
var busy_rendering_tiles: bool = false
var difficulty: String = 'simple':
	set(value):
		difficulty = value
		%TabContainer.get_node('Formula/TabContainer').set_difficulty(difficulty)

func _ready() -> void:
	%Logs.print_console('Helium3D ' + VERSION)
	
	var dir := DirAccess.open("res://")
	if not dir.dir_exists(HELIUM3D_PATH):
		dir.make_dir(HELIUM3D_PATH)
	
	# Make sure the BG panel is behind the fields in the %AnimationSettings node.
	await get_tree().process_frame
	%AnimationSettings.move_child(%AnimationSettings.get_node('BackPanel'), 0)

func get_formulas_forloop_code() -> Array:
	initialize_formulas('res://formulas/')
	var formulas_forloop_code: Array = []
	for formula in formulas:
		for i in range(formulas.size()):
			if formula['difs']:
				formulas_forloop_code.append('//if (current_formula == ' + str(formula['index']) + ') using_' + formula['id'] + ' = true; //-@' + str(formula['index']))
			else:
				var params: String = 'z, dz, original_z, orbit, i'
				if formula['id'] == 'kochcube':
					params += ', s'
				
				formulas_forloop_code.append('//if (current_formula == ' + str(formula['index']) + ') ' + formula['id'] + '_iter(' + params + '); //-@' + str(formula['index']))
			break
	
	return formulas_forloop_code
	#print('// -@Formulas' in %Fractal.material_override.shader.code)
	#%Fractal.material_override.shader.code = %Fractal.material_override.shader.code.replace('// -@Formulas', '\n'.join(formulas_forloop_code))
	#print('// -@Formulas' in %Fractal.material_override.shader.code)
	#var file: FileAccess = FileAccess.open('shader_code_ready', FileAccess.WRITE)
	#file.store_string(%Fractal.material_override.shader.code)
	#file.close()

func get_app_state(optimize_for_clipboard: bool = false) -> Dictionary:
	var data: Dictionary = fields.duplicate(true)
	var other_data: Dictionary = {}
	
	other_data["app_version"] = get_tree().current_scene.VERSION
	other_data["total_visible_formula_pages"] = %TabContainer.total_visible_formulas
	other_data["player_position"] = %Player.global_position
	other_data["head_rotation"] = %Player.get_node("Head").global_rotation_degrees
	other_data["camera_rotation"] = %Player.get_node("Head/Camera").global_rotation_degrees
	other_data["keyframes"] = %AnimationTrack.keyframes
	
	if optimize_for_clipboard:
		for value_node in Global.value_nodes:
			if value_node.get_node('../../../../../..').name == 'Buffer':
				if value_node.get_meta('formula_index') != 0 and value_node.get_meta('formula_index') not in %TabContainer.current_formulas:
					data.erase(value_node.get_meta('uniform_name'))
	
	data["other"] = other_data
	
	return data

func initialize_formulas(path_to_formulas: String) -> void:
	if formulas != []:
		return
	
	var directories_to_process: Array[String] = [path_to_formulas]
	
	while directories_to_process.size() > 0:
		var current_dir_path: String = directories_to_process.pop_back()
		var dir: DirAccess = DirAccess.open(current_dir_path)
		
		if dir == null:
			continue
		
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		
		while file_name != "":
			var full_path: String = current_dir_path + "/" + file_name
			
			if dir.current_is_dir():
				directories_to_process.append(full_path)
			else:
				if not file_name.get_extension().ends_with('uid'):
					var formula_file: FileAccess = FileAccess.open(full_path, FileAccess.READ)
					if formula_file != null:
						var formula_file_contents: String = formula_file.get_as_text()
						var data: Dictionary = parse_data(formula_file_contents)
						
						# Some external tag data
						if '// [DIFS]' in formula_file_contents:
							data['difs'] = true
						else:
							data['difs'] = false
						
						if current_dir_path.get_file() == "mb3d":
							data['software'] = 'Mandelbulb3D'
						else:
							data['software'] = 'Helium3D'
						
						formulas.append(data)
						formula_file.close()
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	formulas.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["index"] < b["index"])

func parse_data(data: String) -> Dictionary:
	var result := {}
	var index_regex := RegEx.new()
	index_regex.compile(r"\/\/\s+\[INDEX\]\n\/\/\s+(\d+)")
	var index_match := index_regex.search(data)
	if index_match:
		result["index"] = int(index_match.get_string(1))
	
	var id_regex := RegEx.new()
	id_regex.compile("// \\[ID\\]\\s*(.+)")
	var id_match := id_regex.search(data)
	if id_match:
		result["id"] = id_match.get_string(1).strip_edges().lstrip('/ ').to_lower().replace(' ', '')
		result["formatted_id"] = id_match.get_string(1).strip_edges().lstrip('/ ')
	
	var code_match := data.find("// [CODE]")
	if code_match != -1:
		result["code"] = data.substr(code_match + 9).strip_edges()
	
	var var_regex := RegEx.new()
	var_regex.compile(r"(?:(advanced|simple)\s+)?(\w+)\s+(\w+)\[([^\]]*)\]\s*=\s*(.+)")
	var variables := {}
	
	for m in var_regex.search_all(data):
		var difficulty := m.get_string(1)
		var var_type := m.get_string(2)
		var var_name := m.get_string(3)
		var values := m.get_string(4)
		var default_value := m.get_string(5).strip_edges()
		
		if var_type == "selection":
			var values_list := values.split(", ")
			variables[var_name] = {
				"type": "selection",
				"values": values_list,
				"default_value": default_value,
				"difficulty": difficulty if difficulty else "medium"
			}
		elif var_type == "float" or var_type == "int":
			var range_vals := values.split(", ")
			var from_val: float = float(range_vals[0]) if "." in range_vals[0] else int(range_vals[0])
			var to_val: float = float(range_vals[1]) if "." in range_vals[1] else int(range_vals[1])
			variables[var_name] = {
				"type": var_type,
				"from": from_val,
				"to": to_val,
				"default_value": float(default_value) if "." in default_value else int(default_value),
				"difficulty": difficulty if difficulty else "medium"
			}
		elif var_type == "vec3" or var_type == "vec4" or var_type == "vec2":
			var vec_parts: Array = values.trim_prefix("(").trim_suffix(")").split("), (")
			var from_vec: Array = vec_parts[0].split(", ")
			var to_vec: Array = vec_parts[1].split(", ")
			var default_vec: Array = default_value.trim_prefix("(").trim_suffix(")").split(", ")
			
			if var_type == "vec3":
				variables[var_name] = {
					"type": "vec3",
					"from": Vector3(float(from_vec[0]), float(from_vec[1]), float(from_vec[2])),
					"to": Vector3(float(to_vec[0]), float(to_vec[1]), float(to_vec[2])),
					"default_value": Vector3(float(default_vec[0]), float(default_vec[1]), float(default_vec[2])),
					"difficulty": difficulty if difficulty else "medium"
				}
			elif var_type == 'vec4':
				variables[var_name] = {
					"type": "vec4",
					"from": Vector4(float(from_vec[0]), float(from_vec[1]), float(from_vec[2]), float(from_vec[3])),
					"to": Vector4(float(to_vec[0]), float(to_vec[1]), float(to_vec[2]), float(to_vec[3])),
					"default_value": Vector4(float(default_vec[0]), float(default_vec[1]), float(default_vec[2]), float(default_vec[3])),
					"difficulty": difficulty if difficulty else "medium"
				}
			elif var_type == 'vec2':
				variables[var_name] = {
					"type": "vec2",
					"from": Vector2(float(from_vec[0]), float(from_vec[1])),
					"to": Vector2(float(to_vec[0]), float(to_vec[1])),
					"default_value": Vector2(float(default_vec[0]), float(default_vec[1])),
					"difficulty": difficulty if difficulty else "medium"
				}
		elif var_type == "bool":
			variables[var_name] = {
				"type": "bool",
				"default_value": default_value.to_lower() == "true",
				"difficulty": difficulty if difficulty else "medium"
			}
	
	result["variables"] = variables
	return result

func update_fields(new_fields: Dictionary) -> void:
	fields.merge(new_fields, true)
	for field_name in (new_fields.keys() as Array[String]):
		var field_val: Variant = new_fields[field_name]
		
		if field_val is EncodedObjectAsID:
			field_val = instance_from_id(field_val.object_id)
		
		if field_val is Color:
			field_val = Vector3(field_val.r, field_val.g, field_val.b)
		
		if field_val is Dictionary and (field_val as Dictionary).has('special_field'):
			if field_val['type'] == 'image':
				if ResourceLoader.exists(field_val['path']):
					field_val = load(field_val['path'])
				else:
					field_val = null
			elif field_val['type'] == 'palette':
				var gradient: Gradient = Gradient.new()
				gradient.offsets = field_val['offsets']
				gradient.colors = field_val['colors']
				gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT if not field_val['is_blurry'] else Gradient.GRADIENT_INTERPOLATE_CUBIC
				field_val = GradientTexture1D.new()
				field_val.gradient = gradient
		
		%Fractal.material_override.set_shader_parameter(field_name, field_val)
	
	%TabContainer.update_field_values(new_fields) # Update node values as well

func update_app_state(data: Dictionary, update_keyframes: bool = true) -> void:
	var old_data: Dictionary = data.duplicate(true)
	data = data.duplicate(true)
	
	if 'other' not in data:
		data['other'] = {"keyframes": data.get("keyframes", {}), 'total_visible_formula_pages': data['total_visible_formula_pages'], 'player_position': data['player_position'], 'head_rotation': data['head_rotation'], 'camera_rotation': data['camera_rotation']}
		for other_field_name in (data['other'].keys() as Array[String]):
			data.erase(other_field_name)
	
	var other_data: Dictionary = data['other']
	var player: Node = %Player
	var head: Node = %Player.get_node('Head')
	var camera: Node = %Player.get_node('Head').get_node('Camera')
	data.erase('other')
	
	if data.has('formulas') and data['formulas'] == %TabContainer.current_formulas:
		# Switching formulas each frame in the animation is very expensive.
		data.erase('formulas')
	
	update_fields(data)
	
	player.global_position = other_data['player_position']
	head.global_rotation_degrees = other_data['head_rotation']
	camera.global_rotation_degrees = other_data['camera_rotation']

	var new_total_visible_formulas: int = %TabContainer.total_visible_formulas
	
	if other_data.has('total_visible_formulas'):
		new_total_visible_formulas = other_data['total_visible_formulas']
	elif data.has('formulas'): 
		new_total_visible_formulas = count_non_zero(data['formulas'])
	
	if %TabContainer.total_visible_formulas != new_total_visible_formulas:
		%TabContainer.total_visible_formulas = new_total_visible_formulas
	
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
	var formulas_forloop_code: Array = get_formulas_forloop_code()
	
	if '// -@Formulas' in shader_code:
		shader_code = shader_code.replace('// -@Formulas', '\n'.join(formulas_forloop_code))
	
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
	
	if using_reflections:
		modified_lines[7] = (modified_lines[7] as String).lstrip('/')
	else:
		modified_lines[7] = '//' + (modified_lines[7] as String)
	
	shader.code = "\n".join(modified_lines)
	%Fractal.material_override.shader = shader

# Shortcuts
func _input(event: InputEvent) -> void:
	# Animation button shortcuts
	if %TextureRect.is_holding:
		return
	
	if Input.is_key_pressed(KEY_TAB) and Input.is_key_pressed(KEY_Q):
		%PlayingToggleButton.emit_signal("pressed")
	elif Input.is_key_pressed(KEY_TAB) and Input.is_key_pressed(KEY_W):
		%AddKeyframeButton.emit_signal("pressed")

	if Input.is_action_just_pressed('shortcut save project'):
		%Save.get_popup().id_pressed.emit(1)
	elif Input.is_action_just_pressed('shortcut save all'):
		%Save.get_popup().id_pressed.emit(0)
	elif Input.is_action_just_pressed('shortcut save image'):
		%Save.get_popup().id_pressed.emit(2)
	
	if Input.is_action_just_pressed('shortcut load'):
		%Load.get_popup().id_pressed.emit(1)
	
	if Input.is_action_just_pressed('shortcut load clipboard'):
		%Load.get_popup().id_pressed.emit(0)
	elif Input.is_action_just_pressed('shortcut save clipboard'):
		%Save.get_popup().id_pressed.emit(3)

func _on_difficulty_pressed() -> void:
	if difficulty == 'simple':
		difficulty = 'advanced'
	elif difficulty == 'advanced':
		difficulty = 'simple'
	
	%Difficulty.text = difficulty.to_pascal_case()
