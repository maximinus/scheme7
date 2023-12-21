extends Control

var dialogs: Array = []
var dialog_index: int = 0


func _ready():
	$Panel.hide()

func setup(new_dialogs):
	dialogs = new_dialogs
	if len(new_dialogs) == 0:
		return
	$Panel.show()
	$Panel/MarginContainer/HBox/Label.text = dialogs[0].text

func next():
	dialog_index += 1
	if dialog_index >= len(dialogs):
		# nothing to do
		hide()
	else:
		$Panel/MarginContainer/HBox/Label.text = dialogs[dialog_index].text
