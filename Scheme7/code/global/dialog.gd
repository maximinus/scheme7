extends Node

var text = ['Good morning.\nToday we will be conducting the standard startup test.',
			'This test will determine if your system has been installed correctly so you can begin active service.',
			'We begin with testing the simpler controls.\nThe L key will cycle through the lights.']


class  Dialog:
	var speaker: String
	var text
	
	func _init():
		pass

func getDialog() -> Array:
	# return a chunk of dialog
	var dialogs = []
	for i in text:
		var d = Dialog.new()
		d.speaker = 'Test Engineer'
		d.text = i
		dialogs.append(d)
	return(dialogs)
