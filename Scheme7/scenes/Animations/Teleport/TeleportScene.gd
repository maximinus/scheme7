extends Node2D

func _ready():
	pass

func setPosition(new_pos: Vector2) -> void:
	position = new_pos
	$Animation/Teleport.position = new_pos
	$Animation/FakePlayer.position = new_pos
	$Animation/FakePlayer.show()
	$Animation/Teleport.show()
	$Animation.play('Teleport')
	$SFX.play()

func _on_SFX_finished() -> void:
	$Animation/Teleport.hide()

func _on_Animation_animation_finished(anim_name: String) -> void:
	$Animation/Teleport.hide()
	$Animation/FakePlayer.hide()
