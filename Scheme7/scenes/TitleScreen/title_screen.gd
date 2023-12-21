extends Node2D

const MAX_TRAIL_SIZE: float = 1300.0

var trail_scene = preload('res://scenes/TitleScreen/intro_trail.tscn')
var trail_colors = [Vector4(0.7, 0.47, 0.23, 1.0),
					Vector4(0.47, 0.25, 0.01, 1.0),
					Vector4(0.28, 0.17, 0.07, 1.0),
					Vector4(0.95, 0.8, 0.64, 1.0),
					Vector4(1.0, 0.72, 0.43, 1.0),
					Vector4(0.2, 0.24, 0.48, 1.0),
					Vector4(0.05, 0.09, 0.32, 1.0),
					Vector4(0.46, 0.5, 0.65, 1.0),
					Vector4(0.39, 0.45, 0.77, 1.0),
					Vector4(0.2, 0.24, 0.48, 1.0),
					Vector4(0.05, 0.2, 0.11, 1.0),
					Vector4(0.01, 0.34, 0.13, 1.0),
					Vector4(0.46, 0.69, 0.55, 1.0),
					Vector4(0.34, 0.8, 0.52, 1.0),
					Vector4(0.16, 0.51, 0.29, 1.0)]
var arrows: Array = []
var option_index: int = 0
var can_continue: bool = false

func _ready():
	var xpos: float = 32.0
	for i in range(20):
		var new_trail = trail_scene.instantiate()
		new_trail.setBallColor(getRandomColor())
		new_trail.setSpeed(getRandomSpeed())
		new_trail.size = randi_range(0, int(MAX_TRAIL_SIZE) - 1)
		new_trail.position = Vector2(xpos, 0.0)
		$Trails.add_child(new_trail)
		xpos += 64.0
	arrows.append($Control/Margin/VBox/Choice/Arrow1)
	arrows.append($Control/Margin/VBox/Choice2/Arrow2)
	arrows.append($Control/Margin/VBox/Choice3/Arrow3)
	arrows.append($Control/Margin/VBox/Choice4/Arrow4)
	# grey out continue option if needed
	if can_continue == false:
		$Control/Margin/VBox/Choice2/Text.label_settings.font_color = Color(0.4, 0.4, 0.4)
	$Music.play()
	# assume player starts with new game
	Scenes.addInitialScenes()

func _process(_delta):
	for i in $Trails.get_children():
		if i.size > MAX_TRAIL_SIZE:
			i.reset(getRandomColor(), getRandomSpeed())
	var old_index = option_index
	if Input.is_action_just_pressed('Up'):
		option_index -= 1
		if option_index == 1 and can_continue == false:
			option_index -= 1
	if Input.is_action_just_pressed('Down'):
		option_index +=1
		if option_index == 1 and can_continue == false:
			option_index += 1
	if old_index != option_index:
		update_arrows()
		$Next.play()
	if Input.is_action_just_pressed('Enter'):
		# do what we have to
		$Chosen.play()
		doSelection()

func doSelection():
	if option_index == 0:
		$FadeScreen.play('fade')
	elif option_index == 3:
		get_tree().quit()

func update_arrows():
	# check index is in range
	option_index = option_index % 4
	for i in arrows:
		i.modulate.a = 0.0
	arrows[option_index].modulate.a = 1.0

func getRandomColor():
	return trail_colors[randi() % 15]

func getRandomSpeed():
	return randi_range(150, 250)

func _on_fade_screen_animation_finished(anim_name):
	# this means we can start the first scene (it is setup by now)
	Scenes.moveToNextScene()
