extends Node2D

var explosion = preload('res://scenes/ExplosionDebris/ExplosionDebris.tscn')

func _ready():
	$Player.connect('player_collision', self, 'playerCollision')
	$CanvasModulate.show()

func playerCollision(position):
	var new_node = explosion.instance()
	new_node.position = position
	add_child(new_node)
