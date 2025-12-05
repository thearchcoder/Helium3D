extends HBoxContainer

var options: Array = []
var filter: String = ''
var type: String = 'any'

func add_option(option_name: String) -> void:
	options.append(option_name)

func get_formula_data_from_name(formula_name: String) -> Dictionary:
	return get_tree().current_scene.get_formula_data_from_name(formula_name)

func reload_popup() -> void:
	$OptionButton.clear()
	$OptionButton.add_item('None')
	
	var filtered_options: Array[String] = []
	
	for option in (options as Array[String]):
		var should_add := true
		
		if filter:
			if not matches_filter(option, filter):
				should_add = false
		
		if type != 'any':
			var formula_data: Dictionary = get_formula_data_from_name(option)
			if formula_data.has('type'):
				if formula_data['type'] != type and formula_data['type'] != 'unknown':
					should_add = false
			else:
				should_add = false
		
		if should_add:
			filtered_options.append(option)
	
	if filter:
		filtered_options.sort_custom(func(a: String, b: String) -> bool: return get_match_score(a, filter) > get_match_score(b, filter))
	
	for option in filtered_options:
		$OptionButton.add_item(option)
	
	$OptionButton.selected = 1 if filtered_options.size() > 0 else 0

func matches_filter(text: String, search_term: String) -> bool:
	var text_lower := text.to_lower()
	var search_lower := search_term.to_lower()
	
	if search_lower in text_lower:
		return true
	
	var search_pos := 0
	for i in text_lower.length():
		if search_pos < search_lower.length() and text_lower[i] == search_lower[search_pos]:
			search_pos += 1
	
	return search_pos == search_lower.length()

func get_match_score(text: String, search_term: String) -> int:
	var text_lower := text.to_lower()
	var search_lower := search_term.to_lower()
	
	if text_lower == search_lower:
		return 1000
	
	if text_lower.begins_with(search_lower):
		return 500
	
	if search_lower in text_lower:
		return 100 + (text_lower.length() - search_lower.length())
	
	var search_pos := 0
	var last_match_pos := -1
	var gap_penalty := 0
	
	for i in text_lower.length():
		if search_pos < search_lower.length() and text_lower[i] == search_lower[search_pos]:
			if last_match_pos >= 0:
				gap_penalty += (i - last_match_pos - 1)
			last_match_pos = i
			search_pos += 1
	
	if search_pos == search_lower.length():
		return 50 - gap_penalty
	
	return 0

func _process(_delta: float) -> void:
	if $"../../..".visible and Input.is_action_just_pressed('enter'):
		_on_option_button_item_selected($OptionButton.selected)
		$"../SearchCloseButton".emit_signal('pressed')
	
	if $"../../..".visible and Input.is_action_just_pressed('escape'):
		$"../SearchCloseButton".emit_signal('pressed')

func update_selected_item(_value: String) -> void:
	$OptionButton.selected = $"../../../..".index

func _ready() -> void:
	$"../../../..".connect('value_changed', update_selected_item)
	await get_tree().process_frame
	for formula in (get_tree().current_scene.formulas as Array[Dictionary]):
		if not formula['formatted_id'].to_lower().contains(' dupe '):
			add_option(formula['formatted_id'])
	reload_popup()

func _on_option_button_item_selected(index: int) -> void:
	if index == 0 or index == -1:
		return
	
	var ind: int = get_formula_data_from_name($OptionButton.get_item_text(index))['index']
	
	for i in (get_tree().current_scene.MAX_ACTIVE_FORMULAS as int):
		if ind in get_tree().current_scene.get_node('%TabContainer').current_formulas:
			ind += 1

	$"../../../..".index = ind

func _on_search_close_button_pressed() -> void:
	$"../../..".visible = false
	filter = ''
	reload_popup()

func _on_popup_close_requested() -> void:
	_on_search_close_button_pressed()

func _on_line_edit_text_changed(new_text: String) -> void:
	filter = new_text
	reload_popup()

func _on_popup_visibility_changed() -> void:
	if $"../../..".visible:
		$"../Filter/LineEdit".grab_focus()
		$"../Filter/LineEdit".text = ""

func _on_types_item_selected(index: int) -> void:
	type = %Types.get_item_text(index).to_lower()
	reload_popup()
