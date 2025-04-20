extends MarginContainer

enum FieldTypes { SELECTION, INT, FLOAT, VEC3, VEC4, BOOL }

@export var fields_list_id: int = 1
@export var light_id: int = 1  # only if fields_list_id is 7
var fields: Array = []

const FONT = preload('res://resources/font/Rubik-SemiBold.ttf')
const FLOAT_FIELD_SCENE = preload('res://ui/fields/float field/float_field.tscn')
const INT_FIELD_SCENE = preload('res://ui/fields/int field/int_field.tscn')
const VECTOR3_FIELD_SCENE = preload('res://ui/fields/vec3 field/vec3_field.tscn')
const VECTOR4_FIELD_SCENE = preload('res://ui/fields/vec4 field/vec4_field.tscn')
const SELECTION_FIELD_SCENE = preload('res://ui/fields/selection field/selection_field.tscn')
const BOOLEAN_FIELD_SCENE = preload('res://ui/fields/boolean field/boolean_field.tscn')
const COLOR_FIELD_SCENE = preload('res://ui/fields/color field/color_field.tscn')
const PALETTE_FIELD_SCENE = preload('res://ui/fields/palette field/palette_field.tscn')

@onready var world: WorldEnvironment = %WorldEnvironment

func field_changed(field_name: String, to: Variant) -> void: %TabContainer.field_changed(field_name, to)
func i_am_a_field_container() -> void: pass

func set_bloom_enabled(to: bool) -> void: 
	world.environment.glow_enabled = to
	%SubViewport.refresh_taa()

func set_bloom_intensity(to: float) -> void: 
	world.environment.glow_bloom = to
	%SubViewport.refresh_taa()

func set_bloom_falloff(to: float) -> void: 
	world.environment.glow_strength = to
	%SubViewport.refresh_taa()

func compute_tiled_render() -> void:
	%TextureRect.material.set_shader_parameter('display_tiled_render', false)
	
	var current_tile_node: Node
	var tiles_x_node: Node
	var tiles_y_node: Node
	for value_node in Global.value_nodes:
		if value_node.name == 'CurrentTile': current_tile_node = value_node
		if value_node.name == 'TilesX': tiles_x_node = value_node
		if value_node.name == 'TilesY': tiles_y_node = value_node
	
	if not current_tile_node || not tiles_x_node || not tiles_y_node:
		return
	
	var tiles_x: int = tiles_x_node.value
	var tiles_y: int = tiles_y_node.value
	var total_tiles: int = tiles_x * tiles_y
	
	current_tile_node.value = 0
	await get_tree().process_frame
	
	var images: Array[Image] = []
	var tile_paths: Array[String] = []
	
	for i in total_tiles:
		current_tile_node.value = i
		await get_tree().process_frame
		var texture: Texture = %TextureRect.texture
		var image: Image = texture.get_image()
		var path: String = "res://tilerender/tile_" + str(i) + ".png"
		image.save_png(path)
		images.append(image)
		tile_paths.append(path)
	
	print(images[0].get_width())
	var img_width: int = images[0].get_width()
	var img_height: int = images[0].get_height()
	
	var final_image: Image = images[0]
	
	for y in tiles_y:
		for x in tiles_x:
			var idx: int = y * tiles_x + x
			if idx < images.size():
				var tile_width: int = img_width / tiles_x
				var tile_height: int = img_height / tiles_y
				
				var src_rect: Rect2i = Rect2i(
					x * tile_width, 
					y * tile_height, 
					tile_width, 
					tile_height
				)
				
				var dst_pos: Vector2i = Vector2i(
					x * tile_width,
					y * tile_height
				)
				
				final_image.blend_rect(images[idx], src_rect, dst_pos)
	
	# Cleanup tile images
	var dir := DirAccess.open("res://")
	for path in tile_paths:
		if dir.file_exists(path):
			dir.remove(path)
	
	final_image.save_png("res://tilerender/combined.png")
	
	%TextureRect.material.set_shader_parameter('display_tiled_render', true)
	%TextureRect.material.set_shader_parameter('tiled_render', ImageTexture.create_from_image(final_image))
	%Logs.print_console("Tiled render complete, Total tiles rendered: " + str(tiles_x * tiles_y))

func _ready() -> void:
	var l: String = str(light_id)
	var ALL_FIELD_CONTAINER_FIELDS := {
		# Lighting
		7: [
			{'name': 'light'+l+'_position', 'type': 'vec3', 'from': Vector3(-20, -20, -20), 'to': Vector3(20, 20, 20), 'default_value': Vector3(10, 10, 10)},
			{'name': 'light'+l+'_color', 'type': 'color', 'default_value': Color('white')},

			{'name': 'shadow_steps', 'type': 'int', 'from': 0, 'to': 128, 'default_value': 64},
			{'name': 'shadow_epsilon', 'type': 'float', 'from': 0, 'to': 0.4, 'default_value': 0.0001},
			{'name': 'shadow_raystep_multiplier', 'type': 'float', 'from': 1.0, 'to': 3.0, 'default_value': 1.5},

			{'name': 'ambient_light', 'type': 'float', 'from': 0.0, 'to': 0.05, 'default_value': 0.004},
			{'name': 'specular_intensity', 'type': 'float', 'from': 0.0, 'to': 100.0, 'default_value': 15},
			{'name': 'specular_sharpness', 'type': 'float', 'from': 0.0, 'to': 40.0, 'default_value': 20},

			{'name': 'palette', 'type': 'palette', 'offsets': [0.0], 'colors': [Color('#cccccc')]},
			{'name': 'bg_color', 'type': 'palette', 'offsets': [0.0], 'colors': [Color('#2e2e2e')]},
			{'name': 'coloring_mode', 'type': 'int', 'from': 0, 'to': 20, 'default_value': 0}
		],
		# Effects / Vignette
		8: [
			{'name': 'vignette_radius', 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 0.9},
			{'name': 'vignette_strength', 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 1.0},
			{'name': 'is_exponential', 'type': 'bool', 'default_value': true}
		],
		# Effects / Fog
		9: [
			{'name': 'fog_density', 'type': 'float', 'from': 0.0, 'to': 0.4, 'default_value': 0.0},
			{'name': 'fog_falloff', 'type': 'float', 'from': 0.0, 'to': 4.1, 'default_value': 1.64},
			{'name': 'fog_color', 'type': 'color', 'default_value': Color(0.5, 0.6, 0.7)},
		],
		# Effects / Modifiers
		10: [
			{'name': 'cut', 'type': 'bool', 'default_value': false},
			{'name': 'cut_normal', 'type': 'vec3', 'from': Vector3(0, 0, 0), 'to': Vector3(1, 1, 1), 'default_value': Vector3(0, 1, 0)},
			{'name': 'cut_position', 'type': 'vec3', 'from': Vector3(-5, -5, -5), 'to': Vector3(5, 5, 5), 'default_value': Vector3(0, 0, 0)},
			{'name': 'repeat', 'type': 'bool', 'default_value': false},
			{'name': 'repeat_gap', 'type': 'vec3', 'from': Vector3(0, 0, 0), 'to': Vector3(20, 20, 20), 'default_value': Vector3(5, 5, 5)},
		],
		# Effects / Fresnel
		11: [
			{'name': 'fresnel_color', 'type': 'color', 'default_value': Color('white')},
			{'name': 'fresnel_intensity', 'type': 'float', 'from': 0.0, 'to': 0.01, 'default_value': 0.00},
			{'name': 'fresnel_falloff', 'type': 'float', 'from': 0.0, 'to': 20.0, 'default_value': 5.0},
		],
		# Effects / Outline
		1: [
			{'name': 'outline', 'type': 'bool', 'default_value': false},
			{'name': 'outline_color', 'type': 'color', 'default_value': Color(1.0, 1.0, 1.0)},
			{'name': 'outline_intensity', 'type': 'float', 'from': 0.0, 'to': 4.0, 'default_value': 0.74},
			{'name': 'outline_threshold', 'type': 'float', 'from': 0.0, 'to': 80.0, 'default_value': 19.34},
			{'name': 'outline_falloff', 'type': 'float', 'from': 0.0, 'to': 4.0, 'default_value': 3.2},
		],
		# Effects / Ambient Occlusion
		6: [
			{'name': 'ambient_occlusion_radius', 'type': 'float', 'from': 0.01, 'to': 1.0, 'default_value': 0.425},
			{'name': 'ambient_occlusion_brightness', 'type': 'float', 'from': -1.0, 'to': 1.0, 'default_value': 0.0},
			{'name': 'ambient_occlusion_steps', 'type': 'int', 'from': 1, 'to': 25, 'default_value': 12},
		],
		# Effects / Tone Mapping
		4: [
			{'name': 'gamma', 'type': 'float', 'from': 0.5, 'to': 4.0, 'default_value': 1.42},
			{'name': 'exposure', 'type': 'float', 'from': 0.5, 'to': 5.0, 'default_value': 1.5},
			{'name': 'tone_mapping', 'type': 'selection', 'values': ['Linear', 'Simple Reinhard', 'Luma Reinhard', 'White Luma Reinhard', 'Rom Bin Da House', 'Filmic', 'Uncharted2', 'ACES'], 'default_value': 'Simple Reinhard'},
		],
		# Effects / Bloom
		3: [
			{'name': 'bloom', 'type': 'bool', 'default_value': false, 'onchange_override': func(to: Variant) -> void: set_bloom_enabled(to)},
			{'name': 'bloom_intensity', 'type': 'float', 'from': 0.0, 'to': 4.0, 'default_value': 0.44, 'onchange_override': func(to: Variant) -> void: set_bloom_intensity(to)},
			{'name': 'bloom_falloff', 'type': 'float', 'from': 0.0, 'to': 4.0, 'default_value': 0.492, 'onchange_override': func(to: Variant) -> void: set_bloom_falloff(to)},
		],
		# Effects / DOF
		5: [
			{'name': 'dof_enabled', 'type': 'bool', 'default_value': false, 'onchange_override': func(val: bool) -> void: 
			%Fractal.material_override.set_shader_parameter('dof_enabled', val)
			get_tree().current_scene.using_dof = val
			get_tree().current_scene.update_fractal_code(%TabContainer.current_formulas)
			%SubViewport.refresh_taa()
			},
			{'name': 'dof_samples', 'type': 'int', 'from': 1, 'to': 20, 'default_value': 3},
			{'name': 'dof_focal_distance', 'type': 'float', 'from': 0.0, 'to': 4.0, 'default_value': 1.2},
			{'name': 'dof_aperture', 'type': 'float', 'from': 0.0, 'to': 0.1, 'default_value': 0.03},
			{'name': 'dof_lens_distance', 'type': 'float', 'from': 0.0, 'to': 4.0, 'default_value': 0.2},
		],
		# Rendering
		2: [
			{'name': 'iterations', 'type': 'int', 'from': 0, 'to': 50, 'default_value': 15},
			{'name': 'max_steps', 'type': 'int', 'from': 0, 'to': 600, 'default_value': 120},
			{'name': 'escape_radius', 'type': 'float', 'from': 0, 'to': 500, 'default_value': 16},
			{'name': 'max_distance', 'type': 'float', 'from': 0.0, 'to': 100.0, 'default_value': 30.0},
			{'name': 'raystep_multiplier', 'type': 'float', 'from': 0.01, 'to': 6.0, 'default_value': 1.0},
			{'name': 'epsilon', 'type': 'float', 'from': 0.0000001, 'to': 0.01, 'default_value': 0.001},
			{'name': 'relative_epsilon', 'type': 'bool', 'default_value': true},
		],
		# Performance / Upscaling
		12: [
			{'name': 'sharpness', 'type': 'float', 'from': 0.0, 'to': 3.0, 'default_value': 0.0, 'onchange_override': func(val: float) -> void: %TextureRect.material.set_shader_parameter('sharpness', val)},
			{'name': 'upscaling_factor', 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 1.0, 'onchange_override': func(val: float) -> void: %SubViewport.set_upscaling_factor(val)},
		],
		# Performance / Tiling
		14: [
			{'name': 'tiled', 'type': 'bool', 'default_value': false, 'onchange_override': func(val: bool) -> void: 
			%Fractal.material_override.set_shader_parameter('tiled', val)
			get_tree().current_scene.using_tiling = val
			get_tree().current_scene.update_fractal_code(%TabContainer.current_formulas)
			%SubViewport.refresh_taa()
			if not val:
				%TextureRect.material.set_shader_parameter('display_tiled_render', false)
			},
			{'name': 'compute_tiles', 'type': 'bool', 'default_value': false, 'onchange_override': func(val: bool) -> void: 
			compute_tiled_render()
			},
			{'name': 'tiles_x', 'type': 'int', 'from': 1, 'to': 32, 'default_value': 4},
			{'name': 'tiles_y', 'type': 'int', 'from': 1, 'to': 32, 'default_value': 4},
			{'name': 'current_tile', 'type': 'int', 'from': 0, 'to': 40, 'default_value': 0},
		],
		# Lighting / Global Illumination
		13: [
			{'name': 'global_illumination', 'type': 'bool', 'default_value': false},
			{'name': 'gi_bounces', 'type': 'int', 'from': 1, 'to': 12, 'default_value': 2},
			{'name': 'gi_intensity', 'type': 'float', 'from': 0.0, 'to': 2.0, 'default_value': 0.5},
			{'name': 'gi_distance', 'type': 'float', 'from': 0.1, 'to': 12.0, 'default_value': 1.0},
		],
	}
	fields = ALL_FIELD_CONTAINER_FIELDS[fields_list_id]
	update_fields_ui()

func add_spaces(text: String) -> String:
	var result := ""
	for i in range(text.length()):
		var char := text[i]
		if i > 0 and char == char.to_upper():
			result += " "
		result += char
	return result

func update_fields_ui() -> void:
	for field in (fields as Array[Dictionary]):
		var variable_data: Dictionary = field
		var variable_name: String = field['name']
		var uniform_name: String = variable_name
		
		# Add value node
		if variable_data['type'] == 'float':
			var value_node: Control = FLOAT_FIELD_SCENE.instantiate()
			value_node.range = Vector2(variable_data['from'], variable_data['to'])
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'int':
			var value_node: Control = INT_FIELD_SCENE.instantiate()
			value_node.range = Vector2(variable_data['from'], variable_data['to'])
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'palette':
			var value_node: Control = PALETTE_FIELD_SCENE.instantiate()
			#value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
			value_node.set_value(PackedFloat32Array(variable_data['offsets']), PackedColorArray(variable_data['colors']))
		elif variable_data['type'] == 'vec3':
			var value_node: Control = VECTOR3_FIELD_SCENE.instantiate()
			value_node.range_min = variable_data['from']
			value_node.range_max = variable_data['to']
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'color':
			var value_node: Control = COLOR_FIELD_SCENE.instantiate()
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'vec4':
			var value_node: Control = VECTOR4_FIELD_SCENE.instantiate()
			value_node.range_min = variable_data['from']
			value_node.range_max = variable_data['to']
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'selection':
			var value_node: Control = SELECTION_FIELD_SCENE.instantiate()
			value_node.set_options(Array(variable_data['values']) as Array[String])
			value_node.index = variable_data['values'].find(variable_data['default_value'])
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, value_node.options.find(to))))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'bool':
			var value_node: Control = BOOLEAN_FIELD_SCENE.instantiate()
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		
		# Add name node
		var as_array := variable_name.split('_')
		var text := "_".join(PackedStringArray(as_array)).to_pascal_case()
		text = add_spaces(text)
		text = text.trim_prefix('4d ')
		
		var label: Label = Label.new()
		label.text = text
		label.name = text
		label.add_theme_font_override('font', FONT)
		label.text += ': '
		
		if %Values.get_node(variable_name.to_pascal_case()).has_method('i_am_a_vec3_field'):
			label.text += '\n'
			label.text += '\n'
			label.text += '\n'
			label.add_theme_constant_override('line_spacing', 8)
		
		if %Values.get_node(variable_name.to_pascal_case()).has_method('i_am_a_vec4_field'):
			label.text += '\n'
			label.text += '\n'
			label.text += '\n'
			label.text += '\n'
			label.add_theme_constant_override('line_spacing', 8)
		
		$Fields/Names.add_child(label)
