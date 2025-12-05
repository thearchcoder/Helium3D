extends HBoxContainer

signal value_changed(to: float)

@export var integer := false
@export var step := 0.0000001
@export var force_precision := false
@export var precision := 3
@warning_ignore("shadowed_global_identifier")
@export var range: Vector2 = Vector2(-20, 20):
	set(value):
		range = value
		$HSlider.min_value = range.x
		$HSlider.max_value = range.y

@export var value: float = 0.0:
	set(v):
		if integer:
			v = round(v)
		
		if v > -0.00001 and v < 0.00001:
			v = 0.0
		
		if force_precision:
			var factor: float = float('1' + '0'.repeat(precision))
			v = round(v * factor) / factor
		
		value = v
		$HSlider.set_value_no_signal(v)
		var old_text_column: int = $LineEdit.caret_column
		$LineEdit.text = format_float(v)
		$LineEdit.caret_column = old_text_column
		Global.action_occurred()

func format_float(float_value: float) -> String:
	var result: String = ("%0." + str(precision) + "f") % float_value
	
	if integer:
		result = result.split('.')[0]
	
	return result

func _ready() -> void:
	Global.value_nodes.append(self)
	$HSlider.step = step
	$HSlider.min_value = range.x
	$HSlider.max_value = range.y
	$HSlider.set_value_no_signal(value)
	$LineEdit.text = format_float(value)
	
	value_changed.emit(value)
	await get_tree().process_frame
	$LineEdit.text = format_float(value)

func _on_h_slider_value_changed(v: float) -> void:
	if integer:
		v = round(v)
	
	if force_precision:
		var factor: float = float('1' + '0'.repeat(precision))
		v = round(v * factor) / factor
	
	$LineEdit.text = format_float(v)
	
	value_changed.emit(v)
	value = v

func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_float():
		$HSlider.set_value_no_signal(float(new_text))
		value_changed.emit(float(new_text))
		value = float(new_text)
	else:
		var fixed_float: String = ""
		for c in new_text:
			if (c >= '0' and c <= '9') or c == '.':
				fixed_float += c
		
		var old_caret_column: int = $LineEdit.caret_column
		if fixed_float != "":
			$LineEdit.text = fixed_float
			$HSlider.set_value_no_signal(float(fixed_float))
			value_changed.emit(float(fixed_float))
			value = float(fixed_float)
		else:
			$LineEdit.text = "0"
			$HSlider.set_value_no_signal(0)
			value_changed.emit(0)
			value = 0
		
		$LineEdit.caret_column = old_caret_column - 1

func _on_h_slider_drag_ended(value_modified: bool) -> void:
	if value_modified:
		Global.action_occurred()
