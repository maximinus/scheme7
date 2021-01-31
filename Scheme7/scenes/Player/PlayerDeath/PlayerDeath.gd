extends Node2D
tool

var explosions = []

func _ready():
	_on_Explosion1_animation_finished()
	_on_Explosion2_animation_finished()
	_on_Explosion3_animation_finished()

func _process(delta):
	pass

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
	$Explosion1.offset = getRandomPoint()
	$Explosion1.rotation = rand_range(0.0, (2 * PI))

func _on_Explosion2_animation_finished():
	$Node2D.rotation = rand_range(0.0, (2 * PI))

func _on_Explosion3_animation_finished():
	$Explosion3.offset = getRandomPoint()
	$Explosion3.rotation = rand_range(0.0, (2 * PI))
