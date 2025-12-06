extends HBoxContainer

signal value_changed(option: String)

@export var options: Array[String] = []
@export var index: int = 0:
	set(value):
		if value < 0: value = len(options) - 1
		if value > len(options) - 1: value = 0
		index = value
		$HBoxContainer/Label.text = options[index]
		
		#value_changed.emit(options[index])

func set_options(new_options: Variant) -> void:
	options = []
	for item in (new_options as Array[String]):
		options.append(str(item))

func _ready() -> void:
	Global.value_nodes.append(self)
	$HBoxContainer/Label.text = options[index]
	value_changed.emit(options[index])

func i_am_a_selection_field() -> void: pass

func _on_left_pressed() -> void:
	index -= 1
	if index < 0:
		index = len(options) - 1
	
	$HBoxContainer/Label.text = options[index]
	value_changed.emit(options[index])

func _on_right_pressed() -> void:
	index += 1
	
	if index > len(options) - 1:
		index = 0
	
	$HBoxContainer/Label.text = options[index]
	value_changed.emit(options[index])
