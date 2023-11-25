extends Node

enum Status {DRAWING, WAITING}

# characters per second
const SPEED = 50.0
	
var dialogs = []
var index = 0
var current_status = Status.DRAWING
var timer_on = false
var text_tween: Tween
	
func _ready():
	text_tween = get_tree().create_tween()
	index = 0
	dialogs = Dialog.getDialog()
	$Next/Next/Margin/HBoxContainer/TextureRect/AnimationPlayer.play('show')
	displayDialog()

func _process(_delta):
	# if the timer is on, do nothing
	if timer_on == true:
		return
	# was the enter key pressed?
	if Input.is_action_just_pressed('Enter'):
		# update status
		if current_status == Status.DRAWING:
			# stop tween, show text
			text_tween.stop_all()
			# $Main/Margin/Text/Tween.stop_all()
			stopAnimation()
		else:
			# must be waiting
			index += 1
			if index == len(dialogs):
				sceneTransition()
			else:
				displayDialog()

func sceneTransition():
	timer_on = true
	$Glitch.material.set_shader_parameter('active', true)
	$Timer.start()

func displayDialog():
	$Next.hide()
	var new_dialog = dialogs[index]
	$Speaker/Margin/HBoxContainer/Text.text = new_dialog.speaker
	$Main/Margin/Text.visible_ratio = 0.0
	$Main/Margin/Text.text = new_dialog.text
	# animate the text appearing
	current_status = Status.DRAWING
	var time = len(new_dialog.text) / SPEED	
	text_tween.tween_property($Main/Margin/Text, 'visible_ratio', 1.0, time)
	text_tween.tween_callback(_on_Tween_tween_completed).set_delay(time)
	text_tween.play()
	$TextNoise.play()

func stopAnimation():
	$TextNoise.stop()
	$Main/Margin/Text.visible_ratio = 1.0
	$Next.show()
	current_status = Status.WAITING	

func _on_Tween_tween_completed(_object, _key):
	stopAnimation()

func _on_Timer_timeout():
	# we are done, move on to the next scene
	Scenes.moveToTransition()
