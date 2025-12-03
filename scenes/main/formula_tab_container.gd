extends TabContainer

func initialize_formula(formula_index: int, page_index: int) -> void:
	var formula_page: Control = get_formula_page(page_index)
	formula_page.initialize_formula(formula_index)

func _process(_delta: float) -> void:
	%Fractal.material_override.set_shader_parameter('number_of_active_formulas', len(get_active_formula_pages()))
	
	for child in $Buffer.get_children():
		child.visible = false
	
	if Input.is_action_just_pressed('move tab left'):
		move_child($Buffer, get_child_count() - 1)
		var current_tab_selected: Node = get_child(current_tab)
		var tab_left: Node = get_child(max(current_tab - 1, 0))
		
		var index_selected: int = current_tab_selected.get_node("Fields/HBoxContainer/Values/Formulas").index
		var index_left: int = tab_left.get_node("Fields/HBoxContainer/Values/Formulas").index
		current_tab_selected.get_node("Fields/HBoxContainer/Values/Formulas").index = index_left
		tab_left.get_node("Fields/HBoxContainer/Values/Formulas").index = index_selected
		current_tab -= 1
	elif Input.is_action_just_pressed('move tab right'):
		move_child($Buffer, 0)
		# Offset current tab by 1 because of buffer node.
		var current_tab_selected: Node = get_child(current_tab + 1)
		var tab_right: Node = get_child(min(current_tab + 2, get_child_count() - 1))
		
		var index_selected: int = current_tab_selected.get_node("Fields/HBoxContainer/Values/Formulas").index
		var index_right: int = tab_right.get_node("Fields/HBoxContainer/Values/Formulas").index
		current_tab_selected.get_node("Fields/HBoxContainer/Values/Formulas").index = index_right
		tab_right.get_node("Fields/HBoxContainer/Values/Formulas").index = index_selected
		current_tab += 1
	elif Input.is_action_just_pressed('switch tab left'): current_tab = clamp(current_tab - 1, 0, get_child_count() - 1)
	elif Input.is_action_just_pressed('switch tab right'): current_tab = clamp(current_tab + 1, 0, get_child_count() - 1)

func set_difficulty(difficulty: String) -> void:
	for formula_page in get_active_formula_pages():
		formula_page.set_difficulty(difficulty)

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
