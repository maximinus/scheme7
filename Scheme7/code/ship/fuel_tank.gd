extends Node

class_name FuelTank

const STARTING_FUEL = 5000.0
const ROCKET_CONSUMPTION = 50.0
	
var fuel = STARTING_FUEL
var burning = false
	
func _init():
	pass
	
func fuelLeft():
	return fuel / STARTING_FUEL
	
func fuelDrain():
	# always max if rocket is on
	if burning == true:
		return 1.0
	else:
		return 0.0
	
func update(delta, rocket_on):
	if rocket_on == true:
		fuel = max(0, fuel - (ROCKET_CONSUMPTION * delta))
		burning = true
	else:
		burning = false

func haveFuel():
	if fuelLeft() <= 0.0:
		return false
	return true

func reset():
	fuel = STARTING_FUEL
	burning = false
