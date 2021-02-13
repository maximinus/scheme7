tool
extends StaticBody2D

enum ORIENTATION { Up, Down, Left, Right }

export var cycle_length : float = 5.0
export var strength : float = 1.0
export var max_variation : float = 0.2
export(ORIENTATION) var direction = ORIENTATION.Up setget setDirection

var now : float = 0.0
var broken : bool = false


func _ready():
	pass

func _process(delta):
	now += delta / cycle_length
	if now > 1.0:
		now -= 1.0
	# now always between 0 and 1
	var offset = sin((2 * PI) * now)
	# offset between -1 and 1, fix
	offset *= max_variation
	offset += 1.0 - max_variation
	$Light2D.energy = offset * strength
	$Light2D.texture_scale = offset + (max_variation / 3.0)

func setDirection(direct):
	if direct == ORIENTATION.Up:
		rotation_degrees = 0.0
	elif direct == ORIENTATION.Right:
		rotation_degrees = 90.0
	elif direct == ORIENTATION.Down:
		rotation_degrees = 180.0
	else:
		rotation_degrees = 270.0
	direction = direct

func collide(_velocity):
	if broken == true:
		# already done
		return
	# hide everything
	$Sprite.hide()
	$Light2D.hide()
	$Remains.show()
	$CollisionShape2D.set_deferred('disabled', true)
	$CollisionShape2D2.set_deferred('disabled', true)
	# start the particles
	$Explosion/Debris2.emitting = true
	$Explosion/Debris3.emitting = true
	$Explosion/Debris4.emitting = true
	# start timer
	$DestroySFX.play()
	$Explosion/Timer.start()

func _on_Timer_timeout():
	$Explosion/Debris2.emitting = false
	$Explosion/Debris3.emitting = false
	$Explosion/Debris4.emitting = false
	$DestroySFX.stop()
