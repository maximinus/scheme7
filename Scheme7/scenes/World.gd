extends Node2D

const EXPLOSION = preload('res://scenes/ExplosionDebris/ExplosionDebris.tscn')
const LASER = preload('res://scenes/LevelObjects/Laser/Laser.tscn')

func _ready():
	$Player.hide()
	$Player.connect('player_collision', self, 'playerCollision')
	$Player.connect('laser_fire', self, 'playerLaser')
	$Player.connect('player_dead', self, 'playerDead')
	$CanvasModulate.show()
	spawnIn()

func playerCollision(position):
	var new_node = EXPLOSION.instance()
	new_node.position = position
	add_child(new_node)

func playerLaser():
	var new_laser = LASER.instance()
	# match position and rotation
	new_laser.position = $Player/LaserStart.global_position
	new_laser.rotation = $Player.rotation
	new_laser.addMotion()
	new_laser.add_collision_exception_with($Player)
	add_child_below_node($Lights, new_laser)

func playerDead():
	pass

func spawnIn():
	$TeleportScene.setPosition($Player.position)
	$TeleportScene/Animation.play('Fade')

func _on_TeleportTimer_timeout():
	$Player.show()
	$Player.processing = true
