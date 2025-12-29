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
var rendering_tiles: bool = false
var should_start_tiled_render: bool = false
var is_computing_tiles_internally: bool = false
var restart_tile_loop: bool = false
var performance_tracking: Dictionary = {}

func start_timer(label: String) -> float:
	var start_time: float = Time.get_ticks_usec() / 1000000.0
	performance_tracking[label] = start_time
	return start_time

func end_timer(label: String) -> float:
	if not performance_tracking.has(label):
		push_error("Timer '%s' was never started" % label)
		return 0.0
	
	var start_time: float = performance_tracking[label]
	var end_time: float = Time.get_ticks_usec() / 1000000.0
	var elapsed: float = end_time - start_time
	
	#print("[PERF] %s: %.3f ms" % [label, elapsed * 1000.0])
	performance_tracking.erase(label)
	return elapsed

func field_changed(field_name: String, to: Variant) -> void: %TabContainer.field_changed(field_name, to)
func field_changed_non_shader(field_name: String, to: Variant, update_viewport: bool = true) -> void: %TabContainer.field_changed_non_shader(field_name, to, update_viewport)
func i_am_a_field_container() -> void: pass

func set_bloom_enabled(to: bool) -> void: 
	world.environment.glow_enabled = to
	%SubViewport.refresh()
	field_changed_non_shader('bloom', to)

func set_bloom_intensity(to: float) -> void: 
	world.environment.glow_bloom = to
	%SubViewport.refresh()
	field_changed_non_shader('bloom_intensity', to)

func set_bloom_falloff(to: float) -> void: 
	world.environment.glow_strength = to
	%SubViewport.refresh()
	field_changed_non_shader('bloom_falloff', to)

func stop_tiled_render() -> void:
	force_stop_tiled_render = true
	should_start_tiled_render = false

	var current_tile_node: Node
	var tiles_x_node: Node
	var tiles_y_node: Node
	for value_node in (Global.value_nodes as Array[Node]):
		if value_node.name == 'CurrentTile':
			current_tile_node = value_node
		if value_node.name == 'TilesX':
			tiles_x_node = value_node
		if value_node.name == 'TilesY':
			tiles_y_node = value_node

	if current_tile_node and tiles_x_node and tiles_y_node:
		var tiles_x: int = tiles_x_node.value
		var tiles_y: int = tiles_y_node.value
		var center_tile: int = (tiles_y / 2) * tiles_x + (tiles_x / 2)
		current_tile_node.value = center_tile

func update_tile_bounds() -> void:
	var tiles_x_node: Node
	var tiles_y_node: Node
	var current_tile_node: Node

	for value_node in (Global.value_nodes as Array[Node]):
		if value_node.name == 'TilesX': tiles_x_node = value_node
		if value_node.name == 'TilesY': tiles_y_node = value_node
		if value_node.name == 'CurrentTile': current_tile_node = value_node

	if not tiles_x_node or not tiles_y_node or not current_tile_node:
		return

	var tiles_x: int = tiles_x_node.value
	var tiles_y: int = tiles_y_node.value
	var current_tile: int = current_tile_node.value

	var tile_x_pos: int = current_tile % tiles_x
	@warning_ignore("integer_division")
	var tile_y_pos: int = current_tile / tiles_x

	var tile_size: Vector2 = Vector2(1.0 / float(tiles_x), 1.0 / float(tiles_y))
	var error_margin: float = 2.0
	var viewport_size: Vector2 = %SubViewport.size
	var padding: Vector2 = Vector2(error_margin, error_margin) / viewport_size

	var tile_start: Vector2 = Vector2(float(tile_x_pos), float(tile_y_pos)) * tile_size
	var tile_end: Vector2 = tile_start + tile_size

	var tile_min: Vector2 = (tile_start - padding).max(Vector2.ZERO)
	var tile_max: Vector2 = (tile_end + padding).min(Vector2.ONE)

	var tile_bounds: Vector4 = Vector4(tile_min.x, tile_min.y, tile_max.x, tile_max.y)
	%Fractal.material_override.set_shader_parameter('tile_bounds', tile_bounds)

func get_spiral_tile_order(tiles_x: int, tiles_y: int) -> Array[int]:
	var order: Array[int] = []
	var center_x: float = (tiles_x - 1) / 2.0
	var center_y: float = (tiles_y - 1) / 2.0

	var tiles: Array[Dictionary] = []
	for y in tiles_y:
		for x in tiles_x:
			var dx: float = float(x) - center_x
			var dy: float = float(y) - center_y
			var distance: float = dx * dx + dy * dy
			tiles.append({"index": y * tiles_x + x, "distance": distance})

	tiles.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.distance < b.distance)

	for tile in tiles:
		order.append(tile.index)

	return order

func compute_tiled_render() -> void:
	start_timer("compute_tiled_render_total")
	
	if get_tree().current_scene.busy_rendering_tiles:
		should_start_tiled_render = true
		return

	rendering_tiles = true
	get_tree().current_scene.busy_rendering_tiles = true
	should_start_tiled_render = false
	force_stop_tiled_render = false
	%PostDisplay.material.set_shader_parameter('display_tiled_render', false)

	var current_tile_node: Node
	var tiles_x_node: Node
	var tiles_y_node: Node
	for value_node in (Global.value_nodes as Array[Node]):
		if value_node.name == 'CurrentTile': current_tile_node = value_node
		if value_node.name == 'TilesX': tiles_x_node = value_node
		if value_node.name == 'TilesY': tiles_y_node = value_node

	if not current_tile_node || not tiles_x_node || not tiles_y_node:
		rendering_tiles = false
		get_tree().current_scene.busy_rendering_tiles = false
		end_timer("compute_tiled_render_total")
		return

	var tiles_x: int = tiles_x_node.value
	var tiles_y: int = tiles_y_node.value
	var total_tiles: int = tiles_x * tiles_y

	var center_tile: int = (tiles_y / 2) * tiles_x + (tiles_x / 2)
	current_tile_node.value = center_tile
	await get_tree().process_frame

	start_timer("get_spiral_order")
	var spiral_order: Array[int] = get_spiral_tile_order(tiles_x, tiles_y)
	end_timer("get_spiral_order")

	is_computing_tiles_internally = true

	start_timer("create_initial_image")
	var first_texture: Texture = %SubViewport.get_texture()
	var first_image: Image = first_texture.get_image()
	var img_width: int = first_image.get_width()
	var img_height: int = first_image.get_height()
	var img_format: Image.Format = first_image.get_format()

	var final_image: Image = Image.create(img_width, img_height, false, img_format)
	final_image.fill(Color(0, 0, 0, 1))
	end_timer("create_initial_image")

	%PostDisplay.material.set_shader_parameter('display_tiled_render', true)
	%PostDisplay.material.set_shader_parameter('tiled_render', ImageTexture.create_from_image(final_image))

	var i := 0
	while i < total_tiles:
		start_timer("tile_%d" % i)
		
		if restart_tile_loop:
			start_timer("restart_loop")
			current_tile_node.value = center_tile
			spiral_order = get_spiral_tile_order(tiles_x, tiles_y)
			final_image = Image.create(img_width, img_height, false, img_format)
			final_image.fill(Color(0, 0, 0, 1))
			%PostDisplay.material.set_shader_parameter('tiled_render', ImageTexture.create_from_image(final_image))
			restart_tile_loop = false
			i = 0
			end_timer("restart_loop")

		var tile_index: int = spiral_order[i]
		current_tile_node.value = tile_index
		
		start_timer("tile_%d_viewport_refresh" % i)
		%SubViewport.refresh(true)
		end_timer("tile_%d_viewport_refresh" % i)

		if force_stop_tiled_render:
			is_computing_tiles_internally = false
			rendering_tiles = false
			get_tree().current_scene.busy_rendering_tiles = false
			%PostDisplay.material.set_shader_parameter('display_tiled_render', false)
			end_timer("tile_%d" % i)
			end_timer("compute_tiled_render_total")
			if should_start_tiled_render:
				compute_tiled_render()
			return

		start_timer("tile_%d_wait_frames" % i)
		if %SubViewport.antialiasing != %SubViewport.AntiAliasing.TAA:
			if force_stop_tiled_render:
				is_computing_tiles_internally = false
				rendering_tiles = false
				get_tree().current_scene.busy_rendering_tiles = false
				%PostDisplay.material.set_shader_parameter('display_tiled_render', false)
				end_timer("tile_%d_wait_frames" % i)
				end_timer("tile_%d" % i)
				end_timer("compute_tiled_render_total")
				return
			await get_tree().process_frame
			await get_tree().process_frame
		else:
			for j in (get_tree().current_scene.taa_samples as int):
				if force_stop_tiled_render:
					is_computing_tiles_internally = false
					rendering_tiles = false
					get_tree().current_scene.busy_rendering_tiles = false
					%PostDisplay.material.set_shader_parameter('display_tiled_render', false)
					end_timer("tile_%d_wait_frames" % i)
					end_timer("tile_%d" % i)
					end_timer("compute_tiled_render_total")
					return
				await get_tree().process_frame
		end_timer("tile_%d_wait_frames" % i)

		start_timer("tile_%d_image_operations" % i)
		var tile_texture: Texture = %SubViewport.get_texture()
		var tile_image: Image = tile_texture.get_image()

		var tile_x_pos: int = tile_index % tiles_x
		@warning_ignore("integer_division")
		var tile_y_pos: int = tile_index / tiles_x

		@warning_ignore('integer_division')
		var start_x: int = (tile_x_pos * img_width) / tiles_x
		@warning_ignore('integer_division')
		var end_x: int = ((tile_x_pos + 1) * img_width) / tiles_x
		@warning_ignore('integer_division')
		var start_y: int = (tile_y_pos * img_height) / tiles_y
		@warning_ignore('integer_division')
		var end_y: int = ((tile_y_pos + 1) * img_height) / tiles_y

		var tile_width: int = end_x - start_x
		var tile_height: int = end_y - start_y

		var src_rect: Rect2i = Rect2i(start_x, start_y, tile_width, tile_height)
		var dst_pos: Vector2i = Vector2i(start_x, start_y)

		final_image.blit_rect(tile_image, src_rect, dst_pos)
		end_timer("tile_%d_image_operations" % i)

		start_timer("tile_%d_texture_update" % i)
		var display_texture := ImageTexture.create_from_image(final_image)
		%PostDisplay.material.set_shader_parameter('tiled_render', display_texture)
		end_timer("tile_%d_texture_update" % i)

		end_timer("tile_%d" % i)
		i += 1

	await get_tree().process_frame
	is_computing_tiles_internally = false
	get_tree().current_scene.last_tiled_render_image = final_image

	%PostDisplay.material.set_shader_parameter('display_tiled_render', true)
	%PostDisplay.material.set_shader_parameter('tiled_render', ImageTexture.create_from_image(final_image))
	rendering_tiles = false
	get_tree().current_scene.busy_rendering_tiles = false

	end_timer("compute_tiled_render_total")

	if should_start_tiled_render:
		compute_tiled_render()

func _ready() -> void:
	var l: String = str(light_id)
	var ALL_FIELD_CONTAINER_FIELDS := {
		# Lighting
		7: [
			{'name': 'light'+l+'_position', 'type': 'vec3', 'from': Vector3(-20, -20, -20), 'to': Vector3(20, 20, 20), 'default_value': Vector3(10, 10, 10)},
			{'name': 'light'+l+'_enabled', 'type': 'bool', 'default_value': true if light_id == 1 else false},
			{'name': 'light'+l+'_color', 'type': 'color', 'default_value': Color('white')},
			{'name': 'light'+l+'_intensity', 'type': 'float', 'from': 0, 'to': 200, 'default_value': 100},
			{'name': 'light'+l+'_radius', 'type': 'float', 'from': 0, 'to': 2, 'default_value': 0.1},
		],
		# Lighting / Shadow
		28: [
			{'name': 'hard_shadows', 'type': 'bool', 'default_value': false},
			{'name': 'shadow_steps', 'type': 'int', 'from': 0, 'to': 400, 'default_value': 230},
			{'name': 'shadow_epsilon', 'advanced_only': true, 'type': 'float', 'from': 0, 'to': 0.4, 'default_value': 0.004},
			{'name': 'shadow_raystep_multiplier', 'advanced_only': true, 'type': 'float', 'from': 0.2, 'to': 3.0, 'default_value': 1.0},
			{'name': 'metallic', 'type': 'float', 'from': 0, 'to': 1, 'default_value': 0},
			{'name': 'roughness', 'type': 'float', 'from': 0, 'to': 1, 'default_value': 0.5},
			{'name': 'clearcoat', 'type': 'float', 'from': 0, 'to': 1, 'default_value': 0.0},
			{'name': 'clearcoat_roughness', 'advanced_only': true, 'type': 'float', 'from': 0, 'to': 1, 'default_value': 0.1},
			{'name': 'anisotropy', 'type': 'float', 'from': -1, 'to': 1, 'default_value': 0.0},
			{'name': 'anisotropic_rotation', 'advanced_only': true, 'type': 'float', 'from': 0, 'to': 6.28318, 'default_value': 0.0},
			{'name': 'sss_strength', 'type': 'float', 'from': 0, 'to': 2, 'default_value': 0.0},
			{'name': 'sss_distortion', 'advanced_only': true, 'type': 'float', 'from': 0, 'to': 1, 'default_value': 0.2},
			{'name': 'sss_color', 'type': 'color', 'default_value': Color(1.0, 0.3, 0.3)},
		],
		29: [
			{'name': 'specular_intensity', 'type': 'float', 'from': 0.0, 'to': 100.0, 'default_value': 15},
			{'name': 'specular_sharpness', 'type': 'float', 'from': 0.0, 'to': 40.0, 'default_value': 20},
		],
		# Lighting / Reflections
		6: [
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
				%TextureRect.material.set_shader_parameter('transparent_bg', value);
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
		# Animation Export
		27: [
			{'name': 'export_keyframes_only', 'type': 'bool', 'default_value': false},
			{'name': 'export_format', 'type': 'selection', 'values': ['PNG', 'JPG', 'WEBP'], 'default_value': 'PNG'}
		],
		# Effects / Vignette
		8: [
			{'name': 'vignette_radius', 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 0.9},
			{'name': 'vignette_strength', 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 1.0},
			{'name': 'is_exponential', 'advanced_only': true, 'type': 'bool', 'default_value': true}
		],
		# Effects / Fog
		9: [
			{'name': 'fog_enabled', 'type': 'bool', 'default_value': false},
			{'name': 'fog_volumetric', 'type': 'bool', 'default_value': true},
			{'name': 'fog_density', 'type': 'float', 'from': 0.0, 'to': 0.4, 'default_value': 0.01},
			{'name': 'fog_falloff', 'type': 'float', 'from': 0.0, 'to': 4.1, 'default_value': 1.64},
			{'name': 'fog_samples', 'type': 'int', 'from': 1, 'to': 32, 'default_value': 12},
			{'name': 'fog_palette', 'type': 'palette', 'default_value': {'special_field': true, 'type': 'palette', 'is_blurry': false, 'offsets': PackedFloat32Array([0.0, 1.0]), 'colors': PackedColorArray([Color(0.0, 0.0, 0.0), Color(1.0, 1.0, 1.0)])}},
			{'name': 'fog_brightness', 'type': 'float', 'from': 0.0, 'to': 10.0, 'default_value': 3.0},
			{'name': 'fog_dither_scale', 'type': 'float', 'from': 1.0, 'to': 512.0, 'default_value': 255.0},
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
			#{'name': 'taa_samples', 'type': 'int', 'from': 2, 'to': 32, 'default_value': 16, 'onchange_override': func(val: int) -> void:
				#get_tree().current_scene.taa_samples = val
				#field_changed_non_shader('taa_samples', val)
				#},
			
			# Texture filter
			{'name': 'texture_filter', 'type': 'selection', 'values': ['Linear', 'Nearest'], 'default_value': 'Linear', 'onchange_override': func(val: String) -> void:
				if val == 'Linear':
					%TextureRect.texture_filter = TEXTURE_FILTER_LINEAR
					%FrozenTextureRect.texture_filter = TEXTURE_FILTER_LINEAR
					%FractalViewport.texture_filter = TEXTURE_FILTER_LINEAR
					%VoxelViewport.texture_filter = TEXTURE_FILTER_LINEAR
				elif val == 'Nearest':
					%TextureRect.texture_filter = TEXTURE_FILTER_NEAREST
					%FrozenTextureRect.texture_filter = TEXTURE_FILTER_NEAREST
					%FractalViewport.texture_filter = TEXTURE_FILTER_NEAREST
					%VoxelViewport.texture_filter = TEXTURE_FILTER_NEAREST
				field_changed_non_shader('texture_filter', val)
				%ToolBar.set_global_setting('texture_filter', 0 if val == 'Linear' else 1)
				},
			
			# Progressive rendering strength
			{'name': 'low_scaling', 'type': 'float', 'from': 0.25, 'to': 1.0, 'default_value': 0.4, 'onchange_override': func(val: float) -> void:
				%ToolBar.set_global_setting('low_scaling', val)
				var iupscaling: float = 1.0 - %SubViewport.upscaling
				val -= iupscaling
				val = clamp(val, 0.25, 1.0)
				%SubViewport.low_scaling = val
				field_changed_non_shader('low_scaling', val)
				},
		],
		# Settings / Fractal
		12: [
			# Fractal DIFS/Primitive smoothing
			{'name': 'difs_smoothing', 'type': 'float', 'from': 0.0, 'to': 1.0, 'default_value': 0.0},
			{'name': 'exponential_smoothing', 'type': 'bool', 'default_value': false},
		],
		# Settings / Debug
		20: [
			{'name': 'display', 'type': 'selection', 'values': ['Render', 'Occlusion', 'Normals', 'Depth'], 'default_value': 'Render'},
			{'name': 'depth_scale', 'type': 'float', 'from': 0, 'to': 4, 'default_value': 0.3}
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
			{'name': 'white_point', 'type': 'float', 'from': 0.0, 'to': 5.0, 'default_value': 1.0},
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
			{'name': 'anti_aliasing', 'type': 'selection', 'values': ['None', 'FXAA', 'SMAA'], 'default_value': 'None', 'onchange_override': func(val: Variant) -> void: 
			%ToolBar._on_antialiasing_value_changed(val)
			field_changed_non_shader('anti_aliasing', val)
			},
			{'name': 'iterations', 'type': 'int', 'from': 0, 'to': 50, 'default_value': 15},
			{'name': 'max_steps', 'type': 'int', 'from': 0, 'to': 600, 'default_value': 360},
			{'name': 'escape_radius', 'advanced_only': true, 'type': 'float', 'from': 0, 'to': 500, 'default_value': 16},
			{'name': 'camera_kalaidoscope', 'advanced_only': true, 'type': 'float', 'from': 1, 'to': 20, 'default_value': 1, 'onchange_override': func(val: Variant) -> void:
			%PostDisplay.material.set_shader_parameter('camera_kalaidoscope', val)
			%Fractal.material_override.set_shader_parameter('camera_kalaidoscope', val)
			field_changed('camera_kalaidoscope', val)
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
			%SubViewport.refresh()
			},
		],
		# Tools
		14: [
			{'name': 'tiled', 'type': 'bool', 'default_value': false, 'onchange_override': func(val: bool) -> void: 
			%SubViewport.refresh()
			%Fractal.material_override.set_shader_parameter('tiled', val)
			if not val:
				%PostDisplay.material.set_shader_parameter('display_tiled_render', false)
				get_tree().current_scene.last_tiled_render_image = null
			},
			{'name': 'tiles_x', 'type': 'int', 'from': 1, 'to': 32, 'default_value': 4, 'onchange_override': func(_val: int) -> void:
			update_tile_bounds()
			},
			{'name': 'tiles_y', 'type': 'int', 'from': 1, 'to': 32, 'default_value': 4, 'onchange_override': func(_val: int) -> void:
			update_tile_bounds()
			},
			{'name': 'current_tile', 'hidden': true, 'type': 'int', 'from': 0, 'to': 40, 'default_value': 0, 'onchange_override': func(_val: int) -> void:
			update_tile_bounds()
			},
			{'name': 'compute_tiled_render', 'hidden': true, 'bool_button': true, 'type': 'bool', 'default_value': false, 'onchange_override': func(_val: bool) -> void:
				if Engine.get_frames_drawn() != 0:
					if not %Fractal.material_override.get_shader_parameter('tiled'):
						Global.error('Cant compute tiled render. Please check "Tiled" first.')
						return
					
					%Rendering.compute_tiled_render()
				},
		]
	}
	fields = ALL_FIELD_CONTAINER_FIELDS[fields_list_id]
	update_fields_ui()
	get_tree().current_scene.reload_difficulty()

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
			value_node.is_button = variable_data.get('bool_button', false)
			value_node.button_text = Global.add_spaces(variable_name.to_pascal_case())
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
		text = Global.add_spaces(text)
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
		
		if variable_data['type'] == 'bool' and variable_data.get('bool_button', false):
			label.visible = false
		
		if variable_data.get('advanced_only', false):
			get_tree().current_scene.advanced_ui_fields.append(value_node)
		
		if variable_data.has('hidden') and variable_data['hidden'] == true:
			label.visible = false
			value_node.visible = false
