extends VBoxContainer

const CAPTURE_SCENE = preload('res://ui/capture/capture.tscn')

func get_library_data() -> Array:
	var library_captures: Array = []
	for capture in $ScrollContainer/HBoxContainer.get_children():
		library_captures.append({
			'data': capture.data,
			'texture_data': capture.texture.get_image().save_png_to_buffer() if capture.texture else null
		})
	return library_captures

func load_library_data(library: Array) -> void:
	for child in $ScrollContainer/HBoxContainer.get_children():
		child.queue_free()
	
	for capture_data in (library as Array[Dictionary]):
		var capture: Node = CAPTURE_SCENE.instantiate()
		capture.data = capture_data['data']
		if capture_data['texture_data']:
			var img := Image.new()
			img.load_png_from_buffer(capture_data['texture_data'])
			capture.texture = ImageTexture.create_from_image(img)
		$ScrollContainer/HBoxContainer.add_child(capture)

func _on_set_scroll_start_button_pressed() -> void:
	$ScrollContainer.scroll_horizontal = 0

func _on_add_capture_button_pressed() -> void:
	var capture: Node = CAPTURE_SCENE.instantiate()
	capture.data = get_tree().current_scene.get_app_state()
	capture.texture = ImageTexture.create_from_image(%TextureRect.texture.get_image())
	$ScrollContainer/HBoxContainer.add_child(capture)

func _on_set_scroll_end_button_pressed() -> void:
	$ScrollContainer.scroll_horizontal = $ScrollContainer.get_h_scroll_bar().max_value
