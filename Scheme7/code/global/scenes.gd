extends Node

# the first scene is dictated in the project settings
# we use this code to transition

var current_load_path: String
var transition = preload('res://scenes/SceneTransitions/Static/Static.tscn')
var dialog_scene = preload('res://scenes/Interface/Dialog/Dialog.tscn')
var next_dialogs: Array = []
var loading_dialog: bool
var scene_stack: Array

func _ready() -> void:
	current_load_path = ''
	scene_stack = []

func addScenes(new_scenes: Array):
	scene_stack.append_array(new_scenes)

func addSingleScene(new_scene: String):
	scene_stack.append(new_scene)

func moveToNextScene():
	# the scene calling this is responsible for doiung any fade outs etc...
	# this code will:
	# start playing the "static" scene
	# load the next scene in the background
	# when the background load is complete, we set a flag
	# when the static transition is complete and loading is done,
	#   static scene will call "completeSceneTransition"
	# and then the new scene is loaded
	# If there are no scenes to move to, crash out
	if len(scene_stack) == 0:
		print('Error: No more scenes')
		get_tree().quit()
	get_tree().change_scene_to_packed(transition)
	loadScene(scene_stack[0])
	scene_stack.pop_front()

func completeSceneTransition():
	if loading_dialog == true:
		get_tree().change_scene_to_packed(dialog_scene)
	else:
		var scene: PackedScene = getLoadedScene()
		get_tree().change_scene_to_packed(scene)

func loadScene(scene_path: String):
	# start the loading of the scene in the background
	current_load_path = scene_path
	# is it a json file, and thus just simple dialog?
	if scene_path.ends_with('.json'):
		# it's a dialog file and we already have that
		Dialog.next_dialog = Dialog.loadDialog(scene_path)
		loading_dialog = true
	else:
		loading_dialog = false
		# this is called first, then loadChunk until it returns true
		ResourceLoader.load_threaded_request(current_load_path)

func loadChunk() -> bool:
	# called constantly until this returns true
	if loading_dialog == true:
		# no need to load anything, we are donw
		return true
	if current_load_path == '':
		print('Error: Null loader')
		return false
	var status = ResourceLoader.load_threaded_get_status(current_load_path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		return true
	if status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		print('Error loading scene ' + current_load_path)
		get_tree().quit()
	# still waiting
	return false

func getLoadedScene():
	if current_load_path == '':
		print('Error: No current scene loading')
		get_tree().quit()
	var new_resource = ResourceLoader.load_threaded_get(current_load_path)
	current_load_path = ''
	return new_resource

func addInitialScenes():
	# run when the game starts. This sets up the tutorial scenes and dialog
	# If a plain dialog scene is run, it needs some dialog
	# thus if a line is plain json, it is just dialog and needs a dialog scene
	var first_scenes = ['tutorials/pre_light_test.json',
						'res://scenes/Levels/tutorial_levels/tutorial_1/tutorial_1.tscn',
						'tutorials/pre_engine_test.json',
						'res://scenes/Levels/tutorial_levels/tutorial_2/tutorial_2.tscn',
						'tutorials/pre_shooting_test.json',
						'res://scenes/Levels/tutorial_levels/tutorial_3_shoot/tutorial_3_shoot.tscn']
	addScenes(first_scenes)
