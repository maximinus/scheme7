extends Node2D

func _ready():
	$LargeParticles.emitting = true
	$SmallParticles.emitting = true

func _on_Timer_timeout():
	queue_free()
