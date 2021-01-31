extends Node2D

var active = false
var animate = true

func _ready():
	_on_Explosion1_animation_finished()
	_on_Explosion2_animation_finished()
	_on_Explosion3_animation_finished()

func _process(delta):
	pass

func setCamera():
	$Camera2D.current = true
	active = true

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

func _on_Explosion1_animation_finished():
	if animate == false:
		return
	$Explosion1.offset = getRandomPoint()
	$Explosion1.rotation = rand_range(0.0, (2 * PI))
	$SFXExp1.play()

func _on_Explosion2_animation_finished():
	if animate == false:
		return
	$Node2D.rotation = rand_range(0.0, (2 * PI))
	$SFXExp2.play()

func _on_Explosion3_animation_finished():
	if animate == false:
		return
	$Explosion3.offset = getRandomPoint()
	$Explosion3.rotation = rand_range(0.0, (2 * PI))
	$SFXExp3.play()

func _on_PlayerDeath_body_entered(body):
	if active == false:
		return
	# we hit something, so try to break it
	if body.is_in_group('breakable'):
		body.collide(50.0)
