extends TextureRect

var is_hovering := false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed('mouse right click') and MissingNode:
		%TextureRect._unhandled_input(event)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('mouse right click') and is_hovering and not %Fractal.material_override.get_shader_parameter('building_mesh'):
		%TextureRect.is_holding = true
	elif Input.is_action_just_released('mouse right click'):
		%TextureRect.is_holding = false
		%DummyFocusButton.grab_focus()

func _on_mouse_entered() -> void: is_hovering = true
func _on_mouse_exited() -> void: is_hovering = false
