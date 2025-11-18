extends TextureRect

func _unhandled_input(event: InputEvent) -> void:
	if $"../../..".type != 1:
		return
	
	if Input.is_action_pressed('mouse right click'):
		$"../../../../../../../../../UI/HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/TextureRect"._unhandled_input(event)

func _process(_delta: float) -> void:
	if $"../../..".type != 1:
		return
	
	if Input.is_action_just_pressed('mouse right click') and $"../../..".mouse_in_area and not $"../../../../../../../../../SubViewport/Fractal".material_override.get_shader_parameter('building_mesh'):
		$"../../../../../../../../../UI/HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/TextureRect".is_holding = true
	elif Input.is_action_just_released('mouse right click'):
		$"../../../../../../../../../UI/HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/TextureRect".is_holding = false
		$"../../../../../../../../../DummyFocusButton".grab_focus()
