extends Node2D

const SQUARES = 26
const BATTERY_PER_SQUARE = 1.0 / SQUARES
const DIAL_WIDTH = 335.0
const BLOCKS = 26
const BLOCK_WIDTH = 13

var battery
var fuel

func _ready():
	battery = Globals.player.battery
	fuel = Globals.player.rocket.fuel

func _process(delta):
	displayBattery(delta)
	displayFuel(delta)

func displayBattery(delta):
	battery.update(delta)
	var charge = battery.chargeLeft()
	var drain = battery.currentDrain()
	
	var pos = drain * DIAL_WIDTH
	$Battery/BatteryIndicator.position.x = pos
	$Battery/BatteryLevelThick.region_rect.end.x = pos

	# how many blocks to show?
	var blocks = int(ceil(charge * BLOCKS))
	$Battery/BatteryLevel.region_rect.end.x = max(0, (blocks * BLOCK_WIDTH) - 3)

func displayFuel(delta):
	var fuel_left = fuel.fuelLeft()
	var drain = fuel.fuelDrain()
	
	var pos = drain * DIAL_WIDTH
	$Fuel/FuelIndicator.position.x = pos
	$Fuel/FuelLevelThick.region_rect.end.x = pos
	
	var blocks = int(ceil(fuel_left * BLOCKS))
	$Fuel/FuelLevel.region_rect.end.x = max(0, (blocks * BLOCK_WIDTH) - 3)
