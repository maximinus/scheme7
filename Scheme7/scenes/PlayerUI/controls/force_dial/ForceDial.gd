extends Node2D


func _ready():
	pass


func getBarSize(speed):
	speed = abs(speed)
	speed = min(speed, 100) / 100
	# 30 is ok, 20 is better
	# below 5, ignore
	var size = (log(speed + 1.1) / log(10)) / 1.5
	size *= 100
	return size
	

func _process(_delta):
	# get the angle from the vector
	if Globals.last_force.y == 0.0:
		$DialCentre.rotation = 0.0 - (PI / 2)
	else:
		$DialCentre.rotation = atan2(-Globals.last_force.y, -Globals.last_force.x) - (PI / 2)
	$XLine.points[1].x = -getBarSize(Globals.last_force.x)
	$YLine.points[1].y = getBarSize(Globals.last_force.y)
