extends Node

var next_scene = [];

func _ready():
	pass

func getNextScene():
	return next_scene.pop_front()

func addScene(scene):
	next_scene.append(scene)
