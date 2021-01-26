extends RigidBody2D

const OFFSET = 14
const LASER_SPEED = 500

func _ready():
	pass

func addMotion():
	# add offset based on current position
	var x_force = sin(rotation) * LASER_SPEED
	var y_force = cos(rotation) * -LASER_SPEED
	apply_impulse(Vector2(0, 0), Vector2(x_force, y_force))
	$LaserSFX.play()

func _on_Laser_body_entered(body):
	if body.is_in_group('breakable'):
		body.collide(Vector2(0, 0))
	if body.is_in_group('door'):
		body.doorHit()
	queue_free()
