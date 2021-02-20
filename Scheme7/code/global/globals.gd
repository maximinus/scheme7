extends Node

# outside influences need to instance this ship and level
class GameWorld:
	# the world outside the player
	func _init():
		pass

var ship: Ship = Ship.new(Rocket.new(),
						  BatteryCharge.new(),
						  Shield.new(),
						  Guns.new())

var level: Level = Level.new()
var world: GameWorld = GameWorld.new()
