extends TextureRect

var speed := 100.0
var zoom := 1.0:
	set(value):
		zoom = value
		%Zoom.value = value
const FRICTION := 0.0
const JUMP_POWER := 6.0
const SENSITIVITY := 0.004
const BOB_FREQUENCY := 2.0
const BOB_AMPLITUDE := 0.08

@onready var head := %Player.get_node('Head')
@onready var camera := %Player.get_node('Head').get_node('Camera')
var velocity := Vector3.ZERO
var is_holding := false
var is_hovering := false

func write_ply_mesh(filename: String, mesh: Mesh) -> void:
	var vertices: PackedVector3Array = mesh.surface_get_array(0, Mesh.ARRAY_VERTEX)
	var indices: PackedInt32Array = mesh.surface_get_array(0, Mesh.ARRAY_INDEX)
	var colors: PackedColorArray = mesh.surface_get_array(0, Mesh.ARRAY_COLOR)
	
	var has_colors: bool = colors != null and colors.size() > 0
	
	var faces: Array[PackedInt32Array] = []
	for i in range(0, indices.size(), 3):
		var face: PackedInt32Array = PackedInt32Array([indices[i], indices[i+1], indices[i+2]])
		faces.append(face)
	
	var file: FileAccess = FileAccess.open(filename, FileAccess.WRITE)
	if file == null:
		print("Failed to open file: ", filename)
		return
	
	file.store_line("ply")
	file.store_line("format ascii 1.0")
	file.store_line("element vertex " + str(vertices.size()))
	file.store_line("property float x")
	file.store_line("property float y")
	file.store_line("property float z")
	if has_colors:
		file.store_line("property uchar red")
		file.store_line("property uchar green")
		file.store_line("property uchar blue")
		file.store_line("property uchar alpha")
	file.store_line("element face " + str(faces.size()))
	file.store_line("property list uchar int vertex_indices")
	file.store_line("end_header")
	
	for i: int in range(vertices.size()):
		var v: Vector3 = vertices[i]
		var line: String = str(v.x) + " " + str(v.y) + " " + str(v.z)
		if has_colors:
			var c: Color = colors[i]
			line += " " + str(int(c.r * 255)) + " " + str(int(c.g * 255)) + " " + str(int(c.b * 255)) + " " + str(int(c.a * 255))
		file.store_line(line)
	
	for face: PackedInt32Array in faces:
		var face_str: String = str(face.size())
		for i: int in face:
			face_str += " " + str(i)
		file.store_line(face_str)
	
	file.close()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_holding:
		var input: Vector2 = Vector2(event.relative.x, event.relative.y)
		var adjusted_input: Vector2 = input.rotated(-camera.rotation.z)
		
		head.rotate_y(-adjusted_input.x * SENSITIVITY)
		camera.rotation.x = camera.rotation.x - adjusted_input.y * SENSITIVITY
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
		%SubViewport.refresh_no_taa()

func _physics_process(delta: float) -> void:
	if get_tree().current_scene.fields.has('resolution'):
		var min_size: Vector2 = (get_tree().current_scene.fields['resolution'] * zoom) / 1.28
		custom_minimum_size = min_size.min(%TextureRect.get_parent().size)
		%PostViewport.size = get_tree().current_scene.fields['resolution']
	
	if Input.is_action_just_pressed('mouse right click') and is_hovering:
		is_holding = true
		%DummyFocusButton.grab_focus()
	elif Input.is_action_just_released('mouse right click'):
		is_holding = false
	
	if is_holding:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if is_holding and Input.is_action_pressed('rotate left'):
		camera.rotation_degrees.z += 20 * delta
		%SubViewport.since_last_dynamic_update = 0.0
	if is_holding and Input.is_action_pressed('rotate right'):
		camera.rotation_degrees.z -= 20 * delta
		%SubViewport.since_last_dynamic_update = 0.0
	
	if is_holding and Input.is_action_just_released('mouse wheel up'):
		speed = clamp(speed * 1.2, 0.0, 10000.0)
	if is_holding and Input.is_action_just_released('mouse wheel down'):
		speed = clamp(speed / 1.2, 0.0, 10000.0)
	
	if is_holding and Input.is_action_pressed('r'):
		speed = clamp(speed * 1.03, 0.0, 10000.0)
	if is_holding and Input.is_action_pressed('f'):
		speed = clamp(speed / 1.03, 0.0, 10000.0)
	
	var speed_multipler := 1.0
	if Input.is_action_pressed('control'):
		speed_multipler = 4.0
	elif Input.is_action_pressed('alt'):
		speed_multipler = 0.25
	
	if is_holding:
		var direction := Input.get_vector("a", "d", "s", "w")
		var target_speed: float = speed * speed_multipler
		
		if direction:
			%SubViewport.refresh_taa()
		
		var forward: Vector3 = -camera.global_transform.basis.z.normalized()
		var right: Vector3 = camera.global_transform.basis.x.normalized()
		var up: Vector3 = camera.global_transform.basis.y.normalized()
		var movement_direction := (right * direction.x + forward * direction.y).normalized()
		
		velocity += movement_direction * target_speed * delta
		
		if Input.is_action_pressed('up'):
			velocity += up * speed * delta
			%SubViewport.refresh_taa()
		elif Input.is_action_pressed('down'):
			velocity -= up * speed * delta
			%SubViewport.refresh_taa()
	
	%Player.global_transform.origin += velocity * delta
	velocity *= FRICTION

func _on_mouse_entered() -> void: is_hovering = true
func _on_mouse_exited() -> void: is_hovering = false

func _on_zoom_value_changed(to:  float) -> void:
	zoom = to
