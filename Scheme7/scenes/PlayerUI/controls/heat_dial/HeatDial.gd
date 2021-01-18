extends Node2D

const CHEVRON_WIDTH = 8

var max_temp
var last_temp

func _ready():
	max_temp = Globals.RocketTemperature.MAX_TEMP
	last_temp = Globals.rocket.nozzle_temp

func _process(delta):
	# the bar is for the nozzle temp
	# get range and convert
	var temp = Globals.rocket.nozzle_temp
	var bar_length = (Globals.rocket.nozzle_temp / max_temp) * 0.9
	bar_length = min(bar_length, 1.0)
	bar_length *= 48
	$HeatBar.region_rect.end.x = int(bar_length)

	if bar_length < 15.0:
		$TempNozzle/Green.visible = true
		$TempNozzle/Amber.visible = false
		$TempNozzle/Red.visible = false
	elif bar_length < 29.0:
		$TempNozzle/Green.visible = false
		$TempNozzle/Amber.visible = true
		$TempNozzle/Red.visible = false
	elif bar_length < 43.0:
		$TempNozzle/Green.visible = false
		$TempNozzle/Amber.visible = false
		$TempNozzle/Red.visible = true

	# finally, handle the chevrons
	var temp_diff = (temp - last_temp) / delta
	var chevrons = min(int(temp_diff / 3), 3)
	
	if chevrons == 0:
		$ChevronLeft.visible = false
		$ChevronRight.visible = false
	elif chevrons > 0:
		$ChevronRight.visible = true
		$ChevronLeft.visible = false
		$ChevronRight.region_rect.end.x = chevrons * CHEVRON_WIDTH
	else:
		# slighty harder
		$ChevronRight.visible = false
		$ChevronLeft.visible = true
		var width = -chevrons * CHEVRON_WIDTH
		$ChevronLeft.region_rect.end.x = width
		$ChevronLeft.offset.x = width - 25

	# remember for next time
	last_temp = Globals.rocket.nozzle_temp
