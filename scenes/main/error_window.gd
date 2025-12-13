extends Window

var text: String = "":
	set(value):
		text = value
		$HBoxContainer/MarginContainer2/VBoxContainer/Label.text = value
