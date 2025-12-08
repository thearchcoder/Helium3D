extends HBoxContainer

signal value_changed(option: String)

@export var options: Array[String] = []
@export var label_overrides: Array[String] = []
@export var index: int = 0:
	set(value):
		if value < 0: value = len(options) - 1
		if value > len(options) - 1: value = 0
		index = value
		$HBoxContainer/Label.text = Global.dupe_to_num(label_overrides[index])
		value_changed.emit(options[index])
		Global.action_occurred()

func _process(_delta: float) -> void:
	if $"../../../../../..".name == 'Formula' and $"../../../..".visible and Input.is_action_pressed('search formula shortcut'):
		$HBoxContainer/Label.pressed.emit()
	
	if $"../../../../..".name == 'Buffer' and index != 0:
		index = 0

func _ready() -> void:
	Global.value_nodes.append(self)
	$HBoxContainer/Label.text = Global.dupe_to_num(label_overrides[index])
	value_changed.emit(options[index])
	
	#for option in options:
		#const FRACTAL_PREVIEW_SCENE = preload('res://ui/fields/formula field fractal preview/fractal_preview.tscn')
		#var preview: Node = FRACTAL_PREVIEW_SCENE.instantiate()
		#preview.formula_name = option
		#preview.formula_id = options.find(option)

func i_am_a_selection_field() -> void: pass

func _on_left_pressed() -> void:
	index -= get_tree().current_scene.MAX_ACTIVE_FORMULAS + 1
	if index < 0:
		index = len(options) - 1
	
	$HBoxContainer/Label.text = Global.dupe_to_num(label_overrides[index])
	value_changed.emit(options[index])

func _on_right_pressed() -> void:
	index += get_tree().current_scene.MAX_ACTIVE_FORMULAS + 1
	
	if index > len(options) - 1:
		index = 0
	
	$HBoxContainer/Label.text = Global.dupe_to_num(label_overrides[index])
	value_changed.emit(options[index])

func _on_label_pressed() -> void: $Popup.visible = true
