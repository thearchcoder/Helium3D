extends Control

@export var image: Texture
var data: Dictionary
var is_mouse_hovering: bool = false
var is_holding: bool = false
var drag_offset: Vector2

func _ready() -> void:
	if image:
		$TextureRect.texture = image

func _process(delta: float) -> void:
	if is_mouse_hovering and Input.is_action_just_pressed("mouse right click"):
		get_parent().get_parent().get_parent().get_parent().remove_keyframe(data)
	elif is_mouse_hovering and Input.is_action_just_pressed("mouse click"):
		is_holding = true
		drag_offset = get_global_mouse_position() - global_position
	elif Input.is_action_just_released("mouse click"):
		is_holding = false

	#if is_holding:
		#position.x = get_global_mouse_position().x - drag_offset.x

func _on_mouse_entered() -> void: is_mouse_hovering = true
func _on_mouse_exited() -> void: is_mouse_hovering = false
