extends Node

class_name FuelTankOff
	
# void class, handles same API
func fuelLeft() -> float:
	return 0.0
	
func fuelDrain() -> float:
	return 0.0
	
func update(_delta: float, _rocket_on: bool) -> void:
	pass

func haveFuel() -> bool:
	return true

func reset() -> void:
	pass
