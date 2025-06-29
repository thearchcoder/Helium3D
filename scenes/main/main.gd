extends Node3D

var VERSION := '0.9.1-beta'
var PHASE := VERSION.split('-')[-1]
var MAJOR := VERSION.split('.')[0]
var MINOR := VERSION.split('.')[1]
var PATCH := VERSION.split('.')[2].split('-')[0]

# DONE | about menu
# DONE | animation keyframe length
# DONE | animation keyframe interpolation (Linear, Bezier, Hermite)
# DONE | octkoch
# DONE | remove wobble
# DONE | uniform system
# DONE | debug/shader_code dump
# DONE | kalaido transform
# DONE | ifs -> kifs
# DONE | ambient occlusion max dist
# DONE | transforms range template
# DONE | update antialiasing entry when enabling upscaling
# DONE | pause icon
# ------------------------------------------------
# DONE | store anti aliasing in save files
# shader baking
# indexed to named
# fix mixing two primitives only causes log de sphere
# ... improve shadows?
# DONE | shadow ray step multiplier 0.1 - 3.0 range not 1.0 - 3.0
# display option for shadow map
# DONE | sharpness parameter has no effect in exported images
# render button set low scaling to 1.0
# undo redo
# binary search ray marching
# proper shadow epsilon options
# DONE | add plane primitive
# proper normal epsilon options
# advanced mode for ALL fields
# in tiled animation rendering, first tile is black
# DONE | smaa anti aliasing
# DONE | fix keyframe length / fps interpolation
# DONE | primitives
# formulas menu reset button
# DONE | gyroid primitive
# DONE | independent formula files
# library
# KALAIDO CAMERA
# DONE | panorama camera
# open native dialog in windows or mac, use godot dialog in linux
# tile render blend previous frame
# tile render stop button
# tile render button, not checkboxes
# tile render center priority
# SORTA DONE | animation estimate time
# SORTA DONE | animation current frame label
# multiple same formulas
# super sample based motion blue
# edit keyframe
# edit multiple keyframes
# DONE | better formula search
# DONE | shortcut tab switching
# DONE | add option to not put // -@ after lines for formulas error checking
# DONE | koch_cube
# DONE | benesi1pow2
# DONE | platonic_solid (koch_cube)
# -----------------------------------------------------
# koch_oct
# mengerkochv2

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
var taa_samples: int = 2
var fields: Dictionary = {}
var other_fields: Array = ['total_visible_formula_pages', 'player_position', 'head_rotation', 'camera_rotation']
var formulas: Array[Dictionary] = []
var using_dof: bool = false
var using_tiling: bool = false
var author: String = ''
var using_reflections: bool = false
var busy_rendering_tiles: bool = false
var keyframe_length: float = 1.0
var interpolation: int = 2
var fps: int = 60
var difficulty: String = 'simple':
	set(value):
		difficulty = value
		%TabContainer.get_node('Formula/TabContainer').set_difficulty(difficulty)

var history: Array = []
var history_at: int = 0
var white_display: Image

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

func _process(_delta: float) -> void:
	if $AboutWindow.visible and Input.is_action_just_pressed('escape'):
		_on_window_close_requested()

func expand_templates(formula_content: String) -> String:
	var lines := formula_content.split('\n')
	var expanded_lines: Array[String] = []
	
	for line in lines:
		var trimmed_line := line.strip_edges()
		if trimmed_line.begins_with('// template '):
			var template_name := trimmed_line.substr(12).strip_edges()
			for template_var in (VAR_TEMPLATES[template_name] as Array[String]):
				expanded_lines.append(template_var)
		else:
			expanded_lines.append(line)
	
	return '\n'.join(expanded_lines)

func get_formulas_forloop_code() -> Array:
	initialize_formulas('res://formulas/')
	var formulas_forloop_code: Array = []
	for formula in formulas:
		for i in range(formulas.size()):
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
	other_data["fps"] = fps
	other_data["interpolation"] = interpolation
	other_data["keyframe_length"] = keyframe_length
	other_data["author"] = author
	other_data["library"] = {}
	
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
	
	var paths: PackedStringArray = DirAccess.get_files_at(path_to_formulas)
	var skipped_formulas: int = 0
	
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
	
	if 'other' not in data:
		data['other'] = {"keyframes": data.get("keyframes", {}), 'total_visible_formula_pages': data['total_visible_formula_pages'], 'player_position': data['player_position'], 'head_rotation': data['head_rotation'], 'camera_rotation': data['camera_rotation'], 'fps': data.get('fps', 60), 'interpolation': data.get('interpolation', 2), 'keyframe_length': data.get('keyframe_length', 1)}
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
	
	author = other_data.get("author", "")
	%AuthorLineEdit.text = author
	
	%SubViewport.refresh_taa()
	
	if full_update:
		%AnimationTrack.update_fps(other_data.get('fps', 60))
		%AnimationTrack.interpolation = other_data.get('interpolation', 3)
		%AnimationTrack.keyframe_length = other_data.get('keyframe_length', 1)
		%AnimationTrack.keyframes = other_data.get('keyframes', {})
		%AnimationTrack.reload_keyframes()
		
		#if len(other_data['custom_formulas'].keys()) >= 1:
			#var all_are_installed: bool = true
			#var formula_ids: Array = formulas.map(func(formula: Dictionary) -> String: return formula.get("id", ""))
			#
			#for custom_formula_id in (other_data['custom_formulas'].keys() as Array[String]):
				#if custom_formula_id not in formula_ids:
					#all_are_installed = false
					#break
	#
			#if not all_are_installed:
				#var install_custom_formulas: bool = await Global.show_yes_no_popup('Install Formulas', 'This project that you\'re trying to open is using a few custom formulas. Would you like to install these custom formulas? Expect unexpected behaviour if you click no. No internet needed, will be instant. App restart will be needed.')
				#if install_custom_formulas:
					#for custom_formula_name in (other_data['custom_formulas'].keys() as Array[String]):
						#var custom_formula: String = other_data['custom_formulas'][custom_formula_name]
						#import_formula(custom_formula_name, custom_formula)
				#
					#var restart_app: bool = await Global.show_yes_no_popup('Formulas Installed', 'Custom formulas installed, App restart is needed.')
					#if restart_app: 
						#OS.create_process(OS.get_executable_path(), [])
						#get_tree().quit()

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
		for formula in formulas:
			if formula['type'] == 'difs' or formula['type'] == 'primitive':
				single_difs_code += '//de = ' + formula['id'] + '_sdf(original_z).x; // -@' + str(formula['index']) + '\n'
		shader_code = shader_code.replace('// -@SingleDIFS', single_difs_code)
	
	if '// -@MultiDIFS':
		var single_difs_code := ''
		for formula in formulas:
			if formula['type'] == 'difs' or formula['type'] == 'primitive':
				var function: String = 'max' if formula['type'] == 'difs' else 'min'
				single_difs_code += '//de = ' + function + '(de, ' + formula['id'] + '_sdf(original_z).x); // -@' + str(formula['index']) + '\n'
		shader_code = shader_code.replace('// -@MultiDIFS', single_difs_code)
	
	#if '// -@CheckOnlyDIFS':
		#var single_difs_code := ''
		#for formula in formulas:
			#if formula['type'] == 'difs' or formula['type'] == 'primitive':
				#var function: String = 'max' if formula['type'] == 'difs' else 'min'
				#single_difs_code += '//de = ' + function + '(de, ' + formula['id'] + '_sdf(original_z).x); // -@' + str(formula['index']) + '\n'
		#shader_code = shader_code.replace('// -@CheckOnlyDIFS', single_difs_code)
	
	if '// -@Uniforms' in shader_code:
		var uniforms_code: String = ""
		for formula in formulas:
			for variable_name in (formula['variables'].keys() as Array[String]):
				var variable: Dictionary = formula['variables'][variable_name]
				var import_check: String = ' // -@' + str(formula['index']) if LAZY_IMPORTING else ''
				uniforms_code += 'uniform ' + variable['type'].replace('selection', 'int') + ' f' + formula['id'] + '_' + variable_name + ';' + import_check + '\n'
		
		shader_code = shader_code.replace('// -@Uniforms', uniforms_code)
	
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
	
	%Fractal.material_override.shader = shader

func _input(event: InputEvent) -> void:
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
