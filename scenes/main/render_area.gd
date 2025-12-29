extends HBoxContainer

var is_hovering: bool = false

func _physics_process(_delta: float) -> void:
	$MarginContainer/VBoxContainer/HBoxContainer/EstTimePopup.position = $"../..".get_screen_position() + (get_local_mouse_position() * 1.4)
	
	if is_hovering and not $MarginContainer/VBoxContainer/HBoxContainer/EstTimePopup.visible:
		$MarginContainer/VBoxContainer/HBoxContainer/EstTimePopup.popup()
	elif not is_hovering and $MarginContainer/VBoxContainer/HBoxContainer/EstTimePopup.visible:
		$MarginContainer/VBoxContainer/HBoxContainer/EstTimePopup.hide()

func _on_margin_container_mouse_entered() -> void: is_hovering = true
func _on_margin_container_mouse_exited() -> void: is_hovering = false
