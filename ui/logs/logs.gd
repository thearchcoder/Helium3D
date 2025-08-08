extends MarginContainer

var logs: String = "":
	set(value):
		logs = value
		$RichTextLabel.text = value

func print_console(text: String) -> void:
	logs += text
	logs += '\n'
