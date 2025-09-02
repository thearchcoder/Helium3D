extends Node3D

var VERSION := '0.9.1-beta'
var PHASE := VERSION.split('-')[-1]
var MAJOR := VERSION.split('.')[0]
var MINOR := VERSION.split('.')[1]
var PATCH := VERSION.split('.')[2].split('-')[0]

const MAX_FORMULAS := 10
const LAZY_IMPORTING := true
const VAR_TEMPLATES := {
	'kifs_rotation': [
		'vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)',
		'vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)'
	],
	'transform_range': [
		'vec2 range[(0, 0), (100, 100)] = (0, 100)'
	],
	'advanced_kifs_rotation': [
		'advanced vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)',
		'advanced vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)'
	]
}

@onready var HELIUM3D_PATH: String = OS.get_environment("HOME") + "/.hlm"
var advanced_ui_fields: Array[Control] = []
var taa_samples: int = 2
var fields: Dictionary = {}
var other_fields: Array = ['total_visible_formula_pages', 'player_position', 'head_rotation', 'camera_rotation']
var formulas: Array[Dictionary] = []
var using_dof: bool = false
var using_tiling: bool = false
var author: String = ''
var using_reflections: bool = false
var busy_rendering_tiles: bool = false
var difficulty: String = 'simple':
	set(value):
		difficulty = value
		%TabContainer.get_node('Formula/TabContainer').set_difficulty(difficulty)

var history: Array[Dictionary] = []
var history_at: int = -1
var last_saved_state: Dictionary = {}
var is_applying_history: bool = false
var white_display: Image

var previous_frame_texture: ImageTexture

func _ready() -> void:
	%Logs.print_console('Helium3D ' + VERSION)
	$AboutWindow/HBoxContainer/VBoxContainer2/RichTextLabel.text = $AboutWindow/HBoxContainer/VBoxContainer2/RichTextLabel.text.replace('{version}', VERSION)
	
	var dir := DirAccess.open("res://")
	if not dir.dir_exists(HELIUM3D_PATH):
		dir.make_dir(HELIUM3D_PATH)
	
	if FileAccess.file_exists(HELIUM3D_PATH + '/heartbeat.hlm') and FileAccess.file_exists(HELIUM3D_PATH + '/autosave.hlm'):
		crash_detected()
	else:
		var file: FileAccess = FileAccess.open(HELIUM3D_PATH + '/heartbeat.hlm', FileAccess.WRITE)
		file.close()
	
	await RenderingServer.frame_post_draw
	DisplayServer.window_set_title("Helium3D", get_window().get_window_id())
	action_occurred(false)
	
	var viewport_texture: ViewportTexture = %PostViewport.get_texture()
	var viewport_image: Image = viewport_texture.get_image()
	var viewport_size: Vector2i = viewport_image.get_size()
	var viewport_format := viewport_image.get_format()
	
	var image := Image.create(viewport_size.x, viewport_size.y, false, viewport_format)
	previous_frame_texture = ImageTexture.create_from_image(image)
	
	%PostDisplay.material.set_shader_parameter('previous_frame', previous_frame_texture)
	%Fractal.material_override.set_shader_parameter('previous_frame', previous_frame_texture)
	
	# By default the difficulty is simple, So hide the advanced fields by updating the UI fields.
	toggle_ui_difficulty()

func action_occurred(add_to_history: bool = true, group_changes: bool = false) -> void:
	if is_applying_history:
		return
	
	var current_state: Dictionary = get_app_state()
	var changes: Dictionary = get_state_changes(last_saved_state, current_state)
	
	if changes.is_empty():
		return
	
	if history_at < history.size() - 1:
		history = history.slice(0, history_at + 1)
	
	# Create separate history entries for each changed field
	if group_changes:
		# Original behavior - group all changes together
		var history_entry: Dictionary = {
			"old_values": {},
			"new_values": changes,
			"timestamp": Time.get_unix_time_from_system()
		}
		
		for key: String in (changes.keys() as Array[String]):
			if last_saved_state.has(key):
				history_entry["old_values"][key] = last_saved_state[key]
			else:
				history_entry["old_values"][key] = null
		
		if add_to_history:
			history.append(history_entry)
			history_at = history.size() - 1
	else:
		# New behavior - separate entry for each field
		var changes_keys: Array = changes.keys()
		changes_keys.reverse()
		for key: String in (changes_keys as Array[String]):
			var old_value: Variant = null
			if last_saved_state.has(key):
				old_value = last_saved_state[key]
			
			var history_entry: Dictionary = {
				"old_values": {key: old_value},
				"new_values": {key: changes[key]},
				"timestamp": Time.get_unix_time_from_system()
			}
			
			if add_to_history:
				history.append(history_entry)
				history_at = history.size() - 1
	
	last_saved_state = current_state.duplicate(true)
	
	# Clean up history if too long
	while history.size() > 100:
		history.pop_front()
		history_at -= 1

func get_state_changes(old_state: Dictionary, new_state: Dictionary) -> Dictionary:
	var changes: Dictionary = {}
	
	for key: String in (new_state.keys() as Array[String]):
		if not old_state.has(key) or old_state[key] != new_state[key]:
			changes[key] = new_state[key]
	
	for key: String in (old_state.keys() as Array[String]):
		if not new_state.has(key):
			changes[key] = null
	
	return changes

func undo() -> void:
	if history_at < 0:
		return
	
	var entry: Dictionary = history[history_at]
	is_applying_history = true
	apply_changes(entry["old_values"])
	is_applying_history = false
	
	history_at -= 1

func redo() -> void:
	if history_at >= history.size() - 1:
		return
	
	history_at += 1
	var entry: Dictionary = history[history_at]
	is_applying_history = true
	apply_changes(entry["new_values"])
	is_applying_history = false

func get_reverse_changes(changes: Dictionary) -> Dictionary:
	var reverse: Dictionary = {}
	var current_state: Dictionary = get_app_state()
	
	for key: String in (changes.keys() as Array[String]):
		if current_state.has(key):
			reverse[key] = current_state[key]
		else:
			reverse[key] = null
	
	return reverse

func apply_changes(changes: Dictionary) -> void:
	var state_to_apply: Dictionary = {}
	
	for key: String in (changes.keys() as Array[String]):
		if changes[key] != null:
			state_to_apply[key] = changes[key]
	
	if not state_to_apply.is_empty():
		update_app_state(state_to_apply, true)
	
	if not is_applying_history:
		last_saved_state = get_app_state().duplicate(true)

func initialize_history() -> void:
	last_saved_state = get_app_state().duplicate(true)
	history.clear()
	history_at = -1

func _process(_delta: float) -> void:
	var current_image: Image = %PostViewport.get_texture().get_image()
	%PostDisplay.material.set_shader_parameter('previous_frame', ImageTexture.create_from_image(current_image))
	%Fractal.material_override.set_shader_parameter('previous_frame', previous_frame_texture)
	
	if Input.is_action_just_pressed('escape'):
		if $AboutWindow.visible: $AboutWindow.visible = false
		if $SettingsWindow.visible: $SettingsWindow.visible = false
		if $CrashSaveWindow.visible: $CrashSaveWindow.visible = false
		if $AuthorWindow.visible: $AuthorWindow.visible = false
		if $RandomizeWindow.visible: $RandomizeWindow.visible = false
		if $VoxelizeWindow.visible: $VoxelizeWindow.visible = false
	
	%Fractal.material_override.set_shader_parameter('voxelization', $VoxelizeWindow.visible)
	
	%Export.disabled = $VoxelizedMeshWorld/Mesh.mesh == null

func _input(event: InputEvent) -> void:
	if %TextureRect.is_holding:
		return
	
	if Input.is_action_just_pressed('undo'):
		undo()
		return
	elif Input.is_action_just_pressed('redo'):
		redo()
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

func expand_templates(formula_content: String) -> String:
	var lines := formula_content.split('\n')
	var expanded_lines: Array[String] = []
	
	for line in lines:
		var trimmed_line := line.strip_edges()
		if trimmed_line.begins_with('// template '):
			var template_name := trimmed_line.substr(12).strip_edges()
			for template_var in (VAR_TEMPLATES[template_name] as Array[String]):
				expanded_lines.append('// ' + template_var)
		else:
			expanded_lines.append(line)
	
	return '\n'.join(expanded_lines)

func get_formulas_forloop_code() -> Array:
	initialize_formulas('res://formulas/')
	var formulas_forloop_code: Array = []
	for formula in formulas:
		for i: int in range(formulas.size()):
			if formula['type'] == 'difs' or formula['type'] == 'primitive':
				continue
			else:
				var params: String = 'z, dz, original_z, orbit, i'
				if formula['id'] == 'kochcube':
					params += ', s'
				
				formulas_forloop_code.append('//if (current_formula == ' + str(formula['index']) + ') ' + formula['id'] + '_iter(' + params + '); //-@' + str(formula['index']))
			break
	
	return formulas_forloop_code

func get_formulas_import_code() -> Array:
	var formulas_import_code := []
	
	for formula in formulas:
		var import_check: String = ' // -@' + str(formula['index']) if LAZY_IMPORTING else ''
		formulas_import_code.append('#include "res://formulas/' + formula['id'] + '.gdshaderinc"' + import_check)
	
	return formulas_import_code

func get_formula_data_from_name(id: String, formatted_id: bool = true) -> Dictionary:
	for formula in formulas:
		if (formula['formatted_id'] if formatted_id else formula['id']) == id:
			return formula
	return {}

func get_formula_data_from_index(index: int) -> Dictionary:
	for formula in formulas:
		if formula['index'] == index:
			return formula
	return {}

func get_app_state(optimize_for_clipboard: bool = false) -> Dictionary:
	var data: Dictionary = fields.duplicate(true)
	var other_data: Dictionary = {}
	
	other_data["app_version"] = get_tree().current_scene.VERSION
	other_data["total_visible_formula_pages"] = %TabContainer.total_visible_formulas
	other_data["player_position"] = %Player.global_position
	other_data["head_rotation"] = %Player.get_node("Head").global_rotation_degrees
	other_data["camera_rotation"] = %Player.get_node("Head/Camera").global_rotation_degrees
	other_data["keyframes"] = %AnimationTrack.keyframes
	other_data["fps"] = %AnimationTrack.fps
	other_data["interpolation"] = %AnimationTrack.interpolation
	other_data["keyframe_length"] = %AnimationTrack.keyframe_length
	other_data["author"] = author
	other_data["library"] = {}
	
	if optimize_for_clipboard:
		for value_node in Global.value_nodes:
			if value_node.get_node('../../../../../..').name == 'Buffer':
				if value_node.get_meta('formula_index') != 0 and value_node.get_meta('formula_index') not in %TabContainer.current_formulas:
					data.erase(value_node.get_meta('uniform_name'))
	
	data["other"] = other_data
	
	return data

func create_duplicate(formula_name: String, var_data: Dictionary, original_content: String, path_to_formulas: String, dupe_identifier: String) -> void:
	var path := path_to_formulas + formula_name + 'dupe' + dupe_identifier + '.gdshaderinc'
	var file := FileAccess.open(path, FileAccess.WRITE)

	var content := original_content
	var lines := content.split('\n')

	for i in range(lines.size()):
		var prevent_replacement := false
		
		if i > 0 and lines[i - 1].strip_edges().begins_with("// [PREVENT-REPLACEMENT]"):
			prevent_replacement = true
		
		if not prevent_replacement:
			lines[i] = lines[i].replace(formula_name, formula_name + 'dupe' + dupe_identifier)
		
		# Add " Dupe X" to second line (index 1) if it exists
		if i == 1 and lines.size() > 1:
			lines[i] += ' Dupe ' + dupe_identifier.capitalize()

	content = '\n'.join(lines)

	file.store_string(content)
	file.close()

func initialize_formulas(path_to_formulas: String) -> void:
	if formulas != []:
		return
	
	var paths: PackedStringArray = DirAccess.get_files_at(path_to_formulas)
	var skipped_formulas: int = 0
	
	# Create dupes for all formulas
	for formula_file_path in paths:
		if formula_file_path.get_file().get_extension().ends_with('uid'):
			continue
		
		var formula_file: FileAccess = FileAccess.open(path_to_formulas + formula_file_path, FileAccess.READ)
		var formula_file_contents: String = formula_file.get_as_text()
		
		formula_file_contents = expand_templates(formula_file_contents)
		var data: Dictionary = parse_data(formula_file_contents, (paths.find(formula_file_path) / 2) + 1 - skipped_formulas)
		
		# Create duplicate for each formula (excluding already duplicated ones)
		if not formula_file_path.contains('dupea.gdshaderinc'):
			for i in MAX_FORMULAS:
				create_duplicate(data['id'], data['variables'], formula_file_contents, path_to_formulas, "abcdefghijklmnopqrstuvwxyz".split("")[i])
	
	for formula_file_path in paths:
		if formula_file_path.get_file().get_extension().ends_with('uid'):
			continue
		
		var formula_file: FileAccess = FileAccess.open(path_to_formulas + formula_file_path, FileAccess.READ)
		var formula_file_contents: String = formula_file.get_as_text()
		
		formula_file_contents = expand_templates(formula_file_contents)
		var data: Dictionary = parse_data(formula_file_contents, (paths.find(formula_file_path) / 2) + 1 - skipped_formulas)
		
		if data['disabled']:
			skipped_formulas += 1
			continue
		
		formulas.append(data)
	
	formulas.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["index"] < b["index"])

func parse_data(data: String, index_override: int = -1) -> Dictionary:
	var result := {}
	var index_regex := RegEx.new()
	
	result['full_code'] = data
	
	index_regex.compile(r"\/\/\s+\[INDEX\]\n\/\/\s+(\d+)")
	var index_match := index_regex.search(data)
	if index_match:
		result["index"] = int(index_match.get_string(1))
	elif index_override != -1:
		result["index"] = index_override
	
	var id_regex := RegEx.new()
	id_regex.compile("// \\[ID\\]\\s*(.+)")
	var id_match := id_regex.search(data)
	if id_match:
		result["id"] = id_match.get_string(1).strip_edges().lstrip('/ ').to_lower().replace(' ', '')
		result["formatted_id"] = id_match.get_string(1).strip_edges().lstrip('/ ')
	
	var code_match := data.find("// [CODE]")
	if code_match != -1:
		result["code"] = data.substr(code_match + 9).strip_edges()
	
	var vars_start := data.find("// [VARS]")
	var vars_end := data.find("// [CODE]")
	if vars_end == -1:
		vars_end = data.length()
	
	var vars_section := ""
	if vars_start != -1:
		vars_section = data.substr(vars_start + 9, vars_end - vars_start - 9)
	
	var var_regex := RegEx.new()
	var_regex.compile(r"(?:(advanced|simple)\s+)?(\w+)\s+(\w+)\[([^\]]*)\]\s*=\s*([^\n\r]+)")
	var variables := {}
	
	for m in var_regex.search_all(vars_section):
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
		elif var_type == "string":
			variables[var_name] = {
				"type": "string",
				"default_value": default_value,
				"difficulty": difficulty if difficulty else "medium"
			}
	
	result["variables"] = variables
	
	if    '// [DIFS]'      in data: result['type'] = 'difs'
	elif  '// [IFS]'       in data: result['type'] = 'ifs'
	elif  '// [ESCAPE]'    in data: result['type'] = 'escape'
	elif  '// [KIFS]'      in data: result['type'] = 'kifs'
	elif  '// [TRANSFORM]' in data: result['type'] = 'transform'
	elif  '// [PRIMITIVE]' in data: result['type'] = 'primitive'
	else: result['type'] = 'unknown'
	
	result['requires_linear_de'] = '// [LINEAR-DE]' in data
	result['official'] = '// [OFFICIAL]' in data
	result['disabled'] = '// [DISABLED]' in data
	
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
	
	%TabContainer.update_field_values(new_fields)

func update_app_state(data: Dictionary, full_update: bool = true) -> void:
	var old_data: Dictionary = data.duplicate(true)
	data = data.duplicate(true)
	
	print(data.get('keyframe_length'))
	
	if 'other' not in data:
		data['other'] = {"keyframes": data.get("keyframes", {}), 'fps': data.get('fps', 60), 'interpolation': data.get('interpolation', 2), 'keyframe_length': data.get('keyframe_length', 1)}
		
		if data.has('total_visible_formula_pages'):
			data['other']['total_visible_formula_pages'] = data['total_visible_formula_pages']
		
		if data.has('player_position'):
			data['other']['player_position'] = data['player_position']
		
		if data.has('head_rotation'):
			data['other']['head_rotation'] = data['head_rotation']
		
		if data.has('camera_rotation'):
			data['other']['camera_rotation'] = data['camera_rotation']
		
		for other_field_name in (data['other'].keys() as Array[String]):
			data.erase(other_field_name)
	
	var other_data: Dictionary = data['other']
	var player: Node = %Player
	var head: Node = %Player.get_node('Head')
	var camera: Node = %Player.get_node('Head').get_node('Camera')
	data.erase('other')
	
	if data.has('formulas') and data['formulas'] == %TabContainer.current_formulas:
		data.erase('formulas')
	
	update_fields(data)
	
	if other_data.has('player_position'): player.global_position = other_data['player_position']
	if other_data.has('head_rotation'): head.global_rotation_degrees = other_data['head_rotation']
	if other_data.has('camera_rotation'): camera.global_rotation_degrees = other_data['camera_rotation']

	var new_total_visible_formulas: int = %TabContainer.total_visible_formulas
	
	if other_data.has('total_visible_formulas'):
		new_total_visible_formulas = other_data['total_visible_formulas']
	elif data.has('formulas'): 
		new_total_visible_formulas = count_non_zero(data['formulas'])
	
	if %TabContainer.total_visible_formulas != new_total_visible_formulas:
		%TabContainer.total_visible_formulas = new_total_visible_formulas
	
	author = other_data.get("author", "")
	%AuthorLineEdit.text = author
	
	%SubViewport.refresh_taa()
	
	if full_update:
		%AnimationTrack.update_fps(other_data.get('fps', 60))
		%AnimationTrack.interpolation = other_data.get('interpolation', 3)
		%AnimationTrack.keyframe_length = other_data.get('keyframe_length', 1)
		%AnimationTrack.keyframes = other_data.get('keyframes', {})
		%AnimationTrack.reload_keyframes()

func count_non_zero(numbers: Array) -> int:
	var count := 0
	
	for number in (numbers as Array[int]):
		if number != 0:
			count += 1
	
	return count

func update_fractal_code(current_formulas: Array[int]) -> void:
	var shader := %Fractal.material_override.shader as Shader
	var shader_code := shader.code
	var formulas_forloop_code: Array = get_formulas_forloop_code()
	var formulas_import_code: Array = get_formulas_import_code()
	
	if '// -@Formulas' in shader_code:
		shader_code = shader_code.replace('// -@Formulas', '\n'.join(formulas_forloop_code))
	
	if '// -@Imports' in shader_code:
		shader_code = shader_code.replace('// -@Imports', '\n'.join(formulas_import_code))
		
	if '// -@AutomaticDE' in shader_code:
		var linear_de_check := ''
		for formula in formulas:
			if formula['requires_linear_de']:
				linear_de_check += ' || ' + "formulas[0] == " + str(formula['index'])
		
		linear_de_check = linear_de_check.trim_prefix(' || ')
		
		var automatic_de_code := '''
			if (single_formula && (!linear_de_check)) de = r / dz;
			else de = 0.5 * log(r) * r / dz;
		'''.replace('!linear_de_check', linear_de_check)
		
		shader_code = shader_code.replace('// -@AutomaticDE', automatic_de_code)
	
	if '// -@SingleDIFS':
		var single_difs_code := ''
		single_difs_code += 'vec2 sdf_result;\n'
		for formula in formulas:
			if formula['type'] == 'difs' or formula['type'] == 'primitive':
				single_difs_code += '//sdf_result = ' + formula['id'] + '_sdf(original_z); de = sdf_result.x; orbit = sdf_result.y; // -@' + str(formula['index']) + '\n'
		shader_code = shader_code.replace('// -@SingleDIFS', single_difs_code)

	if '// -@MultiDIFS':
		var single_difs_code := ''
		var formulas_sorted: Array = formulas.duplicate(true)
		formulas_sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: 
			if a['type'] == 'difs' and b['type'] == 'primitive':
				return true
			elif a['type'] == 'primitive' and b['type'] == 'difs':
				return false
			else:
				return a['index'] < b['index']
		)
		
		single_difs_code += 'vec2 sdf_result;\n'
		for formula in (formulas_sorted as Array[Dictionary]):
			if formula['type'] == 'difs' or formula['type'] == 'primitive':
				var function: String = 'max' if formula['type'] == 'difs' else 'min'
				single_difs_code += '//sdf_result = ' + formula['id'] + '_sdf(original_z); de = ' + function + '(de, sdf_result.x); orbit = min(orbit, sdf_result.y); // -@' + str(formula['index']) + '\n'
		shader_code = shader_code.replace('// -@MultiDIFS', single_difs_code)
	
	if '// -@Uniforms' in shader_code:
		var uniforms_code: String = ""
		for formula in formulas:
			for variable_name in (formula['variables'].keys() as Array[String]):
				var variable: Dictionary = formula['variables'][variable_name]
				var import_check: String = ' // -@' + str(formula['index']) if LAZY_IMPORTING else ''
				var vartype: String = variable['type'].replace('selection', 'int')
				
				if vartype == 'string':
					continue
				
				uniforms_code += 'uniform ' + vartype + ' f' + formula['id'] + '_' + variable_name + ';' + import_check + '\n'
		
		shader_code = shader_code.replace('// -@Uniforms', uniforms_code)
	
	var maintype_count := 0
	var primitive_count := 0
	var difs_count := 0
	
	for current_formula in current_formulas:
		if current_formula == -1 or current_formula == 0:
			continue
		
		var formula_data: Dictionary = get_formula_data_from_index(current_formula)
		var formula_type: String = formula_data['type']
		
		#print(formula_type, ' | ', formula_data['id'])
		match formula_type:
			"primitive":
				primitive_count += 1
			"difs":
				difs_count += 1
			_:
				maintype_count += 1
	
	var single_formula := true
	
	if maintype_count >= 2 or primitive_count >= 2 or difs_count >= 2:
		single_formula = false
	elif maintype_count >= 1 and difs_count >= 1:
		single_formula = false
	elif maintype_count >= 1 and primitive_count >= 1:
		single_formula = false
	elif primitive_count >= 1 and difs_count >= 1:
		single_formula = false
	
	#print('MULTI FORMULA: ', not single_formula)
	%Fractal.material_override.set_shader_parameter('single_formula', single_formula)
	
	var lines := shader_code.split("\n")
	var modified_lines := []
	
	var only_primitive_based_formulas: bool = true
	var only_sdf_based_formulas: bool = true
	
	for formula in current_formulas:
		if formula <= 0:
			continue
		
		var data: Dictionary = get_formula_data_from_index(formula)
		if data['type'] != 'primitive':
			only_primitive_based_formulas = false
		if data['type'] != 'primitive' && data['type'] != 'difs':
			only_sdf_based_formulas = false
	
	#print('ONLY PRIMITIVE BASED FORMULAS: ', only_primitive_based_formulas)
	#print('ONLY SDF BASED FORMULAS: ', only_sdf_based_formulas)
	%Fractal.material_override.set_shader_parameter('only_primitive_based_formulas', only_primitive_based_formulas)
	%Fractal.material_override.set_shader_parameter('only_sdf_based_formulas', only_sdf_based_formulas)
	
	for i: int in range(lines.size()):
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
		if not modified_lines[5].begins_with('//'): modified_lines[5] = '//' + (modified_lines[5] as String)
	
	if using_tiling:
		modified_lines[6] = (modified_lines[6] as String).lstrip('/')
	else:
		if not modified_lines[6].begins_with('//'): modified_lines[6] = '//' + (modified_lines[6] as String)
	
	if using_reflections:
		modified_lines[7] = (modified_lines[7] as String).lstrip('/')
	else:
		if not modified_lines[7].begins_with('//'): modified_lines[7] = '//' + (modified_lines[7] as String)
	
	shader.code = "\n".join(modified_lines)
	
	var file: FileAccess = FileAccess.open('res://renderer/generated_shader_code.gdshader', FileAccess.WRITE)
	file.store_string(shader.code)
	file.close()
	#print('---------------------------------')

func _on_difficulty_pressed() -> void:
	if difficulty == 'simple':
		difficulty = 'advanced'
		%DifficultyButton.text = 'Advanced Mode'
		toggle_ui_difficulty()
	elif difficulty == 'advanced':
		difficulty = 'simple'
		%DifficultyButton.text = 'Simple Mode'
		toggle_ui_difficulty()
	
	# Toggle menu bar buttons
	%History.visible = not %History.visible
	%AuthorButton.visible = not %AuthorButton.visible
	%RandomizeButton.visible = not %RandomizeButton.visible

func toggle_ui_difficulty() -> void:
	for advanced_ui_field in advanced_ui_fields:
		advanced_ui_field.visible = not advanced_ui_field.visible
		advanced_ui_field.get_meta('name_node').visible = not advanced_ui_field.get_meta('name_node').visible

func _on_tree_exiting() -> void:
	DirAccess.open(HELIUM3D_PATH).remove('heartbeat.hlm')

func _on_close_button_pressed() -> void: $AboutWindow.visible = false
func _on_window_close_requested() -> void: $AboutWindow.visible = false
func _on_about_button_pressed() -> void: $AboutWindow.visible = true

func _on_settings_button_pressed() -> void: $SettingsWindow.visible = true
func _on_settings_window_close_requested() -> void: $SettingsWindow.visible = false

func crash_detected() -> void: $CrashSaveWindow.visible = true
func _on_crash_save_close_requested() -> void: $CrashSaveWindow.visible = false
func _on_crash_save_cancel_button_pressed() -> void: $CrashSaveWindow.visible = false
func _on_recover_button_pressed() -> void: 
	%ToolBar.recover()
	$CrashSaveWindow.visible = false

func _on_author_button_pressed() -> void: $AuthorWindow.visible = true
func _on_author_window_close_requested() -> void: $AuthorWindow.visible = false
func _on_cancel_author_pressed() -> void: 
	$AuthorWindow.visible = false
	%AuthorLineEdit.text = author

func _on_done_author_pressed() -> void: 
	$AuthorWindow.visible = false
	author = %AuthorLineEdit.text

func _on_randomize_window_close_requested() -> void: $RandomizeWindow.visible = false
func _on_randomize_pressed() -> void: $RandomizeWindow.visible = true

func _on_voxelize_window_close_requested() -> void: 
	$VoxelizeWindow.visible = false
	await get_tree().process_frame
	%SubViewport.refresh_taa()

func _on_voxelize_pressed() -> void: 
	$VoxelizeWindow.visible = true
	%SubViewport.refresh_taa()

func set_resolution(val: Vector2) -> void:
	for value_node in (Global.value_nodes as Array[Control]):
		if value_node.name == 'Resolution':
			value_node.value = val

func _on_voxelize_button_pressed() -> void:
	%Voxelize.disabled = true
	
	var bounds_size: Vector3 = fields.get('bounds_size', Vector3(2.5, 2.5, 2.5))
	var bounds_position: Vector3 = fields.get('bounds_position', Vector3.ZERO)
	var resolution: int = fields.get('voxel_resolution', 450)
	
	var original_player_position: Vector3 = %Player.position
	var original_head_rotation: Vector3 = %Head.rotation
	var original_camera_rotation: Vector3 = %Camera.rotation
	var original_viewport_size: Vector2i = %SubViewport.size
	var original_camera_fov: float = %Camera.fov
	
	%Fractal.material_override.set_shader_parameter('building_mesh', true)
	%SubViewport.refresh_taa()
	%SubViewport.force_disable_low_scaling = true
	
	%SubViewport.size = Vector2i(resolution, resolution)
	%Fractal.material_override.set_shader_parameter('sample_scale', max(bounds_size.x, bounds_size.y))
	%Fractal.material_override.set_shader_parameter('voxel_screen_resolution', Vector2i(resolution, resolution))
	
	var start_z: float = bounds_position.z + bounds_size.z * 0.5
	var end_z: float = bounds_position.z - bounds_size.z * 0.5
	var step_size: float = bounds_size.z / resolution
	
	%Player.position = Vector3(bounds_position.x, bounds_position.y, start_z)
	%Head.look_at(Vector3(bounds_position.x, bounds_position.y, end_z), Vector3.UP)
	%Camera.rotation = Vector3.ZERO
	%Camera.projection = Camera3D.ProjectionType.PROJECTION_ORTHOGONAL
	
	$Voxelization.StartCapture(resolution)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	for i: int in resolution + 2:
		%SubViewport.refresh_taa()
		await get_tree().process_frame
		if i >= 2:
			%Player.position.z -= step_size
			var layer: Image = (%PostViewport.get_texture() as ViewportTexture).get_image()
			$Voxelization.AddImage(i - 2, layer)
	
	%Player.position = original_player_position
	%Head.rotation = original_head_rotation
	%Camera.rotation = original_camera_rotation
	%Camera.projection = Camera3D.ProjectionType.PROJECTION_PERSPECTIVE
	%SubViewport.size = original_viewport_size
	%Fractal.material_override.set_shader_parameter('building_mesh', false)
	%SubViewport.force_disable_low_scaling = false
	%SubViewport.refresh_taa()
	%Voxelize.release_focus()
	%VoxelizedMeshWorld.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	$Voxelization.VoxelizeFromBuffer()
	var voxel_mesh: ArrayMesh = await $Voxelization.MeshReady
	
	if voxel_mesh != null:
		$VoxelizedMeshWorld/Mesh.mesh = voxel_mesh
		
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.WHITE
		$VoxelizedMeshWorld/Mesh.set_surface_override_material(0, mat)
	
	%SubViewport.refresh_taa()
	%Voxelize.disabled = false

func _on_export_pressed() -> void:
	%VoxelizationFileDialog.show()

func _on_voxelization_file_dialog_file_selected(path: String) -> void:
	$Voxelization.SaveMesh($VoxelizedMeshWorld/Mesh.mesh, path)
