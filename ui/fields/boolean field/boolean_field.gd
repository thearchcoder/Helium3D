extends HBoxContainer

signal value_changed(to: bool)

func _ready() -> void:
	Global.value_nodes.append(self)
	value_changed.emit(value)

var is_button: bool = false:
	set(value):
		is_button = value
		if is_button:
			$Button.visible = true
			$CheckBox.visible = false
		else:
			$Button.visible = false
			$CheckBox.visible = true

@export var value: bool = false:
	set(v):
		value = v
		$CheckBox.button_pressed = v
		Global.action_occurred()

func _on_check_box_toggled(toggled_on: bool) -> void:
	value = toggled_on
	value_changed.emit(toggled_on)
	Global.action_occurred()

func _on_button_pressed() -> void:
	_on_check_box_toggled(not value)
