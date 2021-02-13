extends Node

# outside influences need to instance this ship and level
var ship: Ship = Ship.new(Rocket.new(), BatteryCharge.new(), Shield.new())
var level: Level = Level.new()
