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
@onready var initial_texture := texture
var is_menu_rendered: bool = false
var velocity := Vector3.ZERO
var is_holding := false
var is_hovering := false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_holding:
		var input: Vector2 = Vector2(event.relative.x, event.relative.y)
		var adjusted_input: Vector2 = input.rotated(-camera.rotation.z)
		
		head.rotate_y(-adjusted_input.x * SENSITIVITY)
		camera.rotation.x = camera.rotation.x - adjusted_input.y * SENSITIVITY
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
		%SubViewport.refresh_taa()

func _physics_process(delta: float) -> void:
	if is_menu_rendered:
		get_parent().modulate = Color(1.0, 1.0, 1.0, 0.0)
	else:
		get_parent().modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	if get_tree().current_scene.fields.has('resolution'):
		var min_size: Vector2 = (get_tree().current_scene.fields['resolution'] * zoom) / 1.28
		custom_minimum_size = min_size
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
	zoom = max(to, 0.0)
