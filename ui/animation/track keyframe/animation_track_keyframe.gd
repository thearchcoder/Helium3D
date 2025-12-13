extends Control

@export var image: Texture
var data: Dictionary
var is_mouse_hovering: bool = false
var is_holding: bool = false
var drag_offset: Vector2
var original_index: int = -1
var original_position: Vector2
var last_target_index: int = -1
var is_selected: bool = false

func _ready() -> void:
	if image:
		$TextureRect.texture = image
	
	update_panel()

func get_animation_track() -> Node:
	return get_parent().get_parent().get_parent().get_parent()

func get_current_index() -> int:
	var siblings: Array[Node] = get_parent().get_children()
	for i: int in range(siblings.size()):
		if siblings[i] == self:
			return i
	return -1

func get_target_index_from_position() -> int:
	var siblings: Array[Node] = get_parent().get_children()
	var keyframe_spacing: float = size.x
	var target_slot: int = int((position.x + size.x * 0.5) / keyframe_spacing)
	return clamp(target_slot, 0, siblings.size() - 1)

func update_sibling_positions(target_index: int, instant: bool = false) -> void:
	var siblings: Array[Node] = get_parent().get_children()
	var keyframe_spacing: float = size.x

	for i: int in range(siblings.size()):
		var sibling: Node = siblings[i]
		if sibling == self:
			continue

		var target_pos: int = i

		if original_index < target_index:
			if i > original_index and i <= target_index:
				target_pos = i - 1
		else:
			if i >= target_index and i < original_index:
				target_pos = i + 1

		var target_x: float = target_pos * keyframe_spacing

		if instant:
			sibling.position.x = target_x
		else:
			var tween: Tween = create_tween()
			tween.tween_property(sibling, "position:x", target_x, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func select() -> void:
	var siblings: Array[Node] = get_parent().get_children()
	for sibling in siblings:
		if sibling.has_method("deselect"):
			sibling.deselect()
	is_selected = true
	update_panel()

func deselect() -> void:
	is_selected = false
	update_panel()

func _physics_process(_delta: float) -> void:
	if is_mouse_hovering and Input.is_action_just_pressed("mouse right click"):
		get_animation_track().remove_keyframe(data)

	if is_mouse_hovering and Input.is_action_just_pressed("mouse click"):
		select()
		is_holding = true
		drag_offset = get_global_mouse_position() - global_position
		original_index = get_current_index()
		original_position = position
		last_target_index = original_index
		z_index = 9

	if not is_mouse_hovering and Input.is_action_just_pressed("mouse click"):
		deselect()

	if Input.is_action_just_released("mouse click") and is_holding:
		is_holding = false

		var target_index: int = get_target_index_from_position()
		var keyframe_spacing: float = size.x
		var final_position: Vector2 = Vector2.ZERO

		if target_index != original_index:
			final_position.x = target_index * keyframe_spacing

			var tween: Tween = create_tween()
			tween.finished.connect(func() -> void:
				z_index = 0
				get_animation_track().reorder_keyframe(original_index, target_index, true)
			)
			tween.tween_property(self, "position", final_position, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			var tween: Tween = create_tween()
			tween.tween_property(self, "position", original_position, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			update_sibling_positions(original_index, false)

	update_panel()

	if is_holding:
		position.x = get_global_mouse_position().x - drag_offset.x - 14.0

		var target_index: int = get_target_index_from_position()
		if target_index != last_target_index:
			update_sibling_positions(target_index, false)
			last_target_index = target_index

func update_panel() -> void:
	if self and get_parent():
		$TextureRect/Panel.global_position = $TextureRect.global_position
		$TextureRect/Panel.size = Vector2(get_parent().size.y, get_parent().size.y)
		$TextureRect/Panel.visible = is_selected

func _on_mouse_entered() -> void: is_mouse_hovering = true
func _on_mouse_exited() -> void: is_mouse_hovering = false
