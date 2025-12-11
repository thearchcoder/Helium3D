extends VBoxContainer

var is_mouse_inside: bool = false
var is_dragging: bool = false
var drag_start_x: float = 0.0
var original_position_x: float = 0.0
var prevent_opening_colorpicker: bool = false

@export var offset: float = 1.0

@export var color: Color = Color('#ef001e'):
	set(value):
		color = value
		$Circle.self_modulate = color
		$Circle/ColorPickerButton.color = color

func _ready() -> void:
	$Circle.self_modulate = color
	$Circle/ColorPickerButton.color = color
	_on_color_picker_button_color_changed(color)

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

func _process(_delta: float) -> void:
	if not is_instance_valid(self):
		return
	
	if Engine.get_frames_drawn() == 0:
		reload_position()
	
	if Engine.get_frames_drawn() <= 3:
		return
	
	var length: float = $"../..".size.x - 19  # 20 = margin from margin container
	
	if is_mouse_inside and (Input.is_action_just_pressed("delete") or Input.is_action_just_pressed("mouse right click")):
		$"../../..".call_deferred('changed_gradient')
		# https://github.com/godotengine/godot/issues/73036
		call('free')
		return
	
	if is_mouse_inside and Input.is_action_just_pressed("mouse click") and not $Circle/ColorPickerButton.get_popup().visible:
		is_dragging = true
		drag_start_x = get_global_mouse_position().x
		original_position_x = position.x
		
	if Input.is_action_just_released("mouse click") and is_dragging:
		is_dragging = false
		if int(get_global_mouse_position().x) - int(drag_start_x) != 0:
			$Circle/ColorPickerButton.get_popup().visible = false
	
	if is_dragging and int(get_global_mouse_position().x) - int(drag_start_x) != 0:
		var mouse_delta := get_global_mouse_position().x - drag_start_x
		var previous_x := position.x
		position.x = clamp(original_position_x + mouse_delta, -5, length)
		offset = position.x / length
		if abs(previous_x - position.x) > 0.001:
			$"../../..".changed_gradient()

func _on_circle_mouse_entered() -> void:
	is_mouse_inside = true
	create_tween().tween_property($Circle, "self_modulate", Color(color, 0.8), 0.1)

func _on_circle_mouse_exited() -> void:
	is_mouse_inside = false
	create_tween().tween_property($Circle, "self_modulate", Color(color, 1.0), 0.1)

func _on_color_picker_button_color_changed(new_color: Color) -> void:
	color = new_color
	$"../../..".changed_gradient()
