extends TabContainer

@onready var FORMULAS: Array = $Formula/TabContainer.get_formula_pages()[0].FORMULAS
var current_formulas: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var total_visible_formulas: int = 1:
	set(value):
		var old_value := total_visible_formulas
		value = clamp(value, 1, get_tree().current_scene.MAX_ACTIVE_FORMULAS)
		
		if old_value == value:
			return
		
		total_visible_formulas = value
		
		var formula_tabcontainer: TabContainer = %TabContainer.get_node('Formula/TabContainer')
		var formula_pages: Array[Node] = formula_tabcontainer.get_formula_pages()
		var buffer: Node = formula_tabcontainer.get_node('Buffer')
		
		if old_value < value:
			# Show pages from old_value to value-1
			for i in range(old_value, value):
				formula_pages[i].reparent(formula_tabcontainer)
		else:
			# Hide pages from value to old_value-1
			for i in range(value, old_value):
				formula_pages[i].reparent(buffer)
		
		if total_visible_formulas == 1:
			$Formula/Buttons/AddFormula.disabled = false
			$Formula/Buttons/RemoveFormula.disabled = true
		elif total_visible_formulas == get_tree().current_scene.MAX_ACTIVE_FORMULAS:
			$Formula/Buttons/AddFormula.disabled = true
			$Formula/Buttons/RemoveFormula.disabled = false
		else:
			$Formula/Buttons/AddFormula.disabled = false
			$Formula/Buttons/RemoveFormula.disabled = false

func _ready() -> void:
	await get_tree().process_frame
	set_formula('mandelbulb', 1)

func field_changed_non_shader(field_name: String, value: Variant, update_viewport: bool = true) -> void:
	# A field changed but isn't mean't to be set in the shader
	get_tree().current_scene.fields[field_name] = value
	if update_viewport:
		%SubViewport.refresh_taa()

func field_changed(field_name: String, value: Variant) -> void:
	get_tree().current_scene.fields[field_name] = value
	
	if value is Dictionary and (value as Dictionary).has('special_field'):
		if value['type'] == 'image':
			if ResourceLoader.exists(value['path']):
				value = load(value['path'])
			else:
				value = null
		elif value['type'] == 'palette':
			var gradient: Gradient = Gradient.new()
			gradient.offsets = value['offsets']
			gradient.colors = value['colors']
			gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT if not value['is_blurry'] else Gradient.GRADIENT_INTERPOLATE_CUBIC
			value = GradientTexture1D.new()
			value.gradient = gradient
	
	%Fractal.material_override.set_shader_parameter(field_name, value)
	%SubViewport.refresh_taa()

func set_formula(formula_name: String, for_page: int) -> void:
	var formula_index: int = $Formula/TabContainer/Formula1/Fields/HBoxContainer/Values/Formulas.options.find(formula_name)
	current_formulas[for_page - 1] = formula_index
	$Formula/TabContainer.initialize_formula(formula_index, for_page)
	$Formula/TabContainer.set_difficulty(get_tree().current_scene.difficulty)
	
	field_changed('formulas', current_formulas)
	
	var formula_node_name: String = 'F' + formula_name.replace(' ', '').to_lower()
	
	for other_formula in (FORMULAS as Array[String]):
		var other_node_name: String = 'F' + other_formula.replace(' ', '').to_lower()
		var value_node: Node = %TabContainer.get_node('Formula/TabContainer').get_formula_page(for_page).get_node('Fields/HBoxContainer/Values').get_node(other_node_name)
		var name_node: Node = %TabContainer.get_node('Formula/TabContainer').get_formula_page(for_page).get_node('Fields/HBoxContainer/Names').get_node(other_node_name)
		if value_node: value_node.visible = false
		if name_node: name_node.visible = false
	
	if formula_name.to_lower() != 'none':
		var value_parent: Node = %TabContainer.get_node('Formula/TabContainer').get_formula_page(for_page).get_node('Fields/HBoxContainer/Values')
		var name_parent: Node = %TabContainer.get_node('Formula/TabContainer').get_formula_page(for_page).get_node('Fields/HBoxContainer/Names')
		if value_parent.has_node(formula_node_name): value_parent.get_node(formula_node_name).visible = true
		if name_parent.has_node(formula_node_name): name_parent.get_node(formula_node_name).visible = true
	
	get_tree().current_scene.update_fractal_code(current_formulas)

func _on_add_formula_pressed() -> void: total_visible_formulas += 1
func _on_remove_formula_pressed() -> void:
	%TabContainer.get_node('Formula/TabContainer').get_formula_page(total_visible_formulas).set_formula('None')
	%TabContainer.get_node('Formula/TabContainer').current_tab -= 1
	await get_tree().process_frame
	set_formula('none', total_visible_formulas)
	total_visible_formulas -= 1

func update_field_values(new_fields: Dictionary) -> void:
	var value_nodes: Array[Control] = Global.value_nodes
	
	for field_name in (new_fields.keys() as Array[String]):
		var field_val: Variant = new_fields[field_name]
		
		if field_val is EncodedObjectAsID or field_name in get_tree().current_scene.other_fields or field_name in ["other", "keyframe_texture"]:
			continue
		
		var search_result: Array[Control] = value_nodes.filter(func(x: Control) -> bool: return x.name.to_snake_case() == field_name.to_snake_case())
		if len(search_result) <= 0:
			continue
		
		var target_value_nodes: Array[Control] = search_result
		
		for target_value_node in target_value_nodes:
			if field_name == 'formulas':
				for current_page_number in range(1, 5 + 1):
					target_value_node = value_nodes.filter(func(x: Control) -> bool: return x.name.to_snake_case() == field_name.to_snake_case() and x.get_node('../../../..').page_number == current_page_number)[0]
					
					target_value_node.index = field_val[current_page_number - 1]
					target_value_node.emit_signal('value_changed', target_value_node.options[target_value_node.index])
				continue
			
			if not target_value_node.has_method('i_am_a_selection_field'):
				if typeof(target_value_node.value) == typeof(field_val):
					target_value_node.value = field_val
				else:
					%Logs.print_console("Failed to load field '" + field_name + "', Value: " + str(field_val))
			else:
				target_value_node.index = field_val
