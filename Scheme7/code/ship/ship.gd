extends Node

class_name Ship

class Status:
	var landing: bool
	var landed: bool
	var takeoff: bool
	var electrified: bool
	
	func _init() -> void:
		landing = false
		landed = false
		takeoff = false
		electrified = false
		
var rocket
var battery
var shield
var gun
var status
	
var last_force: Vector2 = Vector2(0.0, 0.0)
var position: Vector2 = Vector2(0, 0)

func _init(r, b, s, g):
	rocket = r
	battery = b
	shield = s
	gun = g
	status = Status.new()

func calculateSystemFailure(_speed: float, _pos: Vector2) -> void:
	pass

func reset() -> void:
	rocket.reset()
	battery.reset()
	shield.reset()
	last_force = Vector2(0.0, 0.0)
	position = Vector2(0.0, 0.0)
	status = Status.new()
