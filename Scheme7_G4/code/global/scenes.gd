extends Node

# the first scene is dictated in the project settings

var loader: ResourceLoader
var load_status
var level_data
var level_index: int
var next_scene
var transition = preload('res://scenes/SceneTransitions/Static/Static.tscn')

func _ready() -> void:
	# we need to load in the level structure
	# this tells where to go from scene to scene
	loader = null
	# we need to load and parse the level data
	level_index = 0
	loadLevelData()
	setupLevel()

func moveToTransition():
	# we always transition using a scene transistion
	get_tree().change_scene_to_packed(transition)

func setupScene():
	# and this is called by the transition
	level_index += 1
	setupLevel()

func loadLevelData() -> void:
	# load the json data
	var filename = 'res://json/levels/tutorial.json'
	var json_file = FileAccess.open(filename, FileAccess.READ)
	if json_file == null:
		print('Failed to load level data')
		get_tree().quit()
	var json_text = json_file.get_as_text()
	json_file.close()
	var json_data = JSON.parse_string(json_text)
	if json_data == null:
		print('Error: Failed to load json')
		get_tree().quit()
	level_data = json_data

func setupLevel():
	print('Setting up: ', level_index)
	# read the level data and setup the next level before loading it
	# this should be handled during the transition scene
	var level = level_data[level_index]
	# now we check everything
	next_scene = getScene(level['level'])
	addDialog(level)
	buildShip(level)

func getScene(scene: String):
	# is it the dialog?
	if scene == 'Dialog':
		return('res://scenes/Interface/Dialog/Dialog.tscn')
	if scene.begins_with('tutorial'):
		return('res://scenes/Levels/tutorial_levels/' + scene + '/' + scene + '.tscn')
	print('Error: Cannot understand scene name ' + scene)
	get_tree().quit()

func addDialog(level):
	if not level.has('dialog'):
		return
	# load the dialog json and store it in Dialog singleton
	var filename = 'res://json/levels/' + level['dialog']
	var dialog_file = FileAccess.open(filename, FileAccess.READ)
	if dialog_file == null:
		print('Error: Failed to load ' + filename)
	var dialog_text = dialog_file.get_as_text()
	dialog_file.close()
	var json_data = JSON.parse_string(dialog_text)
	if json_data == null:
		print('Error: JSON error')
	Dialog.setDialog(json_data['dialog'])

func buildShip(level):
	if not level.has('ship'):
		return
	Globals.ship.reset()
	for ship_item in level['ship']:
		match ship_item:
			'GunsOff':
				Globals.ship.gun = GunsOff.new()
			'ShieldOff':
				Globals.ship.shield = ShieldOff.new()
			'RocketOff':
				Globals.ship.rocket = RocketOff.new()
			'Landed':
				Globals.ship.status.landed = true

# code to handle loading scenes

func loadScene(scene_path):
	ResourceLoader.load_threaded_request(scene_path)
	#loader = ResourceLoader.load_threaded_request(scene_path)
	#if loader == null:
	#	print('Error: New ResourceLoader instance is null')
	#	get_tree().quit()

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
	get_tree().change_scene_to_packed(scene)
