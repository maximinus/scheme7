extends Node2D

var index: int

func _ready():
	$Player.processing = true
	index = 0
	setupObjectives()

func setupObjectives():
	var texts = []
	for i in objectives:
		texts.append(i[0])
	Globals.level.objectives = texts
	Globals.level.callback = funcref(self, 'testObjectives')
	$CanvasLayer/Objectives.setup()

func testObjectives() -> bool:
	# returns true if a mission objective completes
	# take the first and check it
	var data = objectives[index]
	# call the first argument
	if data[1].call_func() == false:
		# nothing to do
		return false
	# move to next objective
	index += 1
	return true

# we need to handle level objectives here.
# So first the code to check each objective
# each of these returns a bool
func takeOff() -> bool:
	# vertical speed above some value
	if Globals.ship.battery.status != BatteryCharge.LIGHT_STATUS.Off:
		return true
	return false

func moveRight() -> bool:
	# position has changed by some value
	if Globals.ship.battery.status == BatteryCharge.LIGHT_STATUS.Circle:
		return true
	return false

func landOnLander() -> bool:
	# correct landed signal triggered somewhere
	if Globals.ship.battery.status != BatteryCharge.LIGHT_STATUS.Off:
		if Globals.ship.battery.fullbeam == true:
			return true
	return false

# finally, we need dump the results out here into an array
# the second entry to the array is the function that checks
var objectives = [
	['Take Off [W]', 	funcref(self, 'takeOff')],
	['Move Right',		funcref(self, 'moveRight')],
	['Land on lander',	funcref(self, 'landOnLander')]
]

func _on_Objectives_mission_complete():
	$CanvasLayer/MissionComplete.show()
	$CanvasLayer/MissionComplete.playAnim()
