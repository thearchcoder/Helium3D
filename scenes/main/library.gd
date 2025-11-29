extends VBoxContainer

const CAPTURE_SCENE = preload('res://ui/capture/capture.tscn')

func _on_set_scroll_start_button_pressed() -> void:
	$ScrollContainer.scroll_horizontal = 0

func _on_add_capture_button_pressed() -> void:
	var capture: Node = CAPTURE_SCENE.instantiate()
	capture.data = get_tree().current_scene.get_app_state()
	capture.texture = ImageTexture.create_from_image(%TextureRect.texture.get_image())
	$ScrollContainer/HBoxContainer.add_child(capture)

func _on_set_scroll_end_button_pressed() -> void:
	$ScrollContainer.scroll_horizontal = $ScrollContainer.get_h_scroll_bar().max_value
