extends Node2D

func _ready():
	pass

func _process(delta):
	var electric_pos = convertPos(Globals.shield.getShield())
	var structure_pos = convertPos(Globals.shield.getStruct())
	var internals_pos = convertPos(Globals.shield.getInternals())
	
	# now we have the pixel sizes
	$ElectricShield/Indicator.offset.x = electric_pos
	$Structure/Indicator.offset.x = structure_pos
	$Internals/Indicator.offset.x = internals_pos

func convertPos(pos):
	# we have to serve from the right
	pos = 1.0 - pos
	return pos * 347.0
