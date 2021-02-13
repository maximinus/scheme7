extends Node

class_name Rocket

const ROCKET_FORCE = 1.6

var fuel = FuelTank.new()
var temp = RocketTemperature.new(0.0, 0.0)
var working = true
var can_turn = true
var firing_rocket = false
	
func _init():
	pass
		
func update(delta, energy):
	if energy > 0.0 == true and working == true:
		firing_rocket = true
	else:
		firing_rocket = false
	fuel.update(delta, firing_rocket)
	temp.update(energy, delta)
			
func canFireRocket():
	if working == false:
		return false
	return fuel.haveFuel()
	
func canTurn():
	return can_turn
	
func reset():
	fuel.reset()
	temp.reset()
	
func getForceVector(rotation):
	var x_force = sin(rotation) * ROCKET_FORCE
	var y_force = cos(rotation) * -ROCKET_FORCE
	return Vector2(x_force, y_force)
