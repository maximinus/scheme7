extends Node

# the first scene is dictated in the project settings

var next_scene = []
var scene_list

func _ready():
	# we need to load in the level structure
	# this tells where to go from scene to scene
	pass
	
func getNextScene():
	return next_scene.pop_front()

func addScene(scene):
	next_scene.append(scene)
