extends HBoxContainer

signal value_changed(to: Vector2)

@export var step: float = 0.0000001
@export var range_min: Vector2 = Vector2(-20, -20)
@export var range_max: Vector2 = Vector2(20, 20)
@export var value: Vector2 = Vector2.ZERO:
	set(v):
		value = v
		value_changed.emit(v)
		%X.value = value.x
		%Y.value = value.y

func _ready() -> void:
	Global.value_nodes.append(self)
	%X.range = Vector2(range_min.x, range_max.x)
	%Y.range = Vector2(range_min.y, range_max.y)
	%X.value = value.x
	%Y.value = value.y
	%X.step = step
	%Y.step = step
	value_changed.emit(value)

func i_am_a_vec2_field() -> void: pass

func _on_x_value_changed(to: float) -> void: value.x = to
func _on_y_value_changed(to: float) -> void: value.y = to
