extends CanvasModulate

export(Color, RGBA) var game_color
export(Color, RGBA) var pause_color

func _ready():
	color = game_color


func _on_PauseScreen_paused():
	print('Pause')
	color = pause_color

func _on_PauseScreen_unpaused():
	color = game_color
	print('Unpause')
