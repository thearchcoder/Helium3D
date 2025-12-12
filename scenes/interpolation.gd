extends Node

enum InterpolationModes { LINEAR, BEZIER, CATMULLROM }

var cache: Dictionary = {}
var cache_size: int = 0
const MAX_CACHE_SIZE: int = 200 * 1024 * 1024

func estimate_result_size(result: Array) -> int:
	if result.is_empty():
		return 0
	var first_value: Variant = result[0]
	var base_size: int = 16
	if first_value is Vector2:
		base_size = 8
	elif first_value is Vector3:
		base_size = 12
	elif first_value is Vector4:
		base_size = 16
	elif first_value is float:
		base_size = 8
	elif first_value is int:
		base_size = 8
	elif first_value is bool:
		base_size = 1
	return result.size() * base_size + 32

func serialize_value(value: Variant) -> String:
	if value is Vector2:
		return "v2_%.6f_%.6f" % [value.x, value.y]
	elif value is Vector3:
		return "v3_%.6f_%.6f_%.6f" % [value.x, value.y, value.z]
	elif value is Vector4:
		return "v4_%.6f_%.6f_%.6f_%.6f" % [value.x, value.y, value.z, value.w]
	elif value is float:
		return "f_%.6f" % value
	elif value is int:
		return "i_%d" % value
	elif value is bool:
		return "b_%d" % (1 if value else 0)
	return str(value)

func generate_cache_key(values: Array, mode: InterpolationModes, steps: int) -> String:
	var key_parts: Array[String] = []
	key_parts.append(str(mode))
	key_parts.append(str(steps))
	for i in values.size():
		var val: Variant = values[i]
		key_parts.append(serialize_value(val))
	return "_".join(key_parts)

func add_to_cache(key: String, result: Array) -> void:
	var estimated_size: int = estimate_result_size(result)
	
	while cache_size + estimated_size > MAX_CACHE_SIZE and not cache.is_empty():
		var first_key: String = cache.keys()[0]
		var removed_result: Array = cache[first_key]
		cache_size -= estimate_result_size(removed_result)
		cache.erase(first_key)
	
	cache[key] = result
	cache_size += estimated_size

func interpolate(values: Array[Variant], interpolation_mode: InterpolationModes, fps: int) -> Array[Variant]:
	if values.is_empty():
		return []
	
	var cache_key: String = generate_cache_key(values, interpolation_mode, fps)
	if cache_key in cache:
		return cache[cache_key]
	
	var first_value: Variant = values[0]
	var catmull_rom_tension: float = 1.0
	var result: Array[Variant] = []
	
	if first_value is Vector2:
		match interpolation_mode:
			InterpolationModes.LINEAR:
				result = linear_vector2_chain(values, fps)
			InterpolationModes.BEZIER:
				result = bezier_vector2_chain(values, fps)
			InterpolationModes.CATMULLROM:
				result = catmull_rom_vector2_chain(values, catmull_rom_tension, fps)
	elif first_value is Vector3:
		match interpolation_mode:
			InterpolationModes.LINEAR:
				result = linear_vector3_chain(values, fps)
			InterpolationModes.BEZIER:
				result = bezier_vector3_chain(values, fps)
			InterpolationModes.CATMULLROM:
				result = catmull_rom_vector3_chain(values, catmull_rom_tension, fps)
	elif first_value is Vector4:
		match interpolation_mode:
			InterpolationModes.LINEAR:
				result = linear_vector4_chain(values, fps)
			InterpolationModes.BEZIER:
				result = bezier_vector4_chain(values, fps)
			InterpolationModes.CATMULLROM:
				result = catmull_rom_vector4_chain(values, catmull_rom_tension, fps)
	elif first_value is float:
		match interpolation_mode:
			InterpolationModes.LINEAR:
				result = linear_float_chain(values, fps)
			InterpolationModes.BEZIER:
				result = bezier_float_chain(values, fps)
			InterpolationModes.CATMULLROM:
				result = catmull_rom_float_chain(values, catmull_rom_tension, fps)
	elif first_value is int:
		match interpolation_mode:
			InterpolationModes.LINEAR:
				result = linear_int_chain(values, fps)
			InterpolationModes.BEZIER:
				result = bezier_int_chain(values, fps)
			InterpolationModes.CATMULLROM:
				result = catmull_rom_int_chain(values, catmull_rom_tension, fps)
	elif first_value is bool:
		result = linear_bool_chain(values, fps)
	
	if not result.is_empty():
		add_to_cache(cache_key, result)
	
	return result

func clear_cache() -> void:
	cache.clear()
	cache_size = 0

func get_cache_size() -> int:
	return cache_size

func get_cache_count() -> int:
	return cache.size()

func linear_vector2_chain(target_points: Array, steps: int) -> Array[Vector2]:
	var total_size: int = (target_points.size() - 1) * steps
	var result: Array[Vector2] = []
	result.resize(total_size)
	var idx: int = 0
	
	for i in target_points.size() - 1:
		var from: Vector2 = target_points[i]
		var to: Vector2 = target_points[i + 1]
		var inv_steps: float = 1.0 / (steps - 1) if steps > 1 else 1.0
		
		for j in steps:
			var t: float = j * inv_steps
			result[idx] = from.lerp(to, t)
			idx += 1
	
	return result

func linear_vector3_chain(target_points: Array, steps: int) -> Array[Vector3]:
	var total_size: int = (target_points.size() - 1) * steps
	var result: Array[Vector3] = []
	result.resize(total_size)
	var idx: int = 0
	
	for i in target_points.size() - 1:
		var from: Vector3 = target_points[i]
		var to: Vector3 = target_points[i + 1]
		var inv_steps: float = 1.0 / (steps - 1) if steps > 1 else 1.0
		
		for j in steps:
			var t: float = j * inv_steps
			result[idx] = from.lerp(to, t)
			idx += 1
	
	return result

func linear_vector4_chain(target_points: Array, steps: int) -> Array[Vector4]:
	var total_size: int = (target_points.size() - 1) * steps
	var result: Array[Vector4] = []
	result.resize(total_size)
	var idx: int = 0
	
	for i in target_points.size() - 1:
		var from: Vector4 = target_points[i]
		var to: Vector4 = target_points[i + 1]
		var inv_steps: float = 1.0 / (steps - 1) if steps > 1 else 1.0
		
		for j in steps:
			var t: float = j * inv_steps
			result[idx] = from.lerp(to, t)
			idx += 1
	
	return result

func linear_float_chain(target_floats: Array, steps: int) -> Array[float]:
	var total_size: int = (target_floats.size() - 1) * steps
	var result: Array[float] = []
	result.resize(total_size)
	var idx: int = 0
	var inv_steps: float = 1.0 / (steps - 1) if steps > 1 else 1.0
	
	for i in target_floats.size() - 1:
		var from: float = target_floats[i]
		var to: float = target_floats[i + 1]
		var diff: float = to - from
		
		for j in steps:
			result[idx] = from + j * inv_steps * diff
			idx += 1
	
	return result

func linear_int_chain(target_ints: Array, steps: int) -> Array[int]:
	var total_size: int = (target_ints.size() - 1) * steps
	var result: Array[int] = []
	result.resize(total_size)
	var idx: int = 0
	var inv_steps: float = 1.0 / (steps - 1) if steps > 1 else 1.0
	
	for i in target_ints.size() - 1:
		var from: int = target_ints[i]
		var to: int = target_ints[i + 1]
		var diff: int = to - from
		
		for j in steps:
			result[idx] = int(round(from + j * inv_steps * diff))
			idx += 1
	
	return result

func linear_bool_chain(target_bools: Array, steps: int) -> Array[bool]:
	var total_size: int = (target_bools.size() - 1) * steps
	var result: Array[bool] = []
	result.resize(total_size)
	var idx: int = 0
	
	for i in target_bools.size() - 1:
		var from: bool = target_bools[i]
		var to: bool = target_bools[i + 1]
		
		if from == to:
			for j in steps:
				result[idx] = from
				idx += 1
		else:
			var transition_point: int = int(steps * 0.5)
			for j in steps:
				result[idx] = to if j >= transition_point else from
				idx += 1
	
	return result

func bezier_vector2_chain(target_points: Array, steps_per_segment: int = 60) -> Array[Vector2]:
	var control_points: Array[Vector2] = generate_control_points_vec2(target_points)
	var total_size: int = (target_points.size() - 1) * steps_per_segment
	var result: Array[Vector2] = []
	result.resize(total_size)
	var idx: int = 0
	var inv_steps: float = 1.0 / (steps_per_segment - 1) if steps_per_segment > 1 else 1.0
	
	for i in target_points.size() - 1:
		var p0: Vector2 = target_points[i]
		var p3: Vector2 = target_points[i + 1]
		var p1: Vector2 = control_points[i * 2]
		var p2: Vector2 = control_points[i * 2 + 1]
		
		for j in steps_per_segment:
			var t: float = j * inv_steps
			result[idx] = cubic_bezier_vec2(p0, p1, p2, p3, t)
			idx += 1
	
	return result

func bezier_vector3_chain(target_points: Array, steps_per_segment: int = 60) -> Array[Vector3]:
	var control_points: Array[Vector3] = generate_control_points_vec3(target_points)
	var total_size: int = (target_points.size() - 1) * steps_per_segment
	var result: Array[Vector3] = []
	result.resize(total_size)
	var idx: int = 0
	var inv_steps: float = 1.0 / (steps_per_segment - 1) if steps_per_segment > 1 else 1.0
	
	for i in target_points.size() - 1:
		var p0: Vector3 = target_points[i]
		var p3: Vector3 = target_points[i + 1]
		var p1: Vector3 = control_points[i * 2]
		var p2: Vector3 = control_points[i * 2 + 1]
		
		for j in steps_per_segment:
			var t: float = j * inv_steps
			result[idx] = cubic_bezier_vec3(p0, p1, p2, p3, t)
			idx += 1
	
	return result

func bezier_vector4_chain(target_points: Array, steps_per_segment: int = 60) -> Array[Vector4]:
	var control_points: Array[Vector4] = generate_control_points_vec4(target_points)
	var total_size: int = (target_points.size() - 1) * steps_per_segment
	var result: Array[Vector4] = []
	result.resize(total_size)
	var idx: int = 0
	var inv_steps: float = 1.0 / (steps_per_segment - 1) if steps_per_segment > 1 else 1.0
	
	for i in target_points.size() - 1:
		var p0: Vector4 = target_points[i]
		var p3: Vector4 = target_points[i + 1]
		var p1: Vector4 = control_points[i * 2]
		var p2: Vector4 = control_points[i * 2 + 1]
		
		for j in steps_per_segment:
			var t: float = j * inv_steps
			result[idx] = cubic_bezier_vec4(p0, p1, p2, p3, t)
			idx += 1
	
	return result

func bezier_float_chain(target_floats: Array, steps_per_segment: int = 60) -> Array[float]:
	var control_points: Array[float] = generate_control_points_float(target_floats)
	var total_size: int = (target_floats.size() - 1) * steps_per_segment
	var result: Array[float] = []
	result.resize(total_size)
	var idx: int = 0
	var inv_steps: float = 1.0 / (steps_per_segment - 1) if steps_per_segment > 1 else 1.0
	
	for i in target_floats.size() - 1:
		var v0: float = target_floats[i]
		var v3: float = target_floats[i + 1]
		var v1: float = control_points[i * 2]
		var v2: float = control_points[i * 2 + 1]
		
		for j in steps_per_segment:
			var t: float = j * inv_steps
			result[idx] = cubic_bezier_float(v0, v1, v2, v3, t)
			idx += 1
	
	return result

func bezier_int_chain(target_ints: Array, steps_per_segment: int = 60) -> Array[int]:
	var control_points: Array[int] = generate_control_points_int(target_ints)
	var total_size: int = (target_ints.size() - 1) * steps_per_segment
	var result: Array[int] = []
	result.resize(total_size)
	var idx: int = 0
	var inv_steps: float = 1.0 / (steps_per_segment - 1) if steps_per_segment > 1 else 1.0
	
	for i in target_ints.size() - 1:
		var v0: int = target_ints[i]
		var v3: int = target_ints[i + 1]
		var v1: int = control_points[i * 2]
		var v2: int = control_points[i * 2 + 1]
		
		for j in steps_per_segment:
			var t: float = j * inv_steps
			result[idx] = int(round(cubic_bezier_float(float(v0), float(v1), float(v2), float(v3), t)))
			idx += 1
	
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
	
	control_points.resize((n - 1) * 2)
	var idx := 0
	
	for i in n - 1:
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
		
		control_points[idx] = current + prev_tangent * distance
		control_points[idx + 1] = next - next_tangent * distance
		idx += 2
	
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
	
	control_points.resize((n - 1) * 2)
	var idx := 0
	
	for i in n - 1:
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
		
		control_points[idx] = current + prev_tangent * distance
		control_points[idx + 1] = next - next_tangent * distance
		idx += 2
	
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
	
	control_points.resize((n - 1) * 2)
	var idx := 0
	
	for i in n - 1:
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
		
		control_points[idx] = current + prev_tangent * distance
		control_points[idx + 1] = next - next_tangent * distance
		idx += 2
	
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
	tangents.resize(n)
	
	for i in n:
		if i == 0:
			tangents[i] = (values[1] - values[0]) * 0.5
		elif i == n - 1:
			tangents[i] = (values[i] - values[i-1]) * 0.5
		else:
			tangents[i] = (values[i+1] - values[i-1]) * 0.25
	
	control_points.resize((n - 1) * 2)
	var idx := 0
	
	for i in n - 1:
		var current: float = values[i]
		var next: float = values[i + 1]
		var segment_length: float = abs(next - current)
		var scale: float = segment_length / 3.0
		control_points[idx] = current + tangents[i] * scale
		control_points[idx + 1] = next - tangents[i+1] * scale
		idx += 2
	
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
	tangents.resize(n)
	
	for i in n:
		if i == 0:
			tangents[i] = float(values[1] - values[0]) * 0.5
		elif i == n - 1:
			tangents[i] = float(values[i] - values[i-1]) * 0.5
		else:
			tangents[i] = float(values[i+1] - values[i-1]) * 0.25
	
	control_points.resize((n - 1) * 2)
	var idx := 0
	
	for i in n - 1:
		var current := float(values[i])
		var next := float(values[i + 1])
		var segment_length: float = abs(next - current)
		var scale: float = segment_length / 3.0
		control_points[idx] = int(round(current + tangents[i] * scale))
		control_points[idx + 1] = int(round(next - tangents[i+1] * scale))
		idx += 2
	
	return control_points

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

func generate_catmull_rom_tangents_vec2(points: Array, tension: float = 0.5) -> Array[Vector2]:
	var n := points.size()
	var tangents: Array[Vector2] = []
	
	if n < 2:
		return tangents
	
	tangents.resize(n)
	
	for i in n:
		if i == 0:
			tangents[i] = tension * (points[1] - points[0])
		elif i == n - 1:
			tangents[i] = tension * (points[n-1] - points[n-2])
		else:
			tangents[i] = tension * (points[i+1] - points[i-1]) * 0.5
	
	return tangents

func generate_catmull_rom_tangents_vec3(points: Array, tension: float = 0.5) -> Array[Vector3]:
	var n := points.size()
	var tangents: Array[Vector3] = []
	
	if n < 2:
		return tangents
	
	tangents.resize(n)
	
	for i in n:
		if i == 0:
			tangents[i] = tension * (points[1] - points[0])
		elif i == n - 1:
			tangents[i] = tension * (points[n-1] - points[n-2])
		else:
			tangents[i] = tension * (points[i+1] - points[i-1]) * 0.5
	
	return tangents

func generate_catmull_rom_tangents_vec4(points: Array, tension: float = 0.5) -> Array[Vector4]:
	var n := points.size()
	var tangents: Array[Vector4] = []
	
	if n < 2:
		return tangents
	
	tangents.resize(n)
	
	for i in n:
		if i == 0:
			tangents[i] = tension * (points[1] - points[0])
		elif i == n - 1:
			tangents[i] = tension * (points[n-1] - points[n-2])
		else:
			tangents[i] = tension * (points[i+1] - points[i-1]) * 0.5
	
	return tangents

func generate_catmull_rom_tangents_float(values: Array, tension: float = 0.5) -> Array[float]:
	var n := values.size()
	var tangents: Array[float] = []
	
	if n < 2:
		return tangents
	
	tangents.resize(n)
	
	for i in n:
		if i == 0:
			tangents[i] = tension * (values[1] - values[0])
		elif i == n - 1:
			tangents[i] = tension * (values[n-1] - values[n-2])
		else:
			tangents[i] = tension * (values[i+1] - values[i-1]) * 0.5
	
	return tangents

func generate_catmull_rom_tangents_int(values: Array, tension: float = 0.5) -> Array[int]:
	var n := values.size()
	var tangents: Array[int] = []
	
	if n < 2:
		return tangents
	
	tangents.resize(n)
	
	for i in n:
		var tangent: float
		if i == 0:
			tangent = tension * (values[1] - values[0])
		elif i == n - 1:
			tangent = tension * (values[n-1] - values[n-2])
		else:
			tangent = tension * (values[i+1] - values[i-1]) * 0.5
		tangents[i] = int(round(tangent))
	
	return tangents

func catmull_rom_vector2_chain(target_points: Array, tension: float = 0.5, steps_per_segment: int = 60) -> Array[Vector2]:
	if target_points.size() < 2:
		return []
	
	var tangents := generate_catmull_rom_tangents_vec2(target_points, tension)
	var total_size := (target_points.size() - 1) * steps_per_segment
	var result: Array[Vector2] = []
	result.resize(total_size)
	var idx := 0
	var inv_steps := 1.0 / (steps_per_segment - 1) if steps_per_segment > 1 else 1.0
	
	for i in target_points.size() - 1:
		var p0: Vector2 = target_points[i]
		var p1: Vector2 = target_points[i + 1]
		var m0 := tangents[i]
		var m1 := tangents[i + 1]
		
		for j in steps_per_segment:
			var t := j * inv_steps
			result[idx] = cubic_hermite_vec2(p0, p1, m0, m1, t)
			idx += 1
	
	return result

func catmull_rom_vector3_chain(target_points: Array, tension: float = 0.5, steps_per_segment: int = 60) -> Array[Vector3]:
	if target_points.size() < 2:
		return []
	
	var tangents := generate_catmull_rom_tangents_vec3(target_points, tension)
	var total_size := (target_points.size() - 1) * steps_per_segment
	var result: Array[Vector3] = []
	result.resize(total_size)
	var idx := 0
	var inv_steps := 1.0 / (steps_per_segment - 1) if steps_per_segment > 1 else 1.0
	
	for i in target_points.size() - 1:
		var p0: Vector3 = target_points[i]
		var p1: Vector3 = target_points[i + 1]
		var m0 := tangents[i]
		var m1 := tangents[i + 1]
		
		for j in steps_per_segment:
			var t := j * inv_steps
			result[idx] = cubic_hermite_vec3(p0, p1, m0, m1, t)
			idx += 1
	
	return result

func catmull_rom_vector4_chain(target_points: Array, tension: float = 0.5, steps_per_segment: int = 60) -> Array[Vector4]:
	if target_points.size() < 2:
		return []
	
	var tangents := generate_catmull_rom_tangents_vec4(target_points, tension)
	var total_size := (target_points.size() - 1) * steps_per_segment
	var result: Array[Vector4] = []
	result.resize(total_size)
	var idx := 0
	var inv_steps := 1.0 / (steps_per_segment - 1) if steps_per_segment > 1 else 1.0
	
	for i in target_points.size() - 1:
		var p0: Vector4 = target_points[i]
		var p1: Vector4 = target_points[i + 1]
		var m0 := tangents[i]
		var m1 := tangents[i + 1]
		
		for j in steps_per_segment:
			var t := j * inv_steps
			result[idx] = cubic_hermite_vec4(p0, p1, m0, m1, t)
			idx += 1
	
	return result

func catmull_rom_float_chain(target_floats: Array, tension: float = 0.5, steps_per_segment: int = 60) -> Array[float]:
	if target_floats.size() < 2:
		return []
	
	var tangents := generate_catmull_rom_tangents_float(target_floats, tension)
	var total_size := (target_floats.size() - 1) * steps_per_segment
	var result: Array[float] = []
	result.resize(total_size)
	var idx := 0
	var inv_steps := 1.0 / (steps_per_segment - 1) if steps_per_segment > 1 else 1.0
	
	for i in target_floats.size() - 1:
		var v0: float = target_floats[i]
		var v1: float = target_floats[i + 1]
		var m0 := tangents[i]
		var m1 := tangents[i + 1]
		
		for j in steps_per_segment:
			var t := j * inv_steps
			result[idx] = cubic_hermite_float(v0, v1, m0, m1, t)
			idx += 1
	
	return result

func catmull_rom_int_chain(target_ints: Array, tension: float = 0.5, steps_per_segment: int = 60) -> Array[int]:
	if target_ints.size() < 2:
		return []
	
	var tangents := generate_catmull_rom_tangents_int(target_ints, tension)
	var total_size := (target_ints.size() - 1) * steps_per_segment
	var result: Array[int] = []
	result.resize(total_size)
	var idx := 0
	var inv_steps := 1.0 / (steps_per_segment - 1) if steps_per_segment > 1 else 1.0
	
	for i in target_ints.size() - 1:
		var v0: float = target_ints[i]
		var v1: float = target_ints[i + 1]
		var m0 := tangents[i]
		var m1 := tangents[i + 1]
		
		for j in steps_per_segment:
			var t := j * inv_steps
			result[idx] = int(round(cubic_hermite_float(v0, v1, float(m0), float(m1), t)))
			idx += 1
	
	return result
