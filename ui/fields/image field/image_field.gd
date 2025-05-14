extends HBoxContainer

signal value_changed(value: Texture)

var selected_image_name: String

var value: Texture:
	set(val):
		value = val
		if value:
			$ImageButton.icon = value
			$ImageButton.text = selected_image_name
		else:
			$ImageButton.icon = null
			$ImageButton.text = 'Open an Image'
		
		value_changed.emit(value)

func _on_image_button_pressed() -> void:
	%FileDialog.show()

func _on_file_dialog_confirmed() -> void:
	if ResourceLoader.exists(%FileDialog.current_path):
		var result: Resource = load(%FileDialog.current_path)
		if result is Texture:
			selected_image_name = %FileDialog.current_file
			value = result
			value_changed.emit(value)

func _on_discard_image_pressed() -> void:
	value = null
