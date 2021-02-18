extends KinematicBody2D

const ROTATION_SPEED: float = 120.0
const GRAVITY_VECTOR: Vector2 = Vector2(0, 5.0)
const TAKEOFF_INJECTION: Vector2 = Vector2(0, -20.0)
const BOUNCE: float = 0.5
const SPIN_BRAKING: float = 0.1
const LANDING_MAX_ROTATION: float = 10.0
const LANDING_TURN_SPEED: float = 20.0
const LANDING_X_SLOWDOWN: float = 1.5
const SHIP_MASS: float = 5.0

const ELECTRIC_MOVE_FORCE: float = 50.0
const ELECTRIC_TURN_FORCE: float = 20.0

signal ship_collision
signal ship_landed
signal laser_fire
signal ship_dead

# sum of forces acting on the ship
var velocity: Vector2 = Vector2(0, 0)

# turned by hitting something
var turning: float = 0.0
#var landing: bool = false
#var landed: bool = false
#var takeoff: bool = false
#var electrified: bool = false
var processing: bool = false
var electric_meet_force: Vector2 = Vector2(0.0, 0.0)

var zoom_target: float = 1.1
var zoom_speed: float = 0.2
var ship

func _ready() -> void:
	randomize()
	ship = Globals.ship

func reset() -> void:
	velocity = Vector2(0.0, 0.0)
	rotation = 0.0
	flameOff(0.0)
	turning = 0.0
	electric_meet_force = Vector2(0.0, 0.0)
	$Image.frame = 0
	ship.reset()

func _process(delta: float) -> void:
	
	print(position)
	
	# update general access area
	ship.position = position
	if processing == false:
		return
	# check rocket functions before movement
	checkLights()
	checkLaser()
	zoomCamera(delta)
	
	# update sprite damage
	$Image.frame = ship.shield.getDamageFrame()

	if Input.is_action_pressed('Thrust') and ship.rocket.canFireRocket():
		ship.status.landing = false
		if ship.status.landed == true:
			ship.status.landed = false
			ship.status.takeoff = true
			zoom_target = 1.1
			zoom_speed = 0.3
		flameOn(delta)
	else:
		flameOff(delta)
	
	if ship.status.landing == true or ship.status.landed == true:
		return

	if ship.rocket.canTurn() == true:
		if Input.is_action_pressed('LeftTurn'):
			rotation_degrees -= ROTATION_SPEED * delta
		if Input.is_action_pressed('RightTurn'):
			rotation_degrees += ROTATION_SPEED * delta
	
	if ship.status.electrified == true:
		rotation += rand_range(-ELECTRIC_TURN_FORCE, ELECTRIC_TURN_FORCE) * delta
	
	if turning != 0:
		rotation_degrees += turning
		if turning < 0.0:
			turning += SPIN_BRAKING
		else:
			turning -= SPIN_BRAKING
		if abs(turning) < SPIN_BRAKING:
			turning = 0.0
	
	if rotation_degrees < 0.0:
		rotation_degrees += 360.0
	if rotation_degrees > 360.0:
		rotation_degrees -= 360.0

func zoomCamera(delta: float) -> void:
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

func checkLaser() -> void:
	if Input.is_action_just_pressed('FireLaser'):
		if ship.gun.canFire() == true:
			emit_signal('laser_fire')

func checkLights() -> void:
	# no charge? turn off the lights and ignore everything else
	if ship.battery.charge <= 0.0:
		$LHNormal.visible = false
		$LCNormal.visible = false
		ship.battery.lightsOff()
		return
	
	# ok, can do lights
	if Input.is_action_just_pressed('Lights'):
		var current_status = ship.battery.cycleLights()
		if current_status == BatteryCharge.LIGHT_STATUS.Normal:
			$LHNormal.visible = true
			$LCNormal.visible = false
		elif current_status == BatteryCharge.LIGHT_STATUS.Circle:
			$LHNormal.visible = false
			$LCNormal.visible = true
		else:
			# all off, to normal
			$LHNormal.visible = false
			$LCNormal.visible = false
	
	if Input.is_action_just_pressed('FullBeam'):
		# if lights are off, ignore
		if ship.battery.status == BatteryCharge.LIGHT_STATUS.Off:
			return
		var energy: float = ship.battery.getFullbeam()
		$LCNormal.energy = energy
		$LHNormal.energy = energy

func processLanding(delta: float):
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
	var xspeed: float = velocity.x
	if xspeed != 0:
		xspeed /= LANDING_X_SLOWDOWN
		if abs(xspeed) < 0.1:
			xspeed = 0.0
	velocity.x = xspeed	
	# add gravity and then move
	velocity += GRAVITY_VECTOR * delta
	var collision = move_and_collide(velocity * delta)
	# did we collide?
	if collision == null:
		return
	# we did, are we actually landed?
	if velocity.x == 0.0 and rotation_degrees == 0.0:
		ship.status.landed = true
		turning = 0.0
		# what did we land on?
		if collision.collider.is_in_group('lander'):
			emit_signal('ship_landed')
			zoom_target = 0.6
			zoom_speed = -0.4

func _physics_process(delta) -> void:
	if ship.status.landed == true or processing == false:
		return
	
	if ship.status.landing == true:
		processLanding(delta)
		return
	
	# apply gravity and move - don't apply on takeoff
	if ship.status.takeoff == false:
		velocity += GRAVITY_VECTOR * delta
	if ship.rocket.firing_rocket == true:
		velocity += ship.rocket.getForceVector(rotation)
	if ship.status.takeoff == true:
		velocity += TAKEOFF_INJECTION
	
	if ship.status.electrified == true:
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
		dead = ship.shield.update(velocity, collision.collider_velocity)
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
		flameOff(delta)
		$RocketSound.stop()
		$ElectricCollision.stop()
		emit_signal('ship_dead')
		return

	ship.last_force = velocity
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
	ship.status.takeoff = false

func checkLanding(_normal) -> void:
	# if contact is slow, and going down, then we may be landing
	var speed = ship.last_force.length()
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
	ship.status.landing = true

func addTurning(normal) -> void:
	var angle_rad: float = atan2(normal.y, normal.x)
	if angle_rad < 0.0:
		angle_rad = (2.0 * PI) + angle_rad
	angle_rad = ((360.0 / (2.0 * PI)) * angle_rad) - 90.0
	if angle_rad < 0.0:
		angle_rad += 360.0
	var ship_angle: float = (atan2(ship.last_force.y, ship.last_force.x)) + (PI / 2)
	ship_angle = (360.0 / (2.0 * PI)) * ship_angle
	if ship_angle < 0.0:
		ship_angle += 360.0
	# calculate the difference
	var difference: float = ship_angle - angle_rad
	if difference > 0.0:
		difference = max(difference, 10.0)
	else:
		difference = min(difference, -10.0)
	# adjust by speed
	var speed: float = ship.last_force.length()
	speed = min(speed, 200) / 5
	turning = (difference / (44.0 - speed))
	if turning > 0.0:
		turning = min(turning, 10.0)
	else:
		turning = max(turning, -10.0)

func updateCameraZoom() -> void:
	# TODO: zoom the camera based on the ship velocity
	pass
	
func collidePlayer(position, speed) -> void:
	# player has hit something
	# speed ranges from 0 - 50
	# don't collide on first frame after takeoff
	if ship.status.takeoff == true:
		return
	$CollisionSound.volume_db = (speed - 50) / 10.0
	$CollisionSound.play()
	emit_signal('ship_collision', position)

func flameOn(delta) -> void:
	$FlameLight.visible = true
	ship.rocket.update(delta, 1.0)
	$Flame/OuterParticle.emitting = true
	$Flame/InnerParticle.emitting = true
	if $RocketSound.playing == false:
		$RocketSound.play()

func flameOff(delta) -> void:
	$FlameLight.visible = false
	ship.rocket.update(delta, 0.0)
	$Flame/OuterParticle.emitting = false
	$Flame/InnerParticle.emitting = false
	$RocketSound.stop()

func _on_ElectricBarrier_electric_contact_end() -> void:
	ship.status.electrified = false
	if $ElectricCollision.playing == true:
		$ElectricCollision.stop()

func _on_ElectricBarrier_electric_contact_start() -> void:
	ship.status.electrified = true
	electric_meet_force = velocity
	if $ElectricCollision.playing == false:
		$ElectricCollision.play()
