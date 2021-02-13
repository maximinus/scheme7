extends Node

class_name BatteryChargeOff
	
func _init() -> void:
	pass
	
func chargeLeft() -> float:
	# returned as a float from 0 to 1
	return 0.0
	
func currentDrain() -> float:
	# returned as a float from 0 to 1
	return 0.0
	
func cycleLights() -> int:
	return BatteryCharge.LIGHT_STATUS.Off
	
func update(_delta: float) -> void:
	pass

func getFullbeam() -> float:
	# return energy level
	return 0.0

func lightsOff() -> void:
	pass

func reset() -> void:
	pass
