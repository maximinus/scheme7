extends Node

var text: Array

class  Dialog:
	var speaker: String
	var text: String
	
	func _init() -> void:
		pass

func setDialog(data) -> void:
	text = data

func getDialog() -> Array:
	# return a chunk of dialog after converting
	var dialogs = []
	for i in text:
		var d = Dialog.new()
		d.speaker = 'Test Engineer'
		d.text = i
		dialogs.append(d)
	return(dialogs)
