extends HBoxContainer

signal value_changed(value: Dictionary)

var selected_image_name: String

var value: Dictionary = {'special_field': true, 'type': 'image', 'path': '!null'}:
	set(val):
		value = val
		selected_image_name = value['path'].get_file()
		
		if value['path'] != '!null' && value:
			var result: Resource = load(value['path'])
			$ImageButton.icon = result
			$ImageButton.text = selected_image_name
		else:
			$ImageButton.icon = null
			$ImageButton.text = 'Open an Image'
		
		value_changed.emit(value)

func _ready() -> void:
	Global.value_nodes.append(self)
	value_changed.emit(value)

func _on_image_button_pressed() -> void:
	%FileDialog.show()

func _on_file_dialog_confirmed() -> void:
	if ResourceLoader.exists(%FileDialog.current_path):
		var result: Resource = load(%FileDialog.current_path)
		if result is Texture:
			selected_image_name = %FileDialog.current_file
			value = {'special_field': true, 'type': 'image', 'path': %FileDialog.current_path}
			value_changed.emit(value)

func _on_discard_image_pressed() -> void:
	value = {'special_field': true, 'type': 'image', 'path': '!null'}
