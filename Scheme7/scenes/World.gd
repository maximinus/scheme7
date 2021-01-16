extends Node2D

var explosion = preload('res://scenes/ExplosionDebris/ExplosionDebris.tscn')

func _ready():
	$Player.connect('player_collision', self, 'playerCollision')

func playerCollision(position):
	var new_node = explosion.instance()
	new_node.position = position
	add_child(new_node)

	# it's not the angle of the player, it's the angle of movement!
	$CanvasLayer/Test.rotation = (atan2(-Globals.last_force.y, Globals.last_force.x))
