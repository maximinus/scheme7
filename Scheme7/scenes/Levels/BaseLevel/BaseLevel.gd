extends Node2D

func _ready():
	$Player.processing = true
	setupObjectives()

func setupObjectives():
	var texts = []
	for i in objectives:
		texts.append(i[0])
	Globals.level.objectives = texts
	Globals.level.callback = funcref(self, 'testObjectives')
	$CanvasLayer/Objectives.setup()

# we need to handle level objectives here.
# So first the code to check each objective
# each of these returns a bool
func checkLightsOn() -> bool:
	if Globals.ship.battery.status != BatteryCharge.LIGHT_STATUS.Off:
		return true
	return false

func checkLightCircle() -> bool:
	if Globals.ship.battery.status == BatteryCharge.LIGHT_STATUS.Circle:
		return true
	return false

func checkHeadlightOn() -> bool:
	if Globals.ship.battery.status != BatteryCharge.LIGHT_STATUS.Off:
		if Globals.ship.battery.fullbeam == true:
			return true
	return false

func testObjectives() -> bool:
	# returns true if a mission objective completes
	# take the first and check it
	var data = objectives[0]
	# call the first argument
	if data[1].call_func() == false:
		# nothing to do
		return false
	# remove this objective
	objectives.pop_front()
	return true

# finally, we need dump the results out here into an array
# the second entry to the array is the function that checks
var objectives = [
	['Turn on lights [L]', 			funcref(self, 'checkLightsOn')],
	['Turn on surround lights [L]',	funcref(self, 'checkLightCircle')],
	['Turn on headlights [K]',		funcref(self, 'checkHeadlightOn')]
]

func _on_Objectives_mission_complete():
	$CanvasLayer/MissionComplete.show()
	$CanvasLayer/MissionComplete.playAnim()
