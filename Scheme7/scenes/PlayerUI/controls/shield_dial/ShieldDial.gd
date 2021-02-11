extends Node2D

const BAR_WIDTH = 347.0
const BAR_HEIGHT = 3

var shield

func _ready():
	shield = Globals.ship.shield

func _process(delta):
	var electric_pos = convertPos(shield.getShield())
	var structure_pos = convertPos(shield.getStruct())
	var internals_pos = convertPos(shield.getInternals())
	
	# now we have the pixel sizes
	$ElectricShield/Indicator.offset.x = BAR_WIDTH - electric_pos
	$Structure/Indicator.offset.x = BAR_WIDTH - structure_pos
	$Internals/Indicator.offset.x = BAR_WIDTH - internals_pos
	
	$ElectricShield/ThickLine.region_rect.end.x = electric_pos
	$ElectricShield/ThickLine.offset.x = BAR_WIDTH - electric_pos
	
	$Structure/ThickLine.region_rect.end.x = structure_pos
	$Structure/ThickLine.offset.x = BAR_WIDTH - structure_pos
	
	$Internals/ThickLine.region_rect.end.x = internals_pos
	$Internals/ThickLine.offset.x = BAR_WIDTH - internals_pos

func convertPos(pos):
	return pos * BAR_WIDTH
