extends VBoxContainer

func _on_formula_value_changed(option: String) -> void:
	%TabContainer.set_formula(option)
