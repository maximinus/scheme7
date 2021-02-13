extends Node

class_name Rocket

const ROCKET_FORCE: float = 1.6

var fuel = FuelTank.new()
var temp = RocketTemperature.new(0.0, 0.0)
var working: bool = true
var can_turn: bool = true
var firing_rocket: bool = false
	
func _init() -> void:
	pass
		
func update(delta, energy) -> void:
	if energy > 0.0 == true and working == true:
		firing_rocket = true
	else:
		firing_rocket = false
	fuel.update(delta, firing_rocket)
	temp.update(energy, delta)
			
func canFireRocket() -> bool:
	if working == false:
		return false
	return fuel.haveFuel()
	
func canTurn() -> bool:
	return can_turn
	
func reset() -> void:
	fuel.reset()
	temp.reset()
	
func getForceVector(rotation) -> Vector2:
	var x_force = sin(rotation) * ROCKET_FORCE
	var y_force = cos(rotation) * -ROCKET_FORCE
	return Vector2(x_force, y_force)
