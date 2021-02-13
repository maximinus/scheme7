extends Node

enum Status {DRAWING, WAITING}

# characters per second
const SPEED = 30.0
	
var dialogs = []
var index = 0
var current_status = Status.DRAWING
	
func _ready():
	# next is static, then back here
	Scenes.addScene('res://scenes/SceneTransitions/Static/Static.tscn')
	Scenes.addScene('res://scenes/World.tscn')
	index = 0
	dialogs = Dialog.getDialog()
	displayDialog()

func _process(_delta):
	# was the enter key pressed?
	if Input.is_action_just_pressed('Enter'):
		# update status
		if current_status == Status.DRAWING:
			# stop tween, show text
			$Main/Margin/Text/Tween.stop_all()
			stopAnimation()
		else:
			# must be waiting
			index += 1
			if index == len(dialogs):
				sceneTransition()
			else:
				displayDialog()

func sceneTransition():
	$Glitch.material.set_shader_param('active', true)
	$Timer.start()

func displayDialog():
	$Next.hide()
	var new_dialog = dialogs[index]
	$Speaker/Margin/Text.text = new_dialog.speaker
	$Main/Margin/Text.percent_visible = 0.0
	$Main/Margin/Text.text = new_dialog.text
	# animate the text appearing
	current_status = Status.DRAWING
	var time = len(new_dialog.text) / SPEED
	$Main/Margin/Text/Tween.interpolate_property($Main/Margin/Text,
		'percent_visible', 0.0, 1.0, time,
		Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Main/Margin/Text/Tween.start()
	$TextNoise.play()

func stopAnimation():
	$TextNoise.stop()
	$Main/Margin/Text.percent_visible = 1.0
	$Next.show()
	current_status = Status.WAITING	

func _on_Tween_tween_completed(_object, _key):
	stopAnimation()

func _on_Timer_timeout():
	var scene = Scenes.getNextScene()
	get_tree().change_scene(scene)
