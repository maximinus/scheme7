extends Node

# this global should handle loading dialog fragments from json
# it will be called by any scenes that need dialog

var text: Array

# the base dialog scene is used many times
# however, it is stored as a packed scene and we cannot edit this data
# also it takes a frame to be instanced: so we place the data it must show
# here so it can be picked up by the scene itself
var next_dialog: Array

class SingleDialog:
	# this is the data for a single block of dialog
	var speaker: String
	var text: String
	
	func _init(spk: String, txt: String) -> void:
		speaker = spk
		text = txt


func loadDialog(filepath: String):
	# load the data in the json, parse it and return as needed
	var new_dialogs: Array = []
	var path_to_dialog = 'res://json/' + filepath
	var json_as_text = FileAccess.get_file_as_string(path_to_dialog)
	var dialog_data = JSON.parse_string(json_as_text)
	var speaker = dialog_data.speaker
	for i in dialog_data.dialogs:
		new_dialogs.append(SingleDialog.new(speaker, i))
	return new_dialogs
