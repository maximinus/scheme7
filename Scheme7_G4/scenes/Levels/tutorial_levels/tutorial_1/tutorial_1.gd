extends Node2D

var index: int

var dialog_text: Array = ['Press <Enter> to move this dialog forward',
						  'First, check the lights',
						  'You can see the objectives in the bottom right',
						  'Press the keys as described',
						  'The tutorial will automatically end']

func _ready():
	$Player.processing = true
	# TODO: Set ship status here
	index = 0
	setupObjectives()
	$CanvasLayer/OverlayDialog.setup(dialog_text)

func _process(_delta):
	# advance dialog if enter pressed
	if Input.is_action_just_pressed('Enter'):
		$CanvasLayer/OverlayDialog.next()

func setupObjectives():
	var texts = []
	#Globals.level.objectives = objectives
	$CanvasLayer/Objectives.setup(objectives)

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
	var data = objectives[index]
	# call the first argument
	if data[1].call_func() == false:
		# nothing to do
		return false
	# move to next objective
	index += 1
	return true

# finally, we need dump the results out here into an array
# the second entry to the array is the function that checks
var objectives = [
	['Turn on lights [L]', 			Callable(self, 'checkLightsOn')],
	['Turn on surround lights [L]',	Callable(self, 'checkLightCircle')],
	['Turn on headlights [K]',		Callable(self, 'checkHeadlightOn')]
]

func _on_Objectives_mission_complete():
	$CanvasLayer/MissionComplete.show()
	$CanvasLayer/MissionComplete.playAnim()
