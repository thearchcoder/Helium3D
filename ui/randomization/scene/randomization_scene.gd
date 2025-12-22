extends MarginContainer

@export var text: String = "Scene":
	set(value):
		text = value
		$VBoxContainer/Label.text = '\n' + text + '\n'

@export_enum('Main', 'Randomized') var type: int = 0
var mouse_in_area: bool = false
var state: Dictionary = {}

var texture: Texture:
	set(value):
		texture = value
		$VBoxContainer/MarginContainer/TextureRect.texture = texture

func _ready() -> void:
	if type == 1:
		$PopupMenu.remove_item(0)
		$PopupMenu.add_item('Use this')
		size.y = 80
	else:
		size.y = 40

func _process(_delta: float) -> void:
	if mouse_in_area and Input.is_action_just_pressed('mouse click'):
		$PopupMenu.grab_focus()
		@warning_ignore("integer_division")
		$PopupMenu.position = DisplayServer.mouse_get_position() + Vector2i(0, -31 / 2)
		$PopupMenu.visible = true
	
	$VBoxContainer/MarginContainer/TextureRect.texture_filter = get_tree().current_scene.get_node('%TextureRect').texture_filter

func _on_popup_menu_focus_exited() -> void:
	$PopupMenu.visible = false

func _on_mouse_entered() -> void: mouse_in_area = true
func _on_mouse_exited() -> void: mouse_in_area = false

func _on_popup_menu_id_pressed(id: int) -> void:
	if type == 0:
		%Randomization.update_base_scene()
	elif type == 1 and id == 0:
		%Randomization.use_state()
