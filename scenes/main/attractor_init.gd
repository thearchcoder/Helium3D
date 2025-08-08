extends Node

const TEXTURE_SIZE := 128 * 5
const BOUNDS := Vector3(2.0, 2.0, 2.0)
const PATH_POINTS := 4000

var aizawa_a: float = 0.95
var aizawa_b: float = 0.7
var aizawa_c: float = 0.6
var aizawa_d: float = 3.5
var aizawa_e: float = 0.25
var aizawa_f: float = 0.1

func aizawa_attractor(p: Vector3) -> Vector3:
	const dt: float = 0.01
	
	var dx: float = (p.z - aizawa_b) * p.x - aizawa_d * p.y
	var dy: float = aizawa_d * p.x + (p.z - aizawa_b) * p.y
	var dz: float = aizawa_c + aizawa_a * p.z - (p.z * p.z * p.z) / 3.0 - (p.x * p.x + p.y * p.y) * (1.0 + aizawa_e * p.z) + aizawa_f * p.z * (p.x * p.x * p.x)
	
	return p + Vector3(dx, dy, dz) * dt

func generate_aizawa_path() -> PackedVector3Array:
	var current := Vector3(0.1, 0.1, 0.1)
	var path: PackedVector3Array = []
	var prev: Vector3 = current
	
	for i in 2000:
		current = aizawa_attractor(current)
		if prev.distance_to(current) > 0.6:
			print(current)
			prev = current
		
		#if i > 1000 and i % 10 == 0:
			#path.append(current * 0.4)
			#if path.size() >= PATH_POINTS:
				#break
	#
	return path

func generate_shader_with_points(path: PackedVector3Array) -> String:
	var points_array := ""
	for i in path.size():
		var point := path[i]
		points_array += "	vec3(%.6f, %.6f, %.6f)" % [point.x, point.y, point.z]
		if i < path.size() - 1:
			points_array += ",\n"
	
	return """
shader_type canvas_item;

uniform vec3 bounds;
uniform float layer_z;

const vec3 path_points[%d] = vec3[%d](
%s
);

float distance_to_segments(vec3 pos) {
	float min_dist = 1000.0;
	
	for (int i = 0; i < %d - 1; i++) {
		vec3 a = path_points[i];
		vec3 b = path_points[i + 1];
		
		vec3 ab = b - a;
		vec3 ap = pos - a;
		float ab_len_sq = dot(ab, ab);
		
		if (ab_len_sq == 0.0) {
			min_dist = min(min_dist, length(ap));
			continue;
		}
		
		float t = clamp(dot(ap, ab) / ab_len_sq, 0.0, 1.0);
		vec3 projection = a + t * ab;
		min_dist = min(min_dist, distance(pos, projection));
	}
	
	return min_dist;
}

void fragment() {
	vec2 uv = UV;
	vec3 world_pos = vec3(
		(uv.x - 0.5) * bounds.x,
		(uv.y - 0.5) * bounds.y,
		layer_z
	);
	
	float dist = distance_to_segments(world_pos);
	float normalized_dist = clamp(dist / 2.0, 0.0, 1.0);
	
	COLOR = vec4(normalized_dist, 0.0, 0.0, 1.0);
}
""" % [path.size(), path.size(), points_array, path.size()]

func create_distance_field_gpu() -> ImageTexture3D:
	var path := generate_aizawa_path()
	var shader_code := generate_shader_with_points(path)
	
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

func aizawa() -> void:
	var distance_texture := await create_distance_field_gpu()
	var bounds_uniform := Vector3(BOUNDS.x, BOUNDS.y, BOUNDS.z)
	
	%Fractal.material_override.set_shader_parameter('florenz_field', distance_texture)
	%Fractal.material_override.set_shader_parameter('florenz_field_bounds', bounds_uniform)

#func _ready() -> void:
	#aizawa()
