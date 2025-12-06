extends MarginContainer

var FORMULAS: Array[String] = []

@export var page_number: int = 1
const FONT = preload('res://resources/font/Rubik-SemiBold.ttf')
const FLOAT_FIELD_SCENE = preload('res://ui/fields/float field/float_field.tscn')
const INT_FIELD_SCENE = preload('res://ui/fields/int field/int_field.tscn')
const BUTTON_FIELD_SCENE = preload('res://ui/fields/button field/button_field.tscn')
const VECTOR2_FIELD_SCENE = preload('res://ui/fields/vec2 field/vec2_field.tscn')
const VECTOR3_FIELD_SCENE = preload('res://ui/fields/vec3 field/vec3_field.tscn')
const VECTOR4_FIELD_SCENE = preload('res://ui/fields/vec4 field/vec4_field.tscn')
const SELECTION_FIELD_SCENE = preload('res://ui/fields/selection field/selection_field.tscn')
const BOOLEAN_FIELD_SCENE = preload('res://ui/fields/boolean field/boolean_field.tscn')
const STRING_FIELD_SCENE = preload('res://ui/fields/string field/string_field.tscn')

var is_initialized := false
var initialized_formulas: Array = []

func initialize_formula(formula_index: int) -> void:
	get_tree().current_scene.initialize_formulas("res://formulas/")
	
	#print('init 1: ', formula_index)
	
	if formula_index == 0 or formula_index == -1 or formula_index in initialized_formulas:
		return
	
	var formula: Dictionary = get_tree().current_scene.get_formula_data_from_index(formula_index)
	
	var formula_id: String = formula["id"]
	var base_name: String = "F" + formula_id.replace(" ", "")
	var uniform_prefix: String = "f" + formula_id + "_"
	var variables: Dictionary = formula["variables"]
	var value_nodes_vbox: VBoxContainer = $Fields/HBoxContainer/Values.get_node(base_name)
	var name_nodes_vbox: VBoxContainer = $Fields/HBoxContainer/Names.get_node(base_name)
	
	if formula_index not in %TabContainer.current_formulas:
		return
	
	initialized_formulas.append(formula_index)
	
	for variable_name in (variables.keys() as Array[String]):
		var variable_data: Dictionary = variables[variable_name]
		var uniform_name: String = uniform_prefix + variable_name
		var node_name: String = base_name + variable_name.to_pascal_case()
		var value_node: Control
		
		match variable_data["type"]:
			"float":
				value_node = FLOAT_FIELD_SCENE.instantiate()
				value_node.range = Vector2(variable_data["from"], variable_data["to"])
				value_node.value = variable_data["default_value"]
			"int":
				value_node = INT_FIELD_SCENE.instantiate()
				value_node.range = Vector2(variable_data["from"], variable_data["to"])
				value_node.value = variable_data["default_value"]
			"vec2":
				value_node = VECTOR2_FIELD_SCENE.instantiate()
				value_node.range_min = variable_data["from"]
				value_node.range_max = variable_data["to"]
				value_node.value = variable_data["default_value"]
			"vec3":
				value_node = VECTOR3_FIELD_SCENE.instantiate()
				value_node.range_min = variable_data["from"]
				value_node.range_max = variable_data["to"]
				value_node.value = variable_data["default_value"]
			"vec4":
				value_node = VECTOR4_FIELD_SCENE.instantiate()
				value_node.range_min = variable_data["from"]
				value_node.range_max = variable_data["to"]
				value_node.value = variable_data["default_value"]
			"selection":
				value_node = SELECTION_FIELD_SCENE.instantiate()
				value_node.set_options(Array(variable_data["values"]) as Array[String])
				value_node.index = variable_data["values"].find(variable_data["default_value"])
			"bool":
				value_node = BOOLEAN_FIELD_SCENE.instantiate()
				value_node.value = variable_data["default_value"]
			"string":
				value_node = STRING_FIELD_SCENE.instantiate()
				value_node.value = variable_data["default_value"]
		
		value_node.name = node_name
		value_node.set_meta("snake_case_name", variable_name)
		value_node.set_meta("uniform_name", uniform_name)
		value_node.set_meta("formula_name", formula_id)
		value_node.set_meta("formula_index", formula["index"])
		value_node.set_meta("shader_formula_field", true)
		
		value_node.connect("value_changed", Callable(self, "_on_value_changed").bind(value_node))
		
		value_nodes_vbox.add_child(value_node)
		if variable_data["difficulty"] == "advanced":
			get_tree().current_scene.advanced_ui_fields.append(value_node)
		
		var as_array := value_node.name.to_snake_case().split("_")
		var text := "_".join(PackedStringArray(as_array.slice(1))).to_pascal_case()
		text = Global.add_spaces(text).trim_prefix("4d ")
		
		var label: Label = Label.new()
		label.text = text + ": "
		label.name = value_node.name
		label.add_theme_font_override("font", FONT)
		
		match variable_data["type"]:
			"vec2":
				label.text += "\n"
				label.add_theme_constant_override("line_spacing", 6)
			"vec3":
				label.text += "\n\n\n"
				label.add_theme_constant_override("line_spacing", 0)
			"vec4":
				label.text += "\n\n\n\n"
				label.add_theme_constant_override("line_spacing", 3)
		
		name_nodes_vbox.add_child(label)
		value_node.set_meta("name_node", label)

func _on_value_changed(new_value: Variant, node: Control) -> void:
	if node.has_method('i_am_a_selection_field'):
		new_value = node.options.find(new_value)
	
	field_changed(node.get_meta("uniform_name"), new_value)

func i_am_a_formula_page() -> void: pass

func field_changed(field_name: String, to: Variant) -> void:
	%TabContainer.field_changed(field_name, to)

func field_changed_non_shader(field_name: String, to: Variant) -> void:
	%TabContainer.field_changed_non_shader(field_name, to)

func set_formula(formula_name: String) -> void:
	%TabContainer.set_formula(formula_name, page_number)

func set_formula_from_id(id: int) -> void:
	var formula_name: String = $Fields/HBoxContainer/Values/Formulas.options[id]
	$Fields/HBoxContainer/Values/Formulas.index = id
	%TabContainer.set_formula(formula_name, page_number)

func basic_initialization() -> void:
	for formula in (get_tree().current_scene.formulas as Array[Dictionary]):
		var formula_id: String = formula["id"]
		var base_name: String = "F" + formula_id.replace(" ", "")
		var value_nodes_vbox: VBoxContainer
		var name_nodes_vbox: VBoxContainer
		
		$Fields/HBoxContainer/Values/Formulas.label_overrides.append(formula["formatted_id"])
		$Fields/HBoxContainer/Values/Formulas.options.append(formula_id)
		FORMULAS.append(formula_id)
		
		value_nodes_vbox = VBoxContainer.new()
		value_nodes_vbox.name = base_name
		value_nodes_vbox.visible = false
		value_nodes_vbox.add_theme_constant_override("separation", 6)
		$Fields/HBoxContainer/Values.add_child(value_nodes_vbox)
		
		name_nodes_vbox = VBoxContainer.new()
		name_nodes_vbox.name = base_name
		name_nodes_vbox.visible = false
		name_nodes_vbox.add_theme_constant_override("separation", 14)
		$Fields/HBoxContainer/Names.add_child(name_nodes_vbox)

func _ready() -> void:
	basic_initialization()
	
	if page_number == 1:
		set_formula('mandelbulb')
		$Fields/HBoxContainer/Values/Formulas.index = $Fields/HBoxContainer/Values/Formulas.options.find('mandelbulb')
