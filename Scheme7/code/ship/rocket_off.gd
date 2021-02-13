extends Node

class_name RocketOff

var fuel
var temp

func _init():
	fuel = FuelTankOff.new()
	temp = RocketTemperatureOff.new()
		
func update(delta: float, energy: float) -> void:
	pass
			
func canFireRocket() -> bool:
	return false
	
func canTurn() -> bool:
	return false
	
func reset() -> void:
	pass
