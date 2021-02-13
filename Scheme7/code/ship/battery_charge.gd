extends Node

enum LIGHT_STATUS { Normal, Circle, Off }

class_name BatteryCharge

const LIGHT_COST: float = 5.0
const FULLBEAM_COST: float = 6.0
const MAX_DRAIN: float = 30.0
const MAX_CHARGE: float = 1000.0
const FULLBEAM_ENERGY: float = 2.0
const LIGHT_ENERGY: float = 1.0

var fullbeam: bool = false
var status: int = LIGHT_STATUS.Off
var charge: float = MAX_CHARGE
var drain: float = 0.0
	
func _init() -> void:
	pass
	
func chargeLeft() -> float:
	# returned as a float from 0 to 1
	return (charge / MAX_CHARGE)
	
func currentDrain() -> float:
	# returned as a float from 0 to 1
	return (drain / MAX_DRAIN)
	
func cycleLights() -> int:
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
	
func update(delta) -> void:
	drain = 0
	if status == LIGHT_STATUS.Off:
		charge -= (LIGHT_COST * delta)
		drain += LIGHT_COST
		if fullbeam == true:
			charge -= (FULLBEAM_COST * delta)
			drain += FULLBEAM_COST
	charge = max(0, charge)

func getFullbeam() -> float:
	# return energy level
	fullbeam = !fullbeam
	if status != LIGHT_STATUS.Off:
		if fullbeam == true:
			return FULLBEAM_ENERGY
		else:
			return LIGHT_ENERGY
	# lights are off
	return 0.0

func lightsOff() -> void:
	fullbeam = false
	status = LIGHT_STATUS.Off

func reset() -> void:
	fullbeam = false
	charge = MAX_CHARGE
	status = LIGHT_STATUS.Off
	drain = 0.0
