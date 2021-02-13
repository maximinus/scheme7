extends Node

var ShieldClass = load('res://code/ship/shield.gd')
var RocketTempClass = load('res://code/ship/rocket_temp.gd')
var FuelClass = load('res://code/ship/fuel_tank.gd')
var RocketClass = load('res://code/ship/rocket.gd')
var BatteryChargeClass = load('res://code/ship/battery_charge.gd')


class Level:
	func _init():
		# probably need to load from json here
		pass
	
	func getObjectives():
		return ['Leave Cavern',
				'Download data',
				'Find landing point']

var ship = Ship.new(Rocket.new(), BatteryCharge.new(), ShieldClass.new())
var level = Level.new()

func _ready():
	pass
