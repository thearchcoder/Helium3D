extends HBoxContainer

signal value_changed(to: int)

@warning_ignore("shadowed_global_identifier")
@export var range: Vector2i = Vector2i(-20, 20)

@export var value: int = 0:
	set(v):
		value = v
		$HSlider.value = v
		var old_text_column: int = $LineEdit.caret_column
		$LineEdit.text = str(v)
		$LineEdit.caret_column = old_text_column

func _ready() -> void:
	Global.value_nodes.append(self)
	$HSlider.min_value = range.x
	$HSlider.max_value = range.y
	$HSlider.set_value_no_signal(value)
	
	# Call for initial value.
	value_changed.emit(value)

func _on_h_slider_value_changed(v: int) -> void:
	$LineEdit.text = str(v)
	value_changed.emit(v)
	value = v

func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		$HSlider.set_value_no_signal(int(new_text))
		value_changed.emit(int(new_text))
		value = int(new_text)
	else:
		var fixed_int: String = ""
		for c in new_text:
			if c >= '0' and c <= '9':
				fixed_int += c
		
		var old_caret_column: int = $LineEdit.caret_column
		if fixed_int != "":
			$LineEdit.text = fixed_int
			$HSlider.set_value_no_signal(int(fixed_int))
			value_changed.emit(int(fixed_int))
			value = int(fixed_int)
		else:
			$LineEdit.text = "0"
			$HSlider.set_value_no_signal(0)
			value_changed.emit(0)
			value = 0
		
		$LineEdit.caret_column = old_caret_column - 1
