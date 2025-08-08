extends HBoxContainer

var is_mouse_hovering: bool = false
var dragging: bool = false
var previous_mouse_position: Vector2

func update_drag() -> void:
	if dragging:
		var new_position_x: float = max(get_global_mouse_position().x + 60, 0)
		new_position_x = min(new_position_x, 138 * len(%AnimationTrack.keyframes) - 6)
		new_position_x = (new_position_x * %AnimationTrack.fps / 133.0) - %AnimationTrack.fps
		# Automatically updates %Time.position in the setter as well.
		%AnimationTrack.currently_at_frame = max(new_position_x, 0)
	
	previous_mouse_position = get_global_mouse_position()

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
