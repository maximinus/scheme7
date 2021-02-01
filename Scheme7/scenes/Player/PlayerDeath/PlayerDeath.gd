extends Node2D

const MAX_EXPLOSIONS = 25

var active = false
var explosions = 0

func _ready():
	pass

func start():
	$Camera2D.current = true
	active = true
	$Explosion1.play('explode')
	$Explosion3.play('explode')
	$Node2D/Explosion2.play('explode')
	explosions = 0

func getRandomPoint():
	# find a point between the 2 gradiants
	while(true):
		var xpos = rand_range(0.0, 0.5)
		var ypos = rand_range(0.0, 1.0)
		var gradiant = ypos / xpos
		if(gradiant > 2.0):
			# adjust and continue
			xpos = 0.5 - xpos
			ypos = 1.0 - ypos
			gradiant = ypos / xpos
		if(gradiant > 0.4):
			ypos = ypos - 0.5
			if randf() > 0.5:
				xpos = 0.5 - xpos
			return Vector2(xpos, ypos) * 48.0

func addExplosion():
	if explosions >  MAX_EXPLOSIONS:
		# end all animations
		return false
	explosions += 1
	return true

func _on_Explosion1_animation_finished():
	if addExplosion() == false:
		return
	$Explosion1.offset = getRandomPoint()
	$Explosion1.rotation = rand_range(0.0, (2 * PI))
	$Explosion1.frame = 0
	$Explosion1.play()
	$SFXExp1.play()

func _on_Explosion2_animation_finished():
	if addExplosion() == false:
		return
	$Node2D.rotation = rand_range(0.0, (2 * PI))
	$Node2D/Explosion2.frame = 0
	$Node2D/Explosion2.play()
	$SFXExp2.play()

func _on_Explosion3_animation_finished():
	if addExplosion() == false:
		return
	$Explosion3.offset = getRandomPoint()
	$Explosion3.rotation = rand_range(0.0, (2 * PI))
	$Explosion3.frame = 0
	$Explosion3.play()
	$SFXExp3.play()

func _on_PlayerDeath_body_entered(body):
	if active == false:
		return
	# we hit something, so try to break it
	if body.is_in_group('breakable'):
		body.collide(50.0)
