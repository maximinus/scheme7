extends Node2D

func _ready():
	pass # Replace with function body.

func setPosition(new_pos):
	$Animation/Image.offset = new_pos
	$Animation/PlayerImage.offset = new_pos

func _on_Animation_animation_finished(anim_name):
	queue_free()
