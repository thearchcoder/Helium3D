extends HBoxContainer

signal value_changed(to: Vector3)

@export var range_min: Vector3 = Vector3(-20, -20, -20)
@export var range_max: Vector3 = Vector3(20, 20, 20)
@export var value: Vector3 = Vector3.ZERO:
	set(v):
		value = v
		value_changed.emit(v)
		%X.value = value.x
		%Y.value = value.y
		%Z.value = value.z

func _ready() -> void:
	Global.value_nodes.append(self)
	%X.range = Vector2(range_min.x, range_max.x)
	%Y.range = Vector2(range_min.y, range_max.y)
	%Z.range = Vector2(range_min.z, range_max.z)
	%X.value = value.x
	%Y.value = value.y
	%Z.value = value.z
	value_changed.emit(value)

func i_am_a_vec3_field() -> void: pass

func _on_x_value_changed(to: float) -> void: value.x = to
func _on_y_value_changed(to: float) -> void: value.y = to
func _on_z_value_changed(to: float) -> void: value.z = to
