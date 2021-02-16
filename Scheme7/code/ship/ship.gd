extends Node

class_name Ship

enum Status {Landing=0, Landed=1, Takeoff=3, Electrified=4}

var rocket
var battery
var shield
var gun
var status_effects
	
var last_force: Vector2 = Vector2(0.0, 0.0)
var position: Vector2 = Vector2(0, 0)
	
func _init(r, b, s, g):
	rocket = r
	battery = b
	shield = s
	gun = g
	status_effects = []
	for i in range(Status.Electrified - 1):
		status_effects.append(false)
		
func calculateSystemFailure(_speed: float, _pos: Vector2) -> void:
	pass

func reset() -> void:
	last_force = Vector2(0.0, 0.0)
	rocket.reset()
	battery.reset()
	shield.reset()
	position = Vector2(0.0, 0.0)

func getStatus(status: int) -> bool:
	return status_effects[status]

func setStatus(status: int, value: bool) -> void:
	status_effects[status] = value

func invertStatus(status: int):
	status_effects[status] = !status_effects[status]
