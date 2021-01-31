extends Node2D

const EXPLOSION = preload('res://scenes/ExplosionDebris/ExplosionDebris.tscn')
const LASER = preload('res://scenes/LevelObjects/Laser/Laser.tscn')
const PLAYER = preload('res://scenes/Player/Player.tscn')
const DEAD_PLAYER = preload('res://scenes/Player/PlayerDeath/PlayerDeath.tscn')

var player_start
var dead_player

func _ready():
	# remember for the next life
	player_start = $Player.position
	$Player.hide()
	$Player.connect('player_collision', self, 'playerCollision')
	$Player.connect('laser_fire', self, 'playerLaser')
	$Player.connect('player_dead', self, 'playerDead')
	$UILayer/DeathNotice.connect('next_life', self, 'nextLife')
	$UILayer/DeathNotice.connect('reset_scene', self, 'resetScene')
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
	var player_pos = $Player.position
	var player_rot = $Player.rotation
	var player_speed = $Player.velocity
	# hide the player
	$Player.hide()
	$Player.processing = false
	# instance the new scene
	dead_player = DEAD_PLAYER.instance()
	dead_player.position = player_pos
	dead_player.rotation = player_rot
	dead_player.linear_velocity = player_speed
	dead_player.setCamera()
	add_child_below_node($Lights, dead_player)
	$UILayer/DeathNotice.start()

func nextLife():
	# kill the playerdeath
	dead_player.queue_free()
	$Player.position = player_start
	spawnIn()

func spawnIn():
	# reset velocity
	$Player.hide()
	$Player.reset()
	$Player.processing = false
	$TeleportScene.show()
	$TeleportScene.setPosition($Player.position)
	$TeleportScene/Animation.play('Fade')
	$TeleportTimer.start()

func resetScene():
	# player wants a new life
	# fading of screen will start: kill the explosion sound
	dead_player.animate = false

func _on_TeleportTimer_timeout():
	$TeleportScene.hide()
	$Player.show()
	$Player.processing = true
