extends Node

class_name RocketOff

var fuel
var temp
var firing_rocket

func _init():
	fuel = FuelTankOff.new()
	temp = RocketTemperatureOff.new()
	firing_rocket = false
		
func update(delta: float, energy: float) -> void:
	pass
			
func canFireRocket() -> bool:
	return false
	
func canTurn() -> bool:
	return false
	
func reset() -> void:
	pass
