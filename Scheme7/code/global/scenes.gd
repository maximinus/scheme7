extends Node

# the first scene is dictated in the project settings

var loader: ResourceInteractiveLoader
var next_scene = []
var scene_list

func _ready() -> void:
	# we need to load in the level structure
	# this tells where to go from scene to scene
	loader = null
	
func getNextScene() -> String:
	return next_scene.pop_front()

func addScene(scene) -> void:
	next_scene.append(scene)

func loadScene(scene_path):
	loader = ResourceLoader.load_interactive(scene_path)
	if loader == null:
		print('Error: New ResourceLoader instance is null')
		get_tree().quit()

func loadChunk() -> bool:
	if loader == null:
		print('Error: Null loader')
		return false
	var err = loader.poll()
	if err == ERR_FILE_EOF:
		# we have finished loading
		return true
	return false

func getLoadedScene():
	if loader == null:
		print('Error: Cannot load scene from null')
		get_tree().quit()
	return(loader.get_resource())

func changeScene():
	var scene: PackedScene = getLoadedScene()
	get_tree().change_scene_to(scene)
