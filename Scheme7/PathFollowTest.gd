extends Node2D

const SPEED = 150.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	$Path2D/PathFollow2D.offset += SPEED * delta
