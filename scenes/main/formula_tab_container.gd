extends TabContainer

func _process(delta: float) -> void:
	%Fractal.material_override.set_shader_parameter('number_of_active_formulas', len(get_active_formula_pages()))

func get_active_formula_pages() -> Array[Node]:
	var used_pages: Array[Node] = get_children()
	used_pages.remove_at(used_pages.find($Buffer))
	return used_pages

func get_formula_pages() -> Array[Node]:
	var used_pages: Array[Node] = get_children()
	used_pages.remove_at(used_pages.find($Buffer))
	return used_pages + $Buffer.get_children()

func get_formula_page(id: int) -> Control:
	if has_node('Formula' + str(id)):
		return get_node('Formula' + str(id))
	else:
		return get_node('Buffer').get_node('Formula' + str(id))
