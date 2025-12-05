extends MarginContainer

var mouse_in_area: bool = false
@export var data: Dictionary = {}
@export var texture: Texture:
	set(value):
		texture = value
		$TextureRect.texture = texture

func _ready() -> void:
	$Panel.size.x = $TextureRect.size.x

func _process(_delta: float) -> void:
	if mouse_in_area and Input.is_action_just_pressed('mouse click'):
		$PopupMenu.grab_focus()
		@warning_ignore("integer_division")
		$PopupMenu.position = DisplayServer.mouse_get_position() + Vector2i(0, -31 / 2)
		$PopupMenu.visible = true

func _on_popup_menu_focus_exited() -> void:
	$PopupMenu.visible = false

func _on_mouse_entered() -> void: mouse_in_area = true
func _on_mouse_exited() -> void: mouse_in_area = false

func _on_popup_menu_id_pressed(id: int) -> void:
	if id == 0:
		get_tree().current_scene.update_app_state(data, false)
	if id == 1:
		texture = ImageTexture.create_from_image(get_tree().current_scene.get_node('UI/HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/TextureRect').texture.get_image())
		data = get_tree().current_scene.get_app_state()
	if id == 2:
		queue_free()
