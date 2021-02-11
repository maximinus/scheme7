extends Node2D

const CHEVRON_WIDTH = 8

var last_temp
var rocket

func _ready():
	rocket = Globals.ship.rocket.temp
	last_temp = rocket.nozzle_temp

func _process(delta):
	if delta <= 0:
		return
	
	# the bar is for the nozzle temp
	# get range and convert
	var bar_length = (rocket.nozzle_temp / Globals.RocketTemperature.MAX_NOZZLE_TEMP) * 0.9
	bar_length = min(bar_length, 1.0)
	bar_length *= 48
	$HeatBarNozzle.region_rect.end.x = int(bar_length)

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

	# repeat for injection
	bar_length = (rocket.injection_temp / Globals.RocketTemperature.MAX_INJECTION_TEMP) * 0.9
	bar_length = min(bar_length, 1.0)
	bar_length *= 48	
	$HeatBarInjection.region_rect.end.x = int(bar_length)

	if bar_length < 15.0:
		$TempInjection/Green.visible = true
		$TempInjection/Amber.visible = false
		$TempInjection/Red.visible = false
	elif bar_length < 29.0:
		$TempInjection/Green.visible = false
		$TempInjection/Amber.visible = true
		$TempInjection/Red.visible = false
	elif bar_length < 43.0:
		$TempInjection/Green.visible = false
		$TempInjection/Amber.visible = false
		$TempInjection/Red.visible = true

	# finally, handle the chevrons
	var current_temp = rocket.nozzle_temp + rocket.injection_temp
	var temp_diff = (current_temp - last_temp) / delta
	# get the number first and worry about the sign later
	var chevrons = 0
	if abs(temp_diff) > 10:
		chevrons = 3
	elif abs(temp_diff) > 5.9:
		chevrons = 2
	elif abs(temp_diff) > 0:
		chevrons = 1
	
	if temp_diff < 0:
		chevrons = -chevrons
		
	if chevrons == 0:
		$ChevronRight.hide()
		$ChevronLeft.hide()
	elif chevrons > 0:
		$ChevronRight.show()
		$ChevronLeft.hide()
		$ChevronRight.region_rect.end.x = chevrons * CHEVRON_WIDTH
	else:
		# slighty harder, negative chevrons
		$ChevronRight.hide()
		$ChevronLeft.show()
		var width = -chevrons * CHEVRON_WIDTH
		$ChevronLeft.region_rect.end.x = width
		$ChevronLeft.offset.x = width - 25

	# remember for next time
	last_temp = current_temp
