extends Node2D

var index: int
var dialog_parts: Array

func _ready():
	$Player.processing = true
	index = 0
	dialog_parts = Dialog.loadDialog('tutorials/engine_test.json')
	$CanvasLayer/OverlayDialog.setup(dialog_parts)

func _process(_delta):
	# advance dialog if enter pressed
	if Input.is_action_just_pressed('Enter'):
		$CanvasLayer/OverlayDialog.next()

func setupObjectives():
	$CanvasLayer/Objectives.setup(objectives)

# we need to handle level objectives here.
# So first the code to check each objective
# each of these returns a bool
func takeOff() -> bool:
	# vertical speed above some value, and not landed
	if Globals.ship.status.landed == true:
		return false
	if $Player.velocity.y < -50.0:
		return true
	return false

func someTest() -> bool:
	return false

# finally, we need dump the results out here into an array
# the second entry to the array is the function that checks
var objectives = [
	['Take Off [W]', 	Callable(self, 'someTest')],
]

func _on_Objectives_mission_complete():
	$CanvasLayer/MissionComplete.show()
	$CanvasLayer/MissionComplete.playAnim()
