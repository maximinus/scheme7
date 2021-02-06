extends Node2D

const OBJ_SCENE = preload('res://scenes/PlayerUI/MissionObjectives/Objective/ObjectiveLabel.tscn')

const SCREEN_WIDTH = 1024
const SCREEN_HEIGHT = 600
const MARGIN = 32

var lander_pos = Vector2(1224.0, 2304.0)

var objectives = []

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
	moveTopLabel()

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
	var tween = Tween.new()
	var node = objectives[-1]
	add_child_below_node(node, tween)
	var from = node.rect_position
	var distance = node.rect_size.x + MARGIN
	var to = Vector2(from.x + distance, from.y)
	tween.interpolate_property(node, 'rect_position', from, to,
		1.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.connect('tween_completed', self, 'tweenComplete')
	tween.start()

func tweenComplete():
	# top animation is done
	var node = objectives.pop_back()
	node.queue_free()

func _process(delta):
	#if lander_found == true:
	#	return
	#var delta_distance = $Player.position - $Lander.position
	#var distance = pow(delta_distance.x, 2.0) + pow(delta_distance.y, 2.0)
	#distance = sqrt(distance)
	#if distance < 360:
	#	lander_found = true
	#	$Lander.startAnimation()
	#	$UILayer/MissionObjectives.slideOff()
	pass
