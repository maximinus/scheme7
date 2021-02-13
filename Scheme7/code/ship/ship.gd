extends Node

class_name Ship

var rocket
var battery
var shield
	
var last_force: Vector2 = Vector2(0.0, 0.0)
var position: Vector2 = Vector2(0, 0)
	
func _init(r, b, s):
	rocket = r
	battery = b
	shield = s
		
func calculateSystemFailure(_speed: float, _pos: Vector2) -> void:
	pass

func reset() -> void:
	last_force = Vector2(0.0, 0.0)
	rocket.reset()
	battery.reset()
	shield.reset()
	position = Vector2(0.0, 0.0)
