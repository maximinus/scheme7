extends Node2D

const OBJ_SCENE = preload('res://scenes/PlayerUI/MissionObjectives/Objective/ObjectiveLabel.tscn')

const SCREEN_WIDTH = 1024
const SCREEN_HEIGHT = 600
const MARGIN = 32

var lander_pos = Vector2(1224.0, 2304.0)
var lander_found = false
var objectives = []
var index = 0

func _ready():
	var txt_objectives = Globals.level.getObjectives()
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
		1.5, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	index -= 1

func downloaded():
	moveTopLabel()

func _process(_delta):
	if lander_found == true:
		return
	var player_pos = Globals.ship.position
	var delta_distance = player_pos - lander_pos
	var distance = delta_distance.length()
	if distance < 360:
		lander_found = true
		moveTopLabel()
