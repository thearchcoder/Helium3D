extends TextureRect

var is_hovering := false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed('mouse right click') and MissingNode:
		%TextureRect._unhandled_input(event)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('mouse right click') and is_hovering:
		%TextureRect.is_holding = true
		%DummyFocusButton.grab_focus()
	elif Input.is_action_just_released('mouse right click'):
		%TextureRect.is_holding = false

func _on_mouse_entered() -> void: is_hovering = true
func _on_mouse_exited() -> void: is_hovering = false
