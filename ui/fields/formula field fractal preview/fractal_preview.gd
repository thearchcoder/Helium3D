extends MarginContainer

@export var formula_id: int = 0
@export var formula_name: String = ""
@export var formula_description: String = ""
var is_mouse_hovering: bool = false

func _ready() -> void:
	$HBoxContainer/Label.text = formula_name
	$HBoxContainer/Label.text = formula_description

func _process(delta: float) -> void:
	if is_mouse_hovering and Input.is_action_just_pressed('mouse click'):
		$"../../../..".index = formula_id

func _on_mouse_entered() -> void: is_mouse_hovering = true
func _on_mouse_exited() -> void: is_mouse_hovering = false
