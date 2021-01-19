extends Node

class RocketTemperature:
	const HEATING = 8
	const COOLING = 3
	const MAX_TEMP = HEATING * 12.0
	
	var nozzle_temp = 0
	var injection_temp = 0
	
	func _init(start_nozzle , start_injection):
		nozzle_temp = start_nozzle
		injection_temp = start_injection
	
	func update(energy, delta):
		if energy <= 0:
			nozzle_temp -= COOLING * delta
			if nozzle_temp < 0:
				nozzle_temp = 0
		else:
			nozzle_temp += (energy * HEATING) * delta

var last_force = Vector2(0, 0)
var rocket = RocketTemperature.new(0, 0)

func _ready():
	pass
