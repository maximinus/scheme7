extends Node

enum LIGHT_STATUS { Normal, Circle, Off }

class_name BatteryCharge

const LIGHT_COST = 5.0
const FULLBEAM_COST = 6.0
const MAX_DRAIN = 30.0
const MAX_CHARGE = 1000.0

var fullbeam = false
var status = LIGHT_STATUS.Off
var charge = MAX_CHARGE
var drain = 0
	
func _init():
	pass
	
func chargeLeft():
	# returned as a float from 0 to 1
	return (charge / MAX_CHARGE)
	
func currentDrain():
	# returned as a float from 0 to 1
	return (drain / MAX_DRAIN)
	
func cycleLights():
	# move to next status if we can
	if charge <= 0:
		status = LIGHT_STATUS.Off
		return LIGHT_STATUS.Off
	if status == LIGHT_STATUS.Off:
		status = LIGHT_STATUS.Normal
	elif status == LIGHT_STATUS.Normal:
		status = LIGHT_STATUS.Circle
	else:
		# must be circle
		status = LIGHT_STATUS.Off
	return status
	
func update(delta):
	drain = 0
	if status == LIGHT_STATUS.Off:
		charge -= (LIGHT_COST * delta)
		drain += LIGHT_COST
		if fullbeam == true:
			charge -= (FULLBEAM_COST * delta)
			drain += FULLBEAM_COST
	charge = max(0, charge)

func switchFullbeam():
	# return new status
	fullbeam = !fullbeam
	if status != LIGHT_STATUS.Off:
		return fullbeam
	# lights are off
	return false

func lightsOff():
	fullbeam = false
	status = LIGHT_STATUS.Off

func reset():
	fullbeam = false
	charge = MAX_CHARGE
	status = LIGHT_STATUS.Off
	drain = 0
