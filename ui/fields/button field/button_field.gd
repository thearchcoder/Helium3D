extends HBoxContainer

var text: String = 'Button': 
	set(value):
		text = value
		$Button.text = value

signal pressed()

func _on_button_pressed() -> void:
	pressed.emit()
