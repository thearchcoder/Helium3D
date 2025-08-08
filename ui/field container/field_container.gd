extends MarginContainer

enum FieldTypes { SELECTION, INT, FLOAT, VEC2, VEC3, VEC4, BOOL }

@export var fields_list_id: int = 1
@export var light_id: int = 1  # only if fields_list_id is 7
var fields: Array = []

const FONT = preload('res://resources/font/Rubik-SemiBold.ttf')
const FLOAT_FIELD_SCENE = preload('res://ui/fields/float field/float_field.tscn')
const INT_FIELD_SCENE = preload('res://ui/fields/int field/int_field.tscn')
const VECTOR2_FIELD_SCENE = preload('res://ui/fields/vec2 field/vec2_field.tscn')
const VECTOR3_FIELD_SCENE = preload('res://ui/fields/vec3 field/vec3_field.tscn')
const VECTOR4_FIELD_SCENE = preload('res://ui/fields/vec4 field/vec4_field.tscn')
const SELECTION_FIELD_SCENE = preload('res://ui/fields/selection field/selection_field.tscn')
const BOOLEAN_FIELD_SCENE = preload('res://ui/fields/boolean field/boolean_field.tscn')
const IMAGE_FIELD_SCENE = preload('res://ui/fields/image field/image_field.tscn')
const COLOR_FIELD_SCENE = preload('res://ui/fields/color field/color_field.tscn')
const BUTTON_FIELD_SCENE = preload('res://ui/fields/button field/button_field.tscn')
const PALETTE_FIELD_SCENE = preload('res://ui/fields/palette field/palette_field.tscn')

@onready var world: WorldEnvironment = %WorldEnvironment
var force_stop_tiled_render: bool = false

func field_changed(field_name: String, to: Variant) -> void: %TabContainer.field_changed(field_name, to)
func field_changed_non_shader(field_name: String, to: Variant, update_viewport: bool = true) -> void: %TabContainer.field_changed_non_shader(field_name, to, update_viewport)
func i_am_a_field_container() -> void: pass

func set_bloom_enabled(to: bool) -> void: 
	world.environment.glow_enabled = to
	%SubViewport.refresh_taa()
	field_changed_non_shader('bloom', to)

func set_bloom_intensity(to: float) -> void: 
	world.environment.glow_bloom = to
	%SubViewport.refresh_taa()
	field_changed_non_shader('bloom_intensity', to)

func set_bloom_falloff(to: float) -> void: 
	world.environment.glow_strength = to
	%SubViewport.refresh_taa()
	field_changed_non_shader('bloom_falloff', to)

func stop_tiled_render() -> void:
	force_stop_tiled_render = true
	get_tree().current_scene.busy_rendering_tiles = false
	await get_tree().process_frame
	force_stop_tiled_render = false

func compute_tiled_render() -> void:
	get_tree().current_scene.busy_rendering_tiles = true
	%PostDisplay.material.set_shader_parameter('display_tiled_render', false)
	
	var current_tile_node: Node
	var tiles_x_node: Node
	var tiles_y_node: Node
	for value_node in (Global.value_nodes as Array[Node]):
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
		
		if %SubViewport.antialiasing != %SubViewport.AntiAliasing.TAA:
			if force_stop_tiled_render: return
			await get_tree().process_frame
		else:
			for j in (get_tree().current_scene.taa_samples as int):
				if force_stop_tiled_render: return
				await get_tree().process_frame
		
		var texture: Texture = %TextureRect.texture
		var target_dir := DirAccess.open(get_tree().current_scene.HELIUM3D_PATH)
		if not target_dir.dir_exists("tilerender"):
			target_dir.make_dir("tilerender")
		var image: Image = texture.get_image()
		var path: String = get_tree().current_scene.HELIUM3D_PATH + "/tilerender/tile_" + str(i) + ".png"
		image.save_png(path)
		images.append(image)
		tile_paths.append(path)
	
	var img_width: int = images[0].get_width()
	var img_height: int = images[0].get_height()
	
	var final_image: Image = images[0].duplicate()
	
	for y in tiles_y:
		for x in tiles_x:
			var idx: int = y * tiles_x + x
			if idx < images.size():
				@warning_ignore('integer_division')
				var start_x: int = (x * img_width) / tiles_x
				@warning_ignore('integer_division')
				var end_x: int = ((x + 1) * img_width) / tiles_x
				@warning_ignore('integer_division')
				var start_y: int = (y * img_height) / tiles_y
				@warning_ignore('integer_division')
				var end_y: int = ((y + 1) * img_height) / tiles_y
				
				var tile_width: int = end_x - start_x
				var tile_height: int = end_y - start_y
				
				var src_rect: Rect2i = Rect2i(start_x, start_y, tile_width, tile_height)
				var dst_pos: Vector2i = Vector2i(start_x, start_y)
				
				final_image.blit_rect(images[idx], src_rect, dst_pos)
				if force_stop_tiled_render: return
	
	var dir := DirAccess.open(get_tree().current_scene.HELIUM3D_PATH)
	for path in tile_paths:
		if dir.file_exists(path):
			dir.remove(path)
	
	final_image.save_png(get_tree().current_scene.HELIUM3D_PATH + "/tilerender/combined.png")
	
	%PostDisplay.material.set_shader_parameter('display_tiled_render', true)
	%PostDisplay.material.set_shader_parameter('tiled_render', ImageTexture.create_from_image(final_image))
	get_tree().current_scene.busy_rendering_tiles = false

func _ready() -> void:
	var l: String = str(light_id)
	var ALL_FIELD_CONTAINER_FIELDS := {
		# Lighting
		7: [
			{'name': 'light'+l+'_position', 'type': 'vec3', 'from': Vector3(-20, -20, -20), 'to': Vector3(20, 20, 20), 'default_value': Vector3(10, 10, 10)},
			{'name': 'light'+l+'_enabled', 'type': 'bool', 'default_value': true if light_id == 1 else false},
			{'name': 'light'+l+'_color', 'type': 'color', 'default_value': Color('white')},
			{'name': 'light'+l+'_intensity', 'type': 'float', 'from': 0, 'to': 2, 'default_value': 0.725},
			{'name': 'light'+l+'_radius', 'type': 'float', 'from': 0, 'to': 2, 'default_value': 0.1},
		],
		# Lighting / General
		6: [
			# Shadow
			{'name': 'hard_shadows', 'type': 'bool', 'default_value': false},
			{'name': 'shadow_steps', 'type': 'int', 'from': 0, 'to': 400, 'default_value': 230},
			{'name': 'shadow_epsilon', 'advanced_only': true, 'type': 'float', 'from': 0, 'to': 0.4, 'default_value': 0.004},
			{'name': 'shadow_raystep_multiplier', 'advanced_only': true, 'type': 'float', 'from': 0.2, 'to': 3.0, 'default_value': 1.0},
			
			# Specular highlights
			{'name': 'specular_intensity', 'type': 'float', 'from': 0.0, 'to': 100.0, 'default_value': 15},
			{'name': 'specular_sharpness', 'type': 'float', 'from': 0.0, 'to': 40.0, 'default_value': 20},

			# Reflections
			{'name': 'reflection_intensity', 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 0.0, 'onchange_override': func(val: float) -> void:
			%Fractal.material_override.set_shader_parameter('reflection_intensity', val)
			get_tree().current_scene.using_reflections = val >= 0.000001
			get_tree().current_scene.update_fractal_code(%TabContainer.current_formulas)
			field_changed_non_shader('reflection_intensity', val)
			},
			{'name': 'reflection_bounces', 'type': 'int', 'from': 0, 'to': 6, 'default_value': 1},
		],
		# Lighting / Background
		19: [
			{'name': 'bg_type', 'type': 'selection', 'values': ['Color', 'Image'], 'default_value': 'Color'},
			{'name': 'bg_color', 'type': 'palette', 'default_value': {'special_field': true, 'type': 'palette', 'is_blurry': false, 'offsets': PackedFloat32Array([0.0]), 'colors': PackedColorArray([Color('#2e2e2e')])}},
			{'name': 'bg_image', 'type': 'image', 'default_value': null},
			{'name': 'transparent_bg', 'advanced_only': true, 'type': 'bool', 'default_value': false, 'onchange_override': func(value: bool) -> void: 
				%SubViewport.transparent_bg = value
				field_changed('transparent_bg', value)
				},
		],
		# Material / Diffuse
		15: [
			{'name': 'palette', 'type': 'palette', 'default_value': {'special_field': true, 'type': 'palette', 'is_blurry': false, 'offsets': PackedFloat32Array([0.0]), 'colors': PackedColorArray([Color('cccccc')])}},
			{'name': 'coloring_mode', 'type': 'int', 'from': 0, 'to': 10, 'default_value': 0},
			{'name': 'color_offset', 'type': 'float', 'from': 0, 'to': 2, 'default_value': 0},
			{'name': 'color_exponent', 'advanced_only': true, 'type': 'float', 'from': 0, 'to': 4, 'default_value': 2},
			{'name': 'color_wrapping', 'advanced_only': true, 'type': 'int', 'from': 0, 'to': 6, 'default_value': 0},
			{'name': 'color_min_iterations', 'advanced_only': true, 'type': 'int', 'from': 0, 'to': 100, 'default_value': 0},
			{'name': 'color_max_iterations', 'advanced_only': true, 'type': 'int', 'from': 0, 'to': 100, 'default_value': 30},
		],
		# Material / Normals
		22: [
			{'name': 'normal_map', 'type': 'image', 'default_value': null},
			{'name': 'normal_map_enabled', 'type': 'bool', 'default_value': false},
			{'name': 'normal_map_projection', 'advanced_only': true, 'type': 'selection', 'values': ['Spherical', 'Planar', 'Triplanar'], 'default_value': 'Triplanar'},
			{'name': 'normal_map_scale', 'type': 'float', 'from': 0, 'to': 4, 'default_value': 0.8},
			{'name': 'normal_map_triplanar_sharpness', 'advanced_only': true, 'type': 'float', 'from': 0, 'to': 64, 'default_value': 12},
			{'name': 'normal_map_height', 'type': 'float', 'from': -12, 'to': 12, 'default_value': 1},
			{'name': 'normal_epsilon', 'type': 'float', 'from': 0, 'to': 0.08, 'default_value': 0.033},
			{'name': 'connect_normal_to_epsilon', 'advanced_only': true, 'type': 'bool', 'default_value': true},
		],
		# Material / Ambient Occlusion
		23: [
			{'name': 'ambient_occlusion_distance', 'type': 'float', 'from': 0, 'to': 0.4, 'default_value': 0.07},
			{'name': 'ambient_occlusion_radius', 'type': 'float', 'from': 0.01, 'to': 1.0, 'default_value': 0.439},
			{'name': 'ambient_occlusion_steps', 'advanced_only': true, 'type': 'int', 'from': 1, 'to': 25, 'default_value': 12},
			{'name': 'ambient_occlusion_light_affect', 'advanced_only': true, 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 0},
		],
		# Material / Ambient
		24: [
			{'name': 'ambient_light', 'type': 'float', 'from': 0.0, 'to': 0.2, 'default_value': 0.005},
			{'name': 'ambient_light_from_background', 'type': 'bool', 'default_value': false},
			{'name': 'ambient_light_color', 'type': 'color', 'default_value': Color('white')},
		],
		# Randomization
		25: [
			{'name': 'chance', 'type': 'float', 'from': 0, 'to': 100, 'default_value': 20, 'onchange_override': func(val: float) -> void:
			%Randomization.chance = val
			field_changed_non_shader('chance', val, false)
			},
			{'name': 'strength', 'type': 'float', 'from': 0.0, 'to': 10.0, 'default_value': 0.2, 'onchange_override': func(val: float) -> void:
			%Randomization.strength = val
			field_changed_non_shader('strength', val, false)
			},
		],
		# Voxelization
		26: [
			{'name': 'bounds_size', 'type': 'vec3', 'from': Vector3(0, 0, 0), 'to': Vector3(5, 5, 5), 'default_value': Vector3(2.5, 2.5, 2.5)},
			{'name': 'bounds_position', 'type': 'vec3', 'from': Vector3(-5, -5, -5), 'to': Vector3(5, 5, 5), 'default_value': Vector3(0, 0, 0)},
			{'name': 'voxel_resolution', 'type': 'int', 'from': 100, 'to': 1000, 'default_value': 450},
			{'name': 'voxel_epsilon', 'type': 'float', 'from': 0.0, 'to': 0.01, 'default_value': 0.001},
		],
		# Effects / Vignette
		8: [
			{'name': 'vignette_radius', 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 0.9},
			{'name': 'vignette_strength', 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 1.0},
			{'name': 'is_exponential', 'advanced_only': true, 'type': 'bool', 'default_value': true}
		],
		# Effects / Fog
		9: [
			{'name': 'fog_density', 'type': 'float', 'from': 0.0, 'to': 0.4, 'default_value': 0.0},
			{'name': 'fog_falloff', 'type': 'float', 'from': 0.0, 'to': 4.1, 'default_value': 1.64},
			{'name': 'fog_color', 'type': 'color', 'default_value': Color(0.5, 0.6, 0.7)},
		],
		# Modifiers / Cut
		10: [
			{'name': 'cut', 'type': 'bool', 'default_value': false},
			{'name': 'interior_mode', 'advanced_only': true, 'type': 'bool', 'default_value': false},
			{'name': 'cut_normal', 'type': 'vec3', 'from': Vector3(0, 0, 0), 'to': Vector3(1, 1, 1), 'default_value': Vector3(0, 1, 0)},
			{'name': 'cut_position', 'type': 'vec3', 'from': Vector3(-5, -5, -5), 'to': Vector3(5, 5, 5), 'default_value': Vector3(0, 0, 0)},
		],
		# Modifiers / Repeat
		17: [
			{'name': 'repeat', 'type': 'bool', 'default_value': false},
			{'name': 'repeat_gap', 'type': 'vec3', 'from': Vector3(0, 0, 0), 'to': Vector3(20, 20, 20), 'default_value': Vector3(5, 5, 5)},
		],
		# Settings / General
		18: [
			# TAA max samples
			{'name': 'taa_samples', 'type': 'int', 'from': 2, 'to': 32, 'default_value': 16, 'onchange_override': func(val: int) -> void:
				get_tree().current_scene.taa_samples = val
				field_changed_non_shader('taa_samples', val)
				},
			
			# Texture filter
			{'name': 'texture_filter', 'type': 'selection', 'values': ['Linear', 'Nearest'], 'default_value': 'Linear', 'onchange_override': func(val: String) -> void:
				if val == 'Linear':
					%TextureRect.texture_filter = TEXTURE_FILTER_LINEAR
				elif val == 'Nearest':
					%TextureRect.texture_filter = TEXTURE_FILTER_NEAREST
				field_changed_non_shader('texture_filter', val)
				},
			
			# Progressive rendering strength
			{'name': 'low_scaling', 'type': 'float', 'from': 0.25, 'to': 1.0, 'default_value': 0.4, 'onchange_override': func(val: float) -> void:
				var iupscaling: float = 1.0 - %SubViewport.upscaling
				val -= iupscaling
				val = clamp(val, 0.25, 1.0)
				%SubViewport.low_scaling = val
				field_changed_non_shader('low_scaling', val)
				},
			
			# Fractal DIFS/Primitive smoothing
			{'name': 'difs_smoothing', 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 0.0},
			{'name': 'exponential_smoothing', 'type': 'bool', 'default_value': false},
		],
		# Settings / Debug
		20: [
			{'name': 'display', 'type': 'selection', 'values': ['Render', 'Occlusion', 'Normals', 'Depth'], 'default_value': 'Render'},
			{'name': 'depth_scale', 'advanced_only': true, 'type': 'float', 'from': 0, 'to': 4, 'default_value': 0.3}
		],
		# Modifiers / Transform
		16: [
			{'name': 'sphere_inversion', 'type': 'bool', 'default_value': false},
			{'name': 'inversion_sphere', 'type': 'vec4', 'from': Vector4(-2, -2, -2, 0.1), 'to': Vector4(2, 2, 2, 1), 'default_value': Vector4(1, 1, 0, 0.75)},
			{'name': 'translation', 'advanced_only': true, 'type': 'vec3', 'from': Vector3(-4, -4, -4), 'to': Vector3(4, 4, 4), 'default_value': Vector3(0, 0, 0)},
			{'name': 'rotation', 'advanced_only': true, 'type': 'vec3', 'from': Vector3(-PI, -PI, -PI), 'to': Vector3(PI, PI, PI), 'default_value': Vector3(0, 0, 0)},
			{'name': 'kalaidoscope', 'type': 'vec3', 'from': Vector3(1, 1, 1), 'to': Vector3(40, 40, 40), 'default_value': Vector3(1, 1, 1)},
			{'name': 'kalaidoscope_mode', 'type': 'selection', 'values': ['Kite 1', 'Kite 2', 'Effie'], 'default_value': 'Kite 1'},
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
			{'name': 'outline_falloff', 'type': 'float', 'from': 0.0, 'to': 4.0, 'default_value': 3.2}
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
			get_tree().current_scene.using_dof = val
			get_tree().current_scene.update_fractal_code(%TabContainer.current_formulas)
			field_changed('dof_enabled', val)
			},
			{'name': 'dof_samples', 'type': 'int', 'from': 1, 'to': 20, 'default_value': 3},
			{'name': 'dof_focal_distance', 'type': 'float', 'from': 0.0, 'to': 4.0, 'default_value': 1.2},
			{'name': 'dof_aperture', 'type': 'float', 'from': 0.0, 'to': 0.1, 'default_value': 0.03},
			{'name': 'dof_lens_distance', 'type': 'float', 'from': 0.0, 'to': 4.0, 'default_value': 0.2},
		],
		# Rendering
		2: [
			{'name': 'anti_aliasing', 'type': 'selection', 'values': ['None', 'FXAA', 'TAA', 'SMAA'], 'default_value': 'None', 'onchange_override': func(val: Variant) -> void: 
			%ToolBar._on_antialiasing_value_changed(val)
			field_changed_non_shader('anti_aliasing', val)
			},
			{'name': 'iterations', 'type': 'int', 'from': 0, 'to': 50, 'default_value': 15},
			{'name': 'max_steps', 'type': 'int', 'from': 0, 'to': 600, 'default_value': 360},
			{'name': 'escape_radius', 'advanced_only': true, 'type': 'float', 'from': 0, 'to': 500, 'default_value': 16},
			{'name': 'camera_kalaidoscope', 'advanced_only': true, 'type': 'float', 'from': 1, 'to': 20, 'default_value': 1, 'onchange_override': func(val: Variant) -> void:
			%PostDisplay.material.set_shader_parameter('camera_kalaidoscope', val)
			field_changed_non_shader('camera_kalaidoscope', val)
			},
			{'name': 'fov', 'type': 'float', 'from': 10, 'to': 300, 'default_value': 75, 'advanced_only': true, 'onchange_override': func(val: Variant) -> void: 
			%Camera.fov = val
			field_changed_non_shader('fov', val)
			},
			{'name': 'max_distance', 'type': 'float', 'from': 0.0, 'to': 100.0, 'default_value': 30.0},
			{'name': 'raystep_multiplier', 'type': 'float', 'from': 0.01, 'to': 6.0, 'default_value': 1.0},
			{'name': 'epsilon', 'type': 'float', 'from': 0.0000001, 'to': 0.001, 'default_value': 0.0004},
			{'name': 'relative_epsilon', 'type': 'bool', 'default_value': true, 'advanced_only': true},
			{'name': 'de_mode', 'type': 'selection', 'values': ['LinearDE', 'LogDE', 'Automatic'], 'default_value': 'Automatic', 'advanced_only': true},
			{'name': 'camera_type', 'type': 'selection', 'values': ['Free', 'Panorama (Equirectangular)'], 'default_value': 'Free', 'advanced_only': true},
			{'name': 'resolution', 'ivec': true, 'type': 'vec2', 'from': Vector2(100, 100), 'to': Vector2(2560, 1440), 'default_value': Vector2(450, 450), 'onchange_override': func(val: Variant) -> void: 
			%SubViewport.size = val
			%PostViewport.size = val
			field_changed_non_shader('resolution', val)
			%SubViewport.refresh_taa()
			},
		],
		# Tools / Upscaling
		12: [
			{'name': 'sharpness', 'type': 'float', 'from': 0.0, 'to': 3.0, 'default_value': 0.0, 'onchange_override': func(val: float) -> void: %PostDisplay.material.set_shader_parameter('sharpness', val)},
			{'name': 'upscaling_factor', 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 1.0, 'onchange_override': func(val: float) -> void: %SubViewport.set_upscaling_factor(val)},
		],
		# Tools / Tiling
		14: [
			{'name': 'progression_strength', 'type': 'float', 'from': 0, 'to': 100, 'default_value': 100},
			{'name': 'tiled', 'type': 'bool', 'default_value': false, 'onchange_override': func(val: bool) -> void: 
			%SubViewport.refresh_taa()
			get_tree().current_scene.using_tiling = val
			get_tree().current_scene.update_fractal_code(%TabContainer.current_formulas)
			%Fractal.material_override.set_shader_parameter('tiled', val)
			if not val:
				%PostDisplay.material.set_shader_parameter('display_tiled_render', false)
			},
			{'name': 'tiles_x', 'type': 'int', 'from': 1, 'to': 32, 'default_value': 4},
			{'name': 'tiles_y', 'type': 'int', 'from': 1, 'to': 32, 'default_value': 4},
			{'name': 'current_tile', 'type': 'int', 'from': 0, 'to': 40, 'default_value': 0},
			{'name': 'compute_tiled_render', 'type': 'bool', 'default_value': false, 'onchange_override': func(val: bool) -> void:
				if Engine.get_frames_drawn() != 0: %Rendering.compute_tiled_render()
				},
		]
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
		var value_node: Control
		
		# Add value node
		if variable_data['type'] == 'float':
			value_node = FLOAT_FIELD_SCENE.instantiate()
			value_node.range = Vector2(variable_data['from'], variable_data['to'])
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		if variable_data['type'] == 'button':
			value_node = BUTTON_FIELD_SCENE.instantiate()
			value_node.text = variable_data['text']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('pressed', variable_data['pressed'])
			%Values.add_child(value_node)
		elif variable_data['type'] == 'int':
			value_node = INT_FIELD_SCENE.instantiate()
			value_node.range = Vector2(variable_data['from'], variable_data['to'])
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'palette':
			value_node = PALETTE_FIELD_SCENE.instantiate()
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'vec3':
			value_node = VECTOR3_FIELD_SCENE.instantiate()
			value_node.range_min = variable_data['from']
			value_node.range_max = variable_data['to']
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'vec2':
			value_node = VECTOR2_FIELD_SCENE.instantiate()
			value_node.range_min = variable_data['from']
			value_node.range_max = variable_data['to']
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			
			if variable_data.has('step'): 
				value_node.step = variable_data['step']
			
			if variable_data.has('ivec'): 
				value_node.ivec = variable_data['ivec']
			
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'color':
			value_node = COLOR_FIELD_SCENE.instantiate()
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'vec4':
			value_node = VECTOR4_FIELD_SCENE.instantiate()
			value_node.range_min = variable_data['from']
			value_node.range_max = variable_data['to']
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'selection':
			value_node = SELECTION_FIELD_SCENE.instantiate()
			value_node.set_options(Array(variable_data['values']) as Array[String])
			value_node.index = variable_data['values'].find(variable_data['default_value'])
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, value_node.options.find(to))))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'bool':
			value_node = BOOLEAN_FIELD_SCENE.instantiate()
			value_node.value = variable_data['default_value']
			value_node.name = variable_name.to_pascal_case()
			value_node.connect('value_changed', variable_data.get('onchange_override', func(to: Variant) -> void: field_changed(uniform_name, to)))
			%Values.add_child(value_node)
		elif variable_data['type'] == 'image':
			value_node = IMAGE_FIELD_SCENE.instantiate()
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
			label.add_theme_constant_override('line_spacing', 0)
		
		if %Values.get_node(variable_name.to_pascal_case()).has_method('i_am_a_vec4_field'):
			label.text += '\n'
			label.text += '\n'
			label.text += '\n'
			label.text += '\n'
			label.add_theme_constant_override('line_spacing', 0)
		
		$Fields/Names.add_child(label)
		value_node.set_meta('name_node', label)
		
		if variable_data.get('advanced_only', false):
			get_tree().current_scene.advanced_ui_fields.append(value_node)
		
		if variable_data.has('hidden') and variable_data['hidden'] == true:
			label.visible = false
			value_node.visible = false
