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
	
	func reset():
		nozzle_temp = 0
		injection_temp = 0


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

	func reset():
		lights = false
		fullbeam = false
		charge = MAX_CHARGE
		drain = 0

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

	func reset():
		fuel = STARTING_FUEL
		burning = false

class Shield:
	# shield - an electrical shield to protect
	# struct - structure of external frame
	# internal - the rest
	# ship is dead when internal is all gone
	
	# Damage as follows:
	# all damage goes to struct up to 50%
	# from 50% lower on struct, internals takes 30%
	# When struct is zero, internals takes over
	
	const MAX_SHIELD = 1000.0
	const MAX_STRUCT = 700.0
	const HALF_STRUCT = MAX_STRUCT / 2.0
	const MAX_INTERNALS = 1000.0
	const HALF_INTERNALS = MAX_INTERNALS / 2.0
	const SPEED_CUTOFF = 30.0
	const SPEED_DAMAGE_RATIO = 1.0
	
	var shield = 0
	var struct = MAX_STRUCT
	var internals = MAX_INTERNALS
	var last_speed = 0

	func _init():
		pass

	func update(player, collider):
		# called when a collision happens
		# we need the speed of the object and the player
		player -= collider
		var speed = abs(player.x) + abs(player.y)
		if speed == last_speed:
			# ignore this extra collision
			return internals <= 0
		if speed <= SPEED_CUTOFF:
			# not fast enough to cause damage
			return internals <= 0
		# damage is half the speed
		updateDamage(speed * SPEED_DAMAGE_RATIO)
		last_speed = speed
		return internals <= 0
	
	func updateDamage(damage_amount):
		if struct <= 0:
			internals = max(0.0, internals - damage_amount)
			return
		elif struct > (HALF_STRUCT + damage_amount):
			struct -= damage_amount
			return
		elif struct > HALF_STRUCT:
			# some of the damage will go to the internals
			var delta = struct - HALF_STRUCT
			damage_amount -= delta
			struct = HALF_STRUCT
		# share between struct and internals
		var sdamage = 0.7 * damage_amount
		var idamage = 0.3 * damage_amount
		if sdamage > struct:
			idamage += sdamage - struct
			struct = 0.0
		else:
			struct -= sdamage
		internals = max(0.0, internals - idamage)
	
	func getShield():
		return shield / MAX_SHIELD
	
	func getStruct():
		return struct / MAX_STRUCT
	
	func getInternals():
		return internals / MAX_INTERNALS
	
	func getDamageFrame():
		# return the frame used to draw the ship showing damage
		if struct > 0:
			var frame = ceil((struct / MAX_STRUCT) * 5.0)
			# gives 1 to 5, with 5 being best
			return 5 - frame
		# no struct
		if internals > HALF_INTERNALS:
			return 5
		# worst damage
		return 6

	func reset():
		shield = 0
		struct = MAX_STRUCT
		internals = MAX_INTERNALS
		last_speed = 0

class EnergyShield:
	func _init():
		pass
	
	func canUse():
		return false
	
	func reset():
		pass

class Gun:
	func _init():
		pass
	
	func canFire():
		return true
		
	func reset():
		pass

class Player:
	var rocket = RocketTemperature.new(0, 0)
	var battery = BatteryCharge.new()
	var fuel = FuelTank.new()
	var shield = Shield.new()
	var energy = EnergyShield.new()
	var gun = Gun.new()
	
	func _init():
		pass
		
	func calculateSystemFailure(speed, position):
		pass

func reset():
	last_force = Vector2(0, 0)
	rocket.reset()
	battery.reset()
	fuel.reset()
	shield.reset()

class Level:
	func _init():
		# probably need to load from json here
		pass
	
	func getObjectives():
		return ['Find landing point',
				'Download data',
				'Leave Cavern']
		

var last_force = Vector2(0, 0)
var rocket = RocketTemperature.new(0, 0)
var battery = BatteryCharge.new()
var fuel = FuelTank.new()
var shield = Shield.new()

func _ready():
	pass
