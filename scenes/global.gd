extends Node

var value_nodes: Array[Control] = []

func show_yes_no_popup(title: String, message: String, parent_node: Node = null) -> bool:
	var confirmation_dialog := AcceptDialog.new()
	confirmation_dialog.title = title
	confirmation_dialog.dialog_text = message
	confirmation_dialog.add_cancel_button("No")
	
	if parent_node == null:
		get_tree().current_scene.add_child(confirmation_dialog)
	else:
		parent_node.add_child(confirmation_dialog)
	
	confirmation_dialog.popup_centered()
	
	var result := false
	confirmation_dialog.confirmed.connect(func() -> void: result = true)
	confirmation_dialog.canceled.connect(func() -> void: result = false)
	
	await confirmation_dialog.close_requested
	confirmation_dialog.queue_free()
	
	return result
