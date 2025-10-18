extends VBoxContainer

var is_mouse_hovering: bool = false

func _process(delta: float) -> void:
	if is_mouse_hovering and Input.is_action_just_released('texture zoom in') and not $TextureRect.is_holding:
		%TextureRect.zoom += 0.1
	if is_mouse_hovering and Input.is_action_just_released('texture zoom out') and not $TextureRect.is_holding:
		%TextureRect.zoom -= 0.1

func _on_mouse_entered() -> void: is_mouse_hovering = true
func _on_mouse_exited() -> void: is_mouse_hovering = false
