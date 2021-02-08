extends Node2D

func _ready():
	pass

func _on_Timer_timeout():
	var scene = Scenes.getNextScene()
	get_tree().change_scene(scene)
