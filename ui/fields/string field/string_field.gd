extends HBoxContainer

signal value_changed(to: String)

@export var placeholder := '...':
	set(v):
		placeholder = v
		$LineEdit.placeholder_text = v

@export var value := '':
	set(v):
		value = v
		var old_text_column: int = $LineEdit.caret_column
		$LineEdit.text = v
		$LineEdit.caret_column = old_text_column

func _ready() -> void:
	Global.value_nodes.append(self)
	$LineEdit.text = value
	value_changed.emit(value)

func _on_line_edit_text_changed(new_text: String) -> void:
	value = new_text
	value_changed.emit(new_text)

func _on_line_edit_text_submitted(_new_text: String) -> void:
	Global.action_occurred()
