extends Node2D

func _ready():
	pass

func setPosition(new_pos):
	position = new_pos
	$Animation/Sprite.position = new_pos
	$Animation/LineAnimation.position = new_pos
	$Animation/ColorRect.rect_position += new_pos
	$Animation.play('Teleport')
	$SFX.play()

func _on_SFX_finished():
	queue_free()

func _on_Animation_animation_finished(anim_name):
	$Animation/Sprite.hide()
