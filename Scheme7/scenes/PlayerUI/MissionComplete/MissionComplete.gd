extends Node2D

var waiting: bool

func _ready() -> void:
	$Logo.hide()
	$Logo.material.set_shader_param('radius', 0.0)
	$Instructions.hide()
	waiting = false

func playAnim():
	$StartTimer.start()

func _on_Reveal_animation_finished(_anim_name) -> void:
	$Instructions/Flash.play('flash')
	waiting = true

func _process(delta):
	if waiting == false:
		return
	if Input.is_action_just_pressed('Enter'):
		print('End scene')

func _on_StartTimer_timeout():
	$Logo.show()
	$Logo/Reveal.play('fadeIn')
	$Logo/Whoosh.play()
