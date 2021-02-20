extends Node2D

var waiting: bool

func _ready() -> void:
	$Logo.hide()
	$Logo.material.set_shader_param('radius', 0.0)
	$Instructions.hide()
	waiting = false

func playAnim():
	# do your stuff, but not instantly
	$StartTimer.start()

func _on_Reveal_animation_finished(_anim_name) -> void:
	$Instructions/Flash.play('flash')
	# we are done, now we wait for input
	waiting = true

func _process(delta):
	# are we waiting for input?
	if waiting == false:
		return
	# did the player ask to move on?
	if Input.is_action_just_pressed('Enter'):
		var scene = Scenes.getNextScene()
		get_tree().change_scene(scene)

func _on_StartTimer_timeout():
	# we waited a little before starting, but now we start
	$Logo.show()
	$Logo/Reveal.play('fadeIn')
	$Logo/Whoosh.play()
