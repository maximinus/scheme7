extends CharacterBody2D

const ROTATION_SPEED: float = 120.0
const GRAVITY_VECTOR: Vector2 = Vector2(0, 1.0)
const BOUNCE_STRENGTH = 1.1
const TAKEOFF_INJECTION: Vector2 = Vector2(0, -20.0)
const BOUNCE: float = 0.5
const SPIN_BRAKING: float = 0.1
const LANDING_MAX_SPEED: float = 1.0
const LANDING_MAX_ROTATION: float = 10.0
const LANDING_X_SLOWDOWN: float = 1.5
const SHIP_MASS: float = 5.0
const SHIP_FEET_OFFSET: float = 24.0

const ELECTRIC_MOVE_FORCE: float = 50.0
const ELECTRIC_TURN_FORCE: float = 20.0

signal ship_collision
signal ship_landed
signal laser_fire
signal ship_dead

# sum of forces acting on the ship
var ship_velocity: Vector2 = Vector2(0, 0)

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
	ship_velocity = Vector2(0.0, 0.0)
	rotation = 0.0
	flameOff(0.0)
	turning = 0.0
	electric_meet_force = Vector2(0.0, 0.0)
	$Image.frame = 0
	ship.reset()

func _process(delta: float) -> void:
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

	# add thrust if thrusting
	if Input.is_action_pressed('Thrust') and ship.rocket.canFireRocket():
		# TODO: maybe "landed" only should be handled
		ship.status.landing = false
		if ship.status.landed == true:
			# no longer landed since we are thrusting
			ship.status.landed = false
			ship.status.takeoff = true
			# and zoom out
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
	
	# if being shocked, move randomly
	if ship.status.electrified == true:
		rotation += randf_range(-ELECTRIC_TURN_FORCE, ELECTRIC_TURN_FORCE) * delta
	
	if turning != 0:
		rotation_degrees += turning
		if turning < 0.0:
			turning += SPIN_BRAKING
		else:
			turning -= SPIN_BRAKING
		# if below a fixed value, reduce to zero
		# (otherwise it will oscillate around zero)
		if abs(turning) < SPIN_BRAKING:
			turning = 0.0
	
	# keep rotation around -360 to +360
	rotation_degrees = fmod(rotation_degrees, 360.0)

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
		$LightSwitch.play()
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

func getElectricForce() -> Vector2:
	var electric_velocity = Vector2(0.0, 0.0)
	if ship.status.electrified == false:
		return electric_velocity
	if electric_meet_force.x > 0:
		electric_velocity.x -= randf_range(0, ELECTRIC_MOVE_FORCE)
	else:
		electric_velocity.x += randf_range(0, ELECTRIC_MOVE_FORCE)
	if electric_meet_force.y > 0:
		electric_velocity.y -= randf_range(0, ELECTRIC_MOVE_FORCE)
	else:
		electric_velocity.y += randf_range(0, ELECTRIC_MOVE_FORCE)
	return electric_velocity

func updateCollisionObject(item_collider, normal):
	if item_collider.is_in_group('Bodies'):
		item_collider.apply_central_impulse(-normal * velocity.length() * SHIP_MASS)
	if item_collider.is_in_group('breakable'):
		# break and remove
		item_collider.collide(velocity.length())
	if item_collider.is_in_group('door'):
		item_collider.doorHit()

func _physics_process(delta) -> void:
	if ship.status.landed == true or processing == false:
		return
		
	# apply all forces and move
	var frame_velocity = GRAVITY_VECTOR
	if ship.rocket.firing_rocket == true:
		frame_velocity += ship.rocket.getForceVector(rotation)
	frame_velocity += getElectricForce()
	velocity += frame_velocity * delta
	var collision = move_and_collide(velocity)
	
	if collision == null:
		return
	# collision - maybe we are landing?
	if isLanding() == true:
		landShip()
		ship.status.landed = true
		ship_velocity = Vector2(0.0, 0.0)
	
	#if collision.collider.is_in_group('lander'):
	#	emit_signal('ship_landed')
	#	zoom_target = 0.6
	#	zoom_speed = -0.4
	
	# we force the player back with a force proportional to the speed
	# it hit the wall with, in the opposite direction
	var normal = collision.get_normal()
	var new_force = velocity.dot(normal) * normal.rotated(PI)
	new_force *= BOUNCE_STRENGTH
	move_and_collide(new_force)
	
	# still alive?
	if ship.shield.update(velocity, collision.get_collider_velocity()) == true:
		flameOff(delta)
		$RocketSound.stop()
		$ElectricCollision.stop()
		emit_signal('ship_dead')
	velocity += new_force
	updateCollisionObject(collision.get_collider(), normal)

func isLanding() -> bool:
	# the conditions for landing are
	# no need to check casts as we have just collided
	# the speed must be low
	if velocity.length() > LANDING_MAX_SPEED:
		return false
	# and mainly downwards
	if velocity.y < 0:
		return false
	if velocity.y < (velocity.x / 2.0):
		return false
	# the ship must be pointing upwards
	if abs(rotation_degrees) > LANDING_MAX_ROTATION:
		return false
	return true

func landShip():
	# we know we are in the right place, let's just correct ourselves a little
	var left_pos = $LeftWing.get_collision_point() - global_position
	var right_pos = $RightWing.get_collision_point() - global_position
	left_pos = left_pos.rotated(-rotation)
	right_pos = right_pos.rotated(-rotation)
	var max_distance = max(left_pos.y, right_pos.y)
	max_distance -= SHIP_FEET_OFFSET
	rotation = 0.0
	position.y += max_distance

func updateCameraZoom() -> void:
	# TODO: zoom the camera based on the ship velocity
	pass
	
func collidePlayer(pos, speed) -> void:
	# player has hit something
	# speed ranges from 0 - 50
	# don't collide on first frame after takeoff
	if ship.status.takeoff == true:
		return
	$CollisionSound.volume_db = (speed - 50) / 10.0
	$CollisionSound.play()
	emit_signal('ship_collision', pos)

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
