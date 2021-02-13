extends Node

class_name FuelTank

const STARTING_FUEL: float = 5000.0
const ROCKET_CONSUMPTION: float = 50.0
	
var fuel: float = STARTING_FUEL
var burning: bool = false
	
func _init() -> void:
	pass
	
func fuelLeft() -> float:
	return fuel / STARTING_FUEL
	
func fuelDrain() -> float:
	# always max if rocket is on
	if burning == true:
		return 1.0
	else:
		return 0.0
	
func update(delta, rocket_on) -> void:
	if rocket_on == true:
		fuel = max(0, fuel - (ROCKET_CONSUMPTION * delta))
		burning = true
	else:
		burning = false

func haveFuel() -> bool:
	if fuelLeft() <= 0.0:
		return false
	return true

func reset() -> void:
	fuel = STARTING_FUEL
	burning = false
