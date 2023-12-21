extends Label


const HIGHLIGHT_COLOR = Color(0.7, 0.55, 0.55)
const NORMAL_COLOR = Color(0.49, 0.26, 0.26)


func _ready():
	pass

func setText(txt):
	text = txt

func setHighlight():
	label_settings.font_color = HIGHLIGHT_COLOR

func setNormal():
	label_settings.font_color = NORMAL_COLOR
