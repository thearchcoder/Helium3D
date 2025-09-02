extends TextureRect

var is_hovering: bool = false
var is_dragging: bool = false
var drag_start_position: Vector2
var initial_mouse_position: Vector2

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('mouse click') and is_hovering:
		is_dragging = true
		drag_start_position = global_position
		initial_mouse_position = get_global_mouse_position()
	
	if Input.is_action_just_released('mouse click'):
		is_dragging = false
	
	if is_dragging:
		var mouse_delta: Vector2 = get_global_mouse_position() - initial_mouse_position
		var rotation_speed: float = 0.007
		
		var camera_origin: Node3D = get_node("%CameraOrigin")
		if camera_origin:
			camera_origin.rotation.y += mouse_delta.x * rotation_speed
			camera_origin.rotation.x += mouse_delta.y * rotation_speed
			camera_origin.rotation.x = clamp(camera_origin.rotation.x, -PI/2, PI/2)
		
		initial_mouse_position = get_global_mouse_position()
		%VoxelizedMeshWorld.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	if is_hovering:
		var camera_origin: Node3D = get_node("%CameraOrigin")
		if camera_origin:
			var zoom_speed: float = 0.1
			var min_scale: float = 0.1
			var max_scale: float = 5.0
			
			if Input.is_action_just_pressed("mouse wheel down"):
				camera_origin.scale += Vector3.ONE * zoom_speed
				camera_origin.scale = camera_origin.scale.clamp(Vector3.ONE * min_scale, Vector3.ONE * max_scale)
				%VoxelizedMeshWorld.render_target_update_mode = SubViewport.UPDATE_ONCE
			
			if Input.is_action_just_pressed("mouse wheel up"):
				camera_origin.scale -= Vector3.ONE * zoom_speed
				camera_origin.scale = camera_origin.scale.clamp(Vector3.ONE * min_scale, Vector3.ONE * max_scale)
				%VoxelizedMeshWorld.render_target_update_mode = SubViewport.UPDATE_ONCE

func _on_mouse_entered() -> void: is_hovering = true
func _on_mouse_exited() -> void: is_hovering = false
