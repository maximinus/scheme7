extends KinematicBody2D

const ROTATION_SPEED = 120.0
const GRAVITY_VECTOR = Vector2(0, 0.3)
const ROCKET_FORCE = 1.2
const BOUNCE = 0.5

signal player_collision

# sum of forces acting on the ship
var velocity = Vector2(0, 0)
var firing_rocket = false
# turned by hitting something
var turning = 0

func _ready():
	pass

func _process(delta):
	# keys pressed?
	if Input.is_action_pressed('LeftTurn'):
		rotation_degrees -= ROTATION_SPEED * delta
	if Input.is_action_pressed('RightTurn'):
		rotation_degrees += ROTATION_SPEED * delta
		
	if rotation_degrees < 0.0:
		rotation_degrees += 360.0
	if rotation_degrees > 360.0:
		rotation_degrees -= 360.0
		
	if Input.is_action_pressed('Thrust'):
		flameOn()
	else:
		flameOff()

func _physics_process(_delta):
	# apply gravity and move
	velocity += GRAVITY_VECTOR
	if firing_rocket == true:
		velocity += getForceVector()
	updateCameraZoom()
	move_and_slide(velocity)
	Globals.last_force = velocity
	if get_slide_count() > 0:
		var result = get_slide_collision(0)
		if result != null:
			# do turning before calculating forces
			addTurning(result.normal)
			var collision_speed = 0
			if abs(result.normal.x) > 0:
				collision_speed += abs(velocity.x)
				velocity.x *= -BOUNCE
			if abs(result.normal.y) > 0:
				collision_speed += abs(velocity.y)
				velocity.y *= -BOUNCE
			var speed = min(collision_speed, 100)
			collidePlayer(result.position, speed)

func addTurning(normal):
	var angle_rad = atan2(normal.y, normal.x)
	if angle_rad < 0:
		angle_rad = (2 * PI) + angle_rad
	angle_rad = ((360 / (2 * PI)) * angle_rad) - 90
	if angle_rad < 0.0:
		angle_rad += 360.0

func updateCameraZoom():
	# zoom the camera based on the ship velocity
	var final_speed = sqrt(pow(abs(velocity.x), 2) + pow(abs(velocity.y), 2))
	if final_speed < 50:
		return
	# going fast, so set the zoom
	#var zoom_level = (final_speed - 50) + 50 / 50.0
	#$Camera2D.zoom = Vector2(zoom_level, zoom_level)
	
func collidePlayer(position, speed):
	# player has hit something
	# speed ranges from 0 - 50
	$CollisionSound.volume_db = (speed - 50) / 10.0
	$CollisionSound.play()
	emit_signal('player_collision', position)

func getForceVector():
	var x_force = sin(rotation) * ROCKET_FORCE
	var y_force = cos(rotation) * -ROCKET_FORCE
	return Vector2(x_force, y_force)

func flameOn():
	firing_rocket = true
	$Flame/OuterParticle.emitting = true
	$Flame/InnerParticle.emitting = true
	if $RocketSound.playing == false:
		$RocketSound.play()

func flameOff():
	firing_rocket = false
	$Flame/OuterParticle.emitting = false
	$Flame/InnerParticle.emitting = false
	$RocketSound.stop()
