extends Node2D

var paused = false

func _ready():
	$BlurFilter.hide()
	$Sprite.hide()

func _process(delta):
	if Input.is_action_just_pressed('Pause'):
		if paused == false:
			paused = true
			$BlurFilter.show()
			$Sprite.show()
			emit_signal('paused')
			get_tree().paused = true
		else:
			paused = false
			get_tree().paused = false
			$BlurFilter.hide()
			$Sprite.hide()
			emit_signal('unpaused')
