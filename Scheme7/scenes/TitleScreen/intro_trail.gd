extends Node2D

var speed: float = 0.0
var size: float = 0.0

func _ready():
	pass

func _process(delta):
	if speed <= 0.0:
		return
	size += speed * delta
	$Trail.points[1].y = size 
	$Trail.material.set_shader_parameter('size', size)
	$Ball.position.y = size

func reset(new_color, new_speed):
	size = 0.0
	setBallColor(new_color)
	setSpeed(new_speed)

func setBallColor(color):
	$Ball.material.set_shader_parameter('ball_color', color)
	$Trail.material.set_shader_parameter('trail_color', color)

func setSpeed(new_speed):
	speed = new_speed
