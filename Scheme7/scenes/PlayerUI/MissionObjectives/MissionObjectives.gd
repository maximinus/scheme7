extends Node2D

const OBJ_SCENE = preload('res://scenes/PlayerUI/MissionObjectives/Objective/ObjectiveLabel.tscn')
const SLIDE_SPEED = 1.0

const SCREEN_WIDTH = 1024
const SCREEN_HEIGHT = 600
const MARGIN = 32

var objectives = []
var index = 0
var callback = null

func _ready():
	pass

func setup():
	var txt_objectives = Globals.level.objectives.duplicate()
	# don't forget we display these backwards
	txt_objectives.invert()
	for i in txt_objectives:
		# create a label
		var obj_label = OBJ_SCENE.instance()
		# set text
		obj_label.setText(i)
		# add position
		setPosition(obj_label)
		objectives.append(obj_label)
		add_child(obj_label)
		index = len(objectives) - 1
	callback = Globals.level.callback

func reset():
	# move all objectives back to correct place
	$Tween.stop_all()
	for i in objectives:
		var size = i.get_minimum_size()
		i.rect_position.x = SCREEN_WIDTH - (size.x + MARGIN)
	index = len(objectives) - 1

func setPosition(label_node):
	var size = label_node.get_minimum_size()
	var xpos = SCREEN_WIDTH - (size.x + MARGIN)
	var ypos = SCREEN_HEIGHT - MARGIN
	for i in objectives:
		ypos -= i.get_minimum_size().y
	ypos -= size.y
	label_node.rect_position = Vector2(xpos, ypos)

func moveTopLabel():
	# the top label is the last one in the list
	var node = objectives[index]
	var from = node.rect_position
	var distance = node.rect_size.x + MARGIN
	var to = Vector2(from.x + distance, from.y)
	$Tween.interpolate_property(node, 'rect_position', from, to,
		SLIDE_SPEED, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	index -= 1

func _process(_delta):
	if index >= 0:
		if callback.call_func() == true:
			moveTopLabel()
	# we have completed all objectives
