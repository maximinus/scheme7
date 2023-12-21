extends Node

enum Status {DRAWING, WAITING}

const CHARACTERS_PER_SECOND = 100.0

var dialogs = [Dialog.SingleDialog.new('Error', 'No dialog set')]
var index = 0
var current_status = Status.DRAWING
var timer_on = false
var text_tween: Tween

func _ready():
	index = 0
	# this is animating the arrow
	dialogs = Dialog.next_dialog
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
			stopAnimation()
		else:
			# must be waiting
			index += 1
			if index == len(dialogs):
				# end of the dialog
				sceneTransition()
			else:
				# show next dialog
				$Selected.play()
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
	var time = len(new_dialog.text) / CHARACTERS_PER_SECOND
	# unlike Godot 3, need to recreate the tween for this
	text_tween = get_tree().create_tween()
	text_tween.tween_property($Main/Margin/Text, 'visible_ratio', 1.0, time)
	text_tween.tween_callback(stopAnimation)
	$TextNoise.play()

func stopAnimation():
	# probably stopped anyway, but early enter can also force this
	text_tween.stop()
	$TextNoise.stop()
	$Main/Margin/Text.visible_ratio = 1.0
	$Next.show()
	current_status = Status.WAITING

func _on_Timer_timeout():
	# we are done, move on to the next scene
	Scenes.moveToNextScene()
