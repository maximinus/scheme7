extends Node

class RocketTemperature:
	const NOZZLE_HEATING = 8
	const NOZZLE_COOLING = 3
	const MAX_NOZZLE_TEMP = NOZZLE_HEATING * 12.0

	const INJECTION_HEATING = 4
	const INJECTION_COOLING = 1
	const MAX_INJECTION_TEMP = INJECTION_HEATING * 15.0
	
	var nozzle_temp = 0
	var injection_temp = 0
	
	func _init(start_nozzle , start_injection):
		nozzle_temp = start_nozzle
		injection_temp = start_injection
	
	func update(energy, delta):
		if energy <= 0:
			nozzle_temp = max(0, nozzle_temp - (NOZZLE_COOLING * delta))
			injection_temp = max(0, injection_temp - (INJECTION_COOLING * delta))
		else:
			nozzle_temp += (energy * NOZZLE_HEATING) * delta
			injection_temp += (energy * INJECTION_HEATING) * delta


class BatteryCharge:
	const LIGHT_COST = 5.0
	const FULLBEAM_COST = 6.0
	const MAX_DRAIN = 30.0
	const MAX_CHARGE = 1000.0
	
	var lights = false
	var fullbeam = false
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
	
	func update(delta):
		drain = 0
		if lights == true:
			charge -= (LIGHT_COST * delta)
			drain += LIGHT_COST
			if fullbeam == true:
				charge -= (FULLBEAM_COST * delta)
				drain += FULLBEAM_COST
		charge = max(0, charge)

class FuelTank:
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

class Shield:
	const STARTING_SHIELD = 1000.0
	const STARTING_STRUCT = 700.0
	const STARTING_INTERNALS = 1000.0
	
	var shield = STARTING_SHIELD
	var struct = STARTING_STRUCT
	var internals = STARTING_INTERNALS
	
	func update(player, collider):
		# called when a collision happens
		# we need the speed of the object and the player
		var speed = abs(player.x) + abs(player.y)
	
	func _init():
		pass

var last_force = Vector2(0, 0)
var rocket = RocketTemperature.new(0, 0)
var battery = BatteryCharge.new()
var fuel = FuelTank.new()
var shield = Shield.new()

func _ready():
	pass
