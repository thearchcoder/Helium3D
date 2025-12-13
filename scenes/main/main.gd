extends Node3D

var VERSION := '0.9.1-beta'
var PHASE := VERSION.split('-')[-1]
var MAJOR := VERSION.split('.')[0]
var MINOR := VERSION.split('.')[1]
var PATCH := VERSION.split('.')[2].split('-')[0]

const DUPES := 10
const MAX_ACTIVE_FORMULAS := 10
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

@onready var HELIUM3D_PATH: String = (OS.get_environment("USERPROFILE") if OS.get_name() == "Windows" else OS.get_environment("HOME")) + Global.path("/.hlm")
var advanced_ui_fields: Array[Control] = []
var taa_samples: int = 2
var fields: Dictionary = {}
var other_fields: Array = ['total_visible_formula_pages', 'player_position', 'head_rotation', 'camera_rotation']
var formulas: Array[Dictionary] = []
var using_dof: bool = false
var author: String = ''
var using_reflections: bool = false
var busy_rendering_tiles: bool = false
var last_tiled_render_image: Image
var difficulty: String = 'simple'
var default_app_state: Dictionary = {}

var made_changes := false
var history: Array[Dictionary] = []
var history_at: int = -1
var last_saved_state: Dictionary = {}
var is_applying_history: bool = false
var white_display: Image
var has_opened_randomization_menu: bool = false

var previous_frame_texture: ImageTexture

var is_resizing_bottom_bar: bool = false
var is_resizing_animation_panel: bool = false
var is_resizing_tab_container: bool = false
var resize_start_pos: Vector2 = Vector2.ZERO
var resize_start_size: float = 0.0
const RESIZE_GRAB_DISTANCE: float = 10.0

func _ready() -> void:
	$UI/HBoxContainer/VBoxContainer/HBoxContainer/ToolBar/Control/Panel.size.x = DisplayServer.window_get_size().x * 2
	$AboutWindow/HBoxContainer/VBoxContainer2/RichTextLabel.text = $AboutWindow/HBoxContainer/VBoxContainer2/RichTextLabel.text.replace('{version}', VERSION)
	
	var dir := DirAccess.open("res://")
	if not dir.dir_exists(HELIUM3D_PATH):
		dir.make_dir(HELIUM3D_PATH)
	
	if FileAccess.file_exists(HELIUM3D_PATH + Global.path('/heartbeat.hlm')) and FileAccess.file_exists(HELIUM3D_PATH + Global.path('/autosave.hlm')):
		crash_detected()
	else:
		var file: FileAccess = FileAccess.open(HELIUM3D_PATH + Global.path('/heartbeat.hlm'), FileAccess.WRITE)
		file.close()
	
	await RenderingServer.frame_post_draw
	DisplayServer.window_set_title("Helium3D", get_window().get_window_id())
	action_occurred(false)
	
	var viewport_texture: ViewportTexture = %TextureRect.get_texture()
	var viewport_image: Image = viewport_texture.get_image()
	var viewport_size: Vector2i = viewport_image.get_size()
	var viewport_format := viewport_image.get_format()
	
	var image := Image.create(viewport_size.x, viewport_size.y, false, viewport_format)
	previous_frame_texture = ImageTexture.create_from_image(image)
	
	%PostDisplay.material.set_shader_parameter('previous_frame', previous_frame_texture)
	%Fractal.material_override.set_shader_parameter('previous_frame', previous_frame_texture)
	default_app_state = get_app_state()

	setup_resize_handlers()

func reset_to_default() -> void:
	if default_app_state != {}:
		update_app_state(default_app_state)

func action_occurred(add_to_history: bool = true) -> void:
	if is_applying_history:
		return
	
	var current_state: Dictionary = get_app_state()
	var changes: Dictionary = get_state_changes(last_saved_state, current_state)
	
	if changes.is_empty():
		return
	
	if history_at < history.size() - 1:
		history = history.slice(0, history_at + 1)
	
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
	#var loading_icon: Image = %LoadingIcon.texture.get_image()
	#loading_icon.rotate_90(CLOCKWISE)
	#
	#var loading_icon_texture: ImageTexture = ImageTexture.create_from_image(loading_icon)
	#%LoadingIcon.texture = loading_icon_texture
	
	var current_image: Image = %TextureRect.get_texture().get_image()
	%PostDisplay.material.set_shader_parameter('previous_frame', ImageTexture.create_from_image(current_image))
	%Fractal.material_override.set_shader_parameter('previous_frame', previous_frame_texture)
	
	if Input.is_action_just_pressed('escape'):
		if $AboutWindow.visible: $AboutWindow.visible = false
		if $SettingsWindow.visible: $SettingsWindow.visible = false
		if $CrashSaveWindow.visible: $CrashSaveWindow.visible = false
		if $AuthorWindow.visible: $AuthorWindow.visible = false
		if $RandomizeWindow.visible: _on_randomize_window_close_requested()
		if $VoxelizeWindow.visible: $VoxelizeWindow.visible = false
	
	%Fractal.material_override.set_shader_parameter('voxelization', $VoxelizeWindow.visible)
	%TextureRect.is_menu_rendered = %RandomizeWindow.visible or %VoxelizeWindow.visible
	%Export.disabled = $VoxelizedMeshWorld/Mesh.mesh == null
	
	$UI/HBoxContainer/VBoxContainer/HBoxContainer/ToolBar/Control/Panel.size.x = DisplayServer.window_get_size().x * 2

func _input(_event: InputEvent) -> void:
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
	
	if Input.is_action_just_pressed('shortcut save current file'):
		%Save.get_popup().id_pressed.emit(4)

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
		#if OS.has_feature("editor"):
		formulas_import_code.append('#include "res://formulas/' + formula['id'] + '.gdshaderinc"' + import_check)
		#else:
		#formulas_import_code.append('//' + formula['full_code'].replace('\n', '\n//') + import_check)
	
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
	other_data["library"] = $UI/BottomBar/Library.get_library_data()
	other_data["randomization"] = %Randomization.get_randomization_data()

	if optimize_for_clipboard:
		for value_node in Global.value_nodes:
			if value_node.get_node('../../../../../..').name == 'Buffer':
				if value_node.get_meta('formula_index') != 0 and value_node.get_meta('formula_index') not in %TabContainer.current_formulas:
					data.erase(value_node.get_meta('uniform_name'))
	
	data["other"] = other_data
	
	return data

func create_duplicate(formula_name: String, original_content: String, path_to_formulas: String, dupe_identifier: String) -> void:
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
	
	var paths: PackedStringArray
	
	if OS.has_feature("editor"):
		paths = DirAccess.get_files_at(path_to_formulas)
		
		var all_formulas: PackedStringArray = []
		for formula_file_path in paths:
			if formula_file_path.ends_with('.gdshaderinc'):
				all_formulas.append(formula_file_path.get_basename())
		
		var list_file: FileAccess = FileAccess.open("res://formula_list.txt", FileAccess.WRITE)
		list_file.store_string("\n".join(all_formulas))
		list_file.close()
	else:
		var formula_list_file: FileAccess = FileAccess.open("res://formula_list.txt", FileAccess.READ)
		if not formula_list_file:
			return
		
		var all_formulas: PackedStringArray = formula_list_file.get_as_text().split("\n")
		formula_list_file.close()
		
		paths = []
		for base in all_formulas:
			if base.strip_edges() != "":
				paths.append(base + ".gdshaderinc")
	
	var current_index: int = 1
	
	for formula_file_path in paths:
		if formula_file_path.get_file().get_extension().ends_with('uid'):
			continue
		
		var formula_file: FileAccess = FileAccess.open(path_to_formulas + formula_file_path, FileAccess.READ)
		if not formula_file:
			continue
		
		var formula_file_contents: String = formula_file.get_as_text()
		formula_file_contents = expand_templates(formula_file_contents)
		
		var is_dupe: bool = formula_file_path.contains('dupe')
		var index: int = current_index
		
		var data: Dictionary = parse_data(formula_file_contents, index)
		
		if not data.has('index'):
			continue
		
		if not is_dupe and OS.has_feature("editor"):
			for i in DUPES:
				create_duplicate(data['id'], formula_file_contents, path_to_formulas, "abcdefghijklmnopqrstuvwxyz".split("")[i])
		
		if data.get('disabled', false):
			continue
		
		formulas.append(data)
		current_index += 1
	
	var extra_formulas_file: FileAccess = FileAccess.open("user://extra_formulas.txt", FileAccess.READ)
	if extra_formulas_file:
		var extra_paths: PackedStringArray = extra_formulas_file.get_as_text().split("\n")
		extra_formulas_file.close()
		
		for extra_path in extra_paths:
			extra_path = extra_path.strip_edges()
			if extra_path == "" or not FileAccess.file_exists(extra_path):
				continue
			
			var extra_file: FileAccess = FileAccess.open(extra_path, FileAccess.READ)
			if not extra_file:
				continue
			
			var extra_contents: String = extra_file.get_as_text()
			extra_contents = expand_templates(extra_contents)
			var extra_data: Dictionary = parse_data(extra_contents, formulas.size() + 1)
			
			if not extra_data.get('disabled', false):
				formulas.append(extra_data)
	
	formulas.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["index"] < b["index"])
	print("Formulas initialized, total: %d" % formulas.size())

func parse_data(data: String, index: int = -1) -> Dictionary:
	var result := {}
	
	result["full_code"] = data
	result["index"] = index
	
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
		var var_difficulty := m.get_string(1)
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
				"difficulty": var_difficulty if var_difficulty else "simple"
			}
		elif var_type == "float" or var_type == "int":
			var range_vals := values.split(", ")
			var from_val: float = float(range_vals[0]) if "." in range_vals[0] else float(int(range_vals[0]))
			var to_val: float = float(range_vals[1]) if "." in range_vals[1] else float(int(range_vals[1]))
			variables[var_name] = {
				"type": var_type,
				"from": from_val,
				"to": to_val,
				"default_value": float(default_value) if "." in default_value else float(int(default_value)),
				"difficulty": var_difficulty if var_difficulty else "simple"
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
					"difficulty": var_difficulty if var_difficulty else "simple"
				}
			elif var_type == 'vec4':
				variables[var_name] = {
					"type": "vec4",
					"from": Vector4(float(from_vec[0]), float(from_vec[1]), float(from_vec[2]), float(from_vec[3])),
					"to": Vector4(float(to_vec[0]), float(to_vec[1]), float(to_vec[2]), float(to_vec[3])),
					"default_value": Vector4(float(default_vec[0]), float(default_vec[1]), float(default_vec[2]), float(default_vec[3])),
					"difficulty": var_difficulty if var_difficulty else "simple"
				}
			elif var_type == 'vec2':
				variables[var_name] = {
					"type": "vec2",
					"from": Vector2(float(from_vec[0]), float(from_vec[1])),
					"to": Vector2(float(to_vec[0]), float(to_vec[1])),
					"default_value": Vector2(float(default_vec[0]), float(default_vec[1])),
					"difficulty": var_difficulty if var_difficulty else "simple"
				}
		elif var_type == "bool":
			variables[var_name] = {
				"type": "bool",
				"default_value": default_value.to_lower() == "true",
				"difficulty": var_difficulty if var_difficulty else "simple"
			}
		elif var_type == "string":
			variables[var_name] = {
				"type": "string",
				"default_value": default_value,
				"difficulty": var_difficulty if var_difficulty else "simple"
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
	
	%TabContainer.update_fields_ui(new_fields)

func update_app_state(data: Dictionary, full_update: bool = true) -> void:
	data = data.duplicate(true)
	
	if 'other' not in data:
		data['other'] = {"keyframes": data.get("keyframes", []), 'fps': data.get('fps', 60), 'interpolation': data.get('interpolation', 2), 'keyframe_length': data.get('keyframe_length', 1)}
		
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
	
	%SubViewport.refresh()
	
	if full_update:
		%AnimationTrack.update_fps(other_data.get('fps', 60))
		%AnimationTrack.interpolation = other_data.get('interpolation', 3)
		%AnimationTrack.keyframe_length = other_data.get('keyframe_length', 1)
		%AnimationTrack.keyframes = other_data.get('keyframes', [])
		$UI/BottomBar/Library.load_library_data(other_data.get('library', []))
		%Randomization.load_randomization_data(other_data.get('randomization', {}))
		%AnimationTrack.reload_keyframes()

func count_non_zero(numbers: Array) -> int:
	var count := 0
	
	for number in (numbers as Array[int]):
		if number != 0:
			count += 1
	
	return count

var shader_code: String = preload('res://renderer/renderer.gdshader').code

func update_fractal_code(current_formulas: Array[int]) -> void:
	var shader := %Fractal.material_override.shader as Shader
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
		
		if linear_de_check == '':
			automatic_de_code = automatic_de_code.replace(' && ()', '')
		
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

	if using_reflections:
		modified_lines[6] = (modified_lines[6] as String).lstrip('/')
	else:
		if not modified_lines[6].begins_with('//'): modified_lines[6] = '//' + (modified_lines[6] as String)
	
	## Remove all comments to reduce shader compilation times
	#var i: int = 0
	#for line in (modified_lines as Array[String]):
		#if line.begins_with('#include'):
			#continue
		#
		#var comment_pos := line.find("//")
		#
		#if comment_pos != -1:
			#line = line.substr(0, comment_pos)
		#
		#if line.rstrip(" \t") == "":
			#modified_lines.remove_at(i)
		#else:
			#modified_lines[i] = line.rstrip(" \t")
		#i += 1

	shader.code = "\n".join(modified_lines)
	
	if OS.has_feature("editor"):
		var file: FileAccess = FileAccess.open('res://renderer/generated_shader_code.gdshader', FileAccess.WRITE)
		if file:
			file.store_string("\n".join(modified_lines))
			file.close()
	#print('---------------------------------')

func _on_difficulty_pressed() -> void:
	if difficulty == 'simple':
		difficulty = 'advanced'
		%DifficultyButton.text = 'Advanced Mode'
		reload_difficulty()
	elif difficulty == 'advanced':
		difficulty = 'simple'
		%DifficultyButton.text = 'Simple Mode'
		reload_difficulty()

func reload_difficulty() -> void:
	set_ui_difficulty(difficulty == 'simple')

func set_ui_difficulty(is_simple: bool) -> void:
	for advanced_ui_field in advanced_ui_fields:
		advanced_ui_field.visible = false if is_simple else true
		advanced_ui_field.get_meta('name_node').visible = false if is_simple else true

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

func _on_randomize_window_close_requested() -> void: 
	$RandomizeWindow.visible = false
	
	if %Randomization.decided_randomization.get('is_null', false) == true:
		update_app_state(%Randomization.undecided_randomization)
	else:
		update_app_state(%Randomization.decided_randomization)
	
	%Randomization.decided_randomization = {'is_null': true}

func _on_randomize_pressed() -> void: 
	$RandomizeWindow.visible = true
	%Randomization.undecided_randomization = get_app_state()
	_on_voxelize_window_close_requested()
	
	if not has_opened_randomization_menu:
		has_opened_randomization_menu = true
		%Randomization.update_base_scene()
		await get_tree().process_frame
		%Randomization.add_to_history(get_app_state())

		%Randomization.randomization()
	
	if %Randomization.last_randomized_scene_data.get('is_null', false) != true:
		update_app_state(%Randomization.last_randomized_scene_data)

func _on_voxelize_window_close_requested() -> void: 
	$VoxelizeWindow.visible = false
	%Fractal.material_override.set_shader_parameter('voxelization', false)
	%SubViewport.refresh()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	%SubViewport.refresh()

func _on_voxelize_pressed() -> void: 
	$VoxelizeWindow.visible = true
	%SubViewport.refresh()
	_on_randomize_window_close_requested()

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
	
	%Fractal.material_override.set_shader_parameter('building_mesh', true)
	%SubViewport.refresh()
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
	
	$Voxelization.StartCapture(resolution, max(bounds_size.x, max(bounds_size.y, bounds_size.z)))
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	for i: int in resolution + 2:
		%SubViewport.refresh()
		await get_tree().process_frame
		if i >= 2:
			%Player.position.z -= step_size
			var layer: Image = (%TextureRect.get_texture() as ViewportTexture).get_image()
			$Voxelization.AddImage(i - 2, layer)
	
	%Player.position = original_player_position
	%Head.rotation = original_head_rotation
	%Camera.rotation = original_camera_rotation
	%Camera.projection = Camera3D.ProjectionType.PROJECTION_PERSPECTIVE
	%SubViewport.size = original_viewport_size
	%Fractal.material_override.set_shader_parameter('building_mesh', false)
	%SubViewport.force_disable_low_scaling = false
	%SubViewport.refresh()
	%Voxelize.release_focus()
	%VoxelizedMeshWorld.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	$Voxelization.VoxelizeFromBuffer()
	var voxel_mesh: ArrayMesh = await $Voxelization.MeshReady
	
	if voxel_mesh != null:
		$VoxelizedMeshWorld/Mesh.mesh = voxel_mesh
		
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.WHITE
		$VoxelizedMeshWorld/Mesh.set_surface_override_material(0, mat)
	
	%SubViewport.refresh()
	%Voxelize.disabled = false

func _on_export_pressed() -> void:
	%VoxelizationFileDialog.show()

func _on_voxelization_file_dialog_file_selected() -> void:
	$Voxelization.SaveMesh($VoxelizedMeshWorld/Mesh.mesh, %VoxelizationFileDialog.current_path)

func setup_resize_handlers() -> void:
	var bottom_bar: TabContainer = $UI/BottomBar
	var animation_panel: HBoxContainer = $UI/BottomBar/Animation
	var library_panel: Control = $UI/BottomBar/Library
	var tab_container: TabContainer = $UI/HBoxContainer/TabContainer

	bottom_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	animation_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	library_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	tab_container.mouse_filter = Control.MOUSE_FILTER_PASS

	animation_panel.gui_input.connect(_on_bottom_panel_gui_input)
	library_panel.gui_input.connect(_on_bottom_panel_gui_input)
	tab_container.gui_input.connect(_on_tab_container_gui_input)

func _on_bottom_panel_gui_input(event: InputEvent) -> void:
	var bottom_bar: TabContainer = $UI/BottomBar
	var current_panel: Control = bottom_bar.get_current_tab_control()
	
	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion
		
		if is_resizing_animation_panel:
			var viewport_mouse: Vector2 = get_viewport().get_mouse_position()
			var parent_local: Vector2 = current_panel.get_parent().get_global_transform().affine_inverse() * viewport_mouse
			var new_height: float = (current_panel.position.y + current_panel.size.y) - parent_local.y
			new_height = clampf(new_height, 100.0, 600.0)
			current_panel.custom_minimum_size.y = new_height
			$UI/BottomBar/Animation/Animation/CurrentTime/HBoxContainer/Time/ColorRect.size.y = max(new_height - 67, 133)
		else:
			var local_pos: Vector2 = mouse_event.position
			if local_pos.y <= RESIZE_GRAB_DISTANCE and not is_resizing_tab_container:
				Input.set_default_cursor_shape(Input.CURSOR_VSIZE)
				#print('vsize')
			elif not is_resizing_tab_container:
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
				#print('arrow')
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			var local_pos: Vector2 = mouse_button.position
			if mouse_button.pressed and local_pos.y <= RESIZE_GRAB_DISTANCE:
				is_resizing_animation_panel = true
				Input.set_default_cursor_shape(Input.CURSOR_VSIZE)
				#print('vsize')
			elif not mouse_button.pressed and is_resizing_animation_panel:
				is_resizing_animation_panel = false
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
				#print('arrow')

func _on_tab_container_gui_input(event: InputEvent) -> void:
	var tab_container: TabContainer = $UI/HBoxContainer/TabContainer

	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion
		var local_pos: Vector2 = mouse_event.position

		if is_resizing_tab_container:
			var delta: float = (resize_start_pos.x - local_pos.x)
			var new_ratio: float = resize_start_size + (delta / get_viewport().get_visible_rect().size.x)
			tab_container.size_flags_stretch_ratio = new_ratio
		elif local_pos.x <= RESIZE_GRAB_DISTANCE and not is_resizing_animation_panel:
			Input.set_default_cursor_shape(Input.CURSOR_HSIZE)
			#print('hsize')
		else:
			if not is_resizing_animation_panel:
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
				#print('arrow')
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton

		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			var local_pos: Vector2 = mouse_button.position

			if mouse_button.pressed and local_pos.x <= RESIZE_GRAB_DISTANCE:
				is_resizing_tab_container = true
				resize_start_pos = local_pos
				resize_start_size = tab_container.size_flags_stretch_ratio
				Input.set_default_cursor_shape(Input.CURSOR_HSIZE)
				#print('hsize')
			elif not mouse_button.pressed and is_resizing_tab_container:
				is_resizing_tab_container = false
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
				#print('arrow')

func _on_okay_button_pressed() -> void:
	$ErrorWindow.visible = false

func _on_forums_button_pressed() -> void:
	$ErrorWindow.visible = false
	pass
	# No forums yet.
