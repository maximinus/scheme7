extends Node2D
tool

signal next_life
signal reset_scene

var active = false

func _ready():
	hide()

func start():
	# reset some params
	$FadeAnimation/AudioStreamPlayer.volume_db = 0
	$StartPause.start()

func _on_Timer_timeout():
	if $Title.visible == true:
		$Title.hide()
	else:
		$Title.show()

func _process(delta):
	if active == false:
		return
	# did player press space bar?
	if Input.is_action_just_released('FireLaser'):
		$FadeAnimation.play('fade')
		active = false
		emit_signal('reset_scene')

func _on_StartPause_timeout():
	show()
	active = true
	$Timer.start()

func _on_AnimationPlayer_animation_finished(anim_name):
	$FadeAnimation/CanvasModulate.color = Color(1.0, 1.0, 1.0, 1.0)
	hide()
	emit_signal('next_life')
