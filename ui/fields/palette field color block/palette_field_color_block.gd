extends VBoxContainer

var is_mouse_inside: bool = false
var is_dragging: bool = false
var drag_start_x: float = 0.0
var original_position_x: float = 0.0
var is_selected: bool = false
var click_time: float = 0.0
var double_click_threshold: float = 0.3
var focused: bool = false

@export var offset: float = 1.0

@export var color: Color = Color('#ef001e'):
	set(value):
		color = value
		$Circle.self_modulate = color
		$Circle/PopupPanel/ColorPicker.color = value

func _ready() -> void:
	$Circle.self_modulate = color
	$Circle/PopupPanel/ColorPicker.color = color
	_on_color_picker_color_changed(color)

func reload_position() -> void:
	var length: float = $"../..".size.x - 19
	position.x = clamp(offset * length, -5, length)
	$"../../..".changed_gradient()

func set_block_offset(new_offset: float) -> void:
	var length: float = $"../..".size.x - 19
	position.x = clamp(new_offset * length, -5, length)
	position.y = ($"../..".size.y - 12) / 2
	$"../../..".changed_gradient()

func free_object(obj: Object) -> void:
	obj.free()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(self):
		return
	
	if Engine.get_frames_drawn() == 0:
		reload_position()
	
	if Engine.get_frames_drawn() <= 3:
		return
	
	var length: float = $"../..".size.x - 19
	
	if Input.is_action_just_pressed("delete"):
		for block in $"../".get_children():
			if block.is_selected and block.get_node('VisibleOnScreen').is_on_screen():
				$"../../..".call_deferred('changed_gradient')
				block.call('free')
		return

	if is_mouse_inside and Input.is_action_just_pressed("mouse right click"):
		$"../../..".call_deferred('changed_gradient')
		call('free')
		return
	
	if is_mouse_inside and Input.is_action_just_pressed("mouse click"):
		var current_time: float = Time.get_ticks_msec() / 1000.0
		var time_since_last_click: float = current_time - click_time

		if time_since_last_click < double_click_threshold and click_time > 0.0:
			var popup: PopupPanel = $Circle/PopupPanel
			var circle_pos: Vector2 = $Circle.get_screen_position()
			var circle_size: Vector2 = $Circle.size
			popup.reset_size()
			var popup_size: Vector2 = popup.get_contents_minimum_size()
			var h_offset: float = (circle_size.x - popup_size.x) / 2
			popup.position = circle_pos + Vector2(h_offset, circle_size.y)
			popup.visible = true
			click_time = 0.0
		else:
			for block in $"../".get_children():
				block.set_selected(false)

			set_selected(!is_selected)
			click_time = current_time

			is_dragging = true
			focused = true
			drag_start_x = get_global_mouse_position().x
			original_position_x = position.x
	elif Input.is_action_just_pressed("mouse click"):
		focused = false

	if Input.is_action_just_released("mouse click") and is_dragging:
		is_dragging = false
		if int(get_global_mouse_position().x) - int(drag_start_x) != 0:
			$Circle/PopupPanel.visible = false
	
	if is_dragging and int(get_global_mouse_position().x) - int(drag_start_x) != 0:
		var mouse_delta: float = get_global_mouse_position().x - drag_start_x
		var previous_x: float = position.x
		position.x = clamp(original_position_x + mouse_delta, -5, length)
		offset = position.x / length
		if abs(previous_x - position.x) > 0.001:
			$"../../..".changed_gradient()

func _on_color_rect_outline_mouse_entered() -> void:
	is_mouse_inside = true
	create_tween().tween_property($Circle, "self_modulate", Color(color, 0.8), 0.1)

func _on_color_rect_outline_mouse_exited() -> void:
	is_mouse_inside = false
	create_tween().tween_property($Circle, "self_modulate", Color(color, 1.0), 0.1)

func _on_color_picker_color_changed(new_color: Color) -> void:
	color = new_color
	$"../../..".changed_gradient()

func set_selected(selected: bool) -> void:
	is_selected = selected
	if is_selected:
		var outline_style: StyleBoxFlat = $Circle/ColorRectOutline.get_theme_stylebox("panel").duplicate()
		outline_style.bg_color = Color(0.622, 0.622, 0.622, 1.0)
		$Circle/ColorRectOutline.add_theme_stylebox_override("panel", outline_style)
	else:
		var outline_style: StyleBoxFlat = $Circle/ColorRectOutline.get_theme_stylebox("panel").duplicate()
		outline_style.bg_color = Color(0.45452428, 0.45452422, 0.4545244, 1)
		$Circle/ColorRectOutline.add_theme_stylebox_override("panel", outline_style)

func _on_picker_closer_pressed() -> void:
	$Circle/PopupPanel.visible = false

func _on_popup_panel_visibility_changed() -> void:
	$Circle/PickerCloser.visible = $Circle/PopupPanel.visible

func _on_focus_exited() -> void:
	set_selected(false)
