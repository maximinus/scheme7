extends Node2D

const SQUARES = 26
const BATTERY_PER_SQUARE = 1.0 / SQUARES
const DIAL_WIDTH = 335.0
const BLOCKS = 26
const BLOCK_WIDTH = 13
const BLOCK_OFFSET = 4

func _ready():
	pass

func _process(delta):
	Globals.battery.update(delta)
	var charge = Globals.battery.chargeLeft()
	var drain = Globals.battery.currentDrain()
	
	var pos = drain * DIAL_WIDTH
	$Indicator.position.x = pos
	$DrainLevelThick.region_rect.end.x = pos

	# how many blocks to show?
	var blocks = int(ceil(charge * BLOCKS))
	$BatteryLevel.region_rect.end.x = (blocks * BLOCK_WIDTH) + BLOCK_OFFSET
