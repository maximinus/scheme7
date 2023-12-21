extends Node2D

# example of a level - in this case used for tutorials
# it may or may not need some documentation, which is loaded in _ready
# you need some objectives; they are hard-coded as functions that return
# true or false if they have been passed, and these are put in a list as
# can be seen in "objectives" as below
# Finally, attach the callback _on_Objectives_mission_complete to fire
# the "mission complete" animation
# Everything else is thus handled for you

# For making the level, you need to:
# 1: Re-make the background so the shader covers the level
# 2: Add the maptiles as required
# 3: Add objects to level; typically grouped, as for example "lights" here
# 4: Save this file as a new file in a new place
# 5: Remove the code attached to the root node and add a new one
#   (you can cut and paste much of this code)

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
