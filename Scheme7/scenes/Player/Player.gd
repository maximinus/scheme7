extends KinematicBody2D

const ROTATION_SPEED = 120.0
const GRAVITY_VECTOR = Vector2(0, 5.0)
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

const ELECTRIC_MOVE_FORCE = 50.0
const ELECTRIC_TURN_FORCE = 20.0

enum LIGHT_STATUS { Normal, Circle, Off }

signal player_collision
signal player_landed
signal laser_fire
signal player_dead

# sum of forces acting on the ship
var velocity = Vector2(0, 0)
var firing_rocket = false
# turned by hitting something
var turning = 0
var landing = false
var landed = false
var takeoff = false
var processing = false
var light_status = LIGHT_STATUS.Off
var electrified = false
var electric_meet_force = Vector2(0.0, 0.0)

var zoom_target = 1.1
var zoom_speed = 0.2
var player

func _ready():
	randomize()
	player = Globals.player
	player.battery.lights = false
	player.battery.fullbeam = false

func reset():
	velocity = Vector2(0.0, 0.0)
	rotation = 0.0
	firing_rocket = false
	flameOff(0.0)
	turning = 0
	landing = false
	landed = false
	takeoff = false
	light_status = LIGHT_STATUS.Off
	electrified = false
	electric_meet_force = Vector2(0.0, 0.0)
	$Image.frame = 0
	player.reset()

func _process(delta):
	if processing == false:
		return
	# check rocket functions before movement
	checkLights()
	checkLaser()
	zoomCamera(delta)
	
	# update sprite damage
	$Image.frame = player.shield.getDamageFrame()

	if Input.is_action_pressed('Thrust') and player.fuel.haveFuel():
		landing = false
		if landed == true:
			landed = false
			takeoff = true
			zoom_target = 1.1
			zoom_speed = 0.3
		flameOn(delta)
	else:
		flameOff(delta)
	
	if landing == true or landed == true:
		return
	
	if Input.is_action_pressed('LeftTurn'):
		rotation_degrees -= ROTATION_SPEED * delta
	if Input.is_action_pressed('RightTurn'):
		rotation_degrees += ROTATION_SPEED * delta
	
	if electrified == true:
		rotation += rand_range(-ELECTRIC_TURN_FORCE, ELECTRIC_TURN_FORCE) * delta
	
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

func zoomCamera(delta):
	if zoom_speed == 0.0:
		return
	var zoom_amount = zoom_speed * delta
	$Camera2D.zoom += Vector2(zoom_amount, zoom_amount)
	if zoom_speed > 0.0:
		# we are adding to the zoom, so if the zoom is over the target
		# then we are done
		if $Camera2D.zoom.x > zoom_target:
			$Camera2D.zoom = Vector2(zoom_target, zoom_target)
			zoom_speed = 0.0
		return
	# zoom_speed is negative, camera is zooming towards
	if $Camera2D.zoom.x < zoom_target:
		$Camera2D.zoom = Vector2(zoom_target, zoom_target)
		zoom_speed = 0.0

func checkLaser():
	if Input.is_action_just_pressed('FireLaser'):
		emit_signal('laser_fire')

func checkLights():
	# no charge? turn off the lights and ignore everything else
	if player.battery.charge <= 0.0:
		$LHNormal.visible = false
		$LCNormal.visible = false
		light_status = LIGHT_STATUS.Off
		player.battery.lights = false
		player.battery.fullbeam = false
		return
	
	if Input.is_action_just_pressed('Lights'):
		if light_status == LIGHT_STATUS.Normal:
			# to circle
			$LHNormal.visible = false
			$LCNormal.visible = true
			light_status = LIGHT_STATUS.Circle
			player.battery.lights = true
		elif light_status == LIGHT_STATUS.Circle:
			# all off
			$LHNormal.visible = false
			$LCNormal.visible = false
			player.battery.lights = false
			light_status = LIGHT_STATUS.Off
		else:
			# all off, to normal
			$LHNormal.visible = true
			$LCNormal.visible = false
			player.battery.lights = true
			light_status = LIGHT_STATUS.Normal
	
	if Input.is_action_just_pressed('FullBeam'):
		# if lights are off, ignore
		if light_status == LIGHT_STATUS.Off:
			return
		if player.battery.fullbeam == false:
			$LCNormal.energy = FULLBEAM_ENERGY
			$LHNormal.energy = FULLBEAM_ENERGY
			player.battery.fullbeam = true
		else:
			$LCNormal.energy = LIGHT_ENERGY
			$LHNormal.energy = LIGHT_ENERGY
			player.battery.fullbeam = false

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
	velocity += GRAVITY_VECTOR * delta
	var collision = move_and_collide(velocity * delta)
	# did we collide?
	if collision == null:
		return
	# we did, are we actually landed?
	if velocity.x == 0.0 and rotation_degrees == 0.0:
		landed = true
		turning = 0.0
		# what did we land on?
		if collision.collider.is_in_group('lander'):
			emit_signal('player_landed')
			zoom_target = 0.6
			zoom_speed = -0.4

func _physics_process(delta):
	if landed == true or processing == false:
		return
	
	if landing == true:
		processLanding(delta)
		return
	
	# apply gravity and move
	# don't apply on takeoff
	if takeoff == false:
		velocity += GRAVITY_VECTOR * delta
	if firing_rocket == true:
		velocity += getForceVector()
	if takeoff == true:
		velocity += TAKEOFF_INJECTION
	
	if electrified == true:
		# force is opposite to current movement
		if electric_meet_force.x > 0:
			velocity.x -= rand_range(0, ELECTRIC_MOVE_FORCE)
		else:
			velocity.x += rand_range(0, ELECTRIC_MOVE_FORCE)
		if electric_meet_force.y > 0:
			velocity.y -= rand_range(0, ELECTRIC_MOVE_FORCE)
		else:
			velocity.y += rand_range(0, ELECTRIC_MOVE_FORCE)

	updateCameraZoom()
	move_and_slide(velocity, Vector2(0, 0), false, 4, 0.785398, false)
	
	# push all the bodies
	var dead = false
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		dead = player.shield.update(velocity, collision.collider_velocity)
		if collision.collider.is_in_group('Bodies'):
			collision.collider.apply_central_impulse(-collision.normal * velocity.length() * SHIP_MASS)
		if collision.collider.is_in_group('breakable'):
			# break and remove
			collision.collider.collide(velocity.length())
		if collision.collider.is_in_group('door'):
			collision.collider.doorHit()

	if dead == true:
		# we are dead, raise the signal and finish
		# kill all sounds and animations
		flameOff(0.1)
		$RocketSound.stop()
		$ElectricCollision.stop()
		emit_signal('player_dead')
		return

	player.last_force = velocity
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
	var speed = sqrt(pow(abs(player.last_force.y), 2) + pow(abs(player.last_force.x), 2))
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
	var ship_angle = (atan2(player.last_force.y, player.last_force.x)) + (PI / 2)
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
	var speed = sqrt(pow(abs(player.last_force.y), 2) + pow(abs(player.last_force.x), 2))
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
	player.rocket.update(1.0, delta)
	player.fuel.update(delta, true)
	$Flame/OuterParticle.emitting = true
	$Flame/InnerParticle.emitting = true
	if $RocketSound.playing == false:
		$RocketSound.play()

func flameOff(delta):
	firing_rocket = false
	$FlameLight.visible = false
	player.rocket.update(0.0, delta)
	player.fuel.update(delta, false)
	$Flame/OuterParticle.emitting = false
	$Flame/InnerParticle.emitting = false
	$RocketSound.stop()

func _on_ElectricBarrier_electric_contact_end():
	electrified = false
	if $ElectricCollision.playing == true:
		$ElectricCollision.stop()

func _on_ElectricBarrier_electric_contact_start():
	electrified = true
	electric_meet_force = velocity
	if $ElectricCollision.playing == false:
		$ElectricCollision.play()
