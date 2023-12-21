extends CanvasModulate

@export var game_color # (Color, RGBA)
@export var pause_color # (Color, RGBA)

func _ready():
	color = game_color


func _on_PauseScreen_paused():
	print('Pause')
	color = pause_color

func _on_PauseScreen_unpaused():
	color = game_color
	print('Unpause')
