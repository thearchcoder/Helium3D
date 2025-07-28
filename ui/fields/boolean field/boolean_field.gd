extends HBoxContainer

signal value_changed(to: bool)

func _ready() -> void:
	Global.value_nodes.append(self)
	value_changed.emit(value)

@export var value: bool = false:
	set(v):
		value = v
		$CheckBox.button_pressed = v
		Global.action_occurred()

func _on_check_box_toggled(toggled_on: bool) -> void:
	value = toggled_on
	value_changed.emit(toggled_on)
	Global.action_occurred()
