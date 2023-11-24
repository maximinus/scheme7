extends Node

class_name RocketTemperature

const NOZZLE_HEATING: float = 8.0
const NOZZLE_COOLING: float = 3.0
const MAX_NOZZLE_TEMP: float = NOZZLE_HEATING * 12.0

const INJECTION_HEATING: float = 4.0
const INJECTION_COOLING: float = 1.0
const MAX_INJECTION_TEMP: float = INJECTION_HEATING * 15.0
	
var nozzle_temp: float = 0.0
var injection_temp: float = 0.0

func _init(start_nozzle:float, start_injection: float) -> void:
	nozzle_temp = start_nozzle
	injection_temp = start_injection
	
func update(energy: float, delta: float) -> void:
	if energy <= 0:
		nozzle_temp = max(0, nozzle_temp - (NOZZLE_COOLING * delta))
		injection_temp = max(0, injection_temp - (INJECTION_COOLING * delta))
	else:
		nozzle_temp += (energy * NOZZLE_HEATING) * delta
		injection_temp += (energy * INJECTION_HEATING) * delta
	
func reset() -> void:
	nozzle_temp = 0
	injection_temp = 0
