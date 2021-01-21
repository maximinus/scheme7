extends KinematicBody2D

const ROTATION_SPEED = 120.0
const GRAVITY_VECTOR = Vector2(0, 0.3)
const TAKEOFF_INJECTION = Vector2(0, -20.0)
const ROCKET_FORCE = 1.6
const BOUNCE = 0.5
const SPIN_BRAKING = 0.1
const LANDING_MAX_ROTATION = 10.0
const LANDING_TURN_SPEED = 20.0
const LANDING_X_SLOWDOWN = 1.5
const SHIP_MASS = 5.0

const FULLBEAM_ENERGY = 2.0
const LIGHT_ENERGY = 1.0

enum LIGHT_STATUS { Normal, Circle, Off }

signal player_collision
signal player_landed

# sum of forces acting on the ship
var velocity = Vector2(0, 0)
var firing_rocket = false
# turned by hitting something
var turning = 0
var landing = false
var landed = false
var takeoff = false
var light_status = LIGHT_STATUS.Normal

func _ready():
	Globals.battery.lights = true
	Globals.battery.fullbeam = false

func _process(delta):
	# check rocket functions before movement
	checkLights()

	if Input.is_action_pressed('Thrust'):
		landing = false
		if landed == true:
			landed = false
			takeoff = true
		flameOn(delta)
	else:
		flameOff(delta)
	
	if landing == true or landed == true:
		return;
	
	if Input.is_action_pressed('LeftTurn'):
		rotation_degrees -= ROTATION_SPEED * delta
	if Input.is_action_pressed('RightTurn'):
		rotation_degrees += ROTATION_SPEED * delta
	
	if turning != 0:
		rotation_degrees += turning
		if turning < 0:
			turning += SPIN_BRAKING
		else:
			turning -= SPIN_BRAKING
		if abs(turning) < SPIN_BRAKING:
			turning = 0
	
	if rotation_degrees < 0.0:
		rotation_degrees += 360.0
	if rotation_degrees > 360.0:
		rotation_degrees -= 360.0

func checkLights():
	# no charge? turn off the lights and ignore everything else
	if Globals.battery.charge <= 0.0:
		$LHNormal.visible = false
		$LCNormal.visible = false
		light_status == LIGHT_STATUS.Off
		Globals.battery.lights = false
		Globals.battery.fullbeam = false
		return
	
	if Input.is_action_just_pressed('Lights'):
		if light_status == LIGHT_STATUS.Normal:
			# to circle
			$LHNormal.visible = false
			$LCNormal.visible = true
			light_status = LIGHT_STATUS.Circle
			Globals.battery.lights = true
		elif light_status == LIGHT_STATUS.Circle:
			# all off
			$LHNormal.visible = false
			$LCNormal.visible = false
			Globals.battery.lights = false
			light_status = LIGHT_STATUS.Off
		else:
			# all off, to normal
			$LHNormal.visible = true
			$LCNormal.visible = false
			Globals.battery.lights = true
			light_status = LIGHT_STATUS.Normal
	
	if Input.is_action_just_pressed('FullBeam'):
		# if lights are off, ignore
		if light_status == LIGHT_STATUS.Off:
			return
		if Globals.battery.fullbeam == false:
			$LCNormal.energy = FULLBEAM_ENERGY
			$LHNormal.energy = FULLBEAM_ENERGY
			Globals.battery.fullbeam = true
		else:
			$LCNormal.energy = LIGHT_ENERGY
			$LHNormal.energy = LIGHT_ENERGY
			Globals.battery.fullbeam = false

func processLanding(delta):
	# we are trying to land
	# the rocket is off, and we are ignoring left right presses.
	# In short, we want to land very quickly
	# centre the rotation as much as possible
	if rotation_degrees != 0.0:
		if rotation_degrees > 0:
			rotation_degrees -= LANDING_TURN_SPEED * delta
		else:
			rotation_degrees += LANDING_TURN_SPEED * delta
		if abs(rotation_degrees) < 0.1:
			rotation_degrees = 0.0	
	
	# take the current velocity and reduce the x portion
	var xspeed = velocity.x
	if xspeed != 0:
		xspeed /= LANDING_X_SLOWDOWN
		if abs(xspeed) < 0.1:
			xspeed = 0.0
	velocity.x = xspeed
	velocity += GRAVITY_VECTOR
	var collision = move_and_collide(velocity * delta)
	# did we collide?
	if collision == null:
		return
	# we did, are we actually landed?
	if velocity.x == 0.0 and rotation_degrees == 0.0:
		landed = true
		turning = 0.0
		emit_signal('player_landed', position)

func _physics_process(delta):
	if landed == true:
		return
	
	if landing == true:
		processLanding(delta)
		return
	
	# apply gravity and move
	# don't apply on takeoff
	if takeoff == false:
		velocity += GRAVITY_VECTOR
	if firing_rocket == true:
		velocity += getForceVector()
	if takeoff == true:
		velocity += TAKEOFF_INJECTION
	updateCameraZoom()
	move_and_slide(velocity, Vector2(0, 0), false, 4, 0.785398, false)
	
	# push all the bodies
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group('Bodies'):
			collision.collider.apply_central_impulse(-collision.normal * velocity.length() * SHIP_MASS)
	
	Globals.last_force = velocity
	if get_slide_count() > 0:
		var result = get_slide_collision(0)
		# handle landing seperately
		if checkLanding(result.normal) == true:
			return
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
	takeoff = false

func checkLanding(normal):
	# if contact is slow, and going down, then we may be landing
	var speed = sqrt(pow(abs(Globals.last_force.y), 2) + pow(abs(Globals.last_force.x), 2))
	if speed > 30:
		# not landing
		return
	# the current movement needs to be increasing y
	if velocity.y <= 0:
		# another direction
		return
	# and x cannot be larger
	if abs(velocity.x) > abs(velocity.y):
		return
	# we need to be more or less upright, so get the current rotation and compare
	var current_rotation = rotation_degrees
	if current_rotation < -LANDING_MAX_ROTATION or current_rotation > LANDING_MAX_ROTATION:
		# not landing, too much angle
		return
	# finally, we are landing
	landing = true
	return true

func addTurning(normal):
	var angle_rad = atan2(normal.y, normal.x)
	if angle_rad < 0:
		angle_rad = (2 * PI) + angle_rad
	angle_rad = ((360 / (2 * PI)) * angle_rad) - 90
	if angle_rad < 0.0:
		angle_rad += 360.0
	var ship_angle = (atan2(Globals.last_force.y, Globals.last_force.x)) + (PI / 2)
	ship_angle = (360 / (2 * PI)) * ship_angle
	if ship_angle < 0:
		ship_angle += 360.0
	# calculate the difference
	var difference = ship_angle - angle_rad
	if difference > 0:
		difference = max(difference, 10)
	else:
		difference = min(difference, -10)
	# adjust by speed
	var speed = sqrt(pow(abs(Globals.last_force.y), 2) + pow(abs(Globals.last_force.x), 2))
	speed = min(speed, 200) / 5
	turning = (difference / (44 - speed))
	if turning > 0:
		turning = min(turning, 10)
	else:
		turning = max(turning, -10)

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
	# don't collide on first frame after takeoff
	if takeoff == true:
		return
	$CollisionSound.volume_db = (speed - 50) / 10.0
	$CollisionSound.play()
	emit_signal('player_collision', position)

func getForceVector():
	var x_force = sin(rotation) * ROCKET_FORCE
	var y_force = cos(rotation) * -ROCKET_FORCE
	return Vector2(x_force, y_force)

func flameOn(delta):
	firing_rocket = true
	$FlameLight.visible = true
	Globals.rocket.update(1.0, delta)
	$Flame/OuterParticle.emitting = true
	$Flame/InnerParticle.emitting = true
	if $RocketSound.playing == false:
		$RocketSound.play()

func flameOff(delta):
	firing_rocket = false
	$FlameLight.visible = false
	Globals.rocket.update(0.0, delta)
	$Flame/OuterParticle.emitting = false
	$Flame/InnerParticle.emitting = false
	$RocketSound.stop()
