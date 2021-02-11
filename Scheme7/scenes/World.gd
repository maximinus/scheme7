extends Node2D

const EXPLOSION = preload('res://scenes/ExplosionDebris/ExplosionDebris.tscn')
const LASER = preload('res://scenes/LevelObjects/Laser/Laser.tscn')
const DEAD_PLAYER = preload('res://scenes/Player/PlayerDeath/PlayerDeath.tscn')

var player_start
var dead_player
var lander_found = false

func _ready():
	# remember for the next life
	player_start = $Player.position
	$Player.hide()
	$Player.connect('ship_collision', self, 'shipCollision')
	$Player.connect('laser_fire', self, 'shipLaser')
	$Player.connect('ship_dead', self, 'shipDead')
	$Player.connect('ship_landed', self, 'shipLanded')
	$UILayer/LanderDataTransfer.connect('download_finished', self, 'downloaded')
	$UILayer/DeathNotice.connect('next_life', self, 'nextLife')
	$CanvasModulate.show()
	spawnIn()

func _process(delta):
	# if we are thrusting, better hide and reset the download animation
	if $UILayer/LanderDataTransfer.visible == true:
		if $Player.landed == false:
			# we took off, so reset animation
			$UILayer/LanderDataTransfer.reset()

func downloaded():
	$UILayer/MissionObjectives.downloaded()

func shipCollision(position):
	var new_node = EXPLOSION.instance()
	new_node.position = position
	add_child(new_node)

func shipLaser():
	var new_laser = LASER.instance()
	# match position and rotation
	new_laser.position = $Player/LaserStart.global_position
	new_laser.rotation = $Player.rotation
	new_laser.addMotion()
	new_laser.add_collision_exception_with($Player)
	add_child_below_node($Lights, new_laser)

func shipLanded():
	$UILayer/LanderDataTransfer.show()
	$UILayer/LanderDataTransfer.processing = true

func shipDead():
	# we can't pause
	$UILayer/PauseScreen.can_pause = false
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
	dead_player.start()
	add_child_below_node($Lights, dead_player)
	$UILayer/DeathNotice.start()

func nextLife():
	# kill the playerdeath
	dead_player.queue_free()
	$Player.position = player_start
	spawnIn()
	# we can pause again
	$UILayer/PauseScreen.can_pause = true

func spawnIn():
	$Player.hide()
	$Player.reset()
	$Player.processing = false
	$UILayer/MissionObjectives.reset()
	$TeleportScene.show()
	$TeleportScene.setPosition($Player.position)
	$TeleportScene/Animation.play('Fade')
	$TeleportTimer.start()

func _on_TeleportTimer_timeout():
	$TeleportScene.hide()
	$Player.show()
	$Player.processing = true
