extends Node

const USE_PRECOMPUTED_DISTANCE_FIELD := false

# "random" - original random pattern
# "center_sphere" - sphere in the center
# "vertical_column" - vertical cylindrical column
# "horizontal_plane" - horizontal plane/slab
# "corners" - fills opposite corners
# "edges" - fills the edges/frame of the volume

const INITIAL_PATTERN := "edges"
const TEXTURE_SIZE := 50
const BOUNDS := Vector3(2.0, 2.0, 2.0)
const CELLULAR_SIZE := TEXTURE_SIZE
const PADDING := 1

var cellular_grid: Array[Array] = []
var prev_forward: bool = false

func _process(_delta: float) -> void:
	if get_tree().current_scene.fields.get('fcellular_forward', prev_forward) != prev_forward:
		prev_forward = get_tree().current_scene.fields['fcellular_forward']
		forward()

func is_in_padding_zone(x: int, y: int, z: int) -> bool:
	return x < PADDING or x >= CELLULAR_SIZE - PADDING or \
		   y < PADDING or y >= CELLULAR_SIZE - PADDING or \
		   z < PADDING or z >= CELLULAR_SIZE - PADDING

func get_initial_pattern_value(x: int, y: int, z: int) -> bool:
	var center := CELLULAR_SIZE * 0.5
	var radius := CELLULAR_SIZE * 0.3
	
	match INITIAL_PATTERN:
		"random":
			return randf() > 0.8
		"center_sphere":
			var dist := Vector3(x - center, y - center, z - center).length()
			return dist <= radius
		"vertical_column":
			var dist := Vector2(x - center, z - center).length()
			return dist <= radius
		"horizontal_plane":
			return abs(y - center) <= 3
		"corners":
			var corner_size := CELLULAR_SIZE * 0.25
			return (x < corner_size and y < corner_size and z < corner_size) or \
				   (x >= CELLULAR_SIZE - corner_size and y >= CELLULAR_SIZE - corner_size and z >= CELLULAR_SIZE - corner_size)
		"edges":
			var edge_thickness := 3
			return x < edge_thickness or x >= CELLULAR_SIZE - edge_thickness or \
				   y < edge_thickness or y >= CELLULAR_SIZE - edge_thickness or \
				   z < edge_thickness or z >= CELLULAR_SIZE - edge_thickness
		_:
			return randf() > 0.8

func generate_cellular_automata() -> void:
	cellular_grid = []
	for x in CELLULAR_SIZE:
		cellular_grid.append([])
		for y in CELLULAR_SIZE:
			cellular_grid[x].append([])
			for z in CELLULAR_SIZE:
				if is_in_padding_zone(x, y, z):
					cellular_grid[x][y].append(false)
				else:
					cellular_grid[x][y].append(get_initial_pattern_value(x, y, z))

func count_neighbors(x: int, y: int, z: int) -> int:
	var count := 0
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			for dz in range(-1, 2):
				if dx == 0 and dy == 0 and dz == 0:
					continue
				
				var nx := x + dx
				var ny := y + dy
				var nz := z + dz
				
				if nx >= 0 and nx < CELLULAR_SIZE and ny >= 0 and ny < CELLULAR_SIZE and nz >= 0 and nz < CELLULAR_SIZE:
					if cellular_grid[nx][ny][nz]:
						count += 1
	
	return count

func apply_single_iteration() -> void:
	var new_grid: Array[Array] = []
	for x in CELLULAR_SIZE:
		new_grid.append([])
		for y in CELLULAR_SIZE:
			new_grid[x].append([])
			for z in CELLULAR_SIZE:
				if is_in_padding_zone(x, y, z):
					new_grid[x][y].append(false)
				else:
					var neighbors := count_neighbors(x, y, z)
					var current: int = cellular_grid[x][y][z]
					
					if current:
						new_grid[x][y].append(neighbors >= 4 and neighbors <= 7)
					else:
						new_grid[x][y].append(neighbors >= 5)
	
	cellular_grid = new_grid

func forward() -> void:
	apply_single_iteration()
	print("cellular forward iteration applied")
	
	if USE_PRECOMPUTED_DISTANCE_FIELD:
		var distance_texture := await create_distance_field_cpu()
		var bounds_uniform := Vector3(BOUNDS.x, BOUNDS.y, BOUNDS.z)
		
		%Fractal.material_override.set_shader_parameter('voxel_data', distance_texture)
		%Fractal.material_override.set_shader_parameter('voxel_bounds', bounds_uniform)
		%Fractal.material_override.set_shader_parameter('voxel_grid_size', TEXTURE_SIZE)
		%Fractal.material_override.set_shader_parameter('use_distance_field', true)
	else:
		var cellular_texture := create_cellular_texture()
		var bounds_uniform := Vector3(BOUNDS.x, BOUNDS.y, BOUNDS.z)
		
		%Fractal.material_override.set_shader_parameter('voxel_data', cellular_texture)
		%Fractal.material_override.set_shader_parameter('voxel_bounds', bounds_uniform)
		%Fractal.material_override.set_shader_parameter('voxel_grid_size', CELLULAR_SIZE)
		%Fractal.material_override.set_shader_parameter('use_distance_field', false)

func world_to_cellular(pos: Vector3) -> Vector3i:
	var normalized := (pos + BOUNDS * 0.5) / BOUNDS
	var grid_pos := normalized * CELLULAR_SIZE
	return Vector3i(
		clamp(int(grid_pos.x), 0, CELLULAR_SIZE - 1),
		clamp(int(grid_pos.y), 0, CELLULAR_SIZE - 1),
		clamp(int(grid_pos.z), 0, CELLULAR_SIZE - 1)
	)

func distance_to_cellular(pos: Vector3) -> float:
	var grid_coord := world_to_cellular(pos)
	var min_dist := 1000.0
	var voxel_size := BOUNDS.x / CELLULAR_SIZE
	
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			for dz in range(-1, 2):
				var check_x := grid_coord.x + dx
				var check_y := grid_coord.y + dy
				var check_z := grid_coord.z + dz
				
				if check_x >= 0 and check_x < CELLULAR_SIZE and check_y >= 0 and check_y < CELLULAR_SIZE and check_z >= 0 and check_z < CELLULAR_SIZE:
					if cellular_grid[check_x][check_y][check_z]:
						var voxel_center := Vector3(
							(check_x + 0.5) / CELLULAR_SIZE * BOUNDS.x - BOUNDS.x * 0.5,
							(check_y + 0.5) / CELLULAR_SIZE * BOUNDS.y - BOUNDS.y * 0.5,
							(check_z + 0.5) / CELLULAR_SIZE * BOUNDS.z - BOUNDS.z * 0.5
						)
						var dist: float = max(
							abs(pos.x - voxel_center.x) - voxel_size * 0.5,
							max(
								abs(pos.y - voxel_center.y) - voxel_size * 0.5,
								abs(pos.z - voxel_center.z) - voxel_size * 0.5
							)
						)
						min_dist = min(min_dist, dist)
	
	return min_dist if min_dist < 1000.0 else voxel_size

func create_cellular_texture() -> ImageTexture3D:
	var images: Array[Image] = []
	
	for z in CELLULAR_SIZE:
		var layer_image := Image.create(CELLULAR_SIZE, CELLULAR_SIZE, false, Image.FORMAT_R8)
		
		for y in CELLULAR_SIZE:
			for x in CELLULAR_SIZE:
				var value := 1.0 if cellular_grid[x][y][z] else 0.0
				layer_image.set_pixel(x, y, Color(value, value, value, 1.0))
		
		images.append(layer_image)
	
	var texture := ImageTexture3D.new()
	texture.create(Image.FORMAT_R8, CELLULAR_SIZE, CELLULAR_SIZE, CELLULAR_SIZE, false, images)
	return texture

func generate_shader_for_layer() -> String:
	return """
shader_type canvas_item;
uniform vec3 bounds;
uniform float layer_z;
float cube_sdf(vec3 p, vec3 b) {
	vec3 q = abs(p) - b;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}
void fragment() {
	vec2 uv = UV;
	vec3 world_pos = vec3(
		(uv.x - 0.5) * bounds.x,
		(uv.y - 0.5) * bounds.y,
		layer_z
	);
	
	float dist = %s;
	float normalized_dist = clamp(dist / 2.0, 0.0, 1.0);
	
	COLOR = vec4(normalized_dist, 0.0, 0.0, 1.0);
}
"""

func create_distance_field_cpu() -> ImageTexture3D:
	var images: Array[Image] = []
	
	for z in TEXTURE_SIZE:
		var layer_z := (float(z) / (TEXTURE_SIZE - 1) - 0.5) * BOUNDS.z
		var layer_image := Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_R8)
		
		for y in TEXTURE_SIZE:
			for x in TEXTURE_SIZE:
				var world_x := (float(x) / (TEXTURE_SIZE - 1) - 0.5) * BOUNDS.x
				var world_y := (float(y) / (TEXTURE_SIZE - 1) - 0.5) * BOUNDS.y
				var world_pos := Vector3(world_x, world_y, layer_z)
				
				var dist := distance_to_cellular(world_pos)
				var normalized_dist: float = clamp(dist / 2.0, 0.0, 1.0)
				
				layer_image.set_pixel(x, y, Color(normalized_dist, normalized_dist, normalized_dist, 1.0))
		
		images.append(layer_image)
		print('cpu layer: ', z, '/', TEXTURE_SIZE)
	
	var texture := ImageTexture3D.new()
	texture.create(Image.FORMAT_R8, TEXTURE_SIZE, TEXTURE_SIZE, TEXTURE_SIZE, false, images)
	return texture

func create_distance_field_gpu() -> ImageTexture3D:
	var voxel_data := ""
	for x in CELLULAR_SIZE:
		for y in CELLULAR_SIZE:
			for z in CELLULAR_SIZE:
				if cellular_grid[x][y][z]:
					var voxel_center := Vector3(
						(x + 0.5) / CELLULAR_SIZE * BOUNDS.x - BOUNDS.x * 0.5,
						(y + 0.5) / CELLULAR_SIZE * BOUNDS.y - BOUNDS.y * 0.5,
						(z + 0.5) / CELLULAR_SIZE * BOUNDS.z - BOUNDS.z * 0.5
					)
					var voxel_size := BOUNDS.x / CELLULAR_SIZE
					voxel_data += "	dist = min(dist, cube_sdf(world_pos - vec3(%.6f, %.6f, %.6f), vec3(%.6f)));\n" % [
						voxel_center.x, voxel_center.y, voxel_center.z, voxel_size * 0.5
					]
	
	var distance_calculation := """
	float dist = 1000.0;
%s
	dist""" % voxel_data
	
	var shader_code := generate_shader_for_layer() % distance_calculation
	
	var shader := Shader.new()
	shader.code = shader_code
	
	var viewport := SubViewport.new()
	viewport.size = Vector2i(TEXTURE_SIZE, TEXTURE_SIZE)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	
	var texture_rect := TextureRect.new()
	texture_rect.size = Vector2(TEXTURE_SIZE, TEXTURE_SIZE)
	texture_rect.texture = ImageTexture.create_from_image(Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGB8))
	
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter('bounds', BOUNDS)
	texture_rect.material = material
	
	viewport.add_child(texture_rect)
	
	var images: Array[Image] = []
	
	for z in TEXTURE_SIZE:
		var layer_z := (float(z) / (TEXTURE_SIZE - 1) - 0.5) * BOUNDS.z
		material.set_shader_parameter('layer_z', layer_z)
		
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await get_tree().process_frame
		await get_tree().process_frame
		
		var layer_image := viewport.get_texture().get_image()
		var r8_image := Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_R8)
		
		for y in TEXTURE_SIZE:
			for x in TEXTURE_SIZE:
				var pixel := layer_image.get_pixel(x, y)
				r8_image.set_pixel(x, y, Color(pixel.r, pixel.r, pixel.r, 1.0))
		
		images.append(r8_image)
		print('gpu layer: ', z, '/', TEXTURE_SIZE)
	
	viewport.queue_free()
	
	var texture := ImageTexture3D.new()
	texture.create(Image.FORMAT_R8, TEXTURE_SIZE, TEXTURE_SIZE, TEXTURE_SIZE, false, images)
	return texture

func cellular() -> void:
	generate_cellular_automata()
	
	if USE_PRECOMPUTED_DISTANCE_FIELD:
		var distance_texture := await create_distance_field_cpu()
		var bounds_uniform := Vector3(BOUNDS.x, BOUNDS.y, BOUNDS.z)
		
		%Fractal.material_override.set_shader_parameter('voxel_data', distance_texture)
		%Fractal.material_override.set_shader_parameter('voxel_bounds', bounds_uniform)
		%Fractal.material_override.set_shader_parameter('voxel_grid_size', TEXTURE_SIZE)
		%Fractal.material_override.set_shader_parameter('use_distance_field', true)
	else:
		var cellular_texture := create_cellular_texture()
		var bounds_uniform := Vector3(BOUNDS.x, BOUNDS.y, BOUNDS.z)
		
		%Fractal.material_override.set_shader_parameter('voxel_data', cellular_texture)
		%Fractal.material_override.set_shader_parameter('voxel_bounds', bounds_uniform)
		%Fractal.material_override.set_shader_parameter('voxel_grid_size', CELLULAR_SIZE)
		%Fractal.material_override.set_shader_parameter('use_distance_field', false)

func _ready() -> void:
	cellular()
