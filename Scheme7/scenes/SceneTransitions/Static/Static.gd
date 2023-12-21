extends Node2D

var switch_scene: bool
var scene_loaded: bool
var scene: String

func _ready():
	# to use this scene, set the value "Scenes.next_scene"
	scene_loaded = false
	switch_scene = false

func _process(_delta):
	# keep loading until there is no more
	if scene_loaded == false:
		scene_loaded = Scenes.loadChunk()
	else:
		if switch_scene == true:
			Scenes.completeSceneTransition()

func _on_Timer_timeout():
	switch_scene = true
