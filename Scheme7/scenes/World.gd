extends Node2D

const EXPLOSION = preload('res://scenes/ExplosionDebris/ExplosionDebris.tscn')
const LASER = preload('res://scenes/LevelObjects/Laser/Laser.tscn')
const DEAD_PLAYER = preload('res://scenes/Player/PlayerDeath/PlayerDeath.tscn')

var player_start: Vector2
var dead_player
var lander_found: bool = false

func _ready() -> void:
	# remember for the next life
	player_start = $Player.position
	$Player.hide()
	$Player.connect('ship_collision', Callable(self, 'shipCollision'))
	$Player.connect('laser_fire', Callable(self, 'shipLaser'))
	$Player.connect('ship_dead', Callable(self, 'shipDead'))
	$Player.connect('ship_landedlanded', Callable(self, 'shipLanded'))
	$UILayer/LanderDataTransfer.connect('download_finished', Callable(self, 'downloaded'))
	$UILayer/DeathNotice.connect('next_life', Callable(self, 'nextLife'))
	$CanvasModulate.show()
	spawnIn()

func _process(_delta: float) -> void:
	# if we are thrusting, better hide and reset the download animation
	if $UILayer/LanderDataTransfer.visible == true:
		if $Player.status.landed == false:
			# we took off, so reset animation
			$UILayer/LanderDataTransfer.reset()

func downloaded() -> void:
	$UILayer/MissionObjectives.downloaded()

func shipCollision(position: Vector2) -> void:
	var new_node = EXPLOSION.instantiate()
	new_node.position = position
	add_child(new_node)

func shipLaser() -> void:
	var new_laser = LASER.instantiate()
	# match position and rotation
	new_laser.position = $Player/LaserStart.global_position
	new_laser.rotation = $Player.rotation
	new_laser.addMotion()
	new_laser.add_collision_exception_with($Player)
	add_sibling($Lights, new_laser)

func shipLanded() -> void:
	$UILayer/LanderDataTransfer.show()
	$UILayer/LanderDataTransfer.processing = true

func shipDead() -> void:
	# we can't pause
	$UILayer/PauseScreen.can_pause = false
	var player_pos: Vector2 = $Player.position
	var player_rot: float = $Player.rotation
	var player_speed: Vector2 = $Player.velocity
	# hide the player
	$Player.hide()
	$Player.processing = false
	# instance the new scene
	dead_player = DEAD_PLAYER.instantiate()
	dead_player.position = player_pos
	dead_player.rotation = player_rot
	dead_player.linear_velocity = player_speed
	dead_player.start()
	add_sibling($Lights, dead_player)
	$UILayer/DeathNotice.start()

func nextLife() -> void:
	# kill the playerdeath
	dead_player.queue_free()
	$Player.position = player_start
	spawnIn()
	# we can pause again
	$UILayer/PauseScreen.can_pause = true

func spawnIn() -> void:
	$Player.hide()
	$Player.reset()
	$Player.processing = false
	$UILayer/MissionObjectives.reset()
	$TeleportScene.show()
	$TeleportScene.setPosition($Player.position)
	$TeleportScene/Animation.play('Teleport')
	$TeleportTimer.start()

func _on_TeleportTimer_timeout() -> void:
	$TeleportScene.hide()
	$Player.show()
	$Player.processing = true
