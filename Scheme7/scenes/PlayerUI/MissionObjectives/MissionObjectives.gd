extends Node2D

const OBJ_SCENE = preload('res://scenes/PlayerUI/MissionObjectives/Objective/ObjectiveLabel.tscn')
const SLIDE_SPEED = 1.0

const SCREEN_WIDTH = 1280
const SCREEN_HEIGHT = 800
const MARGIN = 48

signal mission_complete

var objectives = []
var labels = []
var objective_index: int
var complete: bool
var move_tween: Tween

func _ready():
	move_tween = null
	complete = true
	# it fires at zero, so set to 1 to start
	objective_index = 0


func _process(_delta):
	if complete == true:
		return
	checkObjectives()


func checkObjectives():
	var objective_passed_test = objectives[objective_index][1]
	if objective_passed_test.call() == true:
		moveTopLabel()
		labels[objective_index].setNormal()
		if objective_index == 0:
			$AllCompleted.play()
			emit_signal('mission_complete')
			complete = true
		else:
			$ObjectiveComplete.play()
			objective_index -= 1
			labels[objective_index].setHighlight()
		
func setup(passed_objectives):
	objectives = passed_objectives
	# add in a warning if we are missing an item
	if len(objectives) == 0:
		print('Error: No objective set')
		return
	# don't forget we display these backwards
	objectives.reverse()
	for i in objectives:
		# create a label
		var obj_label = OBJ_SCENE.instantiate()
		# set text
		obj_label.setText(i[0])
		# add position
		setPosition(obj_label)
		labels.append(obj_label)
		add_child(obj_label)
	objective_index = len(objectives) - 1
	labels[objective_index].setHighlight()
	complete = false

func reset():
	# move all objectives back to correct place
	if move_tween != null:
		move_tween.kill()
	for i in labels:
		var size = i.get_minimum_size()
		i.position.x = SCREEN_WIDTH - (size.x + MARGIN)
	objective_index = len(objectives) - 1

func setPosition(label_node):
	# the position should be a fixed value away from the right hand side
	var size = label_node.get_minimum_size()
	var xpos = SCREEN_WIDTH - (size.x + MARGIN)	
	var ypos = SCREEN_HEIGHT - MARGIN
	for i in labels:
		ypos -= i.get_minimum_size().y
	ypos -= size.y
	label_node.position = Vector2(xpos, ypos)

func moveTopLabel():
	var node = labels[objective_index]
	var from = node.position
	var distance = node.size.x + MARGIN
	var to = Vector2(from.x + distance, from.y)
	node.position = from
	move_tween = get_tree().create_tween()
	move_tween.set_ease(Tween.EASE_IN)
	move_tween.set_trans(Tween.TRANS_QUAD)
	move_tween.tween_property(node, 'position', to, SLIDE_SPEED)
