extends Node

class_name RocketTemperature

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
