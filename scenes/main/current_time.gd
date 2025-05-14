extends HBoxContainer

var is_mouse_hovering: bool = false
var dragging: bool = false
var previous_mouse_position: Vector2
var previous_currently_at_frame: float = -1

func update_drag() -> void:
	if dragging and previous_mouse_position.distance_to(get_global_mouse_position()) >= 0.001:
		var new_position_x: float = max(get_global_mouse_position().x - 13, 0)
		new_position_x = min(new_position_x, (133 + 5) * len(%AnimationTrack.keyframes) - 6)
		%Time.position.x = new_position_x
		
		if previous_currently_at_frame != int(%Time.position.x / 4.5):
			%AnimationTrack.currently_at_frame = int(%Time.position.x / 4.5)
	
	previous_mouse_position = get_global_mouse_position()
	previous_currently_at_frame = %AnimationTrack.currently_at_frame

func _process(_delta: float) -> void:
	update_drag()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and is_mouse_hovering:
				dragging = true
			elif not event.pressed:
				dragging = false

func _on_mouse_entered() -> void: is_mouse_hovering = true
func _on_mouse_exited() -> void: is_mouse_hovering = false
