extends Control

const OBJECTIVE_LABEL = preload('res://scenes/PlayerUI/MissionObjectives/Objective/ObjectiveLabel.tscn')

var objectives = []

func _ready():
	objectives = Globals.level.getObjectives()
	for i in objectives:
		var obj_label = OBJECTIVE_LABEL.instance()
		obj_label.text = i
		$Margin/VBox.add_child(obj_label)
