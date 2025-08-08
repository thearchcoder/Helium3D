extends Node

# Catmull-rom is recommended.
enum InterpolationModes { LINEAR, BEZIER, CATMULLROM }

func interpolate(values: Array[Variant], interpolation_mode: InterpolationModes, fps: int) -> Array[Variant]:
	var result: Array[Variant] = []
	var steps: int = fps
	var first_value: Variant = values[0]
	var catmull_rom_tension: float = 1.0

	if first_value is Vector2:
		match interpolation_mode:
			InterpolationModes.LINEAR:
				result = linear_vector2_chain(values)
			InterpolationModes.BEZIER:
				result = bezier_vector2_chain(values, steps)
			InterpolationModes.CATMULLROM:
				result = catmull_rom_vector2_chain(values, catmull_rom_tension, steps)
	elif first_value is Vector3:
		match interpolation_mode:
			InterpolationModes.LINEAR:
				result = linear_vector3_chain(values)
			InterpolationModes.BEZIER:
				result = bezier_vector3_chain(values, steps)
			InterpolationModes.CATMULLROM:
				result = catmull_rom_vector3_chain(values, catmull_rom_tension, steps)
	elif first_value is Vector4:
		match interpolation_mode:
			InterpolationModes.LINEAR:
				result = linear_vector4_chain(values)
			InterpolationModes.BEZIER:
				result = bezier_vector4_chain(values, steps)
			InterpolationModes.CATMULLROM:
				result = catmull_rom_vector4_chain(values, catmull_rom_tension, steps)
	elif first_value is float:
		match interpolation_mode:
			InterpolationModes.LINEAR:
				result = linear_float_chain(values)
			InterpolationModes.BEZIER:
				result = bezier_float_chain(values, steps)
			InterpolationModes.CATMULLROM:
				result = catmull_rom_float_chain(values, catmull_rom_tension, steps)
	elif first_value is int:
		match interpolation_mode:
			InterpolationModes.LINEAR: 
				result = linear_int_chain(values)
			InterpolationModes.BEZIER: 
				result = bezier_int_chain(values, steps)
			InterpolationModes.CATMULLROM:
				result = catmull_rom_int_chain(values, catmull_rom_tension, steps)
	elif first_value is bool:
		result = linear_bool_chain(values)
	
	return result

##########################
## LINEAR INTERPOLATION ##
##########################
func linear_vector2_chain(target_points: Array) -> Array[Vector2]:
	var result: Array[Vector2] = []
	
	for i in len(target_points) - 1:
		result.append_array(linear_vec2(target_points[i], target_points[i + 1], 60))
	
	return result
func linear_vector3_chain(target_points: Array) -> Array[Vector3]:
	var result: Array[Vector3] = []
	
	for i in len(target_points) - 1:
		result.append_array(linear_vec3(target_points[i], target_points[i + 1], 60))
	
	return result
func linear_vector4_chain(target_points: Array) -> Array[Vector4]:
	var result: Array[Vector4] = []
	
	for i in len(target_points) - 1:
		result.append_array(linear_vec4(target_points[i], target_points[i + 1], 60))
	
	return result
func linear_float_chain(target_floats: Array) -> Array[float]:
	var result: Array[float] = []
	
	for i in len(target_floats) - 1:
		result.append_array(linear_float(target_floats[i], target_floats[i + 1], 60))
	
	return result
func linear_int_chain(target_ints: Array) -> Array[int]:
	var result: Array[int] = []
	
	for i in len(target_ints) - 1:
		result.append_array(linear_int(target_ints[i], target_ints[i + 1], 60))
	
	return result
func linear_bool_chain(target_bools: Array) -> Array[bool]:
	var result: Array[bool] = []
	
	for i in len(target_bools) - 1:
		result.append_array(linear_bool(target_bools[i], target_bools[i + 1], 60))
	
	return result

func linear_vec2(from: Vector2, to: Vector2, steps: int) -> Array:
	var result := []
	var x_values := linear_float(from.x, to.x, steps)
	var y_values := linear_float(from.y, to.y, steps)
	
	for i in range(steps):
		result.append(Vector2(x_values[i], y_values[i]))
	
	return result
func linear_vec3(from: Vector3, to: Vector3, steps: int) -> Array:
	var result := []
	var x_values := linear_float(from.x, to.x, steps)
	var y_values := linear_float(from.y, to.y, steps)
	var z_values := linear_float(from.z, to.z, steps)
	
	for i in range(steps):
		result.append(Vector3(x_values[i], y_values[i], z_values[i]))
	
	return result
func linear_vec4(from: Vector4, to: Vector4, steps: int) -> Array:
	var result := []
	var x_values := linear_float(from.x, to.x, steps)
	var y_values := linear_float(from.y, to.y, steps)
	var z_values := linear_float(from.z, to.z, steps)
	var w_values := linear_float(from.w, to.w, steps)
	
	for i in range(steps):
		result.append(Vector4(x_values[i], y_values[i], z_values[i], w_values[i]))
	
	return result
func linear_int(from: int, to: int, steps: int) -> Array[int]:
	var result: Array[int] = []
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		var value := int(round(from + t * (to - from)))
		result.append(value)
	return result
func linear_float(from: float, to: float, steps: int) -> Array:
	var result := []
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		var value := from + t * (to - from)
		result.append(value)
	return result
func linear_bool(from: bool, to: bool, steps: int) -> Array[bool]:
	var result: Array[bool] = []
	
	if from == to:
		for i in range(steps):
			result.append(from)
	else:
		var transition_point := int(steps / 2.0)
		
		for i in range(steps):
			if i < transition_point:
				result.append(from)
			else:
				result.append(to)
	
	return result

##########################
## BEZIER INTERPOLATION ##
##########################
func bezier_vec2(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, steps: int) -> Array[Vector2]:
	var result: Array[Vector2] = []
	
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		result.append(cubic_bezier_vec2(p0, p1, p2, p3, t))
	
	return result
func bezier_vec3(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, steps: int) -> Array[Vector3]:
	var result: Array[Vector3] = []
	
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		result.append(cubic_bezier_vec3(p0, p1, p2, p3, t))
	
	return result
func bezier_vec4(p0: Vector4, p1: Vector4, p2: Vector4, p3: Vector4, steps: int) -> Array[Vector4]:
	var result: Array[Vector4] = []
	
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		result.append(cubic_bezier_vec4(p0, p1, p2, p3, t))
	
	return result
func bezier_float(v0: float, v1: float, v2: float, v3: float, steps: int) -> Array[float]:
	var result: Array[float] = []
	
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		result.append(cubic_bezier_float(v0, v1, v2, v3, t))
	
	return result
func bezier_int(v0: int, v1: int, v2: int, v3: int, steps: int) -> Array[int]:
	var result: Array[int] = []
	
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		result.append(int(round(cubic_bezier_float(float(v0), float(v1), float(v2), float(v3), t))))
	
	return result

func bezier_vector2_chain(target_points: Array, steps_per_segment: int = 60) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var control_points := generate_control_points_vec2(target_points)
	
	for i in range(target_points.size() - 1):
		var p0: Vector2 = target_points[i]
		var p3: Vector2 = target_points[i + 1]
		var p1: Vector2 = control_points[i * 2]
		var p2: Vector2 = control_points[i * 2 + 1]
		
		result.append_array(bezier_vec2(p0, p1, p2, p3, steps_per_segment))
	
	return result
func bezier_vector3_chain(target_points: Array, steps_per_segment: int = 60) -> Array[Vector3]:
	var result: Array[Vector3] = []
	var control_points := generate_control_points_vec3(target_points)
	
	for i in range(target_points.size() - 1):
		var p0: Vector3 = target_points[i]
		var p3: Vector3 = target_points[i + 1]
		var p1: Vector3 = control_points[i * 2]
		var p2: Vector3 = control_points[i * 2 + 1]
		
		result.append_array(bezier_vec3(p0, p1, p2, p3, steps_per_segment))
	
	return result
func bezier_vector4_chain(target_points: Array, steps_per_segment: int = 60) -> Array[Vector4]:
	var result: Array[Vector4] = []
	var control_points := generate_control_points_vec4(target_points)
	
	for i in range(target_points.size() - 1):
		var p0: Vector4 = target_points[i]
		var p3: Vector4 = target_points[i + 1]
		var p1: Vector4 = control_points[i * 2]
		var p2: Vector4 = control_points[i * 2 + 1]
		
		result.append_array(bezier_vec4(p0, p1, p2, p3, steps_per_segment))
	
	return result
func bezier_float_chain(target_floats: Array, steps_per_segment: int = 60) -> Array[float]:
	var result: Array[float] = []
	var control_points := generate_control_points_float(target_floats)
	
	for i in range(target_floats.size() - 1):
		var v0: float = target_floats[i]
		var v3: float = target_floats[i + 1]
		var v1: float = control_points[i * 2]
		var v2: float = control_points[i * 2 + 1]
		
		result.append_array(bezier_float(v0, v1, v2, v3, steps_per_segment))
	
	return result
func bezier_int_chain(target_ints: Array, steps_per_segment: int = 60) -> Array[int]:
	var result: Array[int] = []
	var control_points := generate_control_points_int(target_ints)
	
	for i in range(target_ints.size() - 1):
		var v0: int = target_ints[i]
		var v3: int = target_ints[i + 1]
		var v1: int = control_points[i * 2]
		var v2: int = control_points[i * 2 + 1]
		
		result.append_array(bezier_int(v0, v1, v2, v3, steps_per_segment))
	
	return result

func cubic_bezier_vec2(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 := t * t
	var t3 := t2 * t
	var mt := 1.0 - t
	var mt2 := mt * mt
	var mt3 := mt2 * mt
	
	return mt3 * p0 + 3.0 * mt2 * t * p1 + 3.0 * mt * t2 * p2 + t3 * p3
func cubic_bezier_vec3(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float) -> Vector3:
	var t2 := t * t
	var t3 := t2 * t
	var mt := 1.0 - t
	var mt2 := mt * mt
	var mt3 := mt2 * mt
	
	return mt3 * p0 + 3.0 * mt2 * t * p1 + 3.0 * mt * t2 * p2 + t3 * p3
func cubic_bezier_vec4(p0: Vector4, p1: Vector4, p2: Vector4, p3: Vector4, t: float) -> Vector4:
	var t2 := t * t
	var t3 := t2 * t
	var mt := 1.0 - t
	var mt2 := mt * mt
	var mt3 := mt2 * mt
	
	return mt3 * p0 + 3.0 * mt2 * t * p1 + 3.0 * mt * t2 * p2 + t3 * p3
func cubic_bezier_float(v0: float, v1: float, v2: float, v3: float, t: float) -> float:
	var t2 := t * t
	var t3 := t2 * t
	var mt := 1.0 - t
	var mt2 := mt * mt
	var mt3 := mt2 * mt
	
	return mt3 * v0 + 3.0 * mt2 * t * v1 + 3.0 * mt * t2 * v2 + t3 * v3

func generate_control_points_vec2(path_points: Array) -> Array[Vector2]:
	var n := path_points.size()
	var control_points: Array[Vector2] = []
	
	if n < 2:
		return control_points
	
	if n == 2:
		var p0: Vector2 = path_points[0]
		var p1: Vector2 = path_points[1]
		var dist := p0.distance_to(p1) / 3.0
		var dir := (p1 - p0).normalized()
		control_points.append(p0 + dir * dist)
		control_points.append(p1 - dir * dist)
		return control_points
	
	for i in range(n - 1):
		var current: Vector2 = path_points[i]
		var next: Vector2 = path_points[i + 1]
		var distance := current.distance_to(next) / 3.0
		var prev_tangent: Vector2
		var next_tangent: Vector2
		
		if i == 0:
			prev_tangent = (next - current).normalized()
		else:
			prev_tangent = (next - path_points[i-1]).normalized()
		
		if i == n - 2:
			next_tangent = (next - current).normalized()
		else:
			next_tangent = (path_points[i+2] - current).normalized()
		
		control_points.append(current + prev_tangent * distance)
		control_points.append(next - next_tangent * distance)
	
	return control_points
func generate_control_points_vec3(path_points: Array) -> Array[Vector3]:
	var n := path_points.size()
	var control_points: Array[Vector3] = []
	
	if n < 2:
		return control_points
	
	if n == 2:
		var p0: Vector3 = path_points[0]
		var p1: Vector3 = path_points[1]
		var dist := p0.distance_to(p1) / 3.0
		var dir := (p1 - p0).normalized()
		control_points.append(p0 + dir * dist)
		control_points.append(p1 - dir * dist)
		return control_points
	
	for i in range(n - 1):
		var current: Vector3 = path_points[i]
		var next: Vector3 = path_points[i + 1]
		var distance := current.distance_to(next) / 3.0
		var prev_tangent: Vector3
		var next_tangent: Vector3
		
		if i == 0:
			prev_tangent = (next - current).normalized()
		else:
			prev_tangent = (next - path_points[i-1]).normalized()
		
		if i == n - 2:
			next_tangent = (next - current).normalized()
		else:
			next_tangent = (path_points[i+2] - current).normalized()
		
		control_points.append(current + prev_tangent * distance)
		control_points.append(next - next_tangent * distance)
	
	return control_points
func generate_control_points_vec4(path_points: Array) -> Array[Vector4]:
	var n := path_points.size()
	var control_points: Array[Vector4] = []
	
	if n < 2:
		return control_points
	
	if n == 2:
		var p0: Vector4 = path_points[0]
		var p1: Vector4 = path_points[1]
		var dist := p0.distance_to(p1) / 3.0
		var dir := (p1 - p0).normalized()
		control_points.append(p0 + dir * dist)
		control_points.append(p1 - dir * dist)
		return control_points
	
	for i in range(n - 1):
		var current: Vector4 = path_points[i]
		var next: Vector4 = path_points[i + 1]
		var distance := current.distance_to(next) / 3.0
		var prev_tangent: Vector4
		var next_tangent: Vector4
		
		if i == 0:
			prev_tangent = (next - current).normalized()
		else:
			prev_tangent = (next - path_points[i-1]).normalized()
		
		if i == n - 2:
			next_tangent = (next - current).normalized()
		else:
			next_tangent = (path_points[i+2] - current).normalized()
		
		control_points.append(current + prev_tangent * distance)
		control_points.append(next - next_tangent * distance)
	
	return control_points
func generate_control_points_float(values: Array) -> Array[float]:
	var n := values.size()
	var control_points: Array[float] = []
	
	if n < 2:
		return control_points
	
	if n == 2:
		var v0: float = values[0]
		var v1: float = values[1]
		var diff := v1 - v0
		control_points.append(v0 + diff / 3.0)
		control_points.append(v1 - diff / 3.0)
		return control_points
	
	var tangents: Array[float] = []
	for i in range(n):
		tangents.append(0.0)
	
	for i in range(n):
		if i == 0:
			tangents[i] = (values[i+1] - values[i]) / 2.0
		elif i == n - 1:
			tangents[i] = (values[i] - values[i-1]) / 2.0
		else:
			tangents[i] = (values[i+1] - values[i-1]) / 2.0
	
	for i in range(n - 1):
		var current: float = values[i]
		var next: float = values[i + 1]
		var segment_length: float = abs(next - current)
		var scale := segment_length / 3.0
		control_points.append(current + tangents[i] * scale)
		control_points.append(next - tangents[i+1] * scale)
	
	return control_points
func generate_control_points_int(values: Array) -> Array[int]:
	var n := values.size()
	var control_points: Array[int] = []
	
	if n < 2:
		return control_points
	
	if n == 2:
		var v0: float = float(values[0])
		var v1: float = float(values[1])
		var diff := v1 - v0
		control_points.append(int(round(v0 + diff / 3.0)))
		control_points.append(int(round(v1 - diff / 3.0)))
		return control_points
	
	var tangents: Array[float] = []
	for i in range(n):
		tangents.append(0.0)
	
	for i in range(n):
		if i == 0:
			tangents[i] = float(values[i+1] - values[i]) / 2.0
		elif i == n - 1:
			tangents[i] = float(values[i] - values[i-1]) / 2.0
		else:
			tangents[i] = float(values[i+1] - values[i-1]) / 2.0
	
	for i in range(n - 1):
		var current: float = float(values[i])
		var next: float = float(values[i + 1])
		var segment_length: float = abs(next - current)
		var scale := segment_length / 3.0
		control_points.append(int(round(current + tangents[i] * scale)))
		control_points.append(int(round(next - tangents[i+1] * scale)))
	
	return control_points

###############################
## CATMULL-ROM INTERPOLATION ##
###############################
func hermite_vec2(p0: Vector2, p1: Vector2, m0: Vector2, m1: Vector2, steps: int) -> Array[Vector2]:
	var result: Array[Vector2] = []
	
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		result.append(cubic_hermite_vec2(p0, p1, m0, m1, t))
	
	return result
func hermite_vec3(p0: Vector3, p1: Vector3, m0: Vector3, m1: Vector3, steps: int) -> Array[Vector3]:
	var result: Array[Vector3] = []
	
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		result.append(cubic_hermite_vec3(p0, p1, m0, m1, t))
	
	return result
func hermite_vec4(p0: Vector4, p1: Vector4, m0: Vector4, m1: Vector4, steps: int) -> Array[Vector4]:
	var result: Array[Vector4] = []
	
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		result.append(cubic_hermite_vec4(p0, p1, m0, m1, t))
	
	return result
func hermite_float(v0: float, v1: float, m0: float, m1: float, steps: int) -> Array[float]:
	var result: Array[float] = []
	
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		result.append(cubic_hermite_float(v0, v1, m0, m1, t))
	
	return result
func hermite_int(v0: int, v1: int, m0: int, m1: int, steps: int) -> Array[int]:
	var result: Array[int] = []
	
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 1.0
		result.append(int(round(cubic_hermite_float(float(v0), float(v1), float(m0), float(m1), t))))
	
	return result

func cubic_hermite_vec2(p0: Vector2, p1: Vector2, m0: Vector2, m1: Vector2, t: float) -> Vector2:
	var t2 := t * t
	var t3 := t2 * t
	
	var h00 := 2.0 * t3 - 3.0 * t2 + 1.0
	var h10 := t3 - 2.0 * t2 + t
	var h01 := -2.0 * t3 + 3.0 * t2
	var h11 := t3 - t2
	
	return h00 * p0 + h10 * m0 + h01 * p1 + h11 * m1
func cubic_hermite_vec3(p0: Vector3, p1: Vector3, m0: Vector3, m1: Vector3, t: float) -> Vector3:
	var t2 := t * t
	var t3 := t2 * t
	
	var h00 := 2.0 * t3 - 3.0 * t2 + 1.0
	var h10 := t3 - 2.0 * t2 + t
	var h01 := -2.0 * t3 + 3.0 * t2
	var h11 := t3 - t2
	
	return h00 * p0 + h10 * m0 + h01 * p1 + h11 * m1
func cubic_hermite_vec4(p0: Vector4, p1: Vector4, m0: Vector4, m1: Vector4, t: float) -> Vector4:
	var t2 := t * t
	var t3 := t2 * t
	
	var h00 := 2.0 * t3 - 3.0 * t2 + 1.0
	var h10 := t3 - 2.0 * t2 + t
	var h01 := -2.0 * t3 + 3.0 * t2
	var h11 := t3 - t2
	
	return h00 * p0 + h10 * m0 + h01 * p1 + h11 * m1
func cubic_hermite_float(v0: float, v1: float, m0: float, m1: float, t: float) -> float:
	var t2 := t * t
	var t3 := t2 * t
	
	var h00 := 2.0 * t3 - 3.0 * t2 + 1.0
	var h10 := t3 - 2.0 * t2 + t
	var h01 := -2.0 * t3 + 3.0 * t2
	var h11 := t3 - t2
	
	return h00 * v0 + h10 * m0 + h01 * v1 + h11 * m1

func hermite_vector2_chain(target_points: Array, tangents: Array[Vector2], steps_per_segment: int = 60) -> Array[Vector2]:
	var result: Array[Vector2] = []
	
	# Check if we have enough points and tangents
	if target_points.size() < 2 or tangents.size() < target_points.size():
		push_error("Not enough points or tangents for hermite_vector2_chain")
		return result
	
	for i in range(target_points.size() - 1):
		var p0: Vector2 = target_points[i]
		var p1: Vector2 = target_points[i + 1]
		var m0 := tangents[i]
		var m1 := tangents[i + 1]
		
		result.append_array(hermite_vec2(p0, p1, m0, m1, steps_per_segment))
	
	return result
func hermite_vector3_chain(target_points: Array, tangents: Array[Vector3], steps_per_segment: int = 60) -> Array[Vector3]:
	var result: Array[Vector3] = []
	
	# Check if we have enough points and tangents
	if target_points.size() < 2 or tangents.size() < target_points.size():
		push_error("Not enough points or tangents for hermite_vector3_chain")
		return result
	
	for i in range(target_points.size() - 1):
		var p0: Vector3 = target_points[i]
		var p1: Vector3 = target_points[i + 1]
		var m0 := tangents[i]
		var m1 := tangents[i + 1]
		
		result.append_array(hermite_vec3(p0, p1, m0, m1, steps_per_segment))
	
	return result
func hermite_vector4_chain(target_points: Array, tangents: Array[Vector4], steps_per_segment: int = 60) -> Array[Vector4]:
	var result: Array[Vector4] = []
	
	# Check if we have enough points and tangents
	if target_points.size() < 2 or tangents.size() < target_points.size():
		push_error("Not enough points or tangents for hermite_vector4_chain")
		return result
	
	for i in range(target_points.size() - 1):
		var p0: Vector4 = target_points[i]
		var p1: Vector4 = target_points[i + 1]
		var m0 := tangents[i]
		var m1 := tangents[i + 1]
		
		result.append_array(hermite_vec4(p0, p1, m0, m1, steps_per_segment))
	
	return result
func hermite_float_chain(target_floats: Array, tangents: Array[float], steps_per_segment: int = 60) -> Array[float]:
	var result: Array[float] = []
	
	# Check if we have enough points and tangents
	if target_floats.size() < 2 or tangents.size() < target_floats.size():
		push_error("Not enough points or tangents for hermite_float_chain")
		return result
	
	for i in range(target_floats.size() - 1):
		var v0: float = target_floats[i]
		var v1: float = target_floats[i + 1]
		var m0 := tangents[i]
		var m1 := tangents[i + 1]
		
		result.append_array(hermite_float(v0, v1, m0, m1, steps_per_segment))
	
	return result
func hermite_int_chain(target_ints: Array, tangents: Array[int], steps_per_segment: int = 60) -> Array[int]:
	var result: Array[int] = []
	
	# Check if we have enough points and tangents
	if target_ints.size() < 2 or tangents.size() < target_ints.size():
		push_error("Not enough points or tangents for hermite_int_chain")
		return result
	
	for i in range(target_ints.size() - 1):
		var v0: float = target_ints[i]
		var v1: float = target_ints[i + 1]
		var m0 := tangents[i]
		var m1 := tangents[i + 1]
		
		result.append_array(hermite_int(int(v0), int(v1), m0, m1, steps_per_segment))
	
	return result

# Catmull-rom is just a more convenient version of cubic hermite splines where the tangents are calculated automatically.
func generate_catmull_rom_tangents_vec2(points: Array, tension: float = 0.5) -> Array[Vector2]:
	var tangents: Array[Vector2] = []
	var n := points.size()
	
	if n < 2:
		return tangents
	
	for i in range(n):
		var tangent: Vector2
		
		if i == 0:
			# Start point - use forward difference
			tangent = tension * (points[1] - points[0])
		elif i == n - 1:
			# End point - use backward difference
			tangent = tension * (points[n-1] - points[n-2])
		else:
			# Middle points - use central difference
			tangent = tension * (points[i+1] - points[i-1]) * 0.5
		
		tangents.append(tangent)
	
	return tangents
func generate_catmull_rom_tangents_vec3(points: Array, tension: float = 0.5) -> Array[Vector3]:
	var tangents: Array[Vector3] = []
	var n := points.size()
	
	if n < 2:
		return tangents
	
	for i in range(n):
		var tangent: Vector3
		
		if i == 0:
			# Start point - use forward difference
			tangent = tension * (points[1] - points[0])
		elif i == n - 1:
			# End point - use backward difference
			tangent = tension * (points[n-1] - points[n-2])
		else:
			# Middle points - use central difference
			tangent = tension * (points[i+1] - points[i-1]) * 0.5
		
		tangents.append(tangent)
	
	return tangents
func generate_catmull_rom_tangents_vec4(points: Array, tension: float = 0.5) -> Array[Vector4]:
	var tangents: Array[Vector4] = []
	var n := points.size()
	
	if n < 2:
		return tangents
	
	for i in range(n):
		var tangent: Vector4
		
		if i == 0:
			# Start point - use forward difference
			tangent = tension * (points[1] - points[0])
		elif i == n - 1:
			# End point - use backward difference
			tangent = tension * (points[n-1] - points[n-2])
		else:
			# Middle points - use central difference
			tangent = tension * (points[i+1] - points[i-1]) * 0.5
		
		tangents.append(tangent)
	
	return tangents
func generate_catmull_rom_tangents_float(values: Array, tension: float = 0.5) -> Array[float]:
	var tangents: Array[float] = []
	var n := values.size()
	
	if n < 2:
		return tangents
	
	for i in range(n):
		var tangent: float
		
		if i == 0:
			# Start point - use forward difference
			tangent = tension * (values[1] - values[0])
		elif i == n - 1:
			# End point - use backward difference
			tangent = tension * (values[n-1] - values[n-2])
		else:
			# Middle points - use central difference
			tangent = tension * (values[i+1] - values[i-1]) * 0.5
		
		tangents.append(tangent)
	
	return tangents
func generate_catmull_rom_tangents_int(values: Array, tension: float = 0.5) -> Array[int]:
	var tangents: Array[int] = []
	var n := values.size()
	
	if n < 2:
		return tangents
	
	for i in range(n):
		var tangent: float
		
		if i == 0:
			# Start point - use forward difference
			tangent = tension * (values[1] - values[0])
		elif i == n - 1:
			# End point - use backward difference
			tangent = tension * (values[n-1] - values[n-2])
		else:
			# Middle points - use central difference
			tangent = tension * (values[i+1] - values[i-1]) * 0.5
		
		tangents.append(int(round(tangent)))
	
	return tangents

func catmull_rom_vector2_chain(target_points: Array, tension: float = 0.5, steps_per_segment: int = 60) -> Array[Vector2]:
	var tangents := generate_catmull_rom_tangents_vec2(target_points, tension)
	return hermite_vector2_chain(target_points, tangents, steps_per_segment)
func catmull_rom_vector3_chain(target_points: Array, tension: float = 0.5, steps_per_segment: int = 60) -> Array[Vector3]:
	var tangents := generate_catmull_rom_tangents_vec3(target_points, tension)
	return hermite_vector3_chain(target_points, tangents, steps_per_segment)
func catmull_rom_vector4_chain(target_points: Array, tension: float = 0.5, steps_per_segment: int = 60) -> Array[Vector4]:
	var tangents := generate_catmull_rom_tangents_vec4(target_points, tension)
	return hermite_vector4_chain(target_points, tangents, steps_per_segment)
func catmull_rom_float_chain(target_floats: Array, tension: float = 0.5, steps_per_segment: int = 60) -> Array[float]:
	var tangents := generate_catmull_rom_tangents_float(target_floats, tension)
	return hermite_float_chain(target_floats, tangents, steps_per_segment)
func catmull_rom_int_chain(target_ints: Array, tension: float = 0.5, steps_per_segment: int = 60) -> Array[int]:
	var tangents := generate_catmull_rom_tangents_int(target_ints, tension)
	return hermite_int_chain(target_ints, tangents, steps_per_segment)
