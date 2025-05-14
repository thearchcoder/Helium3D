extends HBoxContainer

var options: Array = []
var filter: String = ''

func add_option(option_name: String) -> void:
	options.append(option_name)

func reload_popup() -> void:
	$OptionButton.clear()
	for option in (options as Array[String]):
		if filter:
			if option.to_lower().begins_with(filter.to_lower()):
				$OptionButton.add_item(option)
		else:
			$OptionButton.add_item(option)

func get_formula_index_from_name(formatted_id: String) -> int:
	for formula in (get_tree().current_scene.formulas as Array[Dictionary]):
		if formula['formatted_id'] == formatted_id:
			return formula['index']
	
	return 0

func _process(delta: float) -> void:
	if $"../../..".visible and Input.is_action_just_pressed('enter'):
		$"../SearchCloseButton".emit_signal('pressed')
		_on_option_button_item_selected($OptionButton.selected)

func update_selected_item(value: String) -> void:
	$OptionButton.selected = $"../../../..".index - 1

func _ready() -> void:
	$"../../../..".connect('value_changed', update_selected_item)
	await get_tree().process_frame
	for formula in (get_tree().current_scene.formulas as Array[Dictionary]):
		add_option(formula['formatted_id'])
	
	reload_popup()

func _on_option_button_item_selected(index: int) -> void:
	$"../../../..".index = get_formula_index_from_name($OptionButton.get_item_text(index))

func _on_search_close_button_pressed() -> void:
	$"../../..".visible = false
	filter = ''

func _on_popup_close_requested() -> void:
	_on_search_close_button_pressed()

func _on_line_edit_text_changed(new_text: String) -> void:
	filter = new_text
	reload_popup()
